local client = require "client"
local logger = require "logger"

local emitter = require "discordia".Emitter()
local storageCall = require "storage/storageCall"
local channelsDB = require "sqlite3".open("channelsData.db")

local storageStatements = {
	addChannel = {"INSERT INTO channels(id, parentType, host, parent, position, companion) VALUES(?,?,?,?,?,?)", "ADD CHANNEL %s"},

	removeChannel = {"DELETE FROM channels WHERE id = ?", "DELETE CHANNEL %s"},

	setChannelHost = {"UPDATE channels SET host = ? WHERE id = ?", "SET HOST %s => CHANNEL %s"},

	setChannelPassword = {"UPDATE channels SET password = ? WHERE id = ?", "SET PASSWORD %s => CHANNEL %s"}
}

for name, statement in pairs(storageStatements) do
	emitter:on(name, storageCall(channelsDB:prepare(statement[1]), statement[2]))
end

local channels = {}
local channelMeta = {
	__index = {
		delete = function (self)
			if channels[self.id] then
				if self.parent and self.parent.detachChild then self.parent:detachChild(self.position) end
				channels[self.id] = nil
				logger:log(6, "GUILD %s ROOM %s: deleted", self.guildID, self.id)
			end
			emitter:emit("removeChannel", self.id)
		end,

		setHost = function (self, hostID)
			local channel = client:getChannel(self.id)
			if channel and channels[self.id] then
				self.host = hostID
				logger:log(6, "GUILD %s ROOM %s: updated host to %s", channel.guild.id, self.id, hostID)
				emitter:emit("setChannelHost", hostID, self.id)
			else
				self:delete()
			end
		end,

		setPassword = function (self, password)
			self.password = password
			logger:log(6, "GUILD %s ROOM %s: updated password to %s", self.guildID, self.id, password)
			emitter:emit("setChannelPassword", password, self.id)	-- yes, password is saved as plaintext without any safety
		end	-- if you don't understand why this is sufficient data protection, i recommend you review the use case
	},
	__tostring = function (self) return string.format("ChannelData: %s", self.id) end
}

local parents = {[0] = require "storage/lobbies", require "storage/guilds", nil --[[require "storage/categories"]], channels}

setmetatable(channels, {
	__index = {
		loadStatement = channelsDB:prepare("SELECT id, parentType, host, parent, position, companion, password FROM channels"),

		add = function (self, channelID, parentType, host, parentID, position, companion, password)
			local parent = parents[tonumber(parentType)][parentID]
			if parent then
				self[channelID] = setmetatable({
					id = channelID,
					guildID = parent.guild and parent.guild.id or parent.id,
					parentType = tonumber(parentType),
					host = host,
					parent = parent,
					position = tonumber(position),
					companion = companion,
					password = password
				}, channelMeta)
				if parent.attachChild then parent:attachChild(self[channelID], tonumber(position)) end

				logger:log(6, "GUILD %s ROOM %s: added", self[channelID].guildID, channelID)
			else
				self[channelID] = setmetatable({
					id = channelID,
					parentID = parentID,
					parentType = tonumber(parentType),
					host = host,
					position = tonumber(position),
					companion = companion,
					password = password
				}, channelMeta)
				logger:log(6, "ORPHAN ROOM %s: added", channelID)
			end
			return self[channelID]
		end,

		store = function (self, channelID, parentType, host, parentID, position, companion)
			emitter:emit("addChannel", channelID, parentType, host, parentID, position, companion)
			return self:add(channelID, parentType, host, parentID, position, companion)
		end,

		cleanup = function (self)
			for channelID, channelData in pairs(self) do
				local channel = client:getChannel(channelID)
				if channel then
					if #channel.connectedMembers == 0 then
						if channelData.parentType == 0 or channelData.parentType == 3 then
							channel:delete()
						end
						channelData:delete()
					end
				elseif not (client:getGuild(channelData.guildID) and client:getGuild(channelData.guildID).unavailable) then
					local companion = client:getChannel(channelData.companion)
					if companion then companion:delete() end
					channelData:delete()
				end
			end
		end,

		users = function (self)
			local p = 0
			for channelID, _ in pairs(self) do
				local channel = client:getChannel(channelID)
				if channel then
					p = p + #channel.connectedMembers
				end
			end
			return p
		end
	},
	__len = function (self)
		local count = 0
		for v,_ in pairs(self) do count = count + 1 end
		return count
	end,
	__tostring = function () return "ChannelStorage" end
})

return channels, emitter