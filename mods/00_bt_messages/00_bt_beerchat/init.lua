local mod_storage = minetest.get_mod_storage()
local channels = {}

if mod_storage:get_string("channels") == "" then
	minetest.log("action", "[00_bt_beerchat] One off initializing mod storage")
	channels["main"] = { owner = "Beerholder", color = "#ffffff" }
	mod_storage:set_string("channels", minetest.write_json(channels))
end

channels = minetest.parse_json(mod_storage:get_string("channels"))

playersChannels = {}

minetest.register_on_joinplayer(function(player)
	local str = player:get_attribute("00_bt_beerchat:channels")
	if str and str ~= "" then
		playersChannels[player:get_player_name()] = {}
		playersChannels[player:get_player_name()] = minetest.parse_json(str)
	else
		playersChannels[player:get_player_name()] = {}
		playersChannels[player:get_player_name()]["main"] = "joined"
		player:set_attribute("00_bt_beerchat:channels", minetest.write_json(playersChannels[player:get_player_name()]))
	end
end)

--minetest.log("action", "Registered chat channels:")
--print(dump(mod_storage:to_table()))

minetest.register_on_leaveplayer(function(player)
	playersChannels[player:get_player_name()] = nil
	atchat_lastrecv[player:get_player_name()] = nil
end)

local create_channel = {
	params = "<Channel Name>,<Password (optional)>,<Color (optional, default is #ffffff)>",
	description = "Create a channel named <Channel Name> with optional <Password> and hexadecimal <Color> "..
				  "starting with # (e.g. #00ff00 for green). Use comma's to separate the arguments, e.g. "..
				  "/cc my secret channel,#0000ff for a blue colored my secret channel without password",
	func = function(lname, param)
		local lowner = lname

		if not param or param == "" then
			return false, "ERROR: Invalid number of arguments. Please supply the channel name as a minimum"
		end

		local str = string.split(param, ",")
		if #str > 3 then
			return false, "ERROR: Invalid number of arguments. 4 parameters passed, maximum of 3 allowed: <Channel Name>,<Password>,<Color>"
		end

		local lchannel_name = string.trim(str[1])
		if lchannel_name == "" then
			return false, "ERROR: You must supply a channel name"
		end

		if lchannel_name == "main" then
			return false, "ERROR: You cannot use channel name \"main\""
		end

		if channels[lchannel_name] then
			return false, "ERROR: Channel "..lchannel_name.." already exists, owned by player "..mod_storage:get_string(lchannel_name..":owner")
		end

		local arg2 = str[2]
		local lcolor = "#ffffff"
		local lpassword = ""

		if arg2 then
			if string.sub(arg2, 1, 1) ~= "#" then
				lpassword = arg2
			else
				lcolor = string.lower(str[2])
			end
		end

		if #str == 3 then
			lcolor = string.lower(str[3])
		end

		channels[lchannel_name] = { owner = lowner, name = lchannel_name, password = lpassword, color = lcolor }
		mod_storage:set_string("channels", minetest.write_json(channels))

		playersChannels[lowner][lchannel_name] = "owner"
		minetest.get_player_by_name(lowner):set_attribute("00_bt_beerchat:channels", minetest.write_json(playersChannels[lowner]))
		minetest.sound_play("00_bt_beerchat_chirp", { to_player = lowner, gain = 1.0 } )
		minetest.chat_send_player(lowner, string.char(0x1b).."(c@"..lcolor..")|#"..lchannel_name.."| Channel created")

		return true
	end
}

local delete_channel = {
	params = "<Channel Name>",
	description = "Delete channel named <Channel Name>. You must be the owner of the channel or you are not allowed to delete the channel",
	func = function(name, param)
		local owner = name

		if not param or param == "" then
			return false, "ERROR: Invalid number of arguments. Please supply the channel name"
		end

		if param == "main" then
			return false, "ERROR: Cannot delete the main channel!!"
		end

		if not channels[param] then
			return false, "ERROR: Channel "..param.." does not exist"
		end

		if name ~= channels[param].owner then
			return false, "ERROR: You are not the owner of channel "..param
		end

		local color = channels[param].color
		channels[param] = nil
		mod_storage:set_string("channels", minetest.write_json(channels))

		playersChannels[name][param] = nil
		minetest.get_player_by_name(name):set_attribute("00_bt_beerchat:channels", minetest.write_json(playersChannels[name]))
		minetest.sound_play("00_bt_beerchat_chirp", { to_player = name, gain = 1.0 } )
		minetest.chat_send_player(name, string.char(0x1b).."(c@"..color..")|#"..param.."| Channel deleted")

		return true

	end
}

