-- A random assortment of methods used in various places in this mod.

dofile( minetest.get_modpath( "digtron" ) .. "/util_item_place_node.lua" ) -- separated out to avoid potential for license complexity
dofile( minetest.get_modpath( "digtron" ) .. "/util_execute_cycle.lua" ) -- separated out simply for tidiness, there's some big code in there

-- Apparently node_sound_metal_defaults is a newer thing, I ran into games using an older version of the default mod without it.
if default.node_sound_metal_defaults ~= nil then
	digtron.metal_sounds = default.node_sound_metal_defaults()
else
	digtron.metal_sounds = default.node_sound_stone_defaults()
end


digtron.find_new_pos = function(pos, facing)
	-- finds the point one node "forward", based on facing
	local dir = minetest.facedir_to_dir(facing)
	return vector.add(pos, dir)
end

digtron.facedir_to_down_dir = function(facing)
	return (
		{[0]={x=0, y=-1, z=0},
		{x=0, y=0, z=-1},
		{x=0, y=0, z=1},
		{x=-1, y=0, z=0},
		{x=1, y=0, z=0},
		{x=0, y=1, z=0}})[math.floor(facing/4)]
end

digtron.find_new_pos_downward = function(pos, facing)
	return vector.add(pos, digtron.facedir_to_down_dir(facing))
end

digtron.mark_diggable = function(pos, nodes_dug)
	-- mark the node as dug, if the player provided would have been able to dig it.
	-- Don't *actually* dig the node yet, though, because if we dig a node with sand over it the sand will start falling
	-- and then destroy whatever node we place there subsequently (either by a builder head or by moving a digtron node)
	-- I don't like sand. It's coarse and rough and irritating and it gets everywhere. And it necessitates complicated dig routines.
	-- returns fuel cost and what will be dropped by digging these nodes.

	local target = minetest.get_node(pos)
	
	-- prevent digtrons from being marked for digging.
	if minetest.get_item_group(target.name, "digtron") ~= 0 or minetest.get_item_group(target.name, "digtron_protected") ~= 0 then
		return 0, {}
	end

	local targetdef = minetest.registered_nodes[target.name]
	if targetdef.can_dig == nil or targetdef.can_dig(pos, player) then 
		nodes_dug:set(pos.x, pos.y, pos.z, true)
		if target.name ~= "air" then
			local in_known_group = false
			local material_cost = 0
			
			if digtron.creative_mode ~= true then
				if minetest.get_item_group(target.name, "cracky") ~= 0 then
					in_known_group = true
					material_cost = math.max(material_cost, digtron.dig_cost_cracky)
				end
				if minetest.get_item_group(target.name, "crumbly") ~= 0 then
					in_known_group = true
					material_cost = math.max(material_cost, digtron.dig_cost_crumbly)
				end
				if minetest.get_item_group(target.name, "choppy") ~= 0 then
					in_known_group = true
					material_cost = math.max(material_cost, digtron.dig_cost_choppy)
				end
				if not in_known_group then
					material_cost = digtron.dig_cost_default
				end
			end
	
			return material_cost, minetest.get_node_drops(target.name, "")
		end
	end
	return 0, {}
end
	
digtron.can_build_to = function(pos, protected_nodes, dug_nodes)
	-- Returns whether a space is clear to have something put into it

	if protected_nodes:get(pos.x, pos.y, pos.z) then
		return false
	end

	-- tests if the location pointed to is clear to move something into
	local target = minetest.get_node(pos)
	if target.name == "air" or
	   dug_nodes:get(pos.x, pos.y, pos.z) == true or
	   minetest.registered_nodes[target.name].buildable_to == true
	   then
		return true
	end
	return false
end

digtron.can_move_to = function(pos, protected_nodes, dug_nodes)
	-- Same as can_build_to, but also checks if the current node is part of the digtron.
	-- this allows us to disregard obstructions that *will* move out of the way.
	if digtron.can_build_to(pos, protected_nodes, dug_nodes) == true or
	   minetest.get_item_group(minetest.get_node(pos).name, "digtron") ~= 0 then
		return true
	end
	return false
end


digtron.place_in_inventory = function(itemname, inventory_positions, fallback_pos)
	--tries placing the item in each inventory node in turn. If there's no room, drop it at fallback_pos
	local itemstack = ItemStack(itemname)
	for k, location in pairs(inventory_positions) do
		local inv = minetest.get_inventory({type="node", pos=location.pos})
		itemstack = inv:add_item("main", itemstack)
		if itemstack:is_empty() then
			return nil
		end
	end
	minetest.add_item(fallback_pos, itemstack)
end

