local discordia = require "discordia"
local emitter = discordia.Emitter()
local client, logger = discordia.storage.client, discordia.storage.logger
local sqlite = require "sqlite3".open("lobbiesData.db")
local storageInteractionEvent = require "./utils.lua".storageInteractionEvent

local channels = require "./channels.lua"

local add, remove, updateTemplate =
	sqlite:prepare("INSERT INTO lobbies VALUES(?,NULL)"),
	sqlite:prepare("DELETE FROM lobbies WHERE id = ?"),
	sqlite:prepare("UPDATE lobbies SET template = ? WHERE id = ?")

emitter:on("add", function (lobbyID)
	pcall(storageInteractionEvent, add, lobbyID)
end)

emitter:on("remove", function (lobbyID)
	pcall(storageInteractionEvent, remove, lobbyID)
end)

emitter:on("updateTemplate", function (lobbyID, template)
	pcall(storageInteractionEvent, add, template, lobbyID)
end)

return setmetatable({}, {
	__index = {
		add = function (self, lobbyID, template)	-- additional parameter are used upon startup to prevent unnecessary checks
			if channels[lobbyID] then channels:remove(lobbyID) end	-- I swear to god, there will be one crackhead
			
			if not self[lobbyID] then 
				self[lobbyID] = {template = template}
				local channel = client:getChannel(lobbyID)
				logger:log(4, "GUILD %s: Added lobby %s", channel.guild.id, lobbyID)
			end
			emitter:emit("add", lobbyID)
		end,
		
		remove = function (self, lobby)
			if self[lobby.id] then
				self[lobby.id] = nil
				logger:log(4, "GUILD %s: Deleted lobby %s", lobby.guild.id, lobby.id)
			end
			emitter:emit("remove", lobbyID)
		end,
		
		load = function (self)
			logger:log(4, "STARTUP: Loading lobbies")
			local lobbyIDs = sqlite:exec("SELECT * FROM lobbies")
			if lobbyIDs then
				for i, lobbyID in ipairs(lobbyIDs[1]) do
					if client:getChannel(lobbyID) then 
						self:add(lobbyID, lobbyIDs.template[i])
					else
						self:remove(lobbyID)
					end
				end
			end
			logger:log(4, "STARTUP: Loaded!")
		end,
		
		updateTemplate = function (self, lobbyID, template)
			self[lobbyID].template = template
			local channel = client:getChannel(lobbyID)
			logger:log(4, "GUILD %s: Updated template for lobby %s", channel.guild.id, lobbyID)
			emitter:emit("updateTemplate", lobbyID, template)
		end,
		
		inGuild = function (self, guildID)
			local count = 0
			for v,_ in pairs(self) do if client:getChannel(v).guild.id == guildID then count = count + 1 end end
			return count
		end
	},
	__len = function (self)
		local count = 0
		for v,_ in pairs(self) do count = count + 1 end
		return count
	end
})