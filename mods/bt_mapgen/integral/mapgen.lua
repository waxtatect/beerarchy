local function touch(pmin1, pmax1, pmin2, pmax2)
	if not ((pmin1.x <= pmin2.x and pmin2.x <= pmax1.x) or (pmin2.x <= pmin1.x and pmin1.x <= pmax2.x)) then
		return false
	end

	if not ((pmin1.y <= pmin2.y and pmin2.y <= pmax1.y) or (pmin2.y <= pmin1.y and pmin1.y <= pmax2.y)) then
		return false
	end

	if not ((pmin1.z <= pmin2.z and pmin2.z <= pmax1.z) or (pmin2.z <= pmin1.z and pmin1.z <= pmax2.z)) then
		return false
	end

	return true
end


function integral.get_tree_coords(x, z)
	--local d = integral.tree_coords
	local d = {}
	d.pos = {}

	-- Hash the kilometer square this falls in.
	local seed = ((math.floor(x / 5000) % 5000) * 5000 + (782 + math.floor(z / 5000)) % 5000)
	math.randomseed(seed)

	d.height = math.random(3,10) * 100
	d.radius = math.floor(d.height * (math.random() + 4.5) / 100)

	-- Pick a spot somewhere in the middle of a kilometer square.
	d.pos.x = math.floor(math.random() * 2500 + 1250 + math.floor(x / 5000) * 5000)
	d.pos.z = math.floor(math.random() * 2500 + 1250 + math.floor(z / 5000) * 5000)
	d.pos.y = math.floor(100 + d.height * 0.5)

	return d
end


function integral.get_ground_root_coords(x, y, z, n, coords)
	local c = coords
	if not c then
		c = integral.get_tree_coords(x, z)
	end

	local rx = ((n % 3) - 1) * 100 + c.pos.x
	local ry = math.floor((1.5 - ((n - 7) % 11)) * 47)
	local rz = (math.floor(n / 3) - 2) * 100 + c.pos.z

	return {x=rx, y=ry, z=rz}
end


function integral.get_ground_root_number(x, y, z, coords)
	local c = coords
	if not c then
		c = integral.get_tree_coords(x, z)
	end

	local n1 = math.floor((x - c.pos.x) / 100 + 0.5) + 1
	local n2 = (math.floor((z - c.pos.z) / 100 + 0.5) + 1) * 3 + 3

	return n1 + n2
end


function integral.get_tree_root_coords(x, y, z, n, coords)
	local c = coords
	if not c then
		c = integral.get_tree_coords(x, z)
	end

	local rx = c.pos.x
	local ry = (6 - n) * 11 + c.pos.y
	local rz = c.pos.z

	return {x=rx, y=ry, z=rz}
end


function integral.get_tree_root_number(x, y, z, coords)
	local c = coords
	if not c then
		c = integral.get_tree_coords(x, z)
	end

	local n = 6 - math.floor((y - c.pos.y) / 11 + 0.5)

	return n
end


local c_air = minetest.get_content_id("air")
local c_ignore = minetest.get_content_id("ignore")

local c_stone = minetest.get_content_id("default:stone")
local c_petrified_wood = minetest.get_content_id("integral:petrified_wood")
local c_wood = minetest.get_content_id("integral:integral_wood")
local c_ironwood = minetest.get_content_id("integral:integral_ironwood")
local c_diamondwood = minetest.get_content_id("integral:integral_diamondwood")
local c_wwater = minetest.get_content_id("integral:weightless_water")
local c_sap = minetest.get_content_id("integral:sap")
local c_bark = minetest.get_content_id("integral:integral_bark")
local c_snow = minetest.get_content_id("default:snow")
local c_amber = minetest.get_content_id("integral:amber")
local c_petrified_animals = {
				minetest.get_content_id("integral:petrified_integrite"),
				minetest.get_content_id("integral:petrified_sheep"),
				minetest.get_content_id("integral:petrified_bee"),
				minetest.get_content_id("integral:petrified_kitten"),
				minetest.get_content_id("integral:petrified_cow"),
			}
local c_leaves = {
	minetest.get_content_id("integral:leaves1"),
	minetest.get_content_id("integral:leaves2"),
	minetest.get_content_id("integral:leaves3"),
	minetest.get_content_id("integral:leaves4"),
	minetest.get_content_id("integral:leaves5"),
}


local data = {}


