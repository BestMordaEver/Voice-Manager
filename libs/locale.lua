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
		"Help | Server commands",
		"Help | Other commands"
	},

	helpDescription = {
		[0] = "","Enter a lobby to create a room. Room is deleted once it's empty",
		"Enter a matchmaking lobby to be moved to a channel in lobby's matchmaking pool",
		"Companion chats are created and deleted along rooms. Chat is visible only to inhabitants of the room",
		"Most room commands are used by a room host - user who created the room. Those commands can be enabled by admins",
		"Most chat commands are used by a room host - user who created the room and its chat. Those commands can be enabled by admins",
		"Global server settings. Room commands in normal channels can be enabled using these commands",""
	},

	helpFieldNames = {
		[0] = {
			"Lobby commands",
			"Matchmaking commands",
			"Companion commands",
			"Room commands",
			"Chat commands",
			"Other commands",
		},
		{
			"/lobby view",
			"/lobby add",
			"/lobby remove",
			"/lobby category",
			"/lobby name",
			"/lobby capacity",
			"/lobby bitrate",
			"/lobby permissions",
			"/lobby role"
		},
		{
			"/matchmaking view",
			"/matchmaking add",
			"/matchmaking remove",
			"/matchmaking target",
			"/matchmaking mode"
		},
		{
			"/companion view",
			"/companion enable|disable",
			"/companion category",
			"/companion name",
			"/companion greeting",
			"/companion log",
		},
		{
			"/room view",
			"/room rename",
			"/room resize",
			"/room bitrate",
			"/room mute|unmute",
			"/room kick",
			"/room blocklist add|remove|clear",
			"/room reservations add|remove|clear",
			"/room lock",
			"/room password",
			"/room host",
			"/room invite"
		},
		{
			"/chat view",
			"/chat rename",
			"/chat mute|unmute",
			"/chat hide|show",
			"/chat clear"
		},
		{
			"/server view",
			"/server limit",
			"/server permissions",
			"/server role"
		},
		{
			"/help [lobbies|matchmaking|companions|room|chat|other]",
			"/support",
			"/reset <command> <subcommand>",
			"/clone <channel> <amount> [name]",
			"/delete <channel_type> [category] [amount] [name] [only_empty]",
			"/users print <channel|lobby|category> [mode] [separator]",
			"/users give|remove <channel|lobby|category> <role>"
		}
	},

	helpFieldValues = {
		[0] = {
			"Setup and configure lobbies - `/lobby`",
			"Setup and configure matchmaking in lobbies or normal channels - `/matchmaking`",
			"Configure companion chats (see `Lobby commands` first) - `/companion`",
			"Allow users to moderate and configure their rooms - `/room`",
			"Allow users to moderate and configure their private chats - `/chat`",
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
`%rename%` - blank when room is created. When host uses `/room rename`, gets replaced by host's input]],
			"Select new rooms' capacity. By default, capacity will be copied over from the lobby",
			"Select new rooms' bitrate. By default, bitrate will be copied over from the lobby. This setting respect server boost status, so you may want to try bigger numbers",
			[[Give room hosts' access to different commands
`rename` - allows use of `/room rename` and `/chat rename`
`resize` - allows use of `/room resize`
`bitrate` - allows use of `/room bitrate`
`manage` - all of the above, plus gives host **Manage Channels** permission in their room
`mute` - allows use of `/room mute|unmute` and `/chat mute|unmute`
`moderate` - same as `mute`, plus gives host **Move Members** permission in their room, `/room kick`, `/room block|reserve` and `/chat hide|show`]],
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
			"Enable or disable companion chat for selected lobby",
			"Select a category in which chats will be created",
			[[Configure what name a chat will have when it's created and customize it with %combos% similarly to `/lobby name`. Default is `private-chat`
Text chat names have default formatting enforced by Discord, name template will be automatically converted to conform to it]],
			[[Configure a message that will be automatically sent to chat when it's created
You can put different `%combos%` in the greeting to customize it
`%roomname%` - name of the room chat belongs to
`%chatname%` - name of the chat
`%commands%` - formatted list of `/room` and `/chat` commands
`%roomcommands%` - raw list of `/room` commands
`%chatcommands%` - raw list of `/chat` commands
`%nickname%`, `%name%`, `%tag%`, `%nickname's%`, `%name's%` - similar to `/lobby name`]],
			"Enable chat logging. Logs will be sent as files to a channel of your choosing"
		},
		{
			"Show room info and available commands",
			[[Change room name
❗Changes to channel names are ratelimited to 2 per 10 minutes❗]],
			"Change room capacity",
			"Change room bitrate. This command respects server boost status, check if you can use higher bitrates",
			"Mute|unmute mentioned users",
			"Kick mentioned users from the room",
			"Manage room's blocklist",
			[[Manage room's reservations
Room won't let any more people in to ensure reservations]],
			"Locks entry to the room, no new people will be able to join",
			"Users will have to enter the password before connecting to the channel, unless they have a reservation",
			"Ping current room host or transfer host privileges to the mentioned user",
			[[Send invite to immediately connect to the room
If specific user is mentioned - sends them a DM
If sent by a room host, adds mentioned users to reservations]]
		},
		{
			"Show chat info and available commands",
			[[Change chat room name
Default Discord formatting rules will be applied automatically]],
			"Restrict|allow mentioned users to write in chat",
			[[Hide|show the chat to mentioned users
You can show chat to people that are not in the room]],
			[[Delete messages in the chat
By default, deletes all messages]]
		},
		{
			"Show server settings",
			"Set the maximum amount of channels bot will create on the server",
			[[Enable room commands in normal voice channels, similar to `/lobby permissions`
Bot will start deleting user permission overwrites in all channels once this is enabled, use at your own risk!]],
			"Change the default role that's used to inflict restrictions in channels"
		},
		{
			[[Show table of contents for help
You can specify the page to show instead of table of contents]],
			"Send invite to the support server",
			[[Reset any setting to its default value
Example: `/reset companions greeting`]],
			[[Clone a channel. You can add `%counter%` to channel name to make the cloned channels numbered, and `%counter(number)%` to start counting from a specific number
This command will not carry over any permission overrides from the cloned channel - all clones will spawn synced with the parent category]],
			[[Delete several channels. Optionally select several filters - category, name, whether to consider channels with messages (for test) or connected members (for voice).
This command will not immediately delete the selected channels, instead helper tool will appear. Handle with care, since channels are deleted irreversibly!]],
			[[Create a handy list of users in a selected channel.
If selected channel is a lobby, prints users in lobby's rooms or matchmaking pool channels
If category is selected, all it's channels are used]],
			"Give or remove a role to/from users in a selected channel. Selection rules are similar to `/users print`"
		}
	},

	helpLinksTitle = "Links",
	helpLinks = [[[Setup Guide](https://github.com/BestMordaEver/Voice-Manager/wiki/Setup-Guide) | [User Guide](https://github.com/BestMordaEver/Voice-Manager/wiki/User-Guide) | [Glossary](https://github.com/BestMordaEver/Voice-Manager/wiki/Glossary)
[Privacy](https://github.com/BestMordaEver/Voice-Manager/blob/dev/privacy.md) | [ToS](https://github.com/BestMordaEver/Voice-Manager/blob/dev/tos.md)
[Support Server](https://discord.gg/tqj6jvT)]],

	-- server
	serverInfoTitle = "Server info | %s",
	serverInfo = [[**Permissions:** %s
**Managed role:** %s
**Lobbies:** %d
**Active users:** %d
**Channels:** %d
**Room limit:** %d]],

	limitConfirm = "Limit is set to %d",
	roleConfirm = "New managed role set",

	-- lobbies
	lobbiesInfoTitle = "Lobbies info | %s",
	lobbiesNoInfo = [[There are no registered lobbies
You can add a lobby with `/lobby add`]],
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
	capacityConfirm = "Changed capacity to %d",
	capacityReset = "Capacity is reset, rooms will copy capacity from their lobby",
	bitrateOOB = "Bitrate must be a number between 8 and 96",
	bitrateOOB1 = "Bitrate must be a number between 8 and 128",
	bitrateOOB2 = "Bitrate must be a number between 8 and 256",
	bitrateOOB3 = "Bitrate must be a number between 8 and 384",
	bitrateConfirm = "Changed bitrate to %d",
	categoryConfirm = "Changed lobby's target category to %s",
	categoryReset = "Category is reset to default",
	companionEnable = "Companion chats are now enabled for this lobby",
	companionDisable = "Companion chats are now disabled for this lobby",
	nameConfirm = "Changed name to %s",
	permissionsConfirm = "New permissions set",
	permissionsReset = "All permissions were disabled",

	-- matchmaking
	matchmakingInfoTitle = "Matchmaking info | %s",
	matchmakingNoInfo = [[There are no registered matchmaking lobbies
You can create a matchmaking lobby with `/matchmaking add`]],
	matchmakingField = [[**Target:** %s
**Mode:** %s
**Matchmaking pool:** %d channels]],

	matchmakingAddConfirm = "Added new matchmaking lobby %s",
	matchmakingRemoveConfirm = "Removed matchmaking lobby %s",
	targetConfirm = "Changed matchmaking target to %s",
	targetReset = "Matchmaking target is reset, lobby will matchmake for its current category",
	modeConfirm = "Changed matchmaking mode to %s",

	-- companion
	companionsInfoTitle = "Companion settings | %s",
	companionsNoInfo = [[There are no lobbies with enabled companion channels
You can enable companion channels with `/lobby companion enable`]],
	companionsField = [[**Category:** %s
**Name:** %s
**Logging:** %s
**Greeting:**
%s]],

	greetingConfirm = "Set new greeting",
	greetingReset = "Disabled the greeting",
	roomCommands = "Available `/room` commands: ",
	chatCommands = "Available `/chat` commands: ",
	logConfirm = "Chat logs will be sent to %s",
	logReset = "Disabled the chatlogs",
	logName = "`%s` room of `%s` lobby\n",
	loggerWarning = "\n\n*This text chat will be logged*",

	-- room
	roomInfoTitle = "Room info | %s",
	roomInfo = [[**Host:** %s
**Reserved:** %s
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
	blocklistClear = "Blocklist is reset",
	reserveConfirm = "Added %s to reservations",
	unreserveConfirm = "Removed %s from reservations",
	reservationsClear = "Reservations are reset",
	lockConfirm = "Room is now invite only",
	inviteConfirm = "Invited %s",
	hostConfirm = "Promoted %s to host",
	badNewHost = "Can't promote users outside of the room",
	hostIdentify = "%s is a room host",
	badHost = "Can't identify the host",
	passwordConfirm = "Password is set to `%s`",
	passwordReset = "Password is removed",
	passwordCheckText = "This channel is protected by password. Please enter the password to access the channel.",
	passwordEnter = "Enter the password",
	password = "Password",
	passwordNoChannel = "This channel no longer exists",
	passwordSuccess = "Correct password",
	passwordFailure = "Wrong password",
	passwordBanned = "You were banned in this channel!",

	-- chat
	chatInfoTitle = "Room info | %s",
	chatInfo = [[**Host:** %s
**Visible to:** %s
**Hidden from:** %s
**Muted:** %s

**Available commands:** %s]],
	noCompanion = "Your room doesn't have companion chat",
	hideConfirm = "Chat is now hidden from %s",
	showConfirm = "Chat is now visible to %s",
	clearConfirm = "Deleted %d messages",

	notHost = "You're not a channel host",
	badHostPermission = "You're not permitted to perform this command",
	renameError = "Bot wasn't able to change channel name. Contact your administrators if issue persists",
	resizeError = "Bot wasn't able to change channel capacity. Contact your administrators if issue persists",
	bitrateError = "Bot wasn't able to change channel bitrate. Contact your administrators if issue persists",
	inviteError = "Bot wasn't able to create invite. Contact your administrators if issue persists",

	-- create
	createCategoryOverflow = "There can be a maximum of 50 channels per category",
	createConfirm = "Created %d channels",

	-- delete
	deleteForm = "You're about to delete %d channels! This action is irreversible, so please review your selection and press all the keys before nuking the channels",
	deleteNotArmed = "Press all the keys first!",
	deleteNone = "No channels matched your selection parameters",
	deleteProcessing = "Processing...",
	deleteConfirm = "Deleted %d channels",

	-- users
	noChildChannels = "This lobby doesn't have children channels",
	usersSent = "Sent users list",
	usersRolesAdded = "Given the role to %d users",
	usersRolesRemoved = "Removed the role from %d users",

	-- utility
	embedOK = "✅ OK",
	embedWarning = "⚠ Warning",
	embedError = "❗ Error",

	inCategory = "in %s category",

	ratelimitRemaining = "This command is ratelimited. You can do this **1** more time in next **%s**",
	ratelimitReached = "This command is ratelimited. You will be able to perform this command after **%s**",

	ping = [[:green_circle: `%dms`
`%d` servers 
`%d | %d` lobbies
`%d | %d` channels
`%d | %d` users]],

	-- errors
	notLobby = "Selected channel is not a lobby",
	lobbyDupe = "This channel is already registered as a lobby",
	channelDupe = "Can't register a room as a lobby",
	badBotPermissions = "Bot doesn't have sufficient permissions",
	badUserPermissions = "You don't have sufficient permissions",
	noParent = "unknown lobby",
	noDMs = "Can't send invite to user. Invite link - %s",
	shame = "Why would you need to do this?",
	interactionTimeout = "Interaction time out!",
	notInGuild = "This command can be issued only from within a server",

	error = "*%s*\nThis issue was reported the moment it occured. Contact us if you need additional help - https://discord.gg/tqj6jvT",
	errorReaction = {
		"I'm sowwy",
		"There go my evening plans",
		"Sure did see this one coming",
		"Kinda saw this one coming",
		"Never saw this one coming",
		"sirens blaring in distance",
		"Is everyone alive?",
		"I sure hope nobody got killed",
		"Ow, my leg",
		"That's why we can't have nice things",
		"Slap a bandaid on, that'll do for now",
		"bonk",
		"This is so sad",
		"insert random pop culture reference here",
		"Now you're just doing this on purpose, aren't you?",
		"Tastes like cookies",
		"Valhalla, take me!",
		"Pretty sure this isn't supposed to happen",
		"Yeah, just let me grab my comically large wrench",
		"smacks computer with comically large wrench",
		"Local bot repeatedly embarasses his owner",
		"Add this one to the list"
	}
}