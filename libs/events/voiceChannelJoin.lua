local discordia = require "discordia"
local guilds = require "storage/guilds"
local lobbies = require "storage/lobbies"
local channels = require "storage/channels"
local categories = require "storage/categories"
local bitfield = require "utils/bitfield"
local templateInterpreter = require "utils/templateInterpreter"

local client = discordia.storage.client
local logger = discordia.storage.logger
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

local voiceChannelJoin = function (member, lobby)  -- your purpose!
	logger:log(4, "GUILD %s LOBBY %s: %s joined", lobby.guild.id, lobby.id, member.user.id)
	
	-- parent to which a new channel will be attached
	local target = client:getChannel(lobbies[lobby.id].target) or lobby.category or lobby.guild
	
	-- target is voice channel? matchmake!
	if target.type == channelType.voice then
		local targetData = lobbies[target.id]
		
		local channels = lobby.guild.voiceChannels:toArray("position", function (channel)
			if channels[channel.id] then
				local parent = client:getChannel(channels[channel.id].parent)
				return (parent == target) and (parent.userLimit == 0 or #parent.connectedMembers < parent.userLimit) and member:hasPermission(parent, permission.connect)
			end
		end)
		
		if #channels > 0 then
			if member:setVoiceChannel((matchmakers[targetData.template] or matchmakers.random)(channels)) then
				logger:log(4, "GUILD %s LOBBY %s: matchmade for %s", lobby.guild.id, lobby.id, target.id)
			end
			return
		else	-- if no available channels - create new
			logger:log(4, "GUILD %s LOBBY %s: no available channels, delegating to %s", lobby.guild.id, lobby.id, target.id)
			client:emit("voiceChannelJoin", member, target)
			return
		end
	end
	
	if guilds[lobby.guild.id].limitation <= guilds[lobby.guild.id].channels then return end
	
	-- determine new channel name
	local lobbyData = lobbies[lobby.id]
	local name = lobbyData.template or guilds[lobby.guild.id].template or "%nickname's% channel"
	local position = lobbyData:attachChild(true)
	local needsMove
	
	if name:match("%%.-%%") then
		needsMove = name:match("%%counter%%") and true
		name = templateInterpreter(name, member, position):match("^%s*(.-)%s*$")
		if name == "" then name = templateInterpreter("%nickname's% channel", member) end
	end
	
	while #target.voiceChannels + #target.textChannels > 48 do
		local targetData = categories[target.id] or categories:getRoot(target.id)
		if not targetData.child then
			local newCategory = target.guild:createCategory(target.name)
			newCategory:moveUp(newCategory.position - target.position)
			if categories[target.id] then
				targetData:addChild(newCategory.id)
			else
				categories(newCategory.id, target.id)
				targetData.child = categories[newCategory.id]
			end
			logger:log(4, "GUILD %s PARENT %s: Added category %s", target.guild.id, target.id, newCategory.id)
		end
		target = client:getChannel(targetData.child.id)
	end
	
	if target.type == channelType.category and #target.voiceChannels + #target.textChannels > 48 then
		
	end
	local newChannel = target:createVoiceChannel(name)
	
	-- did we fail? statistics say "probably yes!"
	if newChannel then
		member:setVoiceChannel(newChannel.id)
		channels:add(newChannel.id, member.user.id, lobby.id, position)
		lobbyData:attachChild(newChannel.id, position)
		guilds[lobby.guild.id].channels = guilds[lobby.guild.id].channels + 1
		newChannel:setUserLimit(lobby.userLimit)
		
		local perms = bitfield(lobbyData.permissions):toDiscordia()
		if #perms ~= 0 and lobby.guild.me:getPermissions(lobby):has(permission.manageRoles, table.unpack(perms)) then
			newChannel:getPermissionOverwriteFor(member):allowPermissions(table.unpack(perms))
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

return function (member, lobby)
	if lobby and lobbies[lobby.id] then
		lobbies[lobby.id].mutex:lock()
		local ok, err = xpcall(voiceChannelJoin, debug.traceback, member, lobby)
		lobbies[lobby.id].mutex:unlock()
		if not ok then error(err) end	-- no ignoring!
	end
end