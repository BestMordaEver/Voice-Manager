local discordia = require "discordia"
local client = require "client"
local logger = require "logger"
local locale = require "locale"

local guilds = require "handlers/storageHandler".guilds
local lobbies = require "handlers/storageHandler".lobbies
local channels = require "handlers/storageHandler".channels

local greetingEmbed = require "embeds/greeting"

local adjustPermissions = require "handlers/channelHandler".adjustPermissions
local handleTemplate = require "handlers/channelHandler".handleTemplate

local Overseer = require "utils/logWriter"
local matchmakers = require "utils/matchmakers"

local Mutex = discordia.Mutex
local permission = discordia.enums.permission
local channelType = discordia.enums.channelType
local blurple = require "handlers/embedHandler".colors.blurple

local processing = {}

-- user joined a lobby
local function lobbyJoin (member, lobby)
	logger:log(4, "GUILD %s LOBBY %s USER %s: joined", lobby.guild.id, lobby.id, member.user.id)

	local guildData = guilds[lobby.guild.id]
	if guildData.limit <= guildData:channels() then return end

	-- parent to which a new channel will be attached
	local target = client:getChannel(lobbies[lobby.id].target) or lobby.category or lobby.guild

	-- determine new channel name
	local lobbyData = lobbies[lobby.id]
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

	local newChannel, err = lobby.guild:createChannel({
		name = name,
		type = channelType.voice,
		bitrate = lobbyData.bitrate,
		user_limit = lobbyData.capacity or lobby.userLimit,
		position = needsMove and distance or nil,
		parent_id = target.id
	})

	-- did we fail? statistics say "probably yes!"
	if newChannel then
		processing[newChannel.id] = Mutex()
		processing[newChannel.id]:lock()

		member:setVoiceChannel(newChannel.id)

		local companion
		if lobbyData.companionTarget then
			-- this might look familiar
			local companionTarget = lobbyData.companionTarget == true and (newChannel.category or newChannel.guild) or client:getChannel(lobbyData.companionTarget)

			if companionTarget then
				local name = lobbyData.companionTemplate or "private-chat"
				if name:match("%%.-%%") then
					name = handleTemplate(name, member, position):discordify()
					if name == "" then name = "private-chat" end
				end

				companion = lobby.guild:createChannel {
					name = name,
					type = channelType.text,
					parent_id = companionTarget.id
				}
			end
		end

		-- save channel data, attach to parent
		channels:store(newChannel.id, 0, member.user.id, lobby.id, position, companion and companion.id or nil)
		lobbyData:attachChild(channels[newChannel.id], position)

		newChannel:getPermissionOverwriteFor(lobby.guild.me):allowPermissions(permission.connect, permission.readMessages)
		adjustPermissions(newChannel, member)

		if companion then
			-- companions are private by default
			companion:getPermissionOverwriteFor(lobby.guild.me):allowPermissions(permission.readMessages, permission.sendMessages)
			companion:getPermissionOverwriteFor(member):allowPermissions(permission.readMessages)
			companion:getPermissionOverwriteFor(lobby.guild:getRole(lobbyData.role or guildData.role) or lobby.guild.defaultRole):denyPermissions(permission.readMessages)
		end

		if lobbyData.companionLog then Overseer.track(companion or newChannel) end
		if lobbyData.greeting or lobbyData.companionLog then (companion or newChannel):send(greetingEmbed(newChannel)) end

		processing[newChannel.id]:unlock()
		processing[newChannel.id] = nil
	else
		-- something went wrong, most likely user error
		lobbyData:detachChild(position)
		logger:log(2, "GUILD %s LOBBY %s USER %s: couldn't create new room - %s", lobby.guild.id, lobby.id, member.user.id, err)
	end
end

-- user joined matchmaking lobby
local function matchmakingJoin (member, lobby)
	logger:log(4, "GUILD %s mLOBBY %s USER %s: joined", lobby.guild.id, lobby.id, member.user.id)

	local target = client:getChannel(lobbies[lobby.id].target) or lobby.category
	if target then
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
end

-- user joined a room
local function roomJoin (member, channel)
	local channelData = channels[channel.id]

	if channelData.password and not (
		member:hasPermission(channel, permission.administrator) or
		channel:getPermissionOverwriteFor(member):getAllowedPermissions():has(permission.connect)
 	) then
		logger:log(4, "GUILD %s ROOM %s USER %s: sending password prompt", channel.guild.id, channel.id, member.user.id)
		channel:getPermissionOverwriteFor(member):denyPermissions(permission.connect)

		local newChannel = member.guild:createChannel {
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
					id = member.guild.id,
					type = 0,
					deny = "3146752"
				}
			}
		}

		member:setVoiceChannel(newChannel)
		channels:store(newChannel.id, 3, member.user.id, channel.id, 0)

		return member.user:send{
			ephemeral = true,
			embeds = {
				{
					description = locale.passwordCheckText,
					color = blurple,
					author = {
						name = channel.name,
						proxy_icon_url = member.guild.iconURL
					}
				}
			},
			components = {
				{
					type = 1,
					components = {
						{
							type = 2,
							style = 1,
							label = locale.passwordEnter,
							custom_id = "room_passwordinit",
						}
					}
				}
			}
		}
	end

	logger:log(4, "GUILD %s ROOM %s USER %s: joined", channel.guild.id, channel.id, member.user.id)

	local companion = client:getChannel(channelData.companion)
	if companion and not companion:getPermissionOverwriteFor(member):getDeniedPermissions():has(permission.readMessages) then
		companion:getPermissionOverwriteFor(member):allowPermissions(permission.readMessages)
	end
end

-- user joined an empty channel that allows execution of commands
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
	if #perms ~= 0 and channel.guild.me:getPermissions(channel):has(permission.manageRoles, table.unpack(perms)) then
		channel:getPermissionOverwriteFor(member):allowPermissions(table.unpack(perms))
	end
end

return function (member, channel)
	if channel then
		local processMutex = processing[channel.id]
		if processMutex then
			processMutex:lock()
		end

		local lobbyData = lobbies[channel.id]
		if lobbyData then
			if lobbyData.isMatchmaking then
				matchmakingJoin(member, channel)
			else
				lobbyData.mutex:lock()
				local ok, err = xpcall(lobbyJoin, debug.traceback, member, channel)
				lobbyData.mutex:unlock()
				if not ok then error(err) end
			end
		elseif channels[channel.id] then
			if channels[channel.id].host ~= member.user.id then roomJoin(member, channel) end
		elseif guilds[channel.guild.id].permissions.bitfield.value ~= 0 then
			channelJoin(member, channel)
		end

		if processMutex then
			processMutex:unlock()
		end
	end
end