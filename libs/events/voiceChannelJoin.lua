local discordia = require "discordia"
local client = require "client"
local logger = require "logger"
local guilds = require "storage/guilds"
local lobbies = require "storage/lobbies"
local channels = require "storage/channels"
local embeds = require "embeds/embeds"
local matchmakers = require "utils/matchmakers"
local templateInterpreter = require "funcs/templateInterpreter"
local enforceReservations = require "funcs/enforceReservations"

local Permissions = discordia.Permissions
local permission = discordia.enums.permission
local channelType = discordia.enums.channelType

local processing = {}

local function lobbyJoin (member, lobby)
	logger:log(4, "GUILD %s LOBBY %s USER %s: joined", lobby.guild.id, lobby.id, member.user.id)
	
	-- parent to which a new channel will be attached
	local target = client:getChannel(lobbies[lobby.id].target) or lobby.category or lobby.guild
	
	-- target is voice channel? nothing to do here!
	if target.type == channelType.voice then
		member:setVoiceChannel()
	end
	
	local guildData = guilds[lobby.guild.id]
	
	if guildData.limit <= channels:inGuild(guildData.id) then return end
	
	-- determine new channel name
	local lobbyData = lobbies[lobby.id]
	local name = lobbyData.template or "%nickname's% room"
	-- potential position may change in process of name generation, so rather than query lobby for position several times, reservation is made and used throughout
	local position = lobbyData:attachChild(true)
	local needsMove
	
	if name:match("%%.-%%") then
		needsMove = name:match("%%counter%%") and true
		name = templateInterpreter(name, member, position):match("^%s*(.-)%s*$")
		if name == "" then name = templateInterpreter("%nickname's% room", member) end
	end
	
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
		end
	end
	
	local perms = lobbyData.permissions:toDiscordia()
	
	local newChannel = lobby.guild:createChannel({
		name = name,
		type = channelType.voice,
		bitrate = lobbyData.bitrate,
		user_limit = lobbyData.capacity or lobby.userLimit,
		position = needsMove and client:getChannel(lobbyData.children[position + distance].id).position - 1 or nil,
		parent_id = target.id
	})
	
	-- did we fail? statistics say "probably yes!"
	if newChannel then
		processing[newChannel.id] = discordia.Mutex()
		processing[newChannel.id]:lock()
		
		member:setVoiceChannel(newChannel.id)
		
		local companion
		if lobbyData.companionTarget then
			local companionTarget = lobbyData.companionTarget == true and (newChannel.category or newChannel.guild) or client:getChannel(lobbyData.companionTarget)
			local name = lobbyData.companionTemplate or "private-chat"
		
			if companionTarget then
				if name:match("%%.-%%") then
					name = templateInterpreter(name, member, position):match("^%s*(.-)%s*$")
					if name == "" then name = "private-chat" end
				end
			
				companion = lobby.guild:createChannel({
					name = name,
					type = channelType.text,
					parent_id = companionTarget.id
				})
			end
		end
		
		channels:add(newChannel.id, false, member.user.id, lobby.id, position, companion and companion.id or nil)
		lobbyData:attachChild(channels[newChannel.id], position)
		
		newChannel:getPermissionOverwriteFor(lobby.guild.me):allowPermissions(permission.connect)
		
		local perms = lobbyData.permissions:toDiscordia()
		if #perms ~= 0 and lobby.guild.me:getPermissions(newChannel):has(permission.manageRoles, table.unpack(perms)) then
			newChannel:getPermissionOverwriteFor(member):allowPermissions(table.unpack(perms))
		end
		
		if companion then
			companion:getPermissionOverwriteFor(lobby.guild.me):allowPermissions(permission.readMessages)
			companion:getPermissionOverwriteFor(member):allowPermissions(permission.readMessages)
			companion:getPermissionOverwriteFor(lobby.guild:getRole(lobbyData.role or guildData.role) or lobby.guild.defaultRole):denyPermissions(permission.readMessages)
			
			if #perms ~= 0 and lobby.guild.me:getPermissions(companion):has(permission.manageRoles, table.unpack(perms)) then
				companion:getPermissionOverwriteFor(member):allowPermissions(table.unpack(perms))
			end
			
			if lobbyData.greeting or lobbyData.companionLog then companion:send(embeds("greeting", newChannel)) end
		end
		
		processing[newChannel.id]:unlock()
		processing[newChannel.id] = nil
	else
		logger:log(2, "GUILD %s LOBBY %s USER %s: couldn't create new room", lobby.guild.id, lobby.id, member.user.id)
	end
