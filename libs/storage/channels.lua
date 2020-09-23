-- object to store data about new channels and interact with corresponding db
-- CREATE TABLE channels(id VARCHAR PRIMARY KEY, parent VARCHAR, position INTEGER)

local discordia = require "discordia"
local sqlite = require "sqlite3".open("channelsData.db")

local client, logger = discordia.storage.client, discordia.storage.logger

local storageInteraction = require "utils/storageInteraction"

-- used to start storageInteractionEvent as async process
-- because fuck data preservation, we need dat speed
local emitter = discordia.Emitter()

-- prepared statements
local add, remove, updateHost =
	sqlite:prepare("INSERT INTO channels VALUES(?,?,?,?)"),
	sqlite:prepare("DELETE FROM channels WHERE id = ?"),
	sqlite:prepare("UPDATE channels SET host = ? WHERE id = ?")
	

emitter:on("add", storageInteraction(add, "Added channel %s", "Couldn't add channel %s"))
emitter:on("remove", storageInteraction(remove, "Removed channel %s", "Couldn't remove channel %s"))
emitter:on("updateHost", storageInteraction(updateHost, "Updated host to %s for channel %s", "Couldn't update host to %s for channel %s"))

return setmetatable({}, {
	-- move functions to index table to iterate over channels easily
	__index = {
		-- perform checks and add channel to table
		loadAdd = function (self, channelID, host, parent, position)
			if not self[channelID] then
				local channel = client:getChannel(channelID)
				if channel and channel.guild then
					self[channelID] = {host = host, parent = parent, position = position}
					logger:log(4, "GUILD %s: Added channel %s", channel.guild.id, channelID)
				end
			end
		end,
		
		-- loadAdd and start interaction with db
		add = function (self, channelID, host, parent, position)
			self:loadAdd(channelID, host, parent, position)
			if self[channelID] then emitter:emit("add", channelID, parent, position, host) end
		end,
		
		-- no granular control, if it goes away, it does so everywhere
		remove = function (self, channelID)
			if self[channelID] then
				self[channelID] = nil
				local channel = client:getChannel(channelID)
				if channel and channel.guild then
					logger:log(4, "GUILD %s: Removed channel %s", channel.guild.id, channelID)
				else
					logger:log(4, "NULL: Removed channel %s", channelID)
				end
			end
			emitter:emit("remove", channelID)
		end,
		
		load = function (self)
			logger:log(4, "STARTUP: Loading channels")
			local channelIDs = sqlite:exec("SELECT * FROM channels")
			if channelIDs then
				for i, channelID in ipairs(channelIDs[1]) do
					local channel = client:getChannel(channelID)
					if channel then
						if #channel.connectedMembers > 0 then
							self:loadAdd(channelID, channelIDs.host[i], channelIDs.parent[i], tonumber(channelIDs.position[i]))
						else
							channel:delete()
						end
					else
						self:remove(channelID)
					end
				end
			end
			logger:log(4, "STARTUP: Loaded!")
		end,
		
		updateHost = function (self, channelID, hostID)
			local channel = client:getChannel(channelID)
			if channel and self[channelID] then
				self[channelID].host = hostID
				logger:log(4, "GUILD %s: Updated host for channel %s", channel.guild.id, channelID)
				emitter:emit("updateHost", hostID, channelID)
			else
				self:remove(channelID)
			end
		end,
		
		-- are there empty channels? kill!
		cleanup = function (self)
			for channelID,_ in pairs(self) do
				local channel = client:getChannel(channelID)
				if channel then
					if #channel.connectedMembers == 0 then
						channel:delete()
					end
				else
					self:remove(channelID)
				end
			end
		end,
		
		-- how many are there?
		people = function (self, guildID)
			local p = 0
			for channelID, _ in pairs(self) do
				local channel = client:getChannel(channelID)
				if channel then
					if guildID and channel.guild.id == guildID or not guildID then p = p + #channel.connectedMembers end
				else
					self:remove(channelID)
				end
			end
			return p
		end
	},
	__len = function (self)
		local count = 0
		for v,_ in pairs(self) do count = count + 1 end
		return count
	end
})