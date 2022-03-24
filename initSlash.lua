local https = require "coro-http"
local json = require "json"
local token = "Bot "..require "token".token
local timer = require "timer"

--local id = "601347755046076427" -- vm
local id = "676787135650463764" -- rat
--local guild = "669676999211483144" -- playground
local guild = "741645965869711410" -- test

local domain = "https://discord.com/api/v8"
local GLOBAL_COMMANDS = string.format("%s/applications/%s/commands", domain, id)
local GLOBAL_COMMAND = string.format("%s/applications/%s/commands/%s", domain, id,"%s")
local GUILD_COMMANDS = string.format("%s/applications/%s/guilds/%s/commands", domain, id, "%s")
local GUILD_COMMAND = string.format("%s/applications/%s/guilds/%s/commands/%s", domain, id, "%s", "%s")

local printf = function (...)
	print(string.format(...))
end

local function parseErrors(ret, errors, key)
	for k, v in pairs(errors) do
		if k == '_errors' then
			for _, err in ipairs(v) do
				table.insert(ret, string.format('%s in %s : %s', err.code, key or 'payload', err.message))
			end
		else
			if key then
				parseErrors(ret, v, string.format(k:find("^[%a_][%a%d_]*$") and '%s.%s' or tonumber(k) and '%s[%d]' or '%s[%q]', key, k))
			else
				parseErrors(ret, v, k)
			end
		end
	end
	return table.concat(ret, '\n\t')
end

local function request (method, url, payload, retries)
	local success, res, msg = pcall(https.request, method, url,
		{{"Authorization", token},{"Content-Type", "application/json"},{"Accept", "application/json"}}, payload and json.encode(payload))
	local delay, maxRetries = 300, 5
	retries = retries or 0

	if not success then
		return nil, res
	end

	for i, v in ipairs(res) do
		res[v[1]:lower()] = v[2]
		res[i] = nil
	end

	if res['x-ratelimit-remaining'] == '0' then
		delay = math.max(1000 * res['x-ratelimit-reset-after'], delay)
	end

	local data = json.decode(msg, 1, json.null)

	if res.code < 300 then
		printf('SUCCESS : %i - %s : %s %s', res.code, res.reason, method, url)
		return data or true, nil
	else
		if type(data) == 'table' then

			local retry
			if res.code == 429 then -- TODO: global ratelimiting
				delay = data.retry_after*1000
				retry = retries < maxRetries
			elseif res.code == 502 then
				delay = delay + math.random(2000)
				retry = retries < maxRetries
			end

			if retry then
				printf('WARNING : %i - %s : retrying after %i ms : %s %s', res.code, res.reason, delay, method, url)
				timer.sleep(delay)
				return request(method, url, payload, retries + 1)
			end

			if data.code and data.message then
				msg = string.format('HTTP ERROR %i : %s', data.code, data.message)
			else
				msg = 'HTTP ERROR'
			end
			if data.errors then
				msg = parseErrors({msg}, data.errors)
			end

			printf('ERROR : %i - %s : %s %s', res.code, res.reason, method, url)
			return nil, msg, delay
		end
	end
end

