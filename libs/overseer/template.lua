return {
	STRINGS = {
		SIDEBAR_EYEBROW = "Transcript archive",
		SIDEBAR_COPY = "A cleaner dark timeline with technical metadata folded into details panels.",
		OVERVIEW_TITLE = "Overview",
		PAGE_PROFILE_TITLE = "Page profile",
		SOURCE_CHANNELS_TITLE = "Source channels",
		ARCHIVE_NOTES_TITLE = "Archive notes",
		ARCHIVE_NOTE = "Media files and cached avatars are archived as sidecar files. Download the transcript attachments into the same folder before opening the HTML if you want local previews to resolve without Discord.",
		MAIN_EYEBROW = "Timeline",
		MAIN_TITLE = "Room activity",
		MAIN_NOTE = "%s entries on this page. Open details panels for IDs, file metadata, and raw interaction payloads.",
	},

	STYLE = [[<style>
		:root {
			color-scheme: dark;
			--bg: #14181f;
			--paper: #1b212b;
			--paper-strong: #222938;
			--ink: #edf3ff;
			--muted: #98a6c0;
			--border: rgba(166, 182, 208, 0.16);
			--line: rgba(138, 157, 187, 0.22);
			--line-strong: #84cbb8;
			--accent: #77d8c4;
			--accent-soft: rgba(119, 216, 196, 0.14);
			--danger: #ff9f97;
			--danger-soft: rgba(255, 159, 151, 0.14);
			--update: #e8cb7c;
			--update-soft: rgba(232, 203, 124, 0.15);
			--shadow: 0 24px 42px rgba(0, 0, 0, 0.34);
		}
		* { box-sizing: border-box; }
		body {
			margin: 0;
			background:
				radial-gradient(circle at top, rgba(58, 83, 121, 0.34) 0, transparent 26rem),
				linear-gradient(180deg, #10141a 0%, var(--bg) 100%);
			color: var(--ink);
			font: 15px/1.6 "Trebuchet MS", "Segoe UI", sans-serif;
		}
		a {
			color: #8ecbff;
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
			background: rgba(27, 33, 43, 0.94);
			border: 1px solid var(--border);
			border-radius: 28px;
			box-shadow: var(--shadow);
			backdrop-filter: blur(10px);
		}
		.sidebar-card {
			padding: 1.15rem 1.2rem;
		}
		.sidebar-hero {
			background: linear-gradient(180deg, rgba(37, 46, 61, 0.98) 0%, rgba(29, 35, 46, 0.98) 100%);
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
			border: 1px solid rgba(166, 182, 208, 0.12);
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
			background: rgba(255, 255, 255, 0.05);
		}
		.source-room { background: rgba(95, 122, 245, 0.14); }
		.source-companion { background: rgba(120, 219, 169, 0.12); }
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
			padding: 0.35rem 0.35rem 1rem 1.8rem;
		}
		.main-header h2 {
			margin-top: 0.2rem;
			font-size: 1.5rem;
		}
		.entries {
			position: relative;
			display: grid;
			gap: 1rem;
			padding-left: 1.8rem;
		}
		.entries::before {
			content: "";
			position: absolute;
			left: 0.58rem;
			top: 0.35rem;
			bottom: 0.35rem;
			width: 1px;
			background: linear-gradient(180deg, transparent 0%, var(--line) 6%, var(--line) 94%, transparent 100%);
		}
		.entry {
			display: grid;
			grid-template-columns: 1rem minmax(0, 1fr);
			gap: 1rem;
			align-items: start;
		}
		.entry-marker {
			position: relative;
			width: 0.95rem;
			height: 0.95rem;
			margin-top: 1.15rem;
			border-radius: 999px;
			border: 1px solid var(--line-strong);
			background: var(--paper);
			box-shadow: 0 0 0 6px rgba(20, 24, 31, 0.95);
			z-index: 1;
		}
		.entry-shell {
			padding: 1rem 1rem 0.95rem;
			background: rgba(27, 33, 43, 0.96);
			border: 1px solid var(--border);
			border-radius: 24px;
			box-shadow: var(--shadow);
		}
		.entry-delete .entry-shell {
			background: rgba(52, 34, 38, 0.96);
			border-color: rgba(255, 159, 151, 0.18);
		}
		.entry-delete .entry-marker { border-color: var(--danger); }
		.entry-update .entry-shell {
			background: rgba(49, 43, 29, 0.96);
			border-color: rgba(232, 203, 124, 0.18);
		}
		.entry-update .entry-marker { border-color: var(--update); }
		.entry-event .entry-shell {
			background: rgba(30, 37, 48, 0.96);
		}
		.entry-header {
			display: flex;
			gap: 0.9rem;
			align-items: flex-start;
		}
		.avatar-frame {
			width: 2.8rem;
			height: 2.8rem;
			border-radius: 50%;
			overflow: hidden;
			flex: none;
			display: grid;
			place-items: center;
			border: 1px solid rgba(142, 203, 255, 0.18);
			background: linear-gradient(135deg, #395988 0%, #2aa386 100%);
			color: #fff;
			font-weight: 700;
		}
		.avatar-image {
			width: 100%;
			height: 100%;
			object-fit: cover;
			display: block;
		}
		.entry-headline {
			min-width: 0;
			flex: 1;
		}
		.headline-top {
			display: flex;
			flex-wrap: wrap;
			gap: 0.55rem;
			align-items: center;
		}
		.headline-top strong {
			font-size: 1rem;
		}
		.headline-meta {
			margin-top: 0.2rem;
			display: flex;
			flex-wrap: wrap;
			gap: 0.5rem;
			align-items: center;
			color: var(--muted);
			font-size: 0.92rem;
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
		.action-event { background: rgba(152, 166, 192, 0.12); color: #b9c6dd; }
		.entry-body {
			margin-top: 0.9rem;
			display: grid;
			gap: 0.85rem;
		}
		.message-text, .event-copy {
			word-break: break-word;
		}
		.reply-context {
			padding-left: 0.85rem;
			border-left: 2px solid var(--line);
			color: var(--muted);
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
			background: #0f141a;
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
			background: rgba(255, 255, 255, 0.03);
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
			border: 1px solid var(--border);
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
			background: rgba(255, 255, 255, 0.04);
			border: 1px solid var(--border);
		}
		.component-stack, .component-row {
			display: flex;
			flex-wrap: wrap;
			gap: 0.5rem;
		}
		.component-copy {
			padding: 0.7rem 0.85rem;
			border-radius: 14px;
			background: rgba(255, 255, 255, 0.03);
			border: 1px solid var(--border);
		}
		.component-pill {
			display: inline-flex;
			align-items: center;
			padding: 0.4rem 0.7rem;
			border-radius: 999px;
			background: rgba(255, 255, 255, 0.05);
			border: 1px solid var(--border);
		}
		.component-pill.primary { background: rgba(95, 122, 245, 0.18); border-color: rgba(95, 122, 245, 0.24); }
		.component-pill.secondary { background: rgba(255, 255, 255, 0.05); }
		.component-pill.success { background: rgba(40, 143, 93, 0.18); border-color: rgba(40, 143, 93, 0.24); }
		.component-pill.danger { background: rgba(173, 69, 69, 0.18); border-color: rgba(173, 69, 69, 0.24); }
		.component-pill.link { background: rgba(40, 87, 144, 0.18); border-color: rgba(40, 87, 144, 0.24); }
		details {
			border: 1px solid var(--border);
			border-radius: 16px;
			background: rgba(255, 255, 255, 0.03);
		}
		details > summary {
			cursor: pointer;
			list-style: none;
			padding: 0.78rem 0.9rem;
			font-weight: 700;
			color: var(--accent);
			display: flex;
			align-items: center;
			gap: 0.5rem;
		}
		details > summary::-webkit-details-marker { display: none; }
		details > summary::after {
			content: "+";
			margin-left: auto;
			font-size: 1rem;
			color: var(--muted);
		}
		details[open] > summary::after { content: "-"; }
		.technical-panel-inline {
			margin-top: 0.7rem;
		}
		.raw-block {
			margin: 0.1rem 0 0;
			padding: 0.85rem 0.9rem;
			background: rgba(255, 255, 255, 0.03);
			border-top: 1px solid var(--border);
			border-radius: 0 0 16px 16px;
			white-space: pre-wrap;
			word-break: break-word;
			overflow: auto;
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
				border-radius: 22px;
			}
			.main-header {
				padding-left: 1.35rem;
			}
			.entries {
				padding-left: 1.35rem;
			}
			.entries::before {
				left: 0.45rem;
			}
			.entry {
				grid-template-columns: 0.8rem minmax(0, 1fr);
				gap: 0.8rem;
			}
			.entry-shell {
				padding: 0.9rem;
			}
			.avatar-frame {
				width: 2.45rem;
				height: 2.45rem;
			}
		}
		</style>]],
}