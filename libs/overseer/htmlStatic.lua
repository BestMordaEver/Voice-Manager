return {
	copy = {
		deletedChannel = "deleted-channel",
		unknownUser = "Unknown user",
		archiveEyebrow = "Transcript archive",
		sidebarSummary = "A lighter timeline view with the dense metadata folded into details panels.",
		overviewTitle = "Overview",
		pageProfileTitle = "Page profile",
		sourceChannelsTitle = "Source channels",
		archiveNotesSummary = "Archive notes",
		archiveNotesBody = "Media files and cached avatars are archived as sidecar files. Download the transcript attachments into the same folder before opening the HTML if you want local previews to resolve without Discord.",
		sentLabel = "Sent",
		editedLabel = "Edited",
		deletedLabel = "Deleted",
		eventLabel = "Event",
		fileDetails = "File details",
		archivedFile = "Archived file",
		embedLabel = "Embed",
		embedDetails = "Embed details",
		rawComponent = "Raw component",
		interactiveComponents = "Components (%d)",
		reactionsLabel = "Reactions",
		messageDetails = "Message details",
		reactionDetails = "Reaction details",
		interactionDetails = "Interaction details",
		voiceDetails = "Voice event details",
		noticeDetails = "Notice details",
		channelDetails = "Channel details",
		channelEventTitle = "Channel",
		noticeTitle = "Notice",
		noCategory = "No category",
		unavailableMessage = "Unavailable message",
		noMessageMetadata = "Message metadata was not cached before it changed.",
		otherMessage = "another message",
		reactionTitle = "Reaction",
		interactionTitle = "Interaction",
		modalInteraction = "Modal interaction",
		componentInteraction = "Component interaction",
		commandInteraction = "Command interaction",
		voiceJoin = "Joined the voice channel",
		voiceLeave = "Left the voice channel",
		ephemeralLabel = "Ephemeral",
		noPreview = "No preview available",
		referenceUnavailable = "Original message unavailable",
		timelineEyebrow = "Timeline",
		timelineTitle = "Room activity",
		timelineNote = "%s entries on this page. Open details panels for IDs, file metadata, and raw interaction payloads.",
	},
	style = [[<style>
		:root {
			color-scheme: dark;
			--bg: #0f1319;
			--bg-glow: #213040;
			--paper: #121820;
			--paper-strong: rgba(21, 28, 38, 0.96);
			--ink: #eef3fb;
			--muted: #95a3bb;
			--border: rgba(148, 163, 184, 0.16);
			--line: rgba(148, 163, 184, 0.22);
			--line-strong: #7fa1c1;
			--accent: #76ddb2;
			--accent-soft: rgba(118, 221, 178, 0.16);
			--danger: #ff9b9b;
			--danger-soft: rgba(255, 155, 155, 0.16);
			--update: #f1ce86;
			--update-soft: rgba(241, 206, 134, 0.16);
			--shadow: 0 14px 32px rgba(0, 0, 0, 0.28);
		}
		* { box-sizing: border-box; }
		body {
			margin: 0;
			background:
				radial-gradient(circle at top left, rgba(33, 48, 64, 0.95) 0%, transparent 28rem),
				radial-gradient(circle at top right, rgba(27, 34, 47, 0.9) 0%, transparent 24rem),
				linear-gradient(180deg, var(--bg) 0%, #0b0f14 100%);
			color: var(--ink);
			font: 15px/1.6 "Trebuchet MS", "Segoe UI", sans-serif;
		}
		a {
			color: #9fd0ff;
			text-decoration: none;
		}
		a:hover { text-decoration: underline; }
		.layout {
			max-width: 1360px;
			margin: 0 auto;
			padding: 1.5rem;
			display: grid;
			grid-template-columns: minmax(280px, 320px) minmax(0, 1fr);
			gap: 1.5rem;
		}
		.sidebar {
			position: sticky;
			top: 1.5rem;
			align-self: start;
			display: grid;
			gap: 1rem;
		}
		.sidebar-card, .main-panel {
			background: rgba(18, 24, 32, 0.86);
			border: 1px solid var(--border);
			border-radius: 16px;
			box-shadow: var(--shadow);
			backdrop-filter: blur(12px);
		}
		.sidebar-card {
			padding: 1.15rem 1.2rem;
			z-index: 0;
		}
		.sidebar-card:focus-within,
		.sidebar-card:has(.meta:hover) { z-index: 1; }
		.sidebar-hero {
			background: linear-gradient(180deg, rgba(31, 40, 53, 0.98) 0%, rgba(18, 24, 32, 0.96) 100%);
		}
		.sidebar-hero h1 {
			margin: 0.2rem 0 0.45rem;
			font-size: 1.9rem;
			line-height: 1.1;
		}
		.sidebar-copy, .sidebar-note p, .main-note, .muted {
			color: var(--muted);
		}
		.eyebrow {
			margin: 0;
			font-size: 0.76rem;
			font-weight: 700;
			letter-spacing: 0.14em;
			text-transform: uppercase;
			color: var(--accent);
		}
		.sidebar-card h2, .main-header h2 {
			margin: 0 0 0.85rem;
			font-size: 1.05rem;
		}
		.chip-stack {
			display: flex;
			flex-wrap: wrap;
			gap: 0.5rem;
		}
		.detail-list {
			margin: 0;
			display: grid;
			gap: 0.75rem;
		}
		.detail-list div {
			padding: 0.7rem 0.8rem;
			background: rgba(255, 255, 255, 0.03);
			border: 1px solid rgba(255, 255, 255, 0.05);
			border-radius: 16px;
		}
		.detail-list dt {
			margin: 0;
			font-size: 0.76rem;
			font-weight: 700;
			letter-spacing: 0.08em;
			text-transform: uppercase;
			color: var(--muted);
		}
		.detail-list dd {
			margin: 0.25rem 0 0;
			word-break: break-word;
		}
		.source {
			display: inline-flex;
			align-items: center;
			padding: 0.22rem 0.58rem;
			border-radius: 999px;
			font-size: 0.82rem;
			border: 1px solid var(--border);
		}
		.source-room {
			background: rgba(95, 122, 245, 0.16);
			color: #cfd9ff;
			border-color: rgba(95, 122, 245, 0.24);
		}
		.source-companion {
			background: rgba(118, 221, 178, 0.14);
			color: #b5f1d9;
			border-color: rgba(118, 221, 178, 0.24);
		}
		.sidebar-details {
			padding: 0;
			overflow: hidden;
		}
		.sidebar-details summary {
			padding: 1.15rem 1.2rem;
		}
		.sidebar-note {
			padding: 0 1.2rem 1rem;
		}
		.main-panel {
			padding: 1rem 1.1rem 1.4rem;
		}
		.main-header {
			padding: 0.35rem 0.5rem 0.85rem;
		}
		.main-header h2 {
			margin-top: 0.2rem;
			font-size: 1.5rem;
		}
		.entries {
			display: grid;
			gap: 0;
		}
		.entry {
			padding: 0.85rem 0.65rem 0.85rem 0.85rem;
			border-top: 1px solid var(--line);
			border-left: 2px solid transparent;
		}
		.entry:first-child { border-top: none; }
		.entry:hover { background: rgba(255, 255, 255, 0.018); }
		.entry-delete { border-left-color: var(--danger); }
		.entry-update { border-left-color: var(--update); }
		.entry-event { border-left-color: var(--line-strong); }
		.entry-ephemeral {
			background: rgba(88, 101, 242, 0.08);
			border-left-color: #5865f2 !important;
		}
		.entry-ephemeral:hover { background: rgba(88, 101, 242, 0.13); }
		.entry-row {
			display: flex;
			flex-wrap: wrap;
			align-items: center;
			gap: 0.4rem 0.6rem;
		}
		.entry-name { font-size: 0.98rem; font-weight: 700; }
		.entry-row .avatar-frame {
			width: 2rem;
			height: 2rem;
		}
		.entry-event .entry-row .avatar-frame {
			width: 1.55rem;
			height: 1.55rem;
			font-size: 0.78rem;
		}
		.entry-spacer { flex: 1 1 auto; }
		.entry-time { color: var(--muted); font-size: 0.86rem; white-space: nowrap; }
		.reply-bar {
			display: flex;
			align-items: center;
			gap: 0.4rem;
			min-width: 0;
			max-width: 100%;
			margin: 0 0 0.3rem 0.5rem;
			color: var(--muted);
			font-size: 0.85rem;
			text-decoration: none;
		}
		.reply-bar:hover { color: var(--ink); }
		.reply-bar:hover .reply-bar-text { color: var(--ink); }
		.reply-bar-spine {
			flex: none;
			align-self: flex-end;
			width: 1.5rem;
			height: 0.7rem;
			margin-bottom: 0.55rem;
			border-left: 2px solid var(--line-strong);
			border-top: 2px solid var(--line-strong);
			border-top-left-radius: 8px;
		}
		.reply-bar .avatar-frame {
			width: 1.15rem;
			height: 1.15rem;
			font-size: 0.62rem;
			border-width: 1px;
		}
		.reply-bar-name { font-weight: 700; color: var(--ink); white-space: nowrap; flex: none; }
		.reply-bar-text {
			min-width: 0;
			overflow: hidden;
			text-overflow: ellipsis;
			white-space: nowrap;
		}
		.avatar-frame {
			width: 2.3rem;
			height: 2.3rem;
			border-radius: 50%;
			overflow: hidden;
			flex: none;
			display: grid;
			place-items: center;
			border: 1px solid rgba(118, 221, 178, 0.2);
			background: linear-gradient(135deg, #355c7d 0%, #6dd5ed 100%);
			color: #fff;
			font-weight: 700;
		}
		.avatar-image {
			width: 100%;
			height: 100%;
			object-fit: cover;
			display: block;
		}
		.avatar-photo {
			background-size: cover;
			background-position: center;
			background-repeat: no-repeat;
		}
		.action-badge {
			display: inline-flex;
			align-items: center;
			padding: 0.16rem 0.55rem;
			border-radius: 999px;
			font-size: 0.78rem;
			font-weight: 700;
			letter-spacing: 0.04em;
			text-transform: uppercase;
		}
		.action-create { background: var(--accent-soft); color: var(--accent); }
		.action-update { background: var(--update-soft); color: var(--update); }
		.action-delete { background: var(--danger-soft); color: var(--danger); }
		.action-event { background: rgba(255, 255, 255, 0.08); color: #ccd5e5; }
		.action-ephemeral { background: rgba(88, 101, 242, 0.22); color: #c2caff; }
		.entry-body {
			margin-top: 0.55rem;
			display: grid;
			gap: 0.6rem;
		}
		.entry-body:empty { display: none; }
		.event-copy {
			color: var(--muted);
			display: inline-flex;
			align-items: center;
			gap: 0.3rem;
			flex-wrap: wrap;
		}
		.message-text, .event-copy {
			word-break: break-word;
		}
		.attachment-stack, .embed-stack {
			display: grid;
			gap: 0.75rem;
		}
		.attachment {
			margin: 0;
			padding: 0.9rem;
			background: rgba(255, 255, 255, 0.03);
			border: 1px solid var(--border);
			border-radius: 18px;
		}
		.attachment-preview img, .attachment-preview video {
			max-width: 100%;
			border-radius: 14px;
			display: block;
			background: #0a0f15;
		}
		.attachment-audio { width: 100%; }
		.attachment-name {
			display: inline-block;
			margin-top: 0.75rem;
			font-weight: 700;
		}
		.attachment-description {
			margin-top: 0.55rem;
			color: var(--muted);
		}
		.attachment-placeholder {
			padding: 0.95rem 1rem;
			border-radius: 14px;
			background: rgba(255, 255, 255, 0.04);
			color: var(--muted);
		}
		.attachment-missing p { margin: 0.45rem 0 0; }
		.embed {
			padding: 0.95rem;
			background: rgba(255, 255, 255, 0.03);
			border: 1px solid var(--border);
			border-radius: 18px;
		}
		.embed-author {
			margin-bottom: 0.3rem;
			font-size: 0.82rem;
			font-weight: 700;
			letter-spacing: 0.04em;
			text-transform: uppercase;
			color: var(--muted);
		}
		.embed-title {
			font-weight: 700;
		}
		.embed-description {
			margin-top: 0.4rem;
			color: var(--muted);
		}
		.embed-fields {
			margin-top: 0.75rem;
			display: grid;
			gap: 0.65rem;
			grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
		}
		.embed-field {
			padding: 0.7rem 0.8rem;
			background: rgba(255, 255, 255, 0.04);
			border-radius: 14px;
		}
		.embed-field-name {
			font-weight: 700;
			margin-bottom: 0.2rem;
		}
		.embed-links {
			margin-top: 0.75rem;
			display: flex;
			flex-wrap: wrap;
			gap: 0.6rem;
		}
		.embed-footer {
			margin: 0.75rem 0 0;
			color: var(--muted);
		}
		.support-block {
			padding: 0.75rem 0.85rem;
			background: rgba(255, 255, 255, 0.03);
			border: 1px solid rgba(255, 255, 255, 0.06);
			border-radius: 16px;
		}
		.support-label {
			font-size: 0.82rem;
			font-weight: 700;
			letter-spacing: 0.04em;
			text-transform: uppercase;
			color: var(--muted);
			margin-bottom: 0.45rem;
		}
		.reactions {
			display: flex;
			flex-wrap: wrap;
			gap: 0.45rem;
		}
		.reaction-chip {
			display: inline-flex;
			gap: 0.35rem;
			align-items: center;
			padding: 0.32rem 0.6rem;
			border-radius: 999px;
			background: rgba(255, 255, 255, 0.05);
			border: 1px solid rgba(255, 255, 255, 0.06);
		}
		.component-stack, .component-row {
			display: flex;
			flex-wrap: wrap;
			gap: 0.5rem;
		}
		.component-copy {
			padding: 0.7rem 0.85rem;
			border-radius: 14px;
			background: rgba(255, 255, 255, 0.04);
			border: 1px solid rgba(255, 255, 255, 0.05);
		}
		.component-pill {
			display: inline-flex;
			align-items: center;
			padding: 0.4rem 0.7rem;
			border-radius: 999px;
			background: rgba(255, 255, 255, 0.06);
			border: 1px solid rgba(255, 255, 255, 0.08);
			max-width: 100%;
			white-space: normal;
			overflow-wrap: anywhere;
		}
		.component-pill.primary { background: rgba(95, 122, 245, 0.16); border-color: rgba(95, 122, 245, 0.22); }
		.component-pill.secondary { background: rgba(255, 255, 255, 0.06); }
		.component-pill.success { background: rgba(118, 221, 178, 0.16); border-color: rgba(118, 221, 178, 0.22); }
		.component-pill.danger { background: rgba(255, 155, 155, 0.16); border-color: rgba(255, 155, 155, 0.22); }
		.component-pill.link { background: rgba(114, 171, 255, 0.16); border-color: rgba(114, 171, 255, 0.22); }
		.meta {
			position: relative;
			display: inline-flex;
		}
		.meta-trigger {
			appearance: none;
			cursor: help;
			border: 1px solid var(--border);
			background: rgba(255, 255, 255, 0.04);
			color: var(--muted);
			font: inherit;
			font-size: 0.74rem;
			letter-spacing: 0.03em;
			padding: 0.08rem 0.55rem;
			border-radius: 999px;
			line-height: 1.5;
			white-space: nowrap;
		}
		.meta-trigger:hover, .meta-trigger:focus-visible {
			color: var(--ink);
			border-color: var(--line-strong);
		}
		.meta-trigger:focus {
			outline: none;
		}
		.meta-popover {
			position: absolute;
			top: calc(100% + 0.45rem);
			left: 0;
			z-index: 30;
			min-width: 240px;
			max-width: 360px;
			padding: 0.85rem;
			background: var(--paper-strong);
			border: 1px solid var(--border);
			border-radius: 14px;
			box-shadow: var(--shadow);
			opacity: 0;
			visibility: hidden;
			transform: translateY(-0.3rem);
			transition: opacity 0.14s ease, transform 0.14s ease, visibility 0.14s;
			pointer-events: none;
		}
		.meta:hover > .meta-popover, .meta:focus-within > .meta-popover {
			opacity: 1;
			visibility: visible;
			transform: translateY(0);
			pointer-events: auto;
		}
		.meta-inline .meta-popover {
			left: auto;
			right: 0;
		}
		.meta-wide .meta-popover {
			min-width: 340px;
			max-width: min(600px, calc(100vw - 2rem));
			width: max-content;
			left: 0;
			right: auto;
		}
		.entry-body > .meta {
			justify-self: start;
		}
		.source-meta .meta-trigger {
			border: none;
			background: none;
			padding: 0;
			cursor: help;
			line-height: inherit;
		}
		.source-meta .meta-trigger:hover, .source-meta .meta-trigger:focus-visible {
			border-color: transparent;
		}
		.meta-popover-title {
			display: block;
			font-size: 0.72rem;
			font-weight: 700;
			letter-spacing: 0.1em;
			text-transform: uppercase;
			color: var(--accent);
			margin-bottom: 0.55rem;
		}
		.meta-popover .detail-list {
			gap: 0.4rem;
		}
		.meta-popover .detail-list div {
			padding: 0.45rem 0.55rem;
			border-radius: 10px;
		}
		.meta-popover .embed-fields {
			margin-top: 0;
		}
		.meta-popover .raw-block {
			max-height: 260px;
			max-width: 320px;
		}
		.raw-block {
			margin: 0;
			padding: 0.7rem 0.8rem;
			background: rgba(255, 255, 255, 0.04);
			border: 1px solid rgba(255, 255, 255, 0.06);
			border-radius: 10px;
			white-space: pre-wrap;
			word-break: break-word;
			overflow: auto;
			font-size: 0.78rem;
		}
		.emoji {
			font-size: 1.05rem;
		}
		@media (max-width: 980px) {
			.layout {
				grid-template-columns: 1fr;
			}
			.sidebar {
				position: static;
			}
		}
		@media (max-width: 640px) {
			body {
				font-size: 14px;
			}
			.layout {
				padding: 0.9rem;
				gap: 1rem;
			}
			.main-panel, .sidebar-card {
				border-radius: 14px;
			}
			.main-header {
				padding-left: 0.5rem;
			}
			.entry {
				padding: 0.75rem 0.4rem 0.75rem 0.7rem;
			}
			.avatar-frame {
				width: 2.1rem;
				height: 2.1rem;
			}
			.meta-popover {
				min-width: 200px;
				max-width: 78vw;
			}
			.meta-wide .meta-popover {
				min-width: min(340px, calc(100vw - 1.4rem));
				max-width: calc(100vw - 1.4rem);
				width: calc(100vw - 1.4rem);
			}
		}
		</style>]],
}