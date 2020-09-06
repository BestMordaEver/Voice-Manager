-- object to store data about lobbies and interact with corresponding db
-- CREATE TABLE lobbies(id VARCHAR PRIMARY KEY, template VARCHAR, target VARCHAR)

local discordia = require "discordia"
local sqlite = require "sqlite3".open("lobbiesData.db")

local client, logger = discordia.storage.client, discordia.storage.logger

local utils = require "./utils.lua"
local storageInteractionEvent = utils.storageInteractionEvent
local hollowArray = utils.hollowArray
local channels = require "./channels.lua"

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

emitter:on("add", function (lobbyID)
	local ok, msg = pcall(storageInteractionEvent, add, lobbyID)
	if ok then
		logger:log(4, "MEMORY: Added lobby %s", lobbyID)
	else
		logger:log(2, "MEMORY: Couldn't add lobby %s: %s", lobbyID, msg)
		client:getChannel("686261668522491980"):sendf("Couldn't add lobby %s: %s", lobbyID, msg)
	end
end)

emitter:on("remove", function (lobbyID)
	local ok, msg = pcall(storageInteractionEvent, remove, lobbyID)
	if ok then
		logger:log(4, "MEMORY: Removed lobby %s", lobbyID)
	else
		logger:log(2, "MEMORY: Couldn't remove lobby %s: %s", lobbyID, msg)
		client:getChannel("686261668522491980"):sendf("Couldn't remove lobby %s: %s", lobbyID, msg)
	end
end)

emitter:on("updateTemplate", function (lobbyID, template)
	local ok, msg = pcall(storageInteractionEvent, updateTemplate, template, lobbyID)
	if ok then
		logger:log(4, "MEMORY: Updated template for lobby %s to %s", lobbyID, template)
	else
		logger:log(2, "MEMORY: Couldn't update template for lobby %s to %s: %s", lobbyID, template, msg)
		client:getChannel("686261668522491980"):sendf("Couldn't update template for lobby %s to %s: %s", lobbyID, template, msg)
	end
end)

emitter:on("updateTarget", function (lobbyID, target)
	local ok, msg = pcall(storageInteractionEvent, updateTarget, target, lobbyID)
	if ok then
		logger:log(4, "MEMORY: Updated target for lobby %s to %s", lobbyID, target)
	else
		logger:log(2, "MEMORY: Couldn't update target for lobby %s to %s: %s", lobbyID, target, msg)
		client:getChannel("686261668522491980"):sendf("Couldn't update target for lobby %s to %s: %s", lobbyID, target, msg)
	end
end)

emitter:on("updatePermissions", function (lobbyID, permissions)
	local ok, msg = pcall(storageInteractionEvent, updatePermissions, permissions, lobbyID)
	if ok then
		logger:log(4, "MEMORY: Updated permissions for lobby %s to %s", lobbyID, permissions)
	else
		logger:log(2, "MEMORY: Couldn't update permissions for lobby %s to %s: %s", lobbyID, permissions, msg)
		client:getChannel("686261668522491980"):sendf("Couldn't update permissions for lobby %s to %s: %s", lobbyID, permissions, msg)
	end
end)

return setmetatable({}, {
	-- move functions to index table to iterate over lobbies easily
	__index = {
	-- perform checks and add lobby to table
		loadAdd = function (self, lobbyID, template, target, permissions)	-- additional parameter are used upon startup to prevent unnecessary checks
			if not self[lobbyID] then
				local channel = client:getChannel(lobbyID)
				if channel and channel.guild then
					self[lobbyID] = {template = template, target = target, permissions = tonumber(permissions) or 0, children = hollowArray()}
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