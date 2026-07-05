local discordia = require "discordia"
local client = require "client"

local assets = require "overseer/assets"
local config = require "overseer/config"
local helpers = require "overseer/helpers"
local guilds = require "storage/guilds"

local Date = discordia.Date

local sessions = {}
local channelToSession = {}

local function makeSession(roomChannel)
	helpers.ensureDirectory(config.TRANSCRIPTS_DIR)
	local guildData = guilds[roomChannel.guild.id]
	local tempDir = helpers.pathJoin(config.TRANSCRIPTS_DIR, roomChannel.id)
	helpers.ensureDirectory(tempDir)
	return {
		id = roomChannel.id,
		guildID = roomChannel.guild.id,
		guildName = roomChannel.guild.name,
		roomName = roomChannel.name,
		hostTag = nil,
		logTimeOffset = guildData and guildData.logTimeOffset or 0,
		tempDir = tempDir,
		sources = {},
		assets = {},
		assetOrder = {},
		snapshots = {},
		entries = {},
		sequence = 0,
	}
end

local function registerSource(session, channel, kind)
	if not channel then return end
	session.sources[channel.id] = {
		id = channel.id,
		name = channel.name,
		kind = kind,
		categoryName = channel.category and channel.category.name or nil,
		position = channel.position,
	}
	channelToSession[channel.id] = session.id
end

-- resolves a display tag for the room host, accepting a member, user or raw id
local function resolveHostTag(host)
	if not host then return nil end
	if type(host) == "table" then
		if host.tag or host.name then return host.tag or host.name end
		if host.user then return host.user.tag or host.user.name end
		host = host.id
	end
	if not host then return nil end
	local ok, user = pcall(client.getUser, client, host)
	if ok and user then return user.tag or user.name end
	return tostring(host)
end

local function safeSource(session, channel)
	local source = channel and session.sources[channel.id]
	if source and channel then
		source.name = channel.name
		return source
	end
	if source then return source end
	return {
		id = channel and channel.id or "unknown",
		name = helpers.safeChannelName(channel),
		kind = "room",
	}
end

local function getOrCreateSession(roomChannel, companionChannel, host)
	local session = sessions[roomChannel.id]
	if not session then
		session = makeSession(roomChannel)
		sessions[roomChannel.id] = session
	end
	session.guildName = roomChannel.guild.name
	session.roomName = roomChannel.name
	if host then session.hostTag = session.hostTag or resolveHostTag(host) end
	local guildData = guilds[roomChannel.guild.id]
	session.logTimeOffset = guildData and guildData.logTimeOffset or 0
	registerSource(session, roomChannel, "room")
	registerSource(session, companionChannel, "companion")
	return session
end

local function snapshotUser(session, user)
	local snapshot = helpers.snapshotUser(user)
	snapshot.avatar = assets.captureUserAvatar(session, snapshot)
	return snapshot
end

local function captureSnapshot(session, message)
	local source = safeSource(session, message.channel)
	local ephemeral = false
	if type(message.hasFlag) == "function" then
		local ok, value = pcall(message.hasFlag, message, "ephemeral")
		ephemeral = ok and value or false
	end
	local snapshot = {
		id = message.id,
		author = snapshotUser(session, message.author),
		sourceChannelID = source.id,
		sourceChannelName = source.name,
		sourceKind = source.kind,
		content = message.cleanContent or message.content or "",
		attachments = assets.captureAttachments(session, message.id, message.attachments),
		embeds = helpers.clone(message.embeds or {}),
		components = helpers.clone(message.components or {}),
		reactions = helpers.reactionSummary(message.reactions),
		referencedMessageID = message.referencedMessage and message.referencedMessage.id or nil,
		referencedAuthor = message.referencedMessage and snapshotUser(session, message.referencedMessage.author) or nil,
		createdAt = message:getDate():toSeconds(),
		editedAt = message.editedTimestamp and Date.parseISO(message.editedTimestamp) or nil,
		pinned = message.pinned or false,
		ephemeral = ephemeral,
	}
	session.snapshots[message.id] = snapshot
	return snapshot
end

local function addEntry(session, entry)
	session.sequence = session.sequence + 1
	entry.sequence = session.sequence
	helpers.insert(session.entries, entry)
