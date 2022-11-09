local discordia = require "discordia"
local client = require "client"
local logger = require "logger"
local locale = require "locale"

local guilds = require "storage".guilds
local lobbies = require "storage".lobbies
local channels = require "storage".channels

local greetingEmbed = require "embeds/greeting"

local Overseer = require "utils/logWriter"
local matchmakers = require "utils/matchmakers"
local templateInterpreter = require "funcs/templateInterpreter"
local enforceReservations = require "funcs/enforceReservations"

local Mutex = discordia.Mutex
local permission = discordia.enums.permission
local channelType = discordia.enums.channelType
local overwriteType = discordia.enums.overwriteType
local blurple = require "embeds".colors.blurple
local insert = table.insert

local processing = {}

-- user joined a lobby
local function lobbyJoin (member, lobby)
	logger:log(4, "GUILD %s LOBBY %s USER %s: joined", lobby.guild.id, lobby.id, member.user.id)

	local guildData = guilds[lobby.guild.id]

	if guildData.limit <= guildData:channels() then return end

	-- parent to which a new channel will be attached
	local target = client:getChannel(lobbies[lobby.id].target) or lobby.category or lobby.guild

	-- determine new channel name
	local lobbyData = lobbies[lobby.id]
	local name = lobbyData.template or "%nickname's% room"
	-- potential position may change in process of name generation, so rather than query lobby for position several times, reservation is made and used throughout
	local position = lobbyData:attachChild(true)
	local needsMove

	if name:match("%%.-%%") then
		needsMove = name:match("%%counter%%") and true
		name = templateInterpreter(name, member, position):match("^%s*(.-)%s*$")
		if name == "" then name = templateInterpreter("%nickname's% room", member) end
	end

	-- determine channel position if %counter% is detected
	local distance = 0
	if needsMove then
		local children = lobbyData.children
		repeat
			distance = distance + 1
			if not (children[position + distance] == nil or client:getChannel(children[position + distance].id)) then
				children:drain(position + distance)
			end
		until children[position + distance] ~= nil or position + distance > children.max

		if position + distance > children.max then
			needsMove = nil
		else
			distance = client:getChannel(lobbyData.children[position + distance].id).position - 1
		end
	end

	local channelTemplate = {
		name = name,
		type = channelType.voice,
		bitrate = lobbyData.bitrate,
		user_limit = lobbyData.capacity or lobby.userLimit,
		position = needsMove and distance or nil,
		parent_id = target.id
	}

	-- if category, copy permissions and add stuff on top
	if target.type == channelType.category then
		channelTemplate.permission_overwrites = {}

		for _, overwrite in pairs(target.permissionOverwrites) do
			insert(channelTemplate.permission_overwrites, {
				id = overwrite:getObject().id,
				type = overwrite.type,
				allow = tostring(overwrite.allowedPermissions),
				deny = tostring(overwrite.deniedPermissions)
			})
		end

		-- bot needs to see and be able to connect
		insert(channelTemplate.permission_overwrites, {id = client.user.id, type = overwriteType.member, allow = permission.connect + permission.readMessages + permission.sendMessages, deny = 0})

		local perms = lobbyData.permissions:toDiscordia()

		-- host permissions
		if #perms ~= 0 then
			local isAdmin, permissions =
			lobby.guild.me:getPermissions():has(permission.administrator),
			lobby.guild.me:getPermissions(target)

			insert(channelTemplate.permission_overwrites, {
				id = member.user.id,
				type = overwriteType.member,
				allow =
					(((isAdmin or permissions:has(permission.moveMembers)) and lobbyData.permissions:has("moderate")) and permission.moveMembers or 0)
				+
					(((isAdmin or permissions:has(permission.manageChannels)) and lobbyData.permissions:has("manage")) and permission.manageChannels or 0)
				+
					((isAdmin and lobbyData.permissions:has("moderate")) and permission.manageRoles or 0)})
		end
	end

	local newChannel, err = lobby.guild:createChannel(channelTemplate)

	-- did we fail? ~statistics say "probably yes!"~ statistics finally say "probably no!"
	if newChannel then
		processing[newChannel.id] = Mutex()
		processing[newChannel.id]:lock()

		member:setVoiceChannel(newChannel.id)

		local companion
		if lobbyData.companionTarget then
			-- this might look familiar
			local companionTarget = lobbyData.companionTarget == true and (newChannel.category or newChannel.guild) or client:getChannel(lobbyData.companionTarget)

			if companionTarget then
				local name = lobbyData.companionTemplate or "private-chat"
				if name:match("%%.-%%") then
					name = templateInterpreter(name, member, position):discordify()
					if name == "" then name = "private-chat" end
				end

				channelTemplate = {
					name = name,
					type = channelType.text,
					parent_id = companionTarget.id
				}

				if companionTarget.type == channelType.category then
					channelTemplate.permission_overwrites = {}

					for _, overwrite in pairs(companionTarget.permissionOverwrites) do
						insert(channelTemplate.permission_overwrites, {
							id = overwrite:getObject().id,
							type = overwrite.type,
							allow = tostring(overwrite.allowedPermissions),
							deny = tostring(overwrite.deniedPermissions)
						})
					end

					-- bot needs to read and send stuff
					insert(channelTemplate.permission_overwrites, {id = client.user.id, type = overwriteType.member, allow = permission.sendMessages + permission.readMessages})

					-- everyone cannot see the channel
					insert(channelTemplate.permission_overwrites, {id = lobbyData.role or guildData.role or lobby.guild.defaultRole.id, type = overwriteType.role, deny = permission.readMessages})

					local perms = lobbyData.permissions:toDiscordia()
					if #perms ~= 0 then
						local isAdmin, permissions =
						lobby.guild.me:getPermissions():has(permission.administrator),
						lobby.guild.me:getPermissions(target)

						insert(channelTemplate.permission_overwrites, {
							id = member.user.id,
							type = overwriteType.member,
							allow =
								(((isAdmin or permissions:has(permission.manageChannels)) and lobbyData.permissions:has("manage")) and permission.manageChannels or 0)
							+
								((isAdmin and lobbyData.permissions:has("moderate")) and permission.manageRoles or 0)
							+
								permission.readMessages})
					else
						-- host needs to see the channel
						insert(channelTemplate.permission_overwrites, {id = client.user.id, type = overwriteType.member, allow = permission.readMessages})
					end
				end

				companion = lobby.guild:createChannel(channelTemplate)
			end
		end

		-- save channel data, attach to parent
		channels:store(newChannel.id, 0, member.user.id, lobby.id, position, companion and companion.id or nil)
		lobbyData:attachChild(channels[newChannel.id], position)

		if companion then
			if lobbyData.companionLog then Overseer.track(companion) end
			if lobbyData.greeting or lobbyData.companionLog then companion:send(greetingEmbed(newChannel)) end
		end

		processing[newChannel.id]:unlock()
		processing[newChannel.id] = nil
	else
		-- something went wrong, most likely user error
		lobbyData:detachChild(position)
		logger:log(2, "GUILD %s LOBBY %s USER %s: couldn't create new room - %s", lobby.guild.id, lobby.id, member.user.id, err)
	end
