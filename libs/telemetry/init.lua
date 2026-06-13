--[[
telemetry collector

wires lightweight, non-invasive instrumentation into the running client and
collects everything into the metrics registry, then flushes it to vmagent.

instrumentation strategy:
  - HTTP: wrap client._api.request to time every REST call and tag the outcome
  - events: wrap client.emit to count every gateway/library event by name
  - latency: listen to the heartbeat event for per-shard websocket latency
gauges (cache sizes, active users, overseer storage, ...) are sampled lazily
at flush time so we never keep stale values around.
]]

local uv = require "uv"
local fs = require "fs"
local timer = require "timer"
local client = require "client"

local metrics = require "telemetry/metrics"
local push = require "telemetry/push"

local storage = require "storage/handler"
local Overseer = require "overseer"
local mercy = require "utils/mercy"
local config = require "config"

local hrtime = uv.hrtime
local wrap = coroutine.wrap
local NS_PER_MS = 1e6

-- how often the lightweight latency flush runs; the heavy full flush stays on
-- the clock's `min` tick (see events/telemetry.lua)
local FAST_INTERVAL_MS = 10000
local LAG_INTERVAL_MS = 1000

-- sqlite databases whose on-disk size we track (WAL/SHM sidecars folded in)
local DATABASES = {
	guilds = "guildsData.db",
	lobbies = "lobbiesData.db",
	channels = "channelsData.db",
}

local telemetry = {metrics = metrics}
local started = false
local startTime = os.time()

-- max event-loop lag observed since the last fast flush, in ms
local maxLagMs = 0

-- declares types/help so the rendered output is self-describing in VictoriaMetrics
local function declareMetrics ()
	-- VoiceManager stats
	metrics.declare("voicemanager_guilds", "gauge", "Guilds the bot is currently in")
	metrics.declare("voicemanager_lobbies", "gauge", "Configured lobbies across all guilds")
	metrics.declare("voicemanager_channels", "gauge", "Live temporary voice rooms")
	metrics.declare("voicemanager_active_users", "gauge", "Users currently connected to live rooms")
	metrics.declare("voicemanager_shards", "gauge", "Number of shards this client manages")
	metrics.declare("voicemanager_uptime_seconds", "gauge", "Seconds since telemetry started")
	metrics.declare("voicemanager_lua_memory_bytes", "gauge", "Lua heap size in bytes")
	metrics.declare("voicemanager_resident_memory_bytes", "gauge", "Process resident set size in bytes")
	metrics.declare("voicemanager_event_loop_lag_ms", "gauge", "Worst event-loop scheduling delay in the last window, in ms")
	metrics.declare("voicemanager_db_writes_total", "counter", "Database write statements, by outcome")
	metrics.declare("voicemanager_db_size_bytes", "gauge", "On-disk size of each sqlite database, including WAL/SHM")
	metrics.declare("voicemanager_commands_total", "counter", "Slash commands invoked, by command and outcome")
	metrics.declare("voicemanager_command_duration_ms_sum", "counter", "Cumulative slash command handling time in ms")
	metrics.declare("voicemanager_command_duration_ms_count", "counter", "Number of slash commands measured")
	metrics.declare("voicemanager_lobby_joins_total", "counter", "Lobby joins by outcome (created, ratelimited, room_limit, guild_limit, create_failed)")
	metrics.declare("voicemanager_overseer_sessions", "gauge", "Active overseer transcript sessions")
	metrics.declare("voicemanager_overseer_entries", "gauge", "Buffered overseer timeline entries")
	metrics.declare("voicemanager_overseer_snapshots", "gauge", "Cached overseer message snapshots")
	metrics.declare("voicemanager_overseer_disk_bytes", "gauge", "Disk used by overseer transcripts in bytes")
	metrics.declare("voicemanager_overseer_transcripts_total", "counter", "Finalized transcripts by outcome (uploaded, skipped_empty, no_log_channel, upload_failed)")
	metrics.declare("voicemanager_overseer_assets_total", "counter", "Captured transcript assets, by kind and outcome (archived, failed)")
	metrics.declare("voicemanager_overseer_asset_bytes_total", "counter", "Bytes downloaded for transcript assets, by kind")
	metrics.declareHistogram("voicemanager_overseer_finalize_duration_ms", "Time spent building a transcript's HTML payloads, in ms")
	metrics.declareHistogram("voicemanager_overseer_transcript_entries", "Timeline entry count per finalized transcript")
	metrics.declareHistogram("voicemanager_overseer_transcript_pages", "HTML page count per finalized transcript")
	metrics.declareHistogram("voicemanager_overseer_transcript_bytes", "Total upload size per finalized transcript, in bytes")
	metrics.declare("voicemanager_watchdog_credits", "gauge", "Heartbeat watchdog credits per shard (3 healthy, <0 reboots)")
	metrics.declareHistogram("voicemanager_room_lifetime_seconds", "Lifetime of temporary voice rooms from creation to deletion")

	-- Discordia telemetry
	metrics.declare("discordia_events_total", "counter", "Library events emitted, by event name")
	metrics.declare("discordia_http_requests_total", "counter", "REST requests, by method and outcome")
	metrics.declare("discordia_http_request_duration_ms_sum", "counter", "Cumulative REST request time in ms")
	metrics.declare("discordia_http_request_duration_ms_count", "counter", "Number of REST requests measured")
	metrics.declare("discordia_http_ratelimited_total", "counter", "REST requests that hit a 429 and were retried")
	metrics.declare("discordia_http_badgateway_total", "counter", "REST requests that hit a 502 and were retried")
	metrics.declare("discordia_gateway_events_total", "counter", "Shard lifecycle events, by type")
	metrics.declare("discordia_shard_latency_ms", "gauge", "Websocket heartbeat round trip per shard")
	metrics.declare("discordia_cache_objects", "gauge", "Cached library objects, by type")
