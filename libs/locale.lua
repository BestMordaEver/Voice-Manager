-- a static storage for everything the bot displays as text to user
-- may be used as a foundation for translation

return {
	-- help
	help = {
		help = {
			title = "Table of contents",
			fields = {
				{
					name = "Lobby commands",
					value = "Setup and configure lobbies - **/lobby**"
				},
				{
					name = "Matchmaking commands",
					value = "Setup and configure matchmaking in lobbies or normal channels - **/matchmaking**"
				},
				{
					name = "Companion commands",
					value = "Configure companion chats (see **Lobby commands** first) - **/companion**"
				},
				{
					name = "Room commands",
					value = "User commands for room configuration and moderation - **/room**"
				},
				{
					name = "Server commands",
					value = "Setup bot functionality in normal channels - **/server**"
				},
				{
					name = "Other commands",
					value = "Different helpful commands for users and administrators"
				}
			}
		},

		lobby = {
			title = "Lobby commands",
			description = "Enter a lobby to create a room. Room is deleted once it's empty",
			fields = {
				{
					name = "/lobby view",
					value = "Show current lobbies"
				},
				{
					name = "/lobby add",
					value = "Add a new lobby"
				},
				{
					name = "/lobby remove",
					value = "Remove an existing lobby"
				},
				{
					name = "/lobby category",
					value = "Select a category in which rooms will be created. By default, rooms are created in the same category as the lobby"
				},
				{
					name = "/lobby name",
					value = [[Configure what name a room will have when it's created
		Default name is **%nickname's% room**
		You can put different **%combos%** in the name to customize it
		**%name%** - user's name
		**%nickname%** - user's nickname (name is used if nickname is not set)
		**%name's%**, **%nickname's%** - corresponding combo with **'s** or **'** attached (difference between **Riddles's** and **Riddles'**)
		**%tag%** - user's tag (for example **Riddles#2773**)
		**%game%** - user's currently played game (**no game** if user's not playing anything)
		**%game(text)%** - same as %game%, but shows **text** instead of **no game**
		**%counter%** - room position. Keeps rooms ordered
		**%rename%** - blank when room is created. When host uses **/room rename**, gets replaced by host's input]]
				},
				{
					name = "/lobby capacity",
					value = "Select new rooms' capacity. By default, capacity will be copied over from the lobby"
				},
				{
					name = "/lobby bitrate",
					value = "Select new rooms' bitrate. By default, bitrate will be copied over from the lobby. This setting respect server boost status, so you may want to try bigger numbers"
				},
				{
					name = "/lobby permissions",
					value = [[Give room hosts' access to different commands
Room settings permissions:
**rename** - allows use of **/room rename**
**resize** - allows use of **/room resize**
**bitrate** - allows use of **/room bitrate**
**manage** - all of the above, plus gives host **Manage Channels** permission in their room
Moderation permissions:
**kick** - allows use of **/room kick**, plus gives host **Move Memebers** permission
**mute** - allows use of **/room mute|unmute**
**hide** - allows use of **/room hide|show**
**lock** - allows use of **/room lock|unlock** and **/room block|unblock**
**password** - allows use of **/room password**
**moderate** - all of the above. If bot is given administrator privileges, gives host **Manage Roles** permission in their room]]
				},
				{
					name = "/lobby role",
					value = "Change the default role that's used to inflict restrictions in room and chat commands. Default is @everyone"
				}
			}
		},

		matchmaking = {
			title = "Matchmaking commands",
			description = "Enter a matchmaking lobby to be moved to a channel in lobby's matchmaking pool",
			fields = {
				{
					name = "/matchmaking view",
					value = "Show current matchmaking lobbies"
				},
				{
					name = "/matchmaking add",
					value = "Add a new matchmaking lobby"
				},
				{
					name = "/matchmaking remove",
					value = "Remove an existing matchmaking lobby"
				},
				{
					name = "/matchmaking target",
					value = [[Select a target for matchmaking pool
**If target is a lobby**, then matchmaking pool is rooms that are created by that lobby. If no room is available, a new one is created using that lobby's settings
**If target is a category**, then matchmaking pool is its voice channels. If no channel is available, user is kicked from matchmaking lobby]]
				},
				{
					name = "/matchmaking mode",
					value = [[Select the matchmaking mode. All modes respect channel capacity and blocklists/reservations
**random** - selects a random available channel. This is the default option
**max** - selects a most filled channel
**min** - selects a least filled channel
**first** - selects the first available channel
**last** - selects the last available channel]]
				}
			}
		},

		companion = {
			title = "Companion commands",
			description = [[Companion chats are created and deleted along rooms. Chat is visible only to the inhabitants of the room.
Some commands in this category can be used with chat-in-voice channels and don't require companion chat to be enabled]],
			fields = {
				{
					name = "/companion view",
					value = "Show all lobies that have companion chats enabled"
				},
				{
					name = "/companion enable|disable",
					value = "Enable or disable companion chat for selected lobby"
				},
				{
					name = "/companion category",
					value = "Select a category in which chats will be created"
				},
				{
					name = "/companion name",
					value = [[Configure what name a chat will have when it's created and customize it with %combos% similarly to **/lobby name**. Default is **private-chat**
Text chat names have default formatting enforced by Discord, name template will be automatically converted to conform to it]]
				},
				{
					name = "/companion greeting",
					value = [[Configure a message that will be automatically sent to the chat when it's created. This command also works in chat-in-voice channels
You can put different **%combos%** in the greeting to customize it
**%roomname%** - name of the room chat belongs to
**%chatname%** - name of the chat
**%commands%** - list of **/room** commands
**%nickname%**, **%name%**, **%tag%**, **%nickname's%**, **%name's%** - similar to **/lobby name**
**%buttons%** - blank, attaches privacy control buttons to the greeting message]]
				},
				{
					name = "/companion log",
					value = "Enable chat logging. Logs will be sent as files to a channel of your choosing. Users will be notified about chat logging with a generic greeting message in chat"
				}
			}
		},

		room = {
			title = "Room commands",
			description = "Most room commands are used by a room host - user who created the room. Those commands can be enabled by admins",
			fields = {
				{
					name = "/room view",
					value = "Show room info and available commands"
				},
				{
					name = "/room rename",
					value = [[Change room or companion name
❗Bot can't make changes to channel names more than twice per 10 minutes❗]]
				},
				{
					name = "/room resize",
					value = "Change room capacity"
				},
				{
					name = "/room bitrate",
					value = "Change room bitrate. This command respects server boost status, check if you can use higher bitrates"
				},
				{
					name = "/room kick",
					value = "Kick a user from the room"
				},
				{
					name = "/room mute|unmute",
					value = "Mute|unmute a user and change whether you want new users to be able to speak or write"
				},
				{
					name = "/room block|allow",
					value = "Restrict|allow entry to the room for a specific user"
				},
				{
					name = "/room hide|show",
					value = "Hide|show the room"
				},
				{
					name = "/room lock|unlock",
					value = "Lock|unlock entry to the room"
				},
				{
					name = "/room password",
					value = "Users will have to enter the password before connecting to the channel, unless they were invited or whitelisted with **/room allow**"
				},
				{
					name = "/room host",
					value = "Ping current room host or transfer host privileges to another user"
				},
				{
					name = "/room invite",
					value = [[Send invite to immediately connect to the room
If specific user is mentioned - sends them a DM
If sent by a room host - whitelists them]]
				}
			}
		},

		server = {
			title = "Server commands",
			description = "Global server settings. Room commands in normal channels can be enabled using these commands",
			fields = {
				{
					name = "/server view",
					value = "Show server settings"
				},
				{
					name = "/server limit",
					value = "Set the maximum amount of channels bot will create on the server"
				},
				{
					name = "/server permissions",
					value = [[Enable room commands in normal voice channels, similar to **/lobby permissions**
Bot will start deleting user permission overwrites in all channels once this is enabled, use at your own risk!]]
				},
				{
					name = "/server role",
					value = "Change the default role that's used to inflict restrictions in channels"
				}
			}
		},

		other = {
			title = "Other commands",
			fields = {
				{
					name = "/help [lobbies|matchmaking|companions|room|chat|other]",
					value = [[Show table of contents for help
You can specify the page to show instead of table of contents]]
				},
				{
					name = "/support",
					value = "Send invite to the support server"
				},
				{
					name = "/reset <command> <subcommand>",
					value = [[Reset any setting to its default value
Example: **/reset companions greeting**]]
				},
				{
					name = "/clone <channel> <amount> [name]",
					value = [[Clone a channel. You can add **%counter%** to channel name to make the cloned channels numbered, and **%counter(number)%** to start counting from a specific number
This command will not carry over any permission overrides from the cloned channel - all clones will spawn synced with the parent category]],
				},
				{
					name = "/delete <channel_type> [category] [amount] [name] [only_empty]",
					value = [[Delete several channels. Optionally select several filters - category, name, whether to consider channels with messages (for text) or connected members (for voice).
This command will not immediately delete the selected channels, instead a helper tool will appear. Handle with care, since channels are deleted irreversibly!]]
				},
				{
					name = "/users print <channel|lobby|category> [mode] [separator]",
					value = [[Create a handy list of users in a selected channel.
If selected channel is a lobby, prints users in lobby's rooms or matchmaking pool channels
If category is selected, all it's channels are used]],
				},
				{
					name = "/users give|remove <channel|lobby|category> <role>",
					value = "Give or remove a role to/from users in a selected channel. Selection rules are similar to **/users print**"
				}
			}
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
You can add a lobby with **/lobby add**]],
	lobbiesInfo = "Select lobbies to change their settings",
	lobbiesField = [[**Target category:** %s
**Name template:** %s
**Permissions:** %s
**Managed role:** %s
**Capacity:** %s
**Bitrate:** %s
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
You can create a matchmaking lobby with **/matchmaking add**]],
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
You can enable companion channels with **/lobby companion enable**]],
	companionsField = [[**Category:** %s
**Name:** %s
**Logging:** %s
**Greeting:**
%s]],

	greetingConfirm = "Set new greeting",
	greetingReset = "Disabled the greeting",
	greetingModalTitle = "Companion greeting",
	greetingModalLabel = "Greeting message",
	roomCommands = "Available commands: ",
	logConfirm = "Chat logs will be sent to %s",
	logReset = "Disabled the chatlogs",
	logName = "**%s** room of **%s** lobby\n",
	loggerWarning = "\n\n*This text chat will be logged*",

	-- room
	roomInfoTitle = "Room info | %s",
	roomInfoHost = "**Host: **",
	roomInfoVisible = "👁 Visibility - **public**",
	roomInfoVisibleExceptions = "Hidden from: ",
	roomInfoInvisible = "⛔ Visibility - **private**",
	roomInfoInvisibleExceptions = "Visible to: ",
	roomInfoPublic = "🔓 Access - **public**",
	roomInfoPublicExceptions = "Blocked: ",
	roomInfoPrivate = "🔒 Access - **private**",
	roomInfoPrivateExceptions = "Reserved for: ",
	roomInfoVocal = "🔉 Voice - **public**",
	roomInfoVocalExceptions = "Muted: ",
	roomInfoSilent = "🔇 Voice - **limited**",
	roomInfoSilentExceptions = "Speakers: ",
	roomInfoWriting = "🖊 Writing in chat - **public**",
	roomInfoWritingExceptions = "Muted: ",
	roomInfoMuted = "📵 Writing in chat - **private**",
	roomInfoMutedExceptions = "Participants: ",
	chatInfoVisible = "📄 Text visibility - **public**",
	chatInfoVisibleExceptions = "Hidden from: ",
	chatInfoInvisible = "🥷 Text visibility - **private**",
	chatInfoInvisibleExceptions = "Visible to: ",
	chatInfoWriting = "🖊 Writing in companion - **public**",
	chatInfoMuted = "📵 Writing in companion - **private**",
	roomInfoCommands = "Available commands",
	notInRoom = "You can't use this command outside of a room",
	none = "none",
	muteConfirm = "Muted %s",
	muteAllConfirm = "Enabled private talking",
	unmuteConfirm = "Unmuted %s",
	unmuteAllConfirm = "Enabled public talking",
	hideConfirm = "Hidden from %s",
	hideAllConfirm = "Enabled invisibility",
	hideNoCompanion = "There is no companion chat to hide. If you want to hide the voice channel chat, use **/room lock** instead",
	showConfirm = "The channel is visible to %s",
	showAllConfirm = "Disabled invisibility",
	showNoCompanion = "There is no companion chat to show",
	kickConfirm = "Kicked %s",
	blockConfirm = "Blocked %s",
	allowConfirm = "Allowed entry to %s",
	invisibleConfirm = "Room is now invisible",
	lockConfirm = "Room is now invite only",
	unlockConfirm = "Room is now public",
	inviteConfirm = "Invited %s",
	inviteText = [[%s invited you to join %s!
https://discord.gg/%s]],
	inviteCreated = "Invite people to this room - https://discord.gg/%s",
	noDMs = "Can't send invite to user. Invite link - https://discord.gg/%s",
	hostConfirm = "Promoted %s to host",
	badNewHost = "Can't promote users outside of the room",
	hostIdentify = "%s is a room host",
	badHost = "Can't identify the host",
	passwordConfirm = "Password is set to **%s**",
	passwordReset = "Password is removed",
	passwordCheckText = "This channel is protected by password. Please enter the password to access the channel.",
	passwordEnter = "Enter the password",
	password = "Password",
	passwordNoChannel = "This channel no longer exists",
	passwordSuccess = "Correct password",
	passwordFailure = "Wrong password",
	passwordBanned = "You were banned in this channel!",
	noCompanion = "Your room doesn't have companion chat",
	clearConfirm = "Deleted %d messages",
	nameRatelimitRemaining = "This command is ratelimited. You can do this **1** more time in next **%s**",
	nameRatelimitReached = "This command is ratelimited. You will be able to perform this command after **%s**",

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

	ping = [[:green_circle: **%dms**
**%d** servers 
**%d | %d** lobbies
**%d | %d** channels
**%d | %d** users]],

	-- errors
	notLobby = "Selected channel is not a lobby",
	lobbyDupe = "This channel is already registered as a lobby",
	channelDupe = "Can't register a room as a lobby",
	badBotPermissions = "Bot doesn't have sufficient permissions",
	badUserPermissions = "You don't have sufficient permissions",
	noParent = "unknown lobby",
	shame = "Why would you need to do this?",
	interactionTimeout = "Interaction time out!",
	notInGuild = "This command can be issued only from within a server",
	wait = "Wait for %s before creating another channel",

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