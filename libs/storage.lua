-- any interaction with database comes through here
local config = require "config"
local client = require "client"
local logger = require "logger"

local discordia = require "discordia"

-- no statement is to be used by two threads at the same time
local Mutex = discordia.Mutex

-- statements are processed asynchronously
local emitter = discordia.Emitter()

local set = require "utils/set"
local Overseer = require "utils/logWriter"
local hollowArray = require "utils/hollowArray"
local botPermissions = require "utils/botPermissions"

local unpack = table.unpack

local guilds, lobbies, categories, channels = {}, {}, {}, {}

-- methods inherited by individual data structures
local guildMeta = {
	__index = {
		delete = function (self)
			if guilds[self.id] then
				guilds[self.id] = nil
				logger:log(6, "GUILD %s: deleted", self.id)
			end
			emitter:emit("removeGuild", self.id)
		end,

		setRole = function (self, role)
			self.role = role
			logger:log(6, "GUILD %s: updated managed role to %d", self.id, role)
			emitter:emit("setGuildRole", role, self.id)
		end,

		setLimit = function (self, limit)
			self.limit = limit
			logger:log(6, "GUILD %s: updated limit to %d", self.id, limit)
			emitter:emit("setGuildLimit", limit, self.id)
		end,

		setPermissions = function (self, permissions)
			self.permissions = permissions
			logger:log(6, "GUILD %s: updated permissions to %d", self.id, permissions.bitfield.value)
			emitter:emit("setGuildPermissions", permissions.bitfield.value, self.id)
		end,

		channels = function (self)
			local count = 0
			for lobbyData, _ in pairs(self.lobbies) do
				count = count + #lobbyData.children
			end
			return count
		end,

		users = function (self)
			local count = 0
			for lobbyData, _ in pairs(self.lobbies) do
				for _, channelData in pairs(lobbyData.children) do
					local channel = client:getChannel(channelData.id)
					if channel then
						count = count + #channel.connectedMembers
					end
				end
			end
			return count
		end
	},
	__tostring = function (self) return string.format("GuildData: %s", self.id) end
}

local lobbyMeta = {
	__index = {
		delete = function (self)
			if lobbies[self.id] then
				lobbies[self.id] = nil
				local lobby = client:getChannel(self.id)
				if lobby and self.guild then
					self.guild.lobbies:remove(self)
					logger:log(6, "GUILD %s LOBBY %s: deleted", self.guild.id, self.id)
				end
			end
			emitter:emit("removeLobby", self.id)
		end,

		setMatchmaking = function (self, isMatchmaking)
			self.isMatchmaking = isMatchmaking
			logger:log(6, "GUILD %s LOBBY %s: updated matchmaking status to %s", self.guild.id, self.id, isMatchmaking)
			emitter:emit("setLobbyMatchmaking", isMatchmaking and 1 or 0, self.id)
		end,

		setRole = function (self, role)
			self.role = role
			logger:log(6, "GUILD %s LOBBY %s: updated managed role to %s", self.guild.id, self.id, role)
			emitter:emit("setLobbyRole", role, self.id)
		end,

		setPermissions = function (self, permissions)
			self.permissions = permissions
			logger:log(6, "GUILD %s LOBBY %s: udated permissions to %s", self.guild.id, self.id, permissions)
			emitter:emit("setLobbyPermissions", permissions.bitfield.value, self.id)
		end,

		setTemplate = function (self, template)
			self.template = template
			logger:log(6, "GUILD %s LOBBY %s: updated template to %s", self.guild.id, self.id, template)
			emitter:emit("setLobbyTemplate", template, self.id)
		end,

		setTarget = function (self, target)
			self.target = target
			logger:log(6, "GUILD %s LOBBY %s: updated target to %s", self.guild.id, self.id, target)
			emitter:emit("setLobbyTarget", target, self.id)
		end,

		setCapacity = function (self, capacity)
			self.capacity = capacity
			logger:log(6, "GUILD %s LOBBY %s: updated capacity to %s", self.guild.id, self.id, capacity)
			emitter:emit("setLobbyCapacity", capacity, self.id)
		end,

		setBitrate = function (self, bitrate)
			self.bitrate = bitrate
			logger:log(6, "GUILD %s LOBBY %s: updated bitrate to %s", self.guild.id, self.id, bitrate)
			emitter:emit("setLobbyBitrate", bitrate, self.id)
		end,

		setCompanionTarget = function (self, companionTarget)
			self.companionTarget = companionTarget
			logger:log(6, "GUILD %s LOBBY %s: updated companion target to %s", self.guild.id, self.id, companionTarget)
			emitter:emit("setLobbyCompanionTarget", tostring(companionTarget), self.id)
		end,

		setCompanionTemplate = function (self, companionTemplate)
			self.companionTemplate = companionTemplate
			logger:log(6, "GUILD %s LOBBY %s: updated companion template to %s", self.guild.id, self.id, companionTemplate)
			emitter:emit("setLobbyCompanionTemplate", companionTemplate, self.id)
		end,

		setGreeting = function (self, greeting)
			self.greeting = greeting
			logger:log(6, "GUILD %s LOBBY %s: updated greeting to %s", self.guild.id, self.id, greeting)
			emitter:emit("setLobbyGreeting", greeting, self.id)
		end,

		setCompanionLog = function (self, companionLog)
			self.companionLog = companionLog
			logger:log(6, "GUILD %s LOBBY %s: updated companion log channel to %s", self.guild.id, self.id, companionLog)
			emitter:emit("setLobbyCompanionLog", companionLog, self.id)
		end,

		-- shortcut, returns filled position
		attachChild = function (self, channelID, position)
			return self.children:fill(channelID, position)
		end,

		detachChild = function (self, position)
			self.children:drain(position)
		end
	},
	__tostring = function (self) return string.format("LobbyData: %s", self.id) end
}

