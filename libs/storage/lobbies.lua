-- object to store data about lobbies and interact with corresponding db
--[[
CREATE TABLE lobbies(
	id VARCHAR PRIMARY KEY,
	isMatchmaking BOOL	/* mutable, default FALSE */
	template VARCHAR,	/* mutable, default NULL */
	companionTemplate VARCHAR,	/* mutable, default NULL */
	target VARCHAR,	/* mutable, default NULL */
	companionTarget VARCHAR,	/* mutable, default NULL */
	role VARCHAR,	/* mutable, default NULL */
	permissions INTEGER NOT NULL,	/* mutable, default 0 */
	capacity INTEGER	/* mutable, default NULL */
)]]

local lobbiesData = require "sqlite3".open("lobbiesData.db")

local client = require "client"
local logger = require "logger"

local guilds = require "storage/guilds"

local storageInteraction = require "funcs/storageInteraction"
local hollowArray = require "utils/hollowArray"
local botPermissions = require "utils/botPermissions"

-- used to start storageInteractionEvent as async process
-- because fuck data preservation, we need dat speed
local discordia = require "discordia"
local emitter = discordia.Emitter()

local storageStatements = {
	add = {
		"INSERT INTO lobbies VALUES(?,FALSE,NULL,NULL,NULL,NULL,NULL,0,NULL)",
		"Added lobby %s", "Couldn't add lobby %s"
	},
	
	remove = {
		"DELETE FROM lobbies WHERE id = ?",
		"Removed lobby %s", "Couldn't remove lobby %s"
	},
	
	setMatchmaking = {
		"UPDATE lobbies SET isMatchmaking = ? WHERE id = ?",
		"Updated matchmaking status to %s for lobby %s", "Couldn't update matchmaking status to %s for lobby %s"
	},
	
	setTemplate = {
		"UPDATE lobbies SET template = ? WHERE id = ?",
		"Updated template to %s for lobby %s", "Couldn't update template to %s for lobby %s"
	},
	
	setCompanionTemplate = {
		"UPDATE lobbies SET companionTemplate = ? WHERE id = ?",
		"Updated companion template to %s for lobby %s", "Couldn't update companionTemplate to %s for lobby %s"
	},
	
	setTarget = {
		"UPDATE lobbies SET target = ? WHERE id = ?",
		"Updated target to %s for lobby %s", "Couldn't update target to %s for lobby %s"
	},
	
	setCompanionTarget = {
		"UPDATE lobbies SET companionTarget = ? WHERE id = ?",
		"Updated companion target to %s for lobby %s", "Couldn't update companion target to %s for lobby %s"
	},
	
	setRole = {
		"UPDATE lobbies SET role = ? WHERE id = ?",
		"Updated managed role to %s for lobby %s", "Couldn't update managed role to %s for lobby %s"
	},
	
	setPermissions = {
		"UPDATE lobbies SET permissions = ? WHERE id = ?",
		"Updated permissions to %s for lobby %s", "Couldn't update permissions to %s for lobby %s"
	},
	
	setCapacity = {
		"UPDATE lobbies SET capacity = ? WHERE id = ?",
		"Updated capacity to %s for lobby %s", "Couldn't update capacity to %s for lobby %s"
	}
}

for name, statement in pairs(storageStatements) do
	emitter:on(name, storageInteraction(lobbiesData:prepare(statement[1]), statement[2], statement[3]))
end

