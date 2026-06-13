local discordia = require "discordia"
local client = require "client"

local helpers = require "overseer/helpers"
local history = require "overseer/history"
local payloads = require "overseer/payloads"
local safeEvent = require "utils/safeEvent"

local emitter = discordia.Emitter()

local Overseer = {
	events = history.events,
	track = history.track,
	resume = history.resume,
	stats = history.stats,
}

Overseer.finalize = function(room)
	local session = history.take(room)
	if not session then return nil end

	if not history.hasLoggableContent(session) then
		helpers.removeTree(session.tempDir)
		return nil
	end

	local batches, entryCount, pageCount = payloads.buildPayloads(session)

	local totalBytes = 0
	for _, batch in ipairs(batches) do
		totalBytes = totalBytes + (batch.bytes or 0)
	end

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

return Overseer