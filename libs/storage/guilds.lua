-- object to store data about guilds and interact with corresponding db
--[[
CREATE TABLE guilds(
	id VARCHAR PRIMARY KEY,
	role VARCHAR,	/* mutable, default NULL */
	cLimit INTEGER NOT NULL,	/* mutable, default 500 */
	permissions INTEGER NOT NULL,	/* mutable, default 0 */
	prefix VARCHAR NOT NULL	/* mutable, default vm! */
)]]

local guildsData = require "sqlite3".open("guildsData.db")

local client = require "client"
local logger = require "logger"

local storageInteraction = require "funcs/storageInteraction"
local set = require "utils/set"
local botPermissions = require "utils/botPermissions"

-- used to start storageInteractionEvent as async process
-- because fuck data preservation, we need dat speed
local emitter = require "discordia".Emitter()

local storageStatements = {
	add = {"INSERT INTO guilds VALUES(?,NULL, 500, 0, 'vm!')", "ADD GUILD %s"},
	
	remove = {"DELETE FROM guilds WHERE id = ?", "DELETE GUILD %s"},
	
	setRole = {"UPDATE guilds SET role = ? WHERE id = ?", "SET ROLE %s => GUILD %s"},
	
	setLimit = {"UPDATE guilds SET cLimit = ? WHERE id = ?", "SET LIMIT %s => GUILD %s"},
	
	setPermissions = {"UPDATE guilds SET permissions = ? WHERE id = ?", "SET PERMISSIONS %s => GUILD %s"},
	
	setPrefix = {"UPDATE guilds SET prefix = ? WHERE id = ?", "SET PREFIX %s => GUILD %s"}
}

for name, statement in pairs(storageStatements) do
	emitter:on(name, storageInteraction(guildsData:prepare(statement[1]), statement[2]))
end

local guilds = {}
local guildMethods = {
	delete = function (self)
		if guilds[self.id] then
			guilds[self.id] = nil
			logger:log(4, "GUILD %s: deleted", self.id)
		end
		emitter:emit("remove", self.id)
	end,
	
	setRole = function (self, role)
		self.role = role
		logger:log(4, "GUILD %s: updated managed role to %d", self.id, role)
		emitter:emit("setRole", role, self.id)
	end,
	
	setLimit = function (self, limit)
		self.limit = limit
		logger:log(4, "GUILD %s: updated limit to %d", self.id, limit)
		emitter:emit("setLimit", limit, self.id)
	end,
	
	setPermissions = function (self, permissions)
		self.permissions = permissions
		logger:log(4, "GUILD %s: updated permissions to %d", self.id, permissions.bitfield.value)
		emitter:emit("setPermissions", permissions.bitfield.value, self.id)
	end,
	
	setPrefix = function (self, prefix)
		self.prefix = prefix
		logger:log(4, "GUILD %s: updated prefix to %s", self.id, prefix)
		emitter:emit("setPrefix", prefix, self.id)
	end
}

local guildMT = {
	__index = function (self, index)
		if index == "delete" or (client:getGuild(self.id) and guilds[self.id]) then
			return guildMethods[index]
		else
			self:delete()
		end
	end,
	__tostring = function (self) return string.format("GuildData: %s", self.id) end
}

local guildsIndex = {
	-- no safety needed, it's either loading time or new guild time, whoever spams invites can go to hell
	loadAdd = function (self, guildID, role, limit, permissions, prefix)
		self[guildID] = setmetatable({
			id = guildID,
			role = role,
			limit = limit or 500,
			permissions = botPermissions(permissions or 0),
			prefix = prefix or "vm!",
			lobbies = set()}, guildMT)
		logger:log(4, "GUILD %s: added", guildID)
	end,
	
	-- loadAdd and start interaction with db
	add = function (self, guildID)
		self:loadAdd(guildID)
		emitter:emit("add", guildID)
		return self[guildID]
	end,
	
	load = function (self)
		logger:log(4, "STARTUP: Loading guilds from save")
		local guildIDs = guildsData:exec("SELECT * FROM guilds")
		if guildIDs then
			for i, guildID in ipairs(guildIDs.id) do
				self:loadAdd(guildID, guildIDs.role[i], tonumber(guildIDs.cLimit[i]), tonumber(guildIDs.permissions[i]), guildIDs.prefix[i])
			end
		end
		
		logger:log(4, "STARTUP: Loading guilds from client")
		for _, guild in pairs(client.guilds) do
			if not self[guild.id] then self:add(guild.id) end
		end
		
		logger:log(4, "STARTUP: Loaded!")
	end,
	
	cleanup = function (self)
		for guildID, _ in pairs(self) do
			if not client:getChannel(guildID) then
				emitter:emit("remove", guildID)
			end
		end
	end
}

return setmetatable(guilds, {
	__index = guildsIndex,
	__call = guildsIndex.add
})