digtron.place_in_specific_inventory = function(itemname, pos, inventory_positions, fallback_pos)
	--tries placing the item in a specific inventory. Other parameters are used as fallbacks on failure
	--Use this method for putting stuff back after testing and failed builds so that if the player
	--is trying to keep various inventories organized manually stuff will go back where it came from,
	--probably.
	local itemstack = ItemStack(itemname)
	local inv = minetest.get_inventory({type="node", pos=pos})
	local returned_stack = inv:add_item("main", itemstack)
	if not returned_stack:is_empty() then
		-- we weren't able to put the item back into that particular inventory for some reason.
		-- try putting it *anywhere.*
		digtron.place_in_inventory(returned_stack, inventory_positions, fallback_pos)
	end
end

digtron.take_from_inventory = function(itemname, inventory_positions)
	--tries to take an item from each inventory node in turn. Returns location of inventory item was taken from on success, nil on failure
	local itemstack = ItemStack(itemname)
	for k, location in pairs(inventory_positions) do
		local inv = minetest.get_inventory({type="node", pos=location.pos})
		local output = inv:remove_item("main", itemstack)
		if not output:is_empty() then
			return location.pos
		end
	end
	return nil
end

-- Used to determine which coordinate is being checked for periodicity. eg, if the digtron is moving in the z direction, then periodicity is checked for every n nodes in the z axis.
digtron.get_controlling_coordinate = function(pos, facedir)
	-- used for determining builder period and offset
	local dir = digtron.facedir_to_dir_map[facedir]
	if dir == 1 or dir == 3 then
		return "z"
	elseif dir == 2 or dir == 4 then
		return "x"
	else
		return "y"
	end
end

-- Searches fuel store inventories for burnable items and burns them until target is reached or surpassed (or there's nothing left to burn). Returns the total fuel value burned
-- if the "test" parameter is set to true, doesn't actually take anything out of inventories. We can get away with this sort of thing for fuel but not for builder inventory because there's just one
-- controller node burning stuff, not multiple build heads drawing from inventories in turn. Much simpler.
digtron.burn = function(fuelstore_positions, target, test)
	local current_burned = 0
	for k, location in pairs(fuelstore_positions) do
		if current_burned > target then
			break
		end
		local inv = minetest.get_inventory({type="node", pos=location.pos})
		local invlist = inv:get_list("fuel")
		for i, itemstack in pairs(invlist) do
			local fuel_per_item = minetest.get_craft_result({method="fuel", width=1, items={itemstack:peek_item(1)}}).time
			if fuel_per_item ~= 0 then
				local actual_burned = math.min(
						math.ceil((target - current_burned)/fuel_per_item ), -- burn this many, if we can.
						itemstack:get_count() -- how many we have at most.
					)
				if test ~= true then
					-- don't bother recording the items if we're just testing, nothing is actually being removed.
					itemstack:set_count(itemstack:get_count() - actual_burned)
				end
				current_burned = current_burned + actual_burned * fuel_per_item
			end
			if current_burned > target then
				break
			end
		end
		if test ~= true then
			-- only update the list if we're doing this for real.
			inv:set_list("fuel", invlist)
		end
	end
	return current_burned
end

digtron.remove_builder_item = function(pos)
	local objects = minetest.get_objects_inside_radius(pos, 0.5)
	if objects ~= nil then
		for _, obj in ipairs(objects) do
			if obj and obj:get_luaentity() and obj:get_luaentity().name == "digtron:builder_item" then
				obj:remove()
			end
		end
	end
end

digtron.update_builder_item = function(pos)
	digtron.remove_builder_item(pos)
	local inv = minetest.get_inventory({type="node", pos=pos})
	local item_stack = inv:get_stack("main", 1)
	if not item_stack:is_empty() then
		digtron.create_builder_item = item_stack:get_name()
		minetest.add_entity(pos,"digtron:builder_item")
	end
end

digtron.damage_creatures = function(player, pos, amount)
	local objects = minetest.get_objects_inside_radius(pos, 1.0)
	if objects ~= nil then
		for _, obj in ipairs(objects) do
			if obj then
				obj:punch(player, 1.0, {
					full_punch_interval = 1.0,
					damage_groups = {fleshy = amount},
					}, nil )
			end
		end
	end
end

digtron.is_soft_material = function(target)
	local target_node = minetest.get_node(target)
	if  minetest.get_item_group(target_node.name, "crumbly") ~= 0 or
		minetest.get_item_group(target_node.name, "choppy") ~= 0 or
		minetest.get_item_group(target_node.name, "snappy") ~= 0 or
		minetest.get_item_group(target_node.name, "oddly_breakable_by_hand") ~= 0 or
		minetest.get_item_group(target_node.name, "fleshy") ~= 0 then
		return true
	end
	return false
end