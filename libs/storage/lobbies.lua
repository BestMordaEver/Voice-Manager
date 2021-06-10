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
	capacity INTEGER,	/* mutable, default NULL */
	bitrate INTEGER,	/* mutable, default NULL */
	greeting VARCHAR,	/* mutable, default NULL */
	companionLog VARCHAR	/* mutable, default NULL */
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
	add = {"INSERT INTO lobbies VALUES(?,FALSE,NULL,NULL,NULL,NULL,NULL,0,NULL,NULL,NULL,NULL)", "ADD LOBBY %s"},
	
	remove = {"DELETE FROM lobbies WHERE id = ?", "DELETE LOBBY %s"},
	
	setMatchmaking = {"UPDATE lobbies SET isMatchmaking = ? WHERE id = ?","SET MATCHMAKING %s => LOBBY %s"},
	
	setRole = {"UPDATE lobbies SET role = ? WHERE id = ?","SET ROLE %s => LOBBY %s"},
	
	setPermissions = {"UPDATE lobbies SET permissions = ? WHERE id = ?","SET PERMISSIONS %s => LOBBY %s"},
	
	setTemplate = {"UPDATE lobbies SET template = ? WHERE id = ?","SET TEMPLATE %s => LOBBY %s"},
	
	setTarget = {"UPDATE lobbies SET target = ? WHERE id = ?","SET TARGET %s => LOBBY %s"},
	
	setCapacity = {"UPDATE lobbies SET capacity = ? WHERE id = ?","SET CAPACITY %s => LOBBY %s"},
	
	setBitrate = {"UPDATE lobbies SET bitrate = ? WHERE id = ?","SET BITRATE %s => LOBBY %s"},
	
	setCompanionTemplate = {"UPDATE lobbies SET companionTemplate = ? WHERE id = ?","SET COMPANION TEMPLATE %s => LOBBY %s"},
	
	setCompanionTarget = {"UPDATE lobbies SET companionTarget = ? WHERE id = ?","SET COMPANION TARGET %s => LOBBY %s"},
	
	setGreeting = {"UPDATE lobbies SET greeting = ? WHERE id = ?","SET GREETING %s => LOBBY %s"},
	
	setCompanionLog = {"UPDATE lobbies SET companionLog = ? WHERE id = ?","SET COMPANION LOG %s => LOBBY %s"},
}

for name, statement in pairs(storageStatements) do
	emitter:on(name, storageInteraction(lobbiesData:prepare(statement[1]), statement[2]))
end

