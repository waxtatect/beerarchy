-- This version of the travelnet box allows to move up or down only.
-- The network name is determined automaticly from the position (x/z coordinates).
-- Author: Sokomine
local F, S = travelnet.F, travelnet.S

travelnet.show_nearest_elevator = function(pos, owner_name, param2)
	if (not pos) or (not pos.x) or (not pos.z) or (not owner_name) then
		return
	end

	if not travelnet.targets[owner_name] then
		minetest.chat_send_player(owner_name,
			S("Congratulations! This is your first elevator. You can build an elevator network by placing further elevators somewhere above or below this one. Just make sure that the x and z coordinate are the same."
		))
		return
	end

	local network_name = tostring(pos.x)..','..tostring(pos.z)
	-- will this be an elevator that will be added to an existing network?
	if travelnet.targets[owner_name][network_name]
		-- does the network have any members at all?
		and next(travelnet.targets[owner_name][network_name], nil)
	then
		minetest.chat_send_player(owner_name,
			S("This elevator will automatically connect to the other elevators you have placed at different heights. Just enter a station name and click on \"store\" to set it up. Or just punch it to set the height as station name."
		))
		return
	end

	local nearest_name = ""
	local nearest_dist = 100000000
	local nearest_dist_x = 0
	local nearest_dist_z = 0
	for network_name, data in pairs(travelnet.targets[owner_name]) do
		local station_name = next(data, nil)
		if station_name and data[station_name]["nr"] and data[station_name].pos then
			local station_pos = data[station_name].pos
			local dist = math.ceil(math.sqrt(
					  (station_pos.x - pos.x) * (station_pos.x - pos.x)
					+ (station_pos.z - pos.z) * (station_pos.z - pos.z)))
			-- find the nearest one, store network_name and (minimal) distance
			if dist < nearest_dist then
				nearest_dist = dist
				nearest_dist_x = station_pos.x - pos.x
				nearest_dist_z = station_pos.z - pos.z
				nearest_name = network_name
			end
		end
	end
	if nearest_name ~= "" then
		local d1, d2, t1, t2 = nil, nil, "", ""
		-- in front of/behind
		if param2 == 0 and nearest_dist_z >= 0 or param2==2 and nearest_dist_z <= 0 then
			d1, t1 = math.abs(nearest_dist_z), "m behind this elevator and"
		elseif param2 == 1 and nearest_dist_x >= 0 or param2 == 3 and nearest_dist_x <= 0 then
			d1, t1 = math.abs(nearest_dist_x), "m behind this elevator and"
		elseif param2 == 0 and nearest_dist_z < 0 or param2 == 2 and nearest_dist_z > 0 then
			d1, t1 = math.abs(nearest_dist_z), "m in front of this elevator and"
		elseif param2 == 1 and nearest_dist_x < 0 or param2 == 3 and nearest_dist_x > 0 then
			d1, t1 = math.abs(nearest_dist_x), "m in front of this elevator and"
		else t1 = "ERROR"
		end

		-- right/left
		if param2 == 0 and nearest_dist_x < 0 or param2 == 2 and nearest_dist_x > 0 then
			d2, t2 = math.abs(nearest_dist_x), "m to the left"
		elseif param2 == 1 and nearest_dist_z >= 0 or param2 == 3 and nearest_dist_z <= 0 then
			d2, t2 = math.abs(nearest_dist_z), "m to the left"
		elseif param2 == 0 and nearest_dist_x >= 0 or param2 == 2 and nearest_dist_x <= 0 then
			d2, t2 = math.abs(nearest_dist_x), "m to the right"
		elseif param2 == 1 and nearest_dist_z < 0 or param2 == 3 and nearest_dist_z > 0 then
			d2, t2 = math.abs(nearest_dist_z), "m to the right"
		else t2 = "ERROR"
		end

		minetest.chat_send_player(owner_name,
			S("Your nearest elevator network is located @1 @2, located at x=@3, z=@4. This elevator here will start a new shaft/network.",
				S("@1 " .. t1, tostring(d1 or "")), S("@1 " .. t2, tostring(d2 or "")), tostring(pos.x + nearest_dist_x), tostring(pos.z + nearest_dist_z)
		))
	else
		minetest.chat_send_player(owner_name,
			S("This is your first elevator. It differs from travelnet networks by only allowing movement in vertical direction (up or down). All further elevators which you will place at the same x,z coordinates at different heights will be able to connect to this elevator."
		))
	end
