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

local locale = {
	english = {
		availableLanguages = "I can speak those languages:",	-- add yours here
		helpText = 
[[Ping me to get help message
Write commands after the mention, for example - `@Voice Manager register 123456789123456780`
**:arrow_down: You need a 'Manage Channels permission to use those commands! :arrow_down:**
`register [voice_chat_id OR voice_chat_name]` - registers a voice chat that will be used as a lobby. You can list several channel IDs
`unregister [voice_chat_id OR voice_chat_name]` - unregisters an existing lobby. You can list several channel IDs
`id [voice_chat_name OR category_name]` - use this to learn ids of voice channels by name or category
`prefix [new_prefix]` - set a new prefix for me. Mentioning will still work
`language [new_language]` - change my language
**:arrow_up: You need a 'Manage Channels permission to use those commands! :arrow_up:**
`list` - lists all registered lobbies on the server
`stats` - take a sneak peek on my performance!
`support` - sends an invite to support Discord server]],
		mentionInVain = '%s, you need to have "Manage Channels" permission to do this',	-- %s = ping, i.e. @Riddles#2773
		emptyInput = "Need an ID or channel name to process that!",
		badInput = "Couldn't find a specified channel",
		registeredOne = "Registered new lobby:",
		registeredMany = "Registered %d lobbies:",		-- %d = amount of registered lobbies
		unregisteredOne = "Unregistered lobby:",
		unregisteredMany = "Unregistered %d new lobbies:",	-- same
		channelIDNameCategory = "`%s` -> `%s` in `%s`",		-- channel ID, then name, then category, contact me if you need to change words order
		channelIDName = "`%s` -> `%s`",						-- same, without category
		ambiguousID = "There are several channels with this name",
		bigMessage = "Can't display more than that!",		-- can't be more than 50 characters long, contact me if that's impossible to fit in
		noLobbies = "No lobbies registered yet!",
		someLobbies = "Registered lobbies on this server:",
		updatedLocale = "Language updated to English",		-- should be your corresponding language
		prefixConfirm = "Prefix is **`%s`** now",
		prefixThis = "My prefix is **`%s`** or you can mention me",
		prefixAbsent = "There is no active prefix, but you can always mention me",
		
		-- all follow the same format, it's ok if you need to write the same things twice
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
		badPermissions = 'I need "Manage Channels" and "Move Members" permissions to function!',
		error = "Something went wrong. *I'm sowwy*. Can you report this on our support server? Timestamp is %s"		-- %s = date and time
	},
	
	russian = {
		availableLanguages = "Я разговариваю на таких языках:",
		helpText = 
[[Упомяните меня, чтобы получить сообщение со списком команд
Пишите команды после упоминания, например - `@Voice Manager register 123456789123456780`
**:arrow_down: Вам потребуются права 'Управлять каналами' для использования этих команд! :arrow_down:**
`register [идентификатор_голосового_канала ИЛИ название_голосового_канала]` - регистрирует голосовой чат, который будет использоваться как лобби. Можно указывать несколько идентификаторов одновременно
`unregister [идентификатор_голосового_канала ИЛИ название_голосового_канала]` - удаляет голосовой канал из списка лобби сервера. Можно указывать несколько идентификаторов одновременно
`id [название_голосового_канала ИЛИ название_категории]` - перечисляет идентификаторы названых голосовых чатов ИЛИ идентификаторы голосовых чатов названой категории
**:arrow_up: Вам потребуются права 'Управлять каналами' для использования этих команд! :arrow_up:**
`list` - перечисляет все зарегестрированные лобби на этом сервере
`stats` - показывает статистику
`support` - отправляет приглашение на сервер поддержки]],
		mentionInVain = '%s, вам требуются права "Управление каналами" чтобы сделать это',
		emptyInput = "Скажите мне идентификатор или название канала чтобы я мог с ним хоть что-то сделать",
		badInput = "Я не смог найти указанный канал",
		registeredOne = "Зарегистрировал новое лобби:",
		registeredMany = "Зарегистрировал %d новых лобби:",
		unregisteredOne = "Удалил лобби:",
		unregisteredMany = "Удалил %d лобби:",
		channelIDNameCategory = "`%s` -> `%s` в `%s`",
		channelIDName = "`%s` -> `%s`",
		ambiguousID = "Несколько голосовых каналов имеют такое название",
		bigMessage = "Я так много не могу выговорить!",
		noLobbies = "Тут не зарегистрировано еще ни одного лобби!",
		someLobbies = "Зарегистрированные лобби этого сервера:",
		updatedLocale = "Текущий язык - русский",
		prefixConfirm = "Установлен префикс **`%s`**",
		prefixThis = "Мой префикс **`%s`**, также меня можно упомянуть",
		prefixAbsent = "Активный префикс отсутствует, но меня всегда можно упомянуть",
		
		-- all follow the same format
		serverLobby = "Я обитаю на **`%d`** сервере и обслуживаю **`%d`** лобби",
		serverLobbies = "Я обитаю на **`%d`** сервере и обслуживаю **`%d`** лобби",
		serversLobby = "Я обитаю на **`%d`** серверах и обслуживаю **`%d`** лобби",
		serversLobbies = "Я обитаю на **`%d`** серверах и обслуживаю **`%d`** лобби",
		
		channelPerson = "Сейчас есть **`%d`** новый канал с **`%d`** человеком",
		channelPeople = "Сейчас есть **`%d`** новый канал с **`%d`** людьми",
		channelsPerson = "Сейчас есть **`%d`** новых каналов с **`%d`** человеком",
		channelsPeople = "Сейчас есть **`%d`** новых каналов с **`%d`** людьми",
		
		ping = "Пинг **`%d мс`**",
		badPermissions = 'Мне нужны права "Управлять каналами" и "Перемещать участников" чтобы работать!',
		error = "Что-то пошло не так. *Пввостите...*. Не могли бы вы зарепортить это на сервеве тех-поддержки? Время происшествия - %s"
	}
}

-- Don't go here, it's dangerous

for localeName, localeTable in pairs(locale) do
	for lineName,_ in pairs(locale.english) do
		assert(localeTable[lineName], lineName.." in "..localeName.." isn't present")
	end
end

return locale