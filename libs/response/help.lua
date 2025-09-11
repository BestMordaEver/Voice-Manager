local enums = require "discordia".enums
local componentType = enums.componentType
local buttonStyle = enums.buttonStyle
local localeHandler = require "locale/runtime/localeHandler"
local response = require "response/response"

local insert = table.insert

local translatedHelp = {}

local function helpLiner (components, line, label, id, disabled)
	if #components ~= 0 then
		insert(components, {type = componentType.separator})
	end

	insert(components, {
		type = componentType.section,
		components = {{type = componentType.textDisplay, content = line}},
		accessory = {
			type = componentType.button,
			style = buttonStyle.secondary,
			label = label,
			disabled = disabled,
			custom_id = id
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
	helpLiner(helpContents, localeHandler(locale, "helpContentsLobby"), localeHandler(locale, "helpContentsSLobby"), "lobby_setup", true)
	helpLiner(helpContents, localeHandler(locale, "helpContentsMatchmaking"), localeHandler(locale, "helpContentsSMatchmaking"), "matchmaking_setup", true)
	helpLiner(helpContents, localeHandler(locale, "helpContentsCompanion"), localeHandler(locale, "helpContentsSCompanion"), "companion_setup", true)
	helpLiner(helpContents, localeHandler(locale, "helpContentsRoom"), localeHandler(locale, "helpContentsSRoom"), "room_setup", true)
	helpLiner(helpContents, localeHandler(locale, "helpContentsServer"), localeHandler(locale, "helpContentsSServer"), "server_setup", true)
	helpLiner(helpContents, localeHandler(locale, "helpContentsOther"), localeHandler(locale, "helpContentsSOther"), "?", true)
	footer(helpContents, locale)

	local helpLobby = {{
		type = componentType.textDisplay,
		content = localeHandler(locale, "helpLobbyHeader")
	}}
	helpLiner(helpLobby, localeHandler(locale, "helpLobbySetup"), localeHandler(locale, "helpLobbySSetup"), "lobby_setup", true)
	helpLiner(helpLobby, localeHandler(locale, "helpLobbyView"), localeHandler(locale, "helpLobbySView"), "lobby_view", true)
	helpLiner(helpLobby, localeHandler(locale, "helpLobbyAdd"), localeHandler(locale, "helpLobbySAdd"), "lobby_add", true)
	helpLiner(helpLobby, localeHandler(locale, "helpLobbyRemove"), localeHandler(locale, "helpLobbySRemove"), "lobby_remove", true)
	helpLiner(helpLobby, localeHandler(locale, "helpLobbyCategory"), localeHandler(locale, "helpLobbySCategory"), "lobby_category", true)
	helpLiner(helpLobby, localeHandler(locale, "helpLobbyCapacity"), localeHandler(locale, "helpLobbySCapacity"), "lobby_capacity", true)
	helpLiner(helpLobby, localeHandler(locale, "helpLobbyLimit"), localeHandler(locale, "helpLobbySLimit"), "lobby_Limit", true)
	helpLiner(helpLobby, localeHandler(locale, "helpLobbyBitrate"), localeHandler(locale, "helpLobbySBitrate"), "lobby_bitrate", true)
	footer(helpLobby, locale)

	local helpLobbyMore = {}
	helpLiner(helpLobbyMore, localeHandler(locale, "helpLobbyName"), localeHandler(locale, "helpLobbySName"), "lobby_name", true)
	helpLiner(helpLobbyMore, localeHandler(locale, "helpLobbyPermissions"), localeHandler(locale, "helpLobbySPermissions"), "lobby_permissions", true)
	helpLiner(helpLobbyMore, localeHandler(locale, "helpLobbyRole"), localeHandler(locale, "helpLobbySRole"), "lobby_role", true)
	footer(helpLobbyMore, locale)

	local helpMatchmaking = {{
		type = componentType.textDisplay,
		content = localeHandler(locale, "helpMatchmakingHeader")
	}}
	helpLiner(helpMatchmaking, localeHandler(locale, "helpMatchmakingSetup"), localeHandler(locale, "helpMatchmakingSSetup"), "matchmaking_setup", true)
	helpLiner(helpMatchmaking, localeHandler(locale, "helpMatchmakingView"), localeHandler(locale, "helpMatchmakingSView"), "matchmaking_view", true)
	helpLiner(helpMatchmaking, localeHandler(locale, "helpMatchmakingAdd"), localeHandler(locale, "helpMatchmakingSAdd"), "matchmaking_add", true)
	helpLiner(helpMatchmaking, localeHandler(locale, "helpMatchmakingRemove"), localeHandler(locale, "helpMatchmakingSRemove"), "matchmaking_remove", true)
	helpLiner(helpMatchmaking, localeHandler(locale, "helpMatchmakingTarget"), localeHandler(locale, "helpMatchmakingSTarget"), "matchmaking_target", true)
	helpLiner(helpMatchmaking, localeHandler(locale, "helpMatchmakingMode"), localeHandler(locale, "helpMatchmakingSMode"), "matchmaking_mode", true)
	footer(helpMatchmaking, locale)

	local helpCompanion = {{
		type = componentType.textDisplay,
		content = localeHandler(locale, "helpCompanionHeader")
	}}
	helpLiner(helpCompanion, localeHandler(locale, "helpCompanionSetup"), localeHandler(locale, "helpCompanionSSetup"), "companion_setup", true)
	helpLiner(helpCompanion, localeHandler(locale, "helpCompanionView"), localeHandler(locale, "helpCompanionSView"), "companion_view", true)
	helpLiner(helpCompanion, localeHandler(locale, "helpCompanionEnable"), localeHandler(locale, "helpCompanionSEnable"), "companion_enable", true)
	helpLiner(helpCompanion, localeHandler(locale, "helpCompanionDisable"), localeHandler(locale, "helpCompanionSView"), "companion_disable", true)
	helpLiner(helpCompanion, localeHandler(locale, "helpCompanionCategory"), localeHandler(locale, "helpCompanionSView"), "companion_category", true)
	helpLiner(helpCompanion, localeHandler(locale, "helpCompanionName"), localeHandler(locale, "helpCompanionSView"), "companion_name", true)
	helpLiner(helpCompanion, localeHandler(locale, "helpCompanionGreeting"), localeHandler(locale, "helpCompanionSView"), "companion_greeting", true)
	helpLiner(helpCompanion, localeHandler(locale, "helpCompanionLog"), localeHandler(locale, "helpCompanionSView"), "companion_log", true)
	footer(helpCompanion, locale)

	local helpRoom = {{
		type = componentType.textDisplay,
		content = localeHandler(locale, "helpRoomHeader")
	}}
	helpLiner(helpRoom, localeHandler(locale, "helpRoomView"), localeHandler(locale, "helpRoomSView"), "room_view", true)
	helpLiner(helpRoom, localeHandler(locale, "helpRoomHost"), localeHandler(locale, "helpRoomSHost"), "room_host", true)
	helpLiner(helpRoom, localeHandler(locale, "helpRoomInvite"), localeHandler(locale, "helpRoomSInvite"), "room_invite", true)
	helpLiner(helpRoom, localeHandler(locale, "helpRoomRename"), localeHandler(locale, "helpRoomSRename"), "room_rename", true)
	helpLiner(helpRoom, localeHandler(locale, "helpRoomResize"), localeHandler(locale, "helpRoomSResize"), "room_resize", true)
	helpLiner(helpRoom, localeHandler(locale, "helpRoomBitrate"), localeHandler(locale, "helpRoomSBitrate"), "room_bitrate", true)
	footer(helpRoom, locale)

	local helpRoomMore = {{
		type = componentType.textDisplay,
		content = localeHandler(locale, "helpRoomHeader")
	}}
	helpLiner(helpRoomMore, localeHandler(locale, "helpRoomKick"), localeHandler(locale, "helpRoomSKick"), "room_kick", true)
	helpLiner(helpRoomMore, localeHandler(locale, "helpRoomBlock"), localeHandler(locale, "helpRoomSBlock"), "room_block", true)
	helpLiner(helpRoomMore, localeHandler(locale, "helpRoomLock"), localeHandler(locale, "helpRoomSLock"), "room_lock", true)
	helpLiner(helpRoomMore, localeHandler(locale, "helpRoomMuteVoice"), localeHandler(locale, "helpRoomSMuteVoice"), "room_mute_voice", true)
	helpLiner(helpRoomMore, localeHandler(locale, "helpRoomMuteText"), localeHandler(locale, "helpRoomSMuteText"), "room_mute_text", true)
	helpLiner(helpRoomMore, localeHandler(locale, "helpRoomHideVoice"), localeHandler(locale, "helpRoomSHideVoice"), "room_hide_voice", true)
	helpLiner(helpRoomMore, localeHandler(locale, "helpRoomHideText"), localeHandler(locale, "helpRoomSHideText"), "room_hide_text", true)
	helpLiner(helpRoomMore, localeHandler(locale, "helpRoomPassword"), localeHandler(locale, "helpRoomSPassword"), "room_password", true)
	footer(helpRoomMore, locale)

	local helpServer = {{
		type = componentType.textDisplay,
		content = localeHandler(locale, "helpServerHeader")
	}}
	helpLiner(helpServer, localeHandler(locale, "helpServerSetup"), localeHandler(locale, "helpServerSSetup"), "server_setup", true)
	helpLiner(helpServer, localeHandler(locale, "helpServerView"), localeHandler(locale, "helpServerSView"), "server_view", true)
	helpLiner(helpServer, localeHandler(locale, "helpServerLimit"), localeHandler(locale, "helpServerSLimit"), "server_limit", true)
	helpLiner(helpServer, localeHandler(locale, "helpServerPermissions"), localeHandler(locale, "helpServerSPermissions"), "server_permissions", true)
	helpLiner(helpServer, localeHandler(locale, "helpServerRole"), localeHandler(locale, "helpServerSRole"), "server_role", true)
	footer(helpServer, locale)

	local helpOther = {}
	helpLiner(helpOther, localeHandler(locale, "helpHelp"), localeHandler(locale, "helpSHelp"), "help", true)
	helpLiner(helpOther, localeHandler(locale, "helpSupport"), localeHandler(locale, "helpSSupport"), "support", true)
	helpLiner(helpOther, localeHandler(locale, "helpReset"), localeHandler(locale, "helpSReset"), "reset", true)
	helpLiner(helpOther, localeHandler(locale, "helpClone"), localeHandler(locale, "helpSClone"), "clone", true)
	helpLiner(helpOther, localeHandler(locale, "helpDelete"), localeHandler(locale, "helpSDelete"), "delete", true)
	helpLiner(helpOther, localeHandler(locale, "helpUsersPrint"), localeHandler(locale, "helpUsersSPrint"), "users_print", true)
	helpLiner(helpOther, localeHandler(locale, "helpUsersGive"), localeHandler(locale, "helpUsersSGive"), "users_give", true)
	helpLiner(helpOther, localeHandler(locale, "helpUsersRemove"), localeHandler(locale, "helpUsersSRemove"), "users_remove", true)
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
	return translatedHelp[locale][page]
end)

return help