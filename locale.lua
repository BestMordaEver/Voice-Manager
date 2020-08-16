-- a static storage for everything the bot displays as text to user
-- may be used as a foundation for translation

return {
	help = [[You can learn more about each command by using `help`, for example `!vm help template`
	
**:arrow_down: You need a "Manage Channels" permission to use those commands! :arrow_down:**
	
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

**:arrow_up: You need a "Manage Channels" permission to use those commands! :arrow_up:**

**list**
Lists all registered lobbies on the server

**stats**
Take a sneak peek on my performance!

**Links**
[Guide](https://github.com/BestMordaEver/Voice-Manager/wiki/Setup-Guide)
[Support Server](https://discord.gg/tqj6jvT)
]],
	
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

`target "<channel name>"` OR
`target "<channel ID>"`
Displays current target for the listed channel

`target "<channel name>" <target ID>` OR
`target "<channel ID> [channel_id] ..." <target ID>`
Changes the target for listed channels

`target <target ID>`
Sends a handy widget with all the channels that you can apply this target to

`target reset "<channel_name>"` OR
`target reset "<channel_id> [channel_id] ..."`
Removes the target for listed channels

`target reset`
Sends a handy widget with all the channels that you can reset target for]],
	
	template = [[You need a **"Manage Channels"** permission to use this command!

`template` OR
`template "<server ID>"`
Displays current global template, that will be used in new channel's name (unless that channel has their own template)

`template "<channel name>"` OR
`template "<channel ID>"`
Displays current template for the listed channel. A channel template overrides a global one

`template <template text>`
Sends a handy widget with all the channels that you can apply this template to

`template "global" <template text>` OR
`template "<server ID>" <template text>`
Changes the global template

`template "<channel name>" <template text>` OR
`template "<channel ID> [channel_id] ..." <template_text>`
Changes the template for listed channels

`template reset "global"` OR
`template reset "<server ID>"`
Resets the global template to default `%nickname's% channel`

`template reset "<channel_name>"` OR
`template reset "<channel_id> [channel_id] ..."`
Removes the template for listed channels so they will use global template

`template reset`
Sends a handy widget with all the channels that you can reset templates for

You can customize a template by including different `%combos%` to it:
`%nickname%` - user's nickname (name is used if no nickname is set)
`%name%` - user's name
`%nickname's%`,`%name's%` - corresponding combo with **'s** or **'** attached (difference between `Riddles's` and `Riddles'`)
`%tag%` - user's tag (for example `Riddles#2773`)
`%game%` - user's currently played or streamed game ("no game" if user doesn't have a game in their status)]],
	
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
	badBotPermission = [[Bot doesn't have permissions to manage this channel:]],
	badBotPermissions = [[Bot doesn't have permissions to manage those channels:]],
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
	-- template
	globalTemplate = [[Current global template is **`%s`**]],
	defaultTemplate = [[Your guild uses the default template `%nickname's% channel`]],
	lobbyTemplate = [[Current template for **`%s`** is **`%s`**]],
	noTemplate = [[This lobby doesn't have a custom template]],
	newTemplate = [[Set a new template **`%s`**:]],
	resetTemplate = [[Reset a template:]],
	embedTemplate = [[Select a lobby that will have template **`%s`**]],
	embedResetTemplate = [[Select a lobby to reset its template]],
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
	
	badUserPermission = [[You're not permitted to manage this channel:]],
	badUserPermissions = [[You're not permitted to manage those channels:]],
	notLobby = [[This channel is not a lobby:]],
	notLobbies = [[Those channels are not lobbies:]],
	badChannel = [[This channel is not valid:]],
	badChannels = [[Those channels are not valid:]],
	notMember = [[You're not a member of this server]],
	noID = [[I can work only with IDs from DMs]],
	error = [[Something went wrong. *I'm sowwy*. Can you report this on our support server? Timestamp is %s]]
}