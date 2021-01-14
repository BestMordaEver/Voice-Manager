-- a static storage for everything the bot displays as text to user
-- may be used as a foundation for translation

return {
	-- help
	helpMenuTitle = [[Help | Table of contents]],
	helpMenu = [[**Lobby commands** - 1️⃣
Admin commands to setup and configure lobbies
`register`, `unregister`, `template`, `target`, `companion`, `permissions`, `capacity`

**Matchmaking commands** - 2️⃣
Admin commands to configure matchmaking features
`matchmaking target`, `matchmaking template`

**Host commands** - 3️⃣
User commands that can be used by channel hosts
`whitelist`, `blacklist`, `mute`, `name`, `resize`, `bitrate`, `promote`

**Server commands** - 4️⃣
Admin commands to configure global settings like prefix
`limit`, `prefix`

**Other commands** - 5️⃣
Miscellaneous commands that can be used by everyone
`list`, `stats`, `support`]],
	
	helpLobbyTitle = [[Help | Lobby commands]],
	helpLobby = [[You need a "Manage Channels" permission to use those commands!
You can learn more about each command by using `help`, for example `!vm help template`

**!vm register <channel name>**
Turns a voice channel into a lobby. Entering this lobby will create a new, temporary channel

**!vm unregister <channel name>**
Reverts a lobby channel back to a normal channel. Channels created by the existing lobby channel will be deleted once vacant

**!vm target "<channel name>" <category name>**
Select a category in which new channels will be created

**!vm companion "<channel name>" <category name>**
Create private text chats alongside new channels

**!vm template "<channel name>" <template text>**
Change the name of new channels

**!vm permissions "<channel name>" <permission list> <on/off>**
Give your users control over their new channels

**!vm capacity "<channel name>" <number between 0 and 99>**
Change the new channels' capacity]],
	
	helpMatchmakingTitle = [[Help | Matchmaking commands]],
	helpMatchmaking = [[You need a "Manage Channels" permission to use those commands!
You can learn more about each command by using `help`, for example `!vm help template`

**!vm matchmaking target "<channel name>" <channel name>**
Select a lobby that will be matchmade

**!vm matchmaking template "<channel name>" <mode>**
Select a matchmaking mode]],

	helpHostTitle = [[Help | Host commands]],
	helpHost = [[You need to be a channel host to use those commands!
Host commands are enabled with `permissions`, check `!vm help permissions` to learn more
You can learn more about each command by using `help`, for example `!vm help template`

**!vm whitelist <user mention>** and **!vm blacklist <user mention>**
Control who can enter your channel

**!vm name <new channel name>**
Change your channel's name

**!vm resize <number between 0 and 99>**
Change your channel's capacity

**!vm bitrate <number between 8 and 96>**
Change your channel's bitrate

**!vm promote <user mention>**
Transfer your host privileges to other user. Transfer happens automatically if you leave your channel]],
	
	helpServerTitle = [[Help | Server commands]],
	helpServer = [[You need a "Manage Channels" permission to use those commands!
You can learn more about each command by using `help`, for example `!vm help template`

**!vm limit <number between 1 and 500>**
Change how many new channels can be created in your server

**!vm prefix <new prefix>**
Set a new prefix. Mentioning will still work]],

	helpOtherTitle = [[Help | Other commands]],
	helpOther = [[You can learn more about each command by using `help`, for example `!vm help template`
	
**!vm list**
Lists all registered lobbies on the server

**!vm stats [local]**
Take a sneak peek on my performance!

**!vm support**
Get a support server invite]],
	
	-- server
	serverInfoTitle = [[Server info | %s]],
	serverInfo = [[**Prefix:** %s
**Permissions:** %s
**Lobbies:** %d
**Active users:** %d
**Channels:** %d
**Limit:** %d]],
	
	limitBadInput = [[Limit must be a number between 0 and 500]],
	limitConfirm = [[New limit set!]],
	roleBadInput = [[Couldn't find the specified role]],
	roleConfirm = [[New managed role set!]],
	prefixConfirm = [[New prefix set: %s]],
	
	-- lobbies
	lobbiesInfoTitle = [[Lobbies info | %s]],
	lobbiesNoInfo = [[There are no registered lobbies
You can add a lobby with `vm!lobbies add`]],
	lobbiesInfo = [[Select lobbies to change their settings]],
	lobbiesField = [[**Target category:** %s
**Name template:** %s
**Permissions:** %s
**Capacity:** %s
**Companion:** %s
**Channels:** %d]],
	
	addConfirm = [[Added new lobby %s]],
	removeConfirm = [[Removed lobby %s]],
	capacityOOB = [[Capacity must be a number between 0 and 99]],
	capacityConfirm = [[Changed rooms' capacity to %d]],
	categoryConfirm = [[Changed lobby's target category to %s]],
	companionToggle = [[Companion chats are now %sd for this lobby]],
	nameConfirm = [[Name template is %s]],
	
	-- matchmaking
	matchmakingInfoTitle = [[Matchmaking info | %s]],
	matchmakingNoInfo = [[There are not registered matchmaking lobbies
You can create a matchmaking lobby with `match`]],
	matchmakingField = [[**Target:** %s
**Mode:** %s]],
	
	matchmakingAddConfirm = [[Added new matchmaking lobby %s]],
	matchmakingRemoveConfirm = [[Removed matchmaking lobby %s]],
	targetConfirm = [[Changed matchmaking target to %s]],
	modeBadInput = [[Unknown matchmaking mode: %s]],
	modeConfirm = [[Changed matchmaking mode to %s]],
	
	-- companion
	companionInfoTitle = [[Companion settings | %s]],
	companionNoInfo = [[There are no lobbies with enabled companion channels
You can enable companion channels with `companion`]],
	companionField = [[**Target:** %s
**Template:** %s
**Permissions:** %s
**Companion channels:** %d]],
	
	permissionsBadInput = [[Unknown permission: %s]],
	permissionsConfirm = [[New permissions set!]],
	
	-- select
	selectVoice = [[Selected lobby %s]],
	selectCategory = [[Selected category %s]],
	
	-- utility
	channelNameCategory = [[`%s` in `%s`]],
	embedPages = [[Page %d of %d]],
	embedDelete = [[❌ - delete this message]],
	embedTip = [[<> - required, [] - optional, "" - include those in message]],
	embedPage = [[Click :page_facing_up: to select the whole page]],
	embedAll = [[Click :asterisk: to select all available channels]],
	links = "\n\n"..[[**Links**
[Setup Guide](https://github.com/BestMordaEver/Voice-Manager/wiki/Setup-Guide)
[User Guide](https://github.com/BestMordaEver/Voice-Manager/wiki/User-Guide)
[How to find IDs](https://github.com/BestMordaEver/Voice-Manager/wiki/How-to-find-channel-ID)
[Glossary](https://github.com/BestMordaEver/Voice-Manager/wiki/Glossary)
[Support Server](https://discord.gg/tqj6jvT)]],
	-- register
	registeredOne = [[Registered new lobby:]],
	registeredMany = [[Registered **`%d`** new lobbies:]],
	embedRegister = [[Select a channel to register]],
	redundantRegister = [[This channel is already registered:]],
	redundantRegisters = [[Those channels are already registered:]],
	-- unregister
	unregisteredOne = [[Unregistered lobby:]],
	unregisteredMany = [[Unregistered **`%d`** lobbies:]],
	embedUnregister = [[Select a lobby to unregister]],
	-- target
	lobbyTarget = [[Current target for **`%s`** is **`%s`**]],
	noTarget = [[This lobby doesn't have a custom target]],
	newTarget = [[Set a new target **`%s`** for:]],
	selfTarget = [[This is a self-reference:]],
	resetTarget = [[Reset a target:]],
	embedTarget = [[Select a lobby that will have target **`%s`**]],
	embedLobbyTarget = [[Select a lobby to show its target]],
	embedResetTarget = [[Select a lobby to reset its target]],
	badTarget = [[Couldn't find specified target]],
	-- template
	lobbyTemplate = [[Current template for **`%s`** is **`%s`**]],
	noTemplate = [[This lobby doesn't have a custom template]],
	newTemplate = [[Set a new template **`%s`** for:]],
	resetTemplate = [[Reset a template:]],
	embedTemplate = [[Select a lobby that will have template **`%s`**]],
	embedLobbyTemplate = [[Select a lobby to show its template]],
	embedResetTemplate = [[Select a lobby to reset its template]],
	-- permissions
	lobbyPermissions = [[Current lobby permissions for **`%s`** include: **`%s`**]],
	newPermissions = [[Added new permissions **`%s`** for:]],
	revokedPermissions = [[Revoked permissions **`%s`**:]],
	resetPermissions = [[Reset permissions:]],
	embedAddPermissions = [[Select a lobby that will receive listed permissions]],
	embedRemovePermissions = [[Select a lobby that will lose listed permissions]],
	embedLobbyPermissions = [[Select a lobby to show its permissions]],
	embedResetPermissions = [[Select a lobby to reset its permissions]],
	noPermission = [[There's no such permission]],
	noToggle = [[No toggle found]],
	-- capacity
	lobbyCapacity = [[Current capacity for **`%s`** is **`%s`**]],
	noCapacity = [[This lobby doesn't change new channels' capacity]],
	newCapacity = [[Set a new capacity **`%s`** for:]],
	resetCapacity = [[Reset a capacity:]],
	embedCapacity = [[Select a lobby that will have capacity **`%s`**]],
	embedLobbyCapacity = [[Select a lobby to show its capacity]],
	embedResetCapacity = [[Select a lobby to reset its capacity]],
	capacityOOB = [[Capacity must be a number between 0 and 99, or -1 to use lobby's capacity]],
	-- companion
	lobbyCompanion = [[Companion channels for **`%s`** are created in category **`%s`**]],
	noCompanion = [[This lobby doesn't create companion channels]],
	newCompanion = [[Lobbies that will create companion channels in **`%s`**:]],
	resetCompanion = [[Lobbies that will stop createing companion channels:]],
	embedCompanion = [[Select a lobby that will create companion channels in **`%s`**]],
	embedLobbyCompanion = [[Select a lobby to show where it creates companion channels]],
	embedResetCompanion = [[Select a lobby to make it stop creating companion channels]],
	badCompanion = [[Couldn't find specified category]],
	-- limit
	limitationConfirm = [[Your server limit is **`%d`** now]],
	limitationThis = [[Your server limit is **`%d`**]],
	limitationOOB = [[Server limit must be a number between 1 and 500]],
	-- prefix
	prefixConfirm = [[Prefix is **`%s`** now]],
	prefixThis = [[My prefix is **`%s`** or you can mention me]],
	-- name
	changedName = [[Successfully changed channel name!]],
	ratelimitRemaining = [[This command is ratelimited. You can do this **1** more time in next **%s**]],
	ratelimitReached = [[This command is ratelimited. You will be able to perform this command after **%s**]],
	-- resize
	channelResized = [[Successfully changed channel capacity!]],
	-- bitrate
	changedBitrate = [[Successfully changed channel bitrate!]],
	-- promote
	newHost = [[New host assigned]],
	noMember = [[No such user in your channel]],
	-- list
	noLobbies = [[No lobbies registered yet!]],
	someLobbies = [[Registered lobbies on this server:]],
	-- stats
	serverLobby = [[I'm currently on **`1`** server serving **`1`** lobby]],
	serverLobbies = [[I'm currently on **`%d`** server serving **`%d`** lobbies]],
	serversLobby = [[I'm currently on **`%d`** servers serving **`1`** lobby]],
	serversLobbies = [[I'm currently on **`%d`** servers serving **`%d`** lobbies]],
	lobby = [[I'm serving **`1`** lobby on this server]],
	lobbies = [[I'm serving **`%d`** lobbies on this server]],
	channelPerson = [[There is **`1`** new channel with **`1`** person]],
	channelPeople = [[There is **`%d`** new channel with **`%d`** people]],
	channelsPerson = [[There are **`%d`** new channels with **`1`** person]],
	channelsPeople = [[There are **`%d`** new channels with **`%d`** people]],
	ping = [[Ping is **`%d ms`**]],
	
	mentionInVain = [[%s, you need to have "Manage Channels" permission to do this]],
	badInput = [[Couldn't find the specified channel]],
	badServer = [[Couldn't find the specified server]],
	ambiguousID = [[There are several channels with this name]],
	gimmeReaction = [[I can process that, but I need "Manage Messages" and "Add Reactions" permissions for that]],
	badArgument = [[You didn't specify the command]],
	
	-- errors
	badBotPermissions = [[Bot doesn't have sufficient permissions]],
	badUserPermissions = [[You don't have sufficient permissions]],
	badSubcommand = [[Unknown subcommand]],
	noLobbySelected = [[You didn't select a lobby]],
	noCategorySelected = [[You didn't select a category]],
	badChannel = [[Couldn't find the specified channel]],
	badCategory = [[Couldn't find the specified category]],
	
	notLobby = [[This channel is not a lobby:]],
	notHost = [[You're not a channel host]],
	badHostPermission = [[You're not permitted to perform this command]],
	hostError = [[Something went wrong. *And it's probably not my fault*. Poke your admins if this continues to happen]],
	error = [[Something went wrong. *I'm sowwy*. The issue is reported, a fix will arrive soon
https://discord.gg/tqj6jvT]]
}