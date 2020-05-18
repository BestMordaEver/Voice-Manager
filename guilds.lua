local discordia = require "discordia"
local mutex = discordia.Mutex()
local emitter = discordia.Emitter()
local client, logger = discordia.storage.client, discordia.storage.logger
local sqlite = require "sqlite3".open("guildsData.db")
local storageInteractionEvent = require "./utils.lua".storageInteractionEvent

local add, remove, updatePrefix, updateTemplate =
	sqlite:prepare("INSERT INTO guilds VALUES(?,'!vm',NULL)"),
	sqlite:prepare("DELETE FROM guilds WHERE id = ?"),
	sqlite:prepare("UPDATE guilds SET prefix = ? WHERE id = ?"),
	sqlite:prepare("UPDATE guilds SET template = ? WHERE id = ?")

emitter:on("add", function (guildID)
	mutex:lock()
	pcall(storageInteractionEvent, add, guildID)
	mutex:unlock()
end)

emitter:on("remove", function (guildID)
	mutex:lock()
	pcall(storageInteractionEvent, remove, guildID)
	mutex:unlock()
end)

emitter:on("updatePrefix", function (guildID, prefix)
	mutex:lock()
	pcall(storageInteractionEvent, updatePrefix, prefix, guildID)
	mutex:unlock()
end)

emitter:on("updateTemplate", function (guildID, template)
	mutex:lock()
	pcall(storageInteractionEvent, updatePrefix, template, guildID)
	mutex:unlock()
end)

return setmetatable({}, {
	__index = {
		add = function (self, guildID, prefix, template)	-- additional parameter are used upon startup to prevent unnecessary checks
			if not self[guildID] then 
				self[guildID] = {prefix = prefix or "!vm", template = template}
				logger:log(4, "MEMORY: Added guild "..guildID)
			end
			emitter:emit("add", guildID)
		end,
		
		remove = function (self, guildID)
			if self[guildID] then
				self[guildID] = nil
				logger:log(4, "MEMORY: Deleted guild "..guildID)
			end
			emitter:emit("remove", guildID)
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
			if self[guildID].prefix ~= prefix then
				self[guildID].prefix = prefix
				logger:log(4, "MEMORY: Updated prefix for "..guildID)
			end
			emitter:emit("updatePrefix", guildID, prefix)
		end,
		
		updateTemplate = function (self, guildID, template)
			if self[guildID].template ~= template then
				self[guildID].template = template
				logger:log(4, "MEMORY: Updated template for guild "..guildID)
			end
			emitter:emit("updateTemplate", guildID, template)
		end
	}
})
