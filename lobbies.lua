-- object to store data about lobbies and interact with corresponding db

local discordia = require "discordia"
local sqlite = require "sqlite3".open("lobbiesData.db")

local client, logger = discordia.storage.client, discordia.storage.logger

local storageInteractionEvent = require "./utils.lua".storageInteractionEvent

-- used to start storageInteractionEvent as async process
-- because fuck data preservation, we need dat speed
local emitter = discordia.Emitter()

local channels = require "./channels.lua"

-- prepared statements
local add, remove, updateTemplate =
	sqlite:prepare("INSERT INTO lobbies VALUES(?,NULL)"),
	sqlite:prepare("DELETE FROM lobbies WHERE id = ?"),
	sqlite:prepare("UPDATE lobbies SET template = ? WHERE id = ?")

emitter:on("add", function (lobbyID)
	local ok, msg = pcall(storageInteractionEvent, add, lobbyID)
	if ok then
		logger:log(4, "MEMORY: Added lobby %s", lobbyID)
	else
		logger:log(2, "MEMORY: Couldn't add lobby %s: %s", lobbyID, msg)
	end
end)

emitter:on("remove", function (lobbyID)
	local ok, msg = pcall(storageInteractionEvent, remove, lobbyID)
	if ok then
		logger:log(4, "MEMORY: Removed lobby %s", lobbyID)
	else
		logger:log(2, "MEMORY: Couldn't remove lobby %s: %s", lobbyID, msg)
	end
end)

emitter:on("updateTemplate", function (lobbyID, template)
	local ok, msg = pcall(storageInteractionEvent, add, template, lobbyID)
	if ok then
		logger:log(4, "MEMORY: Updated template for lobby %s to %s", lobbyID, template)
	else
		logger:log(2, "MEMORY: Couldn't update template for lobby %s to %s: %s", lobbyID, template, msg)
	end
end)

return setmetatable({}, {
	-- move functions to index table to iterate over lobbies easily
	__index = {
	-- perform checks and add lobby to table
		loadAdd = function (self, lobbyID, template)	-- additional parameter are used upon startup to prevent unnecessary checks
			if channels[lobbyID] then channels:remove(lobbyID) end	-- I swear to god, there will be one crackhead
			
			if not self[lobbyID] then
				local channel = client:getChannel(lobbyID)
				if channel and channel.guild then
					self[lobbyID] = {template = template}
					logger:log(4, "GUILD %s: Added lobby %s", channel.guild.id, lobbyID)
				end
			end
		end,
		
		-- loadAdd and start interaction with db
		add = function (self, lobbyID)
			self:loadAdd(lobbyID)
			if self[lobbyID] then emitter:emit("add", lobbyID) end
		end,
		
		-- no granular control, if it goes away, it does so everywhere
		remove = function (self, lobbyID)
			if self[lobbyID] then
				self[lobbyID] = nil
				local lobby = client:getChannel(lobbyID)
				if lobby and lobby.guild then
					logger:log(4, "GUILD %s: Removed lobby %s", lobby.guild.id, lobbyID)
				else
					logger:log(4, "NULL: Removed lobby %s", lobbyID)
				end
			end
			emitter:emit("remove", lobbyID)
		end,
		
		load = function (self)
			logger:log(4, "STARTUP: Loading lobbies")
			local lobbyIDs = sqlite:exec("SELECT * FROM lobbies")
			if lobbyIDs then
				for i, lobbyID in ipairs(lobbyIDs[1]) do
					if client:getChannel(lobbyID) then
						self:loadAdd(lobbyID, lobbyIDs.template[i])
					else
						self:remove(lobbyID)
					end
				end
			end
			logger:log(4, "STARTUP: Loaded!")
		end,
		
		-- there should be enough checks to ensure that lobby and template are valid
		updateTemplate = function (self, lobbyID, template)
			local channel = client:getChannel(lobbyID)
			if channel and self[lobbyID] then
				self[lobbyID].template = template
				logger:log(4, "GUILD %s: Updated template for lobby %s", channel.guild.id, lobbyID)
				emitter:emit("updateTemplate", lobbyID, template)
			else
				self:remove(lobbyID)
			end
		end,
		
		-- check how many lobbies are in a specific guild
		inGuild = function (self, guildID)
			local count = 0
			for v,_ in pairs(self) do if client:getChannel(v).guild.id == guildID then count = count + 1 end end
			return count
		end
	},
	__len = function (self)
		local count = 0
		for v,_ in pairs(self) do count = count + 1 end
		return count
	end
})