local lobbies = {}
local lobbyMethods = {
	delete = function (self)
		if lobbies[self.id] then
			lobbies[self.id] = nil
			local lobby = client:getChannel(self.id)
			if lobby and guilds[self.guildID] then
				guilds[self.guildID].lobbies:remove(self)
				logger:log(6, "GUILD %s LOBBY %s: deleted", self.guildID, self.id)
			end
		end
		emitter:emit("remove", self.id)
	end,
	
	setMatchmaking = function (self, isMatchmaking)
		self.isMatchmaking = isMatchmaking
		logger:log(6, "GUILD %s LOBBY %s: updated matchmaking status to %s", self.guildID, self.id, isMatchmaking)
		emitter:emit("setMatchmaking", isMatchmaking and 1 or 0, self.id)
	end,
	
	setRole = function (self, role)
		self.role = role
		logger:log(6, "GUILD %s LOBBY %s: updated managed role to %s", self.guildID, self.id, role)
		emitter:emit("setRole", role, self.id)
	end,
	
	setPermissions = function (self, permissions)
		self.permissions = permissions
		logger:log(6, "GUILD %s LOBBY %s: udated permissions to %s", self.guildID, self.id, permissions)
		emitter:emit("setPermissions", permissions.bitfield.value, self.id)
	end,
	
	setTemplate = function (self, template)
		self.template = template
		logger:log(6, "GUILD %s LOBBY %s: updated template to %s", self.guildID, self.id, template)
		emitter:emit("setTemplate", template, self.id)
	end,
	
	setTarget = function (self, target)
		self.target = target
		logger:log(6, "GUILD %s LOBBY %s: updated target to %s", self.guildID, self.id, target)
		emitter:emit("setTarget", target, self.id)
	end,
	
	setCapacity = function (self, capacity)
		self.capacity = capacity
		logger:log(6, "GUILD %s LOBBY %s: updated capacity to %s", self.guildID, self.id, capacity)
		emitter:emit("setCapacity", capacity, self.id)
	end,
	
	setBitrate = function (self, bitrate)
		self.bitrate = bitrate
		logger:log(6, "GUILD %s LOBBY %s: updated bitrate to %s", self.guildID, self.id, bitrate)
		emitter:emit("setBitrate", bitrate, self.id)
	end,

	setCompanionTarget = function (self, companionTarget)
		self.companionTarget = companionTarget
		logger:log(6, "GUILD %s LOBBY %s: updated companion target to %s", self.guildID, self.id, companionTarget)
		emitter:emit("setCompanionTarget", tostring(companionTarget), self.id)
	end,
	
	setCompanionTemplate = function (self, companionTemplate)
		self.companionTemplate = companionTemplate
		logger:log(6, "GUILD %s LOBBY %s: updated companion template to %s", self.guildID, self.id, companionTemplate)
		emitter:emit("setCompanionTemplate", companionTemplate, self.id)
	end,
	
	setGreeting = function (self, greeting)
		self.greeting = greeting
		logger:log(6, "GUILD %s LOBBY %s: updated greeting to %s", self.guildID, self.id, greeting)
		emitter:emit("setGreeting", greeting, self.id)
	end,
	
	setCompanionLog = function (self, companionLog)
		self.companionLog = companionLog
		logger:log(6, "GUILD %s LOBBY %s: updated companion log channel to %s", self.guildID, self.id, companionLog)
		emitter:emit("setCompanionLog", companionLog, self.id)
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
	loadAdd = function (self, data)
		if not self[data.id] then
			local lobby = client:getChannel(data.id)
			if lobby and lobby.guild then
				self[data.id] = setmetatable(data, lobbyMT)
				data.guildID = lobby.guild.id
				data.children = hollowArray()
				data.mutex = discordia.Mutex()
				guilds[lobby.guild.id].lobbies:add(self[data.id])
				logger:log(6, "GUILD %s LOBBY %s: added", lobby.guild.id, data.id)
			end
		end
	end,
	
	-- loadAdd and start interaction with db
	add = function (self, lobbyID)
		self:loadAdd({id = lobbyID, isMatchmaking = false, permissions = botPermissions(0)})
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
				self:loadAdd({id = lobbyID,
					isMatchmaking = lobbyIDs.isMatchmaking[i] == 1, role = lobbyIDs.role[i], permissions = botPermissions(tonumber(lobbyIDs.permissions[i]) or 0),
					template = lobbyIDs.template[i], capacity = tonumber(lobbyIDs.capacity[i]), bitrate = tonumber(lobbyIDs.bitrate[i]), target = lobbyIDs.target[i],
					companionTemplate = lobbyIDs.companionTemplate[i],
						companionTarget = lobbyIDs.companionTarget[i] == "true" and true or lobbyIDs.companionTarget[i],
						greeting = lobbyIDs.greeting[i],
						companionLog = lobbyIDs.companionLog[i]})

				local lobby = client:getChannel(lobbyID)
				if lobby then
					guilds[lobby.guild.id].lobbies:add(self[lobbyID])
				end
			end
		end
		
		logger:log(4, "STARTUP: Loaded!")
	end,
	
	cleanup = function (self)
		for lobbyID, lobbyData in pairs(self) do
			local lobby = client:getChannel(lobbyID)
			if lobby then
				guilds[lobby.guild.id].lobbies:add(self[lobbyID])
			else
				emitter:emit("remove", lobbyID)
			end
		end
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