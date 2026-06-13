local json = require "json"

local helpers = require "overseer/helpers"
local static = require "overseer/htmlStatic"
local template = require "overseer/template"

local f = string.format
local strings = template.STRINGS
local copy = static.copy

local function encodeJson(value)
	local ok, encoded = pcall(json.encode, value)
	return ok and encoded or "{}"
end

local function sortSources(sourcesByID)
	local sources = {}
	for _, source in pairs(sourcesByID or {}) do
		helpers.insert(sources, source)
	end
	table.sort(sources, function (left, right)
		return tostring(left.name) < tostring(right.name)
	end)
	return sources
end

local function countArchivedAssets(session)
	local total = 0
	for _, asset in ipairs(session.assetOrder or {}) do
		if asset.used and asset.archived then total = total + 1 end
	end
	return total
end

local function pageStats(entries)
	local stats = {messages = 0, edits = 0, deletes = 0, events = 0}
	for _, entry in ipairs(entries or {}) do
		if entry.type == "message" then
			if entry.action == "create" then
				stats.messages = stats.messages + 1
			elseif entry.action == "update" then
				stats.edits = stats.edits + 1
			else
				stats.deletes = stats.deletes + 1
			end
		else
			stats.events = stats.events + 1
		end
	end
	return stats
end

local function renderDataList(items)
	local blocks = {'<dl class="detail-list">'}
	for _, item in ipairs(items or {}) do
		if item.value and item.value ~= "" then
			helpers.insert(blocks, f('<div><dt>%s</dt><dd>%s</dd></div>', helpers.escapeHtml(item.label), item.value))
		end
	end
	helpers.insert(blocks, '</dl>')
	return helpers.concat(blocks)
end

local function renderTechnicalPanel(summary, items, extraContent, className)
	local content = {}
	if items and items[1] then
		helpers.insert(content, renderDataList(items))
	end
	if extraContent and extraContent ~= "" then
		helpers.insert(content, extraContent)
	end
	if #content == 0 then return "" end
	local modifier = className and className ~= "" and (' ' .. className) or ''
	return f('<span class="meta%s"><button type="button" class="meta-trigger">%s</button><span class="meta-popover"><span class="meta-popover-title">%s</span>%s</span></span>', modifier, helpers.escapeHtml(summary), helpers.escapeHtml(summary), helpers.concat(content))
end

local function sourceChip(kind, name)
	return f('<span class="source %s">#%s</span>', helpers.sourceClass(kind), helpers.escapeHtml(name or copy.deletedChannel))
end

local function renderSourceChannel(source)
	local items = {
		{label = 'Channel ID', value = helpers.escapeHtml(source.id)},
		{label = 'Category', value = helpers.escapeHtml(source.categoryName or copy.noCategory)},
	}
	if source.position ~= nil then
		helpers.insert(items, {label = 'Position', value = helpers.escapeHtml(source.position)})
	end
	helpers.insert(items, {label = 'Surface', value = helpers.escapeHtml(source.kind)})
	return f('<span class="meta source-meta"><button type="button" class="meta-trigger">%s</button><span class="meta-popover"><span class="meta-popover-title">%s</span>%s</span></span>',
		sourceChip(source.kind, source.name), helpers.escapeHtml(copy.channelDetails), renderDataList(items))
end

local function renderAvatar(user)
	local label = user and (user.tag or user.name or copy.unknownUser) or copy.unknownUser
	local avatar = user and user.avatar
	if avatar and avatar.archived and user.id and (avatar.inlinePreview or avatar.filename) then
		return f('<div class="avatar-frame avatar-photo avatar-u%s" role="img" aria-label="%s"></div>', helpers.escapeHtml(user.id), helpers.escapeHtml(label))
	end
	return f('<div class="avatar-frame avatar-fallback">%s</div>', helpers.userInitial(user))
end

