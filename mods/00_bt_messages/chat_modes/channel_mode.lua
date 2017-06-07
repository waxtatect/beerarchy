
-- Channel mode

local allchannels = {} -- channel_name --> list of players
local playerschannel = {} -- playername --> channel_name

-- Define a special moderator channel that cannot be joined by regular players
local moderatorchannel = minetest.setting_get("chat_modes.channels.moderator") or "moderators"

local function channelcheck(playername, params)
	if #params < 1 then
		minetest.chat_send_player("Please specify a channel name")
		return false
	end
	if params[1] == moderatorchannel then
		return minetest.check_player_privs(playername, {basic_privs=true})
	else
		return true
	end
end

chat_modes.register_mode("channel", {
	help = "Send messages to a specific channel only.",

	can_register = function(playername, params)
		return channelcheck(playername, params)
	end,

	register = function(playername, params)
		if not channelcheck(playername, params) then
			return false
		end

		local channelname = params[1]
		playerschannel[playername] = channelname

		if not allchannels[channelname] then
			allchannels[channelname] = {}
		end

		local channelplayers = allchannels[ channelname ]



		channelplayers[playername] = minetest.get_player_by_name(playername)
		playerschannel[playername] = channelname

		return true
	end,

	deregister = function(playername)
		local channelname = playerschannel[playername]
		local channelplayers = allchannels[channelname]

		channelplayers[playername] = nil
		playerschannel[playername] = nil
	end,

	getPlayers = function(playername, message)
		local targetplayers = {}
		local channelname = playerschannel[playername]
		local channelplayers = allchannels[channelname]

		chat_modes.dodebug("Got channel for "..playername..": ", {channel=channelname, channelplayers=allchannels[channelname] })

		-- Use an explicit counter because #targetplayers is always 0
		local i = 1
		for playername,player in pairs(channelplayers) do
			targetplayers[i] = player
			i = i+1
		end

		chat_modes.dodebug("Valid players are ", targetplayers)

		return targetplayers
	end
})