local channelMeta = {
	__index = {
		delete = function (self)
			if channels[self.id] then
				if self.parent.detachChild then self.parent:detachChild(self.position) end
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
		end
	},
	__tostring = function (self) return string.format("ChannelData: %s", self.id) end
}

-- global data handlers
setmetatable(guilds, {
	__index = {
		add = function (self, guildID, role, limit, permissions)
			self[guildID] = setmetatable({
				id = guildID,
				role = role,
				limit = tonumber(limit) or 500,
				permissions = botPermissions(tonumber(permissions) or 0),
				lobbies = set()}, guildMeta)
			logger:log(6, "GUILD %s: added", guildID)
			return self[guildID]
		end,

		store = function (self, guildID)
			emitter:emit("addGuild", guildID)
			return self:add(guildID)
		end,

		cleanup = function (self)
			for guildID, _ in pairs(self) do
				if not client:getGuild(guildID) then
					emitter:emit("removeGuild", guildID)
				end
			end
		end
	},
	__tostring = function () return "GuildStorage" end
})

setmetatable(lobbies, {
	__index = {
		add = function (self, lobbyID, guildID, isMatchmaking, template, companionTemplate, target, companionTarget, role, permissions, capacity, bitrate, greeting, companionLog)
			self[lobbyID] = setmetatable({id = lobbyID, guild = guilds[guildID],
				isMatchmaking = tonumber(isMatchmaking) == 1, role = role, permissions = botPermissions(tonumber(permissions) or 0),
				template = template, target = target, capacity = tonumber(capacity), bitrate = tonumber(bitrate),
				companionTemplate = companionTemplate, companionTarget = companionTarget == "true" or companionTarget,
				greeting = greeting, companionLog = companionLog,
				children = hollowArray(), mutex = discordia.Mutex()
			}, lobbyMeta)
			logger:log(6, "GUILD %s LOBBY %s: added", guildID, lobbyID)
			return self[lobbyID]
		end,

		store = function (self, lobby)
			emitter:emit("addLobby", lobby.id, lobby.guild.id)
			return self:add(lobby.id, lobby.guild.id)
		end,

		cleanup = function (self)
			for lobbyID, lobbyData in pairs(self) do
				if not (client:getChannel(lobbyID) or client:getGuild(lobbyData.guild.id).unavailable) then
					emitter:emit("removeLobby", lobbyID)
				end
			end
		end
	},
	__len = function (self)
		local count = 0
		for _,_ in pairs(self) do count = count + 1 end
		return count
	end,
	__tostring = function () return "LobbyStorage" end
})

