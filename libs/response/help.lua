local enums = require "discordia".enums
local componentType = enums.componentType
local buttonStyle = enums.buttonStyle
local localeHandler = require "locale/localeHandler"
local response = require "response/response"

local insert = table.insert

local translatedHelp = {}

local function helpLiner (components, locale, line)
	if #components ~= 0 then
		insert(components, {type = componentType.separator})
	end

	insert(components, {
		type = componentType.section,
		components = {{type = componentType.textDisplay, content = localeHandler(locale, line)}},
		accessory = {
			type = componentType.button,
			style = buttonStyle.secondary,
			label = localeHandler(locale, line:gsub("^(%l+)(%u)", "%1S%2"), nil),
			disabled = true,
			custom_id = #components
		}
	})
end

local function footer (components, locale)
	insert(components, {type = componentType.separator, spacing = 2})

	insert(components, {
		type = componentType.row,
		components = {
			{
				type = componentType.stringSelect,
				custom_id = "help_widget",
				placeholder = localeHandler(locale, "helpSelectorPlaceholder"),
				options = {
					{
						label = localeHandler(locale, "helpSelectorLobby"),
						value = "lobby"
					},{
						label = localeHandler(locale, "helpSelectorLobbyMore"),
						value = "lobbymore"
					},{
						label = localeHandler(locale, "helpSelectorMatchmaking"),
						value = "matchmaking"
					},{
						label = localeHandler(locale, "helpSelectorCompanion"),
						value = "companion"
					},{
						label = localeHandler(locale, "helpSelectorRoom"),
						value = "room"
					},{
						label = localeHandler(locale, "helpSelectorRoomMore"),
						value = "roommore"
					},{
						label = localeHandler(locale, "helpSelectorServer"),
						value = "server"
					},{
						label = localeHandler(locale, "helpSelectorOther"),
						value = "other"
					}
				}
			}
		}
	})

	insert(components, {
		type = componentType.textDisplay,
		content = localeHandler(locale, "helpLinks")
	})
end

