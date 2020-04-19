local channels = require "./channels.lua"
local discordia = require "discordia"
local client, sqlite, logger = discordia.storage.client, discordia.storage.sqlite, discordia.storage.logger

return setmetatable({}, {
	__index = {
		add = function (self, lobbyID)
			if channels[lobbyID] then channels:remove(lobbyID) end	-- I swear to god, there will be one crackhead
			
			if not self[lobbyID] then 
				self[lobbyID] = true
				logger:log(4, "MEMORY: Added lobby "..lobbyID)
			end
			if not sqlite:exec("SELECT * FROM lobbies WHERE id = "..lobbyID) then
				local res = pcall(function() sqlite:exec("INSERT INTO lobbies VALUES("..lobbyID..")") end)
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
			logger:log(4, "Loading lobbies")
			local lobbyIDs = sqlite:exec("SELECT * FROM lobbies")
			if lobbyIDs then
				for _, lobbyID in ipairs(lobbyIDs[1]) do
					if client:getChannel(lobbyID) then 
						self:add(lobbyID)
					else
						self:remove(lobbyID)
					end
				end
			end
			logger:log(4, "Loaded!")
		end
	},
	__len = function (self)
		local count = 0
		for v,_ in pairs(self) do count = count + 1 end
		return count
	end
})