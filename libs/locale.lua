-- a static storage for everything the bot displays as text to user
-- may be used as a foundation for translation

return {
	register = [[You need a **"Manage Channels"** permission to use this command!

`register` OR
`register <channel name>` OR
`register <channel ID> [channel ID] ...`

Registers a voice channel that will be used as a lobby. Enter this lobby to create a new channel, that will be deleted once it's empty.
If you don't provide any arguments, I will send a handy widget with all the channels that you can register]],
	
	unregister = [[You need a **"Manage Channels"** permission to use this command!

`unregister` OR
`unregister <channel_name>` OR
`unregister <channel ID> [channel ID] ...`
Unregisters an existing lobby. New channels that were created by this lobby will be deleted once they are empty, as usual
If you don't provide any arguments, I will send a handy widget with all the channels that I can unregister]],
	
	target = [[You need a **"Manage Channels"** permission to use this command!

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

`permissions "<lobby ID>"`
Displays current permissions that will be given to the host

`permissions "<lobby name>" <permission> [permission] ... <on/off>` OR
`permissions "<lobby ID> [lobby ID] ..." <permission> [permission] ... <on/off>`
Changes permissions for listed channels

`permissions <permission> [permission] ... <on/off>`
Sends a handy widget with all the channels that you can change permissions for

You can grant following permissions:
mute - allows to server mute people in channel
deafen - allows to server deafen people in channel
disconnect - allows to disconnect people from channel
manage - allows to manage channel properties
name - allows use of `!vm name`
capacity - allows use of `!vm capacity`
bitrate - allows use of `!vm bitrate`]],
	
	limitation = [[You need a **"Manage Channels"** permission to use this command!

`limitation`
Shows currently set channel limit. Default is 100,000

`limitation <limit>` OR
`limitation <server ID> <limit>`
Changes the channel limit. Must be between 1 and 100,000]],
	
	prefix = [[You need a **"Manage Channels"** permission to use this command!

`prefix`
Displays the current prefix. Default is !vm

`prefix [server ID] <new prefix>`
Updates the prefix in the server]],
	
	name = [[You can enable channel hosts to use this command via `!vm permissions`

`name <new name>`
Changes your current channel's name]],
	
	capacity = [[You can enable channel hosts to use this command via `!vm permissions`

`capacity <number between 0 and 99>`
Changes your current channel's capacity]],
	
	bitrate = [[You can enable channel hosts to use this command via `!vm permissions`

`bitrate <number between 8 and 96>`
Changes your current channel's bitrate]],
	
	promote = [[You need to be a channel host to use this command!
	
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
	-- help
	helpAdminTitle = [[Help | Admin commands]],
	helpHostTitle = [[Help | Host commands]],
	helpUserTitle = [[Help | User commands]],
	helpAdmin = [[You need a "Manage Channels" permission to use those commands!
You can learn more about each command by using `help`, for example `!vm help template`

**register**
Registers a voice channel that will be used as a lobby

**unregister**
Unregisters an existing lobby

**target**
Select where to create new channels

**template**
Change new channels' name template

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
	
	badBotPermission = [[Bot doesn't have permissions to manage this channel:]],
	badBotPermissions = [[Bot doesn't have permissions to manage those channels:]],
	badUserPermission = [[You're not permitted to manage this channel:]],
	badUserPermissions = [[You're not permitted to manage those channels:]],
	notLobby = [[This channel is not a lobby:]],
	notLobbies = [[Those channels are not lobbies:]],
	badChannel = [[This channel is not valid:]],
	badChannels = [[Those channels are not valid:]],
	notMember = [[You're not a member of this server]],
	noID = [[When in DMs, I can only work with IDs]],
	error = [[Something went wrong. *I'm sowwy*. Can you report this on our support server? Timestamp is %s]]
}