local config = require "config"

local okEmbed = require "embeds/ok"
local warningEmbed = require "embeds/warning"

local function code (s)
	return string.format("```\n%s```", s)
end

local sandbox = setmetatable({
	client = require "client",
	guilds = require "handlers/storageHandler".guilds,
	lobbies = require "handlers/storageHandler".lobbies,
	channels = require "handlers/storageHandler".channels
},{ __index = _G})

return function (interaction)
    if not config.owners[interaction.user.id] then return "Not owner", warningEmbed("You're not my father") end

    local fn, syntaxError = load(interaction.option.value, "Bot", "t", sandbox)
    if not fn then return "Syntax error", warningEmbed(code(syntaxError)) end

    local success, runtimeError = pcall(fn)
    if not success then return "Runtime error", warningEmbed(code(runtimeError)) end

    return "Code executed", okEmbed("Code executed")
end