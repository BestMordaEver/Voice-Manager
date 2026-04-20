local client = require "client"
local logger = require "logger"
local discordia = require "discordia"

local emitter = discordia.Emitter()
local storageCall = require "storage/storageCall"
local lobbiesDB = require "sqlite3".open("lobbiesData.db")

local storageStatements = {
	addLobby = {"INSERT INTO lobbies(id, guild) VALUES(?,?)", "ADD LOBBY %s"},

	removeLobby = {"DELETE FROM lobbies WHERE id = ?", "DELETE LOBBY %s"},

	setLobbyMatchmaking = {"UPDATE lobbies SET isMatchmaking = ? WHERE id = ?","SET MATCHMAKING %s => LOBBY %s"},

	addLobbyRole = {"INSERT INTO roles VALUES(?, ?)", "ADD ROLE %s => LOBBY %s"},

	removeLobbyRole = {"DELETE FROM roles WHERE id = ? and lobbyID = ?", "DELETE ROLE %s => LOBBY %s"},

	removeLobbyRoles = {"DELETE FROM roles WHERE lobbyID = ?", "DELETE ROLES => LOBBY %s"},

	setLobbyLimit = {"UPDATE lobbies SET cLimit = ? WHERE id = ?", "SET LIMIT %s => LOBBY %s"},

	setLobbyPermissions = {"UPDATE lobbies SET permissions = ? WHERE id = ?","SET PERMISSIONS %s => LOBBY %s"},

	setLobbyTemplate = {"UPDATE lobbies SET template = ? WHERE id = ?","SET TEMPLATE %s => LOBBY %s"},

	setLobbyTarget = {"UPDATE lobbies SET target = ? WHERE id = ?","SET TARGET %s => LOBBY %s"},

	setLobbyCapacity = {"UPDATE lobbies SET capacity = ? WHERE id = ?","SET CAPACITY %s => LOBBY %s"},

	setLobbyBitrate = {"UPDATE lobbies SET bitrate = ? WHERE id = ?","SET BITRATE %s => LOBBY %s"},

	setLobbyRegion = {"UPDATE lobbies SET region = ? WHERE id = ?","SET REGION %s => LOBBY %s"},

	setLobbyGaps = {"UPDATE lobbies SET gaps = ? WHERE id = ?","SET GAPS %s => LOBBY %s"},

	setLobbyPosition = {"UPDATE lobbies SET position = ? WHERE id = ?","SET POSITION %s => LOBBY %s"},

	setLobbyOrder = {"UPDATE lobbies SET cOrder = ? WHERE id = ?","SET ORDER %s => LOBBY %s"},

	setLobbyCompanionTemplate = {"UPDATE lobbies SET companionTemplate = ? WHERE id = ?","SET COMPANION TEMPLATE %s => LOBBY %s"},

	setLobbyCompanionTarget = {"UPDATE lobbies SET companionTarget = ? WHERE id = ?","SET COMPANION TARGET %s => LOBBY %s"},

	setLobbyGreeting = {"UPDATE lobbies SET greeting = ? WHERE id = ?","SET GREETING %s => LOBBY %s"},

	setLobbyCompanionLog = {"UPDATE lobbies SET companionLog = ? WHERE id = ?","SET COMPANION LOG %s => LOBBY %s"}
}


for name, statement in pairs(storageStatements) do
	emitter:on(name, storageCall(lobbiesDB:prepare(statement[1]), statement[2], lobbiesDB))
end

local set = require "utils/set"
local hollowArray = require "utils/hollowArray"
local botPermissions = require "utils/botPermissions"
local Mutex = discordia.Mutex

local lobbies = {n = 0}
local guilds = require "storage/guilds"

