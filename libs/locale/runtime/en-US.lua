---@type {textLine : string|table}
local locale = {
	-- help
	helpSelectorPlaceholder = "Select help article",
	helpSelectorLobby = "Lobby",
	helpSelectorLobbyMore = "Lobby names and permissions",
	helpSelectorMatchmaking = "Matchmaking",
	helpSelectorCompanion = "Companion",
	helpSelectorRoom = "Room management",
	helpSelectorRoomMore = "Room moderation",
	helpSelectorServer = "Server",
	helpSelectorOther = "Other",

	helpContentsLobby = [[**Lobby commands**
Setup and configure lobbies]],
	helpSContentsLobby = "/lobby",
	helpContentsMatchmaking = [[**Matchmaking commands**
Setup and configure matchmaking in lobbies or normal channels]],
	helpSContentsMatchmaking = "/matchmaking",
	helpContentsCompanion = [[**Companion commands**
Configure companion chats (see **Lobby commands** first)]],
	helpSContentsCompanion = "/companion",
	helpContentsRoom = [[**Room commands**
User commands for room configuration and moderation]],
	helpSContentsRoom = "/room",
	helpContentsServer = [[**Server commands**
Setup bot functionality in normal channels]],
	helpSContentsServer = "/server",
	helpContentsOther = [[**Other commands**
Different helpful commands for users and administrators]],
	helpSContentsOther = "/help",

	helpLobbyHeader = [[# Lobby commands
Enter a lobby to create a room. Room is deleted once it's empty]],
	helpLobbySetup = "Quickly configure a lobby",
	helpSLobbySetup = "/lobby setup",
	helpLobbyView = "Show your lobbies",
	helpSLobbyView = "/lobby view",
	helpLobbyAdd = "Add a new lobby",
	helpSLobbyAdd = "/lobby add",
	helpLobbyRemove = "Remove an existing lobby",
	helpSLobbyRemove = "/lobby remove",
	helpLobbyCategory = "Select a category in which rooms will be created. By default, rooms are created in the same category as the lobby.",
	helpSLobbyCategory = "/lobby category",
	helpLobbyCapacity = "Choose the capacity for the new rooms. By default, capacity will be copied from the lobby.",
	helpSLobbyCapacity = "/lobby capacity",
	helpLobbyLimit = "Set the maximum amount of channels bot will create for the lobby",
	helpSLobbyLimit = "/lobby limit",
	helpLobbyBitrate = "Choose the bitrate for the new rooms. By default, bitrate will be copied from the lobby. This setting respects server boost status.",
	helpSLobbyBitrate = "/lobby bitrate",

	helpLobbyName = [[Configure what name a room will have when it's created. Default name is **%nickname's% room**.
You can put different **%patterns%** in the name to customize it
**%name%** - user's name
**%nickname%** - user's nickname (name is used if nickname is not set)
**%name's%**, **%nickname's%** - corresponding combo with **'s** or **'** attached (difference between **Riddles's** and **Riddles'**)
**%tag%** - user's tag (for example **riddlesandlies**)
**%game%** - user's currently played game (**no game** if user's not playing anything)
**%game(text)%** - same as %game%, but shows **text** instead of **no game**
**%counter%** - room position, keeps rooms ordered
**%rename%** - blank when room is created, gets replaced by host's input when **/room rename** is used
**%rename(text)%** - same as %rename%, but shows **text** instead of being blank]],
	helpSLobbyName = "/lobby name",
	helpLobbyPermissions = [[Give room hosts' access to different commands
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
**moderate** - all of the above. If bot is given administrator privileges, gives host **Manage Roles** permission in their room.]],
	helpSLobbyPermissions = "/lobby permissions",
	helpLobbyRole = "Change the default role that's used to inflict restrictions in room and chat commands. Default is @everyone.",
	helpSLobbyRole = "/lobby role",

	helpMatchmakingHeader = [[# Matchmaking commands
Enter a matchmaking lobby to be moved to a channel in lobby's matchmaking pool]],
	helpMatchmakingSetup = "Quickly configure a matchmaking lobby",
	helpSMatchmakingSetup = "/matchmaking setup",
	helpMatchmakingView = "Show your matchmaking lobbies",
	helpSMatchmakingView = "/matchmaking view",
	helpMatchmakingAdd = "Add a new matchmaking lobby",
	helpSMatchmakingAdd = "/matchmaking add",
	helpMatchmakingRemove = "Remove an existing matchmaking lobby",
	helpSMatchmakingRemove = "/matchmaking remove",
	helpMatchmakingTarget = [[Select a target for the matchmaking pool
**If target is a lobby**, then the matchmaking pool is rooms that are created by that lobby. If no room is available, a new one is created using that lobby's settings.
**If target is a category**, then the matchmaking pool is its voice channels. If no channel is available, user is kicked from the matchmaking lobby.]],
	helpSMatchmakingTarget = "/matchmaking target",
	helpMatchmakingMode = [[Select the matchmaking mode. All modes respect channel capacity and blocklists/reservations.
**random** - selects a random available channel. This is the default option
**max** - selects the most filled available channel
**min** - selects the least filled available channel
**first** - selects the first available channel
**last** - selects the last available channel]],
	helpSMatchmakingMode = "/matchmaking mode",

	helpCompanionHeader = [[# Companion commands
Companion chats are created and deleted along the rooms. By default, chat is visible only when you're in the chat's room.
Some commands in this category can be used with text-in-voice and don't require companion chat to be enabled.]],
	helpCompanionSetup = "Quickly configure companion settings for a lobby",
	helpSCompanionSetup = "/companion setup",
	helpCompanionView = "Show all lobies that have companion chats enabled",
	helpSCompanionView = "/companion view",
	helpCompanionEnable = "Enable or disable companion chat for a lobby",
	helpSCompanionEnable = "/companion enable|disable",
	helpCompanionCategory = "Select a category in which chats will be created",
	helpSCompanionCategory = "/companion category",
	helpCompanionName = [[Configure what name a chat will have when it's created and customize it with %patterns% similarly to **/lobby name**. Default is **private-chat**.
Text chat names have default formatting enforced by Discord, name template will be automatically converted to this formatting.]],
	helpSCompanionName = "/companion name",
	helpCompanionGreeting = [[Configure a message that will be automatically sent to the chat when it's created. This command also works in chat-in-voice channels.
You can put different **%patterns%** in the greeting to customize it.
**%roomname%** - name of the room chat belongs to
**%chatname%** - name of the chat
**%commands%** - list of available **/room** commands
**%nickname%**, **%name%**, **%tag%**, **%nickname's%**, **%name's%** - similar to **/lobby name**
**%buttons%** - blank, attaches privacy controls to the greeting message]],
	helpSCompanionGreeting = "/companion greeting",
	helpCompanionLog = "Enable chat logging. Logs will be sent as files to a channel of your choosing. Users will be notified about chat logging with a generic greeting message in chat.",
	helpSCompanionLog = "/companion log",

	helpRoomHeader = [[# Room commands
Most room commands are used by a room host - the user who created the room. Those commands can be enabled by administrator.]],
	helpRoomView = "Show room info and available commands",
	helpSRoomView = "/room view",
	helpRoomHost = "Ping current room host or transfer host privileges to another user",
	helpSRoomHost = "/room host",
	helpRoomInvite = "Send invite to immediately connect to the room. If specific user is mentioned - sends them a DM. If sent by a room host - whitelists them.",
	helpSRoomInvite = "/room invite",
	helpRoomRename = [[Change room or companion name
❗Bot can't change the channel name more than twice per 10 minutes❗]],
	helpSRoomRename = "/room rename",
	helpRoomResize = "Change room capacity",
	helpSRoomResize = "/room resize",
	helpRoomBitrate = "Change room bitrate. This command respects server boost status.",
	helpSRoomBitrate = "/room bitrate",
	helpRoomKick = "Kick a user from the room. This will not prevent the user from joining in the future, use **/room block** for that.",
	helpSRoomKick = "/room kick",
	helpRoomBlock = "Restrict or allow entry to the room for a specific user",
	helpSRoomBlock = "/room block|allow",
	helpRoomLock = "Lock or unlock entry to the room",
	helpSRoomLock = "/room lock|unlock",
	helpRoomMuteVoice = "Mute or unmute a user in your voice channel and change if new users are able to speak",
	helpSRoomMuteVoice = "/room mute|unmute voice",
	helpRoomMuteText = "Mute or unmute a user in your text channels and change if new users are able to write",
	helpSRoomMuteText = "/room mute|unmute text",
	helpRoomHideVoice = "Hide or show the room",
	helpSRoomHideVoice = "/room hide|show voice",
	helpRoomHideText = "Hide or show the companion text channel",
	helpSRoomHideText = "/room hide|show text",
	helpRoomPassword = "Users will have to enter the password before connecting to the channel, unless they were invited or allowed in with **/room allow**",
	helpSRoomPassword = "/room password",

	helpServerHeader = [[# Server commands
Global server settings. Room commands in normal channels can be enabled using these commands.]],
	helpServerSetup = "Quickly configure server settings all in one place",
	helpSServerSetup = "/server setup",
	helpServerView = "Show server settings",
	helpSServerView = "/server view",
	helpServerLimit = "Set the maximum amount of channels bot will create on the server",
	helpSServerLimit = "/server limit",
	helpServerPermissions = [[Enable room commands in normal voice channels, similar to **/lobby permissions**
Bot will start deleting user permission overwrites in all voice channels once this is enabled, use at your own risk!]],
	helpSServerPermissions = "/server permissions",
	helpServerRole = "Change the default role that's used to inflict restrictions in channels",
	helpSServerRole = "/server role",

	helpHelp = "Show table of contents for help. You can also specify a specific article you might want to see",
	helpSHelp = "/help",
	helpSupport = "Sends an invite to the support server",
	helpSSupport = "/support",
	helpReset = "Reset any setting to its default value",
	helpSReset = "/reset",
	helpClone = [[Clone a channel. You can add **%counter%** to channel name to make the cloned channels numbered, and **%counter(number)%** to start counting from a specific number.
This command will not carry over any permission overrides from the cloned channel - all clones will spawn synced with the parent category.]],
	helpSClone = "/clone",
	helpDelete = [[Delete several channels. Optionally select several filters - category, name, whether to consider channels with messages (for text) or connected members (for voice).
This command will not immediately delete the selected channels, instead a helper tool will appear. Handle with care, since channels are deleted irreversibly!]],
	helpSDelete = "/delete",
	helpUsersPrint = [[Create a handy list of users in a selected channel
If selected channel is a lobby, prints users in lobby's rooms or matchmaking pool channels
If category is selected, prints users in the channels in the category]],
	helpSUsersPrint = "/users print",
	helpUsersGive = "Give a role to users in a selected channel. Selection rules are similar to **/users print**",
	helpSUsersGive = "/users remove",
	helpUsersRemove = "Remove a role from users in a selected channel. Selection rules are similar to **/users print**",
	helpSUsersRemove = "/users remove",

	helpLinks = [[[Setup Guide](https://github.com/BestMordaEver/Voice-Manager/wiki/Setup-Guide) | [User Guide](https://github.com/BestMordaEver/Voice-Manager/wiki/User-Guide) | [Glossary](https://github.com/BestMordaEver/Voice-Manager/wiki/Glossary)
[Privacy](https://github.com/BestMordaEver/Voice-Manager/blob/dev/privacy.md) | [ToS](https://github.com/BestMordaEver/Voice-Manager/blob/dev/tos.md)
[Support Server](https://discord.gg/tqj6jvT)]],

	-- server
	serverInfo = [[**Permissions:** %s
**Managed roles:** %s
**Lobbies:** %d
**Active users:** %d
**Channels:** %d
**Room limit:** %d]],

	limitConfirm = "Limit is set to %d",
	roleConfirm = "Updated role list: %s",
	roleConfirmNoRoles = "The default @everyone is in use",

	-- lobbies
	lobbiesNoInfo = [[There are no registered lobbies
You can add a lobby with **/lobby add**]],
	lobbiesField = [[**Target category:** %s
**Name template:** %s
**Permissions:** %s
**Managed roles:** %s
**Capacity:** %s
**Bitrate:** %s
**Companion:** %s
**Channels:** %d]],
	lobbyViewSelect = "Select a lobby",

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
	positionConfirm = "Bot will now create channels in",

	-- matchmaking
	matchmakingNoInfo = [[There are no registered matchmaking lobbies
You can create a matchmaking lobby with **/matchmaking add**]],
	matchmakingField = [[**Target:** %s
**Mode:** %s
**Matchmaking pool:** %d channels]],
	matchmakingViewSelect = "Select a matchmaking lobby",

	matchmakingAddConfirm = "Added new matchmaking lobby %s",
	matchmakingRemoveConfirm = "Removed matchmaking lobby %s",
	targetConfirm = "Changed matchmaking target to %s",
	targetReset = "Matchmaking target is reset, lobby will matchmake for its current category",
	modeConfirm = "Changed matchmaking mode to %s",

	-- companion
	companionsNoInfo = [[There are no lobbies with enabled companion channels
You can enable companion channels with **/companion enable**]],
	companionsField = [[**Category:** %s
**Name:** %s
**Logging:** %s
**Greeting:**
%s]],

	greetingConfirm = "Set new greeting",
	greetingReset = "Disabled the greeting",
	greetingModalTitle = "Companion greeting",
	greetingModalLabel = "Type in the greeting message here",
	roomCommands = "Available commands: ",
	logConfirm = "Chat logs will be sent to %s",
	logReset = "Disabled the chatlogs",
	logName = "**%s** room of **%s** lobby\n",
	loggerWarning = "\n\n*This text chat will be logged*",

	-- room
	roomInfoHost = "**Host: %s**",
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
	roomInfoCommands = "Available commands\n%s",
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
	kickNotInRoom = "You can only kick users from your room",
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
	renameConfirm = "Changed the name to %s\n%s",
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
	embedOK = "# ✅ OK",
	embedWarning = "# ⚠ Warning",
	embedError = "# ❗ Error",
	asIs = "%s",

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
	botPermissionsAdmin = "Bot has administrator privileges. In addition to normal function, it will grant Manage Roles permission to hosts in lobbies with enabled *moderate* permission.",
	botPermissionsMandatory = "Bot is missing important permissions - %s",
	botPermissionsOptional = "Bot might not be working properly due to some disabled permissions - %s",
	botPermissionsOk = "Bot has all default permissions enabled",
	badUserPermissions = "You are not permitted to manage this channel",
	hostMigrationFail = "Bot failed to properly transfer room ownership, some things may not work properly\nIn voice - %s\nIn text - %s",
	noParent = "unknown lobby",
	shame = "Why would you need to do this?",
	interactionTimeout = "Interaction time out!",
	notInGuild = "This command can be issued only from within a server",
	wait = "Wait for %s before creating another channel",
	veryNotPermitted = "You're not my father",

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

return locale