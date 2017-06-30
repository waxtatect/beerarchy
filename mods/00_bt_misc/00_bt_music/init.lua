local players = {}
local playerMusic = {}
local playerMusicEnabled = {}
local mustStartNewMusic = {}

local skippy = 0

local musicTableFirstRun = {
	{ sound = "00_bt_music_second_stand", length = 228, gain = 1.0 },
}

local musicTableGeneric = {
--	{ sound = "00_bt_music_anitra_s_dance", length = 211, gain = 1.0 },
	{ sound = "00_bt_music_second_stand", length = 228, gain = 1.0 },
	{ sound = "00_bt_music_wolf_blood", length = 186, gain = 1.0 },
}

local musicTableArctic = {
	{ sound = "00_bt_music_viking_battle_song", length = 160, gain = 0.5 },
--	{ sound = "00_bt_music_solitude", length = 351, gain = 1.0 },
}

local musicTableWater = {
--	{ sound = "00_bt_music_jeux_d_eau", length = 421, gain = 1.0 },
	{ sound = "00_bt_music_alien_ruins", length = 54, gain = 1.0 },
}

local musicTableSpace = {
--	{ sound = "00_bt_music_random_gods", length = 333, gain = 1.0 },
	{ sound = "00_bt_music_alien_ruins", length = 54, gain = 1.0 },
--	{ sound = "00_bt_music_space_organ", length = 470, gain = 1.0 },
}

local musicTableEpic = {
	{ sound = "00_bt_music_the_dark_amulet", length = 165, gain = 1.0 },
}

local musicTableCastle = {
	{ sound = "00_bt_music_gregorian_chant", length = 192, gain = 1.0 },
	{ sound = "00_bt_music_vox_vulgaris_rokatanc", length = 234, gain = 1.0 },
--	{ sound = "00_bt_music_vox_vulgaris_cantiga", length = 312, gain = 1.0 },
}

local musicTableVillage = {
	{ sound = "00_bt_music_vox_vulgaris_rokatanc", length = 234, gain = 1.0 },
	{ sound = "00_bt_music_vox_vulgaris_cantiga", length = 312, gain = 1.0 },
--	{ sound = "00_bt_music_solitude", length = 351, gain = 1.0 },
}

local musicTableDesert = {
	{ sound = "00_bt_music_the_dark_amulet", length = 165, gain = 1.0 },
	{ sound = "00_bt_music_oud", length = 368, gain = 1.0 },
	{ sound = "00_bt_music_reverie", length = 295, gain = 1.0 },
}

local musicTableJungle = {
	{ sound = "00_bt_music_mist_forest", length = 198, gain = 1.0 },
	{ sound = "00_bt_music_sacred", length = 203, gain = 1.0 },
}

local musicTableCaves = {
	{ sound = "00_bt_music_dark_ambience", length = 272, gain = 1.0 },
	{ sound = "00_bt_music_banshee", length = 243, gain = 1.0 },
	{ sound = "00_bt_music_evil_bgm", length = 284, gain = 1.0 },
	{ sound = "00_bt_music_shades", length = 404, gain = 1.0 },
}

local musicTableHell = {
	{ sound = "00_bt_music_gregorian_chant", length = 192, gain = 1.0 },
	{ sound = "00_bt_music_hellfire", length = 73, gain = 1.0 },
	{ sound = "00_bt_music_acheron", length = 240, gain = 1.0 },
}

local musicTableNyan = {
	{ sound = "00_bt_music_nyan_cat", length = 216, gain = 1.0 },
}

minetest.register_on_joinplayer(function(player)
	local playerName = player:get_player_name()
	players[playerName] = player
	playerMusicEnabled[playerName] = true
	mustStartNewMusic[playerName] = true
end)

minetest.register_on_leaveplayer(function(player)
	local playerName = player:get_player_name()
	local soundHandle = playerMusic[playerName]
	if soundHandle and soundHandle ~= "off" then
		minetest.sound_stop(soundHandle)
	end
	playerMusicEnabled[playerName] = nil
	players[playerName] = nil
	mustStartNewMusic[playerName] = nil

--	collectgarbage()
end)

