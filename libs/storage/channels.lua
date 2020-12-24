-- object to store data about new channels and interact with corresponding db
--[[
CREATE TABLE channels(
	id VARCHAR PRIMARY KEY,
	host VARCHAR NOT NULL,	/* mutable */
	parent VARCHAR NOT NULL,	/* immutable */
	position INTEGER NOT NULL,	/* immutable */
	companion VARCHAR	/* immutable */
)]]

local channelsData = require "sqlite3".open("channelsData.db")

local client = require "client"
local logger = require "logger"

local lobbies = require "storage/lobbies"

local storageInteraction = require "funcs/storageInteraction"

-- used to start storageInteractionEvent as async process
-- because fuck data preservation, we need dat speed
local emitter = require "discordia".Emitter()

local storageStatements = {
	add = {
		"INSERT INTO channels VALUES(?,?,?,?,?)",
		"Added channel %s", "Couldn't add channel %s"
	},
	
	remove = {
		"DELETE FROM channels WHERE id = ?",
		"Removed channel %s", "Couldn't remove channel %s"
	},
	
	setHost = {
		"UPDATE channels SET host = ? WHERE id = ?",
		"Updated host to %s for channel %s", "Couldn't update host to %s for channel %s"
	}
}

for name, statement in pairs(storageStatements) do
	emitter:on(name, storageInteraction(channelsData:prepare(statement[1]), statement[2], statement[3]))
end

local channels = {}
local channelMT = {
	__index = {
		-- no granular control, if it goes away, it does so everywhere
		delete = function (self)
			if channels[self.id] then
				channels[self.id] = nil
				logger:log(4, "CHANNEL %s: Removed", self.id)
			end
			emitter:emit("remove", self.id)
		end,
		
		setHost = function (self, hostID)
			local channel = client:getChannel(self.id)
			if channel and channels[self.id] then
				self.host = hostID
				logger:log(4, "GUILD %s: Updated host for channel %s", channel.guild.id, self.id)
				emitter:emit("setHost", hostID, self.id)
			else
				self:remove()
			end
		end
	},
	__tostring = function (self) return string.format("ChannelData: %s", self.id) end
}

local channelsIndex = {
	-- perform checks and add channel to table
	loadAdd = function (self, channelID, host, parent, position, companion)
		if not self[channelID] then
			local channel = client:getChannel(channelID)
			if channel and channel.guild then
				self[channelID] = setmetatable({
					id = channelID, host = host, parent = parent, position = position, companion = companion
				}, channelMT)
				logger:log(4, "GUILD %s: Added channel %s", channel.guild.id, channelID)
			end
		end
	end,
	
	-- loadAdd and start interaction with db
	add = function (self, channelID, host, parentID, position, companion)
		self:loadAdd(channelID, host, lobbies[parentID], position, companion)
		if self[channelID] then
			emitter:emit("add", channelID, parentID, position, host, companion)
			return self[channelID]
		end
	end,
	
	load = function (self)
		logger:log(4, "STARTUP: Loading channels")
		local channelIDs = channelsData:exec("SELECT * FROM channels")
		
		if channelIDs then
			for i, channelID in ipairs(channelIDs[1]) do
				local channel = client:getChannel(channelID)
				if channel then
					if #channel.connectedMembers > 0 then
						self:loadAdd(channelID, 
							channelIDs.host[i], lobbies[channelIDs.parent[i]], tonumber(channelIDs.position[i]), channelIDs.companion[i])
						if self[channelID].parent then
							self[channelID].parent:attachChild(channelID, tonumber(self[channelID].position))
						end
					else
						channel:delete()
					end
				else
					local companion = client:getChannel(channelIDs.companion[i])
					if companion then companion:delete() end
					emitter:emit("remove", channelID)
				end
			end
		end
		logger:log(4, "STARTUP: Loaded!")
	end,
	
	-- are there empty channels? kill!
	cleanup = function (self)
		for channelID, channelData in pairs(self) do
			local channel = client:getChannel(channelID)
			if channel then
				if #channel.connectedMembers == 0 then
					channel:delete()
				end
			else
				channelData:delete()
			end
		end
	end,
	
	-- how many are there?
	people = function (self, guildID)
		local p = 0
		for channelID, channelData in pairs(self) do
			local channel = client:getChannel(channelID)
			if channel then
				if guildID and channel.guild.id == guildID or not guildID then p = p + #channel.connectedMembers end
			else
				channelData:delete()
			end
		end
		return p
	end
}

return setmetatable(channels, {
	__index = channelsIndex,
	__len = function (self)
		local count = 0
		for v,_ in pairs(self) do count = count + 1 end
		return count
	end,
	__call = channelsIndex.add
})