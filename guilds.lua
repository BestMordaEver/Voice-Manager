local discordia = require "discordia"
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
	pcall(storageInteractionEvent, add, guildID)
end)

emitter:on("remove", function (guildID)
	pcall(storageInteractionEvent, remove, guildID)
end)

emitter:on("updatePrefix", function (guildID, prefix)
	pcall(storageInteractionEvent, updatePrefix, prefix, guildID)
end)

emitter:on("updateTemplate", function (guildID, template)
	pcall(storageInteractionEvent, updatePrefix, template, guildID)
end)

return setmetatable({}, {
	__index = {
		add = function (self, guildID, prefix, template)	-- additional parameter are used upon startup to prevent unnecessary checks
			self[guildID] = {prefix = prefix or "!vm", template = template}
			logger:log(4, "GUILD %s: Added", guildID)
			emitter:emit("add", guildID)
		end,
		
		remove = function (self, guildID)
			self[guildID] = nil
			logger:log(4, "GUILD %s: Deleted", guildID)
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
			self[guildID].prefix = prefix
			logger:log(4, "GUILD %s: Updated prefix", guildID)
			emitter:emit("updatePrefix", guildID, prefix)
		end,
		
		updateTemplate = function (self, guildID, template)
			self[guildID].template = template
			logger:log(4, "GUILD %s: Updated template", guildID)
			emitter:emit("updateTemplate", guildID, template)
		end
	}
})
