local channels = require "./channels.lua"
local discordia = require "discordia"
local mutex = discordia.Mutex()
local client, logger = discordia.storage.client, discordia.storage.logger
local sqlite = require "sqlite3".open("lobbiesData.db")

local selectID, insert, delete, selectTemplate, updateTemplate = 
	sqlite:prepare("SELECT * FROM lobbies WHERE id = ?"),
	sqlite:prepare("INSERT INTO lobbies VALUES(?,NULL)"),
	sqlite:prepare("DELETE FROM lobbies WHERE id = ?"),
	sqlite:prepare("SELECT * FROM lobbies WHERE template = ? AND id = ?"),
	sqlite:prepare("UPDATE lobbies SET template = ? WHERE id = ?")

return setmetatable({}, {
	__index = {
		add = function (self, lobbyID, template)	-- additional parameter are used upon startup to prevent unnecessary checks
			mutex:lock()
			if channels[lobbyID] then channels:remove(lobbyID) end	-- I swear to god, there will be one crackhead
			
			if not self[lobbyID] then 
				self[lobbyID] = {template = template}
				logger:log(4, "MEMORY: Added lobby "..lobbyID)
			end
			if not selectID:reset():bind(lobbyID):step() then
				insert:reset():bind(lobbyID):step()
				logger:log(4, "DATABASE: Added lobby "..lobbyID)
			end
			mutex:unlock()
		end,
		
		remove = function (self, lobbyID)
			mutex:lock()
			if self[lobbyID] then
				self[lobbyID] = nil
				logger:log(4, "MEMORY: Deleted lobby "..lobbyID)
			end
			if selectID:reset():bind(lobbyID):step() then
				delete:reset():bind(lobbyID):step()
				logger:log(4, "DATABASE: Deleted lobby "..lobbyID)
			end
			mutex:unlock()
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
			mutex:lock()
			if self[lobbyID].template ~= template then
				self[lobbyID].template = template
				logger:log(4, "MEMORY: Updated template for lobby "..lobbyID)
			end
			if not selectTemplate:reset():bind(template, lobbyID):step() then
				updateTemplate:reset():bind(template, lobbyID):step()
				logger:log(4, "DATABASE: Updated template for lobby "..lobbyID)
			end
			mutex:unlock()
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