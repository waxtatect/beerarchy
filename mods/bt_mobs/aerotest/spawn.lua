local rad = math.rad
local random = aerotest.random
local spawntimer = 0

-- Count eagles in specified radius or active_object_send_range_blocks, returns a table containing numbers
local function count_objects(pos, radius, name)
	if not radius then radius = aerotest.abo * 16 end

	local all_objects = minetest.get_objects_inside_radius(pos, radius)
	local count = 0

	for _, obj in ipairs(all_objects) do
		local entity = obj:get_luaentity()
		if entity and entity.name == name then
			count = count + 1
		end
	end
	return count
end

-- Spawn function
function aerotest.spawnstep(dtime)
	spawntimer = spawntimer + dtime
	if spawntimer > aerotest.spawncheck_frequence then
		for _, player in ipairs(minetest.get_connected_players()) do
			if random(100) < aerotest.spawnchance then
				local pos = player:get_pos()
				if player and pos.y > aerotest.eagleminheight and pos.y < 500 then
					local yaw = player:get_look_horizontal()
					local count = count_objects(pos, nil, "aerotest:eagle")

					if count < aerotest.maxeagle then
						pos = mobkit.pos_translate2d(pos, yaw + rad(random(-55, 55)), random(10, aerotest.abr))
						local spawnpos = {x = pos.x, y = pos.y + random(aerotest.abr / 2, aerotest.abr), z = pos.z}

						local obj = minetest.add_entity(spawnpos, "aerotest:eagle")
						if obj then
							local self = obj:get_luaentity()
							mobkit.clear_queue_high(self)
							obj:set_yaw(yaw)
							local velo = obj:get_pos()
							velo = vector.subtract(mobkit.pos_translate2d(velo, yaw, 2), velo)
							obj:set_velocity({x = velo.x, y = velo.y + 3, z = velo.z})
							aerotest.hq_climb(self, 1)
						end
					end
				end
			end
		end
		spawntimer = 0
	end
end

-- Spawnit !!
minetest.register_globalstep(aerotest.spawnstep)