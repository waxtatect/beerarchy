--[[
Sprint mod for Minetest by GunshipPenguin

To the extent possible under law, the author(s)
have dedicated all copyright and related and neighboring rights
to this software to the public domain worldwide. This software is
distributed without any warranty.
--]]

local sprint_speed = sprint.speed
local sprint_jump = sprint.jump
local sprint_stamina = sprint.stamina
local sprint_timeout = sprint.timeout
local sprint_hudbars_used = sprint.hudbars_used

local players = {}
local staminaHud = {}

local use_player_monoids = minetest.global_exists("player_monoids")

minetest.register_on_joinplayer(function(player)
	local playerName = player:get_player_name()
	players[playerName] = {
		state = 0,
		timeOut = 0,
		stamina = sprint_stamina
		moving = false
	}
	if sprint_hudbars_used then
		hb.init_hudbar(player, "sprint")
	else
		players[playerName].hud = player:hud_add({
			hud_elem_type = "statbar",
			position = {x = 0.5, y = 1},
			size = {x = 24, y = 24},
			text = "sprint_stamina_icon.png",
			number = 20,
			alignment = {x = 0, y = 1},
			offset = {x = -263, y = -110}
		})
	end
end)

minetest.register_on_leaveplayer(function(player)
	players[player:get_player_name()] = nil
end)

local function setState(playerName, state) -- Sets the state of a player (0=stopped, 1=moving, 2=primed, 3=sprinting)
	local player = minetest.get_player_by_name(playerName)
	local gameTime = minetest.get_gametime()
	if players[playerName] then
		players[playerName]["state"] = state
		if state == 0 then --Stopped
			if use_player_monoids then
				player_monoids.speed:del_change(player, "sprint:physics")
				player_monoids.jump:del_change(player, "sprint:physics")
			else
				player:set_physics_override({speed = 1, jump = 1})
			end
		elseif state == 2 then -- Primed
			players[playerName]["timeOut"] = gameTime
		elseif state == 3 then -- Sprinting
			local physics = {speed = sprint_speed, jump = sprint_jump}
			if use_player_monoids then
				player_monoids.speed:add_change(player, physics.speed, "sprint:physics")
				player_monoids.jump:add_change(player, physics.jump, "sprint:physics")
			else
				player:set_physics_override(physics)
			end
		end
		return true
	end
	return false
end

minetest.register_globalstep(function(dtime)
	-- Get the gametime
	local gameTime = minetest.get_gametime()

	-- Loop through all connected players
	for playerName,playerInfo in pairs(players) do
		local player = minetest.get_player_by_name(playerName)
		if player then
			-- Check if they are moving or not
			players[playerName]["moving"] = player:get_player_control()["up"]

			-- If the player has tapped w longer than sprint_timeout ago, set his/her state to 0
			if playerInfo["state"] == 2 then
				if playerInfo["timeOut"] + sprint_timeout < gameTime then
					players[playerName]["timeOut"] = nil
					setState(playerName, 0)
				end

			-- If the player is sprinting, create particles behind him/her
			elseif playerInfo["state"] == 3 and gameTime % 0.1 == 0 then
				local numParticles = math.random(1, 2)
				local playerPos = player:get_pos()
				local playerNode = minetest.get_node({x = playerPos.z, y = playerPos.y - 1, z = playerPos.z})
				if playerNode["name"] ~= "air" then
					for i = 1, numParticles, 1 do
						minetest.add_particle({
							pos = {
								x = playerPos.x + math.random(-1, 1) * math.random() / 2,
								y = playerPos.y + 0.1,
								z = playerPos.z + math.random(-1, 1) * math.random() / 2
							},
							velocity = {x = 0, y = 5, z = 0},
							acceleration = {x = 0, y = -13, z = 0},
							expirationtime = math.random(),
							size = math.random() + 0.5,
							collisiondetection = true,
							vertical = false,
							texture = "sprint_particle.png"
						})
					end
				end
			end

			-- Adjust player states
			if not players[playerName]["moving"] and playerInfo["state"] == 3 then -- Stopped
				setState(playerName, 0)
			elseif players[playerName]["moving"] and playerInfo["state"] == 0 then -- Moving
				setState(playerName, 1)
			elseif not players[playerName]["moving"] and playerInfo["state"] == 1 then -- Primed
				setState(playerName, 2)
			elseif players[playerName]["moving"] and playerInfo["state"] == 2 then -- Sprinting
				setState(playerName, 3)
			end

			-- Lower the player's stamina by dtime if he/she is sprinting and set his/her state to 0 if stamina is zero
			if playerInfo["state"] == 3 then
				playerInfo["stamina"] = playerInfo["stamina"] - dtime
				if playerInfo["stamina"] <= 0 then
					playerInfo["stamina"] = 0
					setState(playerName, 0)
				end

			-- Increase player's stamina if he/she is not sprinting and his/her stamina is less than sprint_stamina
			elseif playerInfo["state"] ~= 3 and playerInfo["stamina"] < sprint_stamina then
				playerInfo["stamina"] = playerInfo["stamina"] + dtime
			end
			-- Cap stamina at sprint_stamina
			if playerInfo["stamina"] > sprint_stamina then
				playerInfo["stamina"] = sprint_stamina
			end

			-- Update the players's hud sprint stamina bar
			if sprint_hudbars_used then
				hb.change_hudbar(player, "sprint", playerInfo["stamina"])
			else
				local numBars = (playerInfo["stamina"] / sprint_stamina) * 20
				player:hud_change(playerInfo["hud"], "number", numBars)
			end
		end
	end
end)