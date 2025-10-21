local Timer = require "timer"

local discordia = require "discordia"
local client = require "client"
local logger = require "logger"

local guilds = require "storage/guilds"
local lobbies = require "storage/lobbies"
local channels = require "storage/channels"

local greetingResponse = require "response/greeting"
local warningResponse = require "response/warning"
local passwordResponse = require "response/password"

local matchmakers = require "utils/matchmakers"

local Mutex = discordia.Mutex
local enums = discordia.enums
local permission = enums.permission
local channelType = enums.channelType

local adjustHostPermissions = require "channelUtils/adjustHostPermissions"
local handleTemplate = require "channelUtils/handleTemplate"

local Overseer = require "utils/logWriter"
local ratelimiter = require "utils/ratelimiter"

local queue = {}

ratelimiter("channelCreate", 2, 20)

local function lobbyJoinCall (member, lobby)
	logger:log(4, "GUILD %s LOBBY %s USER %s: joined", lobby.guild.id, lobby.id, member.user.id)

	local guild = lobby.guild
	local lobbyData = lobbies[lobby.id]
	local guildData = guilds[guild.id]

	if lobbyData.limit <= #lobbyData.children then
		logger:log(4, "GUILD %s LOBBY %s USER %s: lobby room limit reached", lobby.guild.id, lobby.id, member.user.id)
		return
	end

	if guildData.limit <= guildData:channels() then
		logger:log(4, "GUILD %s LOBBY %s USER %s: guild room limit reached", lobby.guild.id, lobby.id, member.user.id)
		return
	end

	-- parent to which a new channel will be attached
	local target = client:getChannel(lobbies[lobby.id].target) or lobby.category or guild

	-- determine new channel name
	local name = lobbyData.template or "%nickname's% room"
	-- potential position may change in process of name generation, so rather than query lobby for position several times, reservation is made and used throughout
	local position = lobbyData:attachChild(true)
	local needsMove

	if name:match("%%.-%%") then
		needsMove = name:match("%%counter%%") and true
		name = handleTemplate(name, member, position):match("^%s*(.-)%s*$")
		if name == "" then name = handleTemplate("%nickname's% room", member) end
	end

	-- determine channel position if %counter% is detected
	local distance = 0
	if needsMove then
		local children = lobbyData.children
		repeat
			distance = distance + 1
			if not (children[position + distance] == nil or client:getChannel(children[position + distance].id)) then
				children:drain(position + distance)
			end
		until children[position + distance] ~= nil or position + distance > children.max

		if position + distance > children.max then
			needsMove = nil
		else
			distance = client:getChannel(lobbyData.children[position + distance].id).position - 1
		end
	end

	local newChannel, err = guild:createChannel({
		name = name,
		type = channelType.voice,
		bitrate = lobbyData.bitrate or lobby.bitrate,
		user_limit = lobbyData.capacity or lobby.userLimit,
		position = needsMove and distance or nil,
		parent_id = target.id
	})

	if not newChannel then
		lobbyData:detachChild(position)
		logger:log(2, "GUILD %s LOBBY %s USER %s: couldn't create new room - %s", guild.id, lobby.id, member.user.id, err)
		return
	end

	local mutex = Mutex()
	queue[newChannel.id] = mutex
	mutex:lock()
	local timer = mutex:unlockAfter(10000)

	member:setVoiceChannel(newChannel.id)

	local companion
	if lobbyData.companionTarget then
		-- this might look familiar
		local companionTarget = lobbyData.companionTarget == true and (newChannel.category or guild) or client:getChannel(lobbyData.companionTarget)

		if companionTarget then
			local name = lobbyData.companionTemplate or "private-chat"
			if name:match("%%.-%%") then
				name = handleTemplate(name, member, position):discordify()
				if name == "" then name = "private-chat" end
			end

			companion = guild:createChannel {
				name = name,
				type = channelType.text,
				parent_id = companionTarget.id
			}
		end
	end

	-- save channel data, attach to parent
	channels:store(newChannel.id, 0, member.user.id, lobby.id, position, companion and companion.id or nil)
	lobbyData:attachChild(channels[newChannel.id], position)

	newChannel:getPermissionOverwriteFor(guild.me):allowPermissions(permission.connect, permission.readMessages)

	if companion then
		-- companions are private by default
		companion:getPermissionOverwriteFor(guild.me):allowPermissions(permission.readMessages, permission.sendMessages)
		companion:getPermissionOverwriteFor(member):allowPermissions(permission.readMessages)

		if #lobbyData.roles == 0 then
			companion:getPermissionOverwriteFor(guild.defaultRole):denyPermissions(permission.readMessages)
		else for role in pairs(lobbyData.roles) do
			companion:getPermissionOverwriteFor(guild:getRole(role)):denyPermissions(permission.readMessages)
		end end
	end

	adjustHostPermissions(newChannel, member)

	if lobbyData.companionLog then Overseer.track(companion or newChannel) end
	if lobbyData.greeting or lobbyData.companionLog then 
		distance, err = (companion or newChannel):send(greetingResponse(false, member.user.locale, newChannel))
	end

	mutex:unlock()
	Timer.clearTimeout(timer)
	queue[newChannel.id] = nil

	if not distance then logger:log(4, "GUILD %s LOBBY %s USER %s: couldn't send greeting - %s", guild.id, lobby.id, member.user.id, err) end
end



