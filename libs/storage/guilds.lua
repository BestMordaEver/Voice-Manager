local client = require "client"
local logger = require "logger"

local emitter = require "discordia".Emitter()
local storageCall = require "storage/storageCall"
local guildsDB = require "sqlite3".open("guildsData.db")

local storageStatements = {
	addGuild = {"INSERT INTO guilds(id) VALUES(?)", "ADD GUILD %s"},

	removeGuild = {"DELETE FROM guilds WHERE id = ?", "DELETE GUILD %s"},

	addGuildRole = {"INSERT INTO roles VALUES(?, ?)", "ADD ROLE %s => GUILD %s"},

	removeGuildRole = {"DELETE FROM roles WHERE id = ? and guildID = ?", "DELETE ROLE %s => GUILD %s"},

	removeGuildRoles = {"DELETE FROM roles WHERE guildID = ?", "DELETE ROLES GUILD %s"},

	setGuildLimit = {"UPDATE guilds SET cLimit = ? WHERE id = ?", "SET LIMIT %s => GUILD %s"},

	setGuildPermissions = {"UPDATE guilds SET permissions = ? WHERE id = ?", "SET PERMISSIONS %s => GUILD %s"}
}


for name, statement in pairs(storageStatements) do
	emitter:on(name, storageCall(guildsDB:prepare(statement[1]), statement[2]))
end

local set = require "utils/set"
local botPermissions = require "utils/botPermissions"

local guilds = {}
local guildMeta = {
	__index = {
		delete = function (self)
			if guilds[self.id] then
				guilds[self.id] = nil
				logger:log(6, "GUILD %s: deleted", self.id)
			end
			emitter:emit("removeGuildRoles", self.id)
			emitter:emit("removeGuild", self.id)
		end,

		addRole = function (self, roleID)
			self.roles:add(roleID)
			logger:log(6, "GUILD %s: added managed role %d", self.id, roleID)
			emitter:emit("addGuildRole", roleID, self.id)
		end,

		removeRole = function (self, roleID)
			self.roles:remove(roleID)
			logger:log(6, "GUILD %s: removed managed role %d", self.id, roleID)
			emitter:emit("removeGuildRole", roleID, self.id)
		end,

		removeRoles = function (self)
			self.roles = set()
			logger:log(6, "GUILD %s: removed all managed roles", self.id)
			emitter:emit("removeGuildRoles", self.id)
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

setmetatable(guilds, {
	__index = {
		loadGuildsStatement = guildsDB:prepare("SELECT id, cLimit, permissions FROM guilds"),
		loadRolesStatement = guildsDB:prepare("SELECT id, guildID FROM roles WHERE guildID = ?"),

		add = function (self, guildID, limit, permissions, roles)
			self[guildID] = setmetatable({
				id = guildID,
				roles = set(roles),
				limit = tonumber(limit) or 500,
				permissions = botPermissions(tonumber(permissions) or 0),
				lobbies = set()
			}, guildMeta)
			logger:log(6, "GUILD %s: added", guildID)
			return self[guildID]
		end,

		store = function (self, guildID)
			emitter:emit("addGuild", guildID)
			return self:add(guildID)
		end,

		cleanup = function (self)
			for guildID, guildData in pairs(self) do
				if not client:getGuild(guildID) then
					guildData:delete()
				end
			end
		end
	},
	__tostring = function () return "GuildStorage" end
})

return guilds, emitter