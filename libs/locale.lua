-- a static storage for everything the bot displays as text to user
-- may be used as a foundation for translation

return {
	-- help
	helpAdminTitle = [[Help | Admin commands]],
	helpHostTitle = [[Help | Host commands]],
	helpUserTitle = [[Help | User commands]],
	helpAdmin = [[You need a "Manage Channels" permission to use those commands!
You can learn more about each command by using `help`, for example `!vm help template`

**register**
Registers a voice channel that will be used as a lobby. Enter this lobby to create a new channel, that will be deleted once it's empty.

**unregister**
Unregisters an existing lobby. New channels that were created by this lobby will be deleted once they are empty, as usual

**target**
Select a category in which new channels will be created

**template**
Change new channels' name template

**permissions**
Give your users control over their new channels

**limitation**
Change how many new channels can be created in your server

**prefix**
Set a new prefix. Mentioning will still work

**Links**
[Setup Guide](https://github.com/BestMordaEver/Voice-Manager/wiki/Setup-Guide)
[User Guide](https://github.com/BestMordaEver/Voice-Manager/wiki/User-Guide)
[Glossary](https://github.com/BestMordaEver/Voice-Manager/wiki/Glossary)
[Support Server](https://discord.gg/tqj6jvT)]],
	helpHost = [[You need to be a channel host to use those commands!
You can learn more about each command by using `help`, for example `!vm help template`

**ban**
Keep those nasty trolls out of your lobby

**name**
Change your channel's name

**capacity**
Change your channel's capacity

**bitrate**
Change your channel's bitrate

**promote**
Transfer your host privileges to other user. Transfer happens automatically if you leave your channel

**Links**
[Setup Guide](https://github.com/BestMordaEver/Voice-Manager/wiki/Setup-Guide)
[User Guide](https://github.com/BestMordaEver/Voice-Manager/wiki/User-Guide)
[Glossary](https://github.com/BestMordaEver/Voice-Manager/wiki/Glossary)
[Support Server](https://discord.gg/tqj6jvT)]],
	helpUser = [[You can learn more about each command by using `help`, for example `!vm help template`
	
**list**
Lists all registered lobbies on the server

**stats**
Take a sneak peek on my performance!

**Links**
[Setup Guide](https://github.com/BestMordaEver/Voice-Manager/wiki/Setup-Guide)
[User Guide](https://github.com/BestMordaEver/Voice-Manager/wiki/User-Guide)
[Glossary](https://github.com/BestMordaEver/Voice-Manager/wiki/Glossary)
[Support Server](https://discord.gg/tqj6jvT)]],
	register = [[You need a **"Manage Channels"** permission to use this command!
Register a voice channel that will be used as a lobby. Enter this lobby to create a new channel, that will be deleted once it's empty.

`register`
Sends a handy widget with all the channels that you can register

`register <channel name>` OR
`register <channel ID> [channel ID] ...`
Registers all listed channels]],
	
	unregister = [[You need a **"Manage Channels"** permission to use this command!
Unregister an existing lobby. New channels that were created by this lobby will be deleted once they are empty, as usual

`unregister`
Sends a handy widget with all the channels that you can unregister

`unregister <channel_name>` OR
`unregister <channel ID> [channel ID] ...`
Unregisters all listed channels]],
	
	target = [[You need a **"Manage Channels"** permission to use this command!
Select a category in which new channels will be created

`target "<lobby name>"` OR
`target "<lobby ID>"`
Displays current target for the listed channel

`target "<lobby name>" <category ID>` OR
`target "<lobby name>" <category name>` OR
`target "<lobby ID> [lobby ID] ..." <category ID>`
`target "<lobby ID> [lobby ID] ..." <category name>`

Changes the target for listed channels

`target <category ID>`
Sends a handy widget with all the channels that you can apply this target to]],
	
	template = [[You need a **"Manage Channels"** permission to use this command!
Change new channels' name template

`template "<lobby name>"` OR
`template "<lobby ID>"`
Displays current template for the listed channel. A channel template overrides a global one

`template "<lobby name>" <template text>` OR
`template "<lobby ID> [lobby ID] ..." <template_text>`
Changes the template for listed channels

`template <template text>`
Sends a handy widget with all the channels that you can apply this template to

You can customize a template by including different `%combos%` to it:
`%nickname%` - user's nickname (name is used if no nickname is set)
`%name%` - user's name
`%nickname's%`,`%name's%` - corresponding combo with **'s** or **'** attached (difference between `Riddles's` and `Riddles'`)
`%tag%` - user's tag (for example `Riddles#2773`)
`%game%` - user's currently played or streamed game ("no game" if user doesn't have a game in their status)
`%counter%` - channel's position. The channel will be moved to fill in holes in numbering]],
	
	permissions = [[You need a **"Manage Channels"** permission to use this command!
Give your users control over their new channels

`permissions "<lobby ID>"`
Displays current permissions that will be given to the host

`permissions "<lobby name>" <permission> [permission] ... <on/off>` OR
`permissions "<lobby ID> [lobby ID] ..." <permission> [permission] ... <on/off>`
Changes permissions for listed channels

`permissions <permission> [permission] ... <on/off>`
Sends a handy widget with all the channels that you can change permissions for

You can grant following permissions:
mute - allows use of `!vm mute`
moderate - allows to disconnect people from channel and allows use of `!vm blacklist` and `!vm whitelist`
manage - gives user "Manage Channel" permission and gives access to next three commands
name - allows use of `!vm name`
capacity - allows use of `!vm capacity`
bitrate - allows use of `!vm bitrate`]],
	
	limitation = [[You need a **"Manage Channels"** permission to use this command!
Change how many new channels can be created in your server

`limitation`
Shows currently set channel limit. Default is 100,000

`limitation <limit>` OR
`limitation <server ID> <limit>`
Changes the channel limit. Must be between 1 and 100,000]],
	
	prefix = [[You need a **"Manage Channels"** permission to use this command!
Set a new prefix. Mentioning will still work

`prefix`
Displays the current prefix. Default is !vm

`prefix [server ID] <new prefix>`
Updates the prefix in the server]],
	
	blacklist = [[You need to be a channel host to use this command!
This command is enabled with permission "moderate"
**This command will conflict with `whitelist` command!**

`blacklist <user mention> [user mention] ...` OR
`blacklist add <user mention> [user mention] ...`
Restricts mentioned users from connecting to your channel

`blacklist remove <user mention> [user mention] ...`
Removes restriction for mentioned users

`blacklist clear`
Removes all restrictions]],
	
	whitelist = [[You need to be a channel host to use this command!
This command is enabled with permission "moderate"
**This command will conflict with `blacklist` command!**

`whitelist lock`
Whitelist all the people who are already in the lobby

`whitelist <user mention> [user mention] ...` OR
`whitelist add <user mention> [user mention] ...`
Whitelists all mentioned users

`whitelist remove <user mention> [user mention] ...`
Removes all mentioned users from whitelist

`whitelist clear`
Disables the whitelist]],
	
	mute = [[You need to be a channel host to use this command!
This command is enabled with permission "mute"

`mute <user mention> [user mention] ...` OR
`mute add <user mention> [user mention] ...`
Mutes mentioned users when they enter your channel

`mute remove <user mention> [user mention] ...`
Unmutes all mentioned users

`mute clear`
Unmutes all users]],

	name = [[You need to be a channel host to use this command!
This command is enabled with permission "name"

`name <new name>`
Changes your current channel's name

**Changing channel name is currently ratelimited by Discord!** Bots can't change channel name more often than 2 times per 10 minutes, so use this command wisely.]],
	
	capacity = [[You need to be a channel host to use this command!
This command is enabled with permission "capacity"

`capacity <number between 0 and 99>`
Changes your current channel's capacity]],
	
	bitrate = [[You need to be a channel host to use this command!
This command is enabled with permission "bitrate"

`bitrate <number between 8 and 96>`
Changes your current channel's bitrate]],
	
	promote = [[You need to be a channel host to use this command!
Transfer your host privileges to other user. Transfer happens automatically if you leave your channel
	
`promote <user mention>`
Transfers all host privileges to mentioned user]],
	
	list = [[`list [server ID]`
Lists all registered lobbies on the server]],
	
	stats = [[`stats`
Sends general stats

`stats local`
Sends stast for you server

`stats <server_id>`
Sends stats for specific server]],
	-- utility
	channelNameCategory = [[`%s` in `%s`]],
	embedPages = [[Page %d of %d]],
	embedDelete = [[❌ - delete this message]],
	embedTip = [[<> - required, [] - optional]],
	embedPage = [[Click :page_facing_up: to select the whole page]],
	embedAll = [[Click :asterisk: to select all available channels]],
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
	newTarget = [[Set a new target **`%s`**:]],
	resetTarget = [[Reset a target:]],
	embedTarget = [[Select a lobby that will have target **`%s`**]],
	embedResetTarget = [[Select a lobby to reset its target]],
	badCategory = [[Couldn't find the category to target]],
	-- template
	lobbyTemplate = [[Current template for **`%s`** is **`%s`**]],
	noTemplate = [[This lobby doesn't have a custom template]],
	newTemplate = [[Set a new template **`%s`**:]],
	resetTemplate = [[Reset a template:]],
	embedTemplate = [[Select a lobby that will have template **`%s`**]],
	embedResetTemplate = [[Select a lobby to reset its template]],
	-- permissions
	lobbyPermissions = [[Current lobby permissions for **`%s`** include: **`%s`**]],
	newPermissions = [[Added new permissions **`%s`**:]],
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
	error = [[Something went wrong. *I'm sowwy*. The issue was reported already, fix will eventually happen]]
}