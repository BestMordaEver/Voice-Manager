local discordia = require "discordia"
local guilds = require "storage/guilds"
local lobbies = require "storage/lobbies"
local channels = require "storage/channels"
local bitfield = require "utils/bitfield"

local client = discordia.storage.client
local logger = discordia.storage.logger
local permission = discordia.enums.permission

local voiceChannelJoin = function (member, lobby)  -- your purpose!
	logger:log(4, "GUILD %s LOBBY %s: %s joined", lobby.guild.id, lobby.id, member.user.id)
		
	if guilds[lobby.guild.id].limitation <= guilds[lobby.guild.id].channels then return end
	
	-- parent to which a new channel will be attached
	local category = client:getChannel(lobbies[lobby.id].target) or lobby.category or lobby.guild
	
	-- determine new channel name
	local name = lobbies[lobby.id].template or guilds[lobby.guild.id].template or "%nickname's% channel"
	local position = lobbies:attachChild(lobby.id, true)
	local needsMove = name:match("%%counter%%") and true
	if name:match("%%.-%%") then
		local uname = member.user.name
		local nickname = member.nickname or uname
		local game = (member.activity and (member.activity.type == 0 or member.activity.type == 1)) and member.activity.name or "no game"
		
		local rt = {
			nickname = nickname,
			name = uname,
			tag = member.user.tag,
			game = game,
			counter = position,
			["nickname's"] = nickname .. (nickname:sub(-1,-1) == "s" and "'" or "'s"),
			["name's"] = uname .. (uname:sub(-1,-1) == "s" and "'" or "'s")
		}
		name = name:gsub("%%(.-)%%", rt)
	end
	
	local newChannel = category:createVoiceChannel(name)
	
	-- did we fail? statistics say "probably yes!"
	if newChannel then
		member:setVoiceChannel(newChannel.id)
		channels:add(newChannel.id, member.user.id, lobby.id, position)
		lobbies:attachChild(lobby.id, newChannel.id, position)
		guilds[lobby.guild.id].channels = guilds[lobby.guild.id].channels + 1
		newChannel:setUserLimit(lobby.userLimit)
		
		if lobbies[lobby.id].permissions ~= 0 then
			local perms = bitfield(lobbies[lobby.id].permissions):toDiscordia()
			if lobby.guild.me:getPermissions(lobby):has(permission.manageRoles, perms) then
				newChannel:getPermissionOverwriteFor(member):allowPermissions(perms)
			end
		end
		
		if needsMove then
			local children, distance = lobbies[lobby.id].children, 0
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