end

local function matchmakingJoin (member, lobby)
	logger:log(4, "GUILD %s mLOBBY %s USER %s: joined", lobby.guild.id, lobby.id, member.user.id)
	
	local target = client:getChannel(lobbies[lobby.id].target) or lobby.category
	if target then
		local children
		
		if target.type == channelType.voice then
			children = lobby.guild.voiceChannels:toArray("position", function (channel)
				if channels[channel.id] then
					local parent = client:getChannel(channels[channel.id].parent.id)
					return (parent == target) and (channel.userLimit == 0 or #channel.connectedMembers < channel.userLimit) and member:hasPermission(channel, permission.connect)
				end
			end)
		else
			children = target.voiceChannels:toArray("position", function (channel)
				return (channel ~= lobby) and (channel.userLimit == 0 or #channel.connectedMembers < channel.userLimit) and member:hasPermission(channel, permission.connect)
			end)
		end
		
		if #children == 1 then
			if member:setVoiceChannel(children[1]) then
				logger:log(4, "GUILD %s mLOBBY %s USER %s: matchmade", lobby.guild.id, lobby.id, target.id)
			end
			return
		elseif #children > 1 then
			if member:setVoiceChannel((matchmakers[lobbies[lobby.id].template] or matchmakers.random)(children)) then
				logger:log(4, "GUILD %s mLOBBY %s USER %s: matchmade", lobby.guild.id, lobby.id, target.id)
			end
			return
		else	-- if no available channels - create new or kick
			if target.type == channelType.voice then
				logger:log(4, "GUILD %s mLOBBY %s: no available room, delegating to LOBBY %s", lobby.guild.id, lobby.id, target.id)
				client:emit("voiceChannelJoin", member, target)
			else
				logger:log(4, "GUILD %s mLOBBY %s: no available room, gtfo", lobby.guild.id, lobby.id)
				member:setVoiceChannel()
			end
			return
		end
	end
end

local function roomJoin (member, channel)
	logger:log(4, "GUILD %s ROOM %s USER %s: joined", channel.guild.id, channel.id, member.user.id)
	
	enforceReservations(channel)
	
	local companion = client:getChannel(channels[channel.id].companion)
	if companion and not companion:getPermissionOverwriteFor(member):getDeniedPermissions():has(permission.readMessages) then
		companion:getPermissionOverwriteFor(member):allowPermissions(permission.readMessages)
	end
end

local function channelJoin (member, channel)
	logger:log(4, "GUILD %s CHANNEL %s USER %s: joined", channel.guild.id, channel.id, member.user.id)
	
	--[[ TODO
	local name = templateInterpreter(guilds[channel.guild.id].template, member, position):match("^%s*(.-)%s*$")
		
	local position = #(channel.category and 
		channel.category.voiceChannels:toArray("position", function (vchannel) return vchannel.position <= channel.position end)
			or
		channel.guild.voiceChannels:toArray("position", function (vchannel) return not vchannel.category and vchannel.position <= channel.position end))
	]]
	
	channels:add(channel.id, true, member.user.id, channel.guild.id, 0, nil)

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
				if not ok then error(err) end	-- no ignoring!
			end
		elseif channels[channel.id] then
			if channels[channel.id].host ~= member.user.id then roomJoin(member, channel) end
		else
			channelJoin(member, channel)
		end
		
		if processMutex then
			processMutex:unlock()
		end
	end
end