end

-- user joined matchmaking lobby
local function matchmakingJoin (member, lobby)
	logger:log(4, "GUILD %s mLOBBY %s USER %s: joined", lobby.guild.id, lobby.id, member.user.id)

	local target = client:getChannel(lobbies[lobby.id].target) or lobby.category
	if target then
		local children

		if lobbies[target.id] then
			-- if target is another lobby - matchmake among its children
			children = lobby.guild.voiceChannels:toArray("position", function (channel)
				if channels[channel.id] then
					local parent = client:getChannel(channels[channel.id].parent.id)
					return (parent == target) and (channel.userLimit == 0 or #channel.connectedMembers < channel.userLimit) and member:hasPermission(channel, permission.connect)
				end
			end)
		else
			-- otherwise matchmake in the available channels of category
			children = target.voiceChannels:toArray("position", function (channel)
				return (channel ~= lobby) and (channel.userLimit == 0 or #channel.connectedMembers < channel.userLimit) and member:hasPermission(channel, permission.connect)
			end)
		end

		if #children == 1 then
			if member:setVoiceChannel(children[1]) then
				logger:log(4, "GUILD %s mLOBBY %s USER %s: matchmade", lobby.guild.id, lobby.id, target.id)
			end
		elseif #children > 1 then
			if member:setVoiceChannel((matchmakers[lobbies[lobby.id].template] or matchmakers.random)(children)) then
				logger:log(4, "GUILD %s mLOBBY %s USER %s: matchmade", lobby.guild.id, lobby.id, target.id)
			end
		else	-- if no available channels - create new or kick
			if target.type == channelType.voice then
				logger:log(4, "GUILD %s mLOBBY %s: no available room, delegating to LOBBY %s", lobby.guild.id, lobby.id, target.id)
				client:emit("voiceChannelJoin", member, target)
			else
				logger:log(4, "GUILD %s mLOBBY %s: no available room, gtfo", lobby.guild.id, lobby.id)
				member:setVoiceChannel()
			end
		end
	end
end

-- user joined a room
local function roomJoin (member, channel)
	local channelData = channels[channel.id]

	if channelData.password and not (
		member:hasPermission(channel, permission.administrator) or
		channel:getPermissionOverwriteFor(member):getAllowedPermissions():has(permission.connect)
 	) then
		logger:log(4, "GUILD %s ROOM %s USER %s: sending password prompt", channel.guild.id, channel.id, member.user.id)
		channel:getPermissionOverwriteFor(member):denyPermissions(permission.connect)

		local newChannel = member.guild:createChannel {
			name = "Password verification",
			parent_id = (channel.category or channel.guild).id,
			type = channelType.voice,
			permission_overwrites = {
				{
					id = client.user.id,
					type = 1,
					allow = "3146752" -- read connect speak
				},
				{
					id = member.guild.id,
					type = 0,
					deny = "3146752"
				}
			}
		}

		member:setVoiceChannel(newChannel)
		channels:store(newChannel.id, 3, member.user.id, channel.id, 0)

		return member.user:send{
			ephemeral = true,
			embeds = {
				{
					description = locale.passwordCheckText,
					color = blurple,
					author = {
						name = channel.name,
						proxy_icon_url = member.guild.iconURL
					}
				}
			},
			components = {
				{
					type = 1,
					components = {
						{
							type = 2,
							style = 1,
							label = locale.passwordEnter,
							custom_id = "room_passwordinit",
						}
					}
				}
			}
		}
	end

	logger:log(4, "GUILD %s ROOM %s USER %s: joined", channel.guild.id, channel.id, member.user.id)

	enforceReservations(channel)

	local companion = client:getChannel(channelData.companion)
	if companion and not companion:getPermissionOverwriteFor(member):getDeniedPermissions():has(permission.readMessages) then
		companion:getPermissionOverwriteFor(member):allowPermissions(permission.readMessages)
	end
end

-- user joined an empty channel that allows execution of commands
local function channelJoin (member, channel)
	logger:log(4, "GUILD %s CHANNEL %s USER %s: joined", channel.guild.id, channel.id, member.user.id)

	--[[ TODO
	local name = templateInterpreter(guilds[channel.guild.id].template, member, position):match("^%s*(.-)%s*$")

	local position = #(channel.category and 
		channel.category.voiceChannels:toArray("position", function (vchannel) return vchannel.position <= channel.position end)
			or
		channel.guild.voiceChannels:toArray("position", function (vchannel) return not vchannel.category and vchannel.position <= channel.position end))
	]]

	channels:store(channel.id, 1, member.user.id, channel.guild.id, 0, nil)

	local perms = guilds[channel.guild.id].permissions:toDiscordia()
	if #perms ~= 0 and channel.guild.me:getPermissions(channel):has(permission.manageRoles, table.unpack(perms)) then
		channel:getPermissionOverwriteFor(member):allowPermissions(table.unpack(perms))
	end
end

return function (member, channel)
	if channel then
		local processMutex = processing[channel.id]
		if processMutex then
			processMutex:lock()
		end

		local lobbyData = lobbies[channel.id]
		if lobbyData then
			if lobbyData.isMatchmaking then
				matchmakingJoin(member, channel)
			else
				lobbyData.mutex:lock()
				local ok, err = xpcall(lobbyJoin, debug.traceback, member, channel)
				lobbyData.mutex:unlock()
				if not ok then error(err) end
			end
		elseif channels[channel.id] then
			if channels[channel.id].host ~= member.user.id then roomJoin(member, channel) end
		elseif guilds[channel.guild.id].permissions.bitfield.value ~= 0 then
			channelJoin(member, channel)
		end

		if processMutex then
			processMutex:unlock()
		end
	end
end