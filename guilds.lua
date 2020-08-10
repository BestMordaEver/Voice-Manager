-- object to store data about guilds and interact with corresponding db
-- CREATE TABLE guilds(id VARCHAR PRIMARY KEY, prefix VARCHAR, template VARCHAR, limitation INTEGER)

local discordia = require "discordia"
local sqlite = require "sqlite3".open("guildsData.db")

local client, logger = discordia.storage.client, discordia.storage.logger

local utils = require "./utils.lua"
local storageInteractionEvent = utils.storageInteractionEvent
local set = utils.set
local lobbies = require "./lobbies.lua"
local channels = require "./channels.lua"

-- used to start storageInteractionEvent as async process
-- because fuck data preservation, we need dat speed
local emitter = discordia.Emitter()

-- prepared statements
local add, remove, updatePrefix, updateTemplate, updateLimitation =
	sqlite:prepare("INSERT INTO guilds VALUES(?,'!vm',NULL)"),
	sqlite:prepare("DELETE FROM guilds WHERE id = ?"),
	sqlite:prepare("UPDATE guilds SET prefix = ? WHERE id = ?"),
	sqlite:prepare("UPDATE guilds SET template = ? WHERE id = ?"),
	sqlite:prepare("UPDATE guilds SET limitation = ? WHERE id = ?")

emitter:on("add", function (guildID)
	local ok, msg = pcall(storageInteractionEvent, add, guildID)
	if ok then
		logger:log(4, "MEMORY: Added guild %s", guildID)
	else
		logger:log(2, "MEMORY: Couldn't add guild %s: %s", guildID, msg)
		client:getChannel("686261668522491980"):sendf("Couldn't add guild %s: %s", guildID, msg)
	end
end)

emitter:on("remove", function (guildID)
	local ok, msg = pcall(storageInteractionEvent, remove, guildID)
	if ok then
		logger:log(4, "MEMORY: Removed guild %s", guildID)
	else
		logger:log(2, "MEMORY: Couldn't remove guild %s: %s", guildID, msg)
		client:getChannel("686261668522491980"):sendf("Couldn't remove guild %s: %s", guildID, msg)
	end
end)

emitter:on("updatePrefix", function (guildID, prefix)
	local ok, msg = pcall(storageInteractionEvent, updatePrefix, prefix, guildID)
	if ok then
		logger:log(4, "MEMORY: Updated prefix for guild %s to %s", guildID, prefix)
	else
		logger:log(2, "MEMORY: Couldn't update prefix for guild %s to %s: %s", guildID, prefix, msg)
		client:getChannel("686261668522491980"):sendf("Couldn't update prefix for guild %s to %s: %s", guildID, prefix, msg)
	end
end)

emitter:on("updateTemplate", function (guildID, template)
	local ok, msg = pcall(storageInteractionEvent, updateTemplate, template, guildID)
	if ok then
		logger:log(4, "MEMORY: Updated template for guild %s to %s", guildID, template)
	else
		logger:log(2, "MEMORY: Couldn't update template for guild %s to %s: %s", guildID, template, msg)
		client:getChannel("686261668522491980"):sendf("Couldn't update template for guild %s to %s: %s", guildID, template, msg)
	end
end)

emitter:on("updateLimitation", function (guildID, limitation)
	local ok, msg = pcall(storageInteractionEvent, updateLimitation, limitation, guildID)
	if ok then
		logger:log(4, "MEMORY: Updated limitation for guild %s to %s", guildID, limitation)
	else
		logger:log(2, "MEMORY: Couldn't update limitation for guild %s to %s: %s", guildID, limitation, msg)
		client:getChannel("686261668522491980"):sendf("Couldn't update limitation for guild %s to %s: %s", guildID, limitation, msg)
	end
end)

return setmetatable({}, {
	-- move functions to index table to iterate over guilds easily
	__index = {
		-- no safety needed, it's either loading time or new guild time, whoever spams invites can go to hell
		loadAdd = function (self, guildID, prefix, template, limitation)
			self[guildID] = {prefix = prefix or "!vm", template = template, limitation = limitation or 10000, lobbies = set(), channels = 0}
			logger:log(4, "GUILD %s: Added", guildID)
		end,
		
		-- loadAdd and start interaction with db
		add = function (self, guildID)
			self:loadAdd(guildID)
			emitter:emit("add", guildID)
		end,
		
		-- no granular control, if it goes away, it does so everywhere
		remove = function (self, guildID)
			self[guildID] = nil
			logger:log(4, "GUILD %s: Removed", guildID)
			emitter:emit("remove", guildID)
		end,
		
		load = function (self)
			logger:log(4, "STARTUP: Loading guilds from save")
			local guildIDs = sqlite:exec("SELECT * FROM guilds")
			if guildIDs then
				for i, guildID in ipairs(guildIDs.id) do
					if client:getGuild(guildID) then
						self:loadAdd(guildID, guildIDs.prefix[i], guildIDs.template[i], tonumber(guildIDs.limitation[i]))
					else
						self:remove(guildID)
					end
				end
			end
			
			logger:log(4, "STARTUP: Loading guilds from client")
			for _, guild in pairs(client.guilds) do
				if not self[guild.id] then self:add(guild.id) end
			end
			
			for _, lobbyID in pairs(lobbies) do
				local guild = self[client:getChannel(lobbyID).guild.id]
				guild.lobbies:add(lobbyID)
				guild.channels = guild.channels + 1
			end
			
			logger:log(4, "STARTUP: Loaded!")
		end,
		
		-- there should be enough checks to ensure that guild and prefix are valid
		updatePrefix = function (self, guildID, prefix)
			self[guildID].prefix = prefix
			logger:log(4, "GUILD %s: Updated prefix", guildID)
			emitter:emit("updatePrefix", guildID, prefix)
		end,
		
		-- there should be enough checks to ensure that guild and template are valid
		updateTemplate = function (self, guildID, template)
			self[guildID].template = template
			logger:log(4, "GUILD %s: Updated template", guildID)
			emitter:emit("updateTemplate", guildID, template)
		end,
		
		updateLimitation = function (self, guildID, limitation)
			self[guildID].limitation = limitation
			logger:log(4, "GUILD %s: Updated limitation", guildID)
			emitter:emit("updateLimitation", guildID, limitation)
		end
	}
})
