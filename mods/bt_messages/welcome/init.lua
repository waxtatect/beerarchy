local function show_welcome_message(name)
	local text = ([[
						Welcome %s!

							This is the world known as Beerarchy. This is an anarchy server
						without moderation besides keeping the server up and running. Feel
						free to say whatever you want in chat. Griefing in any form whatsoever
						is permitted (destroying structures, lava casting, spawn killing).
						For those who are easily offended, either mute the chat/player, deal
						with the lack of rules or leave if you can't handle anarchy.


							This server has a ranking system in place. Right now you are a N00b.
						various activities (traveling, mining, killing mobs, etc.) will increase
						your ranks in various areas, which add up to a total weighted experience.
						Type /rank in chat to see your rankings.


							The server also has a modified version of basic_machines, meaning you
						must create specific constructors first before certain items can
						be made. This applies to the basic machines, but also small devices
						and the powerful digtron digger builder vehicles. I doubt however
						that you will be smart and persistent enough to get to that level, as you
						will need to gather materials that can only be found in hell. You must
						travel to below -3000 to get these materials, and I got some surprises
						for you on the way there. But of course, you will be richly rewarded
						for your troubles getting there.


						Good luck %s, you will need it as you will start in the desert.

						And oh, I forgot, food is hard to come by...



						By continuing on this server, you agree to the rules and
						that the administrator of this server is in no way
						whatsoever liable for your actions or those of other players.


						Some useful chat commands/keys:


						e -> Sprint. Careful: Sprinting drains hunger.

						/mail -> Read mail/offline messages.

						/rank <player> -> Show your rank. If player is specified, show the
						stats of player.

						/clearbed -> Clear the bed as respawn position. Use this in case you
						get stuck in your bed and need to respawn at the world starting point.

						/verse -> Let SatanicBibleBot cite a verse from the Satanic bible or one
						of the many Satanic wisdoms.]]):format(name, name)
	minetest.show_formspec(name, "welcome:welcome", ([[
		size[11,7.7]textarea[0.5,0.5;10.5,7;welcome:welcome_textarea;;%s]button_exit[9,7;2,1;continue;Continue]]):format(text))
end

minetest.register_on_newplayer(function(player)
	if player and player:is_player() then
		minetest.after(0, function()
			show_welcome_message(player:get_player_name())
		end)
	end
end)

minetest.register_chatcommand("welcome", {
	description = "Show welcome message.",
	func = function(name, param)
		show_welcome_message(name)
	end
})