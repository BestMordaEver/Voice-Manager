local discordia = require "discordia"
local client = require "client"

local helpers = require "overseer/helpers"
local history = require "overseer/history"
local payloads = require "overseer/payloads"
local safeEvent = require "utils/safeEvent"

local logger = require "logger"
local metrics = require "telemetry/metrics"
local timer = require "timer"

local hrtime = require "uv".hrtime

local emitter = discordia.Emitter()

-- transcript size buckets, tuned to the per-guild upload budget (8-90 MB)
local ENTRY_BUCKETS = {1, 5, 10, 25, 50, 100, 250, 500, 1000, 5000}
local PAGE_BUCKETS = {1, 2, 3, 5, 10, 20, 50}
local BYTE_BUCKETS = {1e3, 1e4, 1e5, 5e5, 1e6, 5e6, 1e7, 2.5e7, 5e7, 9e7}
local DURATION_BUCKETS = {5, 10, 25, 50, 100, 250, 500, 1000, 2500, 5000, 10000}

local Overseer = {
	events = history.events,
	track = history.track,
	resume = history.resume,
	ensure = history.ensure,
	stop = history.discard,
	markRoomDeleted = history.markRoomDeleted,
	stats = history.stats,
	sweep = history.sweepDeadSessions,
}

Overseer.preview = function(room)
	local session = history.peek(room)
	if not session then return nil end

	if not history.hasLoggableContent(session) then
		return nil
	end

	local batches, entryCount, pageCount = payloads.buildPayloads(session)
	return {
		payloads = batches,
		entryCount = entryCount,
		pageCount = pageCount,
	}
end

Overseer.finalize = function(room)
	local session = history.take(room)
	if not session then return nil end

	if not history.hasLoggableContent(session) then
		helpers.removeTree(session.tempDir)
		metrics.counter("voicemanager_overseer_transcripts_total", 1, {outcome = "skipped_empty"})
		return nil
	end

	-- building HTML and base64-embedding assets is CPU heavy and runs on the
	-- single thread, so time it - spikes here show up as event-loop lag
	local start = hrtime()
	local batches, entryCount, pageCount = payloads.buildPayloads(session)
	metrics.observe("voicemanager_overseer_finalize_duration_ms", (hrtime() - start) / 1e6, DURATION_BUCKETS)

	-- free the in-memory base64 data URIs now that the HTML payloads are built;
	-- they can be multiple MB each and are not needed after this point
	for _, asset in ipairs(session.assetOrder or {}) do
		asset.dataURI = nil
		asset.inlinePreview = nil
	end

	local totalBytes = 0
	for _, batch in ipairs(batches) do
		totalBytes = totalBytes + (batch.bytes or 0)
	end

	metrics.observe("voicemanager_overseer_transcript_entries", entryCount or 0, ENTRY_BUCKETS)
	metrics.observe("voicemanager_overseer_transcript_pages", pageCount or 0, PAGE_BUCKETS)
	metrics.observe("voicemanager_overseer_transcript_bytes", totalBytes, BYTE_BUCKETS)

	return {
		payloads = batches,
		entryCount = entryCount,
		pageCount = pageCount,
		cleanup = function()
			helpers.removeTree(session.tempDir)
		end,
	}
end

for name, event in pairs(Overseer.events) do
	client:on(name, function(...)
		emitter:emit(name, ...)
	end)
	emitter:onSync(safeEvent(name, event))
end

-- sweep dead sessions every 5 minutes to reclaim memory from guilds the bot
-- was removed from or channels that were manually deleted
timer.setInterval(300000, function()
	local count = history.sweepDeadSessions()
	if count > 0 then
		logger:log(3, "overseer: swept %d dead session(s)", count)
	end
end)

return Overseer