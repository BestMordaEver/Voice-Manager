-- object to store data about new channels and interact with corresponding db
--[[
CREATE TABLE channels(
	id VARCHAR PRIMARY KEY,
	isPersistent BOOL, /* immutable */
	host VARCHAR NOT NULL,	/* mutable */
	parent VARCHAR NOT NULL,	/* immutable */
	position INTEGER NOT NULL,	/* immutable */
	companion VARCHAR	/* immutable */
)]]

local channelsData = require "sqlite3".open("channelsData.db")

local client = require "client"
local logger = require "logger"

local lobbies = require "storage/lobbies"

local Overseer = require "utils/logWriter"
local storageInteraction = require "funcs/storageInteraction"

-- used to start storageInteractionEvent as async process
-- because fuck data preservation, we need dat speed
local emitter = require "discordia".Emitter()

local storageStatements = {
	add = {"INSERT INTO channels VALUES(?,?,?,?,?,?)", "ADD CHANNEL %s"},

	remove = {"DELETE FROM channels WHERE id = ?", "DELETE CHANNEL %s"},

	setHost = {"UPDATE channels SET host = ? WHERE id = ?", "SET HOST %s => CHANNEL %s"}
}

for name, statement in pairs(storageStatements) do
	emitter:on(name, storageInteraction(channelsData:prepare(statement[1]), statement[2]))
end

local channels = {}
local channelMT = {
	__index = {
		-- no granular control, if it goes away, it does so everywhere
		delete = function (self)
			if channels[self.id] then
				if type(self.parent) == "table" then self.parent:detachChild(self.position) end
				channels[self.id] = nil
				logger:log(6, "GUILD %s ROOM %s: deleted", self.guildID, self.id)
			end
			emitter:emit("remove", self.id)
		end,

		setHost = function (self, hostID)
			local channel = client:getChannel(self.id)
			if channel and channels[self.id] then
				self.host = hostID
				logger:log(6, "GUILD %s ROOM %s: updated host to %s", channel.guild.id, self.id, hostID)
				emitter:emit("setHost", hostID, self.id)
			else
				self:delete()
			end
		end
	},
	__tostring = function (self) return string.format("ChannelData: %s", self.id) end
}

local channelsIndex = {
	-- perform checks and add channel to table
	loadAdd = function (self, channelID, isPersistent, host, parent, position, companion)
		if not self[channelID] then
			local channel = client:getChannel(channelID)
			if channel and channel.guild then
				self[channelID] = setmetatable({
					id = channelID, guildID = channel.guild.id, isPersistent = isPersistent, host = host, parent = parent, position = position, companion = companion
				}, channelMT)
				logger:log(6, "GUILD %s ROOM %s: added", channel.guild.id, channelID)
			end
		end
	end,

	-- loadAdd and start interaction with db
	add = function (self, channelID, isPersistent, host, parentID, position, companion)
		self:loadAdd(channelID, isPersistent, host, lobbies[parentID], position, companion)
		if self[channelID] then
			emitter:emit("add", channelID, isPersistent and 1 or 0, host, parentID, position, companion)
			return self[channelID]
		end
	end,

	load = function (self)
		logger:log(4, "STARTUP: Loading rooms")
		local channelIDs = channelsData:exec("SELECT * FROM channels")

		if channelIDs then
			for i, channelID in ipairs(channelIDs[1]) do
				local channel = client:getChannel(channelID)
				if channel then
					if #channel.connectedMembers > 0 then
						local parent = lobbies[channelIDs.parent[i]] -- can be nil!

						self:loadAdd(channelID, 
							channelIDs.isPersistent[i] == 1, channelIDs.host[i], parent,
							tonumber(channelIDs.position[i]), channelIDs.companion[i])

						if parent then
							parent:attachChild(self[channelID], tonumber(self[channelID].position))
							if channelIDs.companion[i] and parent.companionLog and client:getChannel(channelIDs.companion[i]) then
								Overseer:resume(client:getChannel(channelIDs.companion[i]))
							end
						end
					else
						if channelIDs.isPersistent[i] == 1 then
							emitter:emit("remove", channelID)
						else
							channel:delete()
						end
						local companion = client:getChannel(channelIDs.companion[i])
						if companion then companion:delete() end
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
					if channelData.isPersistent then
						channelData:delete()
					else
						channel:delete()
					end
				end
			else
				local companion = client:getChannel(channelData.companion)
				if companion then companion:delete() end
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
			end
		end
		return p
	end,

	inGuild = function (self, guildID)
		local count = 0
		for _,channelData in pairs(self) do if channelData.guildID == guildID then count = count + 1 end end
		return count
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