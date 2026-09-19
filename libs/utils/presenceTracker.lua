-- tracks which guild members should have their presence retained and fetched on demand
local client = require "client"

local tracked = {}	-- guildID -> {userID -> count of %game% rooms hosted}
local requested = {}
local counter = 0

local presenceTracker = {}

function presenceTracker.isTracked (guildId, userId)
	return tracked[guildId] and tracked[guildId][userId]
end

function presenceTracker.markTracked (guildId, userId)
	local guild = tracked[guildId] or {}
	tracked[guildId] = guild
	guild[userId] = (guild[userId] or 0) + 1
end

function presenceTracker.unmarkTracked (guildId, userId)
	local guild = tracked[guildId]
	if guild then
		local count = guild[userId]
		if count then
			if count > 1 then
				guild[userId] = count - 1
			else
				guild[userId] = nil
				if not next(guild) then tracked[guildId] = nil end
			end
		end
	end
end

-- fetches the currently played game for a member if it isn't known yet
function presenceTracker.fetchPresence (member)
	if member.playing or member.streaming or member.competing then return end

	local guild, guildId = member.guild, member.guild.id
	local userId = member.user.id

	local rq = requested[guildId] or {}
	requested[guildId] = rq
	if rq[userId] then return end	-- already awaiting a response
	rq[userId] = true

	if client._shards[guild.shardId] then
		local nonce = tostring(counter)
		counter = counter + 1
		if guild:requestMember(userId, nonce) then
			client:waitFor("guildMembersChunk", 2500, function (_, d)
				return d.nonce == nonce
			end)
		end
	end

	rq[userId] = nil
end

local function templateNeedsGame (template)
	return template and template:match("%%game%(?.-%)?%%")
end

local function roomNeedsGame (channelData)
	local parent = channelData.parent
	return channelData.parentType == 0 and parent and
		(templateNeedsGame(parent.template) or templateNeedsGame(parent.companionTemplate))
end

-- re-tracks hosts of rooms that survived a restart; the stored host is
-- authoritative, so hosts transferred before the restart are handled here
function presenceTracker.restore (channels)
	for guildId in pairs(tracked) do tracked[guildId] = nil end
	for _, channelData in pairs(channels) do
		if channelData.host and roomNeedsGame(channelData) then
			presenceTracker.markTracked(channelData.guildID, channelData.host)
		end
	end
end

return presenceTracker
