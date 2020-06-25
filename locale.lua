-- a static storage for everything the bot displays as text to user
-- may be used as a foundation for translation

return {
	help = [[**:arrow_down: You need a "Manage Channels" permission to use those commands! :arrow_down:**
`register` - registers a voice channel that will be used as a lobby. You can feed it channel IDs or channel name
`unregister` - unregisters an existing lobby. You can feed it channel IDs or channel name
`template` - change new channels' name template. Look at `help template` to learn more
`prefix` - set a new prefix for me. Mentioning will still work
**:arrow_up: You need a "Manage Channels" permission to use those commands! :arrow_up:**
`help` - sends this message or information about another commands
`list` - lists all registered lobbies on the server
`stats` - take a sneak peek on my performance!
`support` - sends an invite to support Discord server]],
	register = [[**:arrow_down: You need a "Manage Channels" permission to use this command! :arrow_down:**

`register` OR
`register <channel_name>` OR
`register <channel_id> <channel_id> ...`
Registers a voice channel that will be used as a lobby. Enter this lobby to create a new channel, that will be deleted once it's empty
If you don't provide any arguments, I will send a handy widget with all the channels that you can register]],
	unregister = [[**:arrow_down: You need a "Manage Channels" permission to use this command! :arrow_down:**

`unregister` OR
`unregister <channel_name>` OR
`unregister <channel_id> <channel_id> ...`
Unregisters an existing lobby. New channels that were created by this lobby will be deleted once they are empty, as usual
If you don't provide any arguments, I will send a handy widget with all the channels that I can unregister]],
	template = [[**:arrow_down: You need a "Manage Channels" permission to use this command! :arrow_down:**

`template` OR
`template "<server_id>"`
Displays current global template, that will be used in new channel's name (unless that channel has their own template)

`template "<channel_name>"` OR
`template "<channel_id>"`
Displays current template for the listed channel. A channel template overrides a global one

`template <template_text>`
Sends a handy widget with all the channels that you can apply this template to

`template "global" <template_text>` OR
`template "<server_id>" <template_text>`
Changes the global template

`template "<channel_name>" <template_text>` OR
`template "<channel_id> <channel_id> ..." <template_text>`
Changes the template for listed channels

`template reset "global"` OR
`template reset "<server_id>"`
Resets the global template to default `%nickname's% channel`

`template reset "<channel_name>"` OR
`template reset "<channel_id> <channel_id> ..."`
Removes the template for listed channels so they will use global template

`template reset`
Sends a handy widget that helps you to reset channel template

You can customize a template by including different `%combos%` to it:
`%nickname%` - user's nickname (name is used if no nickname is set)
`%name%` - user's name
`%tag%` - user's tag (for example `Riddles#2773`)
`%nickname's%`,`%name's%` - corresponding combo with **'s** or **'** attached (difference between `Riddles's` and `Riddles'`)]],
	prefix = [[**:arrow_down: You need a "Manage Channels" permission to use this command! :arrow_down:**

`prefix`
Displays the current prefix. Default is !vm

`prefix <new_prefix>` OR
`prefix <server_id> <new_prefix>`
Updates the prefix in the server]],
	list = [[`list` OR
`list <server_id>`
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
	-- register
	registeredOne = [[Registered new lobby:]],
	registeredMany = [[Registered **`%d`** new lobbies:]],
	embedRegister = [[Click on a channel number to register it or :asterisk: to register all available channels]],
	embedRegisterPages = [[Click on a channel number to register it, click :page_facing_up: to register the whole page or :asterisk: to register all available channels]],
	-- unregister
	unregisteredOne = [[Unregistered lobby:]],
	unregisteredMany = [[Unregistered **`%d`** lobbies:]],
	embedUnregister = [[Click on a channel number to unregister it or :asterisk: to unregister all lobbies]],
	embedUnregisterPages = [[Click on a channel number to unregister it, click :page_facing_up: to unregister the whole page or :asterisk: to unregister all lobbies]],
	-- template
	globalTemplate = [[Current global template is **`%s`**]],
	defaultTemplate = [[Your guild uses the default template `%nickname's% channel`]],
	lobbyTemplate = [[Current template for **`%s`** is **`%s`**]],
	noTemplate = [[This lobby doesn't have a custom template]],
	newTemplate = [[Set a new template **`%s`**:]],
	resetTemplate = [[Reset a template:]],
	embedTemplate = [[Click on a lobby number to apply template **`%s`** to it or :asterisk: to apply it to all lobbies]],
	embedTemplatePages = [[Click on a lobby number to apply template **`%s`** to it, click :page_facing_up: to apply it to the whole page or :asterisk: to apply it to all lobbies]],
	embedResetTemplate = [[Click on a lobby number to reset its template or :asterisk: to reset all lobbies]],
	embedResetTemplatePages = [[Click on a lobby number to reset its template, click :page_facing_up: to reset the whole page or :asterisk: to reset all lobbies]],
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
	gimmeReaction = [[I can process that, but I would need "Manage Messages" and "Add Reactions" permissions for that]],
	badBotPermission = [[Couldn't register this channel due to insufficient permissions:]],
	badBotPermissions = [[Couldn't register those channels due to insufficient permissions:]],
	badUserPermissionRegister = [[You're not permitted to register this channel:]],
	badUserPermissionsRegister = [[You're not permitted to register those channels:]],
	badUserPermissionUnregister = [[You're not permitted to unregister this channel:]],
	badUserPermissionsUnregister = [[You're not permitted to unregister those channels:]],
	badChannel = [[This channel is not valid:]],
	badChannels = [[Those channels are not valid:]],
	redundantRegister = [[This channel is already registered:]],
	redundantRegisters = [[Those channels are already registered:]],
	redundantUnregister = [[This channel is not a lobby:]],
	redundantUnregisters = [[Those channels are not a lobby:]],
	notMember = [[You're not a member of this server]],
	onlyInServer = [[I can find channels by name only in server]],
	noID = [[This would work in server, but in DMs you have to include the ID]],
	error = [[Something went wrong. *I'm sowwy*. Can you report this on our support server? Timestamp is %s]]
}