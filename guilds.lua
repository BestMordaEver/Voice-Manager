local discordia = require "discordia"
local client, sqlite, logger = discordia.storage.client, discordia.storage.sqlite, discordia.storage.logger
local locale = require "./locale"

return setmetatable({}, {
	__index = {
		add = function (self, guildID)
			if not self[guildID] then 
				self[guildID] = {locale = locale.english, prefix = "!vm"}
				logger:log(4, "MEMORY: Added guild "..guildID)
			end
			if not sqlite:exec("SELECT * FROM guilds WHERE id = "..guildID) then
				local res = pcall(function() sqlite:exec("INSERT INTO guilds VALUES("..guildID..", 'english', '!vm')") end)
				if res then logger:log(4, "DATABASE: Added guild "..guildID) end
			end
		end,
		
		remove = function (self, guildID)
			if self[guildID] then
				self[guildID] = nil
				logger:log(4, "MEMORY: Deleted guild "..guildID)
			end
			if sqlite:exec("SELECT * FROM guilds WHERE id = "..guildID) then
				local res = pcall(function() sqlite:exec("DELETE FROM guilds WHERE id = "..guildID) end)
				if res then logger:log(4, "DATABASE: Deleted guild "..guildID) end
			end
		end,
		
		load = function (self)
			logger:log(4, "Loading guilds from save")
			local guildIDs = sqlite:exec("SELECT * FROM guilds")
			if guildIDs then
				for i, guildID in ipairs(guildIDs[1]) do
					if client:getGuild(guildID) then
						self:add(guildID)
						self:updateLocale(guildID, guildIDs.locale[i])
						self:updatePrefix(guildID, guildIDs.prefix[i])
					else
						self:remove(guildID)
					end
				end
			end
			
			logger:log(4, "Loading guilds from client")
			for _, guild in pairs(client.guilds) do
				if not self[guild.id] then self:add(guild.id) end
			end
			
			logger:log(4, "Loaded!")
		end,
		
		updateLocale = function (self, guildID, localeName)
			if localeName then
				if self[guildID].locale ~= locale[localeName] then
					self[guildID].locale = locale[localeName]
					logger:log(4, "MEMORY: Updated locale for "..guildID)
				end
				if not sqlite:exec("SELECT * FROM guilds WHERE locale = '"..localeName.."' AND id = "..guildID) then
					sqlite:exec("UPDATE guilds SET locale = '"..localeName.."' WHERE id = "..guildID)
					logger:log(4, "DATABASE: Updated locale for "..guildID)
				end
			end
		end,
		
		updatePrefix = function (self, guildID, prefix)
			if prefix then
				if self[guildID].prefix ~= prefix then
					self[guildID].prefix = prefix
					logger:log(4, "MEMORY: Updated prefix for "..guildID)
				end
				if not sqlite:prepare("SELECT * FROM guilds WHERE prefix = ? AND id = ?"):bind(prefix, guildID):step() then
					sqlite:prepare("UPDATE guilds SET prefix = ? WHERE id = ?"):bind(prefix, guildID):step()	-- don't even think about it
					logger:log(4, "DATABASE: Updated prefix for "..guildID)
				end
			end
		end
	}
})