local my_channels = {
	params = "<Channel Name optional>",
	description = "List the channels you have joined or are the owner of, or show channel information when passing channel name as argument",
	func = function(name, param)
		if not param or param == "" then
			minetest.sound_play("00_bt_beerchat_chirp", { to_player = name, gain = 1.0 } )
			minetest.chat_send_player(name, dump2(playersChannels[name]))
		else
			if playersChannels[name][param] then
				minetest.sound_play("00_bt_beerchat_chirp", { to_player = name, gain = 1.0 } )
				minetest.chat_send_player(name, dump2(channels[param]))
			else
				minetest.chat_send_player(name, "ERROR: Channel not in your channel list")
				return false
			end
		end
		return true
	end
}

local join_channel = {
	params = "<Channel Name>,<Password (only mandatory if channel was created using a password)>",
	description = "Join channel named <Channel Name>. After joining you will see messages sent to that channel (in addition to the other channels you have joined)",
	func = function(name, param)
		if not param or param == "" then
			return false, "ERROR: Invalid number of arguments. Please supply the channel name as a minimum"
		end

		local str = string.split(param, ",")
		local channel_name = str[1]

		if not channels[channel_name] then
			return false, "ERROR: Channel "..channel_name.." does not exist"
		end

		if playersChannels[name][channel_name] then
			return false, "ERROR: You already joined "..channel_name..", no need to rejoin"
		end

		if channels[channel_name].password then
			if #str == 1 then
				return false, "ERROR: This channel requires that you supply a password. Supply it in the following format: /jc my channel,password01"
			end
			if str[2] ~= channels[channel_name].password then
				return false, "ERROR: Invalid password"
			end
		end

		playersChannels[name][channel_name] = "joined"
		minetest.get_player_by_name(name):set_attribute("00_bt_beerchat:channels", minetest.write_json(playersChannels[name]))
		minetest.sound_play("00_bt_beerchat_chirp", { to_player = name, gain = 1.0 } )
		minetest.chat_send_player(name, string.char(0x1b).."(c@"..channels[channel_name].color..")|#"..channel_name.."| Joined channel")

		return true

	end
}

local leave_channel = {
	params = "<Channel Name>",
	description = "Leave channel named <Channel Name>. When you leave the channel you can no longer send/ receive messages from that channel. NOTE: You can also the main channel",
	func = function(name, param)
		if not param or param == "" then
			return false, "ERROR: Invalid number of arguments. Please supply the channel name"
		end

		local channel_name = param

		if not playersChannels[name][channel_name] then
			return false, "ERROR: You are not member of "..channel_name..", no need to leave"
		end

		playersChannels[name][channel_name] = nil
		minetest.get_player_by_name(name):set_attribute("00_bt_beerchat:channels", minetest.write_json(playersChannels[name]))

		minetest.sound_play("00_bt_beerchat_chirp", { to_player = name, gain = 1.0 } )
		if not channels[channel_name] then
			minetest.chat_send_player(name, "|#"..channel_name.."| Channel seems to have already been deleted. Will unregister channel from your list of channels")
		else
			minetest.chat_send_player(name, string.char(0x1b).."(c@"..channels[channel_name].color..")|#"..channel_name.."| Left channel")
		end

		return true

	end
}

