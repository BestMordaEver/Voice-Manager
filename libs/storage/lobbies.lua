-- object to store data about lobbies and interact with corresponding db
-- CREATE TABLE lobbies(id VARCHAR PRIMARY KEY, template VARCHAR, target VARCHAR)

local discordia = require "discordia"
local sqlite = require "sqlite3".open("libs/storage/lobbiesData.db")

local client, logger = discordia.storage.client, discordia.storage.logger

local channels = require "storage/channels"
local storageInteraction = require "utils/storageInteraction"
local hollowArray = require "utils/hollowArray"

-- used to start storageInteractionEvent as async process
-- because fuck data preservation, we need dat speed
local emitter = discordia.Emitter()

-- prepared statements
local add, remove, updateTemplate, updateTarget, updatePermissions =
	sqlite:prepare("INSERT INTO lobbies VALUES(?,NULL,NULL, 0)"),
	sqlite:prepare("DELETE FROM lobbies WHERE id = ?"),
	sqlite:prepare("UPDATE lobbies SET template = ? WHERE id = ?"),
	sqlite:prepare("UPDATE lobbies SET target = ? WHERE id = ?"),
	sqlite:prepare("UPDATE lobbies SET permissions = ? WHERE id = ?")

emitter:on("add", storageInteraction(add, "Added lobby %s", "Couldn't add lobby %s"))
emitter:on("remove", storageInteraction(remove, "Removed lobby %s", "Couldn't remove lobby %s"))
emitter:on("updateTemplate", storageInteraction(updateTemplate, "Updated template to %s for lobby %s", "Couldn't update template to %s for lobby %s"))
emitter:on("updateTarget", storageInteraction(updateTarget, "Updated target to %s for lobby %s", "Couldn't update target to %s for lobby %s"))
emitter:on("updatePermissions", storageInteraction(updatePermissions, "Updated permissions to %s for lobby %s", "Couldn't update permissions to %s for lobby %s"))

return setmetatable({}, {
	-- move functions to index table to iterate over lobbies easily
	__index = {
	-- perform checks and add lobby to table
		loadAdd = function (self, lobbyID, template, target, permissions)	-- additional parameter are used upon startup to prevent unnecessary checks
			if not self[lobbyID] then
				local channel = client:getChannel(lobbyID)
				if channel and channel.guild then
					self[lobbyID] = {template = template, target = target, permissions = tonumber(permissions) or 0, children = hollowArray(), mutex = discordia.Mutex()}
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
						self:loadAdd(lobbyID, lobbyIDs.template[i], client:getChannel(lobbyIDs.target[i]) and lobbyIDs.target[i] or nil, lobbyIDs.permissions[i])
					else
						self:remove(lobbyID)
					end
				end
				
				for channelID, channelData in pairs(channels) do
					if self[channelData.parent] then
						self[channelData.parent].children:fill(channelID, tonumber(channelData.position))
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
		
		updateTarget = function (self, lobbyID, target)
			local channel = client:getChannel(lobbyID)
			if channel and self[lobbyID] then
				self[lobbyID].target = target
				logger:log(4, "GUILD %s: Updated target for lobby %s", channel.guild.id, lobbyID)
				emitter:emit("updateTarget", lobbyID, target)
			else
				self:remove(lobbyID)
			end
		end,
		
		updatePermissions = function (self, lobbyID, permissions)
			local channel = client:getChannel(lobbyID)
			if channel and self[lobbyID] then
				self[lobbyID].permissions = permissions
				logger:log(4, "GUILD %s: Updated permissions for lobby %s", channel.guild.id, lobbyID)
				emitter:emit("updatePermissions", lobbyID, permissions)
			else
				self:remove(lobbyID)
			end
		end,
		
		-- returns filled position
		attachChild = function (self, lobbyID, channelID, position)
			return self[lobbyID].children:fill(channelID, position)
		end,
		
		detachChild = function (self, channelID)
			if channels[channelID] and self[channels[channelID].parent] then
				self[channels[channelID].parent].children:drain(channels[channelID].position)
			end
		end
	},
	__len = function (self)
		local count = 0
		for v,_ in pairs(self) do count = count + 1 end
		return count
	end
})