end

-- times every REST call and records its outcome (failures carry an error).
-- the discordia class system copies base methods onto each subclass table and
-- forbids overwriting them on an instance, so we patch the method on the class
-- itself (reached through __class) - there is only ever one API in the process.
local function instrumentHTTP ()
	local api = client._api
	if not api then return end

	local apiClass = api.__class
	local rawRequest = apiClass.request
	apiClass.request = function (self, method, endpoint, ...)
		local start = hrtime()
		local data, err = rawRequest(self, method, endpoint, ...)
		local elapsed = (hrtime() - start) / NS_PER_MS

		metrics.counter("discordia_http_requests_total", 1,
			{method = method, outcome = err and "failure" or "success"})
		metrics.counter("discordia_http_request_duration_ms_sum", elapsed, {method = method})
		metrics.counter("discordia_http_request_duration_ms_count", 1, {method = method})

		return data, err
	end
end

-- counts every event the client dispatches, keyed by event name. patched on the
-- Client class (not the shared Emitter base) so only client events are counted.
local function instrumentEvents ()
	local clientClass = client.__class
	local rawEmit = clientClass.emit
	clientClass.emit = function (self, name, ...)
		metrics.counter("discordia_events_total", 1, {event = name})
		return rawEmit(self, name, ...)
	end
end

-- sums per-guild caches in a single pass to avoid repeated iteration
local function collectCacheObjects ()
	metrics.gauge("discordia_cache_objects", client.guilds:count(), {type = "guilds"})
	metrics.gauge("discordia_cache_objects", client.users:count(), {type = "users"})
	metrics.gauge("discordia_cache_objects", client.privateChannels:count(), {type = "privateChannels"})

	local members, roles, channels, emojis = 0, 0, 0, 0
	for guild in client.guilds:iter() do
		members = members + guild.members:count()
		roles = roles + guild.roles:count()
		channels = channels + guild.textChannels:count() + guild.voiceChannels:count() + guild.categories:count()
		emojis = emojis + guild.emojis:count()
	end

	metrics.gauge("discordia_cache_objects", members, {type = "members"})
	metrics.gauge("discordia_cache_objects", roles, {type = "roles"})
	metrics.gauge("discordia_cache_objects", channels, {type = "channels"})
	metrics.gauge("discordia_cache_objects", emojis, {type = "emojis"})
end

-- overseer is under construction; sample it defensively so a hiccup never
-- breaks the rest of the flush
local function collectOverseer ()
	if type(Overseer.stats) ~= "function" then return end

	local ok, snapshot = pcall(Overseer.stats)
	if not ok or type(snapshot) ~= "table" then return end

	metrics.gauge("voicemanager_overseer_sessions", snapshot.sessions or 0)
	metrics.gauge("voicemanager_overseer_entries", snapshot.entries or 0)
	metrics.gauge("voicemanager_overseer_snapshots", snapshot.snapshots or 0)
	metrics.gauge("voicemanager_overseer_disk_bytes", snapshot.diskBytes or 0)
