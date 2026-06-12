---@enum (key) runtimeLine
local runtime = {
	-- server
	serverInfo = [[## %s
**Permissions:** %s
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
You can register a lobby with **/lobby add**]],
	lobbiesField = [[**Target category:** %s
**Name template:** %s
**Permissions:** %s
**Managed roles:** %s
**Capacity:** %s
**Bitrate:** %s
**Voice region:** %s
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
	categoryConfirm = "Changed lobby's target to %s",
	categoryReset = "Bot will create rooms in the current category",
	companionEnable = "Companion chats are now enabled for this lobby",
	companionDisable = "Companion chats are now disabled for this lobby",
	nameConfirm = "Changed name to %s",
	permissionsConfirm = "New permissions set",
	permissionsReset = "All permissions are disabled",
	regionSelect = "Select your preferred voice region",
	regionConfirm = "Voice region changed to %s",
	regionReset = "Voice region reset to automatic selection",
	automatic = "automatic",
	optimal = "optimal",
	deprecated = "deprecated",
	custom = "custom",
	gapsFilling = "New channels will be created in gaps between channels",
	gapsLeaving = "Bot will ignore gaps now",
	positionConfirm = "New target position selected - %s",
	orderConfirm = "Channels will be created in %s order",

	-- matchmaking
	matchmakingNoInfo = [[There are no registered matchmaking lobbies
You can register a matchmaking lobby with **/matchmaking add**]],
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
	companionsNoInfo = [[There are no lobbies with enabled companion text channels
You can enable companions with **/companion enable**]],
	companionsField = [[**Category:** %s
**Name:** %s
**Logging:** %s
**Greeting:**
%s]],

	greetingConfirm = "Set new greeting",
	greetingReset = "Disabled the greeting",
	greetingModalTitle = "Companion greeting",
	greetingModalLabel = "Type your greeting message here",
	roomCommands = "Available commands: ",
	logConfirm = "Chat logs will be sent to %s",
	logReset = "Disabled the chatlogs",
	logName = "**%s** room of **%s** lobby\n",
	loggerWarning = "\n\n*This text chat will be logged*",

	-- room
	roomInfoTitle = "## Room info | %s",
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
	roomInfoCommands = "Available commands - **%s**",
	notInRoom = "You can't use this command outside of a room",
	roomButtonsShow = "Show",
	roomButtonsHide = "Hide",
	roomButtonsLock = "Lock",
	roomButtonsUnlock = "Unlock",
	roomButtonsMuteV = "Mute voice",
	roomButtonsUnmuteV = "Unmute voice",
	roomButtonsMuteT = "Mute text",
	roomButtonsUnmuteT = "Unmute text",
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
	passwordCheckText = "This channel is protected by a password. Please enter the password to access the channel.",
	passwordEnter = "Enter the password",
	passwordLabel = "Password",
	passwordNoChannel = "This channel no longer exists",
	passwordSuccess = "Correct password",
	passwordFailure = "Wrong password",
	passwordBanned = "You were banned in this channel!",
	noCompanion = "Your room doesn't have a companion chat",
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
	noUsers = "No users were found",
	usersRolesAdded = "Given the role to %d users",
	usersRolesRemoved = "Removed the role from %d users",

	-- utility
	embedOK = "# ✅ OK",
	embedWarning = "# ⚠ Warning",
	embedError = "# ❗ Error",
	asIs = "%s",
	default = "default",
	enabled = "enabled",
	disabled = "disabled",

	inCategory = "in %s category",

	pingView = [[:green_circle: **%dms**
**%d** servers 
**%d | %d** lobbies
**%d | %d** channels
**%d | %d** users]],

	-- errors
	notLobby = "Selected channel is not a lobby",
	lobbyDupe = "This channel is already registered as a lobby",
	channelDupe = "Can't register a room as a lobby",
	botPermissionsAdmin = "Bot has administrator privileges. In addition to normal functions, it will grant Manage Roles permission to hosts in lobbies with enabled *moderate* permission.",
	botPermissionsMandatory = "Bot is missing important permissions - %s",
	botPermissionsOptional = "Bot might not be working properly due to some disabled permissions - %s",
	botPermissionsOk = "Bot has all default permissions enabled",
	badUserPermissions = "You are not permitted to manage this channel",
	hostMigrationFail = "Bot failed to grant all permissions, some things may not work properly\nIn voice - %s\nIn text - %s",
	noParent = "unknown lobby",
	shame = "Why would you need to do this?",
	interactionTimeout = "Interaction time out!",
	notInGuild = "This command can be issued only from within a server",
	wait = "Wait for %s before creating another channel",
	veryNotPermitted = "You're not my father",
}

return runtime