local lobbyMeta = {
	__index = {
		delete = function (self)
			if lobbies[self.id] then
				lobbies[self.id] = nil
				lobbies.n = lobbies.n - 1
				local lobby = client:getChannel(self.id)
				if lobby and self.guild then
					self.guild.lobbies:remove(self)
					logger:log(6, "GUILD %s LOBBY %s: deleted", self.guild.id, self.id)
				end
			end
			emitter:emit("removeLobbyRoles", self.id)
			emitter:emit("removeLobby", self.id)
		end,

		setMatchmaking = function (self, isMatchmaking)
			self.isMatchmaking = isMatchmaking
			logger:log(6, "GUILD %s LOBBY %s: updated matchmaking status to %s", self.guild.id, self.id, isMatchmaking)
			emitter:emit("setLobbyMatchmaking", isMatchmaking and 1 or 0, self.id)
		end,

		addRole = function (self, roleID)
			self.roles:add(roleID)
			logger:log(6, "GUILD %s LOBBY %s: added managed role %s", self.guild.id, self.id, roleID)
			emitter:emit("addLobbyRole", roleID, self.id)
		end,

		removeRole = function (self, roleID)
			self.roles:remove(roleID)
			logger:log(6, "GUILD %s LOBBY %s: removed managed role %s", self.guild.id, self.id, roleID)
			emitter:emit("removeLobbyRole", roleID, self.id)
		end,

		removeRoles = function (self)
			self.roles = set()
			logger:log(6, "GUILD %s LOBBY %s: removed all managed roles", self.guild.id, self.id)
			emitter:emit("removeLobbyRoles", self.id)
		end,

		setPermissions = function (self, permissions)
			self.permissions = permissions
			logger:log(6, "GUILD %s LOBBY %s: udated permissions to %s", self.guild.id, self.id, permissions)
			emitter:emit("setLobbyPermissions", permissions.bitfield.value, self.id)
		end,

		setGaps = function (self, gaps)
			self.gaps = gaps
			logger:log(6, "GUILD %s LOBBY %s: updated gaps to %s", self.guild.id, self.id, gaps)
			emitter:emit("setLobbyGaps", gaps and 1 or 0, self.id)
		end,

		setCompanionTarget = function (self, companionTarget)
			self.companionTarget = companionTarget
			logger:log(6, "GUILD %s LOBBY %s: updated companion target to %s", self.guild.id, self.id, companionTarget)
			emitter:emit("setLobbyCompanionTarget", tostring(companionTarget), self.id)
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

-- generate simple setters to avoid repetition
local simpleSetters = {
	{field = "limit",             event = "setLobbyLimit",             label = "limit"},
	{field = "template",          event = "setLobbyTemplate",          label = "template"},
	{field = "target",            event = "setLobbyTarget",            label = "target"},
	{field = "capacity",          event = "setLobbyCapacity",          label = "capacity"},
	{field = "bitrate",           event = "setLobbyBitrate",           label = "bitrate"},
	{field = "region",            event = "setLobbyRegion",            label = "region"},
	{field = "position",          event = "setLobbyPosition",          label = "position"},
	{field = "order",             event = "setLobbyOrder",             label = "order"},
	{field = "companionTemplate", event = "setLobbyCompanionTemplate", label = "companion template"},
	{field = "greeting",          event = "setLobbyGreeting",          label = "greeting"},
	{field = "companionLog",      event = "setLobbyCompanionLog",      label = "companion log channel"},
}

for _, s in ipairs(simpleSetters) do
	local methodName = "set" .. s.field:sub(1,1):upper() .. s.field:sub(2)
	lobbyMeta.__index[methodName] = function (self, value)
		self[s.field] = value
		logger:log(6, "GUILD %s LOBBY %s: updated %s to %s", self.guild.id, self.id, s.label, value)
		emitter:emit(s.event, value, self.id)
	end
end

setmetatable(lobbies, {
	__index = {
		loadLobbiesStatement = lobbiesDB:prepare([[SELECT
			id, guild, isMatchmaking,
			template, companionTemplate,
			target, companionTarget,
			cLimit, permissions, capacity, bitrate, region,
			gaps, position, cOrder,
			greeting, companionLog
		FROM lobbies]]),
		loadRolesStatement = lobbiesDB:prepare("SELECT id, lobbyID FROM roles WHERE lobbyID = ?"),

		add = function (self, lobbyID, guildID, isMatchmaking,
			template, companionTemplate, target, companionTarget,
			limit, permissions, capacity, bitrate, region,
			gaps, position, order,
			greeting, companionLog, roles)
			local lobby = setmetatable({
				id = lobbyID,
				guild = guilds[guildID],
				isMatchmaking = tonumber(isMatchmaking) == 1,
				roles = set(roles),
				limit = tonumber(limit) or 500,
				permissions = botPermissions(tonumber(permissions) or 0),
				template = template,
				target = target,
				capacity = tonumber(capacity),
				bitrate = tonumber(bitrate),
				region = region,
				gaps = tonumber(gaps) == 1,
				position = position or "bottom",
				order = order or "descending",
				companionTemplate = companionTemplate,
				companionTarget = companionTarget == "true" or companionTarget,
				greeting = greeting,
				companionLog = companionLog,
				children = hollowArray(),
				mutex = Mutex()
			}, lobbyMeta)

			if lobby.guild then lobby.guild.lobbies:add(lobby) end
			self[lobbyID] = lobby
			self.n = self.n + 1

			logger:log(6, "GUILD %s LOBBY %s: added", guildID, lobbyID)
			return lobby
		end,

		store = function (self, lobby)
			emitter:emit("addLobby", lobby.id, lobby.guild.id)
			return self:add(lobby.id, lobby.guild.id)
		end,

		cleanup = function (self)
			for lobbyID, lobbyData in pairs(self) do
				if not (client:getChannel(lobbyID) or client:getGuild(lobbyData.guild.id).unavailable) then
					lobbyData:delete()
				end
			end
		end
	},
	__pairs = function (self)
		return function (t, index)
			local k, v = next(t, index)
			while k == "n" do k, v = next(t, k) end
			return k, v
		end, self
	end,
	__len = function (self) return self.n end,
	__tostring = function () return "LobbyStorage" end
})

return lobbies, emitter