local MESSAGE_INTERVAL = 300

important_message = {}
important_message.message =
"IMPORTANT!! This server will migrate to bigger hardware in the next couple of days."..
" There may be some intermittent outages and the migration will take about an hour as"..
" all data will be copied over. The new server address will be beerarchy.tk:30024."

function important_message.display_message()
	if important_message.message and important_message.message ~= "" then
		local msg = string.char(0x1b).."(c@#00ff00)"..important_message.message
		minetest.chat_send_all(msg)
	end
end

function important_message.start_spamming()
	important_message.display_message()
	minetest.after(MESSAGE_INTERVAL, important_message.start_spamming)
end

important_message.start_spamming()
