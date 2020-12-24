local discordia = require "discordia"
local client = require "client"
local logger = require "logger"
local guilds = require "storage/guilds"
local lobbies = require "storage/lobbies"
local channels = require "storage/channels"
local templateInterpreter = require "funcs/templateInterpreter"

local permission = discordia.enums.permission
local channelType = discordia.enums.channelType

local matchmakers = {
	random = function (channels)
		return channels[math.random(#channels)]
	end,
	
	max = function (channels)
		local max = channels[1]
		for i, channel in pairs(channels) do
			if #max.connectedMembers < #channel.connectedMembers then
				max = channel
			end
		end
		return max
	end,
	
	min = function (channels)
		local min = channels[1]
		for i, channel in pairs(channels) do
			if #min.connectedMembers > #channel.connectedMembers then
				min = channel
			end
		end
		return min
	end,
	
	first = function (channels)
		return channels[1]
	end,
	
	last = function (channels)
		return channels[#channels]
	end
}

local function lobbyJoin (member, lobby)
	logger:log(4, "GUILD %s LOBBY %s: %s joined", lobby.guild.id, lobby.id, member.user.id)
	
	-- parent to which a new channel will be attached
	local target = client:getChannel(lobbies[lobby.id].target) or lobby.category or lobby.guild
	
	-- target is voice channel? nothing to do here!
	if target.type == channelType.voice then
		member:setVoiceChannel()
	end
	
	if guilds[lobby.guild.id].limit <= guilds[lobby.guild.id].channels then return end
	
	-- determine new channel name
	local lobbyData = lobbies[lobby.id]
	local name = lobbyData.template or "%nickname's% channel"
	local position = lobbyData:attachChild(true)
	local needsMove
	
	if name:match("%%.-%%") then
		needsMove = name:match("%%counter%%") and true
		name = templateInterpreter(name, member, position):match("^%s*(.-)%s*$")
		if name == "" then name = templateInterpreter("%nickname's% channel", member) end
	end
	
	local newChannel = target:createVoiceChannel(name)
	
	-- did we fail? statistics say "probably yes!"
	if newChannel then
		member:setVoiceChannel(newChannel.id)
		
		local companion
		if lobbyData.companionTarget then
			local name = lobbyData.companionTemplate or "Private chat"
		
			if name:match("%%.-%%") then
				name = templateInterpreter(name, member, position):match("^%s*(.-)%s*$")
				if name == "" then name = "Private chat" end
			end
			
			companion = client:getChannel(lobbyData.companionTarget):createTextChannel(name)
		end
		
		channels:add(newChannel.id, member.user.id, lobby.id, position, companion and companion.id or nil)
		lobbyData:attachChild(newChannel.id, position)
		guilds[lobby.guild.id].channels = guilds[lobby.guild.id].channels + 1
		newChannel:setUserLimit(lobbyData.capacity or lobby.userLimit)
		
		local perms = lobbyData.permissions:toDiscordia()
		if #perms ~= 0 and lobby.guild.me:getPermissions(newChannel):has(permission.manageRoles, table.unpack(perms)) then
			newChannel:getPermissionOverwriteFor(member):allowPermissions(table.unpack(perms))
		end
		
		if companion then
			companion:getPermissionOverwriteFor(lobby.guild.me):allowPermissions(permission.readMessages)
			companion:getPermissionOverwriteFor(lobby.guild:getRole(lobbyData.role) or lobby.guild.defaultRole):denyPermissions(permission.readMessages)
			companion:getPermissionOverwriteFor(member):allowPermissions(permission.readMessages)
			
			local perms = lobbyData.permissions:toDiscordia()
			if #perms ~= 0 and lobby.guild.me:getPermissions(companion):has(permission.manageRoles, table.unpack(perms)) then
				companion:getPermissionOverwriteFor(member):allowPermissions(table.unpack(perms))
			end
		end
		
		if needsMove then
			local children, distance = lobbyData.children, 0
			repeat
				distance = distance + 1
				if children[position + distance] ~= nil and not client:getChannel(children[position + distance]) then
					children:drain(position + distance)
				end
			until children[position + distance] ~= nil or position + distance > children.max
			if position + distance <= children.max then
				newChannel:moveUp(newChannel.position - client:getChannel(children[position + distance]).position)
			end
		end
	else
		logger:log(2, "GUILD %s LOBBY %s: Couldn't create new channel for %s", lobby.guild.id, lobby.id, member.user.id)
	end
end

local function matchmakingJoin (member, lobby)
	logger:log(4, "GUILD %s MATCHMAKING LOBBY %s: %s joined", lobby.guild.id, lobby.id, member.user.id)
	
	local target = client:getChannel(lobbies[lobby.id].target) or lobby.category
	if target then
		local channels
		
		if target.type == channelType.voice then
			channels = lobby.guild.voiceChannels:toArray("position", function (channel)
				if channels[channel.id] then
					local parent = client:getChannel(channels[channel.id].parent.id)
					return (parent == target) and (channel.userLimit == 0 or #channel.connectedMembers < channel.userLimit) and member:hasPermission(channel, permission.connect)
				end
			end)
		else
			channels = target.voiceChannels:toArray("position", function (channel)
				return (channel ~= lobby) and (channel.userLimit == 0 or #channel.connectedMembers < channel.userLimit) and member:hasPermission(channel, permission.connect)
			end)
		end
		
		if #channels == 1 then
			if member:setVoiceChannel(channels[1]) then
				logger:log(4, "GUILD %s MATCHMAKING LOBBY %s: matchmade for %s", lobby.guild.id, lobby.id, target.id)
			end
			return
		elseif #channels > 1 then
			if member:setVoiceChannel((matchmakers[lobbies[lobby.id].template] or matchmakers.random)(channels)) then
				logger:log(4, "GUILD %s MATCHMAKING LOBBY %s: matchmade for %s", lobby.guild.id, lobby.id, target.id)
			end
			return
		else	-- if no available channels - create new or kick
			if target.type == channelType.voice then
				logger:log(4, "GUILD %s MATCHMAKING LOBBY %s: no available channels, delegating to %s", lobby.guild.id, lobby.id, target.id)
				client:emit("voiceChannelJoin", member, target)
			else
				logger:log(4, "GUILD %s MATCHMAKING LOBBY %s: no available channels, gtfo", lobby.guild.id, lobby.id)
				member:setVoiceChannel()
			end
			return
		end
	end
end

local function channelJoin (member, channel)
	logger:log(4, "GUILD %s CHANNEL %s: %s joined", lobby.guild.id, lobby.id, member.user.id)
	
	local companion = client:getChannel(channels[channel.id].companion)
	if companion then
		companion:getPermissionOverwriteFor(member):allowPermissions(permission.readMessages)
	end
end

return function (member, channel)
	if channel then
		local lobbyData = lobbies[channel.id]
		if lobbyData then
			if lobbyData.isMatchmaking then
				matchmakingJoin(member, channel)
			else
				lobbyData.mutex:lock()
				local ok, err = xpcall(lobbyJoin, debug.traceback, member, channel)
				lobbyData.mutex:unlock()	-- no fucking clue
				if not ok then error(err) end	-- no ignoring!
			end
		elseif channels[channel.id] then
			channelJoin(member, channel)
		end
	end
end