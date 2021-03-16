--[[
luvit redefines lua's require
"packageName" must be in luvit's local "deps" or entry point's "libs" folder
"./filename.lua" may be anywhere, just make sure the path is fine

require "discordia"								table: 0x02563805ddf8
require "../deps/discordia/init.lua"			table: 0x02563805ddf8
require "D:\\lua\\deps\\discordia\\init.lua"	table: 0x025638037e88 absolute path is a bitch i guess :/
]]
local discordia = require "discordia"
discordia.extensions.table()

local client = discordia.Client()

-- creating stubs for require to easily access all relevant bits without making them global
package.loaded.client = client
package.loaded.clock = discordia.Clock()
package.loaded.logger = discordia.Logger(4, '%F %T')

--[[ 
holds all the event methods and logic
notice that metametod call of the table produces two values
]]
local events = require "events/init"

-- Other events are registered in "ready"
client:once(events("ready"))

-- initializing all embed types
-- really gotta think about a more elegant solution
require "embeds/init"

-- yep, it's permanent now
local timer = require "timer"
timer.setTimeout(60000, client.emit, client, "ready")

-- bot starts working here
client:run('Bot '..require "token".token)