--[[ comments start with "--"
this is a commentary, it's just for you
format is simple - 
	variableName = "text"
or
	variableName = 'text' (if you need to include symbol " in a sentence)
alternatively you can do this
	variableName = "text with \"quotes\" in it"
this will later read as 
	text with "quotes" in it

there are sentences that will change during runtime, such as ping command
they include symbols %s and %d, those will later transform into something else
for example 
	"Registered %d new lobbies:"
will be displayed as 
	Registered 3 new lobbies:
try to fit them in sentences accordingly

don't change the names of variables

commentary ends here]]

return {
	english = {
		names = {
			english = "English"
		},
		commands = {
			help = "help",
			register = "register",
			unregister = "unregister",
			list = "list",
			shutdown = "shutdown",
			stats = "stats",
			support = "support",
			id = "id"
		},
		helpText = 
[[Ping this bot to get help message
Write commands after the mention, for example - `@Voice Manager register 123456789123456780`
**:arrow_down: You need a 'Manage Channels permission to use those commands! :arrow_down:**
`register [voice_chat_id OR voice_chat_name]` - registers a voice chat that will be used as a lobby. You can list several channel IDs
`unregister [voice_chat_id OR voice_chat_name]` - unregisters an existing lobby. You can list several channel IDs
`id [voice_chat_name OR category_name]` - use this to learn ids of voice channels by name or category
**:arrow_up: You need a 'Manage Channels permission to use those commands! :arrow_up:**
`list` - lists all registered lobbies on the server
`stats` - take a sneak peek on bot's performance!
`support` - sends an invite to support Discord server]],
		mentionInVain = '%s, you need to have "Manage Channels" permission to do this',	-- %s = ping, i.e. @Riddles#2773
		emptyInput = "Need an ID or channel name to process that!",
		badInput = "Couldn't find a specified channel",
		registeredOne = "Registered new lobby:",
		registeredMany = "Registered %d new lobbies:",		-- %d = amount of registered lobbies
		unregisteredOne = "Unregistered new lobby:",
		unregisteredMany = "Unregistered %d new lobbies:",	-- same
		channelIDNameCategory = "`%s` -> `%s` in `%s`",		-- channel ID, then name, then category, contact me if you need to change words order
		channelIDName = "`%s` -> `%s`",						-- same, without category
		ambiguousID = "There are several channels with this name",
		bigMessage = "Can't display more than that!",		-- can't be more than 50 characters long, contact me if that's impossible to fit in
		noLobbies = "No lobbies registered yet!",
		someLobbies = "Registered lobbies on this server:",
		
		-- all follow the same format
		serverLobby = "I'm currently on **`%d`** server serving **`%d`** lobby",
		serverLobbies = "I'm currently on **`%d`** server serving **`%d`** lobbies",
		serversLobby = "I'm currently on **`%d`** servers serving **`%d`** lobby",
		serversLobbies = "I'm currently on **`%d`** servers serving **`%d`** lobbies",
		
		-- same
		channelPerson = "There is **`%d`** new channel with **`%d`** person",
		channelPeople = "There is **`%d`** new channel with **`%d`** people",
		channelsPerson = "There are **`%d`** new channels with **`%d`** person",
		channelsPeople = "There are **`%d`** new channels with **`%d`** people",
		
		ping = "Ping is **`%d ms`**",
		badChannel = "This bot can only be used in servers. Mention the bot within the server to get the help message.",
		badPermissions = 'This bot needs "Manage Channels" and "Move Members" permissions to function!',
		error = "Something went wrong. *I'm sowwy*. Can you report this on our support server? Timestamp is %s"		-- %s = date and time
	},
	
	newLang = {
		names = {
			english = ""	-- name of your language in english, for example German or French
		},
		commands = {
			help = "help",
			register = "register",
			unregister = "unregister",
			list = "list",
			shutdown = "shutdown",
			stats = "stats",
			support = "support",
			id = "id"
		},
		helpText = 
[[Ping this bot to get help message
Write commands after the mention, for example - `@Voice Manager register 123456789123456780`
**:arrow_down: You need a 'Manage Channels permission to use those commands! :arrow_down:**
`register [voice_chat_id OR voice_chat_name]` - registers a voice chat that will be used as a lobby. You can list several channel IDs
`unregister [voice_chat_id OR voice_chat_name]` - unregisters an existing lobby. You can list several channel IDs
`id [voice_chat_name OR category_name]` - use this to learn ids of voice channels by name or category
**:arrow_up: You need a 'Manage Channels permission to use those commands! :arrow_up:**
`list` - lists all registered lobbies on the server
`stats` - take a sneak peek on bot's performance!
`support` - sends an invite to support Discord server]],
		mentionInVain = '%s, you need to have "Manage Channels" permission to do this',	-- %s = ping, i.e. @Riddles#2773
		emptyInput = "Need an ID or channel name to process that!",
		badInput = "Couldn't find a specified channel",
		registeredOne = "Registered new lobby:",
		registeredMany = "Registered %d new lobbies:",		-- %d = amount of registered lobbies
		unregisteredOne = "Unregistered new lobby:",
		unregisteredMany = "Unregistered %d new lobbies:",	-- same
		channelIDNameCategory = "`%s` -> `%s` in `%s`",		-- channel ID, then name, then category, contact me if you need to change words order
		channelIDName = "`%s` -> `%s`",						-- same, without category
		ambiguousID = "There are several channels with this name",
		bigMessage = "Can't display more than that!",		-- can't be more than 50 characters long, contact me if that's impossible to fit in
		noLobbies = "No lobbies registered yet!",
		someLobbies = "Registered lobbies on this server:",
		
		-- all follow the same format
		serverLobby = "I'm currently on **`%d`** server serving **`%d`** lobby",
		serverLobbies = "I'm currently on **`%d`** server serving **`%d`** lobbies",
		serversLobby = "I'm currently on **`%d`** servers serving **`%d`** lobby",
		serversLobbies = "I'm currently on **`%d`** servers serving **`%d`** lobbies",
		
		-- same
		channelPerson = "There is **`%d`** new channel with **`%d`** person",
		channelPeople = "There is **`%d`** new channel with **`%d`** people",
		channelsPerson = "There are **`%d`** new channels with **`%d`** person",
		channelsPeople = "There are **`%d`** new channels with **`%d`** people",
		
		ping = "Ping is **`%d ms`**",
		badChannel = "This bot can only be used in servers. Mention the bot within the server to get the help message.",
		badPermissions = 'This bot needs "Manage Channels" and "Move Members" permissions to function!',
		error = "Something went wrong. *I'm sowwy*. Can you report this on our support server? Timestamp is %s"		-- %s = date and time
	}
}