function integral.generate(minp, maxp, seed)
	-- Deal with memory issues. This, of course, is supposed to be automatic.
	local mem = math.floor(collectgarbage("count")/1024)
	if mem > 500 then
		print("Integral is manually collecting garbage as memory use has exceeded 500K.")
		collectgarbage("collect")
	end

	local leaf_radius = 3

	local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
	vm:get_data(data)
	local a = VoxelArea:new({MinEdge = emin, MaxEdge = emax})
	local csize = vector.add(vector.subtract(maxp, minp), 1)

	local write = false

	local coords = integral.get_tree_coords(minp.x, minp.z)
	local width = coords.height * 0.2
	local r_y = coords.height * 0.5
	local bush = 1.1

	-- The z axis is off. Check this.
	local size = {x=width*1.25, y=r_y*1.25, z=coords.radius*1.6}
	local tree_p1 = vector.subtract(coords.pos, size)
	local tree_p2 = vector.add(coords.pos, size)

	-- If these boxes intersect, we might need to make part of the tree.
	if touch(minp, maxp, tree_p1, tree_p2) then
		local wood_noise = minetest.get_perlin_map({offset = 0, scale = 1, seed = -4640, spread = {x = 32, y = 32, z = 32}, octaves = 4, persist = 0.7, lacunarity = 2}, csize):get3dMap_flat(minp)

		local index3d = 0
		local ivm, y_dist, distance, y_ratio, radius, end_radius, center_x
		local r, dist1, ivm1, pos, leaf_type, chance
		for z = minp.z, maxp.z do
			for y = minp.y, maxp.y do
				for x = minp.x, maxp.x do
					index3d = index3d + 1
					ivm = a:index(x, y, z)

					y_dist = math.abs(y - coords.pos.y)
					if y_dist < size.y then
						y_ratio = (y - coords.pos.y) / r_y
						radius = coords.radius * (((r_y * 1.5) - y_dist) / r_y)
						end_radius = coords.radius * bush * y_dist / r_y
						center_x = width * 0.6 * y_ratio^5 + coords.pos.x

						if y_dist < r_y then
							distance = math.sqrt((center_x - x)^2 + (coords.pos.z - z)^2)
						else
							distance = math.sqrt((center_x - x)^2 + (y_dist - r_y)^2 + (coords.pos.z - z)^2)
						end

						if data[ivm] == c_air or data[ivm] == c_ignore or data[ivm] == c_snow then
							r = math.floor(wood_noise[index3d] * 100000)
							if distance < radius - 8 and y_dist < r_y - 8 and r % 34927 == 1 then
								for x1 = -2,2 do
									for y1 = -3,3 do
										for z1 = -2,2 do
											dist1 = math.floor(math.sqrt(x1^2 + (y1/2)^2 + z1^2))
											if dist1 < 2 and x + x1 >= minp.x and x + x1 <= maxp.x and y + y1 >= minp.y and y + y1 <= maxp.y and z + z1 >= minp.z and z + z1 <= maxp.z then
												ivm1 = a:index(x + x1, y + y1, z + z1)
												if x1 == 0 and y1 == 0 and z1 == 0 then
													data[ivm1] = c_petrified_animals[math.random(#c_petrified_animals)]
												else
													data[ivm1] = c_amber
												end
											end
										end
									end
								end
							elseif distance < radius - 1 and y_dist < r_y - 2 and r % 537 == 1 then
								data[ivm] = c_sap
							elseif distance < radius - 1 and y_dist < r_y - 2 then
								if math.floor(distance) % 20 == 10 and wood_noise[index3d] < 0.3 then
									data[ivm] = c_petrified_wood
								elseif wood_noise[index3d] < -0.98 then
									data[ivm] = c_wwater
								elseif wood_noise[index3d] < -0.8 then
									data[ivm] = c_air
								elseif wood_noise[index3d] < -0.05 then
									data[ivm] = c_wood
								elseif wood_noise[index3d] < 0.05 then
									data[ivm] = c_air
								elseif wood_noise[index3d] < 0.6 then
									data[ivm] = c_wood
								elseif wood_noise[index3d] < 0.97 then
									data[ivm] = c_ironwood
								else
									data[ivm] = c_diamondwood
								end
								write = true
							elseif distance < radius and y_dist < r_y then
								data[ivm] = c_bark
								write = true
							elseif (y_dist < r_y and distance < radius + 3) or (distance / bush < end_radius) and x - 2 >= minp.x and x + 2 <= maxp.x and y - 2 >= minp.y and y + 2 <= maxp.y and z - 2 >= minp.z and z + 2 <= maxp.z then
								pos = {x = x, y = y, z = z}
								leaf_type = math.floor(wood_noise[index3d] * 10 % 5) + 1

								if y_dist < r_y then
									chance = 37 / (y_dist / r_y) ^ 2
								else
									chance = 37
								end

								if math.floor(wood_noise[index3d] * 1000 % chance) == 1 then
									if data[ivm] == c_air or data[ivm] == c_snow then
										data[ivm] = c_bark
										write = true
										for x1 = -leaf_radius,leaf_radius do
											for y1 = -leaf_radius,leaf_radius do
												for z1 = -leaf_radius,leaf_radius do
													dist1 = math.sqrt(x1^2 + y1^2 + z1^2)
													if dist1 <= leaf_radius and x + x1 >= minp.x and x + x1 <= maxp.x and y + y1 >= minp.y and y + y1 <= maxp.y and z + z1 >= minp.z and z + z1 <= maxp.z and math.random(9) ~= 1 then
														ivm1 = a:index(x + x1, y + y1, z + z1)
														if data[ivm1] == c_air then
															data[ivm1] = c_leaves[leaf_type]
														end
													end
												end
											end
										end
									end
								end
							end
						end
					end
				end
			end
		end
	end

	if write then
		vm:set_data(data)
		vm:set_lighting({day = 0, night = 0})
		vm:calc_lighting()
		vm:update_liquids()
		vm:write_to_map()
	end

	local v
	for i = 1,12 do
		v = integral.get_ground_root_coords(minp.x, minp.y, minp.z, i, coords)
		if v.x >= minp.x and v.y >= minp.y and v.z >= minp.z and v.x <= maxp.x and v.y <= maxp.y and v.z <= maxp.z then
			minetest.place_schematic({x=v.x-2,y=v.y-1,z=v.z-2}, integral.integral_root_schematic, nil, true)
		end

		v = integral.get_tree_root_coords(minp.x, minp.y, minp.z, i, coords)
		if v.x >= minp.x and v.y >= minp.y and v.z >= minp.z and v.x <= maxp.x and v.y <= maxp.y and v.z <= maxp.z then
			minetest.place_schematic({x=v.x-2,y=v.y-1,z=v.z-2}, integral.integral_root_schematic, nil, true)
		end
	end
end