end

-- sums a database file together with its WAL/SHM sidecars; 0 if absent
local function dbSize (path)
	local total = 0
	for _, suffix in ipairs({"", "-wal", "-shm"}) do
		local stat = fs.statSync(path .. suffix)
		if stat then total = total + (stat.size or 0) end
	end
	return total
end

local function collectDatabases ()
	for name, path in pairs(DATABASES) do
		metrics.gauge("voicemanager_db_size_bytes", dbSize(path), {database = name})
	end
end

-- cheap gauges sampled on the fast (10s) flush: memory, event-loop lag
local function collectFast ()
	metrics.gauge("voicemanager_lua_memory_bytes", collectgarbage("count") * 1024)
	metrics.gauge("voicemanager_resident_memory_bytes", uv.resident_set_memory())
	metrics.gauge("voicemanager_event_loop_lag_ms", maxLagMs)
	maxLagMs = 0
end

-- mercy is the heartbeat watchdog; only meaningful when the check is enabled
local function collectWatchdog ()
	if not config.heartbeat or type(mercy.peek) ~= "function" then return end
	for shard, credits in pairs(mercy.peek()) do
		metrics.gauge("voicemanager_watchdog_credits", credits, {shard = tostring(shard)})
	end
end

-- samples all point-in-time gauges right before a full flush
local function collectGauges ()
	local stats = storage.stats

	metrics.gauge("voicemanager_guilds", client.guilds:count())
	metrics.gauge("voicemanager_lobbies", stats.lobbies)
	metrics.gauge("voicemanager_channels", stats.channels)
	metrics.gauge("voicemanager_active_users", stats.users)
	metrics.gauge("voicemanager_shards", client.shardCount or 1)

	metrics.gauge("voicemanager_uptime_seconds", os.time() - startTime)

	collectFast()
	collectDatabases()
	collectWatchdog()
	collectCacheObjects()
	collectOverseer()
end

-- lightweight latency flush: refreshes only cheap gauges then pushes the
-- registry (counters are cumulative, heavy gauges keep their last full value)
function telemetry.flushFast ()
	collectFast()
	return push(metrics.render())
end

-- samples every gauge, renders the registry and pushes it to vmagent
function telemetry.flush ()
	collectGauges()
	return push(metrics.render())
end

-- installs instrumentation once; safe to call again as a no-op
function telemetry.initialize ()
	if started then return end
	started = true
	startTime = os.time()

	declareMetrics()
	instrumentHTTP()
	instrumentEvents()

	client:on("heartbeat", function (shard, latency)
		metrics.gauge("discordia_shard_latency_ms", latency, {shard = tostring(shard)})
	end)

	-- shard lifecycle: dedicated, clearly named counters for dashboards/alerting
	client:on("shardReady", function ()
		metrics.counter("discordia_gateway_events_total", 1, {type = "ready"})
	end)
	client:on("shardResumed", function ()
		metrics.counter("discordia_gateway_events_total", 1, {type = "resumed"})
	end)
	client:on("shardDisconnect", function ()
		metrics.counter("discordia_gateway_events_total", 1, {type = "disconnect"})
	end)

	-- rate limit / bad gateway detection: API:commit logs a numeric-prefixed
	-- warning ("<code> - <reason> : retrying after ...") only on 429 and 502
	client:on("warning", function (msg)
		local code = tostring(msg):match("^(%d+) %-")
		if code == "429" then
			metrics.counter("discordia_http_ratelimited_total", 1)
		elseif code == "502" then
			metrics.counter("discordia_http_badgateway_total", 1)
		end
	end)

	-- event-loop lag: a 1s timer should fire ~every 1000ms; anything beyond that
	-- is time the single-threaded loop spent blocked. we keep the worst value
	-- seen each window and push it on the fast (10s) latency flush.
	local expected = hrtime()
	timer.setInterval(LAG_INTERVAL_MS, function ()
		local now = hrtime()
		local lag = (now - expected) / NS_PER_MS - LAG_INTERVAL_MS
		expected = now
		if lag > maxLagMs then maxLagMs = lag end
	end)

	-- fast latency flush; timer callbacks are not coroutines, so wrap each tick
	-- because the http push yields
	timer.setInterval(FAST_INTERVAL_MS, function ()
		wrap(telemetry.flushFast)()
	end)
end

return telemetry
