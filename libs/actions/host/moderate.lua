local discordia = require "discordia"
local locale = require "locale"
local lobbies = require "storage/lobbies"
local channels = require "storage/channels"

local hostCheck = require "utils/hostCheck"
local bitfield = require "utils/bitfield"
local client = discordia.storage.client
local permission = discordia.enums.permission

local actions 
actions = {
	blacklist = {
		add = function (channel, message)
			if channels[channel.id].whitelisted then actions.whitelist.clear(channel) end
			
			if not channels[channel.id].blacklisted then channels[channel.id].blacklisted = {} end
			
			for _, user in pairs(message.mentionedUsers) do
				if not channel:getPermissionOverwriteFor(channel.guild:getMember(user)):denyPermissions(permission.connect) then return end
				channels[channel.id].blacklisted[user] = true
			end
			return true
		end,
		
		remove = function (channel, message)
			if not channels[channel.id].blacklisted then return end
			
			for _, user in pairs(message.mentionedUsers) do
				if not channel:getPermissionOverwriteFor(channel.guild:getMember(user)):clearPermissions(permission.connect) then return end
				channels[channel.id].blacklisted[user] = nil
			end
			return true
		end,
		
		clear = function (channel)
			if not channels[channel.id].blacklisted then return end
			
			for user, _ in pairs(channels[channel.id].blacklisted) do
				if not channel:getPermissionOverwriteFor(channel.guild:getMember(user)):clearPermissions(permission.connect) then return end
			end
			channels[channel.id].blacklisted = nil
			return true
		end
	},

	whitelist = {
		add = function (channel, message)
			if channels[channel.id].blacklisted then actions.blacklist.clear(channel) end
			
			if not channels[channel.id].whitelisted then channels[channel.id].whitelisted = {} end
			
			if not channel:getPermissionOverwriteFor(channel.guild.defaultRole):denyPermissions(permission.connect) then return end
			for _, user in pairs(message.mentionedUsers) do
				if not channel:getPermissionOverwriteFor(channel.guild:getMember(user)):allowPermissions(permission.connect) then return end
				channels[channel.id].whitelisted[user] = true
			end
			return true
		end,
		
		remove = function (channel, message)
			if not channels[channel.id].whitelisted then return end
			
			for _, user in pairs(message.mentionedUsers) do
				if not channel:getPermissionOverwriteFor(channel.guild:getMember(user)):clearPermissions(permission.connect) then return end
				channels[channel.id].whitelisted[user] = nil
			end
			
			if not next(channels[channel.id].whitelisted) then
				channels[channel.id].whitelisted = nil
				if not channel:getPermissionOverwriteFor(channel.guild.defaultRole):clearPermissions(permission.connect) then return end
			end
			
			return true
		end,
		
		lock = function (channel)
			if channels[channel.id].blacklisted then actions.blacklist.clear(channel) end
			
			if not channels[channel.id].whitelisted then channels[channel.id].whitelisted = {} end
			
			if not channel:getPermissionOverwriteFor(channel.guild.defaultRole):denyPermissions(permission.connect) then return end
			
			for _, member in pairs(channel.connectedMembers) do
				if not channel:getPermissionOverwriteFor(member):allowPermissions(permission.connect) then return end
				channels[channel.id].whitelisted[member.user] = true
			end
			return true
		end,
		
		clear = function (channel)
			if not channels[channel.id].whitelisted then return end
			for user, _ in pairs(channels[channel.id].whitelisted) do
				if not channel:getPermissionOverwriteFor(channel.guild:getMember(user)):clearPermissions(permission.connect) then return end
			end
			channels[channel.id].whitelisted = nil
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
	
	local permissions = bitfield(lobbies[channels[channel.id].parent].permissions)
	if not permissions:has(permissions.bits.moderate) then
		message:reply(locale.badHostPermission)
		return "Insufficient permissions"
	end
	
	local context, action = message.content:match("%s*(%a*)%s*(%a*)"):lower()
	if not actions[context] and not actions[context][action] then
		action = "add"
	end
	
	if actions[context][action](channel, message) then
		message:addReaction("✅")
		return "Sucessfully processed blacklist"
	else
		message:reply(locale.hostError)
		return "Couldn't process blacklist"
	end
end