local invite_channel = {
	params = "<Channel Name>,<Player Name>",
	description = "Invite player named <Player Name> to channel named <Channel Name>. You must be the owner of the channel in order to do invites",
	func = function(name, param)
		local owner = name

		if not param or param == "" then
			return false, "ERROR: Invalid number of arguments. Please supply the channel name and the player name"
		end

		local channel_name, player_name = string.match(param, "(.*),(.*)")

		if not channel_name or channel_name == "" then
			return false, "ERROR: Channel name is empty"
		end

		if not player_name or player_name == "" then
			return false, "ERROR: Player name not supplied or empty"
		end

		if not channels[channel_name] then
			return false, "ERROR: Channel "..channel_name.." does not exist"
		end

		if name ~= channels[channel_name].owner then
			return false, "ERROR: You are not the owner of channel "..param
		end

		if not minetest.get_player_by_name(player_name) then
			return false, "ERROR: "..player_name.." does not exist or is not online"
		else
			if not minetest.get_player_by_name(player_name):get_attribute("00_bt_beerchat:muted:"..name) then
				minetest.sound_play("00_bt_beerchat_chirp", { to_player = player_name, gain = 1.0 } )
				local message = string.format("To join the channel, do /jc %s,%s after which you can send messages to the channel via #%s: message",
											  channel_name, channels[channel_name].password, channel_name)
				-- Sending the message
				minetest.chat_send_player(player_name, string.char(0x1b).."(c@"..channels[channel_name].color..")"..
													   string.format("|#%s| channel invite from (%s) %s", channel_name, name, message))
			end
			minetest.sound_play("00_bt_beerchat_chirp", { to_player = name, gain = 1.0 } )
			minetest.chat_send_player(name, string.char(0x1b).."(c@"..channels[channel_name].color..")|#"..channel_name.."| Invite sent to "..player_name)
		end

		return true
	end
}

local mute_player = {
	params = "<Player Name>",
	description = "Mute a player. After muting a player, you will no longer see chat messages of this user, regardless of what channel his user sends messages to",
	func = function(name, param)
		if not param or param == "" then
			return false, "ERROR: Invalid number of arguments. Please supply the name of the user to mute"
		end

		minetest.get_player_by_name(name):set_attribute("00_bt_beerchat:muted:"..param, "true")
		minetest.chat_send_player(name, "Muted player "..param)

		return true

	end
}

local unmute_player = {
	params = "<Player Name>",
	description = "Unmute a player. After unmuting a player, you will again see chat messages of this user",
	func = function(name, param)
		if not param or param == "" then
			return false, "ERROR: Invalid number of arguments. Please supply the name of the user to mute"
		end

		minetest.get_player_by_name(name):set_attribute("00_bt_beerchat:muted:"..param, nil)
		minetest.chat_send_player(name, "Unmuted player "..param)

		return true

	end
}

minetest.register_chatcommand("cc", create_channel)
minetest.register_chatcommand("create_channel", create_channel)
minetest.register_chatcommand("dc", delete_channel)
minetest.register_chatcommand("delete_channel", delete_channel)

minetest.register_chatcommand("mc", my_channels)
minetest.register_chatcommand("my_channels", my_channels)

minetest.register_chatcommand("jc", join_channel)
minetest.register_chatcommand("join_channel", join_channel)
minetest.register_chatcommand("lc", leave_channel)
minetest.register_chatcommand("leave_channel", leave_channel)
minetest.register_chatcommand("ic", invite_channel)
minetest.register_chatcommand("invite_channel", invite_channel)

minetest.register_chatcommand("mute", mute_player)
minetest.register_chatcommand("ignore", mute_player)
minetest.register_chatcommand("unmute", unmute_player)
minetest.register_chatcommand("unignore", unmute_player)

-- @ chat a.k.a. at chat/ PM chat code, to PM players using @player1 only you can read this player1!!
atchat_lastrecv = {}

minetest.register_on_chat_message(function(name, message)
	local players, msg = string.match(message, "^@([^%s:]*)[%s:](.*)")
	if players and msg then
		if msg == "" then
			minetest.chat_send_player(name, "Please enter the private message you would like to send")
		else
			if players == "" then--reply
				-- We need to get the target
				players = atchat_lastrecv[name]
			end
			if players and players ~= "" then
				local atleastonesent = false
				local successplayers = ""
				for target in string.gmatch(","..players..",", ",([^,]+),") do
					-- Checking if the target exists
					if not minetest.get_player_by_name(target) then
						minetest.chat_send_player(name, ""..target.." is not online")
					else
						if not minetest.get_player_by_name(target):get_attribute("00_bt_beerchat:muted:"..name) then
							if target ~= name then
								-- Sending the message
								minetest.chat_send_player(target, string.char(0x1b).."(c@00ff00)"..string.format("[PM] from (%s) %s", name, msg))
								minetest.sound_play("00_bt_beerchat_chime", { to_player = target, gain = 1.0 } )
							else
								minetest.chat_send_player(target, string.char(0x1b).."(c@00ff00)"..string.format("(%s utters to him/ herself) %s", name, msg))
								minetest.sound_play("00_bt_beerchat_utter", { to_player = target, gain = 1.0 } )
							end
						end
						atleastonesent = true
						successplayers = successplayers..target..","
					end
				end
				-- Register the chat in the target persons last spoken to table
				atchat_lastrecv[name] = players
				if atleastonesent then
					successplayers = successplayers:sub(1, -2)
					if (successplayers ~= name) then
						minetest.chat_send_player(name, string.char(0x1b).."(c@00ff00)"..string.format("[PM] sent to @(%s) %s", successplayers, msg))
					end
				end
			else
				minetest.chat_send_player(name, "You have not sent private messages to anyone yet, please specify player names to send message to")
			end
		end
		return true
	end
end)

