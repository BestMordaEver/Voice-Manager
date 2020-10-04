-- a static storage for everything the bot displays as text to user
-- may be used as a foundation for translation

return {
	-- help
	helpLobbyTitle = [[Help | Lobby commands]],
	helpLobby = [[You need a "Manage Channels" permission to use those commands!
You can learn more about each command by using `help`, for example `!vm help template`

**register**
Turns a voice channel into a lobby. Entering this lobby will create a new, temporary channel

**unregister**
Reverts a lobby channel back to a normal channel. Channels created by the existing lobby channel will be deleted once vacant

**target**
Select a category in which new channels will be created

**template**
Change the name of new channels

**permissions**
Give your users control over their new channels]],
	
	helpMatchmakingTitle = [[Help | Matchmaking commands]],
	helpMatchmaking = [[You need a "Manage Channels" permission to use those commands!
You can learn more about each command by using `help`, for example `!vm help template`

**matchmaking target**
Select a lobby that will be matchmade

**matchmaking template**
Select a matchmaking mode]],

	helpHostTitle = [[Help | Host commands]],
	helpHost = [[You need to be a channel host to use those commands!
You can learn more about each command by using `help`, for example `!vm help template`

**whitelist** and **blacklist**
Control who can enter your channel

**name**
Change your channel's name

**capacity**
Change your channel's capacity

**bitrate**
Change your channel's bitrate

**promote**
Transfer your host privileges to other user. Transfer happens automatically if you leave your channel]],
	
	helpServerTitle = [[Help | Server commands]],
	helpServer = [[You need a "Manage Channels" permission to use those commands!
You can learn more about each command by using `help`, for example `!vm help template`

**limitation**
Change how many new channels can be created in your server

**prefix**
Set a new prefix. Mentioning will still work]],

	helpOtherTitle = [[Help | Other commands]],
	helpOther = [[You can learn more about each command by using `help`, for example `!vm help template`
	
**list**
Lists all registered lobbies on the server

**stats**
Take a sneak peek on my performance!

**support**
Get a support server invite]],

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

You can also use **<prefix> target <category ID or name>** to be given a list of lobbies that you can change target for

**• Example**
!vm target "Join to connect to random party" Join to create new channel
!vm target "759657662773330022" 759657549745750026
!vm target "759657662773330022 759213923588112406" 759657549745750026]],
	
	template = [[You need a **"Manage Channels"** permission to use this command!
Change the name of new channels

**• Usage**
*(Show the current template for the provided channel)*
<prefix> template "<channel ID or name>"

*(Change the template for the provided channels)*
<prefix> template "<channel ID or name>" <template text> *OR*
<prefix> template "<channel ID> [channel ID] ..." <template text>

You can also use **<prefix> template <template text>** to be given a list of lobbies that you can change template for

You can customize a template by including different `%combos%` to it:
**%nickname%** - user's nickname (name is used if no nickname is set)
**%name%** - user's name
**%nickname's%**, **%name's%** - corresponding combo with **'s** or **'** attached (difference between **Riddles's** and **Riddles'**)
**%tag%** - user's tag (for example **Riddles#2773**)
**%game%** - user's currently played or streamed game ("no game" if user doesn't have a game in their status)
**%counter%** - channel's position. The channel will be moved to fill in holes in numbering

**• Example**
!vm template "Join to create new channel" %nickname's% funky place
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

You can also use **<prefix> permissions <permission> [permission] ... <on/off>** to be given a list of lobbies that you can change permissions for

You can grant following permissions:
**mute** - allows use of host command **mute**
**moderate** - allows to disconnect people from channel and allows use of host commands **blacklist** and **whitelist**
**manage** - gives user "Manage Channel" permission and gives access to next three commands
**name** - allows use of host command **name**
**capacity** - allows use of host command **capacity**
**bitrate** - allows use of host command **bitrate**

**• Example**
!vm permissions "Join to create new channel" mute moderate manage on
!vm permissions "759657662773330022" manage off
!vm permissions "759657662773330022 759213923588112406" moderate name on]],
	
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