local function collectAvatarStyles(entries)
	local seen, blocks = {}, {}
	local function visit(user)
		local avatar = user and user.avatar
		local id = user and user.id
		if not (avatar and avatar.archived and id) then return end
		if seen[id] then return end
		local source = avatar.dataURI or avatar.inlinePreview or (avatar.filename and ('./' .. avatar.filename))
		if not source then return end
		seen[id] = true
		helpers.insert(blocks, f('.avatar-u%s{background-image:url("%s")}', helpers.escapeHtml(id), source))
	end
	for _, entry in ipairs(entries or {}) do
		if entry.message then
			visit(entry.message.author)
			visit(entry.message.referencedAuthor)
		end
		visit(entry.user)
	end
	if #blocks == 0 then return '' end
	return '<style>' .. helpers.concat(blocks) .. '</style>'
end

local function renderSidebar(session, entries, pageIndex, pageCount)
	local stats = pageStats(entries)
	local sourceBlocks = {}
	for _, source in ipairs(sortSources(session.sources)) do
		helpers.insert(sourceBlocks, renderSourceChannel(source))
	end

	local overview = renderDataList({
		{label = 'Server', value = helpers.escapeHtml(session.guildName)},
		{label = 'Time zone', value = helpers.escapeHtml('UTC' .. helpers.formatOffset(session.logTimeOffset))},
		{label = 'Page', value = helpers.escapeHtml(f('%d of %d', pageIndex, pageCount))},
		{label = 'Entries on page', value = helpers.escapeHtml(#entries)},
		{label = 'Archived files', value = helpers.escapeHtml(countArchivedAssets(session))},
	})

	local activity = renderDataList({
		{label = 'Messages', value = helpers.escapeHtml(stats.messages)},
		{label = 'Edits', value = helpers.escapeHtml(stats.edits)},
		{label = 'Deletes', value = helpers.escapeHtml(stats.deletes)},
		{label = 'Other events', value = helpers.escapeHtml(stats.events)},
	})

	return helpers.concat({
		'<aside class="sidebar">',
		'<section class="sidebar-card sidebar-hero">',
		f('<h2>%s</h2>', helpers.escapeHtml(copy.sourceChannelsTitle)),
		f('<div class="chip-stack">%s</div>', helpers.concat(sourceBlocks, ' ')),
		'</section>',
		'<section class="sidebar-card">',
		f('<h2>%s</h2>', helpers.escapeHtml(copy.overviewTitle)),
		overview,
		'</section>',
		'<section class="sidebar-card">',
		f('<h2>%s</h2>', helpers.escapeHtml(copy.pageProfileTitle)),
		activity,
		'</section>',
		'</aside>',
	})
end

local function actionLabel(action)
	if action == 'create' then return copy.sentLabel end
	if action == 'update' then return copy.editedLabel end
	if action == 'delete' then return copy.deletedLabel end
	return copy.eventLabel
end

local function actionClass(action)
	if action == 'create' then return 'action-create' end
	if action == 'update' then return 'action-update' end
	if action == 'delete' then return 'action-delete' end
	return 'action-event'
end

local function renderAttachmentDetails(asset)
	local items = {
		{label = 'Type', value = helpers.escapeHtml(asset.mimeType or 'unknown')},
		{label = 'Size', value = helpers.escapeHtml(helpers.formatBytes(asset.size))},
	}
	if asset.width and asset.height then
		helpers.insert(items, {label = 'Dimensions', value = helpers.escapeHtml(f('%sx%s', asset.width, asset.height))})
	end
	if asset.spoiler then
		helpers.insert(items, {label = 'Spoiler', value = 'Yes'})
	end
	return renderTechnicalPanel(copy.fileDetails, items, nil, 'meta-inline')
end

local function renderAttachmentPreview(asset, title)
	if asset.isImage then
		local src = asset.dataURI or asset.inlinePreview
		if src then
			return f('<img class="attachment-image" src="%s" alt="%s">', src, title)
		end
		return f('<img class="attachment-image" src="./%s" alt="%s" loading="lazy">', helpers.escapeHtml(asset.filename), title)
	end
	if asset.isVideo then
		return f('<video class="attachment-video" controls preload="metadata" src="%s"></video>', asset.dataURI or ('./' .. helpers.escapeHtml(asset.filename)))
	end
	if asset.isAudio then
		return f('<audio class="attachment-audio" controls preload="metadata" src="%s"></audio>', asset.dataURI or ('./' .. helpers.escapeHtml(asset.filename)))
	end
	return f('<div class="attachment-placeholder">%s</div>', helpers.escapeHtml(copy.archivedFile))
end

local function renderAttachments(attachments)
	if not attachments or not attachments[1] then return '' end
	local blocks = {'<section class="attachment-stack">'}
	for _, asset in ipairs(attachments) do
		local title = helpers.escapeHtml(asset.originalName or asset.filename)
		if asset.archived then
			helpers.insert(blocks, '<figure class="attachment">')
			helpers.insert(blocks, '<div class="attachment-preview">')
			helpers.insert(blocks, renderAttachmentPreview(asset, title))
			helpers.insert(blocks, '</div>')
			helpers.insert(blocks, f('<figcaption><a class="attachment-name" href="%s" download="%s">%s</a></figcaption>', asset.dataURI or ('./' .. helpers.escapeHtml(asset.filename)), title, title))
			if asset.description then
				helpers.insert(blocks, f('<div class="attachment-description">%s</div>', helpers.renderText(asset.description)))
			end
			helpers.insert(blocks, renderAttachmentDetails(asset))
			helpers.insert(blocks, '</figure>')
		else
			helpers.insert(blocks, f('<div class="attachment attachment-missing"><strong>%s</strong><p class="muted">Archive copy unavailable%s</p></div>', title, asset.error and (': ' .. helpers.escapeHtml(asset.error)) or ''))
		end
	end
	helpers.insert(blocks, '</section>')
	return helpers.concat(blocks)
end

local function renderEmbedDetails(embed)
	local blocks = {}
	if embed.fields and embed.fields[1] then
		helpers.insert(blocks, '<div class="embed-fields">')
		for _, field in ipairs(embed.fields) do
			helpers.insert(blocks, f('<div class="embed-field"><div class="embed-field-name">%s</div><div class="embed-field-value">%s</div></div>', helpers.escapeHtml(field.name), helpers.renderText(field.value)))
		end
		helpers.insert(blocks, '</div>')
	end

	local links = {}
	if embed.image and embed.image.url then
		helpers.insert(links, f('<a href="%s">Embed image</a>', helpers.escapeHtml(embed.image.url)))
	elseif embed.thumbnail and embed.thumbnail.url then
		helpers.insert(links, f('<a href="%s">Embed thumbnail</a>', helpers.escapeHtml(embed.thumbnail.url)))
	end
	if links[1] then
		helpers.insert(blocks, f('<div class="embed-links">%s</div>', helpers.concat(links, ' ')))
	end

	if embed.footer and embed.footer.text then
		helpers.insert(blocks, f('<p class="embed-footer">%s</p>', helpers.escapeHtml(embed.footer.text)))
	end

	return renderTechnicalPanel(copy.embedDetails, nil, helpers.concat(blocks), 'meta-inline')
end

local function renderEmbeds(embeds)
	if not embeds or not embeds[1] then return '' end
	local blocks = {'<section class="embed-stack">'}
	for _, embed in ipairs(embeds) do
		local heading = embed.title or (embed.author and embed.author.name) or copy.embedLabel
		helpers.insert(blocks, '<section class="embed">')
		if embed.author and embed.author.name and embed.title then
			helpers.insert(blocks, f('<div class="embed-author">%s</div>', helpers.escapeHtml(embed.author.name)))
		end
		if embed.url and embed.title then
			helpers.insert(blocks, f('<div class="embed-title"><a href="%s">%s</a></div>', helpers.escapeHtml(embed.url), helpers.escapeHtml(heading)))
		else
			helpers.insert(blocks, f('<div class="embed-title">%s</div>', helpers.escapeHtml(heading)))
		end
		if embed.description then
			helpers.insert(blocks, f('<div class="embed-description">%s</div>', helpers.renderText(embed.description)))
		end
		helpers.insert(blocks, renderEmbedDetails(embed))
		helpers.insert(blocks, '</section>')
	end
	helpers.insert(blocks, '</section>')
	return helpers.concat(blocks)
end

local function componentLabel(component)
	if component.emoji and component.emoji.name then
		return component.label and (component.emoji.name .. ' ' .. component.label) or component.emoji.name
	end
	return component.label or component.placeholder or component.custom_id or component.customId or 'component'
end

local function componentStyle(style)
	if style == 1 then return 'primary' end
	if style == 2 then return 'secondary' end
	if style == 3 then return 'success' end
	if style == 4 then return 'danger' end
	if style == 5 then return 'link' end
	return 'secondary'
end

local function renderComponent(component)
	if component.content then
		return f('<div class="component-copy">%s</div>', helpers.renderText(component.content))
	end
	if component.components then
		local row = {'<div class="component-row">'}
		for _, nested in ipairs(component.components) do
			helpers.insert(row, renderComponent(nested))
		end
		helpers.insert(row, '</div>')
		return helpers.concat(row)
	end
	if component.style or component.label or component.custom_id or component.customId then
		return f('<span class="component-pill %s">%s</span>', componentStyle(component.style), helpers.escapeHtml(componentLabel(component)))
	end
	if component.options then
		return f('<span class="component-pill secondary">%s (%d options)</span>', helpers.escapeHtml(component.placeholder or componentLabel(component)), #component.options)
	end
	return renderTechnicalPanel(copy.rawComponent, nil, f('<pre class="raw-block">%s</pre>', helpers.escapeHtml(encodeJson(component))), 'meta-inline')
end

local function renderComponents(components)
	if not components or not components[1] then return '' end
	local blocks = {'<div class="component-stack">'}
	for _, component in ipairs(components) do
		helpers.insert(blocks, renderComponent(component))
	end
	helpers.insert(blocks, '</div>')
	return renderTechnicalPanel(f(copy.interactiveComponents, #components), nil, helpers.concat(blocks), 'meta-inline meta-wide')
end

local function renderReactions(reactions)
	if not reactions or not reactions[1] then return '' end
	local chips = {'<div class="reactions">'}
	for _, reaction in ipairs(reactions) do
		helpers.insert(chips, f('<span class="reaction-chip">%s <strong>%s</strong></span>', helpers.escapeHtml(reaction.emoji), helpers.escapeHtml(reaction.count)))
	end
	helpers.insert(chips, '</div>')
	return f('<section class="support-block"><div class="support-label">%s</div>%s</section>', helpers.escapeHtml(copy.reactionsLabel), helpers.concat(chips))
end

local function renderMessageDetails(entry, message, session)
	local items = {
		{label = 'Message ID', value = helpers.escapeHtml(message.id or entry.messageID or 'unknown')},
		{label = 'Author ID', value = helpers.escapeHtml(message.author and message.author.id or 'unknown')},
		{label = 'Channel', value = helpers.escapeHtml(message.sourceChannelName or 'deleted-channel')},
		{label = 'Surface', value = helpers.escapeHtml(message.sourceKind or 'room')},
		{label = 'Logged at', value = helpers.escapeHtml(helpers.formatTimestamp(entry.timestamp, session.logTimeOffset))},
	}
	if type(message.createdAt) == 'number' then
		helpers.insert(items, {label = 'Created at', value = helpers.escapeHtml(helpers.formatTimestamp(message.createdAt, session.logTimeOffset))})
	end
	if type(message.editedAt) == 'number' then
		helpers.insert(items, {label = 'Edited at', value = helpers.escapeHtml(helpers.formatTimestamp(message.editedAt, session.logTimeOffset))})
	end
	if message.referencedMessageID then
		helpers.insert(items, {label = 'Reply target', value = helpers.escapeHtml(message.referencedMessageID)})
	end
	if message.pinned then
		helpers.insert(items, {label = 'Pinned', value = 'Yes'})
	end
	if message.attachments and message.attachments[1] then
		helpers.insert(items, {label = 'Attachment count', value = helpers.escapeHtml(#message.attachments)})
	end
	return renderTechnicalPanel(copy.messageDetails, items, nil, nil)
end

local function truncatePreview(text, limit)
	text = tostring(text or ''):gsub('%s+', ' ')
	text = text:gsub('^%s+', ''):gsub('%s+$', '')
	if text == '' then return '' end
	if #text <= limit then return text end
	return text:sub(1, limit - 1) .. '...'
end

local function messagePreviewText(message)
	if not message then return nil end
	local preview = truncatePreview(message.content, 120)
	if preview ~= '' then return preview end
	if message.attachments and message.attachments[1] then return '[attachment]' end
	if message.embeds and message.embeds[1] then return '[embed]' end
	return nil
end

local function renderReferenceBar(messageID, messageIndex, fallbackAuthor, locationIndex, currentFile)
	if not messageID then return '' end
	local message = messageIndex and messageIndex[messageID]
	local author = (message and message.author) or fallbackAuthor
	local name = author and (author.tag or author.name or copy.unknownUser) or copy.otherMessage
	local preview = message and messagePreviewText(message)
	local previewHtml
	if preview then
		previewHtml = f('<span class="reply-bar-text">%s</span>', helpers.escapeHtml(preview))
	elseif message then
		previewHtml = f('<span class="reply-bar-text muted">%s</span>', helpers.escapeHtml(copy.noPreview))
	else
		previewHtml = f('<span class="reply-bar-text muted">%s</span>', helpers.escapeHtml(copy.referenceUnavailable))
	end
	local inner = helpers.concat({
		'<span class="reply-bar-spine"></span>',
		author and renderAvatar(author) or '',
		f('<span class="reply-bar-name">%s</span>', helpers.escapeHtml(name)),
		previewHtml,
	})
	local targetFile = locationIndex and locationIndex[messageID]
	local prefix = (targetFile and targetFile ~= currentFile) and helpers.escapeHtml(targetFile) or ''
	return f('<a class="reply-bar" href="%s#msg-%s">%s</a>', prefix, helpers.escapeHtml(messageID), inner)
end

local function renderRow(opts)
	local idAttr = opts.id and f(' id="msg-%s"', helpers.escapeHtml(opts.id)) or ''
	local classes = 'entry ' .. opts.entryClass
	if opts.ephemeral then classes = classes .. ' entry-ephemeral' end
	local name = opts.titleOverride or (opts.user and (opts.user.tag or opts.user.name or copy.unknownUser)) or copy.unknownUser
	local row = {
		f('<article class="%s"%s>', classes, idAttr),
		opts.referenceBar or '',
		'<div class="entry-row">',
		renderAvatar(opts.user),
		f('<strong class="entry-name">%s</strong>', helpers.escapeHtml(name)),
	}
	if opts.badge then
		helpers.insert(row, f('<span class="action-badge %s">%s</span>', opts.badgeClass or 'action-event', helpers.escapeHtml(opts.badge)))
	end
	if opts.ephemeral then
		helpers.insert(row, f('<span class="action-badge action-ephemeral">%s</span>', helpers.escapeHtml(copy.ephemeralLabel)))
	end
	if opts.inline and opts.inline ~= '' then
		helpers.insert(row, f('<span class="event-copy">%s</span>', opts.inline))
	end
	helpers.insert(row, '<span class="entry-spacer"></span>')
	helpers.insert(row, f('<time class="entry-time">%s</time>', helpers.escapeHtml(opts.timestamp)))
	helpers.insert(row, sourceChip(opts.sourceKind, opts.sourceName))
	if opts.meta and opts.meta ~= '' then helpers.insert(row, opts.meta) end
	helpers.insert(row, '</div>')
	if opts.body and opts.body ~= '' then
		helpers.insert(row, f('<div class="entry-body">%s</div>', opts.body))
	end
	helpers.insert(row, '</article>')
	return helpers.concat(row)
end

local function renderMessageEntry(entry, session, messageIndex, locationIndex, currentFile)
	local message = entry.message
	if not message then
		local meta = renderTechnicalPanel(copy.messageDetails, {
			{label = 'Message ID', value = helpers.escapeHtml(entry.messageID or 'unknown')},
			{label = 'Channel', value = helpers.escapeHtml(entry.sourceChannelName or copy.deletedChannel)},
			{label = 'Surface', value = helpers.escapeHtml(entry.sourceKind or 'room')},
		}, nil, 'meta-inline')
		return renderRow{
			entryClass = 'entry-' .. entry.action,
			id = entry.messageID,
			titleOverride = copy.unavailableMessage,
			badge = actionLabel(entry.action),
			badgeClass = actionClass(entry.action),
			timestamp = helpers.formatTimestamp(entry.timestamp, session.logTimeOffset),
			sourceKind = entry.sourceKind,
			sourceName = entry.sourceChannelName,
			meta = meta,
			body = f('<p class="message-text muted">%s</p>', helpers.escapeHtml(copy.noMessageMetadata)),
		}
	end

	local bodyParts = {
		f('<div class="message-text">%s</div>', helpers.renderText(message.content)),
		renderAttachments(message.attachments),
		renderEmbeds(message.embeds),
		renderComponents(message.components),
		renderReactions(message.reactions),
	}
	local badge = entry.action ~= 'create' and actionLabel(entry.action) or nil
	return renderRow{
		entryClass = 'entry-' .. entry.action,
		id = message.id,
		ephemeral = message.ephemeral,
		referenceBar = message.referencedMessageID and renderReferenceBar(message.referencedMessageID, messageIndex, message.referencedAuthor, locationIndex, currentFile) or '',
		user = message.author,
		badge = badge,
		badgeClass = badge and actionClass(entry.action) or nil,
		timestamp = helpers.formatTimestamp(entry.timestamp, session.logTimeOffset),
		sourceKind = message.sourceKind,
		sourceName = message.sourceChannelName,
		meta = renderMessageDetails(entry, message, session),
		body = helpers.concat(bodyParts),
	}
end

local function renderReactionEntry(entry, session, messageIndex, locationIndex, currentFile)
	local details = renderTechnicalPanel(copy.reactionDetails, {
		{label = 'User ID', value = helpers.escapeHtml(entry.user.id)},
		{label = 'Message ID', value = helpers.escapeHtml(entry.messageID or 'unknown')},
		{label = 'Emoji', value = helpers.escapeHtml(entry.emoji)},
		{label = 'Channel', value = helpers.escapeHtml(entry.sourceChannelName or copy.deletedChannel)},
		{label = 'Surface', value = helpers.escapeHtml(entry.sourceKind or 'room')},
		{label = 'Logged at', value = helpers.escapeHtml(helpers.formatTimestamp(entry.timestamp, session.logTimeOffset))},
	}, nil, 'meta-inline')

	local verb = entry.action == 'add' and 'Added' or 'Removed'
	local inline = f('<span class="emoji">%s</span> %s a reaction', helpers.escapeHtml(entry.emoji), verb)
	return renderRow{
		entryClass = 'entry-event',
		user = entry.user,
		inline = inline,
		referenceBar = entry.messageID and renderReferenceBar(entry.messageID, messageIndex, nil, locationIndex, currentFile) or '',
		timestamp = helpers.formatTimestamp(entry.timestamp, session.logTimeOffset),
		sourceKind = entry.sourceKind,
		sourceName = entry.sourceChannelName,
		meta = details,
	}
end

local function renderInteractionEntry(entry, session, messageIndex, locationIndex, currentFile)
	local details = renderTechnicalPanel(copy.interactionDetails, {
		{label = 'User ID', value = helpers.escapeHtml(entry.user.id)},
		{label = 'Message ID', value = helpers.escapeHtml(entry.messageID or 'unknown')},
		{label = 'Custom ID', value = helpers.escapeHtml(entry.customID or 'interaction')},
		{label = 'Channel', value = helpers.escapeHtml(entry.sourceChannelName or copy.deletedChannel)},
		{label = 'Surface', value = helpers.escapeHtml(entry.sourceKind or 'room')},
		{label = 'Logged at', value = helpers.escapeHtml(helpers.formatTimestamp(entry.timestamp, session.logTimeOffset))},
	}, nil, 'meta-inline')

	local label = entry.action == 'modal' and copy.modalInteraction or copy.componentInteraction
	return renderRow{
		entryClass = 'entry-event',
		user = entry.user,
		inline = f('%s was triggered', helpers.escapeHtml(label)),
		referenceBar = entry.messageID and renderReferenceBar(entry.messageID, messageIndex, nil, locationIndex, currentFile) or '',
		timestamp = helpers.formatTimestamp(entry.timestamp, session.logTimeOffset),
		sourceKind = entry.sourceKind,
		sourceName = entry.sourceChannelName,
		meta = details,
	}
end

local function renderChannelEntry(entry, session)
	local details = renderTechnicalPanel(copy.channelDetails, {
		{label = 'Channel ID', value = helpers.escapeHtml(entry.sourceChannelID or 'unknown')},
		{label = 'Surface', value = helpers.escapeHtml(entry.sourceKind or 'room')},
		{label = 'Logged at', value = helpers.escapeHtml(helpers.formatTimestamp(entry.timestamp, session.logTimeOffset))},
	}, nil, 'meta-inline')

	local inline
	if entry.oldName and entry.oldName ~= '' then
		inline = f('Renamed from <strong>#%s</strong> to <strong>#%s</strong>', helpers.escapeHtml(entry.oldName), helpers.escapeHtml(entry.sourceChannelName))
	else
		inline = f('Renamed to <strong>#%s</strong>', helpers.escapeHtml(entry.sourceChannelName))
	end

	return renderRow{
		entryClass = 'entry-event',
		titleOverride = copy.channelEventTitle,
		inline = inline,
		timestamp = helpers.formatTimestamp(entry.timestamp, session.logTimeOffset),
		sourceKind = entry.sourceKind,
		sourceName = entry.sourceChannelName,
		meta = details,
	}
end

local function renderEntry(entry, session, messageIndex, locationIndex, currentFile)
	if entry.type == 'message' then return renderMessageEntry(entry, session, messageIndex, locationIndex, currentFile) end
	if entry.type == 'reaction' then return renderReactionEntry(entry, session, messageIndex, locationIndex, currentFile) end
	if entry.type == 'interaction' then return renderInteractionEntry(entry, session, messageIndex, locationIndex, currentFile) end
	if entry.type == 'channel' then return renderChannelEntry(entry, session) end
	return ''
end

local function renderMainHeader(session)
	return helpers.concat({
		'<header class="main-header">',
		f('<h2>%s</h2>', helpers.escapeHtml(session.roomName)),
		'</header>',
	})
end

local function renderHtmlPage(session, entries, pageIndex, pageCount, messageIndex, locationIndex, currentFile)
	local blocks = {
		'<!DOCTYPE html>',
		'<html lang="en">',
		'<head>',
		'<meta charset="utf-8">',
		f('<title>%s transcript</title>', helpers.escapeHtml(session.roomName)),
		'<meta name="viewport" content="width=device-width, initial-scale=1">',
		static.style,
		collectAvatarStyles(entries),
		'</head>',
		'<body>',
		'<div class="layout">',
		renderSidebar(session, entries, pageIndex, pageCount),
		'<main class="main-panel">',
		renderMainHeader(session),
		'<section class="entries">',
	}

	for _, entry in ipairs(entries) do
		helpers.insert(blocks, renderEntry(entry, session, messageIndex, locationIndex, currentFile))
	end

	helpers.insert(blocks, '</section>')
	helpers.insert(blocks, '</main>')
	helpers.insert(blocks, '</div>')
	helpers.insert(blocks, '</body>')
	helpers.insert(blocks, '</html>')
	return helpers.concat(blocks, '\n')
end

local function sortedEntries(session)
	local entries = helpers.clone(session.entries)
	table.sort(entries, function (left, right)
		if left.timestamp == right.timestamp then
			return left.sequence < right.sequence
		end
		return left.timestamp < right.timestamp
	end)
	return entries
end

local function sliceEntries(entries, first, last)
	local slice = {}
	for index = first, last do
		helpers.insert(slice, entries[index])
	end
	return slice
end

local function partitionEntries(session, entries, budget, messageIndex)
	local probe = renderHtmlPage(session, entries, 1, 1, messageIndex)
	if #probe <= budget or #entries <= 1 then
		return {entries}
	end

	local midpoint = math.floor(#entries / 2)
	local parts = partitionEntries(session, sliceEntries(entries, 1, midpoint), budget, messageIndex)
	local remainder = partitionEntries(session, sliceEntries(entries, midpoint + 1, #entries), budget, messageIndex)
	for _, page in ipairs(remainder) do
		helpers.insert(parts, page)
	end
	return parts
end

local function buildMessageIndex(entries)
	local index = {}
	for _, entry in ipairs(entries or {}) do
		if entry.type == 'message' and entry.message and entry.message.id then
			index[entry.message.id] = entry.message
		end
	end
	return index
end

local function pageFileName(base, pageIndex, pageCount)
	local suffix = pageCount == 1 and '' or f('-part-%d', pageIndex)
	return base .. suffix .. '.html'
end

-- maps every message id to the page file that will contain it, so reference
-- bars can link across split transcript pages
local function buildLocationIndex(pages, base)
	local index = {}
	for pageIndex, pageEntries in ipairs(pages) do
		local file = pageFileName(base, pageIndex, #pages)
		for _, entry in ipairs(pageEntries) do
			if entry.type == 'message' then
				local id = entry.message and entry.message.id or entry.messageID
				if id then index[id] = file end
			end
		end
	end
	return index
end

local html = {}

-- filename label uses the room id plus host tag so transcripts don't collide
-- when two rooms happen to share the same display name
local function transcriptBase(session)
	local label = tostring(session.id or session.roomName or 'transcript')
	if session.hostTag and session.hostTag ~= '' then
		label = label .. ' - ' .. session.hostTag
	end
	return helpers.sanitizeFilename(label .. '-transcript')
end

function html.buildHtmlFiles(session, budget)
	local entries = sortedEntries(session)
	local messageIndex = buildMessageIndex(entries)
	local pages = partitionEntries(session, entries, budget, messageIndex)
	local base = transcriptBase(session)
	local locationIndex = buildLocationIndex(pages, base)
	local files = {}
	for index, pageEntries in ipairs(pages) do
		local name = pageFileName(base, index, #pages)
		local page = renderHtmlPage(session, pageEntries, index, #pages, messageIndex, locationIndex, name)
		helpers.insert(files, {
			name = name,
			content = page,
			size = #page,
		})
	end
	return files, #entries
end

return html