minetest.register_globalstep(function(dtime)
	if skippy >= 200 then
		skippy = 0
		for name,player in pairs(players) do
			local pos = player:getpos()

			if not pos then
				break
			end

			if minetest.get_node( { x = pos.x, y = pos.y, z = pos.z } ).name == "ignore" then
				break
			end

			-- If player music is no longer there, start a new song
			-- if music for this player is enabled
			if playerMusic[name] == nil and playerMusicEnabled[name] and mustStartNewMusic[name] then
				local musicTable = determine_music_table(player)

				if musicTable == nil then
					return
				end

				local musicIndex = math.random(1, #musicTable)
				local sound = musicTable[musicIndex]["sound"]
				local length = musicTable[musicIndex]["length"]
				local g = musicTable[musicIndex]["gain"]

				mustStartNewMusic[player:get_player_name()] = false
				local soundHandle = minetest.sound_play(sound,
					{ to_player = player:get_player_name(), gain = g }
				)
				playerMusic[player:get_player_name()] = soundHandle
				minetest.after(length + math.random(5, 60), clear_player_music, player)
			end
		end
	end
	skippy = skippy + 1
end)

function stop_music(player)
	if player then
		local name = player:get_player_name()
		if name then
			if playerMusic[name] then
				minetest.sound_stop(playerMusic[name])
			end
		end
	end
end

function clear_player_music(player)
	if player then
		local name = player:get_player_name()
		if name then
			if playerMusic[name] then
				playerMusic[name] = nil
				mustStartNewMusic[name] = true
			end
		end
	end
end

--[[function execute_music(player)
	if not player then
		return
	end

	local pos = player:getpos()

	if not pos then
		return
	end

	if playerMusic[player:get_player_name()] == "off" then
		minetest.after(30, execute_music, player)
	end

	if minetest.get_node( { x = pos.x, y = pos.y, z = pos.z } ).name == "ignore" then
		minetest.after(2, execute_music, player)
		return
	end

	local musicTable = determine_music_table(player)

	if musicTable == nil then
		return
	end

	local musicIndex = math.random(1, #musicTable)
	local sound = musicTable[musicIndex]["sound"]
	local length = musicTable[musicIndex]["length"]
	local g = musicTable[musicIndex]["gain"]

	local soundHandle = minetest.sound_play(sound,
		{ to_player = player:get_player_name(), gain = g }
	)
	playerMusic[player:get_player_name()] = soundHandle

	collectgarbage()

	minetest.after(length + math.random(5, 60), execute_music, player, false)
end]]--

function determine_music_table(player)
	if player == nil then return end

	local pos = player:getpos()

--	if not playerMusic[player:get_player_name()] then
--		return musicTableFirstRun
--	end

	if minetest.find_node_near(pos, 8, "nyancat:nyancat") then
		return musicTableNyan
	elseif
		minetest.get_node( { x = pos.x, y = pos.y, z = pos.z } ).name == "default:water_source" or
		minetest.get_node( { x = pos.x, y = pos.y - 1, z = pos.z } ).name == "default:water_source"
	then
		return musicTableWater
	elseif pos.y < -50 and pos.y >= -2357 then
		return musicTableCaves
	elseif pos.y < -2357 and pos.y > -2422 then
		return musicTableCastle
	elseif pos.y <= -2422 and pos.y >= -5800 then
		return musicTableCaves
	elseif pos.y < -5800 and pos.y > -6030 then
		return musicTableHell
	elseif pos.y <= -6030 then
		return musicTableCaves
	elseif pos.y > 5000 then
		return musicTableSpace
	elseif
		(minetest.find_node_near(pos, 8, "default:glass") or minetest.find_node_near(pos, 8, "xpanes:pane")) and
		 minetest.find_node_near(pos, 8, "doors:door_wood_a") and minetest.find_node_near(pos, 8, "default:dirt_with_grass")
	then
		return musicTableCastle
	elseif
		minetest.get_node( { x = pos.x, y = pos.y - 1, z = pos.z } ).name == "default:dirt_with_dry_grass" or
		minetest.get_node( { x = pos.x, y = pos.y - 1, z = pos.z } ).name == "default:desert_sand" or
		minetest.get_node( { x = pos.x, y = pos.y - 1, z = pos.z } ).name == "default:desert_stone" or
		minetest.get_node( { x = pos.x, y = pos.y - 1, z = pos.z } ).name == "default:sand" or
		minetest.get_node( { x = pos.x, y = pos.y - 1, z = pos.z } ).name == "default:silver_sand"
	then
		return musicTableDesert
	elseif
		minetest.get_node( { x = pos.x, y = pos.y - 1, z = pos.z } ).name == "default:dirt_with_rainforest_litter" or
		minetest.find_node_near(pos, 4, "default:jungletree")
	then
		return musicTableJungle
	elseif
		minetest.get_node( { x = pos.x, y = pos.y - 1, z = pos.z } ).name == "default:dirt_with_snow" or
		minetest.get_node( { x = pos.x, y = pos.y - 1, z = pos.z } ).name == "default:snow" or
		minetest.get_node( { x = pos.x, y = pos.y - 1, z = pos.z } ).name == "default:snowblock" or
		minetest.get_node( { x = pos.x, y = pos.y - 1, z = pos.z } ).name == "default:ice" or
		minetest.find_node_near(pos, 4, "default:pine_tree")
	then
		return musicTableArctic
	else
		return musicTableGeneric
	end
end

minetest.register_chatcommand("music", {
	params = "on/ off",
	description = "Turn music on/ off",
	func = function(name, param)
		local player = minetest.get_player_by_name(name)
		if not player then
			return false
		end
		if param == "off" then
			local soundHandle = playerMusic[player:get_player_name()]
			if soundHandle then
				minetest.sound_stop(soundHandle)
			end
			playerMusicEnabled[player:get_player_name()] = false
			playerMusic[player:get_player_name()] = nil
			collectgarbage()
		elseif param == "on" then
			playerMusic[player:get_player_name()] = nil
			playerMusicEnabled[player:get_player_name()] = true
		else
			minetest.chat_send_player(name, "ERROR: Please only use \"on\" or \"off\" (without the quotes) as parameter to the /music chat command.")
		end
	end,
})
