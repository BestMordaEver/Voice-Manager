local enums = require "discordia".enums
local commandOptionType = enums.applicationCommandOptionType

local function apply(o, extra)
	if extra then for k, v in pairs(extra) do o[k] = v end end
	return o
end

return {
	subcommand = function (name, desc, options)
		return {
			name = name,
			description = desc,
			type = commandOptionType.subcommand,
			options = options,
		}
	end,

	group = function (name, desc, options)
		return {
			name = name,
			description = desc,
			type = commandOptionType.subcommandGroup,
			options = options,
		}
	end,

	string = function (name, desc, extra)
		return apply({
			name = name,
			description = desc,
			type = commandOptionType.string,
		}, extra)
	end,

	integer = function (name, desc, extra)
		return apply({
			name = name,
			description = desc,
			type = commandOptionType.integer,
		}, extra)
	end,

	boolean = function (name, desc, extra)
		return apply({
			name = name,
			description = desc,
			type = commandOptionType.boolean,
		}, extra)
	end,

	user = function (name, desc, extra)
		return apply({
			name = name,
			description = desc,
			type = commandOptionType.user,
		}, extra)
	end,

	channel = function (name, desc, channelTypes, extra)
		return apply({
			name = name,
			description = desc,
			type = commandOptionType.channel,
			channel_types = channelTypes,
		}, extra)
	end,

	role = function (name, desc, extra)
		return apply({
			name = name,
			description = desc,
			type = commandOptionType.role,
		}, extra)
	end,
}