You can also use **<prefix> target <target channel ID or name>** to be given a list of lobbies that you can change matchmaking target for

**• Example**
!vm target "Join to connect to random party" Join to create new channel
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

You can also use **<prefix> template <matchmaking mode>** to be given a list of lobbies that you can change matchmaking template for

There are several matchmaking modes available:
**random** - selects a random channel, default mode of operation
**first** - selects the first available channel
**last** - selects the last available channel
**max** - selects the most filled available channel
**min - select the least filled available channel

**• Example**
!vm template "Join to connect to random party" random
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

**• Usage**
<prefix> name <new name>

**Changing channel name is currently ratelimited by Discord!** Bots can't change channel name more often than 2 times per 10 minutes, so use this command wisely

**• Example**
!vm name We respect women in this chatroom]],
	
	capacity = [[You need to be a channel host to use this command!
This command is enabled with permission "capacity"

Change your channel's capacity

**• Usage**
<prefix> capacity <number between 0 and 99>

**• Example**
!vm capacity 4]],
	
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
	limitation = [[You need a **"Manage Channels"** permission to use this command!
Change how many new channels can be created in your server. Absolute maximum is 100,000

**• Usage**
*(Show the current channel limit in your server)*
<prefix> limitation

*(Change the current channel limit in your server)*
<prefix> limitation [server ID] <number between 0 and 100,000>

**• Example**
!vm limitation 20
!vm limitation 759657662773330022 100]],
	
	prefix = [[You need a **"Manage Channels"** permission to use this command!
Set a new prefix. Mentioning will still work

**• Usage**
*(Show the current prefix. Default is !vm)*
<prefix> prefix

*(Change the prefix in your server)*
prefix [server ID] <new prefix>

**• Example**
!vm prefix vm/
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
	resetTarget = [[Reset a target:]],
	embedTarget = [[Select a lobby that will have target **`%s`**]],
	embedResetTarget = [[Select a lobby to reset its target]],
	badCategory = [[Couldn't find the category to target]],
	-- template
	lobbyTemplate = [[Current template for **`%s`** is **`%s`**]],
	noTemplate = [[This lobby doesn't have a custom template]],
	newTemplate = [[Set a new template **`%s`** for:]],
	resetTemplate = [[Reset a template:]],
	embedTemplate = [[Select a lobby that will have template **`%s`**]],
	embedResetTemplate = [[Select a lobby to reset its template]],
	-- permissions
	lobbyPermissions = [[Current lobby permissions for **`%s`** include: **`%s`**]],
	newPermissions = [[Added new permissions **`%s`** for:]],
	revokedPermissions = [[Revoked permissions **`%s`**:]],
	resetPermissions = [[Reset permissions:]],
	embedAddPermissions = [[Select a lobby that will receive listed permissions]],
	embedRemovePermissions = [[Select a lobby that will lose listed permissions]],
	noPermission = [[There's no such permission]],
	noToggle = [[No toggle found]],
	-- limitation
	limitationConfirm = [[Your server limit is **`%d`** now]],
	limitationThis = [[Your server limit is **`%d`**]],
	limitationOOB = [[Server limit must be a number between 10,000 and 1]],
	-- prefix
	prefixConfirm = [[Prefix is **`%s`** now]],
	prefixThis = [[My prefix is **`%s`** or you can mention me]],
	-- name
	changedName = [[Successfully changed channel name!]],
	ratelimitRemaining = [[This action is ratelimited. You can do this **1** more time in next **%s**]],
	ratelimitReached = [[This action is ratelimited. You will be able to perform this action after **%s**]],
	-- capacity
	changedCapacity = [[Successfully changed channel capacity!]],
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
	badArgument = [[You didn't specify the action]],
	
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
	badHostPermission = [[You're not permitted to perform this action]],
	hostError = [[Something went wrong. *And it's probably not my fault*. Poke your admins if this continues to happen]],
	error = [[Something went wrong. *I'm sowwy*. The issue is reported, a fix will arrive soon
https://discord.gg/tqj6jvT]]
}