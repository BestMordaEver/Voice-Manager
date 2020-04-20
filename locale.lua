local locale = {
english={
help = [[**:arrow_down: You need a "Manage Channels" permission to use those commands! :arrow_down:**
`register` - registers a voice channel that will be used as a lobby. You can feed it channel IDs or channel name
`unregister` - unregisters an existing lobby. You can feed it channel IDs or channel name
`template` - change the new channel's name template. Look at `help template` to learn more
`prefix` - set a new prefix for me. Mentioning will still work
`language` - change my language
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
`template global`
Displays current global template, that will be used in new channel's name (unless that channel has their own template)

`template <channel_name>` OR
`template <channel_id>`
Displays current template for the listed channel. A channel template has higher priority than a global one

`template "global" "<template_text>"` OR
`template "<server_id>" "<template_text>"`
Changes the global template
The quote marks are used to delimit text, see `template1` or `template2` if you want to include them in your template
Note that you can add `%s` to your template, it will be replaced with username. For example, the default is `%s's channel`

`template "<template_text>"`
Sends a handy widget with all the channels that you can apply this template to

`template "<channel_name>" "<template_text>"` OR
`template "<channel_id> <channel_id> ..." "<template_text>"`
Changes the template for listed channels]],
template1 = [[**:arrow_down: You need a "Manage Channels" permission to use this command! :arrow_down:**

`template1` OR
`template1 global`
Displays current global template, that will be used in new channel's name (unless that channel has their own template)

`template1 <channel_id>`
Displays current template for the listed channel. A channel template has higher priority than a global one

`template [global] [<template_text>]` OR
`template [<server_id>] [<template_text>]`
Changes the global template
The square brackets are used to delimit text, see `template` or `template2` if you want to include them in your template
Note that you can add `%s` to your template, it will be replaced with username. For example, the default is `%s's channel`

`template1 <template_text>` OR
`template1 [<template_text>]`
Sends a handy widget with all the channels that you can apply this template to

`template1 [<channel_name>] [<template_text>]` OR
`template1 [<channel_id> <channel_id> ...] [<template_text>]`
Changes the template for listed channels]],
template2 = [[**:arrow_down: You need a "Manage Channels" permission to use this command! :arrow_down:**

`template2 <delimeter> global <delimeter> <template_text>` OR
`template2 <delimeter> <server_id> <delimeter> <template_text>`
Changes the global template
`<delimeter>` is determined by you and can be any combination of symbols (except spaces). Make sure this combination is not included in your template text
`template2 ### global ### ##%s's party bus##` :arrow_left: this works
Note that you can add `%s` to your template, it will be replaced with username. For example, the default is `%s's channel`

`template2 <template_text>`
Sends a handy widget with all the channels that you can apply this template to

`template2 <delimeter> <channel_name> <delimeter> <template_text>` OR
`template2 <delimeter> <channel_id> <channel_id> ... <delimeter> <template_text>`
Changes the template for listed channels]],
prefix = [[**:arrow_down: You need a "Manage Channels" permission to use this command! :arrow_down:**

`prefix`
Displays the current prefix. Default is !vm

`prefix <new_prefix>
Updates the prefix]],
language = [[**:arrow_down: You need a "Manage Channels" permission to use this command! :arrow_down:**

`language`
Lists all available languages

`language <new_language>
Updates the language]],
list = [[`list` OR
`list <server_id>`
Lists all registered lobbies on the server]],
registeredOne = [[Registered new lobby:]],
registeredMany = [[Registered %d new lobbies:]],
unregisteredOne = [[Unregistered lobby:]],
unregisteredMany = [[Unregistered %d lobbies:]],
channelNameCategory = [[`%s` in `%s`]],
noLobbies = [[No lobbies registered yet!]],
someLobbies = [[Registered lobbies on this server:]],
availableLanguages = [[I can speak those languages:]],
updatedLocale = [[Language updated to English]],
prefixConfirm = [[Prefix is **`%s`** now]],
prefixThis = [[My prefix is **`%s`** or you can mention me]],
prefixAbsent = [[There is no active prefix, but you can always mention me]],
serverLobby = [[I'm currently on **`%d`** server serving **`%d`** lobby]],
serverLobbies = [[I'm currently on **`%d`** server serving **`%d`** lobbies]],
serversLobby = [[I'm currently on **`%d`** servers serving **`%d`** lobby]],
serversLobbies = [[I'm currently on **`%d`** servers serving **`%d`** lobbies]],
channelPerson = [[There is **`%d`** new channel with **`%d`** person]],
channelPeople = [[There is **`%d`** new channel with **`%d`** people]],
channelsPerson = [[There are **`%d`** new channels with **`%d`** person]],
channelsPeople = [[There are **`%d`** new channels with **`%d`** people]],
ping = [[Ping is **`%d ms`**]],
embedRegister = [[Click on a channel number to register it]],
embedUnregister = [[Click on a channel number to unregister it]],
mentionInVain = [[%s, you need to have "Manage Channels" permission to do this]],
badInput = [[Couldn't find the specified channel]],
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
error = [[Something went wrong. *I'm sowwy*. Can you report this on our support server? Timestamp is %s]],
},

}

local mt = {__index = locale.english}
for _, localeTable in pairs(locale) do
	if localeTable ~= locale.english then setmetatable(localeTable, mt) end
end

--[[
for localeName, localeTable in pairs(locale) do
	for lineName,_ in pairs(locale.english) do
		assert(rawget(localeTable, lineName), lineName.." in "..localeName.." isn't present")
	end
end
--]]

return locale