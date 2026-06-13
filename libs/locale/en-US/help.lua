---@enum (key) helpLine
local help = {
	helpSelectorPlaceholder = "Select a help article",
	helpSelectorLobby = "Lobby",
	helpSelectorLobbyPlacement = "Lobby targeting",
	helpSelectorLobbyMore = "Lobby names and permissions",
	helpSelectorMatchmaking = "Matchmaking",
	helpSelectorCompanion = "Companion",
	helpSelectorLogging = "Logging",
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
	helpContentsLogging = [[**Logging commands**
Archive companion chats as transcripts]],
	helpSContentsLogging = "/logging",
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
Enter a lobby to create a room. The room is deleted once it's empty]],
	helpLobbySetup = "Quickly configure a lobby",
	helpSLobbySetup = "/lobby setup",
	helpLobbyView = "Show your lobbies",
	helpSLobbyView = "/lobby view",
	helpLobbyAdd = "Register a new lobby",
	helpSLobbyAdd = "/lobby add",
	helpLobbyRemove = "Remove an existing lobby",
	helpSLobbyRemove = "/lobby remove",
	helpLobbyCapacity = "Choose the capacity for the new rooms. By default, capacity will be copied from the lobby.",
	helpSLobbyCapacity = "/lobby capacity",
	helpLobbyLimit = "Set the maximum amount of channels the bot will create for the lobby",
	helpSLobbyLimit = "/lobby limit",
	helpLobbyBitrate = "Choose the bitrate for the new rooms. By default, bitrate will be copied from the lobby. This setting respects server boost status.",
	helpSLobbyBitrate = "/lobby bitrate",
	helpLobbyRegion = "Set the default voice region for the new rooms",
	helpSLobbyRegion = "/lobby region",
	helpLobbyCategory = "Select a category in which the new rooms will be created. By default, rooms are created in the same category as the lobby.",
	helpSLobbyCategory = "/lobby category",
	helpLobbyTarget = "Select a channel around which rooms will be created",
	helpSLobbyTarget = "/lobby target",
	helpLobbyGaps = "Choose if gaps left from deleted channels should be filled. This is especially usefull with %counter% in room name.",
	helpSLobbyGaps = "/lobby gaps",
	helpLobbyPosition = "Configure room position",
	helpSLobbyPosition = "/lobby position",
	helpLobbyOrder = "Change which direction new channels stack",
	helpSLobbyOrder = "/lobby order",

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
	helpLobbyPermissions = [[Give room hosts access to different commands
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
**moderate** - all of the above. If bot has admini privileges, gives host **Manage Roles** permission in their room.]],
	helpSLobbyPermissions = "/lobby permissions",
	helpLobbyRole = "Change the default role that's used to inflict restrictions in room and chat commands. Default is @everyone.",
	helpSLobbyRole = "/lobby role",

	helpMatchmakingHeader = [[# Matchmaking commands
Enter a matchmaking lobby to be moved to a channel in the lobby's matchmaking pool]],
	helpMatchmakingSetup = "Quickly configure a matchmaking lobby",
	helpSMatchmakingSetup = "/matchmaking setup",
	helpMatchmakingView = "Show your matchmaking lobbies",
	helpSMatchmakingView = "/matchmaking view",
	helpMatchmakingAdd = "Register a new matchmaking lobby",
	helpSMatchmakingAdd = "/matchmaking add",
	helpMatchmakingRemove = "Remove an existing matchmaking lobby",
	helpSMatchmakingRemove = "/matchmaking remove",
	helpMatchmakingTarget = [[Select a target for the matchmaking pool
**If target is a lobby**, then the matchmaking pool includes rooms that are created by that lobby. If no room is available, a new one is created using that lobby's settings.
**If target is a category**, then the matchmaking pool is its voice channels. If no channel is available, user is kicked from the matchmaking lobby.]],
	helpSMatchmakingTarget = "/matchmaking target",
	helpMatchmakingMode = [[Select the matchmaking mode. All modes respect channel capacity and blocks/invites.
**random** - selects a random available channel. This is the default option
**max** - selects the most filled available channel
**min** - selects the least filled available channel
**first** - selects the first available channel
**last** - selects the last available channel]],
	helpSMatchmakingMode = "/matchmaking mode",

	helpCompanionHeader = [[# Companion commands
Companion chats are created and deleted along the rooms. By default, a chat is visible only when you're in the chat's room.
Some commands in this category can be used with text-in-voice and don't require companion chats to be enabled.]],
	helpCompanionSetup = "Quickly configure companion settings for a lobby",
	helpSCompanionSetup = "/companion setup",
	helpCompanionView = "Show all lobies that have companion chats enabled",
	helpSCompanionView = "/companion view",
	helpCompanionEnable = "Enable or disable the companion chat for a lobby",
	helpSCompanionEnable = "/companion enable|disable",
	helpCompanionCategory = "Select a category in which chats will be created",
	helpSCompanionCategory = "/companion category",
	helpCompanionName = [[Configure what name a chat will have when it's created and customize it with %patterns% similarly to **/lobby name**. Default is **private-chat**.
Text channel names have default formatting enforced by Discord, the name template will be automatically converted to this formatting.]],
	helpSCompanionName = "/companion name",
	helpCompanionGreeting = [[Configure a message that will be automatically sent to the chat when it's created. This command also works with chat-in-voice channels.
You can put different **%patterns%** in the greeting to customize it.
**%roomname%** - name of the room the chat belongs to
**%chatname%** - name of the chat
**%commands%** - list of available **/room** commands
**%nickname%**, **%name%**, **%tag%**, **%nickname's%**, **%name's%** - similar to **/lobby name**
**%buttons%** - blank, attaches privacy controls to the greeting message]],
	helpSCompanionGreeting = "/companion greeting",

	helpLoggingHeader = [[# Logging commands
Companion chats can be archived as self-contained HTML transcripts that are uploaded to a channel of your choosing when a room is deleted.]],
	helpLoggingView = "Show lobbies with logging enabled and the current transcript time zone",
	helpSLoggingView = "/logging view",
	helpLoggingEnable = "Enable logging for a lobby and pick the channel transcripts are sent to. Users are notified about logging with a generic greeting message in chat.",
	helpSLoggingEnable = "/logging enable|disable",
	helpLoggingChannel = "Change the channel where a lobby's transcripts are sent",
	helpSLoggingChannel = "/logging channel",
	helpLoggingOffset = "Set the UTC offset used for timestamps in exported transcripts",
	helpSLoggingOffset = "/logging offset",

	helpRoomHeader = [[# Room commands
Most room commands are used by a room host - the user who created the room. Those commands can be enabled by administrator.]],
	helpRoomView = "Show room info and available commands",
	helpSRoomView = "/room view",
	helpRoomHost = "Ping current room host or transfer host privileges to another user",
	helpSRoomHost = "/room host",
	helpRoomInvite = "Create a room invite. If specific user is mentioned - DMs them the invite. If sent by a room host - whitelists them.",
	helpSRoomInvite = "/room invite",
	helpRoomRename = [[Change room or text channel name
❗Bot can't change channel names more than twice per 10 minutes❗]],
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
	helpRoomMuteVoice = "Mute or unmute a user in your voice channel or change if new users are able to speak",
	helpSRoomMuteVoice = "/room mute|unmute voice",
	helpRoomMuteText = "Mute or unmute a user in your text channels or change if new users are able to write",
	helpSRoomMuteText = "/room mute|unmute text",
	helpRoomHideVoice = "Hide or show the room",
	helpSRoomHideVoice = "/room hide|show voice",
	helpRoomHideText = "Hide or show the companion text channel",
	helpSRoomHideText = "/room hide|show text",
	helpRoomPassword = "Users will have to enter a password before connecting to the channel, unless they were invited or allowed in with **/room allow**",
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
If a lobby is selected, prints users in lobby's rooms or matchmaking pool channels
If a category is selected, prints users in the channels in the category]],
	helpSUsersPrint = "/users print",
	helpUsersGive = "Give a role to users in a selected channel. Selection rules are similar to **/users print**",
	helpSUsersGive = "/users remove",
	helpUsersRemove = "Remove a role from users in a selected channel. Selection rules are similar to **/users print**",
	helpSUsersRemove = "/users remove",

	helpLinks = [[[Setup Guide](https://github.com/BestMordaEver/Voice-Manager/wiki/Setup-Guide) | [User Guide](https://github.com/BestMordaEver/Voice-Manager/wiki/User-Guide) | [Glossary](https://github.com/BestMordaEver/Voice-Manager/wiki/Glossary)
[Privacy](https://github.com/BestMordaEver/Voice-Manager/blob/dev/privacy.md) | [ToS](https://github.com/BestMordaEver/Voice-Manager/blob/dev/tos.md)
[Support Server](https://discord.gg/tqj6jvT)]],
}

return help
