local enums = require "discordia".enums
local commandType = enums.applicationCommandType
local commandOptionType = enums.applicationCommandOptionType

---@module "locale/slash/en-US"
local locale = require "locale/localeHandler"

local commandsStructure = {
	require "slash/help",
	require "slash/lobby",
	require "slash/matchmaking",
	require "slash/companion",
	require "slash/room",
	require "slash/server",
	require "slash/reset",
	require "slash/clone",
	require "slash/delete",
	require "slash/users",
	{
		name = locale.support,
		description = locale.supportDesc,
	},
	{
		name = locale.ping,
		description = locale.pingDesc
	},
	{
		name = locale.invite,
		type = commandType.user
	},
	--[[{
		name = "Clear messages above",
		type = commandType.message
	},
	{
		name = "Clear messages below",
		type = commandType.message
	}]]
}

local debugCommands = {
	{
		name = locale.exec,
		description = locale.execDesc,
		options = {
			{
				name = locale.execCode,
				description = locale.execCodeDesc,
				type = commandOptionType.string,
				required = true
			}
		}
	},
	{
		name = locale.shutdown,
		description = locale.shutdownDesc,
	}
}

local swap = {}
for name, line in pairs(locale["en-US"]) do
	swap[line] = name
end

local function worker (t)
	if t.name then
		local lineName = swap[t.name]
		t.name_localizations = {}
		for locName, loc in pairs(locale) do
			t.name_localizations[locName] = loc[lineName]
		end
	end

	if t.description then
		local lineName = swap[t.description]
		t.description_localizations = {}
		for locName, loc in pairs(locale) do
			t.description_localizations[locName] = loc[lineName]
		end
	end

	for _, v in pairs(t) do
		if type(v) == "table" then
			worker(v)
		end
	end
end

local function localize(commands)
	for _, command in pairs(commands) do
		worker(command)
	end
end

localize(commandsStructure)
localize(debugCommands)

return {commandsStructure, debugCommands}