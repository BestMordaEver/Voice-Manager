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
	
	-- lobbies
	lobbiesInfoTitle = [[Lobbies info | %s]],
	lobbiesNoInfo = [[There are no registered lobbies
You can register a lobby with `register`]],
	lobbiesInfo = [[Select lobbies to change their settings]],
	lobbiesField = [[**Target:** %s
**Template:** %s
**Permissions:** %s
**Capacity:** %d
**Companion:** %s
**Channels:** %d]],

	limitBadInput = [[Limit must be a number between 0 and 500]],
	limitConfirm = [[New limit set!]],
	roleBadInput = [[Couldn't find the specified role]],
	roleConfirm = [[New managed role set!]],
	permissionsBadInput = [[Unknown permission: %s]],
	permissionsConfirm = [[New permissions set!]],
	prefixConfirm = [[New prefix set: %s]],
	
	-- matchmaking
	matchmakingInfoTitle = [[Matchmaking info | %s]],
	matchmakingNoInfo = [[There are not registered matchmaking lobbies
You can create a matchmaking lobby with `match`]],
	matchmakingField = [[**Target:** %s
**Mode:** %s
**Channels:** %d]],

	-- companion
	companionInfoTitle = [[Companion settings | %s]],
	companionNoInfo = [[There are no lobbies with enabled companion channels
You can enable companion channels with `companion`]],
	companionField = [[**Target:** %s
**Template:** %s
**Permissions:** %s
**Companion channels:** %d]],
	
	-- lobby
	register = [[You need the **Manage Channels** permission in order to use this command

Turns a voice channel into a lobby. Entering this lobby will create a new, temporary channel

**• Usage**
*(Create a single lobby channel)*
<prefix> register <channel ID or name>

*(Create multiple lobby channels)*
<prefix> register <channel ID> [channel ID] ...

You can also use **<prefix> register** to be given a list of channels that can be turned into lobbies

**• Example**
!vm register Join to create new channel
!vm register 759657662773330022
!vm register 759657662773330022 759213923588112406]],
	
	unregister = [[You need the **Manage Channels** permission in order to use this command

Reverts a lobby channel back to a normal channel. Channels created by the existing lobby channel will be deleted once vacant

**• Usage**
*(Unregister a single lobby channel)*
<prefix> unregister <channel ID or name>

*(Unregister multiple lobby channels)*
<prefix> unregister <channel ID> [channel ID] ...

You can also use **<prefix> unregister** to be given a list of lobbies that can be reverted into normal channels

**• Example**
!vm unregister Join to create new channel
!vm unregister 759657662773330022
!vm unregister 759657662773330022 759213923588112406]],
	
	target = [[You need the **Manage Channels** permission in order to use this command
Select the category where new channels will be created

**• Usage**
*(Show the current target for the provided channel)*
<prefix> target "<channel ID or name>"

*(Change the target for the provided channels)*
<prefix> target "<channel ID or name>" <category ID or name> *OR*
<prefix> target "<channel ID> [channel ID] ..." <category ID or name>

*(Reset the target to default for the provided channels)*
<prefix> reset target <channel ID or name> *OR*
<prefix> reset target <channel ID> [channel ID] ...

You can also use **<prefix> [reset] target <category ID or name>** to be given a list of lobbies that you can change target for

**• Example**
!vm target "Join to create new channel" Lobbies
!vm reset target Join to create new channel
!vm target "759657662773330022" 759657549745750026
!vm target "759657662773330022 759213923588112406" 759657549745750026]],
	
	companion = [[You need the **Manage Channels** permission in order to use this command
Create private text chats alongside new channels. Those text channels are accessible only to those currently in a corresponding voice channel

**• Usage**
*(Show where provided lobby will create companion channels)*
<prefix> companion "<channel ID or name>"

*(Change where provided lobby will create companion channels)*
<prefix> companion "<channel ID or name>" <category ID or name> *OR*
<prefix> companion "<channel ID> [channel ID] ..." <category ID or name>

*(Disable companion channels for provided lobbies)*
<prefix> reset companion <channel ID or name> *OR*
<prefix> reset companion <channel ID> [channel ID] ...

You can also use **<prefix> [reset] companion <category ID or name>** to be given a list of lobbies that you can change companion target for

**• Example**
!vm companion "Join to start new session" Lobbies
!vm reset companion Join to start new session
!vm companion "759657662773330022" 759657549745750026
!vm companion "759657662773330022 759213923588112406" 759657549745750026]],
	
	template = [[You need a **"Manage Channels"** permission to use this command!
Change the name of new channels

**• Usage**
*(Show the current template for the provided channel)*
<prefix> template "<channel ID or name>"

*(Change the template for the provided channels)*
<prefix> template "<channel ID or name>" <template text> *OR*
<prefix> template "<channel ID> [channel ID] ..." <template text>

*(Reset the template to default for the provided channels)*
<prefix> reset template <channel ID or name> *OR*
<prefix> reset template <channel ID> [channel ID] ...

You can also use **<prefix> [reset] template <template text>** to be given a list of lobbies that you can change template for

You can customize a template by including different `%combos%` to it:
**%nickname%** - user's nickname (name is used if no nickname is set)
**%name%** - user's name
**%nickname's%**, **%name's%** - corresponding combo with **'s** or **'** attached (difference between **Riddles's** and **Riddles'**)
**%tag%** - user's tag (for example **Riddles#2773**)
**%game%** - user's currently played or streamed game ("no game" if user doesn't have a game in their status)
**%counter%** - channel's position. The channel will be moved to fill in holes in numbering
**%rename%** - doesn't actually change the channel name, but interacts with **!vm name**. Read **!vm help name** for more info on that

**• Example**
!vm template "Join to create new channel" %nickname's% funky place
!vm reset target Join to create new channel
!vm template "759657662773330022" Raid room %counter%
!vm template "759657662773330022 759213923588112406" %game% - Room %counter%]],
	
	permissions = [[You need a **"Manage Channels"** permission to use this command!
Give your users control over their new channels

**• Usage**
*(Show the current permissions for the provided channel)*
<prefix> permissions "<channel ID or name>"

*(Change the permissions for the provided channels)*
<prefix> permissions "<channel ID or name>" <permission> [permission] ... <on/off> *OR*
<prefix> permissions "<channel ID> [channel ID] ..." <permission> [permission] ... <on/off>

*(Reset the permissions to default for the provided channels)*
<prefix> reset permissions <channel ID or name> *OR*
<prefix> reset permissions <channel ID> [channel ID] ...

You can also use **<prefix> [reset] permissions <permission> [permission] ... <on/off>** to be given a list of lobbies that you can change permissions for

You can grant following permissions:
**mute** - allows use of host command **mute**
**moderate** - allows to disconnect people from channel and allows use of host commands **blacklist** and **whitelist**
**manage** - gives user "Manage Channel" permission and gives access to next three commands
**name** - allows use of host command **name**
**resize** - allows use of host command **resize**
**bitrate** - allows use of host command **bitrate**

**• Example**
!vm permissions "Join to create new channel" mute moderate manage on
!vm reset permissions Join to create new channel
!vm permissions "759657662773330022" manage off
!vm permissions "759657662773330022 759213923588112406" moderate name on]],

	capacity = [[You need the **Manage Channels** permission in order to use this command
Specify the planned capacity new channels will have. By default, new channels will imitate their lobby's capacity

**• Usage**
*(Show the planned capacity for the provided channel)*
<prefix> capacity "<channel ID or name>"

*(Change the planned capacity for the provided channels)*
<prefix> capacity "<channel ID or name>" <number between 0 and 99> *OR*
<prefix> capacity "<channel ID> [channel ID] ..." <number between 0 and 99>

*(Reset the capacity to default for the provided channels)*
<prefix> reset capacity <channel ID or name> *OR*
<prefix> reset capacity <channel ID> [channel ID] ...

You can also use **<prefix> [reset] capacity <number between 0 and 99>** to be given a list of lobbies that you can change planned capacity for

**• Example**
!vm capacity "Join to connect to random party" 4
!vm reset capacity Join to connect to random party
!vm capacity "759657662773330022" 10
!vm capacity "759657662773330022 759213923588112406" 2]],
	
	-- matchmaking
	["matchmaking target"] = [[You need a **"Manage Channels"** permission to use this command!
Turns a lobby into a matchmaking lobby. Entering this lobby will join you to one of existing new channels. Bot will respect channel capacity and whitelists/blacklists
Both matchmaking target and matchmaking lobby must be registered lobbies!

**• Usage**
*(Show the current matchmaking target for the provided channel)*
<prefix> target "<channel ID or name>"

*(Change the matchmaking target for the provided channels)*
<prefix> target "<channel ID or name>" <target channel ID or name> *OR*
<prefix> target "<channel ID> [channel ID] ..." <target channel ID or name>

*(Reset the target to default for the provided channels. This turns matchmaking lobby into a normal lobby)*
<prefix> reset target <channel ID or name> *OR*
<prefix> reset target <channel ID> [channel ID] ...

You can also use **<prefix> [reset] target <target channel ID or name>** to be given a list of lobbies that you can change matchmaking target for

**• Example**
!vm target "Join to connect to random party" Join to create new channel
!vm target reset Join to connect to random party
!vm target "759657662773330022" 759657549745750026
!vm target "759657662773330022 759213923588112406" 759657549745750026]],
	
	["matchmaking template"] = [[You need a **"Manage Channels"** permission to use this command!
Change matchmaking mode for matchmaking lobby. This will determine how bot will match users

**• Usage**
*(Show the current matchmaking mode for the provided channel)*
<prefix> template "<channel ID or name>"

*(Change the matchmaking mode for the provided channels)*
<prefix> template "<channel ID or name>" <matchmaking mode> *OR*
<prefix> template "<channel ID> [channel ID] ..." <matchmaking mode>

*(Reset the matchmaking template to default for the provided channels)*
<prefix> reset template <channel ID or name> *OR*
<prefix> reset template <channel ID> [channel ID] ...

You can also use **<prefix> [reset] template <matchmaking mode>** to be given a list of lobbies that you can change matchmaking template for

There are several matchmaking modes available:
**random** - selects a random channel, default mode
**first** - selects the first available channel
**last** - selects the last available channel
**max** - selects the most filled available channel
**min** - select the least filled available channel

**• Example**
!vm template "Join to connect to random party" random
!vm template reset Join to connect to random party
!vm template "759657662773330022" max
!vm template "759657662773330022 759213923588112406" min]],
	
	-- host
	blacklist = [[You need to be a channel host to use this command!
This command is enabled with permission "moderate"
**This command will conflict with `whitelist` command!**

Restrict specific users from entering your channel

**• Usage**
*(Restrict mentioned users from connecting to your channel)*
<prefix> blacklist [add] <user mention> [user mention] ...

*(Allow mentioned users to connect again)*
<prefix> blacklist remove <user mention> [user mention] ...

*(Remove all restrictions)*
<prefix> blacklist clear

**• Example**
!vm blacklist @heckingtroll @urmom @nastydude
!vm blacklist remove @dudebro123]],
	
	whitelist = [[You need to be a channel host to use this command!
This command is enabled with permission "moderate"
**This command will conflict with `blacklist` command!**

Let only specific people to enter your channels and restrict everybody else

**• Usage**
*(Whitelist all the people who are already in the lobby)*
<prefix> whitelist lock

*(Allow all mentioned users to connect)*
<prefix> whitelist [add] <user mention> [user mention] ...

*(Restrict the mentioned users from connecting to your channel again)*
<prefix> whitelist remove <user mention> [user mention] ...

*(Remove all restrictions)*
<prefix> whitelist clear

**• Example**
!vm whitelist @wumpus @atrustworthysnail
!vm whitelist remove @nastydude]],
	
	mute = [[You need to be a channel host to use this command!
This command is enabled with permission "mute"

Restrict people from talking in your lobby

**• Usage**
*(Restrict mentioned users from talking in your channel)*
<prefix> mute [add] <user mention> [user mention] ...

*(Allow mentioned users to talk in your channel again)*
<prefix> mute remove <user mention> [user mention] ...

*(Unmute everybody in your channel)*
<prefix> mute clear

**• Example**
!vm mute @ispeaktoomuch @theloudeater @constructionworker
!vm mute remove @sneezy]],

	name = [[You need to be a channel host to use this command!
This command is enabled with permission "name"

Change your channel's name
If channel's template has %rename% combo, then only %rename% part will change

**• Usage**
<prefix> name <new name>

**Changing channel name is currently ratelimited by Discord!** Bots can't change channel name more often than 2 times per 10 minutes, so use this command wisely

**• Example**
!vm name Cozy place]],
	
	resize = [[You need to be a channel host to use this command!
This command is enabled with permission "resize"

Change your channel's capacity

**• Usage**
<prefix> resize <number between 0 and 99>

**• Example**
!vm resize 4]],
	
	bitrate = [[You need to be a channel host to use this command!
This command is enabled with permission "bitrate"

Change your channel's bitrate

**• Usage**
<prefix> bitrate <number between 8 and 96>

**• Example**
!vm bitrate 96]],
	
	promote = [[You need to be a channel host to use this command!

Transfer all your host privileges to other user. Transfer happens automatically if you leave your channel

**• Usage**
<prefix> promote <user mention>

**• Example**
!vm promote @atrustworthysnail]],
	
	-- server
	limit = [[You need a **"Manage Channels"** permission to use this command!
Change how many new channels can be created in your server. Absolute maximum is 500

**• Usage**
*(Show the current channel limit in your server)*
<prefix> limit

*(Change the current channel limit in your server)*
<prefix> limit [server ID] <number between 0 and 500>

*(Reset the channel limit to default)*
<prefix> reset limit [server ID]

**• Example**
!vm limit 20
!vm reset limit
!vm limit 759657662773330022 100]],
	
	prefix = [[You need a **"Manage Channels"** permission to use this command!
Set a new prefix. Mentioning will still work

**• Usage**
*(Show the current prefix. Default is !vm)*
<prefix> prefix

*(Change the prefix in your server)*
prefix [server ID] <new prefix>

*(Reset the prefix to default)*
<prefix> reset prefix [server ID]

**• Example**
!vm prefix vm/
!vm reset prefix
!vm prefix 759657662773330022 According to all known laws of aviation, there is no way a bee should be able to fly. Its wings are too small to get its fat little body off the ground. The bee, of course, flies anyway because bees don't care what humans think is impossible. Yellow, black. Yellow, black. Yellow, black. Yellow, black. Ooh, black and yellow! Let's shake it up a little. Barry! Breakfast is ready! Coming! Hang on a second. Hello? - Barry? - Adam? - Can you believe this is happening? - I can't. I'll pick you up. Looking sharp. Use the stairs. Your father paid good money for those. Sorry. I'm excited.]],
	
	-- user
	list = [=[Show all lobbies in the server
<prefix> list [server ID]]=],
	
	stats = [[Show global bot stats
<prefix> stats

Show stats for you server
<prefix> stats local

Show stats for specific server
<prefix> stats <server_id>]],
	
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
	badPermissions = [[You don't have required permissions]],
	badSubcommand = [[Unknown subcommand]],
	
	badBotPermission = [[Bot doesn't have permissions to manage this channel:]],
	badBotPermissions = [[Bot doesn't have permissions to manage those channels:]],
	badUserPermission = [[You're not permitted to manage this channel:]],
	badUserPermissions = [[You're not permitted to manage those channels:]],
	notLobby = [[This channel is not a lobby:]],
	notLobbies = [[Those channels are not lobbies:]],
	badChannel = [[This channel is not valid:]],
	badChannels = [[Those channels are not valid:]],
	notMember = [[You're not a member of this server]],
	noID = [[I can't process this input in DMs]],
	notHost = [[You're not a channel host]],
	badHostPermission = [[You're not permitted to perform this command]],
	hostError = [[Something went wrong. *And it's probably not my fault*. Poke your admins if this continues to happen]],
	error = [[Something went wrong. *I'm sowwy*. The issue is reported, a fix will arrive soon
https://discord.gg/tqj6jvT]]
}