end

local function addNotice(session, action, text)
	addEntry(session, {
		type = "notice",
		action = action,
		text = text,
		timestamp = os.time(),
	})
end

local function recordMessage(session, message, action)
	local snapshot = captureSnapshot(session, message)
	addEntry(session, {
		type = "message",
		action = action,
		timestamp = action == "create" and snapshot.createdAt or snapshot.editedAt or os.time(),
		message = snapshot,
	})
end

local function recordMessageByLookup(session, channel, messageID, action)
	local message = channel:getMessage(messageID)
	if message then
		recordMessage(session, message, action)
		return
	end

	local source = safeSource(session, channel)
	addEntry(session, {
		type = "message",
		action = action,
		timestamp = os.time(),
		messageID = messageID,
		sourceChannelID = source.id,
		sourceChannelName = source.name,
		sourceKind = source.kind,
	})
end

local function recordDeletion(session, message)
	local snapshot = session.snapshots[message.id] or captureSnapshot(session, message)
	addEntry(session, {
		type = "message",
		action = "delete",
		timestamp = os.time(),
		message = helpers.clone(snapshot),
	})
	session.snapshots[message.id] = nil
end

local function recordDeletionByLookup(session, channel, messageID)
	local snapshot = session.snapshots[messageID]
	if snapshot then
		addEntry(session, {
			type = "message",
			action = "delete",
			timestamp = os.time(),
			message = helpers.clone(snapshot),
		})
		session.snapshots[messageID] = nil
		return
	end

	local source = safeSource(session, channel)
	addEntry(session, {
		type = "message",
		action = "delete",
		timestamp = os.time(),
		messageID = messageID,
		sourceChannelID = source.id,
		sourceChannelName = source.name,
		sourceKind = source.kind,
	})
end

local function recordReaction(session, source, messageID, emoji, userID, action)
	local user = client:getUser(userID)
	addEntry(session, {
		type = "reaction",
		action = action,
		timestamp = os.time(),
		messageID = messageID,
		emoji = emoji,
		user = snapshotUser(session, user or {id = userID, tag = userID, name = userID}),
		sourceChannelID = source.id,
		sourceChannelName = source.name,
		sourceKind = source.kind,
	})
end

local function recordInteraction(session, interaction, action)
	local source = safeSource(session, interaction.channel)
	addEntry(session, {
		type = "interaction",
		action = action,
		timestamp = os.time(),
		user = snapshotUser(session, interaction.user),
		messageID = interaction.message and interaction.message.id or nil,
		customID = interaction.customId,
		sourceChannelID = source.id,
		sourceChannelName = source.name,
		sourceKind = source.kind,
	})
end

local function recordCommand(session, interaction)
	local source = safeSource(session, interaction.channel)
	local commandParts = {interaction.commandName}
	if interaction.subcommand then helpers.insert(commandParts, interaction.subcommand) end
	if interaction.subcommandOption then helpers.insert(commandParts, interaction.subcommandOption) end

	addEntry(session, {
		type = "interaction",
		action = "command",
		timestamp = os.time(),
		user = snapshotUser(session, interaction.user),
		messageID = interaction.commandType == 3 and interaction.target and interaction.target.id or nil,
		customID = helpers.concat(commandParts, " "),
		commandType = interaction.commandType,
		sourceChannelID = source.id,
		sourceChannelName = source.name,
		sourceKind = source.kind,
	})
end

local function recordVoice(session, channel, member, action)
	local source = safeSource(session, channel)
	addEntry(session, {
		type = "voice",
		action = action,
		timestamp = os.time(),
		user = snapshotUser(session, member and member.user),
		sourceChannelID = source.id,
		sourceChannelName = source.name,
		sourceKind = source.kind,
	})
end

