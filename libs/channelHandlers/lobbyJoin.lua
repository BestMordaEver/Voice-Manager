local timer = require "timer"

local discordia = require "discordia"
local client = require "client"
local logger = require "logger"

local guilds = require "storage/guilds"
local lobbies = require "storage/lobbies"
local channels = require "storage/channels"

local greetingEmbed = require "embeds/greeting"
local warningEmbed = require "embeds/warning"

local adjustPermissions = require "channelHandlers/adjustPermissions"
local handleTemplate = require "channelHandlers/handleTemplate"

local Overseer = require "utils/logWriter"
local ratelimiter = require "utils/ratelimiter"

local Mutex = discordia.Mutex
local permission = discordia.enums.permission
local channelType = discordia.enums.channelType

local processing = {}
ratelimiter("channelCreate", 2, 20)

local function lobbyJoin (member, lobby)
	logger:log(4, "GUILD %s LOBBY %s USER %s: joined", lobby.guild.id, lobby.id, member.user.id)

	local guild = lobby.guild
	local lobbyData = lobbies[lobby.id]
	local guildData = guilds[guild.id]

	if lobbyData.limit <= #lobbyData.children then
		logger:log(4, "GUILD %s LOBBY %s USER %s: lobby room limit reached", lobby.guild.id, lobby.id, member.user.id)
		return
	end

	if guildData.limit <= guildData:channels() then
		logger:log(4, "GUILD %s LOBBY %s USER %s: guild room limit reached", lobby.guild.id, lobby.id, member.user.id)
		return
	end

	-- parent to which a new channel will be attached
	local target = client:getChannel(lobbies[lobby.id].target) or lobby.category or guild

	-- determine new channel name
	local name = lobbyData.template or "%nickname's% room"
	-- potential position may change in process of name generation, so rather than query lobby for position several times, reservation is made and used throughout
	local position = lobbyData:attachChild(true)
	local needsMove

	if name:match("%%.-%%") then
		needsMove = name:match("%%counter%%") and true
		name = handleTemplate(name, member, position):match("^%s*(.-)%s*$")
		if name == "" then name = handleTemplate("%nickname's% room", member) end
	end

	-- determine channel position if %counter% is detected
	local distance = 0
	if needsMove then
		local children = lobbyData.children
		repeat
			distance = distance + 1
			if not (children[position + distance] == nil or client:getChannel(children[position + distance].id)) then
				children:drain(position + distance)
			end
		until children[position + distance] ~= nil or position + distance > children.max

		if position + distance > children.max then
			needsMove = nil
		else
			distance = client:getChannel(lobbyData.children[position + distance].id).position - 1
		end
	end

	local newChannel, err = guild:createChannel({
		name = name,
		type = channelType.voice,
		bitrate = lobbyData.bitrate or lobby.bitrate,
		user_limit = lobbyData.capacity or lobby.userLimit,
		position = needsMove and distance or nil,
		parent_id = target.id
	})

	if not newChannel then
		lobbyData:detachChild(position)
		logger:log(2, "GUILD %s LOBBY %s USER %s: couldn't create new room - %s", guild.id, lobby.id, member.user.id, err)
		return
	end

	processing[newChannel.id] = Mutex()
	processing[newChannel.id]:lock()

	member:setVoiceChannel(newChannel.id)

	local companion
	if lobbyData.companionTarget then
		-- this might look familiar
		local companionTarget = lobbyData.companionTarget == true and (newChannel.category or guild) or client:getChannel(lobbyData.companionTarget)

		if companionTarget then
			local name = lobbyData.companionTemplate or "private-chat"
			if name:match("%%.-%%") then
				name = handleTemplate(name, member, position):discordify()
				if name == "" then name = "private-chat" end
			end

			companion = guild:createChannel {
				name = name,
				type = channelType.text,
				parent_id = companionTarget.id
			}
		end
	end

	-- save channel data, attach to parent
	channels:store(newChannel.id, 0, member.user.id, lobby.id, position, companion and companion.id or nil)
	lobbyData:attachChild(channels[newChannel.id], position)

	newChannel:getPermissionOverwriteFor(guild.me):allowPermissions(permission.connect, permission.readMessages)
	adjustPermissions(newChannel, member)

	if companion then
		-- companions are private by default
		companion:getPermissionOverwriteFor(guild.me):allowPermissions(permission.readMessages, permission.sendMessages)
		companion:getPermissionOverwriteFor(member):allowPermissions(permission.readMessages)

		if #lobbyData.roles == 0 then
			companion:getPermissionOverwriteFor(guild.defaultRole):denyPermissions(permission.readMessages)
		else for role in pairs(lobbyData.roles) do
			companion:getPermissionOverwriteFor(guild:getRole(role)):denyPermissions(permission.readMessages)
		end end
	end

	if lobbyData.companionLog then Overseer.track(companion or newChannel) end
	if lobbyData.greeting or lobbyData.companionLog then (companion or newChannel):send(greetingEmbed(newChannel)) end

	processing[newChannel.id]:unlock()
	processing[newChannel.id] = nil
end

local function reset (channel, member, mutex)
	logger:log(4, "GUILD %s LOBBY %s USER %s: processing timeout", channel.guild.id, channel.id, member.user.id)
	mutex:unlock()
end

return function (member, lobby)
	local lobbyData = lobbies[lobby.id]
	local limit, retryIn = ratelimiter:limit("channelCreate", member.user.id)
	if limit == -1 then
		member:setVoiceChannel()
		member.user:send(warningEmbed(member.user, "wait", retryIn))
		return
	end

	lobbyData.mutex:lock()
	local timeout = timer.setTimeout(10000, reset, lobby, member, lobbyData.mutex)
	local ok, err = xpcall(lobbyJoin, debug.traceback, member, lobby)
	timer.clearTimeout(timeout)
	lobbyData.mutex:unlock()
	if not ok then error(string.format('failed to process a user %s joining lobby "%s"\n%s', member.user.id, lobby.id, err)) end
end