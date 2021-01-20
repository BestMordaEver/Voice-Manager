-- a static storage for everything the bot displays as text to user
-- may be used as a foundation for translation

return {
	-- help
	helpTitle = {
		[0] = "Help | Table of contents",
		"Help | Lobby commands",
		"Help | Matchmaking commands",
		"Help | Companion commands",
		"Help | Room commands",
		"Help | Chat commands",
		"Help | Server commmands",
		"Help | Other commands"
	},
	
	helpDescription = {
		[0] = "",[[Enter a lobby to create a room. Room is deleted once it's empty
Select a lobby with `vm!select <lobby ID or name>` to change it's settings]],
		[[Enter a matchmaking lobby to be moved to a channel in lobby's matchmaking pool
Select a lobby with `vm!select <lobby ID or name>` to change it's settings]],
		[[Companion chats are created and deleted along rooms. Chat is visible only to inhabitants of the room
Companion chats are enabled with `vm!lobbies companion`
Select a lobby with `vm!select <lobby ID or name>` to change it's settings]],
		"Most room commands are used by a room host - user who created the room. Those commands can be enabled by admins",
		"Most chat commands are used by a room host - user who created the room and its chat. Those commands can be enabled by admins","","",
	},
	
	helpFieldNames = {
		[0] = {
			"Lobby commands - 1️⃣",
			"Matchmaking commands - 2️⃣",
			"Companion commands - 3️⃣",
			"Room commands - 4️⃣",
			"Chat commands - 5️⃣",
			"Server commands - 6️⃣",
			"Other commands - 7️⃣",
		},
		{
			"vm!lobbies",
			"vm!lobbies add <channel ID or name>",
			"vm!lobbies remove <lobby ID or name>",
			"vm!lobbies category <category ID or name>",
			"vm!lobbies name <new room name>",
			"vm!lobbies capacity <0-99>",
			"vm!lobbies bitrate <8-96>",
			"vm!lobbies companion enable/disable",
			"vm!lobbies permissions <permission> [permission] allow/deny"
		},
		{
			"vm!matchmaking",
			"vm!matchmaking add <channel ID or name>",
			"vm!matchmaking remove <lobby ID or name>",
			"vm!matchmaking target <lobby or category ID or name>",
			"vm!matchmaking mode <mode>"
		},
		{
			"vm!companions",
			"vm!companions category <category ID or name>",
			"vm!companions name <new companion name>",
		},
		{
			"vm!room",
			"vm!room rename <new name>",
			"vm!room resize <0-99>",
			"vm!room bitrate <8-96>",
			"vm!room mute/unmute <user mention>",
			"vm!room kick <user mention>",
			"vm!room block add/remove <user mention>",
			"vm!room reserve add/remove <user mention>",
			"vm!room reserve lock",
			"vm!room block/reserve clear",
			"vm!room promote <user mention>",
			"vm!room host",
			"vm!room invite [user mention]"
		},
		{
			"vm!chat",
			"vm!chat rename <new name>",
			"vm!chat mute/unmute <user mention>",
			"vm!chat hide/show <user mention>",
			"vm!chat clear"
		},
		{
			"vm!server",
			"vm!server role <role mention or ID>",
			"vm!server limit <0-500>",
			"vm!server permissions <permission> [permission] allow/deny",
			"vm!server prefix <new prefix>"
		},
		{
			"vm!help [lobbies/matchmaking/companions/room/chat/server/other]",
			"vm!invite or vm!support",
			"vm!select <lobby or category ID or name>",
			"vm!create voice/text [top/bottom] <1-50> <name>",
			"vm!delete voice/text top/bottom <1-50> [force]"
		}
	},
	
	helpFieldValues = {
		[0] = {
			"Setup and configure lobbies - `vm!lobbies`",
			"Setup and configure matchmaking in lobbies or normal channels - `vm!matchmaking`",
			"Configure companion chats (see `Lobby commands` first) - `vm!companions`",
			"Allow users to moderate and configure their rooms - `vm!room`",
			"Allow users to moderate and configure their private chats - `vm!chat`",
			"Additional settings like prefix - `vm!server`",
			"Different helpful commands for users and administrators",
		},
		{
			"Show current lobbies",
			"Add a new lobby",
			"Remove an existing lobby",
			"Select a category, in which users' rooms will be created. By default, rooms are created in the same category as the lobby",
			[[Configure what name a room will have when it's created
Default name is `%nickname's% room`

You can put different `%combos%` in the name to customize it
`%name%` - user's name
`%nickname%` - user's nickname (name is used if nickname is not set)
`%name's%`, `%nickname's%` - corresponding combo with **'s** or **'** attached (difference between **Riddles's** and **Riddles'**)
`%tag%` - user's tag (for example **Riddles#2773**)
`%game%` - user's currently played or streamed game (**no game** if user's not playing anything)
`%counter%` - room position. Keeps rooms ordered
`%rename%` - blank by default, but interacts with `vm!room rename`]],
			"Select new rooms' capacity. By default, capacity will be copied over from the lobby",
			"Select new rooms' bitrate. By default, bitrate will be copied over from the lobby",
			"Create text chats along the new rooms, that are visible only for room's inhabitants. Chat will be deleted along the room",
			[[Give rooms' hosts access to different commands
`rename` - allows use of `vm!room rename` and `vm!chat rename`
`resize` - allows use of `vm!room resize`
`bitrate` - allows use of `vm!room bitrate`
`manage` - all of the above, plus gives host **Manage Channels** permission in their room
`mute` - allows use of `vm!room mute/unmute` and `vm!chat mute/unmute`
`moderate` - same as `mute`, plus gives host **Move Members** permission in their room, `vm!room kick`, `vm!room block/reserve` and `vm!chat hide/show`]]
		},
		{
			"Show current matchmaking lobbies",
			"Add a new matchmaking lobby",
			"Remove an existing matchmaking lobby",
			[[Select a target for matchmaking pool
**If target is a lobby**, then matchmaking pool is rooms that are created by that lobby. If no room is available, a new one is created using that lobby's settings
**If target is a category**, then matchmaking pool is its voice channels. If no channel is available, user is kicked from matchmaking lobby]],
			[[Select the matchmaking mode. All modes respect channel capacity and blocklists/reservations
`random` - selects a random available channnel
`max` - selects a most filled channel
`min` - selects a least filled channel
`first` - selects the first available channel
`last` - selects the last available channel]],
		},
		{
			"Show all lobies that have companion enabled",
			"Select a category in which chats will be created",
			[[Configure what name a chat will have when it's created. Default is `private-chat`
Text chat names have default formatting enforced by Discord, name template will be automatically converted to conform to it]]
		},
		{
			"Show room info and available commands",
			[[Change room name
❗Changes to channel names are ratelimited to 2 per 10 minutes❗]],
			"Change room capacity",
			"Change room bitrate",
			"Mute/unmute mentioned users",
			"Kick mentioned users from the room",
			"Add mentioned users to room's blocklist",
			[[Add mentioned users to room's reservations
Room won't let any more people in to ensure reservations]],
			"Add all users that are currently in the room to room's reservations",
			"Clear blocklist/reservations",
			"Transfer host privileges to the mentioned users",
			"Ping current room host",
			[[Send invite to immediately connect to the room
If specific user is mentioned - sends them a DM
If sent by a room host, adds mentioned users to reservations]]
		},
		{
			"Show chat info and available commands",
			[[Change chat room name
Default Discord formatting rules will be applied automatically]],
			"Restrict/allow mentioned users to write in chat",
			[[Hide/show the chat to mentioned users
You can show chat to people that are not in the room]],
			"Fully clear the chat"
		},
		{
			"Show server info",
			"Change the default role that's used to inflict restrictions in room and chat commands. Default is @ everyone",
			[[Set the global limit of channels created by the bot
Discord limits you to 50 channels per category and 500 channels per server]],
			"Acts similarly to lobby permissions and allows use of room commands in *any* voice channel",
			"Change bot's prefix"
		},
		{
			[[Show table of contents for help
You can specify the page to show instead of table of contents]],
			"Send invite to the support server",
			"Select a lobby or a category to change their settings",
			[[Create a certain amount of channels in selected category
Insert `%counter%` to include channel index in the name, include `top` or `bottom` to determine direction]],
			[[Delete a certain amount of empty channels in selected category starting from the top/bottom
If `force` is added in the end, non-empty channels are also deleted]]
		}
	},
	
	helpLinksTitle = "Links",
	helpLinks = [[[Setup Guide](https://github.com/BestMordaEver/Voice-Manager/wiki/Setup-Guide)
[User Guide](https://github.com/BestMordaEver/Voice-Manager/wiki/User-Guide)
[How to find IDs](https://github.com/BestMordaEver/Voice-Manager/wiki/How-to-find-channel-ID)
[Glossary](https://github.com/BestMordaEver/Voice-Manager/wiki/Glossary)
[Support Server](https://discord.gg/tqj6jvT)]],
	
	-- server
	serverInfoTitle = "Server info | %s",
	serverInfo = [[**Prefix:** %s
**Permissions:** %s
**Lobbies:** %d
**Active users:** %d
**Channels:** %d
**Limit:** %d]],
	
	limitBadInput = "Limit must be a number between 0 and 500",
	limitConfirm = "New limit set!",
	roleBadInput = "Couldn't find the specified role",
	roleConfirm = "New managed role set!",
	prefixConfirm = "New prefix set: %s",
	
	-- lobbies
	lobbiesInfoTitle = "Lobbies info | %s",
	lobbiesNoInfo = [[There are no registered lobbies
You can add a lobby with `vm!lobbies add`]],
	lobbiesInfo = "Select lobbies to change their settings",
	lobbiesField = [[**Target category:** %s
**Name template:** %s
**Permissions:** %s
**Capacity:** %s
**Companion:** %s
**Channels:** %d]],
	
	addConfirm = "Added new lobby %s",
	removeConfirm = "Removed lobby %s",
	capacityOOB = "Capacity must be a number between 0 and 99",
	capacityConfirm = "Changed rooms' capacity to %d",
	categoryConfirm = "Changed lobby's target category to %s",
	companionToggle = "Companion chats are now %sd for this lobby",
	nameConfirm = "Name template is %s",
	
	-- matchmaking
	matchmakingInfoTitle = "Matchmaking info | %s",
	matchmakingNoInfo = [[There are not registered matchmaking lobbies
You can create a matchmaking lobby with `match`]],
	matchmakingField = [[**Target:** %s
**Mode:** %s
**Matchmaking pool:** %d channels]],
	
	matchmakingAddConfirm = "Added new matchmaking lobby %s",
	matchmakingRemoveConfirm = "Removed matchmaking lobby %s",
	targetConfirm = "Changed matchmaking target to %s",
	modeBadInput = "Unknown matchmaking mode: %s",
	modeConfirm = "Changed matchmaking mode to %s",
	
	-- companion
	companionInfoTitle = "Companion settings | %s",
	companionNoInfo = [[There are no lobbies with enabled companion channels
You can enable companion channels with `companion`]],
	companionField = [[**Category:** %s
**Name:** %s
**Companion channels:** %d]],
	
	permissionsBadInput = "Unknown permission: %s",
	permissionsConfirm = "New permissions set!",
	
	-- select
	selectVoice = "Selected lobby %s",
	selectCategory = "Selected category %s",
	
	-- utility
	embedPages = "Page %d of %d",
	embedDelete = "❌ - delete this message",
	embedTip = "<> - required, [] - optional",
	embedPage = "Click :page_facing_up: to select the whole page",
	embedAll = "Click :asterisk: to select all available channels",
	embedOK = "✅ OK",
	embedWarning = "⚠ Warning",
	embedError = "❗ Error",
	
	-- name
	changedName = "Successfully changed channel name!",
	ratelimitRemaining = "This command is ratelimited. You can do this **1** more time in next **%s**",
	ratelimitReached = "This command is ratelimited. You will be able to perform this command after **%s**",
	-- resize
	channelResized = "Successfully changed channel capacity!",
	-- bitrate
	changedBitrate = "Successfully changed channel bitrate!",
	-- promote
	newHost = "New host assigned",
	noMember = "No such user in your channel",
	-- list
	noLobbies = "No lobbies registered yet!",
	someLobbies = "Registered lobbies on this server:",
	
	-- errors
	badBotPermissions = "Bot doesn't have sufficient permissions",
	badUserPermissions = "You don't have sufficient permissions",
	badSubcommand = "Unknown subcommand",
	noLobbySelected = "You didn't select a lobby",
	noCategorySelected = "You didn't select a category",
	badChannel = "Couldn't find the specified channel",
	badCategory = "Couldn't find the specified category",
	
	notHost = "You're not a channel host",
	badHostPermission = "You're not permitted to perform this command",
	error = "*%s*\nThe issue was reported and is already being fixed. Contact us if you need additional help - https://discord.gg/tqj6jvT",
	errorReaction = {
		"I'm sowwy",
		"There go my evening plans",
		"Sure did see this one coming",
		"Kinda saw this one coming",
		"Never saw this one coming",
		"Sirens blaring in distance",
		"Is everyone alive?",
		"I sure hope nobody got killed",
		"Ow, my leg",
		"That's why we can't have nice things",
		"Slap a bandaid on, that'll do for now",
		"bonk",
		"This is so sad",
		"insert random pop culture reference here",
		"Now you're just doing this on purpose, don't you?"
	},
}