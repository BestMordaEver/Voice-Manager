local pp = require "pretty-print"
local config = require "config"

local okEmbed = require "embeds/ok"
local warningEmbed = require "embeds/warning"

local sandbox = setmetatable({
	client = require "client",
	guilds = require "storage/guilds",
	lobbies = require "storage/lobbies",
	channels = require "storage/channels"
},{ __index = _G})

local function code (s)
	return string.format("```\n%s```", s)
end

local function printLine(...)
    local ret = {}
    for i = 1, select('#', ...) do
        local arg = tostring(select(i, ...))
        table.insert(ret, arg)
    end
    return table.concat(ret, '\t')
end

local function prettyLine(...)
    local ret = {}
    for i = 1, select('#', ...) do
        local arg = pp.strip(pp.dump(select(i, ...)))
        table.insert(ret, arg)
    end
    return table.concat(ret, '\t')
end

return function (interaction)
    if not config.owners[interaction.user.id] then return "Not owner", warningEmbed(interaction, "veryNotPermitted") end

    local lines = {}

    sandbox.print = function(...) -- intercept printed lines with this
        table.insert(lines, printLine(...))
    end

    sandbox.p = function(...) -- intercept pretty-printed lines with this
        table.insert(lines, prettyLine(...))
    end

    local fn, syntaxError = load(interaction.option.value, "Bot", "t", sandbox)
    if not fn then return "Syntax error", warningEmbed:compose(interaction)("asIs", code(syntaxError))() end

    local success, runtimeError = pcall(fn)
    if not success then return "Runtime error", warningEmbed:compose(interaction)("asIs", code(runtimeError))() end

    lines = table.concat(lines, '\n') -- bring all the lines together
    return "Code executed", okEmbed:compose(interaction)("asIs", code(lines))()
end