end

minetest.register_node("travelnet:elevator", {
	description = S("Elevator"),
	drawtype = "mesh",
	mesh = "travelnet_elevator.obj",
	sunlight_propagates = true,
	paramtype = 'light',
	paramtype2 = "facedir",
	wield_scale = {x=0.6, y=0.6, z=0.6},
	selection_box = {
		type = "fixed",
		fixed = {-0.5, -0.5, -0.5, 0.5, 1.5, 0.5}
	},
	collision_box = {
		type = "fixed",
		fixed = {
			{ 0.48, -0.5,-0.5,   0.5,  0.5, 0.5},
			{-0.5 , -0.5, 0.48,  0.48, 0.5, 0.5},
			{-0.5,  -0.5,-0.5 , -0.48, 0.5, 0.5},
			--groundplate to stand on
			{-0.5, -0.5, -0.5, 0.5, -0.48, 0.5}
		}
	},
	tiles = travelnet.tiles_elevator,
	inventory_image = travelnet.elevator_inventory_image,
	groups = {}, -- cracky=1, choppy=1, snappy=1
	light_source = 10,

	after_place_node = function(pos, placer, itemstack)
		local meta = minetest.get_meta(pos)
		local name = placer:get_player_name()
		meta:set_string("infotext"		 , S("Elevator (unconfigured)"))
		meta:set_string("station_name"	 , "")
		meta:set_string("station_network", "")
		meta:set_string("owner"			 , name)
		-- request initial data
		meta:set_string("formspec",
			"size[12,10]"..
			"field[0.3,5.6;6,0.7;station_name;"..F(S("Name of this station:"))..";]"..
			-- "field[0.3,6.6;6,0.7;station_network;"..F(S("Assign to Network:"))"..;]"..
			-- "field[0.3,7.6;6,0.7;owner_name;"..F(S("(optional) owned by:"))"..;]"..
			"button_exit[6.3,6.2;1.7,0.7;station_set;"..F(S("Store")).."]"
		)

		local p = {x = pos.x, y = pos.y + 1, z = pos.z}
		local p2 = minetest.dir_to_facedir(placer:get_look_dir())
		minetest.add_node(p, {name="travelnet:elevator_top", paramtype2="facedir", param2=p2})
		travelnet.show_nearest_elevator(pos, name, p2)
	end,

	on_receive_fields = travelnet.on_receive_fields,

	on_punch = function(pos, node, puncher)
		travelnet.update_formspec(pos, puncher:get_player_name())
	end,

	can_dig = function(pos, player)
		return travelnet.can_dig(pos, player, 'elevator')
	end,

	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		travelnet.remove_box(pos, oldnode, oldmetadata, digger)
	end,

	-- TNT and overenthusiastic DMs do not destroy elevators either
	on_blast = function(pos, intensity) end,

	-- taken from VanessaEs homedecor fridge
	on_place = function(itemstack, placer, pointed_thing)
		local pos  = pointed_thing.above
		local node = minetest.get_node({x=pos.x, y=pos.y+1, z=pos.z})
		-- leftover elevator_top nodes can be removed by placing a new elevator underneath
		if node and node.name ~= "air" and node.name ~= 'travelnet:elevator_top' then
			minetest.chat_send_player(placer:get_player_name(), S("Not enough vertical space to place the elevator!"))
			return
		end
		return minetest.item_place(itemstack, placer, pointed_thing)
	end,

	on_destruct = function(pos)
		local p = {x = pos.x, y = pos.y + 1, z = pos.z}
		minetest.remove_node(p)
	end
})

minetest.register_alias("travelnet:elevator_top", "air")
--[[
if minetest.get_modpath("technic") then
	minetest.register_craft({
		output = "travelnet:elevator",
		recipe = {
			{"default:steel_ingot", "technic:motor"				, "default:steel_ingot"},
			{"default:steel_ingot", "technic:control_logic_unit", "default:steel_ingot"},
			{"default:steel_ingot", "moreores:copper_ingot"		, "default:steel_ingot"}
		}
	})
else
	minetest.register_craft({
		output = "travelnet:elevator",
		recipe = travelnet.elevator_recipe
	})
end
--]]