local function helpFactory (locale)
	local helpContents = {}
	helpLiner(helpContents, locale, "helpContentsLobby")
	helpLiner(helpContents, locale, "helpContentsMatchmaking")
	helpLiner(helpContents, locale, "helpContentsCompanion")
	helpLiner(helpContents, locale, "helpContentsRoom")
	helpLiner(helpContents, locale, "helpContentsServer")
	helpLiner(helpContents, locale, "helpContentsOther")
	footer(helpContents, locale)

	local helpLobby = {{
		type = componentType.textDisplay,
		content = localeHandler(locale, "helpLobbyHeader")
	}}
	--helpLiner(helpLobby, locale, "helpLobbySetup")
	helpLiner(helpLobby, locale, "helpLobbyView")
	helpLiner(helpLobby, locale, "helpLobbyAdd")
	helpLiner(helpLobby, locale, "helpLobbyRemove")
	helpLiner(helpLobby, locale, "helpLobbyCategory")
	helpLiner(helpLobby, locale, "helpLobbyCapacity")
	helpLiner(helpLobby, locale, "helpLobbyLimit")
	helpLiner(helpLobby, locale, "helpLobbyBitrate")
	footer(helpLobby, locale)

	local helpLobbyMore = {}
	helpLiner(helpLobbyMore, locale, "helpLobbyName")
	helpLiner(helpLobbyMore, locale, "helpLobbyPermissions")
	helpLiner(helpLobbyMore, locale, "helpLobbyRole")
	footer(helpLobbyMore, locale)

	local helpMatchmaking = {{
		type = componentType.textDisplay,
		content = localeHandler(locale, "helpMatchmakingHeader")
	}}
	--helpLiner(helpMatchmaking, locale, "helpMatchmakingSetup")
	helpLiner(helpMatchmaking, locale, "helpMatchmakingView")
	helpLiner(helpMatchmaking, locale, "helpMatchmakingAdd")
	helpLiner(helpMatchmaking, locale, "helpMatchmakingRemove")
	helpLiner(helpMatchmaking, locale, "helpMatchmakingTarget")
	helpLiner(helpMatchmaking, locale, "helpMatchmakingMode")
	footer(helpMatchmaking, locale)

	local helpCompanion = {{
		type = componentType.textDisplay,
		content = localeHandler(locale, "helpCompanionHeader")
	}}
	--helpLiner(helpCompanion, locale, "helpCompanionSetup")
	helpLiner(helpCompanion, locale, "helpCompanionView")
	helpLiner(helpCompanion, locale, "helpCompanionEnable")
	helpLiner(helpCompanion, locale, "helpCompanionCategory")
	helpLiner(helpCompanion, locale, "helpCompanionName")
	helpLiner(helpCompanion, locale, "helpCompanionGreeting")
	helpLiner(helpCompanion, locale, "helpCompanionLog")
	footer(helpCompanion, locale)

	local helpRoom = {{
		type = componentType.textDisplay,
		content = localeHandler(locale, "helpRoomHeader")
	}}
	helpLiner(helpRoom, locale, "helpRoomView")
	helpLiner(helpRoom, locale, "helpRoomHost")
	helpLiner(helpRoom, locale, "helpRoomInvite")
	helpLiner(helpRoom, locale, "helpRoomRename")
	helpLiner(helpRoom, locale, "helpRoomResize")
	helpLiner(helpRoom, locale, "helpRoomBitrate")
	footer(helpRoom, locale)

	local helpRoomMore = {{
		type = componentType.textDisplay,
		content = localeHandler(locale, "helpRoomHeader")
	}}
	helpLiner(helpRoomMore, locale, "helpRoomKick")
	helpLiner(helpRoomMore, locale, "helpRoomBlock")
	helpLiner(helpRoomMore, locale, "helpRoomLock")
	helpLiner(helpRoomMore, locale, "helpRoomMuteVoice")
	helpLiner(helpRoomMore, locale, "helpRoomMuteText")
	helpLiner(helpRoomMore, locale, "helpRoomHideVoice")
	helpLiner(helpRoomMore, locale, "helpRoomHideText")
	helpLiner(helpRoomMore, locale, "helpRoomPassword")
	footer(helpRoomMore, locale)

	local helpServer = {{
		type = componentType.textDisplay,
		content = localeHandler(locale, "helpServerHeader")
	}}
	--helpLiner(helpServer, locale, "helpServerSetup")
	helpLiner(helpServer, locale, "helpServerView")
	helpLiner(helpServer, locale, "helpServerLimit")
	helpLiner(helpServer, locale, "helpServerPermissions")
	helpLiner(helpServer, locale, "helpServerRole")
	footer(helpServer, locale)

	local helpOther = {}
	helpLiner(helpOther, locale, "helpHelp")
	helpLiner(helpOther, locale, "helpSupport")
	helpLiner(helpOther, locale, "helpReset")
	helpLiner(helpOther, locale, "helpClone")
	helpLiner(helpOther, locale, "helpDelete")
	helpLiner(helpOther, locale, "helpUsersPrint")
	helpLiner(helpOther, locale, "helpUsersGive")
	helpLiner(helpOther, locale, "helpUsersRemove")
	footer(helpOther, locale)

	return {
		help = helpContents,
		lobby = helpLobby,
		lobbymore = helpLobbyMore,
		matchmaking = helpMatchmaking,
		companion = helpCompanion,
		room = helpRoom,
		roommore = helpRoomMore,
		server = helpServer,
		other = helpOther,
	}
end

for localeName, _ in pairs(localeHandler) do
	translatedHelp[localeName] = helpFactory(localeName)
end

---@overload fun(ephemeral : boolean, locale : localeName, page : string) : table
local help = response("help", response.colors.blurple, function (locale, page)
	page = page or "help"
	return (translatedHelp[locale] or translatedHelp["en-US"])[page]
end)

return help