local CommandManager = {
	getGlobalCommands = function ()
		return request("GET", GLOBAL_COMMANDS)
	end,

	getGlobalCommand = function (id)
		return request("GET", GLOBAL_COMMAND:format(id))
	end,

	createGlobalCommand = function (payload)
		return request("POST", GLOBAL_COMMANDS, payload)
	end,

	editGlobalCommand = function (id, payload)
		return request("PATCH", GLOBAL_COMMAND:format(id), payload)
	end,

	editGlobalCommands = function (payload)
		return request("PATCH", GLOBAL_COMMANDS, payload)
	end,

	deleteGlobalCommand = function (id)
		return request("DELETE", GLOBAL_COMMAND:format(id))
	end,

	overwriteGlobalCommands = function(payload)
		return request("PUT", GLOBAL_COMMANDS, payload)
	end,

	getGuildCommands = function (guild)
		return request("GET", GUILD_COMMANDS:format(guild))
	end,

	getGuildCommand = function (guild, id)
		return request("GET", GUILD_COMMAND:format(guild, id))
	end,

	createGuildCommand = function (guild, payload)
		return request("POST", GUILD_COMMANDS:format(guild), payload)
	end,

	editGuildCommand = function (guild, id, payload)
		return request("PATCH", GUILD_COMMAND:format(guild, id), payload)
	end,

	editGuildCommands = function (guild, payload)
		return request("PATCH", GUILD_COMMANDS:format(guild), payload)
	end,

	deleteGuildCommand = function (guild, id)
		return request("DELETE", GUILD_COMMAND:format(guild, id))
	end,

	overwriteGuildCommands = function(guild, payload)
		return request("PUT", GUILD_COMMANDS:format(guild), payload)
	end
}

local enums = require "discordia".enums
local channelType = enums.channelType
local commandType = enums.applicationCommandType
local commandOptionType = enums.applicationCommandOptionType

