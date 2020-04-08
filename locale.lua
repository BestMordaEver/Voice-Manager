local locale = {
	english = {
		helpText =	-- this is one big message
[[Ping me to get help message
Write commands after the mention, for example - `@Voice Manager register 123456789123456780`
**:arrow_down: You need a 'Manage Channels permission to use those commands! :arrow_down:**
`register` - registers a voice chat that will be used as a lobby. You can feed it channel IDs or channel name
`unregister` - unregisters an existing lobby. You can feed it channel IDs or channel name
`prefix` - set a new prefix for me. Mentioning will still work
`language` - change my language
**:arrow_up: You need a 'Manage Channels permission to use those commands! :arrow_up:**
`list` - lists all registered lobbies on the server
`stats` - take a sneak peek on my performance!
`support` - sends an invite to support Discord server]],

		mentionInVain = '%s, you need to have "Manage Channels" permission to do this',		-- %s = ping, i.e. @Riddles#2773
		badInput = "Couldn't find a specified channel",
		ambiguousID = "There are several channels with this name",
		
		registeredOne = "Registered new lobby:",
		registeredMany = "Registered %d lobbies:",			-- %d = amount of registered lobbies
		unregisteredOne = "Unregistered lobby:",
		unregisteredMany = "Unregistered %d new lobbies:",	-- same
		
		channelIDNameCategory = "`%s` -> `%s` in `%s`",		-- channel ID, then name, then category, contact me if you need to change words order
		channelNameCategory = "`%s` in `%s`",				-- same, without ID
		
		noLobbies = "No lobbies registered yet!",
		someLobbies = "Registered lobbies on this server:",
		
		availableLanguages = "I can speak those languages:",
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
		
		embedRegister = "Click on a channel number to register it",
		embedUnregister = "Click on a channel number to unregister it",
		
		emptyInput = 'I can process that, but I would need "Manage Messages" and "Add Reactions" permissions for that',
		badPermissions = 'I need "Manage Channels" and "Move Members" permissions to function!',
		error = "Something went wrong. *I'm sowwy*. Can you report this on our support server? Timestamp is %s"	-- %s = date and time
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
		badInput = "Я не смог найти указанный канал",
		ambiguousID = "Несколько голосовых каналов имеют такое название",
		
		registeredOne = "Зарегистрировал новое лобби:",
		registeredMany = "Зарегистрировал %d новых лобби:",
		unregisteredOne = "Отключил лобби:",
		unregisteredMany = "Отключил %d лобби:",
		
		channelIDNameCategory = "`%s` -> `%s` в `%s`",
		channelNameCategory = "`%s` в `%s`",
		
		noLobbies = "Тут не зарегистрировано еще ни одного лобби!",
		someLobbies = "Зарегистрированные лобби этого сервера:",
		updatedLocale = "Текущий язык - русский",
		
		prefixConfirm = "Установлен префикс **`%s`**",
		prefixThis = "Мой префикс **`%s`**, но также меня можно просто упомянуть",
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

		embedID = "Нажмите ✅, чтобы зарегестрировать новые лобби или ❌, чтобы отключить уже существующие",
		embedRegister = "Нажмите на цифру, соответствующую номеру канала, чтобы зарегестрировать его или ❌, чтобы отключить уже существующие",
		embedUnregister = "Нажмите на цифру, соответствующую номеру лобби, чтобы отключить его или ✅, чтобы зарагестрировать новые",
		embedFooter = "Нажмите 🔄, чтобы обновить виджет",
		embedSigns = "🛃 - лобби, 🆕 - новый канал, 🆓 - обычный канал",
		
		badPermissions = 'Мне нужны права "Управлять каналами" и "Перемещать участников" чтобы работать!',
		error = "Что-то пошло не так. *Пввостите...*. Не могли бы вы зарепортить это на сервеве тех-поддержки? Время происшествия - %s",
	}
}

for localeName, localeTable in pairs(locale) do
	for lineName,_ in pairs(locale.english) do
		assert(localeTable[lineName], lineName.." in "..localeName.." isn't present")
	end
end

return locale