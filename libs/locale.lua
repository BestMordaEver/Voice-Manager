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
Select a lobby with `%prefix%select <lobby ID or name>` to change it's settings]],
		[[Enter a matchmaking lobby to be moved to a channel in lobby's matchmaking pool
Select a lobby with `%prefix%select <lobby ID or name>` to change it's settings]],
		[[Companion chats are created and deleted along rooms. Chat is visible only to inhabitants of the room
Companion chats are enabled with `%prefix%lobbies companion`
Select a lobby with `%prefix%select <lobby ID or name>` to change it's settings]],
		"Most room commands are used by a room host - user who created the room. Those commands can be enabled by admins",
		"Most chat commands are used by a room host - user who created the room and its chat. Those commands can be enabled by admins","",""
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
			"%prefix%lobbies",
			"%prefix%lobbies add <channel ID or name>",
			"%prefix%lobbies remove <lobby ID or name>",
			"%prefix%lobbies category <category ID or name>",
			"%prefix%lobbies name <new room name>",
			"%prefix%lobbies capacity <0-99>",
			"%prefix%lobbies bitrate <8-96>",
			"%prefix%lobbies companion enable/disable",
			"%prefix%lobbies permissions <permission> [permission] allow/deny",
			"%prefix%lobbies role <role mention>"
		},
		{
			"%prefix%matchmaking",
			"%prefix%matchmaking add <channel ID or name>",
			"%prefix%matchmaking remove <lobby ID or name>",
			"%prefix%matchmaking target <lobby or category ID or name>",
			"%prefix%matchmaking mode <mode>"
		},
		{
			"%prefix%companions",
			"%prefix%companions category <category ID or name>",
			"%prefix%companions name <new companion name>",
			"%prefix%companions greeting <greeting text>",
			"%prefix%companions log <log channel>",
		},
		{
			"%prefix%room",
			"%prefix%room rename <new name>",
			"%prefix%room resize <0-99>",
			"%prefix%room bitrate <8-96>",
			"%prefix%room mute/unmute <user mention>",
			"%prefix%room kick <user mention>",
			"%prefix%room blocklist add/remove <user mention>",
			"%prefix%room reservations add/remove <user mention>",
			"%prefix%room reservations lock",
			"%prefix%room blocklist/reservations clear",
			"%prefix%room promote <user mention>",
			"%prefix%room host",
			"%prefix%room invite [user mention]"
		},
		{
			"%prefix%chat",
			"%prefix%chat rename <new name>",
			"%prefix%chat mute/unmute <user mention>",
			"%prefix%chat hide/show <user mention>",
			"%prefix%chat clear [amount]"
		},
		{
			"%prefix%server",
			"%prefix%server role <role mention>",
			"%prefix%server limit <0-500>",
			"%prefix%server permissions <permission> [permission] allow/deny",
			"%prefix%server prefix <new prefix>"
		},
		{
			"%prefix%help [lobbies/matchmaking/companions/room/chat/server/other]",
			"%prefix%invite or %prefix%support",
			"%prefix%select <lobby or category ID or name>",
			"%prefix%reset <command> <subcommand>",
			"%prefix%create voice/text <1-50> <name>",
			"%prefix%create voice/text <start index> <end index> <name>",
			"%prefix%delete voice/text top/bottom <1-50> [force]"
		}
	},

	helpFieldValues = {
		[0] = {
			"Setup and configure lobbies - `%prefix%lobbies`",
			"Setup and configure matchmaking in lobbies or normal channels - `%prefix%matchmaking`",
			"Configure companion chats (see `Lobby commands` first) - `%prefix%companions`",
			"Allow users to moderate and configure their rooms - `%prefix%room`",
			"Allow users to moderate and configure their private chats - `%prefix%chat`",
			"Additional settings like prefix - `%prefix%server`",
			"Different helpful commands for users and administrators"
		},
		{
			"Show current lobbies",
			"Add a new lobby",
			"Remove an existing lobby",
			"Select a category in which rooms will be created. By default, rooms are created in the same category as the lobby",
			[[Configure what name a room will have when it's created
Default name is `%nickname's% room`
You can put different `%combos%` in the name to customize it
`%name%` - user's name
`%nickname%` - user's nickname (name is used if nickname is not set)
`%name's%`, `%nickname's%` - corresponding combo with **'s** or **'** attached (difference between **Riddles's** and **Riddles'**)
`%tag%` - user's tag (for example **Riddles#2773**)
`%game%` - user's currently played game (**no game** if user's not playing anything)
`%game(text)%` - same as %game%, but shows **text** instead of **no game**
`%counter%` - room position. Keeps rooms ordered
`%rename%` - blank when room is created. When host uses `%prefix%room rename`, gets replaced by host's input]],
			"Select new rooms' capacity. By default, capacity will be copied over from the lobby",
			"Select new rooms' bitrate. By default, bitrate will be copied over from the lobby. This setting respect server boost status, so you may want to try bigger numbers",
			"Create text chats along the new rooms, that are visible only for room's inhabitants. Chat will be deleted along the room",
			[[Give room hosts' access to different commands
`rename` - allows use of `%prefix%room rename` and `%prefix%chat rename`
`resize` - allows use of `%prefix%room resize`
`bitrate` - allows use of `%prefix%room bitrate`
`manage` - all of the above, plus gives host **Manage Channels** permission in their room
`mute` - allows use of `%prefix%room mute/unmute` and `%prefix%chat mute/unmute`
`moderate` - same as `mute`, plus gives host **Move Members** permission in their room, `%prefix%room kick`, `%prefix%room block/reserve` and `%prefix%chat hide/show`]],
			"Change the default role that's used to inflict restrictions in room and chat commands. Default is @everyone",
		},
		{
			"Show current matchmaking lobbies",
			"Add a new matchmaking lobby",
			"Remove an existing matchmaking lobby",
			[[Select a target for matchmaking pool
**If target is a lobby**, then matchmaking pool is rooms that are created by that lobby. If no room is available, a new one is created using that lobby's settings
**If target is a category**, then matchmaking pool is its voice channels. If no channel is available, user is kicked from matchmaking lobby]],
			[[Select the matchmaking mode. All modes respect channel capacity and blocklists/reservations
`random` - selects a random available channel
`max` - selects a most filled channel
`min` - selects a least filled channel
`first` - selects the first available channel
`last` - selects the last available channel]],
		},
		{
			"Show all lobies that have companion chats enabled",
			"Select a category in which chats will be created",
			[[Configure what name a chat will have when it's created and customize it with %combos% similarly to `%prefix%lobbies name`. Default is `private-chat`
Text chat names have default formatting enforced by Discord, name template will be automatically converted to conform to it]],
			[[Configure a message that will be automatically sent to chat when it's created
You can put different `%combos%` in the name to customize it
`%roomname%` - name of the room chat belongs to
`%chatname%` - name of the chat
`%commands%` - formatted list of `%prefix%room` and `%prefix%chat` commands
`%roomcommands%` - raw list of `%prefix%room` commands
`%chatcommands%` - raw list of `%prefix%chat` commands
`%nickname%`, `%name%`, `%tag%`, `%nickname's%`, `%name's%` - similar to `%prefix%lobbies name`]],
			"Enable chat logging. Logs will be sent as files to a channel of your choosing"
		},
		{
			"Show room info and available commands",
			[[Change room name
❗Changes to channel names are ratelimited to 2 per 10 minutes❗]],
			"Change room capacity",
			"Change room bitrate. This command respects server boost status, check if you can use higher bitrates",
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
			[[Delete messages in the chat
By default, deletes all messages]]
		},
		{
			"Show server info",
			"Change the default role that's used to inflict restrictions in room and chat commands. Default is @everyone",
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
			[[Reset any setting to its default value
Example: `%prefix%reset companions greeting`]],
			[[🛠 Command is temporarily disabled 🛠
Create a certain amount of channels in selected category
Use `%counter%` to include channel number in the name]],
			[[🛠 Command is temporarily disabled 🛠
Create a certain amount of channels in selected category
`%counter%` will be sequentially replaced with numbers between start and end index]],
			[[🛠 Command is temporarily disabled 🛠
Delete a certain amount of empty channels in selected category starting from the top/bottom
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
**Managed role:** %s
**Lobbies:** %d
**Active users:** %d
**Channels:** %d
**Limit:** %d]],

	limitBadInput = "Limit must be a number between 0 and 500",
	limitConfirm = "New limit set!",
	limitReset = "Limit is reset to 500",
	roleBadInput = "Couldn't find the specified role",
	roleConfirm = "New managed role set!",
	roleReset = "Managed role is reset to @everyone",
	prefixConfirm = "New prefix set: %s",
	prefixReset = "Prefix is reset to `vm!`",

	-- lobbies
	lobbiesInfoTitle = "Lobbies info | %s",
	lobbiesNoInfo = [[There are no registered lobbies
You can add a lobby with `%prefix%lobbies add`]],
	lobbiesInfo = "Select lobbies to change their settings",
	lobbiesField = [[**Target category:** %s
**Name template:** %s
**Permissions:** %s
**Managed role:** %s
**Capacity:** %s
**Companion:** %s
**Channels:** %d]],

	addConfirm = "Added new lobby %s",
	removeConfirm = "Removed lobby %s",
	capacityOOB = "Capacity must be a number between 0 and 99",
	capacityConfirm = "Changed capacity to %d",
	capacityReset = "Capacity is reset, rooms will copy capacity from their lobby",
	bitrateOOB = "Bitrate must be a number between 8 and 96",
	bitrateOOB1 = "Bitrate must be a number between 8 and 128",
	bitrateOOB2 = "Bitrate must be a number between 8 and 256",
	bitrateOOB3 = "Bitrate must be a number between 8 and 384",
	bitrateConfirm = "Changed bitrate to %d",
	categoryConfirm = "Changed lobby's target category to %s",
	categoryReset = "Category is reset to default",
	companionToggle = "Companion chats are now %sd for this lobby",
	nameConfirm = "Changed name to %s",
	permissionsBadInput = "Unknown permission: %s",
	permissionsConfirm = "New permissions set!",
	permissionsReset = "All permissions were disabled!",

	-- matchmaking
	matchmakingInfoTitle = "Matchmaking info | %s",
	matchmakingNoInfo = [[There are no registered matchmaking lobbies
You can create a matchmaking lobby with `%prefix%matchmaking add`]],
	matchmakingField = [[**Target:** %s
**Mode:** %s
**Matchmaking pool:** %d channels]],

	matchmakingAddConfirm = "Added new matchmaking lobby %s",
	matchmakingRemoveConfirm = "Removed matchmaking lobby %s",
	targetConfirm = "Changed matchmaking target to %s",
	targetReset = "Matchmaking target is reset, lobby will matchmake for its current category",
	modeBadInput = "Unknown matchmaking mode: %s",
	modeConfirm = "Changed matchmaking mode to %s",

	-- companion
	companionsInfoTitle = "Companion settings | %s",
	companionsNoInfo = [[There are no lobbies with enabled companion channels
You can enable companion channels with `%prefix%lobbies companion enable`]],
	companionsField = [[**Category:** %s
**Name:** %s
**Logging:** %s
**Greeting:**
%s]],

	greetingConfirm = "Set new greeting!",
	greetingReset = "Disabled the greeting",
	roomCommands = "Available `%prefix%room` commands: ",
	chatCommands = "Available `%prefix%chat` commands: ",
	logConfirm = "Chat logs will be sent to %s",
	logReset = "Disabled the chatlogs",
	logName = "`%s` room of `%s` lobby\n",
	loggerWarning = "\n\n*This text chat will be logged*",
	pastebinError = "`%s` room of `%s` lobby\nThere was an issue with pastebin, notify devs if this persists",

	-- room
	roomInfoTitle = "Room info | %s",
	roomInfo = [[**Reserved:** %s
**Blocked:** %s
**Muted:** %s

**Available commands:** %s]],
	notInRoom = "You can't use this command outside of a room",
	none = "none",
	muteConfirm = "Muted %s",
	unmuteConfirm = "Unmuted %s",
	kickConfirm = "Kicked %s",
	blockConfirm = "Blocked %s",
	unblockConfirm = "Unblocked %s",
	reserveConfirm = "Added %s to reservations",
	unreserveConfirm = "Removed %s from reservations",
	inviteConfirm = "Invited %s",
	hostConfirm = "Promoted %s to host",
	badNewHost = "Can't promote users outside of the room",
	hostIdentify = "%s is a room host",
	badHost = "Can't identify the host",

	-- chat
	chatInfoTitle = "Room info | %s",
	chatInfo = [[**Visible to:** %s
**Hidden from:** %s
**Muted:** %s

**Available commands:** %s]],
	noCompanion = "Your room doesn't have companion chat",
	hideConfirm = "Chat is now hidden from %s",
	showConfirm = "Chat is now visible to %s",
	clearConfirm = "Deleted %d messages",

	notHost = "You're not a channel host",
	badHostPermission = "You're not permitted to perform this command",
	hostError = "Bot wasn't able to perform this action. Contact your administrators if issue persists",

	-- select
	selectFailed = "Couldn't find a lobby or category",
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
	unfinishedCommand = "🛠 Command is temporarily disabled 🛠",

	ratelimitRemaining = "This command is ratelimited. You can do this **1** more time in next **%s**",
	ratelimitReached = "This command is ratelimited. You will be able to perform this command after **%s**",

	-- errors
	lobbyDupe = "This channel is already registered as a lobby",
	channelDupe = "Can't register a room as a lobby",
	badBotPermissions = "Bot doesn't have sufficient permissions",
	badUserPermissions = "You don't have sufficient permissions",
	badSubcommand = "Unknown subcommand",
	noLobbySelected = "You didn't select a lobby",
	noCategorySelected = "You didn't select a category",
	badChannel = "Couldn't find the specified channel",
	badCategory = "Couldn't find the specified category",
	badType = "Unknown channel type",
	amountNotANumber = "Channels amount must be a number between 1 and 50",
	amountOOB = "There can be only 50 channels per category",
	emptyName = "Given input will result in an empty name",
	noParent = "unknown lobby",

	error = "*%s*\nThis issue was reported the moment it occured. Contact us if you need additional help - https://discord.gg/tqj6jvT",
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