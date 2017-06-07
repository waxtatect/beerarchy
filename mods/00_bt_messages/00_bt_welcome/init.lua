minetest.register_on_newplayer(function(player)
	if player then
		show_welcome_message(player)
	end
end)

minetest.register_chatcommand("welcome", {
	params = "",
	description = "Show welcome message.",
	func = function(name, param)
		local player = minetest.get_player_by_name(name)
		if player then
			show_welcome_message(player)
		end
		return true
	end,
})

function show_welcome_message(player)
	local formspec =		"size[11,7.7]textarea[0.5,0.5;10.5,7;welcome:welcome_textarea;;"..
							"Welcome "..player:get_player_name().."!\n\n"..
							"This is the world known as Beerarchy. This is an anarchy server"..
							" without moderation besides keeping the server up and running. Feel "..
							"free to say whatever you want in chat. Griefing in any form whatsoever"..
							" is permitted (destroying structures, lava casting, spawn killing). "..
							"For those who are easily offended, either mute the chat/ player, deal"..
							" with the lack of rules or leave if you can't handle anarchy.\n\n"..
							"This server has a ranking system in place. Right now you are a N00b."..
							" various activities (traveling, mining, killing mobs, etc.) will increase "..
							"your ranks in various areas, which add up to a total weighted experience."..
							" Type /rank in chat to see your rankings.\n\n"..
							"The server also has a modified version of basic_machines, meaning you "..
							" must create specific constructors first before certain items can "..
							"be made. This applies to the basic machines, but also small devices"..
							" and the powerful digtron digger builder vehicles. I doubt however "..
							"that you will be smart and persistent enough to get to that level, as you"..
							" will need to gather materials that can only be found in hell. You must "..
							"travel to below -3000 to get these materials, and I got some surprises"..
							" for you on the way there. But of course, you will be richly rewarded "..
							"for your troubles getting there.\n\n"..
							"Good luck "..player:get_player_name()..", you will need it as you will"..
							" start in the desert. And oh, I forgot, food is hard to come by...\n\n"..
							"By continuing on this server, you agree to the rules and "..
							"that the administrator of this server is in no way "..
							"whatsoever liable for your actions or those of other players.\n\n"..
							"Some useful chat commands/ keys:\n\n"..
							"e -> Sprint. Careful: Sprinting drains hunger.\n"..
							"/music on|off -> Switch music on or off. There are some issues with"..
							" starting the music sometimes. If so, you can try \"/music on\" to"..
							" reset the music.\n"..
							"/mail -> Read mail/ offline messages.\n"..
							"/rank <player> -> Show your rank. If player is specified, show the"..
							" stats of player.\n"..
							"/clearbed -> Clear the bed as respawn position. Use this in case you"..
							" get stuck in your bed and need to respawn at the world starting point.\n"..
							"/verse -> Let SatanicBibleBot cite a verse from the Satanic bible or one"..
							" of the many Satanic wisdoms.\n"..
							"]button_exit[9,7;2,1;continue;Continue]"

	minetest.show_formspec(player:get_player_name(), "welcome:welcome", formspec)

end
