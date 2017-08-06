-- Underworlds undergen.lua
-- Copyright Duane Robertson (duane@duanerobertson.com), 2017
-- Distributed under the LGPLv2.1 (https://www.gnu.org/licenses/old-licenses/lgpl-2.1.en.html)


underworlds_mod.cave_width = 0.05  -- figurative width
local max_depth = 31000


local terrain_noise = {offset = 15, scale = 10, seed = 3721, spread = {x = 40, y = 40, z = 40}, octaves = 3, persist = 1, lacunarity = 2}
local earth_terrain_noise = {offset = 200, scale = 100, seed = 3721, spread = {x = 1000, y = 1000, z = 1000}, octaves = 4, persist = 1, lacunarity = 2}
local humidity_noise = {offset = 0, scale = 100, seed = 666, spread = {x = 1000, y = 1000, z = 1000}, octaves = 2, persist = 1, lacunarity = 2}
local temperature_noise = {offset = -50, scale = 100, seed = -666, spread = {x = 1000, y = 1000, z = 1000}, octaves = 2, persist = 1, lacunarity = 2}
local tree_noise = {offset = 0, scale = 10, seed = 888, spread = {x = 600, y = 600, z = 600}, octaves = 3, persist = 1, lacunarity = 2}
local beach_noise = {offset = 0, scale = 10, seed = -888, spread = {x = 600, y = 600, z = 600}, octaves = 2, persist = 1, lacunarity = 2}
local terrain_map
local earth_terrain_map
local humidity_map
local temperature_map
local tree_map
local beach_map
local terrain = {}
local humidity = {}
local temperature = {}
local climate = {}
local trees = {}
local beaches = {}
generate_trees = {}

underworlds_mod.undergen = function(vm, minp, maxp, data, p2data, area, node, underzone)
	if not (minp and maxp and data and area and node and type(data) == 'table' and underzone and underworlds_mod.underzones) then
		return
	end

	local csize = vector.add(vector.subtract(maxp, minp), 1)
	local map_max = {x = csize.x, y = csize.y + 2, z = csize.z}
	local map_min = {x = minp.x, y = minp.y - 1, z = minp.z}

  if not terrain_map then
    terrain_map = minetest.get_perlin_map(terrain_noise, {x=csize.x, y=csize.z})

    if not terrain_map then
      return
    end
  end

  if not earth_terrain_map then
    earth_terrain_map = minetest.get_perlin_map(earth_terrain_noise, {x=csize.x, y=csize.z})
    humidity_map = minetest.get_perlin_map(humidity_noise, {x=csize.x, y=csize.z})
    temperature_map = minetest.get_perlin_map(temperature_noise, {x=csize.x, y=csize.z})
    tree_map = minetest.get_perlin_map(tree_noise, {x=csize.x, y=csize.z})
    beach_map = minetest.get_perlin_map(beach_noise, {x=csize.x, y=csize.z})

    if not earth_terrain_map then
      return
    end
  end

	if underzone.name == "Gaia" or underzone.name == "Paradisium" then
		terrain = earth_terrain_map:get2dMap_flat({x=minp.x, y=minp.z}, terrain)
		humidity = humidity_map:get2dMap_flat({x=minp.x, y=minp.z}, humidity)
		temperature = temperature_map:get2dMap_flat({x=minp.x, y=minp.z}, temperature)
		trees = tree_map:get2dMap_flat({x=minp.x, y=minp.z}, trees)
		beaches = beach_map:get2dMap_flat({x=minp.x, y=minp.z}, beaches)
	else
		terrain = terrain_map:get2dMap_flat({x=minp.x, y=minp.z}, terrain)
	end

	if not terrain then
		return
	end

	local math_random = math.random
	local dis_map = {}
	if underzone and underzone.city then
		for i = 0, 10, 2 do
			dis_map[i] = {}
			for j = 0, 10, 2 do
				dis_map[i][j] = math_random(6)
				if dis_map[i][j] == 6 then
					dis_map[i][j] = 5 + math_random(10)
				end
			end
		end
	end

	local write = false

	local index = 0
	local cindex = 0
	local index3d = 0
	local cave_width = underworlds_mod.cave_width
	local styx_sea_level = underworlds_mod.underzones['Styx'].sealevel

--	for x = minp.x, maxp.x do
--		for z = minp.z, maxp.z do
--			cindex = index + 1
--		end
--	end

	for z = minp.z, maxp.z do
		for x = minp.x, maxp.x do
			index = index + 1

			index3d = (z - minp.z) * (csize.y + 2) * csize.x + (x - minp.x) + 1
			local ivm = area:index(x, minp.y-1, z)



			local column = 0
      if terrain[index] < 30 then
        column = 1
      elseif terrain[index] < 35 then
        column = 2
      end

			for y = minp.y-1, maxp.y+1 do
				if underzone.regular_columns and (x - minp.x) < 8 and (z - minp.z) < 8 then
					data[ivm] = node[underzone.column_node]
					write = true
				elseif underzone.column_node and not underzone.regular_columns and column == 2 then
					if underzone.column_node_rare and math.random(70) == 1 then
						data[ivm] = node[underzone.column_node_rare]
					else
						data[ivm] = node[underzone.column_node]
					end
					write = true
				elseif (y < underzone.ceiling - (underzone.vary and terrain[index] or 0) and y > underzone.floor + (underzone.vary and terrain[index] or 0)) then
					if underzone.sealevel and y <= underzone.sealevel then
						data[ivm] = node["default:water_source"]
          elseif underzone.lake and y < underzone.floor + underzone.lake_level then
            data[ivm] = node[underzone.lake]
					else
						data[ivm] = node["air"]
					end
					write = true
				elseif y < underzone.ceiling + 10 - (underzone.vary and terrain[index] or 0) and (not underworlds_mod.integration or data[ivm] ~= node['air']) then
          data[ivm] = node["default:stone"]
				elseif y > underzone.floor - 10 + (underzone.vary and terrain[index] or 0) and (not underworlds_mod.integration or data[ivm] ~= node['air']) then
          data[ivm] = node["default:stone"]
				end

				ivm = ivm + area.ystride
				index3d = index3d + csize.x
			end
		end
	end


  local math_floor = math.floor

	for z = minp.z, maxp.z do
		for x = minp.x, maxp.x do
			cindex = cindex + 1
			index = index + 1
			index3d = (z - minp.z) * (csize.y + 2) * csize.x + (x - minp.x) + 1
			local ivm = area:index(x, minp.y-1, z)

			--local column = 0
      --if terrain[index] < 30 then
      --  column = 1
      --elseif terrain[index] < 35 then
      --  column = 2
      --end

			for y = minp.y-1, maxp.y+1 do
        local node_below
        if y > minp.y then
          node_below = data[ivm - area.ystride]
        end
        local node_above = data[ivm + area.ystride]

        for deco_non_loop = 1, 1 do
          if data[ivm] == node["default:stone"] then
            if node_above == node["air"] and underzone.dirt and math_random(underzone.dirt_chance) == 1 then
              data[ivm] = node[underzone.dirt]
              write = true
              break
            end

            local air_above = false
            for i = 1, underzone.stone_depth do
              if data[ivm + area.ystride * i] == node["air"] or (y < styx_sea_level and data[ivm + area.ystride * i] == node["default:water_source"]) then
                air_above = true
              end
            end

            if air_above then
			if underzone.name == "Gaia" then
				local temp = temperature[cindex] - (terrain[cindex] / 60)
				local pos = {}
				pos.x = x
				pos.y = y - 3
				pos.z = z
				if y > -19890 then


					if humidity[cindex] < 25 then -- desert
						if temp < -25 then -- iceworld
							data[ivm] = node["default:ice"]
							for i = 1, math.random(1,3) do
								data[ivm - area.ystride * i] = node["default:ice"]
							end
						elseif temp >= -25 and temp < 0 then -- snow
							if y > -19864 then
								if y < -19860 and beaches[cindex] <= 8 then
									data[ivm] = node["default:ice"]
									for i = 1, math.random(1,3) do
										data[ivm - area.ystride * i] = node["default:ice"]
									end
								else
									data[ivm] = node["default:snowblock"]
									for i = 1, math.random(1,3) do
										data[ivm - area.ystride * i] = node["default:snowblock"]
									end
								end
							else
								if beaches[cindex] <= 8 then
									data[ivm] = node["default:ice"]
									for i = 1, math.random(1,3) do
										data[ivm - area.ystride * i] = node["default:ice"]
									end
								end
							end
						elseif temp >= 0 and temp < 25 then -- desert
							data[ivm] = node["default:sand"]
							for i = 1, math.random(1,3) do
								data[ivm - area.ystride * i] = node["default:sand"]
							end
						elseif temp >= 25 then -- desert
							data[ivm] = node["default:silver_sand"]
							for i = 1, math.random(1,3) do
								data[ivm - area.ystride * i] = node["default:silver_sand"]
							end
						end


					elseif humidity[cindex] >= 25 and humidity[cindex] < 50 then -- tundra
						if temp < -25 then -- iceworld
							if y > -19864 then
								if y < -19860 and beaches[cindex] <= 8 then
									data[ivm] = node["default:ice"]
									for i = 1, math.random(1,3) do
										data[ivm - area.ystride * i] = node["default:ice"]
									end
								else
									data[ivm] = node["default:snowblock"]
									for i = 1, math.random(1,3) do
										data[ivm - area.ystride * i] = node["default:snowblock"]
									end
								end
							else
								if beaches[cindex] <= 8 then
									data[ivm] = node["default:ice"]
									for i = 1, math.random(1,3) do
										data[ivm - area.ystride * i] = node["default:ice"]
									end
								end
							end
						elseif temp >= -25 and temp < 0 then -- snow
							if y > -19864 then
								if y < -19860 and beaches[cindex] <= 8 then
									data[ivm] = node["default:gravel"]
									for i = 1, math.random(1,3) do
										data[ivm - area.ystride * i] = node["default:gravel"]
									end
								else
									data[ivm] = node["default:snowblock"]
									for i = 1, math.random(1,3) do
										data[ivm - area.ystride * i] = node["default:snowblock"]
									end
								end
							else
								if beaches[cindex] <= 8 then
									data[ivm] = node["default:gravel"]
									for i = 1, math.random(1,3) do
										data[ivm - area.ystride * i] = node["default:gravel"]
									end
								end
							end
						elseif temp >= 0 and temp < 25 then -- tundra
							if y > -19864 then
								if y < -19860 and beaches[cindex] <= 8 then
									data[ivm] = node["default:sand"]
									for i = 1, math.random(1,3) do
										data[ivm - area.ystride * i] = node["default:sand"]
									end
								else
									data[ivm] = node["default:dirt_with_dry_grass"]
									for i = 1, math.random(1,3) do
										data[ivm - area.ystride * i] = node["default:dirt"]
									end
									if y > -19863 and trees[cindex] > 5 and math.random(1, 500) == 1 then
										for i = 1, 5 do
											if data[ivm - area.ystride * i] ~= node["air"] then
												pos.y = pos.y - i
												table.insert(generate_trees, {pos, minetest.get_modpath("default").."/schematics/acacia_tree.mts"})
												break
											end
										end
									end
								end
							else
								if beaches[cindex] <= 8 then
									data[ivm] = node["default:sand"]
									for i = 1, math.random(1,3) do
										data[ivm - area.ystride * i] = node["default:sand"]
									end
								else
									data[ivm] = node["default:dirt"]
									for i = 1, math.random(1,3) do
										data[ivm - area.ystride * i] = node["default:dirt"]
									end
								end
							end
						elseif temp >= 25 then -- desert
							data[ivm] = node["default:desert_sand"]
							for i = 1, math.random(1,3) do
								data[ivm - area.ystride * i] = node["default:desert_sand"]
							end
						end


					elseif humidity[cindex] >= 50 and humidity[cindex] < 75 then -- temperate
						if temp < -25 then -- iceworld
							if y > -19864 then
								if y < -19860 and beaches[cindex] <= 8 then
									data[ivm] = node["default:gravel"]
									for i = 1, math.random(1,3) do
										data[ivm - area.ystride * i] = node["default:gravel"]
									end
								else
									data[ivm] = node["default:snowblock"]
									for i = 1, math.random(1,3) do
										data[ivm - area.ystride * i] = node["default:snowblock"]
									end
								end
							else
								if beaches[cindex] <= 8 then
									data[ivm] = node["default:gravel"]
									for i = 1, math.random(1,3) do
										data[ivm - area.ystride * i] = node["default:gravel"]
									end
								end
							end
						elseif temp >= -25 and temp < 0 then -- taiga
							if y > -19864 then
								if y < -19860 and beaches[cindex] <= 8 then
									data[ivm] = node["default:sand"]
									for i = 1, math.random(1,3) do
										data[ivm - area.ystride * i] = node["default:sand"]
									end
								else
									data[ivm] = node["default:dirt_with_snow"]
									for i = 1, math.random(1,3) do
										data[ivm - area.ystride * i] = node["default:dirt"]
									end
									if y > -19863 and trees[cindex] > 5 and math.random(1, 20) == 1 then
										table.insert(generate_trees, {pos, minetest.get_modpath("default").."/schematics/pine_tree.mts"})
									end
								end
							else
								if beaches[cindex] <= 8 then
									data[ivm] = node["default:sand"]
									for i = 1, math.random(1,3) do
										data[ivm - area.ystride * i] = node["default:sand"]
									end
								else
									data[ivm] = node["default:dirt"]
									for i = 1, math.random(1,3) do
										data[ivm - area.ystride * i] = node["default:dirt"]
									end
								end
							end
						elseif temp >= 0 and temp < 25 then -- temperate
							if y > -19864 then
								if y < -19860 and beaches[cindex] <= 8 then
									data[ivm] = node["default:sand"]
									for i = 1, math.random(1,3) do
										data[ivm - area.ystride * i] = node["default:sand"]
									end
								else
									data[ivm] = node["default:dirt_with_grass"]
									for i = 1, math.random(1,3) do
										data[ivm - area.ystride * i] = node["default:dirt"]
									end
									if y > -19863 and trees[cindex] > 5 and math.random(1, 20) == 1 then
										if math.random(1, 40) == 1 then
											for i = 1, 5 do
												if data[ivm - area.ystride * i] ~= node["air"] then
													pos.y = pos.y - i
													table.insert(generate_trees, {pos, minetest.get_modpath("default").."/schematics/aspen_tree.mts"})
													break
												end
											end
										else
											for i = 1, 5 do
												if data[ivm - area.ystride * i] ~= node["air"] then
													pos.y = pos.y - i
													table.insert(generate_trees, {pos, minetest.get_modpath("default").."/schematics/apple_tree.mts"})
													break
												end
											end
										end
									end
								end
							else
								if beaches[cindex] <= 8 then
									data[ivm] = node["default:sand"]
									for i = 1, math.random(1,3) do
										data[ivm - area.ystride * i] = node["default:sand"]
									end
								else
									data[ivm] = node["default:dirt"]
									for i = 1, math.random(1,3) do
										data[ivm - area.ystride * i] = node["default:dirt"]
									end
								end
							end
						elseif temp >= 25 then -- temperate
							if y > -19864 then
								if y < -19860 and beaches[cindex] <= 8 then
									data[ivm] = node["default:sand"]
									for i = 1, math.random(1,3) do
										data[ivm - area.ystride * i] = node["default:sand"]
									end
								else
									data[ivm] = node["default:dirt_with_grass"]
									for i = 1, math.random(1,3) do
										data[ivm - area.ystride * i] = node["default:dirt"]
									end
									if y > -19863 and trees[cindex] > 5 and math.random(1, 20) == 1 then
										if math.random(1, 40) == 1 then
											for i = 1, 5 do
												if data[ivm - area.ystride * i] ~= node["air"] then
													pos.y = pos.y - i
													table.insert(generate_trees, {pos, minetest.get_modpath("default").."/schematics/aspen_tree.mts"})
													break
												end
											end
										else
											for i = 1, 5 do
												if data[ivm - area.ystride * i] ~= node["air"] then
													pos.y = pos.y - i
													table.insert(generate_trees, {pos, minetest.get_modpath("default").."/schematics/apple_tree.mts"})
													break
												end
											end
										end
									end
								end
							else
								if beaches[cindex] <= 8 then
									data[ivm] = node["default:sand"]
									for i = 1, math.random(1,3) do
										data[ivm - area.ystride * i] = node["default:sand"]
									end
								else
									data[ivm] = node["default:dirt"]
									for i = 1, math.random(1,3) do
										data[ivm - area.ystride * i] = node["default:dirt"]
									end
								end
							end
						end


					else -- tropical
						if temp < -25 then -- iceworld
							if y > -19864 then
								if y < -19860 and beaches[cindex] <= 8 then
									data[ivm] = node["default:gravel"]
									for i = 1, math.random(1,3) do
										data[ivm - area.ystride * i] = node["default:gravel"]
									end
								else
									data[ivm] = node["default:snowblock"]
									for i = 1, math.random(1,3) do
										data[ivm - area.ystride * i] = node["default:snowblock"]
									end
								end
							else
								if beaches[cindex] <= 8 then
									data[ivm] = node["default:gravel"]
									for i = 1, math.random(1,3) do
										data[ivm - area.ystride * i] = node["default:gravel"]
									end
								end
							end
						elseif temp >= -25 and temp < 0 then -- snow
							if y > -19864 then
								if y < -19860 and beaches[cindex] <= 8 then
									data[ivm] = node["default:gravel"]
									for i = 1, math.random(1,3) do
										data[ivm - area.ystride * i] = node["default:gravel"]
									end
								else
									data[ivm] = node["default:dirt_with_snow"]
									for i = 1, math.random(1,3) do
										data[ivm - area.ystride * i] = node["default:dirt"]
									end
									if y > -19863 and trees[cindex] > 5 and math.random(1, 20) == 1 then
										table.insert(generate_trees, {pos, minetest.get_modpath("default").."/schematics/pine_tree.mts"})
									end
								end
							else
								if beaches[cindex] <= 8 then
									data[ivm] = node["default:gravel"]
									for i = 1, math.random(1,3) do
										data[ivm - area.ystride * i] = node["default:gravel"]
									end
								else
									data[ivm] = node["default:dirt"]
									for i = 1, math.random(1,3) do
										data[ivm - area.ystride * i] = node["default:dirt"]
									end
								end
							end
						elseif temp >= 0 and temp < 25 then -- temperate
							if y > -19864 then
								if y < -19860 and beaches[cindex] <= 8 then
									data[ivm] = node["default:sand"]
									for i = 1, math.random(1,3) do
										data[ivm - area.ystride * i] = node["default:silver_sand"]
									end
								else
									data[ivm] = node["default:dirt_with_grass"]
									for i = 1, math.random(1,3) do
										data[ivm - area.ystride * i] = node["default:dirt"]
									end
									if y > -19863 and trees[cindex] > 5 and math.random(1, 20) == 1 then
										if math.random(1, 40) == 1 then
											for i = 1, 5 do
												if data[ivm - area.ystride * i] ~= node["air"] then
													pos.y = pos.y - i
													table.insert(generate_trees, {pos, minetest.get_modpath("default").."/schematics/aspen_tree.mts"})
													break
												end
											end
										else
											for i = 1, 5 do
												if data[ivm - area.ystride * i] ~= node["air"] then
													pos.y = pos.y - i
													table.insert(generate_trees, {pos, minetest.get_modpath("default").."/schematics/apple_tree.mts"})
													break
												end
											end
										end
									end
								end
							else
								if beaches[cindex] <= 8 then
									data[ivm] = node["default:sand"]
									for i = 1, math.random(1,3) do
										data[ivm - area.ystride * i] = node["default:sand"]
									end
								else
									data[ivm] = node["default:dirt"]
									for i = 1, math.random(1,3) do
										data[ivm - area.ystride * i] = node["default:dirt"]
									end
								end
							end


						elseif temp >= 25 then -- jungle
							if y > -19864 then
								if y < -19860 and beaches[cindex] <= 8 then
									data[ivm] = node["default:desert_sand"]
									for i = 1, math.random(1,3) do
										data[ivm - area.ystride * i] = node["default:desert_sand"]
									end
								else
									data[ivm] = node["default:dirt_with_rainforest_litter"]
									for i = 1, math.random(0,4) do
										data[ivm - area.ystride * i] = node["default:dirt"]
									end
									if y > -19863 and math.random(1, 10) == 1 then
										for i = 1, 5 do
											if data[ivm - area.ystride * i] ~= node["air"] then
												pos.y = pos.y - i
												table.insert(generate_trees, {pos, minetest.get_modpath("default").."/schematics/jungle_tree.mts"})
												break
											end
										end
									end
								end
							else
								if beaches[cindex] <= 8 then
									data[ivm] = node["default:desert_sand"]
									for i = 1, math.random(1,3) do
										data[ivm - area.ystride * i] = node["default:desert_sand"]
									end
								else
									data[ivm] = node["default:dirt"]
									for i = 1, math.random(0,4) do
										data[ivm - area.ystride * i] = node["default:dirt"]
									end
								end
							end
						end
					end
					write = true
					break
				end

              elseif underzone.deco and math_random(underzone.deco_chance) == 1 then
                data[ivm] = node[underzone.deco]
                write = true
                break
              elseif underzone.special_floor_nodes then
                local sn_found = false
                for sn_index = 1, #underzone.special_floor_nodes do
                  if (not sn_found and math_random(underzone.special_floor_nodes_chances[sn_index]) == 1) then
                    data[ivm] = node[underzone.special_floor_nodes[sn_index]]
                    sn_found = true
                  end
                end
                if not sn_found then
                  data[ivm] = node[underzone.floor_node]
                end
			    write = true
			    break
			  else
                data[ivm] = node[underzone.floor_node]
                write = true
                break
              end
            end

            local air_below = false
            for i = 1, underzone.stone_depth do
              if data[ivm - area.ystride * i] == node["air"] then
                air_below = true
              end
            end

            if not air_above and underzone.floor_node == "default:sand" then
              data[ivm] = node["default:sandstone"]
              write = true
              break
            end

            if air_below then
              if underzone.deco and math_random(underzone.deco_chance) == 1 then
                data[ivm] = node[underzone.deco]
                write = true
                break
              elseif underzone.special_ceiling_nodes then
                local sn_found = false
                for sn_index = 1, #underzone.special_ceiling_nodes do
                  if (not sn_found and math_random(underzone.special_ceiling_nodes_chances[sn_index]) == 1) then
                    data[ivm] = node[underzone.special_ceiling_nodes[sn_index]]
                    sn_found = true
                  end
                end
                if not sn_found then
                  data[ivm] = node[underzone.ceiling_node]
                end
			    write = true
			    break
			  else
                data[ivm] = node[underzone.ceiling_node]
                write = true
                break
              end
            end
          end

          -- smallest city generator ever
          if underzone.city and data[ivm] == node['air'] and math_floor((x - minp.x) / 8) % 2 == 0 and math_floor((z - minp.z) / 8) % 2 == 0 and y - underzone.floor < dis_map[math_floor((x - minp.x) / 8)][math_floor((z - minp.z) / 8)] * 4 + 1 and y - underzone.floor >= 0 then
            local dx = (x - minp.x) % 16
            local dy = y - underzone.floor + 1
            local dz = (z - minp.z) % 16
            if dx == 1 and dz == 1 then
              data[ivm] = node["default:ladder_steel"]
              p2data[ivm] = 3
              --write_p2 = true
            elseif ((dx == 0 or dx == 7) and (dz % 3 ~= 2 or dy % 4 == 0)) or ((dz == 0 or dz == 7) and (dx % 3 ~= 2 or dy % 4 == 0)) then
              data[ivm] = node["underworlds:hot_iron"]
            elseif dy % 4 == 0 then
              data[ivm] = node["underworlds:hot_brass"]
            end
            write = true
            break
          end

          if data[ivm] == node["air"] and y < maxp.y then
            -- hanging down
            --  stone hasn't yet been changed
            if underzone.stalactite and node_above == node["default:stone"] and math_random(underzone.stalactite_chance) == 1 then
              data[ivm] = node[underzone.stalactite]
              write = true
              break
            end

            -- fluids
            if y > minp.y and underzone.fluid and node_below == node[underzone.floor_node] and math_random(underzone.fluid_chance) == 1 then
              data[ivm] = node[underzone.fluid]
              write = true
              break

              -- standing up
            elseif node_below == node[underzone.floor_node] and underzone.stalagmite and math_random(underzone.stalagmite_chance) == 1 then
              if type(underzone.stalagmite) == 'table' then
                data[ivm] = node[underzone.stalagmite[math_random(#underzone.stalagmite)]]
              else
                data[ivm] = node[underzone.stalagmite]
              end
              write = true
              break

              -- vegetation
            elseif node_below == node["underworlds:polluted_dirt"] then
              if math_random(10) == 1 then
                data[ivm] = node["default:dry_shrub"]
                write = true
                break
              elseif math_random(50) == 1 then
                local air_count = 0
                local pos = {}
                local j
                for i = 1, 9 do
                  j = ivm + area.ystride * i
                  if j <= #data and data[j] == node["air"] then
                    air_count = air_count + 1
                  end
                end
                if air_count > 6 then
                  pos.x = x
                  pos.y = y
                  pos.z = z
                  underworlds_mod.place_schematic(minp, maxp, data, p2data, area, node, pos, underworlds_mod.schematics['decaying_tree'], true)
                end
              end
            elseif node_below == node["underworlds:hot_cobble"] then
              if underzone.name == "Nessus" then
                if math_random(25) == 1 then
                  data[ivm] = node["fire:permanent_flame"]
                  write = true
                  break
				end
              end
            end
          end
        end

        ivm = ivm + area.ystride
        index3d = index3d + csize.x
      end
    end
  end

  return write
end
