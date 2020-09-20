-- object to store data about guilds and interact with corresponding db
-- CREATE TABLE guilds(id VARCHAR PRIMARY KEY, prefix VARCHAR, template VARCHAR, limitation INTEGER)

local discordia = require "discordia"
local sqlite = require "sqlite3".open("libs/storage/guildsData.db")

local client, logger = discordia.storage.client, discordia.storage.logger

local lobbies = require "storage/lobbies"
local channels = require "storage/channels"
local storageInteraction = require "utils/storageInteraction"
local set = require "utils/set"

-- used to start storageInteractionEvent as async process
-- because fuck data preservation, we need dat speed
local emitter = discordia.Emitter()

-- prepared statements
local add, remove, updatePrefix, updateTemplate, updateLimitation =
	sqlite:prepare("INSERT INTO guilds VALUES(?,'!vm',NULL, 100000)"),
	sqlite:prepare("DELETE FROM guilds WHERE id = ?"),
	sqlite:prepare("UPDATE guilds SET prefix = ? WHERE id = ?"),
	sqlite:prepare("UPDATE guilds SET template = ? WHERE id = ?"),
	sqlite:prepare("UPDATE guilds SET limitation = ? WHERE id = ?")

emitter:on("add", storageInteraction(add, "Added guild %s", "Couldn't add guild %s"))
emitter:on("remove", storageInteraction(remove, "Removed guild %s", "Couldn't remove guild %s"))
emitter:on("updatePrefix", storageInteraction(updatePrefix, "Updated prefix to %s for guild %s", "Couldn't update prefix to %s for guild %s"))
emitter:on("updateTemplate", storageInteraction(updateTemplate, "Updated template to %s for guild %s", "Couldn't update template to %s for guild %s"))
emitter:on("updateLimitation", storageInteraction (updateLimitation, "Updated limitation to %s for guild %s", "Couldn't update limitation to %s for guild %s"))

return setmetatable({}, {
	-- move functions to index table to iterate over guilds easily
	__index = {
		-- no safety needed, it's either loading time or new guild time, whoever spams invites can go to hell
		loadAdd = function (self, guildID, prefix, template, limitation)
			self[guildID] = {prefix = prefix or "!vm", template = template, limitation = limitation or 100000, lobbies = set(), channels = 0}
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
			
			for lobbyID, _ in pairs(lobbies) do
				self[client:getChannel(lobbyID).guild.id].lobbies:add(lobbyID)
			end
			
			for channelID, _ in pairs(channels) do
				local guild = self[client:getChannel(channelID).guild.id]
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
