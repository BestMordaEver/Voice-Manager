--[[
lightweight Prometheus-style metric registry

counters are cumulative (only ever increased) and survive between flushes,
which is exactly what VictoriaMetrics expects so it can compute rates itself.
gauges are point-in-time values that get overwritten on every collection.

series are stored under a fully rendered key (name + sorted labels) so that
each unique label combination becomes its own time series.
]]

local concat, sort, format = table.concat, table.sort, string.format

local metrics = {}

-- fullKey -> {name = string, key = string, value = number}
local series = {}
-- name -> {type = "counter"|"gauge", help = string}
local declared = {}
-- declaration order, so the rendered output stays stable
local order = {}

local function escapeLabel (value)
	return (tostring(value)
		:gsub("\\", "\\\\")
		:gsub('"', '\\"')
		:gsub("\n", "\\n"))
end

-- builds "name{a="1",b="2"}" with labels sorted for a deterministic key
local function buildKey (name, labels)
	if not labels then return name end

	local keys = {}
	for key in pairs(labels) do keys[#keys + 1] = key end
	if #keys == 0 then return name end
	sort(keys)

	local parts = {}
	for _, key in ipairs(keys) do
		parts[#parts + 1] = format('%s="%s"', key, escapeLabel(labels[key]))
	end
	return format("%s{%s}", name, concat(parts, ","))
end

-- registers a metric's type and help text once; safe to call repeatedly
function metrics.declare (name, mtype, help)
	if not declared[name] then
		declared[name] = {type = mtype, help = help}
		order[#order + 1] = name
	end
end

local function ensure (name, mtype)
	if not declared[name] then metrics.declare(name, mtype) end
end

-- adds delta (default 1) to a cumulative counter series
function metrics.counter (name, delta, labels)
	ensure(name, "counter")
	local key = buildKey(name, labels)
	local existing = series[key]
	if existing then
		existing.value = existing.value + (delta or 1)
	else
		series[key] = {name = name, key = key, value = delta or 1}
	end
end

-- sets the current value of a gauge series, replacing any previous value
function metrics.gauge (name, value, labels)
	ensure(name, "gauge")
	local key = buildKey(name, labels)
	local existing = series[key]
	if existing then
		existing.value = value
	else
		series[key] = {name = name, key = key, value = value}
	end
end

-- formats a histogram bucket bound for the le label; +Inf is the catch-all
local function formatBound (bound)
	if bound == math.huge then return "+Inf" end
	if bound % 1 == 0 then return format("%d", bound) end
	return format("%.10g", bound)
end

-- declares a histogram as its three underlying cumulative series so the render
-- stays self-describing. observations land in <name>_bucket{le}, <name>_sum and
-- <name>_count, which is exactly what Prometheus/VictoriaMetrics expects.
-- the parts are plain counters (cumulative); histogram_quantile() reads the
-- _bucket series via its le label, so no special histogram type is needed.
function metrics.declareHistogram (name, help)
	metrics.declare(name .. "_bucket", "counter", help)
	metrics.declare(name .. "_sum", "counter")
	metrics.declare(name .. "_count", "counter")
end

-- records one observation against a histogram. buckets is a sorted list of
-- upper bounds; counts are cumulative (every bucket whose bound >= value is
-- incremented), and an implicit +Inf bucket always receives the observation.
function metrics.observe (name, value, buckets, labels)
	local bucketLabels = {}
	if labels then
		for key, label in pairs(labels) do bucketLabels[key] = label end
	end

	for _, bound in ipairs(buckets) do
		if value <= bound then
			bucketLabels.le = formatBound(bound)
			metrics.counter(name .. "_bucket", 1, bucketLabels)
		end
	end
	bucketLabels.le = "+Inf"
	metrics.counter(name .. "_bucket", 1, bucketLabels)

	metrics.counter(name .. "_sum", value, labels)
	metrics.counter(name .. "_count", 1, labels)
end

local function formatValue (value)
	if value ~= value then return "NaN" end
	if value == math.huge then return "+Inf" end
	if value == -math.huge then return "-Inf" end
	-- whole numbers render without a decimal point, everything else keeps precision
	if value % 1 == 0 and math.abs(value) < 1e15 then
		return format("%d", value)
	end
	return format("%.10g", value)
end

-- renders every series into the Prometheus text exposition format
function metrics.render ()
	-- group series keys per metric name so TYPE/HELP lines are emitted once
	local byName = {}
	for _, serie in pairs(series) do
		local bucket = byName[serie.name]
		if not bucket then
			bucket = {}
			byName[serie.name] = bucket
		end
		bucket[#bucket + 1] = serie
	end

	local out = {}
	for _, name in ipairs(order) do
		local bucket = byName[name]
		if bucket then
			local meta = declared[name]
			if meta.help then
				out[#out + 1] = format("# HELP %s %s", name, meta.help)
			end
			out[#out + 1] = format("# TYPE %s %s", name, meta.type)
			sort(bucket, function (a, b) return a.key < b.key end)
			for _, serie in ipairs(bucket) do
				out[#out + 1] = format("%s %s", serie.key, formatValue(serie.value))
			end
		end
	end

	return concat(out, "\n") .. "\n"
end

return metrics
