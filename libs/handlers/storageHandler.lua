local client = require "client"
local Overseer = require "utils/logWriter"

local guilds = require "storage/guilds"
local lobbies = require "storage/lobbies"
--local categories, categoriesEmitter = require "storage/categories"
local channels = require "storage/channels"

-- cleanup reference, shrinks as guilds load
local data = {
	-- guildID = guildData
	guilds = {},
	-- guildID = {lobbyID = lobbyData}
	lobbies = {},
	-- parentType = {parentID = {channelID = channelData}}
	channels = {[0] = {},{},{},{}}}

-- helper loader method, called once per guild, per lobby and per channel
local function loadChannels (parent, parentType)
	-- find all children of the parent
	local channelsByParent = data.channels[parentType][parent.id]
	if channelsByParent then
		for id, channelData in pairs(channelsByParent) do
			channelsByParent[id] = nil

			local channel, companion = client:getChannel(id), client:getChannel(channelData.companion)
			if channel then
				if #channel.connectedMembers > 0 then
					-- required for position tracking
					if parentType == 0 then parent:attachChild(channelData, channelData.position) end
					-- continue logger if needed
					if parent.companionLog then Overseer.resume(companion) end
					-- load in password checker channels
					loadChannels(channelData, 3)
				else
					if companion then companion:delete() end
					-- lobby children are rooms, rooms' children are password checkers
					if parentType == 0 or parentType == 3 then
						channel:delete()
					else	-- guild and category children are persistent
						channelData:delete()
					end
				end
			else
				if companion then companion:delete() end
				channelData:delete()
			end
		end
	end
end

-- main loader method that's used on bot startup
-- this might be called on reconnects
local loadGuild = function (guild)
	local guildData = guilds[guild.id] or guilds:store(guild.id)
	data.guilds[guild.id] = nil

	loadChannels(guildData, 1)

	local lobbiesByGuild = data.lobbies[guild.id]

	if lobbiesByGuild then
		for id, lobbyData in pairs(lobbiesByGuild) do
			lobbiesByGuild[id] = nil
			if client:getChannel(id) then
				guildData.lobbies:add(lobbyData)

				loadChannels(lobbyData, 0)
			else
				lobbyData:delete()
			end
		end
	end
end

-- preloader, the one that has a special place in hell reserved for me
local load = function ()
	local rawData, columns = guilds.loadGuildsStatement:step({},{})
	while rawData do
		local rolesData = guilds.loadRolesStatement:reset():bind(rawData[1]):step()
		if rolesData then
			local roles = {}
			rawData[#columns+1] = roles
			repeat
				roles[rolesData[1]] = true
			until not guilds.loadRolesStatement:step(rolesData)
		end

		data.guilds[rawData[1]] = guilds:add(unpack(rawData, 1, #columns + (rolesData and 1 or 0)))	-- many fields may be null, unpack would halt on them
		rawData = guilds.loadGuildsStatement:step()
	end
	guilds.loadRolesStatement = nil
	guilds.loadGuildsStatement = nil

	rawData, columns = lobbies.loadLobbiesStatement:step({},{})
	local dummy = {id = "none"}
	while rawData do
		local rolesData = lobbies.loadRolesStatement:reset():bind(rawData[1]):step()
		if rolesData then
			local roles = {}
			rawData[#columns+1] = roles
			repeat
				roles[rolesData[1]] = true
			until not lobbies.loadRolesStatement:step(rolesData)
		end

		local lobby = lobbies:add(unpack(rawData, 1, #columns + (rolesData and 1 or 0)))
		if not lobby.guild then lobby.guild = dummy end
		if not data.lobbies[lobby.guild.id] then data.lobbies[lobby.guild.id] = {} end
		data.lobbies[lobby.guild.id][lobby.id] = lobby
		rawData = lobbies.loadLobbiesStatement:step()
	end
	lobbies.loadRolesStatement = nil
	lobbies.loadLobbiesStatement = nil

	rawData, columns = channels.loadStatement:step({},{})
	while rawData do
		local channel = channels:add(unpack(rawData, 1, #columns))
		if not data.channels[channel.parentType][channel.parentID or channel.parent.id] then data.channels[channel.parentType][channel.parentID or channel.parent.id] = {} end
		data.channels[channel.parentType][channel.parentID or channel.parent.id][channel.id] = channel
		rawData = channels.loadStatement:step()
	end
	channels.loadStatement = nil
end

local cleanup = function ()
	for id, guildData in pairs(data.guilds) do
		if not client:getGuild(id) then
			guildData:delete()
		end
	end

	for guildID, lobbies in pairs(data.lobbies) do
		for lobbyID, lobbyData in pairs(lobbies) do
			if not (client:getChannel(lobbyID) or (client:getGuild(guildID) and client:getGuild(guildID).unavailable)) then
				lobbyData:delete()
			end
		end
	end

	-- no parent or guild unavailable
	for parentType, parents in pairs(data.channels) do
		for parentID, channels in pairs(parents) do
			for channelID, channelData in pairs(channels) do
				local channel = client:getChannel(channelID)
				if channel then
					if #channel.connectedMembers == 0 then
						if channelData.parentType == 1 or channelData.parentType == 2 then
							channelData:delete()
						else
							channel:delete()
						end
					end
				elseif parentType == 1 then
					local guild = client:getGuild(parentID)
					if not (guild and guild.unavailable) then
						channelData:delete()
					end
				else
					local parent = client:getChannel(parentID)
					if not (parent and parent.guild and parent.guild.unavailable) then
						channelData:delete()
					end
				end
			end
		end
	end

	data = nil
end

return {
	loadGuild = loadGuild,
	load = load,
	cleanup = cleanup,
	stats = {
		lobbies = 0,
		channels = 0,
		users = 0
	}
}