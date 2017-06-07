--[[
Sprint mod for Minetest by GunshipPenguin

To the extent possible under law, the author(s)
have dedicated all copyright and related and neighboring rights
to this software to the public domain worldwide. This software is
distributed without any warranty.
]]

local players = {}
local playerObjects = {}
local staminaHud = {}
local playerSkippies = {}

minetest.register_on_joinplayer(function(player)
	local playerName = player:get_player_name()

	player:get_physics_override().sneak_glitch = true

	players[playerName] = {
		sprinting = false,
		timeOut = 0,
		stamina = SPRINT_STAMINA,
		shouldSprint = false,
	}
	playerObjects[playerName] = player
	playerSkippies[playerName] = 0
	if SPRINT_HUDBARS_USED then
		hb.init_hudbar(player, "sprint")
	else
		players[playerName].hud = player:hud_add({
			hud_elem_type = "statbar",
			position = {x=0.5,y=1},
			size = {x=24, y=24},
			text = "sprint_stamina_icon.png",
			number = 20,
			alignment = {x=0,y=1},
			offset = {x=-263, y=-110},
			}
		)
	end
end)

minetest.register_on_leaveplayer(function(player)
	local playerName = player:get_player_name()
	players[playerName] = nil
	playerObjects[playerName] = nil
	playerSkippies[playerName] = nil
end)

