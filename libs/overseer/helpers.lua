local config = require "overseer/config"

local fs = require "fs"
local pathjoin = require "pathjoin"

local existsSync = fs.existsSync
local mkdirSync = fs.mkdirSync
local unlinkSync = fs.unlinkSync
local rmdirSync = fs.rmdirSync
local scandirSync = fs.scandirSync
local statSync = fs.statSync
local pathJoin = pathjoin.pathJoin
local splitPath = pathjoin.splitPath

local concat, insert, sort = table.concat, table.insert, table.sort
local f = string.format

local helpers = {}

local function safeUserCall(user, methodName, ...)
	local method = user and user[methodName]
	if type(method) ~= "function" then return nil end
	local ok, value = pcall(method, user, ...)
	if ok and type(value) == "string" and value ~= "" then return value end
	return nil
end

function helpers.clone(value)
	if type(value) ~= "table" then return value end
	local copy = {}
	for index, nested in ipairs(value) do
		copy[index] = helpers.clone(nested)
	end
	for key, nested in pairs(value) do
		if type(key) ~= "number" or key < 1 or key > #value or key % 1 ~= 0 then
			copy[key] = helpers.clone(nested)
		end
	end
	return copy
end

function helpers.ensureDirectory(path)
	if existsSync(path) then return end
	local current
	for _, part in ipairs(splitPath(path)) do
		current = current and pathJoin(current, part) or part
		if not existsSync(current) then mkdirSync(current) end
	end
end

function helpers.removeTree(path)
	if not path or not existsSync(path) then return end
	for name, fileType in scandirSync(path) do
		local fullPath = pathJoin(path, name)
		if fileType == "directory" then
			helpers.removeTree(fullPath)
		else
			unlinkSync(fullPath)
		end
	end
	rmdirSync(path)
end

-- total size in bytes of everything under path, recursively; 0 if absent
function helpers.directorySize(path)
	if not path or not existsSync(path) then return 0 end
	local total = 0
	for name, fileType in scandirSync(path) do
		local fullPath = pathJoin(path, name)
		if fileType == "directory" then
			total = total + helpers.directorySize(fullPath)
		else
			local stat = statSync(fullPath)
			if stat then total = total + (stat.size or 0) end
		end
	end
	return total
end

function helpers.escapeHtml(text)
	if text == nil then return "" end
	text = tostring(text)
	text = text:gsub("&", "&amp;")
	text = text:gsub("<", "&lt;")
	text = text:gsub(">", "&gt;")
	text = text:gsub('"', "&quot;")
	text = text:gsub("'", "&#39;")
	return text
end

function helpers.renderText(text)
	text = helpers.escapeHtml(text or "")
	if text == "" then return '<span class="muted">No message text</span>' end
	return text:gsub("\n", "<br>")
end

function helpers.sanitizeFilename(name)
	name = tostring(name or "asset")
	name = name:gsub("[\r\n\t]", " ")
	name = name:gsub("[\\/:*?\"<>|#%c]", "_")
	name = name:gsub("%s+", "_")
	name = name:gsub("_+", "_")
	name = name:gsub("^_+", "")
	name = name:gsub("_+$", "")
	if name == "" then name = "asset" end
	if #name > 120 then
		local ext = name:match("(%.[^%.]+)$")
		if ext and #ext < 24 then
			name = name:sub(1, 120 - #ext) .. ext
		else
			name = name:sub(1, 120)
		end
	end
	return name
end

function helpers.extname(name)
	if not name then return nil end
	local ext = name:match("%.([^.]+)$")
	return ext and ext:lower() or nil
end

function helpers.guessMimeType(name, fallback)
	if type(fallback) == "string" and fallback ~= "" then return fallback end
	local ext = helpers.extname(name)
	return ext and config.mimeByExtension[ext] or "application/octet-stream"
end

function helpers.isImageAttachment(asset)
	if not asset then return false end
	if asset.mimeType and asset.mimeType:match("^image/") then return true end
	local ext = helpers.extname(asset.filename or asset.originalName)
	return ext and config.imageExtensions[ext] or false
end

function helpers.isVideoAttachment(asset)
	return asset and asset.mimeType and asset.mimeType:match("^video/") ~= nil
end

function helpers.isAudioAttachment(asset)
	return asset and asset.mimeType and asset.mimeType:match("^audio/") ~= nil
end

function helpers.formatBytes(size)
	size = tonumber(size) or 0
	if size < 1024 then return f("%d B", size) end
	if size < 1024 * 1024 then return f("%.1f KB", size / 1024) end
	if size < 1024 * 1024 * 1024 then return f("%.2f MB", size / 1024 / 1024) end
	return f("%.2f GB", size / 1024 / 1024 / 1024)
end

function helpers.formatOffset(offsetMinutes)
	offsetMinutes = tonumber(offsetMinutes) or 0
	local sign = offsetMinutes < 0 and "-" or "+"
	offsetMinutes = math.abs(offsetMinutes)
	local hours = math.floor(offsetMinutes / 60)
	local minutes = offsetMinutes % 60
	return f("%s%02d:%02d", sign, hours, minutes)
end

function helpers.formatTimestamp(seconds, offsetMinutes)
	seconds = tonumber(seconds) or os.time()
	offsetMinutes = tonumber(offsetMinutes) or 0
	return f("%s", os.date("!%Y-%m-%d %H:%M:%S", seconds + offsetMinutes * 60))
end

function helpers.headerMap(response)
	local headers = {}
	for _, header in ipairs(response or {}) do
		headers[header[1]:lower()] = header[2]
	end
	return headers
end

function helpers.getUserAvatarURL(user)
	if not user then return nil end
	local directURL = user.avatarURL or user.avatarUrl
	if type(directURL) == "string" and directURL ~= "" then return directURL end
	local avatarURL = safeUserCall(user, "getAvatarURL", 128, "png")
	if avatarURL then return avatarURL end
	directURL = user.defaultAvatarURL
	if type(directURL) == "string" and directURL ~= "" then return directURL end
	return safeUserCall(user, "getDefaultAvatarURL", 128)
end

function helpers.userInitial(user)
	local label = user and (user.name or user.username or user.tag or user.id) or "?"
	label = tostring(label or "?")
	if label == "" then label = "?" end
	return helpers.escapeHtml(label:sub(1, 1):upper())
end

function helpers.snapshotUser(user)
	if not user then
		return {id = "unknown", name = "Unknown user", tag = "Unknown user"}
	end
	local name = tostring(user.name or user.username or user.tag or user.id)
	return {
		id = tostring(user.id or "unknown"),
		name = name,
		tag = tostring(user.tag or name),
		avatarURL = helpers.getUserAvatarURL(user),
	}
end

function helpers.reactionSummary(reactions)
	local items = {}
	for _, reaction in pairs(reactions or {}) do
		insert(items, {
			emoji = reaction.emojiHash,
			count = reaction.count,
		})
	end
	sort(items, function (left, right)
		return tostring(left.emoji) < tostring(right.emoji)
	end)
	return items
end

function helpers.safeChannelName(channel)
	return channel and channel.name or "deleted-channel"
end

function helpers.sourceClass(kind)
	return kind == "companion" and "source-companion" or "source-room"
end

helpers.pathJoin = pathJoin
helpers.concat = concat
helpers.insert = insert

return helpers