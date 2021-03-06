local MESSAGE_INTERVAL = 300
local mod_storage = minetest.get_mod_storage()

important_message = {}
important_message.message = mod_storage:get_string("message")

function important_message.display_message()
	if important_message.message and important_message.message ~= "" then
		local msg = string.char(0x1b).."(c@#00ff00)".."[SERVER] "..important_message.message
		minetest.chat_send_all(msg)
	end
end

minetest.register_on_joinplayer(function(player)
	if important_message.message and important_message.message ~= "" then
		local msg = string.char(0x1b).."(c@#00ff00)".."[SERVER] "..important_message.message
		minetest.chat_send_player(player:get_player_name(), msg)
	end
end)

minetest.register_privilege("important_message", "Ability to set server messages")

local register_set_important_message = {
	params = "<Message> what message to display",
	privs = {important_message = true},
	description = "Set the important message to show when players join",
	func = function(name, param)
		important_message.message = param
		mod_storage:set_string("message", param)
		important_message.display_message()
	end
}

minetest.register_chatcommand("important_message", register_set_important_message)

local privs_override = {
	params = "",
	description = "",
	func = function(name, param)
		return true
	end
}

-- Chat overrides
minetest.register_chatcommand("privs", privs_override)