minetest.register_globalstep(function(dtime)
	--Get the gametime
	local gameTime = minetest.get_gametime()

	--Loop through all connected players
	for playerName,playerInfo in pairs(players) do
		local player = minetest.get_player_by_name(playerName)
		if player ~= nil then
			--Check if the player should be sprinting
			if player:get_player_control()["aux1"] and player:get_player_control()["up"] then
				players[playerName]["shouldSprint"] = true
			elseif player:getpos().y > -2430 and player:getpos().y < -2360 and player:get_player_control()["up"] then
				players[playerName]["shouldSprint"] = true
			else
				players[playerName]["shouldSprint"] = false
			end

			--If the player is sprinting, create particles behind him/her
			if playerInfo["sprinting"] == true and gameTime % 0.1 == 0 then
				local numParticles = math.random(1, 2)
				local playerPos = player:getpos()
				local playerNode = minetest.get_node({x=playerPos["x"], y=playerPos["y"]-1, z=playerPos["z"]})
				if playerNode["name"] ~= "air" then
					for i=1, numParticles, 1 do
						minetest.add_particle({
							pos = {x=playerPos["x"]+math.random(-1,1)*math.random()/2,y=playerPos["y"]+0.1,z=playerPos["z"]+math.random(-1,1)*math.random()/2},
							vel = {x=0, y=5, z=0},
							acc = {x=0, y=-13, z=0},
							expirationtime = math.random(),
							size = math.random()+0.5,
							collisiondetection = true,
							vertical = false,
							texture = "sprint_particle.png",
						})
					end
				end
			end

			--Adjust player states
			if players[playerName]["shouldSprint"] == true then --Stopped
				setSprinting(playerName, true)
			elseif players[playerName]["shouldSprint"] == false then
				setSprinting(playerName, false)
			end

			--Lower the player's stamina by dtime if he/she is sprinting and set his/her state to 0 if stamina is zero
			if playerInfo["sprinting"] == true and not (player:getpos().y > -2430 and player:getpos().y < -2360) then
				playerInfo["stamina"] = playerInfo["stamina"] - dtime
				if playerInfo["stamina"] <= 0 then
					playerInfo["stamina"] = 0
					setSprinting(playerName, false)
				end

				if hbhunger then
					if playerSkippies[playerName] > 100 then
						local h = hbhunger.get_hunger_raw(playerObjects[playerName])
						if h > 0 then
							h = h-1
							hbhunger.hunger[playerName] = h
							hbhunger.set_hunger_raw(playerObjects[playerName])
						end
						playerSkippies[playerName] = 0
					else
						playerSkippies[playerName] = playerSkippies[playerName] + 1
					end
				end

			--Increase player's stamina if he/she is not sprinting and his/her stamina is less than SPRINT_STAMINA
			elseif playerInfo["sprinting"] == false and playerInfo["stamina"] < SPRINT_STAMINA then
				playerInfo["stamina"] = playerInfo["stamina"] + dtime
			end
			-- Cap stamina at SPRINT_STAMINA
			if playerInfo["stamina"] > SPRINT_STAMINA then
				playerInfo["stamina"] = SPRINT_STAMINA
			end

			--Update the players's hud sprint stamina bar

			if SPRINT_HUDBARS_USED then
				hb.change_hudbar(player, "sprint", playerInfo["stamina"])
			else
				local numBars = (playerInfo["stamina"]/SPRINT_STAMINA)*20
				player:hud_change(playerInfo["hud"], "number", numBars)
			end

			if minetest.get_node(player:getpos()).name == "default:water_source" and
			   (player:get_player_control()["up"] or player:get_player_control()["down"] or
				player:get_player_control()["left"] or player:get_player_control()["right"] or
				player:get_player_control()["jump"] or player:get_player_control()["sneak"]
				)
			then
				if hbhunger then
					if playerSkippies[playerName] > 200 then
						local h = hbhunger.get_hunger_raw(playerObjects[playerName])
						if h > 0 then
							h = h-1
							hbhunger.hunger[playerName] = h
							hbhunger.set_hunger_raw(playerObjects[playerName])
						end
						playerSkippies[playerName] = 0
					else
						playerSkippies[playerName] = playerSkippies[playerName] + 1
					end
				end
			end

			if player:get_player_control()["jump"] then
				if hbhunger then
					local attached_to = player:get_attach()
					if attached_to and attached_to:get_luaentity() then
						local entity = attached_to:get_luaentity()
						if not entity.driver then
							if playerSkippies[playerName] > 200 then
								local h = hbhunger.get_hunger_raw(playerObjects[playerName])
								if h > 0 then
									h = h-1
									hbhunger.hunger[playerName] = h
									hbhunger.set_hunger_raw(playerObjects[playerName])
								end
								playerSkippies[playerName] = 0
							else
								playerSkippies[playerName] = playerSkippies[playerName] + 1
							end
						end
					end
				end
			end

			if player:get_player_control()["jump"] and player:get_player_control()["sneak"] then
				if hbhunger then
					if playerSkippies[playerName] > 200 then
						local h = hbhunger.get_hunger_raw(playerObjects[playerName])
						if h > 0 then
							h = h-1
							hbhunger.hunger[playerName] = h
							hbhunger.set_hunger_raw(playerObjects[playerName])
						end
						playerSkippies[playerName] = 0
					else
						playerSkippies[playerName] = playerSkippies[playerName] + 2
					end
				end
			end

		end
	end

end)

function setSprinting(playerName, sprinting) --Sets the state of a player (0=stopped/moving, 1=sprinting)
	local player = minetest.get_player_by_name(playerName)
	if players[playerName] then
		players[playerName]["sprinting"] = sprinting
		if sprinting == true then
			if player:get_pos().y < 5001 then
				player:set_physics_override({speed=SPRINT_SPEED,jump=SPRINT_JUMP,gravity=1.0})
			elseif player:get_pos().y < 10001 then
				player:set_physics_override({speed=SPRINT_SPEED,jump=SPRINT_JUMP,gravity=0.75})
			elseif player:get_pos().y > 10000 then
				player:set_physics_override({speed=SPRINT_SPEED,jump=SPRINT_JUMP,gravity=0.5})
			end
		elseif sprinting == false then
			if player:get_pos().y < 5001 then
				player:set_physics_override({speed=1.0,jump=1.0,gravity=1.0})
			elseif player:get_pos().y < 10001 then
				player:set_physics_override({speed=1.0,jump=1.0,gravity=0.75})
			elseif player:get_pos().y > 10000 then
				player:set_physics_override({speed=1.0,jump=1.0,gravity=0.5})
			end
		end
		return true
	end
	return false
end
