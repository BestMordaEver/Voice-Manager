local discordia = require "discordia"
local locale = require "locale"

local lobbies = require "storage/lobbies"
local guilds = require "storage/guilds"

local bitfield = require "utils/bitfield"

local channelType, permission = discordia.enums.channelType, discordia.enums.permission
local client = discordia.storage.client

local function new (conditionsToPass, messageConstructors, actionName, probing)
	return function (message, ids, argument)
		if probing then 
			local res = probing(message, ids, argument)
			if res then return res end
		end
		
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
				command(channel, argument)
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
		
		message:reply(msg)
		return (#failed.final == 0 and "Successfully completed command for all" or ("Couldn't complete command for "..table.concat(failed.final, " ")))
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
			lobbies[channel.id]:delete()
		end
	),
	
	template = new(
		{isLobby,isUser},
		{
			default = function (nids, template) return string.format(template and locale.newTemplate or locale.resetTemplate, template).."\n" end,
			notLobby, badUser
		},
		function (channel, template)
			lobbies[channel.id]:setTemplate(template)
		end, 
		function (message, ids, template)
			if template == "" then
				message:reply(lobbies[ids[1]].template and locale.lobbyTemplate:format(client:getChannel(ids[1]).name, lobbies[ids[1]].template) or locale.noTemplate)
				return "Sent channel template"
			end
		end
	),
	
	target = new(
		{isLobby,isUser, function (author, channel, argument) return channel ~= client:getChannel(argument) end},
		{
			default = function (nids, target) return (target and locale.newTarget:format(client:getChannel(target).name) or locale.resetTarget).."\n" end,
			notLobby, badUser, 
			function (nids) return locale.selfTarget.."\n" end
		},
		function (channel, target)
			lobbies[channel.id]:setTarget(target)
		end,
		function (message, ids, target)
			if target == "" then
				message:reply(lobbies[ids[1]].target and locale.lobbyTarget:format(client:getChannel(ids[1]).name, client:getChannel(lobbies[ids[1]].target).name) or locale.noTarget)
				return "Sent channel target"
			end
		end
	),
	
	permissions = new(
		{isLobby,isUser},
		{
			default = function (nids, permissions)
				if permissions then
					local permissionBits = bitfield(permissions)
					return string.format(permissionBits:has(permissionBits.bits.on) and locale.newPermissions or locale.revokedPermissions, tostring(permissionBits)).."\n"
				else
					return locale.resetPermissions.."\n"
				end
			end,
			notLobby, badUser
		},
		function (channel, permissions)
			if permissions then
				local permissionBits = bitfield(lobbies[channel.id].permissions)
				local newPermissionBits = bitfield(permissions)
				lobbies[channel.id]:setPermissions(newPermissionBits:has(newPermissionBits.bits.on) and (permissionBits + newPermissionBits) or (permissionBits - newPermissionBits))
			else
				lobbies[channel.id]:setPermissions(0)
			end
		end,
		function (message, ids, permissions)
			if permissions == 0 then
				message:reply(locale.lobbyPermissions:format(client:getChannel(ids[1]).name, tostring(bitfield(lobbies[ids[1]].permissions))))
				return "Sent channel permissions"
			end
		end
	),
	
	capacity = new(
		{isLobby,isUser},
		{
			default = function (nids, capacity) return string.format(capacity and locale.newCapacity or locale.resetCapacity, capacity).."\n" end,
			notLobby, badUser
		},
		function (channel, capacity)
			lobbies[channel.id]:setCapacity(capacity)
		end,
		function (message, ids, capacity)
			if not capacity then
				message:reply(lobbies[ids[1]].capacity and locale.lobbyCapacity:format(client:getChannel(ids[1]).name, lobbies[ids[1]].capacity) or locale.noCapacity)
				return "Sent channel capacity"
			end
		end
	),
	
	companion = new(
		{isLobby,isUser},
		{
			default = function (nids, target) return (target and locale.newCompanion:format(client:getChannel(target).name) or locale.resetCompanion).."\n" end,
			notLobby, badUser
		},
		function (channel, target)
			lobbies[channel.id]:setCompanionTarget(target)
		end,
		function (message, ids, target)
			if target == "" then
				message:reply(lobbies[ids[1]].companion and locale.lobbyCompanion:format(client:getChannel(ids[1]).name, client:getChannel(lobbies[ids[1]].companion).name) or locale.noCompanion)
				return "Sent companion target"
			end
		end
	)
}