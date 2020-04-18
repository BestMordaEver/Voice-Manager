local locale = {
	english = {
		helpText =	-- this is one big message
[[**:arrow_down: You need a "Manage Channels" permission to use those commands! :arrow_down:**
`register` - registers a voice chat that will be used as a lobby. You can feed it channel IDs or channel name
`unregister` - unregisters an existing lobby. You can feed it channel IDs or channel name
`prefix` - set a new prefix for me. Mentioning will still work
`language` - change my language
**:arrow_up: You need a "Manage Channels" permission to use those commands! :arrow_up:**
`list` - lists all registered lobbies on the server
`stats` - take a sneak peek on my performance!
`support` - sends an invite to support Discord server]],
		
		registeredOne = "Registered new lobby:",
		registeredMany = "Registered %d new lobbies:",			-- %d = amount of registered lobbies
		unregisteredOne = "Unregistered lobby:",
		unregisteredMany = "Unregistered %d lobbies:",	-- same
		
		channelNameCategory = "`%s` in `%s`",				-- channel name, then category, contact me if you need to change words order
		
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
		
		mentionInVain = '%s, you need to have "Manage Channels" permission to do this',        -- %s = ping, i.e. @Riddles#2773
		badInput = "Couldn't find the specified channel",
		ambiguousID = "There are several channels with this name",
		gimmeReaction = 'I can process that, but I would need "Manage Messages" and "Add Reactions" permissions for that',

		badBotPermission = "Couldn't register this channel due to insufficient permissions:",
		badBotPermissions = "Couldn't register those channels due to insufficient permissions:",

		badUserPermissionRegister = "You're not permitted to register this channel:",
		badUserPermissionsRegister = "You're not permitted to register those channels:",
		badUserPermissionUnregister = "You're not permitted to unregister this channel:",
		badUserPermissionsUnregister = "You're not permitted to unregister those channels:",

		badChannel = "This channel is not valid:",		-- you can't register text channel for example
		badChannels = "Those channels are not valid:",

		redundantRegister = "This channel is already registered:",
		redundantRegisters = "Those channels are already registered:",
		redundantUnregister = "This channel is not a lobby:",
		redundantUnregisters = "Those channels are not a lobby:",
		
		error = "Something went wrong. *I'm sowwy*. Can you report this on our support server? Timestamp is %s"	-- %s = date and time
	},
	
	russian = {
		helpText = 
[[**:arrow_down: Вам потребуются права "Управление каналами" для использования этих команд! :arrow_down:**
`register` - регистрирует голосовой канал, который будет использоваться как лобби. Также можно указывать ID каналов или их название
`unregister` - удаляет голосовой канал из списка лобби этого сервера. Также можно указывать ID каналов или их название
`prefix` - добавляет новый префикс для работы со мной. Упоминания также все еще будут работать
`language` - меняет язык, на котором я буду с вами говорить
**:arrow_up: Вам потребуются права "Управление каналами" для использования этих команд! :arrow_up:**
`list` - перечисляет все зарегестрированные лобби на этом сервере
`stats` - показывает мою статистику!
`support` - отправляет приглашение на сервер тех. поддержки]],

		registeredOne = "Я зарегистрировал новое лобби:",
		registeredMany = "Я зарегистрировал %d новых лобби:",
		unregisteredOne = "Я отключил лобби:",
		unregisteredMany = "Я отключил %d лобби:",  

		channelNameCategory = "`%s` в `%s`",       

		noLobbies = "Вы не зарегестрировали еще ни одного лобби!",
		someLobbies = "Зарегистрированные лобби на этом сревере:",

		availableLanguages = "Я могу говорить на таких языках:",
		updatedLocale = "Язык успешно изменен на русский!", 
		
		prefixConfirm = "Установлен префикс **`%s`**",
		prefixThis = "Мой префикс **`%s`**, но также меня можно просто упомянуть",
		prefixAbsent = "Активный префикс отсутствует, но меня всегда можно упомянуть",

		serverLobby = "Я нахожусь на **`%d`** сервере и обслуживаю **`%d`** лобби",
		serverLobbies = "Я нахожусь на **`%d`** сервере и обслуживаю **`%d`** лобби",
		serversLobby = "Я нахожусь на **`%d`** серверах и обслуживаю **`%d`** лобби",
		serversLobbies = "Я нахожусь на **`%d`** серверах и обслуживаю **`%d`** лобби",

		channelPerson = "Сейчас есть **`%d`** новый канал с **`%d`** человеком",
		channelPeople = "Сейчас есть **`%d`** новый канал с **`%d`** людьми",
		channelsPerson = "Сейчас есть **`%d`** новых каналов с **`%d`** человеком",
		channelsPeople = "Сейчас есть **`%d`** новых каналов с **`%d`** людьми",

		ping = "Пинг сейчас составляет **`%d мс`**",

		embedRegister = "Нажмите на номер канала, чтобы зарегистрировать его",
		embedUnregister = "Нажмите на номер лобби, чтобы отключить его",
		
		mentionInVain = '%s, вам нужно иметь права "Управление каналами", чтобы сделать это',       
		badInput = "Я не смог найти указанный вами канал",
		ambiguousID = "Несколько голосовых каналов имеют такое название",
		gimmeReaction = 'Я могу это сделать, но мне для этого потребуются права "Управление сообщениями" и "Добавлять реакции"',

		badBotPermission = "Я не смог зарегестрировать этот канал из-за того, что у меня недостаточно разрешений:",
		badBotPermissions = "Я не смог зарегестрировать эти каналы из-за того, что у меня недостаточно разрешений:",

		badUserPermissionRegister = "У вас не достаточно прав, чтобы зарегестрировать этот канал:",
		badUserPermissionsRegister = "У вас не достаточно прав, чтобы зарегестрировать эти каналы:",
		badUserPermissionUnregister = "У вас не достаточно прав, чтобы отключить этот канал:",
		badUserPermissionsUnregister = "У вас не достаточно прав, чтобы отключить эти каналы:",

		badChannel = "Это не голосовой канал:",   
		badChannels = "Это не голосовые каналы:",

		redundantRegister = "Этот канал уже зарегестрирован:",
		redundantRegisters = "Эти каналы уже зарегестрированы:",
		redundantUnregister = "Этот канал еще не лобби:",
		redundantUnregisters = "Эти каналы еще не лобби:",

		error = "Что-то пошло не так. *Пввостите...* Не могли бы вы зарепортить это на сервере тех-поддержки? Время происшествия - %s"
	}
}

local mt = {__index = locale.english}
for _, localeTable in pairs(locale) do
	setmetatable(localeTable, mt)
end

-- [[
for localeName, localeTable in pairs(locale) do
	for lineName,_ in pairs(locale.english) do
		assert(rawget(localeTable, lineName), lineName.." in "..localeName.." isn't present")
	end
end
--]]

return locale