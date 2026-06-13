local client = require "client"

local config = require "overseer/config"
local helpers = require "overseer/helpers"
local html = require "overseer/html"

local function guildUploadBudget(guild)
	if guild and guild.premiumTier and guild.premiumTier >= 3 then
		return 90 * 1024 * 1024
	end
	if guild and guild.premiumTier and guild.premiumTier >= 2 then
		return 45 * 1024 * 1024
	end
	return config.DEFAULT_UPLOAD_BUDGET
end

local function buildBatches(files, budget)
	local batches = {}
	local current = {files = {}, bytes = 0}

	local function pushCurrent()
		if #current.files > 0 then
			helpers.insert(batches, current)
			current = {files = {}, bytes = 0}
		end
	end

	for _, file in ipairs(files) do
		local size = file.size or 0
		if #current.files > 0 and (#current.files >= 10 or current.bytes + size > budget) then
			pushCurrent()
		end
		helpers.insert(current.files, file.payload)
		current.bytes = current.bytes + size
	end

	pushCurrent()
	return batches
end

local payloads = {}

function payloads.buildPayloads(session)
	local guild = client:getGuild(session.guildID)
	local budget = guildUploadBudget(guild)
	local htmlFiles, entryCount = html.buildHtmlFiles(session, budget)
	local htmlPayloadFiles = {}

	for _, file in ipairs(htmlFiles) do
		helpers.insert(htmlPayloadFiles, {
			payload = {file.name, file.content},
			size = file.size,
		})
	end

	-- every asset is embedded inline in the HTML, so nothing is uploaded as a sidecar file
	local batches = buildBatches(htmlPayloadFiles, budget)

	return batches, entryCount, #htmlFiles
end

return payloads