local function hydrateChannelHistory(session, channel)
	if not channel then return end
	local message = channel:getFirstMessage()
	local lastMessage = channel:getLastMessage()

	if not message then return end
	recordMessage(session, message, "create")

	while message ~= lastMessage do
		local messages = channel:getMessagesAfter(message, 100)
		if not messages then break end
		messages = messages:toArray("createdAt")
		for _, nextMessage in ipairs(messages) do
			recordMessage(session, nextMessage, "create")
		end
		message = messages[#messages]
	end
end

local history = {}

function history.track(roomChannel, companionChannel, host)
	return getOrCreateSession(roomChannel, companionChannel, host)
end

function history.resume(roomChannel, companionChannel, host, reason)
	local session = getOrCreateSession(roomChannel, companionChannel, host)
	hydrateChannelHistory(session, roomChannel)
	hydrateChannelHistory(session, companionChannel)
	if reason == "restored" then
		addNotice(session, "restored", "Logger session was restored from active room state. Earlier edits/deletes/reactions may be missing.")
	end
	return session
end

function history.ensure(roomChannel, companionChannel, host, reason)
	local existing = sessions[roomChannel.id]
	if existing then
		getOrCreateSession(roomChannel, companionChannel, host)
		return existing, false
	end

	local session = history.resume(roomChannel, companionChannel, host)
	if reason == "subscribe" then
		addNotice(session, "late_start", "Transcript collection started after /room subscribe. Earlier events may be missing.")
	elseif reason == "log" then
		addNotice(session, "late_start", "Transcript collection started after /room log. Earlier events may be missing.")
	end

	return session, true
end

function history.discard(room)
	local session = history.take(room)
	if not session then return nil end
	helpers.removeTree(session.tempDir)
	return session
end

function history.markRoomDeleted(room)
	local roomID = type(room) == "table" and room.id or room
	local session = sessions[roomID]
	if not session then return end
	addNotice(session, "room_deleted", "Room deletion detected. Finalizing transcript upload.")
end

function history.take(room)
	local roomID = type(room) == "table" and room.id or room
	local session = sessions[roomID]
	if not session then return nil end

	if type(room) == "table" then
		session.roomName = room.name
		session.guildName = room.guild.name
		local guildData = guilds[room.guild.id]
		session.logTimeOffset = guildData and guildData.logTimeOffset or 0
	end

	sessions[roomID] = nil
	for channelID in pairs(session.sources) do
		channelToSession[channelID] = nil
	end
	return session
end

function history.peek(room)
	local roomID = type(room) == "table" and room.id or room
	local session = sessions[roomID]
	if not session then return nil end

	if type(room) == "table" then
		session.roomName = room.name
		session.guildName = room.guild.name
		local guildData = guilds[room.guild.id]
		session.logTimeOffset = guildData and guildData.logTimeOffset or 0
	end

	return session
end

history.events = {
	messageCreate = function(message)
		local sessionID = channelToSession[message.channel.id]
		local session = sessionID and sessions[sessionID] or nil
		if session then recordMessage(session, message, "create") end
	end,

	messageUpdate = function(message)
		local sessionID = channelToSession[message.channel.id]
		local session = sessionID and sessions[sessionID] or nil
		if session then recordMessage(session, message, "update") end
	end,

	messageUpdateUncached = function(channel, messageID)
		local sessionID = channelToSession[channel.id]
		local session = sessionID and sessions[sessionID] or nil
		if session then recordMessageByLookup(session, channel, messageID, "update") end
	end,

	messageDelete = function(message)
		local sessionID = channelToSession[message.channel.id]
		local session = sessionID and sessions[sessionID] or nil
		if session then recordDeletion(session, message) end
	end,

	messageDeleteUncached = function(channel, messageID)
		local sessionID = channelToSession[channel.id]
		local session = sessionID and sessions[sessionID] or nil
		if session then recordDeletionByLookup(session, channel, messageID) end
	end,

	reactionAdd = function(reaction, userID)
		local sessionID = channelToSession[reaction.message.channel.id]
		local session = sessionID and sessions[sessionID] or nil
		if session then
			recordReaction(session, safeSource(session, reaction.message.channel), reaction.message.id, reaction.emojiHash, userID, "add")
		end
	end,

	reactionAddUncached = function(channel, messageID, hash, userID)
		local sessionID = channelToSession[channel.id]
		local session = sessionID and sessions[sessionID] or nil
		if session then
			recordReaction(session, safeSource(session, channel), messageID, hash, userID, "add")
		end
	end,

	reactionRemove = function(reaction, userID)
		local sessionID = channelToSession[reaction.message.channel.id]
		local session = sessionID and sessions[sessionID] or nil
		if session then
			recordReaction(session, safeSource(session, reaction.message.channel), reaction.message.id, reaction.emojiHash, userID, "remove")
		end
	end,

	reactionRemoveUncached = function(channel, messageID, hash, userID)
		local sessionID = channelToSession[channel.id]
		local session = sessionID and sessions[sessionID] or nil
		if session then
			recordReaction(session, safeSource(session, channel), messageID, hash, userID, "remove")
		end
	end,

	componentInteraction = function(interaction)
		if interaction.channel then
			local sessionID = channelToSession[interaction.channel.id]
			local session = sessionID and sessions[sessionID] or nil
			if session then recordInteraction(session, interaction, "component") end
		end
	end,

	modalInteraction = function(interaction)
		if interaction.channel then
			local sessionID = channelToSession[interaction.channel.id]
			local session = sessionID and sessions[sessionID] or nil
			if session then recordInteraction(session, interaction, "modal") end
		end
	end,

	commandInteraction = function(interaction)
		if interaction.channel then
			local sessionID = channelToSession[interaction.channel.id]
			local session = sessionID and sessions[sessionID] or nil
			if session then recordCommand(session, interaction) end
		end
	end,

	voiceChannelJoin = function(member, channel)
		if not channel then return end
		local sessionID = channelToSession[channel.id]
		local session = sessionID and sessions[sessionID] or nil
		if session then recordVoice(session, channel, member, "join") end
	end,

	voiceChannelLeave = function(member, channel)
		if not channel then return end
		local sessionID = channelToSession[channel.id]
		local session = sessionID and sessions[sessionID] or nil
		if session then recordVoice(session, channel, member, "leave") end
	end,

	channelUpdate = function(channel)
		local sessionID = channelToSession[channel.id]
		local session = sessionID and sessions[sessionID] or nil
		if not session then return end
		local source = session.sources[channel.id]
		if not source then return end
		local oldName = source.name
		source.name = channel.name
		source.categoryName = channel.category and channel.category.name or nil
		source.position = channel.position
		if channel.id == session.id then session.roomName = channel.name end
		if oldName ~= channel.name then
			addEntry(session, {
				type = "channel",
				action = "rename",
				timestamp = os.time(),
				sourceChannelID = channel.id,
				sourceChannelName = channel.name,
				oldName = oldName,
				sourceKind = source.kind,
			})
		end
	end,
}

-- returns true if the session holds anything worth logging beyond the bot's own greeting
function history.hasLoggableContent(session)
	if not session then return false end
	local botID = client.user and tostring(client.user.id) or nil
	for _, entry in ipairs(session.entries) do
		if entry.type == "notice" then
			return true
		end
		local author = entry.type == "message" and entry.message and entry.message.author
		local isBotGreeting = botID and author and tostring(author.id) == botID
		if not isBotGreeting then
			return true
		end
	end
	return false
end

-- read-only snapshot of overseer storage, used for telemetry
function history.stats()
	local sessionCount, entries, snapshots = 0, 0, 0
	for _, session in pairs(sessions) do
		sessionCount = sessionCount + 1
		entries = entries + #session.entries
		for _ in pairs(session.snapshots) do
			snapshots = snapshots + 1
		end
	end
	return {
		sessions = sessionCount,
		entries = entries,
		snapshots = snapshots,
		diskBytes = helpers.directorySize(config.TRANSCRIPTS_DIR),
	}
end

-- sweep sessions whose guild or room channel no longer exists
-- (bot was kicked, guild deleted, channel manually removed)
-- returns the number of dead sessions discarded
function history.sweepDeadSessions()
	local dead = {}
	for roomID, session in pairs(sessions) do
		local guild = client:getGuild(session.guildID)
		if not guild then
			helpers.insert(dead, {id = roomID, reason = "guild_gone"})
		else
			local channel = guild:getChannel(roomID)
			if not channel then
				helpers.insert(dead, {id = roomID, reason = "channel_deleted"})
			end
		end
	end
	for _, item in ipairs(dead) do
		history.discard(item.id)
	end
	return #dead
end

return history