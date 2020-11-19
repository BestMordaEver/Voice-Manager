local discordia = require "discordia"
local locale = require "locale"
local channels = require "storage/channels"

local hostCheck = require "utils/hostCheck"
local bitfield = require "utils/bitfield"
local client = discordia.storage.client
local permission = discordia.enums.permission

local actions 
actions = {
	blacklist = {
		add = function (channel, message)
			-- wl and bl are incompatible, reset the other if present
			if channels[channel.id].whitelisted then actions.whitelist.clear(channel) end
			
			-- no implicit init needed
			if not channels[channel.id].blacklisted then channels[channel.id].blacklisted = {} end
			
			-- blacklist mentioned users
			for _, user in pairs(message.mentionedUsers) do
				local member = channel.guild:getMember(user)
				if member.voiceChannel == channel then member:setVoiceChannel() end
				if not channel:getPermissionOverwriteFor(member):denyPermissions(permission.connect) then return end
				channels[channel.id].blacklisted[user] = true
			end
			return true
		end,
		
		remove = function (channel, message)
			-- if no bl, ignore
			if not channels[channel.id].blacklisted then return end
			
			-- unblacklist mentioned users
			for _, user in pairs(message.mentionedUsers) do
				if not channel:getPermissionOverwriteFor(channel.guild:getMember(user)):clearPermissions(permission.connect) then return end
				channels[channel.id].blacklisted[user] = nil
			end
			return true
		end,
		
		clear = function (channel)
			-- if no bl, ignore
			if not channels[channel.id].blacklisted then return end
			
			-- unblacklist connected users
			for user, _ in pairs(channels[channel.id].blacklisted) do
				if not channel:getPermissionOverwriteFor(channel.guild:getMember(user)):clearPermissions(permission.connect) then return end
			end
			channels[channel.id].blacklisted = nil
			return true
		end
	},

	whitelist = {
		add = function (channel, message)
			-- wl and bl are incompatible, reset the other if present
			if channels[channel.id].blacklisted then actions.blacklist.clear(channel) end
			
			-- if no previous wl - init with host as the first whitelisted
			if not channels[channel.id].whitelisted then
				if not channel:getPermissionOverwriteFor(channel.guild:getMember(message.author)):allowPermissions(permission.connect) then return end
				channels[channel.id].whitelisted = {[message.author] = true}
			end
			
			-- TODO: default moderated role instead of @everyone
			if not channel:getPermissionOverwriteFor(channel.guild.defaultRole):denyPermissions(permission.connect) then return end
			
			-- whitelist mentioned users
			for _, user in pairs(message.mentionedUsers) do
				if not channel:getPermissionOverwriteFor(channel.guild:getMember(user)):allowPermissions(permission.connect) then return end
				channels[channel.id].whitelisted[user] = true
			end
			return true
		end,
		
		remove = function (channel, message)
			-- if no wl, ignore
			if not channels[channel.id].whitelisted then return end
			
			-- unwhitelist mentioned users
			for _, user in pairs(message.mentionedUsers) do
				if not channel:getPermissionOverwriteFor(channel.guild:getMember(user)):clearPermissions(permission.connect) then return end
				channels[channel.id].whitelisted[user] = nil
			end
			return true
		end,
		
		lock = function (channel)
			-- wl and bl are incompatible, reset the other if present
			if channels[channel.id].blacklisted then actions.blacklist.clear(channel) end
			
			-- no host init needed, host in connectedMembers
			if not channels[channel.id].whitelisted then channels[channel.id].whitelisted = {} end
			
			-- TODO: default moderated role instead of @everyone
			if not channel:getPermissionOverwriteFor(channel.guild.defaultRole):denyPermissions(permission.connect) then return end
			
			-- whitelist connected users
			for _, member in pairs(channel.connectedMembers) do
				if not channel:getPermissionOverwriteFor(member):allowPermissions(permission.connect) then return end
				channels[channel.id].whitelisted[member.user] = true
			end
			return true
		end,
		
		clear = function (channel)
			-- if no wl, ignore
			if not channels[channel.id].whitelisted then return end
			
			-- whitelist all whitelisted
			for user, _ in pairs(channels[channel.id].whitelisted) do
				if not channel:getPermissionOverwriteFor(channel.guild:getMember(user)):clearPermissions(permission.connect) then return end
			end
			
			-- reset the list
			channels[channel.id].whitelisted = nil
			
			-- TODO: default moderated role instead of @everyone
			if not channel:getPermissionOverwriteFor(channel.guild.defaultRole):clearPermissions(permission.connect) then return end
			return true
		end
	}
}

return function (message)
	local channel = hostCheck(message)
	if type(channel) == "string" then
		return channel
	end
	
	local permissions = bitfield(channels[channel.id].parent.permissions)
	if not permissions:has(permissions.bits.moderate) then
		message:reply(locale.badHostPermission)
		return "Insufficient permissions"
	end
	
	local context = message.content:match("blacklist") or message.content:match("whitelist")
	if context then context = context:lower() else return end
	
	local action = message.content:match(context.."%s*(%a*)")
	if not actions[context][action] then
		action = "add"
	end
	
	if actions[context][action](channel, message) then
		message:addReaction("✅")
		return "Sucessfully processed "..action
	else
		message:reply(locale.hostError)
		return "Couldn't process "..action
	end
end