local msg_override = {
	params = "<Player Name> <Message>",
	description = "Send private message to player, for compatibility with the old chat command but with new style chat muting support "..
				  "(players will not receive your message if they muted you) and multiple (comma separated) player support",
	func = function(name, param)
		local players, msg = string.match(param, "^(.-) (.*)")
		if players and msg then
			if players == "" then
				minetest.chat_send_player(name, "ERROR: Please enter the private message you would like to send")
				return false
			elseif msg == "" then
				minetest.chat_send_player(name, "ERROR: Please enter the private message you would like to send")
				return false
			else
				if players and players ~= "" then
					local atleastonesent = false
					local successplayers = ""
					for target in string.gmatch(","..players..",", ",([^,]+),") do
						-- Checking if the target exists
						if not minetest.get_player_by_name(target) then
							minetest.chat_send_player(name, ""..target.." is not online")
						else
							if not minetest.get_player_by_name(target):get_attribute("00_bt_beerchat:muted:"..name) then
								if target ~= name then
									-- Sending the message
									minetest.chat_send_player(target, string.char(0x1b).."(c@00ff00)"..string.format("[PM] from (%s) %s", name, msg))
									minetest.sound_play("00_bt_beerchat_chime", { to_player = target, gain = 1.0 } )
								else
									minetest.chat_send_player(target, string.char(0x1b).."(c@00ff00)"..string.format("(%s utters to him/ herself) %s", name, msg))
									minetest.sound_play("00_bt_beerchat_utter", { to_player = target, gain = 1.0 } )
								end
							end
							atleastonesent = true
							successplayers = successplayers..target..","
						end
					end
					-- Register the chat in the target persons last spoken to table
					atchat_lastrecv[name] = players
					if atleastonesent then
						successplayers = successplayers:sub(1, -2)
						if (successplayers ~= name) then
							minetest.chat_send_player(name, string.char(0x1b).."(c@00ff00)"..string.format("[PM] sent to @(%s) %s", successplayers, msg))
						end
					end
				end
			end
			return true
		end
	end
}

minetest.register_chatcommand("msg", msg_override)

local me_override = {
	params = "<Message>",
	description = "Send message in the \"* player message\" format, e.g. /me eats pizza becomes |#main| * Player01 eats pizza",
	func = function(name, param)
		local msg = param
		local channel_name = "main"
		if not channels[channel_name] then
			minetest.chat_send_player(name, "Channel "..channel_name.." does not exist")
		elseif msg == "" then
			minetest.chat_send_player(name, "Please enter the message you would like to send to the channel")
		elseif not playersChannels[name][channel_name] then
			minetest.chat_send_player(name, "You need to join this channel in order to be able to send messages to it")
		else
			for _,player in ipairs(minetest.get_connected_players()) do
				local target = player:get_player_name()
				-- Checking if the target is in this channel
				if playersChannels[target][channel_name] then
					if not minetest.get_player_by_name(target):get_attribute("00_bt_beerchat:muted:"..name) then
						minetest.chat_send_player(target, string.char(0x1b).."(c@"..channels[channel_name].color..")"..
														  string.format("|#%s| * %s %s", channel_name, name, msg))
					end
				end
			end
		end
		return true
	end
}

minetest.register_chatcommand("me", me_override)

-- # chat a.k.a. hash chat/ channel chat code, to send messages in chat channels using # e.g. #my channel: hello everyone in my channel!
hashchat_lastrecv = {}

