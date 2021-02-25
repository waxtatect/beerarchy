local sky_start = -100 -- black skybox displays under this depth
local dark_blue_start = 5001 -- black skybox displays under this depth
local black_start = 10001 -- black skybox displays under this depth

local player_list = {}

local timer = 0

local function node_ok(pos, fallback)
	fallback = fallback or "air"
	local node = minetest.get_node_or_nil(pos)

	if not node then
		return fallback
	end

	if minetest.registered_nodes[node.name] then
		return node.name
	end

	return fallback
end

local function toggle_visibility(player, b)
	player:set_sun({visible = b, sunrise_visible = b})
	player:set_moon({visible = b})
	player:set_stars({visible = b})
end

minetest.register_globalstep(function(dtime)
	timer = timer + dtime

	if timer < 2 then
		return
	end
	timer = 0

	for _, player in pairs(minetest.get_connected_players()) do
		local name = player:get_player_name()
		local pos = player:get_pos()

		pos.y = pos.y + 1.5 -- head level
		local head_node = node_ok(pos)

		pos.y = pos.y - 1.5 -- reset pos

		local ndef = minetest.registered_nodes[head_node]

		local current = player_list[name] or ""

		-- Noclip
		if (ndef.walkable == nil or ndef.walkable == true) and
			(ndef.drowning == nil or ndef.drowning == 0) and
			(ndef.damage_per_second == nil or ndef.damage_per_second <= 0) and
			(ndef.collision_box == nil or ndef.collision_box.type == "regular") and
			(ndef.node_box == nil or ndef.node_box.type == "regular")
		then
			if current ~= "noclip" then
				player:set_sky({type = "regular"})
				player_list[name] = "noclip"
			end
		-- Surface
		elseif pos.y > sky_start and pos.y < dark_blue_start and current ~= "surface" then
			snowdrift_enabled[name] = true
			player:set_sky({type = "regular", clouds = true})
			toggle_visibility(player, true)
			player_list[name] = "surface"
		-- Blackness
		elseif pos.y <= sky_start and pos.y > -5800 and current ~= "blackness" then
			snowdrift_enabled[name] = false
			player:set_sky({base_color = 0x000000, type = "plain", clouds = false})
			toggle_visibility(player, false)
			player_list[name] = "blackness"
		-- Hell
		elseif pos.y <= -5800 and pos.y > -6030 and current ~= "hell" then
			snowdrift_enabled[name] = false
			player:set_sky({base_color = 0x420000, type = "plain", clouds = false})
			toggle_visibility(player, false)
			player_list[name] = "hell"
		-- Everything else (blackness)
		elseif pos.y <= -6030 and pos.y > -18800 and current ~= "blackness" then
			snowdrift_enabled[name] = false
			player:set_sky({base_color = 0x000000, type = "plain", clouds = false})
			toggle_visibility(player, false)
			player_list[name] = "blackness"
		elseif pos.y <= -18800 and pos.y > -20020 and current ~= "paradise" then
			snowdrift_enabled[name] = false
			player:set_sky({type = "regular", clouds = false})
			toggle_visibility(player, false)
			player_list[name] = "paradise"
		elseif pos.y <= -20020 and current ~= "depths" then
			snowdrift_enabled[name] = false
			player:set_sky({type = "regular", clouds = false})
			toggle_visibility(player, false)
			player_list[name] = "depths"
		elseif pos.y > dark_blue_start and pos.y < black_start and current ~= "dark_blue" then
			snowdrift_enabled[name] = false
			player:set_sky({base_color = 0x000060, type = "plain", clouds = false})
			toggle_visibility(player, false)
			player_list[name] = "dark_blue"
		elseif pos.y >= black_start and current ~= "space" then
			snowdrift_enabled[name] = false
			player:set_sky({base_color = 0x000000, type = "plain", clouds = false})
			toggle_visibility(player, false)
			player_list[name] = "space"
		end
	end
end)

minetest.register_on_leaveplayer(function(player)
	local name = player:get_player_name()
	player_list[name] = nil
end)