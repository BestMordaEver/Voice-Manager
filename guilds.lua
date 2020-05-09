local discordia = require "discordia"
local mutex = discordia.Mutex()
local client, logger = discordia.storage.client, discordia.storage.logger
local sqlite = require "sqlite3".open("guildsData.db")

local selectID, insert, delete, selectPrefix, updatePrefix, selectTemplate, updateTemplate = 
	sqlite:prepare("SELECT * FROM guilds WHERE id = ?"),
	sqlite:prepare("INSERT INTO guilds VALUES(?,'!vm',NULL)"),
	sqlite:prepare("DELETE FROM guilds WHERE id = ?"),
	sqlite:prepare("SELECT * FROM guilds WHERE prefix = ? AND id = ?"),
	sqlite:prepare("UPDATE guilds SET prefix = ? WHERE id = ?"),
	sqlite:prepare("SELECT * FROM guilds WHERE template = ? AND id = ?"),
	sqlite:prepare("UPDATE guilds SET template = ? WHERE id = ?")

return setmetatable({}, {
	__index = {
		add = function (self, guildID, prefix, template)	-- additional parameter are used upon startup to prevent unnecessary checks
			mutex:lock()
			if not self[guildID] then 
				self[guildID] = {prefix = prefix or "!vm", template = template}
				logger:log(4, "MEMORY: Added guild "..guildID)
			end
			if not selectID:reset():bind(guildID):step() then
				insert:reset():bind(guildID):step()
				logger:log(4, "DATABASE: Added guild "..guildID)
			end
			mutex:unlock()
		end,
		
		remove = function (self, guildID)
			mutex:lock()
			if self[guildID] then
				self[guildID] = nil
				logger:log(4, "MEMORY: Deleted guild "..guildID)
			end
			if selectID:reset():bind(guildID):step() then
				delete:reset():bind(guildID):step()
				logger:log(4, "DATABASE: Deleted guild "..guildID)
			end
			mutex:unlock()
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
			mutex:lock()
			if prefix then
				if self[guildID].prefix ~= prefix then
					self[guildID].prefix = prefix
					logger:log(4, "MEMORY: Updated prefix for "..guildID)
				end
				if not selectPrefix:reset():bind(prefix, guildID):step() then
					updatePrefix:reset():bind(prefix, guildID):step()
					logger:log(4, "DATABASE: Updated prefix for "..guildID)
				end
			end
			mutex:unlock()
		end,
		
		updateTemplate = function (self, guildID, template)
			mutex:lock()
			if self[guildID].template ~= template then
				self[guildID].template = template
				logger:log(4, "MEMORY: Updated prefix for "..guildID)
			end
			if not selectTemplate:reset():bind(template, guildID):step() then
				updateTemplate:reset():bind(template, guildID):step()
				logger:log(4, "DATABASE: Updated template for guild "..guildID)
			end
			mutex:unlock()
		end
	}
})
