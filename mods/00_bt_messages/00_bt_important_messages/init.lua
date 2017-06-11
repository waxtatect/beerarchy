local MESSAGE_INTERVAL = 300

important_message = {}
important_message.message = ""

function important_message.display_message()
	if important_message.message and important_message.message ~= "" then
		local msg = string.char(0x1b).."(c@#ff0000)"..important_message.message
		minetest.chat_send_all(msg)
	end
end

function important_message.start_spamming()
	important_message.display_message()
	minetest.after(MESSAGE_INTERVAL, important_message.start_spamming)
end

if important_message.message and important_message.message ~= "" then
	important_message.start_spamming()
end
