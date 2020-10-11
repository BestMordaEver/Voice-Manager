local discordia = require "discordia"
local locale = require "locale"

local guilds = require "storage/guilds"
local lobbies = require "storage/lobbies"
local channels = require "storage/channels"
local bitfield = require "utils/bitfield"

local channelType, permission = discordia.enums.channelType, discordia.enums.permission
local client = discordia.storage.client

--[=[
@ conditionsToPass
t table of functions (author, channel)

{
	function (author, channel)
		return channel.type == channelType.voice
	end
}

@ messageConstructors
t table of functions (nids)

{
	default = function (nids)
		return string.format(nids == 1 and locale.registeredOne or locale.registeredMany, nids).."\n"
	end,
	
	function (nids)
		return (nids == 1 and locale.badChannel or locale.badChannels).."\n"
	end
}

@ action
t function (channel)
]=]

local function new (conditionsToPass, messageConstructors, action)
	return function (message, ids, argument)
		local failed = {final = {}}
		
		for i,conditionToPass in ipairs(conditionsToPass) do
			table.insert(failed, {})
			
			for j,_ in ipairs(ids) do repeat
				local channel = client:getChannel(ids[j])
				if channel and conditionToPass(message.author, channel, argument) then
					break
				else
					table.insert(failed[i], table.remove(ids,j))
				end
			until not ids[j] end
		end

		local msg = ""
		if #ids > 0 then
			msg = messageConstructors.default(#ids, argument)
			for _, channelID in ipairs(ids) do
				local channel = client:getChannel(channelID)
				msg = msg..string.format(locale.channelNameCategory, channel.name, channel.category and channel.category.name or "no category").."\n"
				action(channel, argument)
			end
		end
		
		for i, failures in ipairs(failed) do
			if #failures > 0 then
				msg = msg..messageConstructors[i](#failures)
				for _, channelID in ipairs(failures) do
					local channel = client:getChannel(channelID)
					if channel then
						msg = msg..string.format(locale.channelNameCategory, channel.name, channel.category and channel.category.name or "no category").."\n"
					end
					table.insert(failed.final, channelID)
				end
			end
		end
		
		return msg, failed.final
	end
end

local function isLobby (author, channel) return lobbies[channel.id] end
local function notLobby (nids) return (nids == 1 and locale.notLobby or locale.notLobbies).."\n"end

local function isUser (author, channel)
	local member = channel.guild:getMember(author)
	return member and member:hasPermission(channel, permission.manageChannels)
end
local function badUser (nids) return (nids == 1 and locale.badUserPermission or locale.badUserPermissions).."\n" end

return {
	register = new(
		{
			function (author, channel) return channel and channel.type == channelType.voice end,
			function (author, channel) return not lobbies[channel.id] end,
			isUser
		},{
			default = function (nids) return string.format(nids == 1 and locale.registeredOne or locale.registeredMany, nids).."\n" end,
			function (nids) return (nids == 1 and locale.badChannel or locale.badChannels).."\n" end,
			function (nids) return (nids == 1 and locale.redundantRegister or locale.redundantRegisters).."\n" end,
			badUser
		},
		function (channel) 
			guilds[channel.guild.id].lobbies:add(channel.id)
			lobbies:add(channel.id)
		end
	),
	
	unregister = new(
		{isLobby,isUser},
		{
			default = function (nids) return string.format(nids == 1 and locale.unregisteredOne or locale.unregisteredMany, nids).."\n" end,
			notLobby, badUser
		},
		function (channel)
			guilds[channel.guild.id].lobbies:remove(channel.id)
			lobbies:remove(channel.id)
		end
	),
	
	template = new(
		{isLobby,isUser},
		{
			default = function (nids, template) return string.format(template and locale.newTemplate or locale.resetTemplate, template).."\n" end,
			notLobby, badUser
		},
		function (channel, template)
			lobbies:updateTemplate(channel.id, template)
		end
	),
	
	target = new(
		{isLobby,isUser, function (author, channel, argument) return channel ~= client:getChannel(argument) end},
		{
			default = function (nids, target) return string.format(target and locale.newTarget or locale.resetTarget, client:getChannel(target).name).."\n" end,
			notLobby, badUser, 
			function (nids) return locale.selfTarget.."\n" end
		},
		function (channel, target)
			lobbies:updateTarget(channel.id, target)
		end
	),
	
	permissions = new(
		{isLobby,isUser},
		{
			default = function (nids, permissions)
				local permissionBits = bitfield(permissions)
				if permissions == 0 then
					return locale.resetPermissions.."\n"
				else
					return string.format(permissionBits:has(permissionBits.bits.on) and locale.newPermissions or locale.revokedPermissions, tostring(permissionBits)).."\n"
				end
			end,
			notLobby, badUser
		},
		function (channel, permissions)
			local permissionBits = bitfield(lobbies[channel.id].permissions)
			local newPermissionBits = bitfield(permissions)
			lobbies:updatePermissions(channel.id, newPermissionBits:has(newPermissionBits.bits.on) and (permissionBits + newPermissionBits) or (permissionBits - newPermissionBits))
		end
	)
}