local mod_storage = minetest.get_mod_storage()

local important_message = {message = mod_storage:get_string("message")}

local function get_message()
	local msg, b = "", false
	if important_message.message and important_message.message ~= "" then
		msg, b = string.char(0x1b) .. "(c@#00ff00)" .. "[SERVER] " .. important_message.message, true
	end
	return msg, b
end

minetest.register_on_joinplayer(function(player)
	local msg, b = get_message()
	if b then
		minetest.chat_send_player(player:get_player_name(), msg)
	end
end)

minetest.register_privilege("important_message", "Ability to set server message")

minetest.register_chatcommand("important_message", {
	params = "<Message> what message to display",
	privs = {important_message = true},
	description = "Set the important message to show when players join",
	func = function(param)
		important_message.message = param
		mod_storage:set_string("message", param)
		minetest.chat_send_all(get_message())
	end
})