local function lobbyJoin (member, lobby)
	local lobbyData = lobbies[lobby.id]
	local limit, retryIn = ratelimiter:limit("channelCreate", member.user.id)
	if limit == -1 then
		member:setVoiceChannel()
		member.user:send(warningResponse(false, member.user.locale, "wait", retryIn))
		return
	end

	lobbyData.mutex:lock()
	local timer = lobbyData.mutex:unlockAfter(10000)
	local ok, err = xpcall(lobbyJoinCall, debug.traceback, member, lobby)
	lobbyData.mutex:unlock()
	Timer.clearTimeout(timer)
	if not ok then error(string.format('failed to process a user %s joining lobby "%s"\n%s', member.user.id, lobby.id, err)) end
end



local function matchmakingJoin (member, lobby)
	logger:log(4, "GUILD %s mLOBBY %s USER %s: joined", lobby.guild.id, lobby.id, member.user.id)

	local target = client:getChannel(lobbies[lobby.id].target) or lobby.category
	if not target then return end

	local children

	if lobbies[target.id] then
		-- if target is another lobby - matchmake among its children
		children = lobby.guild.voiceChannels:toArray("position", function (channel)
			if channels[channel.id] then
				local parent = client:getChannel(channels[channel.id].parent.id)
				return (parent == target) and (channel.userLimit == 0 or #channel.connectedMembers < channel.userLimit) and member:hasPermission(channel, permission.connect)
			end
		end)
	else
		-- otherwise matchmake in the available channels of category
		children = target.voiceChannels:toArray("position", function (channel)
			return (channel ~= lobby) and (channel.userLimit == 0 or #channel.connectedMembers < channel.userLimit) and member:hasPermission(channel, permission.connect)
		end)
	end

	if #children == 1 then
		if member:setVoiceChannel(children[1]) then
			logger:log(4, "GUILD %s mLOBBY %s USER %s: matchmade", lobby.guild.id, lobby.id, target.id)
		end
	elseif #children > 1 then
		if member:setVoiceChannel((matchmakers[lobbies[lobby.id].template] or matchmakers.random)(children)) then
			logger:log(4, "GUILD %s mLOBBY %s USER %s: matchmade", lobby.guild.id, lobby.id, target.id)
		end
	else	-- if no available channels - create new or kick
		if target.type == channelType.voice then
			logger:log(4, "GUILD %s mLOBBY %s: no available room, delegating to LOBBY %s", lobby.guild.id, lobby.id, target.id)
			client:emit("voiceChannelJoin", member, target)
		else
			logger:log(4, "GUILD %s mLOBBY %s: no available room, gtfo", lobby.guild.id, lobby.id)
			member:setVoiceChannel()
		end
	end
end



local function roomJoin (member, channel)
	local channelData = channels[channel.id]

	if channelData.password and not (
		member:hasPermission(channel, permission.administrator) or
		channel:getPermissionOverwriteFor(member):getAllowedPermissions():has(permission.connect)
 	) then
		logger:log(4, "GUILD %s ROOM %s USER %s: sending password prompt", channel.guild.id, channel.id, member.user.id)
		channel:getPermissionOverwriteFor(member):denyPermissions(permission.connect)

		local newChannel = channel.guild:createChannel {
			name = "Password verification",
			parent_id = (channel.category or channel.guild).id,
			type = channelType.voice,
			permission_overwrites = {
				{
					id = client.user.id,
					type = 1,
					allow = "3146752"
				},
				{
					id = channel.guild.id,
					type = 0,
					deny = "3146752"
				}
			}
		}

		channels:store(newChannel.id, 3, member.user.id, channel.id, 0)
		member:setVoiceChannel(newChannel)

		return member.user:send(passwordResponse(false, member.user.locale, channel))
	end

	logger:log(4, "GUILD %s ROOM %s USER %s: joined", channel.guild.id, channel.id, member.user.id)

	local companion = client:getChannel(channelData.companion)
	if companion and not companion:getPermissionOverwriteFor(member):getDeniedPermissions():has(permission.readMessages) then
		companion:getPermissionOverwriteFor(member):allowPermissions(permission.readMessages)
	end
end



local function channelJoin (member, channel)
	logger:log(4, "GUILD %s CHANNEL %s USER %s: joined", channel.guild.id, channel.id, member.user.id)

	--[[ TODO
	local name = handleTemplate(guilds[channel.guild.id].template, member, position):match("^%s*(.-)%s*$")

	local position = #(channel.category and 
		channel.category.voiceChannels:toArray("position", function (vchannel) return vchannel.position <= channel.position end)
			or
		channel.guild.voiceChannels:toArray("position", function (vchannel) return not vchannel.category and vchannel.position <= channel.position end))
	]]

	channels:store(channel.id, 1, member.user.id, channel.guild.id, 0, nil)

	local perms = guilds[channel.guild.id].permissions:toDiscordia()
	if #perms == 0 or not channel.guild.me:getPermissions(channel):has(permission.manageRoles, table.unpack(perms)) then return end
	channel:getPermissionOverwriteFor(member):allowPermissions(table.unpack(perms))
end



return function (member, channel)
	if channel then
		local mutex = queue[channel.id]
		local timer
		if mutex then
			mutex:lock()
			timer = mutex:unlockAfter(10000)
		end

		local lobbyData = lobbies[channel.id]
		if lobbyData then
			if lobbyData.isMatchmaking then
				matchmakingJoin(member, channel)
			else
				lobbyJoin(member, channel)
			end
		elseif channels[channel.id] then
			if channels[channel.id].parentType == 3 then return end
			if channels[channel.id].host ~= member.user.id then roomJoin(member, channel) end
		elseif guilds[channel.guild.id].permissions.bitfield.value ~= 0 then
			channelJoin(member, channel)
		end

		if mutex then
			mutex:unlock()
			Timer.clearTimeout(timer)
		end
	end
end