local parents = {[0] = lobbies, guilds, categories, channels}

setmetatable(channels, {
	__index = {
		add = function (self, channelID, parentType, host, parentID, position, companion)
			local parent = parents[tonumber(parentType)][parentID]
			self[channelID] = setmetatable({
				id = channelID, guildID = parent.guild and parent.guild.id or parent.id, parentType = tonumber(parentType),
				host = host, parent = parent, position = tonumber(position), companion = companion
			}, channelMeta)
			logger:log(6, "GUILD %s ROOM %s: added", self[channelID].guildID, channelID)
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
						if channelData.isPersistent then
							channelData:delete()
						else
							channel:delete()
						end
					end
				elseif not client:getGuild(channelData.guildID).unavailable then
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

-- some actual db interaction
local sql = require "sqlite3"
local guildDB = sql.open("guildsData.db")
local lobbyDB = sql.open("lobbiesData.db")
--local categoryDB = sql.open("categoryData.db")
local channelDB = sql.open("channelsData.db")

local mutexes = {}
local pcallFunc = function (statement, ...) statement:reset():bind(...):step() end

-- all statements come through this logic
local function interaction (statement, logMsg)
	-- setup
	-- prepare log messages
	local success, failure = logMsg..": completed", logMsg..": failed"

	-- create mutex for statement
	mutexes[statement] = Mutex()

	-- the actual logic
	return function (...)
		mutexes[statement]:lock()
		local ok, msg = xpcall(pcallFunc, debug.traceback, statement, ...)
		mutexes[statement]:unlock()

		if ok then
			logger:log(5, success, ...)
		else
			logger:log(2, "%s: %s", string.format(failure, ...), msg)
			if config.stderr then
				client:getChannel(config.stderr):sendf("%s: %s", string.format(failure, ...), msg)
			end
		end
	end
end

-- all statements that are gonna be used to interact with db
-- naming convention is <action><scope>[key]
-- second value is logger message
local guildFields, lobbyFields, channelFields = 4, 13, 6
local storageStatements = {
	addGuild = {"INSERT INTO guilds VALUES(?, NULL, 500, 0)", "ADD GUILD %s"},

	removeGuild = {"DELETE FROM guilds WHERE id = ?", "DELETE GUILD %s"},

	setGuildRole = {"UPDATE guilds SET role = ? WHERE id = ?", "SET ROLE %s => GUILD %s"},

	setGuildLimit = {"UPDATE guilds SET cLimit = ? WHERE id = ?", "SET LIMIT %s => GUILD %s"},

	setGuildPermissions = {"UPDATE guilds SET permissions = ? WHERE id = ?", "SET PERMISSIONS %s => GUILD %s"},

	addLobby = {"INSERT INTO lobbies VALUES(?,?,FALSE,NULL,NULL,NULL,NULL,NULL,0,NULL,NULL,NULL,NULL)", "ADD LOBBY %s"},

	removeLobby = {"DELETE FROM lobbies WHERE id = ?", "DELETE LOBBY %s"},

	setLobbyMatchmaking = {"UPDATE lobbies SET isMatchmaking = ? WHERE id = ?","SET MATCHMAKING %s => LOBBY %s"},

	setLobbyRole = {"UPDATE lobbies SET role = ? WHERE id = ?","SET ROLE %s => LOBBY %s"},

	setLobbyPermissions = {"UPDATE lobbies SET permissions = ? WHERE id = ?","SET PERMISSIONS %s => LOBBY %s"},

	setLobbyTemplate = {"UPDATE lobbies SET template = ? WHERE id = ?","SET TEMPLATE %s => LOBBY %s"},

	setLobbyTarget = {"UPDATE lobbies SET target = ? WHERE id = ?","SET TARGET %s => LOBBY %s"},

	setLobbyCapacity = {"UPDATE lobbies SET capacity = ? WHERE id = ?","SET CAPACITY %s => LOBBY %s"},

	setLobbyBitrate = {"UPDATE lobbies SET bitrate = ? WHERE id = ?","SET BITRATE %s => LOBBY %s"},

	setLobbyCompanionTemplate = {"UPDATE lobbies SET companionTemplate = ? WHERE id = ?","SET COMPANION TEMPLATE %s => LOBBY %s"},

	setLobbyCompanionTarget = {"UPDATE lobbies SET companionTarget = ? WHERE id = ?","SET COMPANION TARGET %s => LOBBY %s"},

	setLobbyGreeting = {"UPDATE lobbies SET greeting = ? WHERE id = ?","SET GREETING %s => LOBBY %s"},

	setLobbyCompanionLog = {"UPDATE lobbies SET companionLog = ? WHERE id = ?","SET COMPANION LOG %s => LOBBY %s"},

	addChannel = {"INSERT INTO channels VALUES(?,?,?,?,?,?)", "ADD CHANNEL %s"},

	removeChannel = {"DELETE FROM channels WHERE id = ?", "DELETE CHANNEL %s"},

	setChannelHost = {"UPDATE channels SET host = ? WHERE id = ?", "SET HOST %s => CHANNEL %s"}
}

-- tie up callbacks
for name, statement in pairs(storageStatements) do
	if name:match("Guild") then
		emitter:on(name, interaction(guildDB:prepare(statement[1]), statement[2]))
	elseif name:match("Lobby") then
		emitter:on(name, interaction(lobbyDB:prepare(statement[1]), statement[2]))
	--elseif name:match("Category") then
		--emitter:on(name, interaction(categoryDB:prepare(statement[1]), statement[2]))
	elseif name:match("Channel") then
		emitter:on(name, interaction(channelDB:prepare(statement[1]), statement[2]))
	end
end

local getGuild = guildDB:prepare("SELECT * FROM guilds WHERE id = ?")
local getLobbies = lobbyDB:prepare("SELECT * FROM lobbies WHERE guild = ?")
local getChannels = channelDB:prepare("SELECT * FROM channels WHERE parent = ? AND parentType = ?")

-- helper loader method
local loadChannels = function (parent, parentType)
	local rawChannel = getChannels:reset():bind(parent.id, parentType):step()

	if rawChannel then
		repeat
			local channel, companion = client:getChannel(rawChannel[1]), client:getChannel(rawChannel[6])
			if channel then
				if #channel.connectedMembers > 0 then
					local channelData = channels:add(unpack(rawChannel, 1, channelFields))

					if parentType == 0 then parent:attachChild(channelData, tonumber(channelData.position)) end
					if companion and parent.companionLog then
						Overseer.resume(companion)
					end
				else
					if parentType == 0 then
						channel:delete()
					end

					if companion then companion:delete() end
					emitter:emit("removeChannel", rawChannel[1])
				end
			else
				if companion then companion:delete() end
				emitter:emit("removeChannel", rawChannel[1])
			end
			rawChannel = getChannels:step()
		until not rawChannel
	end
end

-- main loader method that's used on bot startup
local loadGuild = function (guild)
	local rawGuild, guildData = getGuild:reset():bind(guild.id):step()

	if rawGuild then
		guildData = guilds:add(unpack(rawGuild, 1, guildFields))
	else
		guildData = guilds:store(guild.id)
	end

	loadChannels(guildData, 1)

	local rawLobby = getLobbies:reset():bind(guild.id):step()

	if rawLobby then
		repeat
			if client:getChannel(rawLobby[1]) then
				local lobbyData = lobbies:add(unpack(rawLobby, 1, lobbyFields))
				guildData.lobbies:add(lobbyData)

				loadChannels(lobbyData, 0)
			else
				emitter:emit("removeLobby", rawLobby[1])
			end
			rawLobby = getLobbies:step()
		until not rawLobby
	end
end


return {
	guilds = guilds,
	lobbies = lobbies,
	channels = channels,
	loadGuild = loadGuild,
	stats = {
		lobbies = 0,
		channels = 0,
		users = 0
	}
}