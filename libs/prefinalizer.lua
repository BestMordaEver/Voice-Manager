local discordia = require "discordia"
local locale = require "locale"
local finalizer = require "finalizer"

local lobbies = require "storage/lobbies"
local guilds = require "storage/guilds"

local bitfield = require "utils/bitfield"

local client = discordia.storage.client
local permission = discordia.enums.permission

local function new (action, probing)
	return function (message, ids, argument)
		if probing then 
			local res = probing(message, ids, argument)
			if res then return res end
		end
		
		argument, ids = finalizer[action](message, ids, argument)
		message:reply(argument)
		return (#ids == 0 and "Successfully completed action for all" or ("Couldn't complete action for "..table.concat(ids, " ")))
	end
end

return {
	register = new("register"),
	
	unregister = new("unregister"),
	
	template = new("template", function (message, ids, template)
		if template == "" then
			message:reply(lobbies[ids[1]].template and locale.lobbyTemplate:format(client:getChannel(ids[1]).name, lobbies[ids[1]].template) or locale.noTemplate)
			return "Sent channel template"
		end
	end),
	
	target = new("target", function (message, ids, target)
		if target == "" then
			message:reply(lobbies[ids[1]].target and locale.lobbyTarget:format(client:getChannel(ids[1]).name, client:getChannel(lobbies[ids[1]].target).name) or locale.noTarget)
			return "Sent channel target"
		end
	end),
	
	permissions = new("permissions", function (message, ids, permissions)
		if permissions == 0 then
			message:reply(locale.lobbyPermissions:format(client:getChannel(ids[1]).name, tostring(bitfield(lobbies[ids[1]].permissions))))
			return "Sent channel permissions"
		end
	end),
	
	capacity = new("capacity", function (message, ids, capacity)
		if not capacity then
			message:reply(lobbies[ids[1]].capacity and locale.lobbyCapacity:format(client:getChannel(ids[1]).name, lobbies[ids[1]].capacity) or locale.noCapacity)
			return "Sent channel capacity"
		end
	end),
	
	companion = new("companion", function (message, ids, target)
		if target == "" then
			message:reply(lobbies[ids[1]].companion and locale.lobbyCompanion:format(client:getChannel(ids[1]).name, client:getChannel(lobbies[ids[1]].companion).name) or locale.noCompanion)
			return "Sent companion target"
		end
	end),
	
	limitation = new("limitation", function (message, guild, limitation)
		if not guild then
			message:reply(locale.badServer)
			return "Didn't find the guild"
		end
		
		if guild and not guild:getMember(message.author) then
			message:reply(locale.notMember)
			return "Not a member"
		end

		if limitation ~= "" then
			if not guild:getMember(message.author):hasPermission(permission.manageChannels) then
				message:reply(locale.mentionInVain:format(message.author.mentionString))
				return "Bad user permissions"
			end
			
			limitation = tonumber(limitation)
			if not limitation or limitation > 500 or limitation < 1 then
				message:reply(locale.limitationOOB)
				return "Limitation OOB"
			end
			
			guilds[guild.id]:updateLimitation(limitation)
			message:reply(locale.limitationConfirm:format(limitation))
			return "Set new limitation"
		else
			message:reply(locale.limitationThis:format(guilds[guild.id].limitation))
			return "Sent current limitation"
		end
	end),
	
	prefix = new("prefix", function (message, guild, prefix)
		if not guild then
			message:reply(locale.badServer)
			return "Didn't find the guild"
		end
		
		if guild and not guild:getMember(message.author) then
			message:reply(locale.notMember)
			return "Not a member"
		end
		
		if prefix and prefix ~= "" then
			if not guild:getMember(message.author):hasPermission(permission.manageChannels) then
				message:reply(locale.mentionInVain:format(message.author.mentionString))
				return "Bad user permissions"
			end
			guilds[guild.id]:updatePrefix(prefix)
			message:reply(locale.prefixConfirm:format(prefix))
			return "Set new prefix"
		else
			message:reply(locale.prefixThis:format(guilds[guild.id].prefix))
			return "Sent current prefix"
		end
	end)
}