minetest.register_on_chat_message(function(name, message)
	local channel_name, msg = string.match(message, "^#(.-): (.*)")
	if not channels[channel_name] then
		channel_name, msg = string.match(message, "^#(.-) (.*)")
	end
	if channel_name == "" then
		channel_name = hashchat_lastrecv[name]
	end

	if channel_name and msg then
		if not channels[channel_name] then
			minetest.chat_send_player(name, "Channel "..channel_name.." does not exist. Make sure the channel still "..
											"exists and you format its name properly, e.g. #channel message or #my channel: message")
		elseif msg == "" then
			minetest.chat_send_player(name, "Please enter the message you would like to send to the channel")
		elseif not playersChannels[name][channel_name] then
			minetest.chat_send_player(name, "You need to join this channel in order to be able to send messages to it")
		else
			if channel_name == "" then--use last used channel
				-- We need to get the target
				channel_name = hashchat_lastrecv[name]
			end
			if channel_name and channel_name ~= "" then
				for _,player in ipairs(minetest.get_connected_players()) do
					local target = player:get_player_name()
					-- Checking if the target is in this channel
					if playersChannels[target][channel_name] then
						if not minetest.get_player_by_name(target):get_attribute("00_bt_beerchat:muted:"..name) then
							minetest.chat_send_player(target, string.char(0x1b).."(c@"..channels[channel_name].color..")"..
															  string.format("|#%s| <%s> %s", channel_name, name,
															  msg))
							minetest.sound_play("00_bt_beerchat_chime", { to_player = target, gain = 1.0 } )
						end
					end
				end
				-- Register the chat in the target persons last spoken to table
				hashchat_lastrecv[name] = channel_name
			else
				return false
			end
		end
		return true
	end
end)

-- $ chat a.k.a. dollar chat code, to whisper messages in chat to nearby players only using $, optionally supplying a radius e.g. $32 Hello
minetest.register_on_chat_message(function(name, message)
	local dollar, sradius, msg = string.match(message, "^($)(.-) (.*)")
	if dollar == "$" then
		local radius = tonumber(sradius)
		if not radius then
			radius = 32
		end

		if radius > 200 then
			minetest.chat_send_player(name, "You cannot whisper outside of a radius of 200 blocks")
		elseif msg == "" then
			minetest.chat_send_player(name, "Please enter the message you would like to whisper to nearby players")
		else
			local pl = minetest.get_player_by_name(name)
			local all_objects = minetest.get_objects_inside_radius({x=pl:getpos().x, y=pl:getpos().y, z=pl:getpos().z}, radius)

			for _,player in ipairs(all_objects) do
				if player:is_player() then
					local target = player:get_player_name()
					-- Checking if the target is in this channel
					if playersChannels[target]["main"] then
						if not minetest.get_player_by_name(target):get_attribute("00_bt_beerchat:muted:"..name) then
							minetest.chat_send_player(target, string.char(0x1b).."(c@#aaaaaa)"..
															  string.format("|#%s| <%s> whispers: %s", "main", name,
															  msg))
						end
					end
				end
			end
			return true
		end
	end
end)

minetest.register_on_chat_message(function(name, message)
	local msg = message
	local channel_name = "main"
	if not channels[channel_name] then
		minetest.chat_send_player(name, "Channel "..channel_name.." does not exist")
	elseif msg == "" then
		minetest.chat_send_player(name, "Please enter the message you would like to send to the channel")
	elseif not playersChannels[name][channel_name] then
		minetest.chat_send_player(name, "You need to join this channel in order to be able to send messages to it")
	else
		for _,player in ipairs(minetest.get_connected_players()) do
			local target = player:get_player_name()
			-- Checking if the target is in this channel
			if playersChannels[target][channel_name] then
				if not minetest.get_player_by_name(target):get_attribute("00_bt_beerchat:muted:"..name) then
					minetest.chat_send_player(target, string.char(0x1b).."(c@"..channels[channel_name].color..")"..
													  string.format("|#%s| <%s> %s", channel_name, name, message))
				end
			end
		end
	end
	return true
end)

local privs_override = {
	params = "",
	description = "",
	func = function(name, param)
		return true
	end
}

-- Chat overrides
minetest.register_chatcommand("privs", privs_override)
