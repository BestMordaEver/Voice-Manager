-- object to store data about lobbies and interact with corresponding db
-- CREATE TABLE lobbies(id VARCHAR PRIMARY KEY, template VARCHAR, target VARCHAR, permissions INTEGER, capacity INTEGER, companion VARCHAR)

local discordia = require "discordia"
local sqlite = require "sqlite3".open("lobbiesData.db")

local client, logger = discordia.storage.client, discordia.storage.logger

local storageInteraction = require "utils/storageInteraction"
local hollowArray = require "utils/hollowArray"

-- used to start storageInteractionEvent as async process
-- because fuck data preservation, we need dat speed
local emitter = discordia.Emitter()

-- prepared statements
local add, remove, updateTemplate, updateTarget, updatePermissions, updateCapacity, updateCompanion =
	sqlite:prepare("INSERT INTO lobbies VALUES(?,NULL,NULL, 0,-1,NULL)"),
	sqlite:prepare("DELETE FROM lobbies WHERE id = ?"),
	sqlite:prepare("UPDATE lobbies SET template = ? WHERE id = ?"),
	sqlite:prepare("UPDATE lobbies SET target = ? WHERE id = ?"),
	sqlite:prepare("UPDATE lobbies SET permissions = ? WHERE id = ?"),
	sqlite:prepare("UPDATE lobbies SET capacity = ? WHERE id = ?"),
	sqlite:prepare("UPDATE lobbies SET companion = ? WHERE id = ?")

emitter:on("add", storageInteraction(add, "Added lobby %s", "Couldn't add lobby %s"))
emitter:on("remove", storageInteraction(remove, "Removed lobby %s", "Couldn't remove lobby %s"))
emitter:on("updateTemplate", storageInteraction(updateTemplate, "Updated template to %s for lobby %s", "Couldn't update template to %s for lobby %s"))
emitter:on("updateTarget", storageInteraction(updateTarget, "Updated target to %s for lobby %s", "Couldn't update target to %s for lobby %s"))
emitter:on("updatePermissions", storageInteraction(updatePermissions, "Updated permissions to %s for lobby %s", "Couldn't update permissions to %s for lobby %s"))
emitter:on("updateCapacity", storageInteraction(updateCapacity, "Updated capacity to %s for lobby %s", "Couldn't update capacity to %s for lobby %s"))
emitter:on("updateCompanion", storageInteraction(updateCompanion, "Updated companion target to %s for lobby %s", "Couldn't update companion target to %s for lobby %s"))

local lobbies = {}
local lobbyMT = {
	__index = {
		-- no granular control, if it goes away, it does so everywhere
		delete = function (self)
			if lobbies[self.id] then
				lobbies[self.id] = nil
				local lobby = client:getChannel(self.id)
				if lobby and lobby.guild then
					logger:log(4, "GUILD %s: Removed lobby %s", lobby.guild.id, self.id)
				else
					logger:log(4, "NULL: Removed lobby %s", self.id)
				end
			end
			emitter:emit("remove", self.id)
		end,
		
		-- there should be enough checks to ensure that lobby and template are valid
		updateTemplate = function (self, template)
			local channel = client:getChannel(self.id)
			if channel and lobbies[self.id] then
				self.template = template
				logger:log(4, "GUILD %s: Updated template for lobby %s", channel.guild.id, self.id)
				emitter:emit("updateTemplate", template, self.id)
			else
				self:delete()
			end
		end,
		
		updateTarget = function (self, target)
			local channel = client:getChannel(self.id)
			if channel and lobbies[self.id] then
				self.target = target
				logger:log(4, "GUILD %s: Updated target for lobby %s", channel.guild.id, self.id)
				emitter:emit("updateTarget", target, self.id)
			else
				self:delete()
			end
		end,
		
		updatePermissions = function (self, permissions)
			local channel = client:getChannel(self.id)
			if channel and lobbies[self.id] then
				self.permissions = permissions
				logger:log(4, "GUILD %s: Updated permissions for lobby %s", channel.guild.id, self.id)
				emitter:emit("updatePermissions", permissions, self.id)
			else
				self:delete()
			end
		end,
		
		updateCapacity = function (self, capacity)
			local channel = client:getChannel(self.id)
			if channel and lobbies[self.id] then
				self.capacity = capacity
				logger:log(4, "GUILD %s: Updated capacity for lobby %s", channel.guild.id, self.id)
				emitter:emit("updateCapacity", capacity, self.id)
			else
				self:delete()
			end
		end,
		
		updateCompanion = function (self, target)
			local channel = client:getChannel(self.id)
			if channel and lobbies[self.id] then
				self.companion = target
				logger:log(4, "GUILD %s: Updated companion target for lobby %s", channel.guild.id, self.id)
				emitter:emit("updateCompanion", target, self.id)
			else
				self:delete()
			end
		end,
		
		-- returns filled position
		attachChild = function (self, channelID, position)
			return self.children:fill(channelID, position)
		end,
		
		detachChild = function (self, position)
			self.children:drain(position)
		end
	},
	__tostring = function (self) return string.format("LobbyData: %s", self.id) end
}
local lobbiesIndex = {
	-- perform checks and add lobby to table
	loadAdd = function (self, lobbyID, template, target, permissions, capacity, companion)	-- additional parameter are used upon startup to prevent unnecessary checks
		if not self[lobbyID] then
			local channel = client:getChannel(lobbyID)
			if channel and channel.guild then
				self[lobbyID] = setmetatable({
					id = lobbyID, template = template, target = target, companion = companion,
					permissions = tonumber(permissions) or 0, capacity = tonumber(capacity) or -1,
					children = hollowArray(), mutex = discordia.Mutex()
				}, lobbyMT)
				logger:log(4, "GUILD %s: Added lobby %s", channel.guild.id, lobbyID)
			end
		end
	end,
	
	-- loadAdd and start interaction with db
	add = function (self, lobbyID)
		self:loadAdd(lobbyID)
		if self[lobbyID] then
			emitter:emit("add", lobbyID)
			return self[lobbyID]
		end
	end,
	
	load = function (self)
		logger:log(4, "STARTUP: Loading lobbies")
		local lobbyIDs = sqlite:exec("SELECT * FROM lobbies")
		if lobbyIDs then
			for i, lobbyID in ipairs(lobbyIDs[1]) do
				if client:getChannel(lobbyID) then
					self:loadAdd(lobbyID, lobbyIDs.template[i], 
						client:getChannel(lobbyIDs.target[i]) and lobbyIDs.target[i] or nil,
						lobbyIDs.permissions[i], lobbyIDs.capacity[i], lobbyIDs.companion[i])
				else
					emitter:emit("remove", lobbyID)
				end
			end
		end
		logger:log(4, "STARTUP: Loaded!")
	end
}

return setmetatable(lobbies, {
	__index = lobbiesIndex,
	__len = function (self)
		local count = 0
		for v,_ in pairs(self) do count = count + 1 end
		return count
	end,
	__call = lobbiesIndex.add
})