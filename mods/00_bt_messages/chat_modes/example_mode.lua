-- EXAMPLE
-- Copy this file to your mod and adjust it as required
-- You MUST add chat_modes to your depends.txt

-- ============================================

-- Check both if chat_modes is registered, and if it sucessfully activated.

if minetest.get_modpath("chat_modes") and chat_modes then

	local examplemode = {}

	chat_modes.register_mode("example", {
		help = "example",

		register = function(playername, params)
			examplemode[playername] = true
		end,

		deregister = function(playername)
			examplemode[playername] = nil
		end,

		getPlayers = function(playername, message)
			local targetplayers = {}
			local thisplayer = minetest.get_player_by_name(playername)
			
			-- INSERT LOGIC HERE

			return targetplayers
		end
	})
end