local lobbies = {}
local lobbyMethods = {
	delete = function (self)
		if lobbies[self.id] then
			for _, childData in pairs(lobbies[self.id].children) do
				childData.parent = true	-- you still have to die, kiddo
			end
			
			lobbies[self.id] = nil
			local lobby = client:getChannel(self.id)
			if lobby and guilds[self.guildID] then
				guilds[self.guildID].lobbies:remove(self)
				logger:log(4, "GUILD %s: Removed lobby %s", self.guildID, self.id)
			end
		end
		emitter:emit("remove", self.id)
	end,
	
	setMatchmaking = function (self, isMatchmaking)
		self.isMatchmaking = isMatchmaking
		logger:log(4, "GUILD %s: Updated matchmaking status for lobby %s to %s", self.guildID, self.id, isMatchmaking)
		emitter:emit("setMatchmaking", isMatchmaking and 1 or 0, self.id)
	end,
	
	setTemplate = function (self, template)
		self.template = template
		logger:log(4, "GUILD %s: Updated template for lobby %s to %s", self.guildID, self.id, template)
		emitter:emit("setTemplate", template, self.id)
	end,
	
	setCompanionTemplate = function (self, companionTemplate)
		self.companionTemplate = companionTemplate
		logger:log(4, "GUILD %s: Updated companion template for lobby %s to %s", self.guildID, self.id, companionTemplate)
		emitter:emit("setCompanionTemplate", companionTemplate == true and "true" or companionTemplate, self.id)
	end,
	
	setTarget = function (self, target)
		self.target = target
		logger:log(4, "GUILD %s: Updated target for lobby %s to %s", self.guildID, self.id, target)
		emitter:emit("setTarget", target, self.id)
	end,

	setCompanionTarget = function (self, companionTarget)
		self.companionTarget = companionTarget
		logger:log(4, "GUILD %s: Updated companion target for lobby %s to %s", self.guildID, self.id, companionTarget)
		emitter:emit("setCompanionTarget", tostring(companionTarget), self.id)
	end,
	
	setRole = function (self, role)
		self.role = role
		logger:log(4, "GUILD %s: Updated managed role for lobby %s to %s", self.guildID, self.id, role)
		emitter:emit("setRole", role, self.id)
	end,
	
	setPermissions = function (self, permissions)
		self.permissions = permissions
		logger:log(4, "GUILD %s: Updated permissions for lobby %s to %s", self.guildID, self.id, permissions)
		emitter:emit("setPermissions", permissions.bitfield.value, self.id)
	end,
	
	setCapacity = function (self, capacity)
		self.capacity = capacity
		logger:log(4, "GUILD %s: Updated capacity for lobby %s to %s", self.guildID, self.id, capacity)
		emitter:emit("setCapacity", capacity, self.id)
	end,
	
	-- returns filled position
	attachChild = function (self, channelID, position)
		return self.children:fill(channelID, position)
	end,
	
	detachChild = function (self, position)
		self.children:drain(position)
	end
}

local nonSetters = {delete = true, attachChild = true, detachChild = true}
local lobbyMT = {
	__index = function (self, index)
		if nonSetters[index] or (client:getChannel(self.id) and lobbies[self.id]) then
			return lobbyMethods[index]
		else
			self:delete()
		end
	end,
	__tostring = function (self) return string.format("LobbyData: %s", self.id) end
}

local lobbiesIndex = {
	-- perform checks and add lobby to table
	-- additional parameter are used upon startup to prevent unnecessary checks
	loadAdd = function (self, lobbyID, isMatchmaking, template, companionTemplate, target, companionTarget, role, permissions, capacity)
		if not self[lobbyID] then
			local lobby = client:getChannel(lobbyID)
			if lobby and lobby.guild then
				self[lobbyID] = setmetatable({
					id = lobbyID, guildID = lobby.guild.id, isMatchmaking = isMatchmaking,
					template = template, companionTemplate = companionTemplate,
					target = target, companionTarget = companionTarget,
					role = role, permissions = botPermissions(permissions or 0), capacity = capacity,
					children = hollowArray(), mutex = discordia.Mutex()
				}, lobbyMT)
				guilds[lobby.guild.id].lobbies:add(self[lobbyID])
				logger:log(4, "GUILD %s: Added lobby %s", lobby.guild.id, lobbyID)
			end
		end
	end,
	
	-- loadAdd and start interaction with db
	add = function (self, lobbyID)
		self:loadAdd(lobbyID)
		if self[lobbyID] then
			emitter:emit("add", lobbyID)
			return self[lobbyID]
		end
	end,
	
	load = function (self)
		logger:log(4, "STARTUP: Loading lobbies")
		local lobbyIDs = lobbiesData:exec("SELECT * FROM lobbies")
		if lobbyIDs then
			for i, lobbyID in ipairs(lobbyIDs.id) do
				local lobby = client:getChannel(lobbyID)
				if lobby then
					self:loadAdd(lobbyID, lobbyIDs.isMatchmaking[i] == 1,
						lobbyIDs.template[i], lobbyIDs.companionTemplate[i],
						lobbyIDs.target[i], lobbyIDs.companionTarget[i] == "true" and true or lobbyIDs.companionTarget[i],
						lobbyIDs.role[i],
						tonumber(lobbyIDs.permissions[i]), tonumber(lobbyIDs.capacity[i]))
					guilds[lobby.guild.id].lobbies:add(self[lobbyID])
				else
					emitter:emit("remove", lobbyID)
				end
			end
		end
		
		logger:log(4, "STARTUP: Loaded!")
	end
}

return setmetatable(lobbies, {
	__index = lobbiesIndex,
	__len = function (self)
		local count = 0
		for v,_ in pairs(self) do count = count + 1 end
		return count
	end,
	__call = lobbiesIndex.add
})