local commandsStructure = {
	{ -- 0
		name = "help",
		description = "A help command!",
		options = {
			{
				name = "article",
				description = "Which help article do you need?",
				type = commandOptionType.string,
				choices = {
					{
						name = "lobby",
						value = "lobby"
					},
					{
						name = "matchmaking",
						value = "matchmaking"
					},
					{
						name = "companion",
						value = "companion"
					},
					{
						name = "room",
						value = "room"
					},
					{
						name = "chat",
						value = "chat"
					},
					{
						name = "server",
						value = "server"
					},
					{
						name = "misc",
						value = "misc"
					}
				}
			}
		}
	},
	{ -- 1
		name = "lobby",
		description = "Configure lobby settings",
		options = {
			{
				name = "view",
				description = "Show registered lobbies",
				type = commandOptionType.subcommand,
				options = {
					{
						name = "lobby",
						description = "A lobby to be viewed",
						type = commandOptionType.channel,
						channel_types = {
							channelType.voice
						}
					}
				}
			},
			{
				name = "add",
				description = "Register a new lobby",
				type = commandOptionType.subcommand,
				options = {
					{
						name = "channel",
						description = "A channel to be registered",
						type = commandOptionType.channel,
						required = true,
						channel_types = {
							channelType.voice
						}
					}
				}
			},
			{
				name = "remove",
				description = "Remove an existing lobby",
				type = commandOptionType.subcommand,
				options = {
					{
						name = "lobby",
						description = "A lobby to be removed",
						type = commandOptionType.channel,
						required = true,
						channel_types = {
							channelType.voice
						}
					}
				}
			},
			{
				name = "name",
				description = "Configure what name a room will have when it's created",
				type = commandOptionType.subcommand,
				options = {
					{
						name = "lobby",
						description = "A lobby to be configured",
						type = commandOptionType.channel,
						required = true,
						channel_types = {
							channelType.voice
						}
					},
					{
						name = "name",
						description = "Name a room will have when it's created",
						type = commandOptionType.string,
						required = true
					}
				}
			},
			{
				name = "category",
				description = "Select a category in which rooms will be created",
				type = commandOptionType.subcommand,
				options = {
					{
						name = "lobby",
						description = "A lobby to be configured",
						type = commandOptionType.channel,
						required = true,
						channel_types = {
							channelType.voice
						}
					},
					{
						name = "category",
						description = "Category in which rooms will be created",
						type = commandOptionType.channel,
						required = true,
						channel_types = {
							channelType.category
						}
					}
				}
			},
			{
				name = "bitrate",
				description = "Select new rooms' bitrate",
				type = commandOptionType.subcommand,
				options = {
					{
						name = "lobby",
						description = "A lobby to be configured",
						type = commandOptionType.channel,
						required = true,
						channel_types = {
							channelType.voice
						}
					},
					{
						name = "bitrate",
						description = "New rooms' bitrate",
						type = commandOptionType.integer,
						required = true,
						min_value = 8,
						max_value = 384
					}
				}
			},
			{
				name = "capacity",
				description = "Select new rooms' capacity",
				type = commandOptionType.subcommand,
				options = {
					{
						name = "lobby",
						description = "A lobby to be configured",
						type = commandOptionType.channel,
						required = true,
						channel_types = {
							channelType.voice
						}
					},
					{
						name = "capacity",
						description = "New rooms' capacity",
						type = commandOptionType.integer,
						required = true,
						min_value = 0,
						max_value = 99
					}
				}
			},
			{
				name = "permissions",
				description = "Give room hosts' access to different commands",
				type = commandOptionType.subcommand,
				options = {
					{
						name = "lobby",
						description = "A lobby to be configured",
						type = commandOptionType.channel,
						required = true,
						channel_types = {
							channelType.voice
						}
					},
					{
						name = "moderate",
						description = "Permission to use moderation commands",
						type = commandOptionType.boolean
					},
					{
						name = "manage",
						description = "Permission to manage room properties",
						type = commandOptionType.boolean
					},
					{
						name = "rename",
						description = "Permission to rename room",
						type = commandOptionType.boolean
					},
					{
						name = "resize",
						description = "Permission to change room capacity",
						type = commandOptionType.boolean
					},
					{
						name = "bitrate",
						description = "Permission to change room bitrate",
						type = commandOptionType.boolean
					},
					{
						name = "mute",
						description = "Permission to mute users in room",
						type = commandOptionType.boolean
					}
				}
			},
			{
				name = "role",
				description = "Change the default role bot uses to enforce user commands",
				type = commandOptionType.subcommand,
				options = {
					{
						name = "lobby",
						description = "A lobby to be configured",
						type = commandOptionType.channel,
						required = true,
						channel_types = {
							channelType.voice
						}
					},
					{
						name = "role",
						description = "The default role bot uses to enforce user commands",
						type = commandOptionType.role,
						required = true
					}
				}
			}
		}
	},
	{ -- 2
		name = "matchmaking",
		description = "Configure matchmaking lobby settings",
		options = {
			{
				name = "view",
				description = "Show registered matchmaking lobbies",
				type = commandOptionType.subcommand,
				options = {
					{
						name = "lobby",
						description = "A lobby to be viewed",
						type = commandOptionType.channel,
						channel_types = {
							channelType.voice
						}
					}
				}
			},
			{
				name = "add",
				description = "Register a new matchmaking lobby",
				type = commandOptionType.subcommand,
				options = {
					{
						name = "channel",
						description = "A channel to be registered",
						type = commandOptionType.channel,
						required = true,
						channel_types = {
							channelType.voice
						}
					}
				}
			},
			{
				name = "remove",
				description = "Remove an existing matchmaking lobby",
				type = commandOptionType.subcommand,
				options = {
					{
						name = "lobby",
						description = "A matchmaking lobby to be removed",
						type = commandOptionType.channel,
						required = true,
						channel_types = {
							channelType.voice
						}
					}
				}
			},
			{
				name = "target",
				description = "Select a target for matchmaking pool",
				type = commandOptionType.subcommand,
				options = {
					{
						name = "lobby",
						description = "A lobby to be configured",
						type = commandOptionType.channel,
						required = true,
						channel_types = {
							channelType.voice
						}
					},
					{
						name = "target",
						description = "A target for matchmaking pool",
						type = commandOptionType.channel,
						required = true,
						channel_types = {
							channelType.voice, channelType.category
						}
					}
				}
			},
			{
				name = "mode",
				description = "Select the matchmaking mode",
				type = commandOptionType.subcommand,
				options = {
					{
						name = "lobby",
						description = "A lobby to be configured",
						type = commandOptionType.channel,
						required = true,
						channel_types = {
							channelType.voice
						}
					},
					{
						name = "mode",
						description = "A matchmaking mode",
						type = commandOptionType.string,
						required = true,
						choices = {
							{
								name = "random",
								value = "random"
							},
							{
								name = "max",
								value = "max"
							},
							{
								name = "min",
								value = "min"
							},
							{
								name = "first",
								value = "first"
							},
							{
								name = "last",
								value = "last"
							}
						}
					}
				}
			}
		}
	},
	{ -- 3
		name = "companion",
		description = "Configure lobby companion settings",
		options = {
			{
				name = "view",
				description = "Show lobbies with enabled companion chats",
				type = commandOptionType.subcommand,
				options = {
					{
						name = "lobby",
						description = "A lobby to be viewed",
						type = commandOptionType.channel,
						channel_types = {
							channelType.voice
						}
					}
				}
			},
			{
				name = "enable",
				description = "Enable companion chats for selected lobby",
				type = commandOptionType.subcommand,
				options = {
					{
						name = "lobby",
						description = "Selected lobby",
						type = commandOptionType.channel,
						required = true,
						channel_types = {
							channelType.voice
						}
					}
				}
			},
			{
				name = "disable",
				description = "Disable companion chats for selected lobby",
				type = commandOptionType.subcommand,
				options = {
					{
						name = "lobby",
						description = "Selected lobby",
						type = commandOptionType.channel,
						required = true,
						channel_types = {
							channelType.voice
						}
					}
				}
			},
			{
				name = "category",
				description = "Select a category in which a companion chat will be created",
				type = commandOptionType.subcommand,
				options = {
					{
						name = "lobby",
						description = "A lobby to be configured",
						type = commandOptionType.channel,
						required = true,
						channel_types = {
							channelType.voice
						}
					},
					{
						name = "category",
						description = "A category in which a companion chat will be created",
						type = commandOptionType.channel,
						required = true,
						channel_types = {
							channelType.category
						}
					}
				}
			},
			{
				name = "name",
				description = "Configure what name a chat will have when it's created",
				type = commandOptionType.subcommand,
				options = {
					{
						name = "lobby",
						description = "A lobby to be configured",
						type = commandOptionType.channel,
						required = true,
						channel_types = {
							channelType.voice
						}
					},
					{
						name = "name",
						description = "Name a chat will have when it's created",
						type = commandOptionType.string,
						required = true
					}
				}
			},
			{
				name = "greeting",
				description = "Configure a message that will be automatically sent to chat when it's created",
				type = commandOptionType.subcommand,
				options = {
					{
						name = "lobby",
						description = "A lobby to be configured",
						type = commandOptionType.channel,
						required = true,
						channel_types = {
							channelType.voice
						}
					},
					{
						name = "greeting",
						description = "A message that will be automatically sent to chat when it's created",
						type = commandOptionType.string,
						required = true
					}
				}
			},
			{
				name = "log",
				description = "Enable chat logging. Logs will be sent as files to a channel of your choosing",
				type = commandOptionType.subcommand,
				options = {
					{
						name = "lobby",
						description = "A lobby to be configured",
						type = commandOptionType.channel,
						required = true,
						channel_types = {
							channelType.voice
						}
					},
					{
						name = "channel",
						description = "A channel where logs will be sent",
						type = commandOptionType.channel,
						required = true,
						channel_types = {
							channelType.text
						}
					}
				}
			}
		}
	},
	{ -- 4
		name = "room",
		description = "Configure room settings",
		options = {
			{
				name = "view",
				description = "Show room settings",
				type = commandOptionType.subcommand
			},
			{
				name = "host",
				description = "Ping current room host and transfer room ownership",
				type = commandOptionType.subcommand,
				options = {
					{
						name = "user",
						description = "User that you want to transfer ownership to",
						type = commandOptionType.user
					}
				}
			},
			{
				name = "invite",
				description = "Send people an invite to immediately connect to the room",
				type = commandOptionType.subcommand,
				options = {
					{
						name = "user",
						description = "User that you want to send an invite to",
						type = commandOptionType.user
					}
				}
			},
			{
				name = "rename",
				description = "Change the name of the room",
				type = commandOptionType.subcommand,
				options = {
					{
						name = "name",
						description = "New room name",
						type = commandOptionType.string,
						required = true
					}
				}
			},
			{
				name = "resize",
				description = "Change the capacity of the room",
				type = commandOptionType.subcommand,
				options = {
					{
						name = "capacity",
						description = "New room capacity",
						type = commandOptionType.integer,
						min_value = 0,
						max_value = 99,
						required = true
					}
				}
			},
			{
				name = "bitrate",
				description = "Change the bitrate",
				type = commandOptionType.subcommand,
				options = {
					{
						name = "bitrate",
						description = "New room bitrate",
						type = commandOptionType.integer,
						min_value = 8,
						max_value = 384,
						required = true
					}
				}
			},
			{
				name = "mute",
				description = "Mute a user",
				type = commandOptionType.subcommand,
				options = {
					{
						name = "user",
						description = "User that you want to mute",
						type = commandOptionType.user,
						required = true
					}
				}
			},
			{
				name = "unmute",
				description = "Unmute a user",
				type = commandOptionType.subcommand,
				options = {
					{
						name = "user",
						description = "User that you want to unmute",
						type = commandOptionType.user,
						required = true
					}
				}
			},
			{
				name = "kick",
				description = "Kick a user from your room",
				type = commandOptionType.subcommand,
				options = {
					{
						name = "user",
						description = "User that you want to kick",
						type = commandOptionType.user,
						required = true
					}
				}
			},
			{
				name = "blocklist",
				description = "Manage the blocklist in your room",
				type = commandOptionType.subcommandGroup,
				options = {
					{
						name = "add",
						description = "Add users to the blocklist",
						type = commandOptionType.subcommand,
						options = {
							{
								name = "user",
								description = "User that you want to add to blocklist",
								type = commandOptionType.user,
								required = true
							}
						}
					},
					{
						name = "remove",
						description = "Remove users from the blocklist",
						type = commandOptionType.subcommand,
						options = {
							{
								name = "user",
								description = "User that you want to remove from the blocklist",
								type = commandOptionType.user,
								required = true
							}
						}
					},
					{
						name = "clear",
						description = "Clear the blocklist",
						type = commandOptionType.subcommand
					}
				}
			},
			{
				name = "reservations",
				description = "Manage the reservations in your room",
				type = commandOptionType.subcommandGroup,
				options = {
					{
						name = "add",
						description = "Reserve a place for a user",
						type = commandOptionType.subcommand,
						options = {
							{
								name = "user",
								description = "User that you want to add to reservations",
								type = commandOptionType.user,
								required = true
							}
						}
					},
					{
						name = "remove",
						description = "Remove a reservation for a user",
						type = commandOptionType.subcommand,
						options = {
							{
								name = "user",
								description = "User that you want to remove from reservations",
								type = commandOptionType.user,
								required = true
							}
						}
					},
					{
						name = "clear",
						description = "Clear the reservations",
						type = commandOptionType.subcommand
					}
				}
			},
			{
				name = "lock",
				description = "Set room to invite only mode",
				type = commandOptionType.subcommand
			}
		}
	},
	{ -- 5
		name = "chat",
		description = "Configure chat settings",
		options = {
			{
				name = "view",
				description = "Show chat settings",
				type = commandOptionType.subcommand
			},
			{
				name = "rename",
				description = "Change the name of the chat",
				type = commandOptionType.subcommand,
				options = {
					{
						name = "name",
						description = "New chat name",
						type = commandOptionType.string,
						required = true
					}
				}
			},
			{
				name = "mute",
				description = "Mute a user",
				type = commandOptionType.subcommand,
				options = {
					{
						name = "user",
						description = "User that you want to mute",
						type = commandOptionType.user,
						required = true
					}
				}
			},
			{
				name = "unmute",
				description = "Unmute a user",
				type = commandOptionType.subcommand,
				options = {
					{
						name = "user",
						description = "User that you want to unmute",
						type = commandOptionType.user,
						required = true
					}
				}
			},
			{
				name = "hide",
				description = "Hide the chat from mentioned user",
				type = commandOptionType.subcommand,
				options = {
					{
						name = "user",
						description = "User that you want to hide the chat from",
						type = commandOptionType.user,
						required = true
					}
				}
			},
			{
				name = "show",
				description = "Show the chat to mentioned user",
				type = commandOptionType.subcommand,
				options = {
					{
						name = "user",
						description = "User that you want to show the chat to",
						type = commandOptionType.user,
						required = true
					}
				}
			},
			{
				name = "clear",
				description = "Delete messages in the chat",
				type = commandOptionType.subcommand,
				options = {
					{
						name = "amount",
						description = "How many messages to delete",
						type = commandOptionType.integer,
						min_value = 0
					}
				}
			}
		}
	},
	{ -- 6
		name = "server",
		description = "Configure global server settings",
		options = {
			{
				name = "view",
				description = "Show server settings",
				type = commandOptionType.subcommand
			},
			{
				name = "limit",
				description = "Limit the amount of rooms bot is permitted to create",
				type = commandOptionType.subcommand,
				options = {
					{
						name = "limit",
						description = "The amount of rooms bot will be able to create",
						type = commandOptionType.integer,
						required = true,
						min_value = 0,
						max_value = 500
					}
				}
			},
			{
				name = "permissions",
				description = "Give users ability to access room commands in normal channels",
				type = commandOptionType.subcommand,
				options = {
					{
						name = "moderate",
						description = "Permission to use moderation commands",
						type = commandOptionType.boolean
					},
					{
						name = "manage",
						description = "Permission to manage room properties",
						type = commandOptionType.boolean
					},
					{
						name = "rename",
						description = "Permission to rename room",
						type = commandOptionType.boolean
					},
					{
						name = "resize",
						description = "Permission to change room capacity",
						type = commandOptionType.boolean
					},
					{
						name = "bitrate",
						description = "Permission to change room bitrate",
						type = commandOptionType.boolean
					},
					{
						name = "mute",
						description = "Permission to mute users in room",
						type = commandOptionType.boolean
					}
				}
			},
			{
				name = "role",
				description = "Change the default role bot uses to enforce user commands",
				type = commandOptionType.subcommand,
				options = {
					{
						name = "role",
						description = "The default role bot uses to enforce user commands",
						type = commandOptionType.role,
						required = true
					}
				}
			}
		}
	},
	{ -- 7
		name = "reset",
		description = "Reset bot settings",
		options = {
			{
				name = "lobby",
				description = "Lobby settings",
				type = commandOptionType.subcommandGroup,
				options = {
					{
						name = "name",
						description = "Set new room name to default \"%nickname's room\"",
						type = commandOptionType.subcommand,
						options = {
							{
								name = "lobby",
								description = "A lobby to be configured",
								type = commandOptionType.channel,
								required = true,
								channel_types = {
									channelType.voice
								}
							}
						}
					},
					{
						name = "category",
						description = "Set new room category to lobby's category",
						type = commandOptionType.subcommand,
						options = {
							{
								name = "lobby",
								description = "A lobby to be configured",
								type = commandOptionType.channel,
								required = true,
								channel_types = {
									channelType.voice
								}
							}
						}
					},
					{
						name = "bitrate",
						description = "Set new room bitrate to 64",
						type = commandOptionType.subcommand,
						options = {
							{
								name = "lobby",
								description = "A lobby to be configured",
								type = commandOptionType.channel,
								required = true,
								channel_types = {
									channelType.voice
								}
							}
						}
					},
					{
						name = "capacity",
						description = "Set new room capacity to copy from lobby",
						type = commandOptionType.subcommand,
						options = {
							{
								name = "lobby",
								description = "A lobby to be configured",
								type = commandOptionType.channel,
								required = true,
								channel_types = {
									channelType.voice
								}
							}
						}
					},
					{
						name = "permissions",
						description = "Disable all room permissions",
						type = commandOptionType.subcommand,
						options = {
							{
								name = "lobby",
								description = "A lobby to be configured",
								type = commandOptionType.channel,
								required = true,
								channel_types = {
									channelType.voice
								}
							}
						}
					},
					{
						name = "role",
						description = "Reset default managed role to @everyone",
						type = commandOptionType.subcommand,
						options = {
							{
								name = "lobby",
								description = "A lobby to be configured",
								type = commandOptionType.channel,
								required = true,
								channel_types = {
									channelType.voice
								}
							}
						}
					}
				}
			},
			{
				name = "matchmaking",
				description = "Matchmaking lobby settings",
				type = commandOptionType.subcommandGroup,
				options = {
					{
						name = "target",
						description = "Reset matchmaking target to current category",
						type = commandOptionType.subcommand,
						options = {
							{
								name = "lobby",
								description = "A lobby to be configured",
								type = commandOptionType.channel,
								required = true,
								channel_types = {
									channelType.voice
								}
							}
						}
					},
					{
						name = "mode",
						description = "Reset matchmaking mode to random",
						type = commandOptionType.subcommand,
						options = {
							{
								name = "lobby",
								description = "A lobby to be configured",
								type = commandOptionType.channel,
								required = true,
								channel_types = {
									channelType.voice
								}
							}
						}
					}
				}
			},
			{
				name = "companion",
				description = "Lobby companion settings",
				type = commandOptionType.subcommandGroup,
				options = {
					{
						name = "category",
						description = "Reset companion category to use lobby settings",
						type = commandOptionType.subcommand,
						options = {
							{
								name = "lobby",
								description = "A lobby to be configured",
								type = commandOptionType.channel,
								required = true,
								channel_types = {
									channelType.voice
								}
							}
						}
					},
					{
						name = "name",
						description = "Reset companion name to \"private-chat\"",
						type = commandOptionType.subcommand,
						options = {
							{
								name = "lobby",
								description = "A lobby to be configured",
								type = commandOptionType.channel,
								required = true,
								channel_types = {
									channelType.voice
								}
							}
						}
					},
					{
						name = "greeting",
						description = "Disable companion greeting",
						type = commandOptionType.subcommand,
						options = {
							{
								name = "lobby",
								description = "A lobby to be configured",
								type = commandOptionType.channel,
								required = true,
								channel_types = {
									channelType.voice
								}
							}
						}
					},
					{
						name = "log",
						description = "Disable companion logging",
						type = commandOptionType.subcommand,
						options = {
							{
								name = "lobby",
								description = "A lobby to be configured",
								type = commandOptionType.channel,
								required = true,
								channel_types = {
									channelType.voice
								}
							}
						}
					}
				}
			},
			{
				name = "server",
				description = "Server settings",
				type = commandOptionType.subcommandGroup,
				options = {
					{
						name = "limit",
						description = "Reset limit to 500",
						type = commandOptionType.subcommand
					},
					{
						name = "permissions",
						description = "Disable all permissions",
						type = commandOptionType.subcommand
					},
					{
						name = "role",
						description = "Reset default managed role to @everyone",
						type = commandOptionType.subcommand
					}
				}
			}
		}
	},
	{ -- 8
		name = "support",
		description = "Send invite to the support server",
	},
	{ -- 9
		name = "clone",
		description = "Spawn multiple clones of a channel",
		options = {
			{
				name = "source",
				description = "Which channel to copy",
				type = commandOptionType.channel,
				required = true,
				channel_types = {
					channelType.text,
					channelType.voice
				}
			},
			{
				name = "amount",
				description = "How many channels to create",
				type = commandOptionType.integer,
				required = true,
				min_value = 1,
				max_value = 50
			},
			{
				name = "name",
				description = "Channel names",
				type = commandOptionType.string
			}
		}
	},
	{ -- 10
		name = "delete",
		description = "Quickly delete several channels",
		options = {
			{
				name = "type",
				description = "Channel type",
				type = commandOptionType.string,
				required = true,
				choices = {
					{
						name = "text",
						value = "text"
					},
					{
						name = "voice",
						value = "voice"
					}
				}
			},
			{
				name = "category",
				description = "Category where channels will be deleted",
				type = commandOptionType.channel,
				channel_types = {
					channelType.category
				}
			},
			{
				name = "amount",
				description = "How many channels to delete",
				type = commandOptionType.integer,
				min_value = 1,
				max_value = 100
			},
			{
				name = "name",
				description = "Delete all the channels that match the name",
				type = commandOptionType.string
			},
			{
				name = "only_empty",
				description = "Whether to delete voice channels with connected users. Defaults to false",
				type = commandOptionType.boolean
			}
		}
	},
	{ -- 11
		name = "users",
		description = "Miscellaneous moderation and helper commands",
		options = {
			{
				name = "print",
				description = "Create a list of users that are in the channel",
				type = commandOptionType.subcommand,
				options = {
					{
						name = "channel",
						description = "Channels to be queried",
						type = commandOptionType.channel,
						required = true,
						channel_types = {
							channelType.voice,
							channelType.stage,
							channelType.category
						}
					},
					{
						name = "print_as",
						description = "Output mode, default is mention (will never ping)",
						type = commandOptionType.string,
						choices = {
							{
								name = "username",
								value = "username"
							},
							{
								name = "tag",
								value = "tag"
							},
							{
								name = "nickname",
								value = "nickname"
							},
							{
								name = "mention",
								value = "mention"
							},
							{
								name = "id",
								value = "id"
							}
						}
					},
					{
						name = "separator",
						description = "Separator string that will be put between entries of a list, default is space",
						type = commandOptionType.string
					}
				}
			},
			{
				name = "give",
				description = "Give users in a channel or lobby rooms a role",
				type = commandOptionType.subcommand,
				options = {
					{
						name = "channel",
						description = "Channel or lobby to be queried",
						type = commandOptionType.channel,
						required = true,
						channel_types = {
							channelType.voice,
							channelType.stage,
							channelType.category
						}
					},
					{
						name = "role",
						description = "Role to be given out",
						type = commandOptionType.role,
						required = true
					}
				}
			},
			{
				name = "remove",
				description = "Give users in a channel or lobby rooms a role",
				type = commandOptionType.subcommand,
				options = {
					{
						name = "channel",
						description = "Channel or lobby to be queried",
						type = commandOptionType.channel,
						required = true,
						channel_types = {
							channelType.voice,
							channelType.stage,
							channelType.category
						}
					},
					{
						name = "role",
						description = "Role to be given out",
						type = commandOptionType.role,
						required = true
					}
				}
			}
		}
	},
	{ -- 12
		name = "ping",
		description = "Check up on bot's status!"
	},
	{ -- 13
		name = "Invite",
		type = commandType.user
	},
	--[[{ -- 14
		name = "Clear messages above",
		type = commandType.message
	},
	{ -- 15
		name = "Clear messages below",
		type = commandType.message
	}]]
}

local debugCommands = {
	{
		name = "exec",
		description = "This is gonna be our little secret",
		options = {
			{
				name = "code",
				description = "What do you want me to do?",
				type = commandOptionType.string,
				required = true
			}
		}
	},
	{
		name = "shutdown",
		description = "Guess I'll die",
	}
}

coroutine.wrap(function ()
	CommandManager.overwriteGuildCommands(guild,commandsStructure)
	for _,command in ipairs(debugCommands) do CommandManager.createGuildCommand(guild, command) end
end)()

return CommandManager