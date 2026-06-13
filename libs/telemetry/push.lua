--[[
pushes a Prometheus text exposition payload to a local vmagent / VictoriaMetrics.

the /api/v1/import/prometheus endpoint accepts the same text format that a
Prometheus scrape would expose, so the body produced by telemetry/metrics can
be sent verbatim. must be called from within a coroutine (coro-http requirement),
which is satisfied by the async clock event that drives the flush.
]]

local https = require "coro-http"
local config = require "config"
local logger = require "logger"

local request = https.request

-- only log on state transitions so a persistently down vmagent doesn't flood
-- the console with an identical warning on every flush
local lastOk = true
local function report (ok, level, fmt, ...)
	if ok then
		if not lastOk then logger:log(4, "telemetry: vmagent reachable again") end
	elseif lastOk then
		logger:log(level, fmt, ...)
	end
	lastOk = ok
end

return function (body)
	local endpoint = (config.vmagent or "http://127.0.0.1:8429") .. "/api/v1/import/prometheus"

	-- coro-http raises (assert) on connection failures such as ECONNREFUSED,
	-- so guard the call - a missing vmagent must not crash the flush event,
	-- otherwise safeEvent would spam the stderr channel every minute
	local ok, res, resBody = pcall(request, "POST", endpoint,
		{{"Content-Type", "text/plain"}},
		body)

	if not ok then
		report(false, 2, "telemetry: push to vmagent failed - %s", tostring(res))
		return false
	end

	if not res then
		report(false, 2, "telemetry: push to vmagent failed - %s", tostring(resBody))
		return false
	end

	if res.code >= 300 then
		report(false, 2, "telemetry: vmagent responded %d - %s", res.code, tostring(resBody))
		return false
	end

	report(true)
	return true
end
