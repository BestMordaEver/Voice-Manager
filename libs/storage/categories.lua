-- object to store data about active categories and interact with corresponding db
-- parentless categories are never deleted
-- child must be deleted when empty
-- CREATE TABLE categories(id VARCHAR PRIMARY KEY, parent VARCHAR, child VARCHAR)

local discordia = require "discordia"
local sqlite = require "sqlite3".open("channelsData.db")

local client, logger = discordia.storage.client, discordia.storage.logger

local lobbies = require "storage/lobbies"
local storageInteraction = require "utils/storageInteraction"
local channelType = discordia.enums.channelType

-- used to start storageInteractionEvent as async process
-- because fuck data preservation, we need dat speed
local emitter = discordia.Emitter()

-- prepared statements
local add, remove, updateChild =
	sqlite:prepare("INSERT INTO categories VALUES(?,?,?)"),
	sqlite:prepare("DELETE FROM categories WHERE id = ?"),
	sqlite:prepare("UPDATE categories SET child = ? WHERE id = ?")
	

emitter:on("add", storageInteraction(add, "Added category %s", "Couldn't add category %s"))
emitter:on("remove", storageInteraction(remove, "Removed category %s", "Couldn't remove category %s"))
emitter:on("updateChild", storageInteraction(updateChild, "Updated child to %s for category %s", "Couldn't update child to %s for category %s"))

local categories = {}
local categoryMT = {
	__index = {
		-- no granular control, if it goes away, it does so everywhere
		delete = function (self)
			if categories[self.id] then
				categories[self.id] = nil
				local category = client:getChannel(self.id)
				if category and category.guild then	-- if we initiate removal, we delete storage info first, so we have info about parent guild
					logger:log(4, "GUILD %s: Removed category %s", category.guild.id, self.id)
				else	-- otherwise we have no context of parent guild and have to investigate
					logger:log(4, "NULL: Removed category %s", self.id)
				end
			end
			emitter:emit("remove", self.id)
		end,
		
		updateChild = function (self, childID)	-- childID can be nil
			local category = client:getChannel(self.id)
			if category and categories[self.id] then
				self.child = childID
				logger:log(4, "GUILD %s: Updated child for category %s", category.guild.id, self.id)
				emitter:emit("updateChild", childID, self.id)
			else
				self:remove()
			end
		end
	},
	__tostring = function (self) return string.format("CategoryData: %s", self.id) end
}
local categoriesIndex = {
	-- perform checks and add category to table
	loadAdd = function (self, categoryID, parentData, childData)
		if not self[categoryID] then
			local category = client:getChannel(categoryID)
			if category and category.guild then
				self[categoryID] = setmetatable({id = categoryID, parent = parentData, child = childData}, categoryMT)
				logger:log(4, "GUILD %s: Added category %s", category.guild.id, categoryID)
			end
		end
	end,
	
	-- loadAdd and start interaction with db
	add = function (self, categoryID, parent, child)
		if parent then parent = categories[parent] end
		if child then child = categories[child] end
		
		self:loadAdd(categoryID, parent, child)
		if self[categoryID] then
			emitter:emit("add", categoryID, parent and parent.id or nil, child and child.id or nil)
			return self[categoryID]
		end
	end,
	
	load = function (self)
		logger:log(4, "STARTUP: Loading categories")
		local categoryIDs = sqlite:exec("SELECT * FROM categories")
		if categoryIDs then
			for i, categoryID in ipairs(categoryIDs[1]) do
				local category = client:getChannel(categoryID)
				if category then
					if #category.textChannels > 0 or #category.voiceChannels > 0 then
						self:loadAdd(categoryID, categories[channelIDs.parent[i]], categories[channelIDs.child[i]])
					else
						category:delete()
					end
				else
					emitter:emit("remove", categoryID)
				end
			end
		end
		
		logger:log(4, "STARTUP: Loading parent categories from client")
		for _, lobbyData in pairs(lobbies) do
			local target = client:getChannel(lobbyData.target) or client:getChannel(lobbyData).category
			if target and not categories[target.id] and target.type == channelType.category then
				self:loadAdd(categoryID, nil, nil)
			end
		end
		
		logger:log(4, "STARTUP: Loaded!")
	end,
	
	-- are there empty channels? kill!
	cleanup = function (self)
		for categoryID, categoryData in pairs(self) do
			local category = client:getChannel(categoryID)
			if category then
				if categoryData.parent ~= nil and #category.textChannels = 0 and #category.voiceChannels = 0 then
					category:delete()
				end
			else
				categoryData:delete()
			end
		end
	end
}

return setmetatable(categories, {
	__index = categoriesIndex,
	__len = function (self)
		local count = 0
		for v,_ in pairs(self) do count = count + 1 end
		return count
	end,
	__call = categoriesIndex.add
})