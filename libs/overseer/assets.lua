local client = require "client"

local base64 = require "base64"
local fs = require "fs"
local http = require "coro-http"

local config = require "overseer/config"
local helpers = require "overseer/helpers"

local metrics = require "telemetry/metrics"

local encodeBase64 = base64.encode
local request = http.request
local writeFileSync = fs.writeFileSync

local f = string.format

local function extensionForMimeType(mimeType)
	if type(mimeType) ~= "string" then return nil end
	for extension, mappedType in pairs(config.mimeByExtension) do
		if mappedType == mimeType then return extension end
	end
	return nil
end

local function inferExtension(url, name, mimeType)
	local extension = helpers.extname(name)
	if extension then return extension end
	local cleanURL = type(url) == "string" and url:match("^[^%?#]+") or nil
	extension = cleanURL and cleanURL:match("%.([^.\\/]+)$")
	if extension then return extension:lower() end
	return extensionForMimeType(mimeType) or "bin"
end

local function downloadBytes(url)
	if not url then return nil, nil, "missing url" end
	local attempts = {}
	local authHeaders = helpers.isDiscordAttachmentUrl(url) and {{"Authorization", client._api._token}} or nil
	helpers.insert(attempts, {url = url, headers = authHeaders})
	if authHeaders then helpers.insert(attempts, {url = url}) end

	for _, attempt in ipairs(attempts) do
		local ok, response, body = pcall(request, "GET", attempt.url, attempt.headers)
		if ok and response and response.code and response.code < 300 and type(body) == "string" then
			local headers = helpers.headerMap(response)
			return body, headers["content-type"], nil
		end
	end

	return nil, nil, "download failed"
end

local function assetFilename(messageID, index, originalName)
	return helpers.sanitizeFilename(f("%s-%03d-%s", messageID, index, originalName or "attachment"))
end

local function captureRemoteAsset(session, spec)
	local key = tostring(spec.key)
	if session.assets[key] then
		session.assets[key].used = true
		return session.assets[key]
	end

	local bytes, contentType, err = downloadBytes(spec.url)
	local mimeType = helpers.guessMimeType(spec.originalName or spec.filename, spec.contentType or spec.mimeType or contentType)
	local filename = spec.filename
	if not filename or filename == "" then
		filename = helpers.sanitizeFilename((spec.baseName or "asset") .. "." .. inferExtension(spec.url, spec.originalName or spec.filename, mimeType))
	else
		filename = helpers.sanitizeFilename(filename)
	end

	local filePath = helpers.pathJoin(session.tempDir, filename)
	local size = spec.size or (bytes and #bytes or 0)
	local asset = {
		key = key,
		kind = spec.kind or "asset",
		messageID = spec.messageID,
		filename = filename,
		originalName = spec.originalName or filename,
		path = filePath,
		size = size,
		mimeType = mimeType,
		spoiler = spec.spoiler or false,
		width = spec.width,
		height = spec.height,
		description = spec.description,
		archived = bytes ~= nil,
		error = err,
		url = spec.url,
		used = true,
	}

	if bytes then
		writeFileSync(filePath, bytes)
		-- transcripts embed every asset inline, so build a data URI for all archived bytes
		asset.dataURI = f("data:%s;base64,%s", asset.mimeType, encodeBase64(bytes))
		if asset.mimeType:match("^image/") then
			asset.inlinePreview = asset.dataURI
		end
	end

	asset.isImage = helpers.isImageAttachment(asset)
	asset.isVideo = helpers.isVideoAttachment(asset)
	asset.isAudio = helpers.isAudioAttachment(asset)

	-- track CDN download outcome and volume per asset kind (attachment/avatar/asset)
	local kind = asset.kind or "asset"
	if bytes then
		metrics.counter("voicemanager_overseer_assets_total", 1, {kind = kind, outcome = "archived"})
		metrics.counter("voicemanager_overseer_asset_bytes_total", #bytes, {kind = kind})
	else
		metrics.counter("voicemanager_overseer_assets_total", 1, {kind = kind, outcome = "failed"})
	end

	session.assets[key] = asset
	helpers.insert(session.assetOrder, asset)
	return asset
end

local function captureAttachment(session, messageID, attachment, index)
	local originalName = attachment.filename or attachment.name or f("attachment-%d", index)
	return captureRemoteAsset(session, {
		key = attachment.id or f("%s:%d", messageID, index),
		kind = "attachment",
		messageID = messageID,
		url = attachment.url or attachment.proxy_url or attachment.proxyURL,
		filename = assetFilename(messageID, index, originalName),
		originalName = originalName,
		size = attachment.size,
		contentType = attachment.content_type or attachment.contentType,
		spoiler = attachment.spoiler or tostring(originalName):match("^SPOILER_") ~= nil,
		width = attachment.width,
		height = attachment.height,
		description = attachment.description,
		allowInlinePreview = true,
	})
end

local assets = {}

function assets.captureAttachments(session, messageID, attachments)
	local captured = {}
	for index, attachment in ipairs(attachments or {}) do
		helpers.insert(captured, captureAttachment(session, messageID, attachment, index))
	end
	return captured
end

function assets.captureUserAvatar(session, user)
	local avatarURL = user and user.avatarURL
	if type(avatarURL) ~= "string" or avatarURL == "" then return nil end
	local userID = tostring(user.id or "unknown")
	local extension = inferExtension(avatarURL, nil, "image/png")
	return captureRemoteAsset(session, {
		key = f("avatar:%s:%s", userID, avatarURL),
		kind = "avatar",
		url = avatarURL,
		filename = f("avatar-%s.%s", userID, extension),
		originalName = f("avatar-%s.%s", userID, extension),
		allowInlinePreview = true,
	})
end

return assets