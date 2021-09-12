return {
	owners = {
		["188731184501620736"] = true,	-- Riddles
		["272093076778909707"] = true,	-- SosnoviyBor
	},
	guildFeed = nil,							-- channel that will list all guilds, that invite the bot; can be nil
	wakeUpFeed = "676432067566895111",			-- channel that will receive a message every time the bot starts up
	statsFeed = "676432067566895111",			-- channel that will receive stats every hour (guild count, active users, channels and lobbies)
	stderr = "686261668522491980",				-- channel than will post error messages; can be nil
	heartbeat = true,							-- perform heartbeat check?
	heartbeatChannel = "676791988518912020",	-- channel that contains heartbeat message
	heartbeatMessage = "886681295499968532",	-- message that will be edited every minute
	dailyreboot = false,						-- bot will reboot whenever there are no active users, once per day
	sendStats = true							-- send stats to bot list sites (top.gg and the likes)
}