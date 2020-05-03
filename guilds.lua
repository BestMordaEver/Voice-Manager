local discordia = require "discordia"
local client, logger = discordia.storage.client, discordia.storage.logger
local sqlite = require "sqlite3".open("guildsData.db")

return setmetatable({}, {
	__index = {
		add = function (self, guildID, prefix, template)	-- additional parameter are used upon startup to prevent unnecessary checks
			if not self[guildID] then 
				self[guildID] = {prefix = prefix or "!vm", template = template}
				logger:log(4, "MEMORY: Added guild "..guildID)
			end
			if not sqlite:exec("SELECT * FROM guilds WHERE id = "..guildID) then
				local res = pcall(function() sqlite:exec("INSERT INTO guilds VALUES("..guildID..", '!vm', NULL)") end)
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
			logger:log(4, "STARTUP: Loading guilds from save")
			local guildIDs = sqlite:exec("SELECT * FROM guilds")
			if guildIDs then
				for i, guildID in ipairs(guildIDs.id) do
					if client:getGuild(guildID) then
						self:add(guildID, guildIDs.prefix[i], guildIDs.template[i])
					else
						self:remove(guildID)
					end
				end
			end
			
			logger:log(4, "STARTUP: Loading guilds from client")
			for _, guild in pairs(client.guilds) do
				if not self[guild.id] then self:add(guild.id) end
			end
			
			logger:log(4, "STARTUP: Loaded!")
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
		end,
		
		updateTemplate = function (self, guildID, template)
			if template then
				if self[guildID].template ~= template then
					self[guildID].template = template
					logger:log(4, "MEMORY: Updated prefix for "..guildID)
				end
				if not sqlite:prepare("SELECT * FROM guilds WHERE template = ? AND id = ?"):bind(template, guildID):step() then
					sqlite:prepare("UPDATE guilds SET template = ? WHERE id = ?"):bind(template, guildID):step()	-- don't even think about it
					logger:log(4, "DATABASE: Updated template for guild "..guildID)
				end
			end
		end
	}
})
