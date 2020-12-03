-- object to store data about guilds and interact with corresponding db
-- CREATE TABLE guilds(id VARCHAR PRIMARY KEY, prefix VARCHAR, template VARCHAR, limitation INTEGER)

local discordia = require "discordia"
local sqlite = require "sqlite3".open("guildsData.db")

local client, logger = discordia.storage.client, discordia.storage.logger

local lobbies = require "storage/lobbies"
local channels = require "storage/channels"
local storageInteraction = require "storage/storageInteraction"
local set = require "utils/set"

-- used to start storageInteractionEvent as async process
-- because fuck data preservation, we need dat speed
local emitter = discordia.Emitter()

-- prepared statements
local add, remove, updatePrefix, updateTemplate, updateLimitation =
	sqlite:prepare("INSERT INTO guilds VALUES(?,'!vm',NULL, 500)"),
	sqlite:prepare("DELETE FROM guilds WHERE id = ?"),
	sqlite:prepare("UPDATE guilds SET prefix = ? WHERE id = ?"),
	sqlite:prepare("UPDATE guilds SET template = ? WHERE id = ?"),
	sqlite:prepare("UPDATE guilds SET limitation = ? WHERE id = ?")

emitter:on("add", storageInteraction(add, "Added guild %s", "Couldn't add guild %s"))
emitter:on("remove", storageInteraction(remove, "Removed guild %s", "Couldn't remove guild %s"))
emitter:on("updatePrefix", storageInteraction(updatePrefix, "Updated prefix to %s for guild %s", "Couldn't update prefix to %s for guild %s"))
emitter:on("updateTemplate", storageInteraction(updateTemplate, "Updated template to %s for guild %s", "Couldn't update template to %s for guild %s"))
emitter:on("updateLimitation", storageInteraction(updateLimitation, "Updated limitation to %s for guild %s", "Couldn't update limitation to %s for guild %s"))

local guilds = {}
local guildMT = {
	__index = {
		-- no granular control, if it goes away, it does so everywhere
		delete = function (self)
			guilds[self.id] = nil
			logger:log(4, "GUILD %s: Removed", self.id)
			emitter:emit("remove", self.id)
		end,
		
		-- there should be enough checks to ensure that guild and prefix are valid
		updatePrefix = function (self, prefix)
			self.prefix = prefix
			logger:log(4, "GUILD %s: Updated prefix", self.id)
			emitter:emit("updatePrefix", prefix, self.id)
		end,
		
		-- there should be enough checks to ensure that guild and template are valid
		updateTemplate = function (self, template)
			self.template = template
			logger:log(4, "GUILD %s: Updated template", self.id)
			emitter:emit("updateTemplate", template, self.id)
		end,
		
		updateLimitation = function (self, limitation)
			self.limitation = limitation
			logger:log(4, "GUILD %s: Updated limitation", self.id)
			emitter:emit("updateLimitation", limitation, self.id)
		end
	},
	__tostring = function (self) return string.format("GuildData: %s", self.id) end
}
local guildsIndex = {
	-- no safety needed, it's either loading time or new guild time, whoever spams invites can go to hell
	loadAdd = function (self, guildID, prefix, template, limitation)
		self[guildID] = setmetatable({id = guildID, prefix = prefix or "!vm", template = template, limitation = limitation or 500, lobbies = set(), channels = 0}, guildMT)
		logger:log(4, "GUILD %s: Added", guildID)
	end,
	
	-- loadAdd and start interaction with db
	add = function (self, guildID)
		self:loadAdd(guildID)
		emitter:emit("add", guildID)
		return self[guildID]
	end,
	
	load = function (self)
		logger:log(4, "STARTUP: Loading guilds from save")
		local guildIDs = sqlite:exec("SELECT * FROM guilds")
		if guildIDs then
			for i, guildID in ipairs(guildIDs.id) do
				if client:getGuild(guildID) then
					self:loadAdd(guildID, guildIDs.prefix[i], guildIDs.template[i], tonumber(guildIDs.limitation[i]))
				else
					emitter:emit("remove", guildID)
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
	end
}

return setmetatable({}, {
	__index = guildsIndex,
	__call = guildsIndex.add
})
