local channels = require "./channels.lua"
local discordia = require "discordia"
local client, logger = discordia.storage.client, discordia.storage.logger
local sqlite = require "sqlite3".open("lobbiesData.db")

return setmetatable({}, {
	__index = {
		add = function (self, lobbyID, template)
			if channels[lobbyID] then channels:remove(lobbyID) end	-- I swear to god, there will be one crackhead
			
			if not self[lobbyID] then 
				self[lobbyID] = {template = template}
				logger:log(4, "MEMORY: Added lobby "..lobbyID)
			end
			if not sqlite:exec("SELECT * FROM lobbies WHERE id = "..lobbyID) then
				local res = pcall(function() sqlite:exec("INSERT INTO lobbies VALUES("..lobbyID..", NULL)") end)
				if res then logger:log(4, "DATABASE: Added lobby "..lobbyID) end
			end
		end,
		
		remove = function (self, lobbyID)
			if self[lobbyID] then
				self[lobbyID] = nil
				logger:log(4, "MEMORY: Deleted lobby "..lobbyID)
			end
			if sqlite:exec("SELECT * FROM lobbies WHERE id = "..lobbyID) then
				local res = pcall(function() sqlite:exec("DELETE FROM lobbies WHERE id = "..lobbyID) end)
				if res then logger:log(4, "DATABASE: Deleted lobby "..lobbyID) end
			end
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
			if template then
				if self[lobbyID].template ~= template then
					self[lobbyID].template = template
					logger:log(4, "MEMORY: Updated template for lobby "..lobbyID)
				end
				if not sqlite:prepare("SELECT * FROM lobbies WHERE template = ? AND id = ?"):bind(template, lobbyID):step() then
					sqlite:prepare("UPDATE lobbies SET template = ? WHERE id = ?"):bind(template, lobbyID):step()	-- don't even think about it
					logger:log(4, "DATABASE: Updated template for lobby "..lobbyID)
				end
			end
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