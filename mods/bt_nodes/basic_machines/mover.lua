------------------------------------------------------------------------------------------------------------------------------------
-- BASIC MACHINES MOD by rnd
-- mod with basic simple automatization for minetest. No background processing, just one abm with 5s timer (clock generator), no other lag causing background processing.
------------------------------------------------------------------------------------------------------------------------------------

-- *** SETTINGS *** --
basic_machines.timer = 5 -- main timestep
basic_machines.machines_minstep = 1 -- minimal allowed activation timestep, if faster machines overheat

basic_machines.max_range = 10 -- machines normal range of operation
basic_machines.machines_operations = 10 -- 1 coal will provide 10 mover basic operations (moving dirt 1 block distance)
basic_machines.machines_TTL = 16 -- time to live for signals, how many hops before signal dissipates
basic_machines.version = "01/17/2017a custom"
basic_machines.clockgen = 1 -- if 0 all background continuously running activity (clockgen/keypad) repeating is disabled

-- how hard it is to move blocks, default factor 1, note fuel cost is this multiplied by distance and divided by machine_operations..
basic_machines.hardness = {
	["bedrock2:bedrock"] = 999999,
	["default:acacia_tree"] = 2,
	["default:bush_leaves"] = 0.1,
	["default:cloud"] = 999999,
	["default:jungleleaves"] = 0.1,
	["default:jungletree"] = 2,
	["default:lava_source"] = 5950,
	["default:leaves"] = 0.1,
	["default:obsidian"] = 20,
	["default:pine_tree"] = 2,
	["default:stone"] = 4,
	["default:tree"] = 2,
	["default:water_source"] = 5950,
	["gloopblocks:pumice_cooled"] = 2
}
-- move machines for free
basic_machines.hardness["basic_machines:mover"] = 0
basic_machines.hardness["basic_machines:keypad"] = 0
basic_machines.hardness["basic_machines:distributor"] = 0
basic_machines.hardness["basic_machines:battery"] = 0
basic_machines.hardness["basic_machines:detector"] = 0
basic_machines.hardness["basic_machines:generator"] = 0
basic_machines.hardness["basic_machines:clockgen"] = 0
basic_machines.hardness["basic_machines:ball_spawner"] = 0
basic_machines.hardness["basic_machines:light_on"] = 0
basic_machines.hardness["basic_machines:light_off"] = 0

-- grief potential items need highest possible upgrades
basic_machines.hardness["boneworld:acid_source_active"] = 5950
basic_machines.hardness["darkage:mud"] = 5950

basic_machines.hardness["es:toxic_water_source"] = 5950; basic_machines.hardness["es:toxic_water_flowing"] = 5950
basic_machines.hardness["default:river_water_source"] = 5950

-- farming operations are much cheaper
basic_machines.hardness["farming:wheat_8"] = 1; basic_machines.hardness["farming:cotton_8"] = 1
basic_machines.hardness["farming:seed_wheat"] = 0.5; basic_machines.hardness["farming:seed_cotton"] = 0.5

-- digging mese crystals more expensive
basic_machines.hardness["mese_crystals:mese_crystal_ore1"] = 10
basic_machines.hardness["mese_crystals:mese_crystal_ore2"] = 10
basic_machines.hardness["mese_crystals:mese_crystal_ore3"] = 10
basic_machines.hardness["mese_crystals:mese_crystal_ore4"] = 10

-- define which nodes are dug up completely, like a tree
basic_machines.dig_up_table = {
	["default:acacia_tree"] = true,
	["default:aspen_tree"] = true,
	["default:cactus"] = true,
	["default:jungletree"] = true,
	["default:papyrus"] = true,
	["default:pine_tree"] = true,
	["default:tree"] = true
}

-- set up nodes for harvest when digging: [nodename] = {what remains after harvest, harvest result}
basic_machines.harvest_table = {
	["mese_crystals:mese_crystal_ore1"] = {"mese_crystals:mese_crystal_ore1", ""}, -- harvesting mese crystals
	["mese_crystals:mese_crystal_ore2"] = {"mese_crystals:mese_crystal_ore1", "default:mese_crystal 1"},
	["mese_crystals:mese_crystal_ore3"] = {"mese_crystals:mese_crystal_ore1", "default:mese_crystal 2"},
	["mese_crystals:mese_crystal_ore4"] = {"mese_crystals:mese_crystal_ore1", "default:mese_crystal 3"}
}

-- set up nodes for plant with reverse on and filter set (for example seeds -> plant) : [nodename] = plant_name
basic_machines.plant_table = { -- so it works with farming redo mod
	["farming:beans"] = "farming:beanpole_1",
	["farming:blueberries"] = "farming:blueberry_1",
	["farming:carrot"] = "farming:carrot_1",
	["farming:cocoa_beans"] = "farming:cocoa_1",
	["farming:coffee_beans"] = "farming:coffee_1",
	["farming:corn"] = "farming:corn_1",
	["farming:cucumber"] = "farming:cucumber_1",
	["farming:grapes"] = "farming:grapes_1",
	["farming:melon_slice"] = "farming:melon_1",
	["farming:pineapple_top"] = "farming:pineapple_1",
	["farming:potato"] = "farming:potato_1",
	["farming:pumpkin_slice"] = "farming:pumpkin_1",
	["farming:raspberries"] = "farming:raspberry_1",
	["farming:rhubarb"] = "farming:rhubarb_1",
	["farming:seed_barley"] = "farming:barley_1",
	["farming:seed_cotton"] = "farming:cotton_1",
	["farming:seed_hemp"] = "farming:hemp_1",
	["farming:seed_mint"] = "farming:mint_1",
	["farming:seed_wheat"] = "farming:wheat_1",
	["farming:tomato"] = "farming:tomato_1"
}

-- list of objects that cant be teleported with mover
basic_machines.no_teleport_table = {
	["shield_frame:shield_entity"] = true,
	["signs_lib:text"] = true
}

-- list of nodes mover cant take from in inventory mode
basic_machines.limit_inventory_table = { -- node name = {list of bad inventories to take from} OR node name = true to ban all inventories
	["basic_machines:autocrafter"] = {["recipe"] = 1, ["output"] = 1},
	["basic_machines:constructor"] = {["recipe"] = 1},
	["basic_machines:digtron_constructor"] = {["recipe"] = 1},
	["basic_machines:electronics_constructor"] = {["recipe"] = 1},
	["basic_machines:mover"] = true
}

-- when activated with keypad these will be "punched" to update their text too
basic_machines.signs = {
	["basic_signs:sign_wall_locked"] = true,
	["basic_signs:sign_wall_steel_blue"] = true,
	["basic_signs:sign_wall_steel_brown"] = true,
	["basic_signs:sign_wall_steel_green"] = true,
	["basic_signs:sign_wall_steel_orange"] = true,
	["basic_signs:sign_wall_steel_red"] = true,
	["basic_signs:sign_wall_steel_white_black"] = true,
	["basic_signs:sign_wall_steel_white_red"] = true,
	["basic_signs:sign_wall_steel_yellow"] = true,
	["default:sign_wall_steel"] = true,
	["default:sign_wall_wood"] = true
}

-- *** END OF SETTINGS *** --

local machines_timer = basic_machines.timer
local machines_minstep = basic_machines.machines_minstep
local max_range = basic_machines.max_range
local machines_operations = basic_machines.machines_operations
local machines_TTL = basic_machines.machines_TTL

local punchset = {}

minetest.register_on_joinplayer(function(player)
	local name = player:get_player_name(); if name == "" then return end
	punchset[name] = {}
	punchset[name].state = 0
end)

local get_mover_form = function(pos, name)
	if name == "" then return end
	local meta = minetest.get_meta(pos)

	local pos1 = {x = meta:get_int("x0"), y = meta:get_int("y0"), z = meta:get_int("z0")}
	local pos11 = {x = meta:get_int("x1"), y = meta:get_int("y1"), z = meta:get_int("z1")}
	local pos2 = {x = meta:get_int("x2"), y = meta:get_int("y2"), z = meta:get_int("z2")}

	machines.pos1[name] = vector.add(pos, pos1); machines.mark_pos1(name) -- mark pos1
	machines.pos11[name] = vector.add(pos, pos11); machines.mark_pos11(name) -- mark pos11
	machines.pos2[name] = vector.add(pos, pos2); machines.mark_pos2(name) -- mark pos2

	local meta1 = minetest.get_meta(machines.pos1[name]) -- source meta
	local meta2 = minetest.get_meta(machines.pos2[name]) -- target meta

	local inv1, inv2 = 1, 2
	local inv1m, inv2m = meta:get_string("inv1"), meta:get_string("inv2")

	local list1 = meta1:get_inventory():get_lists(); local inv_list1 = ""
	local j = 1 -- stupid dropdown requires item index but returns string on receive so we have to find index.. grrr, one other solution: invert the table: key <-> value
	for i in pairs(list1) do
		inv_list1 = inv_list1..i..","
		if i == inv1m then inv1 = j end; j = j + 1
	end

	local list2 = meta2:get_inventory():get_lists(); local inv_list2 = ""
	j = 1
	for i in pairs(list2) do
		inv_list2 = inv_list2..i..","
		if i == inv2m then inv2 = j; end; j = j + 1
	end

	local mode_list = {["normal"] = 1, ["dig"] = 2, ["drop"] = 3, ["object"] = 4, ["inventory"] = 5, ["transport"] = 6}
	local mode_string = meta:get_string("mode")
	local mode = mode_list[mode_string] or 1

	local mode_description = {
		["normal"] = "This will move blocks as they are - without change",
		["dig"] = "This will transform blocks as if player digged them",
		["drop"] = "This will take block/item out of chest (you need to set filter) and will drop it",
		["object"] = "Make TELEPORTER/ELEVATOR:\n This will move any object inside sphere (with center source1 and radius defined by source2) to target position\n For ELEVATOR, teleport points need to be placed exactly in same coordinate line with mover,\n and you need to upgrade with 1 diamond block for every 100 height difference",
		["inventory"] = "This will move items from inventory of any block at source position to any inventory of block at target position",
		["transport"] = "This will move all blocks at source area to new area starting at target position\nThis mode preserves all inventories and other metadata"
	}
	local text = mode_description[mode_string] or "description"

	local upgrade = meta:get_float("upgrade"); if upgrade > 0 then upgrade = upgrade - 1 end
	local list_name = "nodemeta:"..pos.x..','..pos.y..','..pos.z

	return (
		"size[8,9.5]"..
		"field[0.25,0.5;1,1;x0;source1;"..pos1.x.."]field[1.25,0.5;1,1;y0;;"..pos1.y.."]field[2.25,0.5;1,1;z0;;"..pos1.z.."]"..
		"dropdown[3,0.25;1.5,1;inv1;"..inv_list1..";"..inv1.."]"..
		"button[6,0.25;2,1;altgui;alternate gui]"..
		"field[0.25,1.5;1,1;x1;source2;"..pos11.x.."]field[1.25,1.5;1,1;y1;;"..pos11.y.."]field[2.25,1.5;1,1;z1;;"..pos11.z.."]"..
		"field[3.25,1.5;1,1;reverse;reverse;"..meta:get_int("reverse").."]"..
		"field[0.25,2.5;1,1;x2;target;"..pos2.x.."]field[1.25,2.5;1,1;y2;;"..pos2.y.."]field[2.25,2.5;1,1;z2;;"..pos2.z.."]"..
		"dropdown[3,2.25;1.5,1;inv2;"..inv_list2..";"..inv2.."]"..
		"label[0,3;MODE selection]"..
		"dropdown[0,3.35;3,1;mode;normal,dig,drop,object,inventory,transport;"..mode.."]"..
		"tooltip[0,3.35;1,0.72;"..text.."]"..
		"button[3,3.25;1,1;help;help]button_exit[4,3.25;1,1;OK;OK]"..
		"label[4,4;upgrade .. "..upgrade.."]"..
		"field[0.25,4.7;3,1;prefer;filter;"..meta:get_string("prefer").."]"..
		"list["..list_name..";filter;3,4.4;1,1;]"..
		"list["..list_name..";upgrade;4,4.4;1,1;]"..
		"list[current_player;main;0,5.5;8,4;]"..
		"listring["..list_name..";upgrade]"..
		"listring[current_player;main]"..
		"listring["..list_name..";filter]"..
		"listring[current_player;main]"
	)
end

local find_and_connect_battery = function(pos)
	local r = 1
	local positions = minetest.find_nodes_in_area( -- find battery
		vector.subtract(pos, r),
		vector.add(pos, r),
		"basic_machines:battery"
	)
	if #positions > 0 then
		local meta = minetest.get_meta(pos)
		local fpos = positions[1]
		meta:set_int("batx", fpos.x); meta:set_int("baty", fpos.y); meta:set_int("batz", fpos.z)
		return fpos
	end -- pick first battery we found
end

local check_for_falling = minetest.check_for_falling or nodeupdate -- 1st for mt 5.0.0+, 2nd for 0.4.17.1 and older


-- MOVER --
minetest.register_node("basic_machines:mover", {
	description = "Mover - universal digging/harvesting/teleporting/transporting machine, its upgradeable.",
	tiles = {"compass_top.png", "default_furnace_top.png", "basic_machine_mover_side.png", "basic_machine_mover_side.png", "basic_machine_mover_side.png", "basic_machine_mover_side.png"},
	groups = {cracky = 3},
	sounds = default.node_sound_wood_defaults(),
	after_place_node = function(pos, placer)
		local meta = minetest.get_meta(pos)
		local name = placer:get_player_name()
		meta:set_string("infotext", "Mover block. Set it up by punching or right click. Activate it by keypad signal.")
		meta:set_string("owner", name); meta:set_int("public", 0)
		meta:set_int("x0", 0); meta:set_int("y0", -1); meta:set_int("z0", 0) -- source1
		meta:set_int("x1", 0); meta:set_int("y1", -1); meta:set_int("z1", 0) -- source2: defines cube
		meta:set_int("pc", 0); meta:set_int("dim", 1) -- current cube position and dimensions
		meta:set_int("pc", 0); meta:set_int("dim", 1) -- current cube position and dimensions
		meta:set_int("x2", 0); meta:set_int("y2", 1); meta:set_int("z2", 0)
		meta:set_float("fuel", 0)
		meta:set_string("prefer", "")
		meta:set_string("mode", "normal")
		meta:set_float("upgrade", 1)

		local privs = minetest.get_player_privs(name)
		if privs.privs then meta:set_float("upgrade", -1) end -- means operation will be for free

		local inv = meta:get_inventory(); inv:set_size("filter", 1 * 1); inv:set_size("upgrade", 1 * 1)
		punchset[name].state = 0

		local text = "This machine can move anything. General idea is the following : \n\n"..
		"First you need to define rectangle box work area (larger area, where it takes from, defined by source1/source2 which are two number 1 boxes that appear in world) and target position (where it puts, marked by one number 2 box) by punching mover then following CHAT instructions exactly.\n\n"..
		"CHECK why it doesnt work: 1. did you click OK in mover after changing setting 2. does it have battery, 3. does battery have enough fuel 4. did you set filter for taking out of chest?\n\n"..
		"IMPORTANT: Please read the help button inside machine before first use."

		minetest.show_formspec(name, "basic_machines:intro_mover",
			"size[5.5,5.5]textarea[0,0;6,7;help;MOVER INTRODUCTION;"..text.."]")
	end,

	can_dig = function(pos, player) -- dont dig if upgrades inside, cause they will be destroyed
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		return inv:is_empty("upgrade")
	end,

	on_rightclick = function(pos, node, player, itemstack, pointed_thing)
		local name = player:get_player_name()
		-- local privs = minetest.get_player_privs(name)
		-- local cant_build = minetest.is_protected(pos, name)
		-- if not privs.privs and cant_build then return end -- only ppl sharing protection can setup

		local form = get_mover_form(pos, name)
		if form then minetest.show_formspec(name, "basic_machines:mover_"..minetest.pos_to_string(pos), form) end
	end,

	allow_metadata_inventory_put = function(pos, listname, index, stack, player)
		local name = player:get_player_name()
		if minetest.is_protected(pos, name) then return 0 end
		if listname == "filter" then
			local meta = minetest.get_meta(pos)

			meta:set_string("prefer", stack:to_string())

			minetest.show_formspec(name, "basic_machines:mover_"..minetest.pos_to_string(pos),
				get_mover_form(pos, name))
			return 1
		end

		if listname == "upgrade" then
			-- update upgrades
			local meta = minetest.get_meta(pos)
			local inv = meta:get_inventory()

			local upgrade_name = "default:mese"
			if meta:get_int("elevator") == 1 then upgrade_name = "default:diamondblock" end
			if stack:get_name() == upgrade_name then
			-- inv:contains_item("upgrade", ItemStack({name = "default:mese"})) then
				local upgrade = (inv:get_stack("upgrade", 1):get_count()) or 0
				upgrade = upgrade + stack:get_count()
				if upgrade > 10 then upgrade = 10 end -- not more than 10
				meta:set_float("upgrade", upgrade + 1)
				minetest.show_formspec(name, "basic_machines:mover_"..minetest.pos_to_string(pos),
					get_mover_form(pos, name))
			end

		end

		return stack:get_count()
	end,

	allow_metadata_inventory_take = function(pos, listname, index, stack, player)
		local name = player:get_player_name()
		if minetest.is_protected(pos, name) then return 0 end
		if listname == "upgrade" then
			local meta = minetest.get_meta(pos)
			meta:set_float("upgrade", 1) -- reset upgrade
			local privs = minetest.get_player_privs(name)
			if privs.privs then meta:set_float("upgrade", -1) end -- means operation will be for free
		end
		minetest.show_formspec(name, "basic_machines:mover_"..minetest.pos_to_string(pos),
			get_mover_form(pos, name))

		return stack:get_count()
	end,

	effector = {
		action_on = function(pos, node, ttl)
			if type(ttl) ~= "number" then ttl = 1 end
			local meta = minetest.get_meta(pos)
			local fuel = meta:get_float("fuel")

			local x0, y0, z0 = meta:get_int("x0"), meta:get_int("y0"), meta:get_int("z0")
			local x2, y2, z2 = meta:get_int("x2"), meta:get_int("y2"), meta:get_int("z2")

			local mode = meta:get_string("mode")
			local mreverse = meta:get_int("reverse")
			local pos1 = vector.add(pos, {x = x0, y = y0, z = z0}) -- where to take from
			local pos2 = vector.add(pos, {x = x2, y = y2, z = z2}) -- where to put

			local pc = meta:get_int("pc"); local dim = meta:get_int("dim");	pc = (pc + 1) % dim; meta:set_int("pc", pc) -- cycle position
			local x1, y1, z1 = meta:get_int("x1") - x0 + 1, meta:get_int("y1") - y0 + 1, meta:get_int("z1") - z0 + 1 -- get dimensions

			-- pc = z * a * b + x * b + y, from x, y, z to pc
			-- set current input position
			pos1.y = y0 + (pc % y1); pc = (pc - (pc % y1)) / y1
			pos1.x = x0 + (pc % x1); pc = (pc - (pc % x1)) / x1
			pos1.z = z0 + pc
			pos1.x, pos1.y, pos1.z = pos.x + pos1.x, pos.y + pos1.y, pos.z + pos1.z

			-- special modes that use its own source/target positions:
			if mode == "transport" and mreverse < 2 then
				pos2 = {
					x = x2 - x0 + pos1.x,
					y = y2 - y0 + pos1.y,
					z = z2 - z0 + pos1.z
				} -- translation from pos1
			end

			if mreverse ~= 0 and mreverse ~= 2 then -- reverse pos1, pos2
				if mode == "object" then
					x0, y0, z0 = pos2.x - pos.x, pos2.y - pos.y, pos2.z - pos.z
					pos2 = {x = pos1.x, y = pos1.y, z = pos1.z}
				else
					local post = {x = pos1.x, y = pos1.y, z = pos1.z}
					pos1 = {x = pos2.x, y = pos2.y, z = pos2.z}
					pos2 = {x = post.x, y = post.y, z = post.z}
				end
			end

			-- PROTECTION CHECK
			local owner = meta:get_string("owner")
			if mode ~= "object" and (minetest.is_protected(pos1, owner) or minetest.is_protected(pos2, owner)) then
				meta:set_string("infotext", "Mover block. Protection fail.")
				return
			end

			local node1, node2 = minetest.get_node(pos1), minetest.get_node(pos2)
			local prefer = meta:get_string("prefer")

			-- FUEL COST: calculate
			local dist = math.abs(pos2.x - pos1.x) + math.abs(pos2.y - pos1.y) + math.abs(pos2.z - pos1.z)
			local hardness = basic_machines.hardness[node1.name]
			-- no free teleports from machine blocks
			if hardness == 0 and mode == "object" then hardness = 1 end
			local fuel_cost = hardness or 1

			local upgrade = meta:get_float("upgrade") or 1

			-- taking items from chests/inventory move
			if node1.name == "default:chest_locked" or mode == "inventory" then fuel_cost = basic_machines.hardness[prefer] or 1 end

			fuel_cost = fuel_cost * dist / machines_operations -- machines_operations = 10 by default, so 10 basic operations possible with 1 coal
			if mode == "object" then
				fuel_cost = fuel_cost * 0.1
				if (x2 == 0 and y2 == 0) or (x2 == 0 and z2 == 0) or (y2 == 0 and z2 == 0) then -- check if elevator mode
					local requirement = math.floor((math.abs(pos2.x - pos.x) + math.abs(pos2.y - pos.y) + math.abs(pos2.z - pos.z)) / 100) + 1
					if upgrade - 1 < requirement then
						meta:set_string("infotext", "MOVER: Elevator error. Need at least "..requirement.." diamond block(s) in upgrade (1 for every 100 distance).")
						return
					end
					fuel_cost = 0
				end
			elseif mode == "inventory" then
				fuel_cost = fuel_cost * 0.1
			end

			fuel_cost = fuel_cost / upgrade -- upgrade decreases fuel cost
			if upgrade == -1 then fuel_cost = 0 end -- free operation for admin

			-- FUEL OPERATIONS
			if fuel < fuel_cost then -- needs fuel to operate, find nearby battery
				local found_fuel = 0

				-- cached battery position
				local fpos = {x = meta:get_int("batx"), y = meta:get_int("baty"), z = meta:get_int("batz")}

				local power_draw = fuel_cost
				if power_draw < 1 then power_draw = 1 end -- at least 10 one block operations with 1 refuel
				local supply = basic_machines.check_power(fpos, power_draw)

				if supply > 0 then
					found_fuel = supply
				elseif supply < 0 then -- no battery at target location, try to find it!
					local fpos = find_and_connect_battery(pos)
					if not fpos then
						meta:set_string("infotext", "Can not find nearby battery to connect to!")
						minetest.sound_play("default_cool_lava", {pos = pos, gain = 1, max_hear_distance = 8})
						return
					end
				end

				if found_fuel ~= 0 then
					fuel = fuel + found_fuel
					meta:set_float("fuel", fuel)
					meta:set_string("infotext", "Mover block refueled. Fuel "..fuel)

				end
			end

			if fuel < fuel_cost then
				meta:set_string("infotext", "Mover block. Energy "..fuel..", needed energy "..fuel_cost..". Put nonempty battery next to mover.")
				return
			end

		if mode == "object" then -- teleport objects and return
			-- if target is chest put items in it
			local target_chest = false
			if node2.name == "default:chest" or node2.name == "default:chest_locked" then
				target_chest = true
			end
			local r = math.max(math.abs(x1), math.abs(y1), math.abs(z1)); r = math.min(r, 10)
			local teleport_any = false

			if target_chest then -- put objects in target chest
				local cmeta = minetest.get_meta(pos2)
				local inv = cmeta:get_inventory()

				for _, obj in pairs(minetest.get_objects_inside_radius(vector.add(pos, {x = x0, y = y0, z = z0}), r)) do
					local lua_entity = obj:get_luaentity()
					if not obj:is_player() and lua_entity and lua_entity.itemstring ~= "" then
						local detected_obj = lua_entity.itemstring or ""
						if not basic_machines.no_teleport_table[detected_obj] and (prefer == "" or prefer == detected_obj) then -- object on no teleport list
							-- put item in chest
							local stack = ItemStack(lua_entity.itemstring)
							if inv:room_for_item("main", stack) then
								teleport_any = true
								inv:add_item("main", stack)
							end
							obj:set_pos({x = 0, y = 0, z = 0})
							obj:remove()
						end
					end
				end
				if teleport_any then
					fuel = fuel - fuel_cost; meta:set_float("fuel", fuel)
					meta:set_string("infotext", "Mover block. Fuel "..fuel)
					minetest.sound_play("tng_transporter1", {pos = pos2, gain = 1, max_hear_distance = 8})
				end
				return
			end

			local times = tonumber(prefer) or 0; if times > 20 then times = 20 elseif times < 0.2 then times = 0 end
			local velocityv = nil
			if times ~= 0 then
				velocityv = {
					x = pos2.x - x0 - pos.x,
					y = pos2.y - y0 - pos.y,
					z = pos2.z - z0 - pos.z
				}
				local vv = math.sqrt(velocityv.x * velocityv.x + velocityv.y * velocityv.y + velocityv.z * velocityv.z)
				local velocitys = 0
				if times ~= 0 then velocitys = vv / times else vv = 0 end
				if vv ~= 0 then vv = velocitys / vv else vv = 0 end
				velocityv.x = velocityv.x * vv;	velocityv.y = velocityv.y * vv;	velocityv.z = velocityv.z * vv
			end

			-- minetest.chat_send_all("times "..times.." v "..minetest.pos_to_string(velocityv))

			-- move objects to another location
			local finalsound = true
			for _, obj in pairs(minetest.get_objects_inside_radius(vector.add(pos, {x = x0, y = y0, z = z0}), r)) do
				if obj:is_player() then
					if not minetest.is_protected(obj:get_pos(), owner) and (prefer == "" or obj:get_player_name() == prefer) then -- move player only from owners land
						obj:move_to(pos2, false)
						teleport_any = true
					end
				else
					local lua_entity = obj:get_luaentity()
					local detected_obj = lua_entity.name or ""
					if not basic_machines.no_teleport_table[detected_obj] then -- object on no teleport list
						if times > 0 then
							local finalmove = true
							-- move objects with set velocity in target direction
							obj:set_velocity(velocityv)
							if obj:get_luaentity() then -- interaction with objects like carts
								if lua_entity.name then
									if lua_entity.name == "basic_machines:ball" then -- move balls for free
										lua_entity.velocity = {
											x = velocityv.x * times,
											y = velocityv.y * times,
											z = velocityv.z * times
										}
										finalmove = false
										finalsound = false
									end
									if lua_entity.name == "carts:cart" then -- just accelerate cart
										lua_entity.velocity = {
											x = velocityv.x * times,
											y = velocityv.y * times,
											z = velocityv.z * times
										}
										fuel = fuel - fuel_cost; meta:set_float("fuel", fuel)
										meta:set_string("infotext", "Mover block. Fuel "..fuel)
										return
									end
								end
							end
							-- obj:set_acceleration({x = 0, y = 0, z = 0})
							if finalmove then -- dont move objects like balls to destination after delay
								minetest.after(times, function() if obj then obj:set_velocity({x = 0, y = 0, z = 0}); obj:move_to(pos2, false) end end)
							end
						else
							obj:move_to(pos2, false)
						end
					end
					teleport_any = true
				end
			end

			if teleport_any then
				fuel = fuel - fuel_cost; meta:set_float("fuel", fuel)
				meta:set_string("infotext", "Mover block. Fuel "..fuel)
				if finalsound then minetest.sound_play("tng_transporter1", {pos = pos2, gain = 1, max_hear_distance = 8}) end
			end

			return
		end

		local dig = false; if mode == "dig" then dig = true end -- digs at target location
		local drop = false; if mode == "drop" then drop = true end -- drops node instead of placing it
		local harvest = false -- harvest mode for special nodes: mese crystals

		-- decide what to do if source or target are chests
		local source_chest = false; if string.find(node1.name, "default:chest") then source_chest = true end
		if node1.name == "air" then return end -- nothing to move

		local target_chest = false
		if node2.name == "default:chest" or node2.name == "default:chest_locked" then
			target_chest = true
		end

		if not target_chest and not (mode == "inventory") and minetest.get_node(pos2).name ~= "air" then return end -- do nothing if target nonempty and not chest

		local invName1, invName2 = "", ""
		if mode == "inventory" then
			invName1, invName2 = meta:get_string("inv1"), meta:get_string("inv2")
			if mreverse == 1 then -- reverse inventory names too
				local invNamet = invName1; invName1 = invName2; invName2 = invNamet
			end
		end

		-- inventory mode
		if mode == "inventory" then
			-- if prefer == "" then meta:set_string("infotext", "Mover block. Must set nodes to move (filter) in inventory mode."); return end

			-- forbidden nodes to take from in inventory mode - to prevent abuses :
			local limit_inventory = basic_machines.limit_inventory_table[node1.name]
			if limit_inventory then
				if limit_inventory or limit_inventory[invName1] then -- forbidden to take from this inventory
					return
				end
			end

			local stack, meta1, inv1 = nil
			if prefer == "" then -- if prefer == "" then just pick one item from chest to transfer
				meta1 = minetest.get_meta(pos1)
				inv1 = meta1:get_inventory()
				if inv1:is_empty(invName1) then return end -- nothing to move

				local size = inv1:get_size(invName1)

				local found = false
				for i = 1, size do -- find item to move in inventory
					stack = inv1:get_stack(invName1, i)
					if not stack:is_empty() then found = true break end
				end
				if not found then return end
			end

			-- can we move item to target inventory?
			if prefer ~= "" then
				stack = ItemStack(prefer)
			end
			local meta2 = minetest.get_meta(pos2); local inv2 = meta2:get_inventory()
			if not inv2:room_for_item(invName2, stack) then	return end

			-- add item to target inventory and remove item from source inventory
			if prefer ~= "" then
				meta1 = minetest.get_meta(pos1); inv1 = meta1:get_inventory()
			end

			if inv1:contains_item(invName1, stack) then
				inv2:add_item(invName2, stack)
				inv1:remove_item(invName1, stack)
			else
				if upgrade == -1 then -- admin is owner.. just add stuff
					inv2:add_item(invName2, stack)
				else
					return -- item not found in chest
				end
			end

			minetest.sound_play("chest_inventory_move", {pos = pos2, gain = 1, max_hear_distance = 8})
			fuel = fuel - fuel_cost; meta:set_float("fuel", fuel)
			meta:set_string("infotext", "Mover block. Fuel "..fuel)
			return
		end

		-- filtering
		if prefer ~= "" then -- prefered node set
			if prefer ~= node1.name and not source_chest and mode ~= "inventory" then return end -- only take prefered node or from chests/inventories
			if source_chest then -- take stuff from chest
				local cmeta = minetest.get_meta(pos1)
				local inv = cmeta:get_inventory()
				local stack = ItemStack(prefer)

				if inv:contains_item("main", stack) then
					inv:remove_item("main", stack)
				else
					return
				end

				if mreverse == 1 then -- planting mode: check if transform seed -> plant is needed
				if basic_machines.plant_table[prefer] then
					prefer = basic_machines.plant_table[prefer]
				end
			end
			end

			node1 = {}; node1.name = prefer
		end

		if (prefer == "" and source_chest) then return end -- doesnt know what to take out of chest/inventory

		-- if target chest put in chest
		if target_chest then
			local cmeta = minetest.get_meta(pos2)
			local inv = cmeta:get_inventory()

			-- dig tree or cactus
			local count = 0 -- check for cactus or tree
			local dig_up = false -- digs up node as a tree
			if dig then
				if not source_chest and basic_machines.dig_up_table[node1.name] then dig_up = true end
				-- do we harvest the node?
				if not source_chest then
					if basic_machines.harvest_table[node1.name] ~= nil then
						harvest = true
						local remains = basic_machines.harvest_table[node1.name][1]
						local result = basic_machines.harvest_table[node1.name][2]
						minetest.set_node(pos1, {name = remains})
						inv:add_item("main", result)
					end
				end

				if dig_up then -- dig up to 16 nodes
					local r = 1
					if node1.name == "default:cactus" or node1.name == "default:papyrus" then r = 0 end
					if node1.name == "default:acacia_tree" then r = 2 end -- acacia trees grow wider than others

					local positions = minetest.find_nodes_in_area(
						{x = pos1.x - r, y = pos1.y, z = pos1.z - r},
						{x = pos1.x + r, y = pos1.y + 16, z = pos1.z + r},
						node1.name
					)

					for _, pos3 in ipairs(positions) do
						-- if count > 16 then break end
						minetest.set_node(pos3, {name = "air"}); count = count + 1
					end

					inv:add_item("main", node1.name.." "..count - 1) -- if tree or cactus was digged up
				end

				-- minetest drop code emulation
				if not harvest then
					local table = minetest.registered_items[node1.name]
					if table ~= nil then -- put in chest
						if table.drop ~= nil then -- drop handling
							if table.drop.items then
								-- handle drops better, emulation of drop code
								local max_items = table.drop.max_items or 0
								if max_items == 0 then -- just drop all the items (taking the rarity into consideration)
									max_items = #table.drop.items or 0
								end
								local drop = table.drop
								local i = 0
								for _, v in pairs(drop.items) do
									if i > max_items then break end; i = i + 1
									local rare = v.rarity or 1
									if math.random(1, rare) == 1 then
										node1 = {}; node1.name = v.items[math.random(1, #v.items)] -- pick item randomly from list
										inv:add_item("main", node1.name)
									end
								end
							else
								inv:add_item("main", table.drop)
							end
						else
							inv:add_item("main", node1.name)
						end
					end
				end
			else -- if not dig just put it in
				inv:add_item("main", node1.name)
			end
		end

		minetest.sound_play("transporter", {pos = pos2, gain = 1, max_hear_distance = 8})

		if target_chest and source_chest then -- chest to chest transport has lower cost, * 0.1
			fuel_cost = fuel_cost * 0.1
		end

		fuel = fuel - fuel_cost; meta:set_float("fuel", fuel)
		meta:set_string("infotext", "Mover block. Fuel "..fuel)

		if mode == "transport" then -- transport nodes parallel as defined by source1 and target, clone with complete metadata
			local meta1 = minetest.get_meta(pos1):to_table()

			minetest.set_node(pos2, minetest.get_node(pos1))
			minetest.get_meta(pos2):from_table(meta1)
			minetest.set_node(pos1, {name = "air"}); minetest.get_meta(pos1):from_table(nil)
			return
		end

		-- REMOVE DIGGED NODE
		if not target_chest then
			if not drop then minetest.set_node(pos2, {name = node1.name}) end
			if drop then
				local stack = ItemStack(node1.name)
				minetest.add_item(pos2, stack) -- drops it
			end
		end
		if not source_chest and not harvest then
			if dig then check_for_falling(pos1) end -- pre 5.0.0 nodeupdate(pos1)
			minetest.set_node(pos1, {name = "air"})
			end
		end,

		action_off = function(pos, node, ttl) -- this toggles reverse option of mover
			if type(ttl) ~= "number" then ttl = 1 end
			local meta = minetest.get_meta(pos)
			local mreverse = meta:get_int("reverse")
			local mode = meta:get_string("mode")
			if mode ~= "dig" then -- reverse switching is not very helpful when auto harvest trees for example
				if mreverse == 1 then mreverse = 0 elseif mreverse == 0 then mreverse = 1 end
				meta:set_int("reverse", mreverse)
			end
		end
	}
})

local function rank(name)
	local player = minetest.get_player_by_name(name)
	if player and ranking.get_rank_raw(player, "intelligence") == 65535 then
		return false
	end
	return true
end

local admin = minetest.settings:get("name")

-- anal retentive change in minetest 5.0.0 to minetest 5.1.0 changing unknown node warning into crash
-- forcing many checks with all possible combinations + adding many new crash combinations
local check_mover_filter = function(mode, filter, mreverse, name) -- mover input validation, is it correct node
	if filter == "" then return true end -- allow clearing filter
	if mode == "normal" or mode == "dig" then
		local nodedef = minetest.registered_nodes[filter]
		if mreverse == 1 and basic_machines.plant_table[filter] then return true end -- allow farming
		if not nodedef then
			return false
		end
	else
		filter = filter:match("^[%l_]+:[%w_]+%s?%d*$")
		if not filter and rank(name) and name ~= admin then
			return false
		end
	end
	return true
end

local function check_target_chest(mode, pos, meta)
	if mode == "normal" or mode == "dig" then
		local pos2 = vector.add(pos, {x = meta:get_int("x2"), y = meta:get_int("y2"), z = meta:get_int("z2")})
		local tnode = minetest.get_node(pos2)
		if tnode.name == "default:chest" or tnode.name == "default:chest_locked" then
			return true
		end
	end
	return false
end

local use_signs_lib = minetest.global_exists("signs_lib")


-- KEYPAD --
local function use_keypad(pos, ttl, again) -- position, time to live (how many times can signal travel before vanishing to prevent infinite recursion), do we want to activate again
	if ttl < 0 then return end
	local meta = minetest.get_meta(pos)

	local t0 = meta:get_int("t")
	local t1 = minetest.get_gametime()
	local T = meta:get_int("T") -- temperature

	if t0 > t1 - machines_minstep then -- activated before natural time
		T = T + 1
	else
		if T > 0 then
			T = T - 1
			if t1 - t0 > 5 then T = 0 end
		end
	end
	meta:set_int("T", T)
	meta:set_int("t", t1) -- update last activation time

	if T > 2 then -- overheat
		minetest.sound_play("default_cool_lava", {pos = pos, max_hear_distance = 16, gain = 0.25})
		meta:set_string("infotext", "Overheat: Temperature "..T)
		return
	end

	local name = meta:get_string("owner")
	if minetest.is_protected(pos, name) then meta:set_string("infotext", "Protection fail. Reset."); meta:set_int("count", 0) return end
	local count = meta:get_int("count") or 0 -- counts how many repeats left

	local repeating = meta:get_int("repeating")

	if repeating == 1 and again ~= 1 then
		-- stop it
		meta:set_int("repeating", 0)
		meta:set_int("count", 0)
		meta:set_int("T", 4)
		meta:set_string("infotext", "KEYPAD: Reseting. Punch again after 5s to activate")
		return
	end

	if count > 0 then -- this is keypad repeating its activation
		count = count - 1; meta:set_int("count", count)
	else
		meta:set_int("repeating", 0)
		-- return
	end

	if count >= 0 then
		meta:set_string("infotext", "Keypad operation: "..count.." cycles left")
	else
		meta:set_string("infotext", "Keypad operation: Activation "..-count)
	end

	if count > 0 then -- only trigger repeat if count on
		if repeating == 0 then meta:set_int("repeating", 1) end -- its repeating now
		if basic_machines.clockgen == 0 then return end
		minetest.after(machines_timer, function()
			use_keypad(pos, machines_TTL, 1)
		end)
	end

	local mode = meta:get_int("mode")

	-- pass the signal on to target, depending on mode

	local tpos = vector.add(pos, {x = meta:get_int("x0"), y = meta:get_int("y0"), z = meta:get_int("z0")})-- target position
	local node = minetest.get_node(tpos); if not node.name then return end -- error
	local text = meta:get_string("text")

	if text ~= "" then -- TEXT MODE; set text on target
		if text == "@" then -- keyboard mode, set text from input
			text = meta:get_string("input")
			meta:set_string("input", "") -- clear input again
		end

		local bit = string.byte(text)
		if bit == 33 then -- if text starts with !, then we send chat text to all nearby players, radius 5
			text = string.sub(text, 2); if not text or text == "" then return end
			local players = minetest.get_connected_players()
			for _, player in pairs(players) do
				local pos1 = player:get_pos()
				local dist = math.sqrt((pos1.x - tpos.x)^2 + (pos1.y - tpos.y)^2 + (pos1.z - tpos.z)^2)
				if dist <= 5 then
					minetest.chat_send_player(player:get_player_name(), text)
				end
			end
			return
		elseif bit == 36 then -- text starts with $, play sound
			text = string.sub(text, 2); if not text or text == "" then return end
			local i = string.find(text, " ")
			if not i then
				minetest.sound_play(text, {pos = pos, gain = 1, max_hear_distance = 16})
			else
				local pitch = tonumber(string.sub(text, i + 1)) or 1
				if pitch < 0.01 or pitch > 10 then pitch = 1 end
				minetest.sound_play(string.sub(text, 1, i - 1), {pos = pos, gain = 1, max_hear_distance = 16, pitch = pitch})
			end
		end

		local tmeta = minetest.get_meta(tpos); if not tmeta then return end

		if basic_machines.signs[node.name] then -- update text on signs with signs_lib
			tmeta:set_string("infotext", text)
			tmeta:set_string("text", text)
			local table = minetest.registered_nodes[node.name]
			if not table.on_punch then return end -- error
			if use_signs_lib and signs_lib.update_sign then
				-- signs_lib.update_sign(pos)
				table.on_punch(tpos, node, nil) -- warning - this can cause problems if no signs_lib installed
			end

			return
		end

		-- target is keypad, special functions: @, % that output to target keypad text
		if node.name == "basic_machines:keypad" then -- special modify of target keypad text and change its target
			-- tpos = vector.add(tpos, {x = tmeta:get_int("x0"), y = tmeta:get_int("y0"), z = tmeta:get_int("z0")})
			if string.byte(text) == 64 then -- target keypad's text starts with @ (ascii code 64) -> character replacement
				text = string.sub(text, 2); if not text or text == "" then return end
				-- read words [j] from blocks above keypad:
				local j = 0
				text = string.gsub(text, "@",
					function()
						j = j + 1
						return meta:get_string("infotext")
					end
				) -- replace every @ in ttext with string on blocks above

				-- set target keypad's text
				-- tmeta = minetest.get_meta(tpos); if not tmeta then return end
				tmeta:set_string("text", text)
			elseif string.byte(text) == 37 then -- target keypad's text starts with % (ascii code 37) -> word extraction
				local ttext = minetest.get_meta({x = pos.x, y = pos.y + 1, z = pos.z}):get_string("infotext")
				local i = tonumber(string.sub(text, 2, 2)) or 1 -- read the number following the %
				-- extract i - th word from text
				local j = 0
				for word in string.gmatch(ttext, "%S+") do
					j = j + 1; if j == i then text = word; break end
				end

				-- set target keypad's target's text
				-- tmeta = minetest.get_meta(tpos); if not tmeta then return end
				tmeta:set_string("text", text)
			else

				if string.byte(text) == 64 then -- if text starts with @ clear target keypad text
					tmeta:set_string("text", "")
					return
				end
				-- just set text..
				-- tmeta = minetest.get_meta(tpos); if not tmeta then return end
				tmeta:set_string("infotext", text)
			end
			return
		end

		if node.name == "basic_machines:detector" then -- change filter on detector
			if string.byte(text) == 64 then -- if text starts with @ clear the filter
				tmeta:set_string("node", "")
			else
				tmeta:set_string("node", text)
			end
			return
		end

		if node.name == "basic_machines:mover" then -- change filter on mover
			if string.byte(text) == 64 then -- if text starts with @ clear the filter
				tmeta:set_string("prefer", "")
			else
				local puncher = meta:get_string("puncher")
				local mode = tmeta:get_string("mode")
				if check_mover_filter(mode, text, tmeta:get_int("reverse"), puncher) or check_target_chest(mode, tpos, tmeta) then -- mover input validate
					if puncher ~= "" then meta:set_string("puncher", "") end; tmeta:set_string("prefer", text)
				end
			end
			return
		end

		if node.name == "basic_machines:distributor" then
			local i = string.find(text, " ")
			if i then
				local ti = tonumber(string.sub(text, 1, i - 1)) or 1
				local tm = tonumber(string.sub(text, i + 1)) or 1
				if ti >= 1 and ti <= 16 and tm >= -2 and tm <= 2 then
					tmeta:set_int("active"..ti, tm)
				end
			end
			return
		end

		tmeta:set_string("infotext", text) -- else just set text
	end

	-- activate target
	local table = minetest.registered_nodes[node.name]
	if not table then return end -- error
	if not table.effector then return end -- error
	local effector = table.effector

	if mode == 3 then -- keypad in toggle mode
		local state = meta:get_int("state") or 0; state = 1 - state; meta:set_int("state", state)
		if state == 0 then mode = 1 else mode = 2 end
	end

	-- pass the signal on to target
	if mode == 2 then -- on
		if not effector.action_on then return end
		effector.action_on(tpos, node, ttl - 1) -- run
	elseif mode == 1 then -- off
		if not effector.action_off then return end
		effector.action_off(tpos, node, ttl - 1) -- run
	end
end

local function check_keypad(pos, name, ttl) -- called only when manually activated via punch
	local meta = minetest.get_meta(pos)
	if meta:get_string("pass") == "" then
		local iter = meta:get_int("iter")
		local count = meta:get_int("count")
		if count < iter - 1 or iter < 2 then meta:set_int("active_repeats", 0) end -- so that keypad can work again, at least one operation must have occured though
		meta:set_int("count", iter); use_keypad(pos, machines_TTL, 0) -- time to live set when punched
		return
	end
	if name == "" then return end

	if meta:get_string("text") == "@" then -- keypad works as a keyboard
		minetest.show_formspec(name, "basic_machines:check_keypad_"..minetest.pos_to_string(pos),
			"size[3,1]field[0.25,0.25;3,1;pass;Enter text:;]button_exit[0,0.75;1,1;OK;OK]")
		return
	end

	minetest.show_formspec(name, "basic_machines:check_keypad_"..minetest.pos_to_string(pos),
		"size[3,1.25]bgcolor[#FF8888BB;false]field[0.25,0.25;3,1;pass;Enter password:;]button_exit[0,0.75;1,1;OK;OK]")
end

minetest.register_node("basic_machines:keypad", {
	description = "Keypad - basic way to activate machines by sending signal",
	tiles = {"keypad.png"},
	groups = {cracky = 3},
	sounds = default.node_sound_wood_defaults(),
	after_place_node = function(pos, placer)
		local meta = minetest.get_meta(pos)
		local name = placer:get_player_name()
		meta:set_string("infotext", "Keypad. Right click to set it up or punch it. Set any password and text \"@\" to work as keyboard.")
		meta:set_string("owner", name); meta:set_int("public", 1)
		meta:set_int("x0", 0); meta:set_int("y0", 0); meta:set_int("z0", 0) -- target

		meta:set_string("pass", ""); meta:set_int("mode", 2) -- pasword, mode of operation
		meta:set_int("iter", 1); meta:set_int("count", 0) -- how many repeats to do, current repeat count
		punchset[name] = {}; punchset[name].state = 0
	end,

	effector = {
		action_on = function(pos, node, ttl)
			if type(ttl) ~= "number" then ttl = 1 end
			if ttl < 0 then return end -- machines_TTL prevents infinite recursion
			use_keypad(pos, 0, 0) -- activate just 1 time
		end
	},
	on_rightclick = function(pos, node, player, itemstack, pointed_thing)
		local name = player:get_player_name()
		local meta = minetest.get_meta(pos)
		local privs = minetest.get_player_privs(name)
		local cant_build = minetest.is_protected(pos, name)
		-- meta:get_string("owner") ~= name and
		if not privs.privs and cant_build then
			return
		end -- only ppl sharing protection can set up keypad
		local x0, y0, z0 = meta:get_int("x0"), meta:get_int("y0"), meta:get_int("z0")
		local iter = meta:get_int("iter") or 1
		local text = meta:get_string("text")
		local mode = meta:get_int("mode") or 1

		machines.pos1[name] = vector.add(pos, {x = x0, y = y0, z = z0}); machines.mark_pos1(name) -- mark pos1

		local pass = meta:get_string("pass")
		local form =
			"size[4.25,3.75]".. -- width, height
			"bgcolor[#888888BB;false]"..
			"field[1.25,0.25;1,1;iter;repeat;"..iter.."]"..
			"field[0.25,0.25;1,1;mode;mode;"..mode.."]"..
			"field[2.25,0.25;2.25,1;pass;password;"..pass.."]"..
			"label[0,0.75;"..minetest.colorize("lawngreen", "MODE: 1=OFF, 2=ON, 3=TOGGLE").."]"..
			"field[0.25,2.5;3.25,1;text;text;"..text.."]button_exit[3.25,2.25;1,1;OK;OK]"..
			"field[0.25,3.5;1,1;x0;target;"..x0.."]field[1.25,3.5;1,1;y0;;"..y0.."]field[2.25,3.5;1,1;z0;;"..z0.."]"..
			"button[3.25,3.25;1,1;help;help]"

		-- if meta:get_string("owner") == name then
			minetest.show_formspec(name, "basic_machines:keypad_"..minetest.pos_to_string(pos), form)
		-- else
			-- minetest.show_formspec(name, "view_only_basic_machines_keypad", form)
		-- end
	end
})


-- DETECTOR --
minetest.register_node("basic_machines:detector", {
	description = "Detector - can detect blocks/players/objects and activate machines",
	tiles = {"detector.png"},
	groups = {cracky = 3},
	sounds = default.node_sound_wood_defaults(),
	after_place_node = function(pos, placer)
		local meta = minetest.get_meta(pos)
		local name = placer:get_player_name()
		meta:set_string("infotext", "Detector. Right click/punch to set it up.")
		meta:set_string("owner", name); meta:set_int("public", 0)
		meta:set_int("x0", 0); meta:set_int("y0", 0); meta:set_int("z0", 0) -- source1: read
		meta:set_int("x1", 0); meta:set_int("y1", 0); meta:set_int("z1", 0) -- source1: read
		meta:set_int("x2", 0); meta:set_int("y2", 1); meta:set_int("z2", 0) -- target: activate
		meta:set_int("r", 0)
		meta:set_string("node", ""); meta:set_int("NOT", 2)
		meta:set_string("mode", "node")
		meta:set_int("public", 0)
		meta:set_int("state", 0)

		local inv = meta:get_inventory(); inv:set_size("mode_select", 3 * 1)
		inv:set_stack("mode_select", 1, ItemStack("default:coal_lump"))
		punchset[name] = {}; punchset[name].node = ""; punchset[name].state = 0
	end,

	on_rightclick = function(pos, node, player, itemstack, pointed_thing)
		local name = player:get_player_name(); if name == "" then return end
		local meta = minetest.get_meta(pos)
		local privs = minetest.get_player_privs(name)

		local cant_build = minetest.is_protected(pos, name)
		-- meta:get_string("owner") ~= name and
		if not privs.privs and cant_build then
			return
		end

		local pos1 = {x = meta:get_int("x0"), y = meta:get_int("y0"), z = meta:get_int("z0")}
		local pos11 = {x = meta:get_int("x1"), y = meta:get_int("y1"), z = meta:get_int("z1")}
		local pos2 = {x = meta:get_int("x2"), y = meta:get_int("y2"), z = meta:get_int("z2")}

		machines.pos1[name] = vector.add(pos, pos1); machines.mark_pos1(name) -- mark pos1
		machines.pos11[name] = vector.add(pos, pos11); machines.mark_pos11(name) -- mark pos11
		machines.pos2[name] = vector.add(pos, pos2); machines.mark_pos2(name) -- mark pos2

		local op = meta:get_string("op")
		local mode = meta:get_string("mode")
		local mode_list = {["node"] = 1, ["player"] = 2, ["object"] = 3, ["inventory"] = 4, ["infotext"] = 5, ["light"] = 6}
		mode = mode_list[mode] or 1
		local op_list = {[""] = 1, ["AND"] = 2, ["OR"] = 3}
		op = op_list[op] or 1

		local inv1 = 1
		local inv1m = meta:get_string("inv1")
		local meta1 = minetest.get_meta(machines.pos1[name])

		local list1 = meta1:get_inventory():get_lists(); local inv_list1 = ""
		local j = 1 -- stupid dropdown requires item index but returns string on receive so we have to find index.. grrr, one other solution: invert the table: key <-> value
		for i in pairs(list1) do
			inv_list1 = inv_list1..i..","
			if i == inv1m then inv1 = j end; j = j + 1
		end

		local form =
			"size[4,6.25]".. -- width, height
			"field[0.25,0.5;1,1;x0;source1;"..pos1.x.."]field[1.25,0.5;1,1;y0;;"..pos1.y.."]field[2.25,0.5;1,1;z0;;"..pos1.z.."]"..
			"dropdown[3,0.25;1,1;op; ,AND,OR;"..op.."]"..
			"field[0.25,1.5;1,1;x1;source2;"..pos11.x.."]field[1.25,1.5;1,1;y1;;"..pos11.y.."]field[2.25,1.5;1,1;z1;;"..pos11.z.."]"..
			"field[0.25,2.5;1,1;x2;target;"..pos2.x.."]field[1.25,2.5;1,1;y2;;"..pos2.y.."]field[2.25,2.5;1,1;z2;;"..pos2.z.."]"..
			"field[0.25,3.5;2,1;node;Node/player/object:;"..meta:get_string("node").."]field[3.25,2.5;1,1;r;radius;"..meta:get_int("r").."]"..
			"dropdown[0,4.5;3,1;mode;node,player,object,inventory,infotext,light;"..mode.."]"..
			"dropdown[0,5.5;3,1;inv1;"..inv_list1..";"..inv1.."]"..
			"label[0,4;"..minetest.colorize("lawngreen", "MODE selection").."]"..
			"label[0,5.2;inventory selection]"..
			"field[2.25,3.5;2,1;NOT;filter out -2/-1/0/1/2/3/4;"..meta:get_int("NOT").."]"..
			"button[3,4.4;1,1;help;help]button_exit[3,5.4;1,1;OK;OK]"

		-- if meta:get_string("owner") == name then
			minetest.show_formspec(name, "basic_machines:detector_"..minetest.pos_to_string(pos), form)
		-- else
			-- minetest.show_formspec(name, "view_only_basic_machines_detector", form)
		-- end
	end,

	allow_metadata_inventory_put = function(pos, listname, index, stack, player)
		return 0
	end,

	allow_metadata_inventory_take = function(pos, listname, index, stack, player)
		return 0
	end,

	allow_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
		local mode = "node"
		local meta = minetest.get_meta(pos)
		if to_index == 2 then
			mode = "player"
			meta:set_int("r", math.max(meta:get_int("r"), 1))
		end
		if to_index == 3 then
			mode = "object"
			meta:set_int("r", math.max(meta:get_int("r"), 1))
		end
		meta:set_string("mode", mode)
		minetest.chat_send_player(player:get_player_name(), "DETECTOR: Mode of operation set to: "..mode)
		return count
	end,

	effector = {
		action_on = function(pos, node, ttl)
			if type(ttl) ~= "number" then ttl = 1 end
			if ttl < 0 then return end

			local meta = minetest.get_meta(pos)

			local t0 = meta:get_int("t")
			local t1 = minetest.get_gametime()
			local T = meta:get_int("T") -- temperature

			if t0 > t1 - machines_minstep then -- activated before natural time
				T = T + 1
			else
				if T > 0 then T = T - 1 end
			end
			meta:set_int("T", T)
			meta:set_int("t", t1) -- update last activation time

			if T > 2 then -- overheat
				minetest.sound_play("default_cool_lava", {pos = pos, max_hear_distance = 16, gain = 0.25})
				meta:set_string("infotext", "Overheat: Temperature "..T)
				return
			end

			local pos1 = vector.add(pos, {x = meta:get_int("x0"), y = meta:get_int("y0"), z = meta:get_int("z0")})
			local pos2 = vector.add(pos, {x = meta:get_int("x2"), y = meta:get_int("y2"), z = meta:get_int("z2")})

			local r = meta:get_int("r") or 0
			local NOT = meta:get_int("NOT")
			local mode = meta:get_string("mode")
			local node = meta:get_string("node")
			local op = meta:get_string("op")

			local trigger = false
			local detected_obj = ""

			if mode == "node" then
				local tnode = minetest.get_node(pos1).name -- read node at source position
				detected_obj = tnode

				if node ~= "" and string.find(tnode, "default:chest") then -- if source is chest, look inside chest for items
					local cmeta = minetest.get_meta(pos1)
					local inv = cmeta:get_inventory()
					local stack = ItemStack(node)
					if inv:contains_item("main", stack) then trigger = true end
				else -- source not a chest
					if (node == "" and tnode ~= "air") or node == tnode then trigger = true end
					if r > 0 and node ~= "" then
						local found_node = minetest.find_node_near(pos1, r, {node})
						if node ~= "" and found_node then trigger = true end
					end
				end

				-- operation: AND, OR... look at other source position too
				if op ~= "" then
					local trigger1 = false
					local pos11 = vector.add(pos, {x = meta:get_int("x1"), y = meta:get_int("y1"), z = meta:get_int("z1")})
					tnode = minetest.get_node(pos11).name -- read node at source position

					if node ~= "" and string.find(tnode, "default:chest") then -- it source is chest, look inside chest for items
						local cmeta = minetest.get_meta(pos11)
						local inv = cmeta:get_inventory()
						local stack = ItemStack(node)
						if inv:contains_item("main", stack) then trigger1 = true end
					else -- source not a chest
						if (node == "" and tnode ~= "air") or node == tnode then trigger1 = true end
						if r > 0 and node ~= "" then
							local found_node = minetest.find_node_near(pos1, r, {node})
							if node ~= "" and found_node then trigger1 = true end
						end
					end
					if op == "AND" then
						trigger = trigger and trigger1
					elseif op == "OR" then
						trigger = trigger or trigger1
					end
				end

			elseif mode == "inventory" then
				local cmeta = minetest.get_meta(pos1)
				local inv = cmeta:get_inventory()

				local inv1m = meta:get_string("inv1")

				if node == "" then -- if there is item report name and trigger
					if inv:is_empty(inv1m) then
						trigger = false
					else -- nonempty
						trigger = true
						local size = inv:get_size(inv1m)
						for i = 1, size do -- find item to move in inventory
							local stack = inv:get_stack(inv1m, i)
							if not stack:is_empty() then detected_obj = stack:to_string() break end
						end
					end
				else -- node name was set
					local stack = ItemStack(node)
					if inv:contains_item(inv1m, stack) then trigger = true end
				end
			elseif mode == "infotext" then
				local cmeta = minetest.get_meta(pos1)
				detected_obj = cmeta:get_string("infotext")
				if detected_obj == node or node == "" then trigger = true end
			elseif mode == "light" then
				detected_obj = minetest.get_node_light(pos1) or 0
				if detected_obj >= (tonumber(node) or 0) or node == "" then trigger = true end
			else -- players/objects
				local objects = minetest.get_objects_inside_radius(pos1, r)
				local player_near = false
				for _, obj in pairs(objects) do
					if mode == "player" then
						if obj:is_player() then
							player_near = true
							detected_obj = obj:get_player_name()
							if node == "" or detected_obj == node then
								trigger = true break
							end
						end
					elseif mode == "object" and not obj:is_player() then
						if obj:get_luaentity() then
							detected_obj = obj:get_luaentity().itemstring or ""
							if detected_obj == "" then
								detected_obj = obj:get_luaentity().name or ""
							end

							if detected_obj == node then trigger = true break end
						end
						if node == "" then trigger = true break end
					end
				end

				if node ~= "" and NOT == -1 and not trigger and not player_near and mode == "player" then
					trigger = true
				end -- name specified, but noone around and negation -> 0

			end

			-- negation and output filtering
			local state = meta:get_int("state")

			if NOT == 1 then -- just go on normally
				-- -2: only false, -1: NOT, 0: no signal, 1: normal signal: 2: only true
			elseif NOT == -1 then trigger = not trigger -- NEGATION
			elseif NOT == -2 and trigger then return -- ONLY FALSE
			elseif NOT == 0 then return -- do nothing
			elseif NOT == 2 and not trigger then return -- ONLY TRUE
			elseif NOT == 3 and ((trigger and state == 1) or (not trigger and state == 0)) then
				return -- no change of state
			end

			local nstate
			if trigger then nstate = 1 else nstate = 0 end -- next detector output state
			if nstate ~= state then meta:set_int("state", nstate) end -- update state if changed

			node = minetest.get_node(pos2); if not node.name then return end -- error
			local table = minetest.registered_nodes[node.name]
			if not table then return end -- error
			if not table.effector then return end -- error
			local effector = table.effector

			if trigger then -- activate target node if succesful
				meta:set_string("infotext", "Detector: On")
				if not effector.action_on then return end
				if NOT == 4 then -- set detected object name as target text (target must be keypad, if not changes infotext)
					if minetest.get_node(pos2).name == "basic_machines:keypad" then
						detected_obj = detected_obj or ""
						local tmeta = minetest.get_meta(pos2)
						tmeta:set_string("text", detected_obj)
					end
				end
				effector.action_on(pos2, node, ttl - 1) -- run
			else
				meta:set_string("infotext", "Detector: Off")
				if not effector.action_off then return end
				effector.action_off(pos2, node, ttl - 1) -- run
			end
		end
	}
})

minetest.register_chatcommand("clockgen", { -- test: toggle machine running with clockgen/keypad repeats, useful for debugging
-- i.e. seeing how machines running affect server performance
	description = "Toggle clock generator/keypad repeats",
	privs = {privs = true},
	func = function(name, param)
		if basic_machines.clockgen == 0 then basic_machines.clockgen = 1 else basic_machines.clockgen = 0 end
		minetest.chat_send_player(name, "clockgen set to "..basic_machines.clockgen)
	end
})

-- CLOCK GENERATOR : periodically activates machine on top of it
minetest.register_abm({
	label = "Clock Generator activation",
	nodenames = {"basic_machines:clockgen"},
	neighbors = {},
	interval = machines_timer,
	chance = 1,

	action = function(pos, node, active_object_count, active_object_count_wider)
		if basic_machines.clockgen == 0 then return end
		local meta = minetest.get_meta(pos)
		local machines = meta:get_int("machines")
		if machines ~= 1 then -- no machines privilege
			if not minetest.get_player_by_name(meta:get_string("owner")) then -- owner not online
				return
			end
		end

		pos.y = pos.y + 1
		node = minetest.get_node(pos); if not node.name or node.name == "air" then return end
		local table = minetest.registered_nodes[node.name]
		if table and table.effector then -- check if all elements exist, safe cause it checks from left to right
		else return end
		local effector = table.effector
		if effector.action_on then
			effector.action_on(pos, node, machines_TTL)
		end
	end
})

minetest.register_node("basic_machines:clockgen", {
	description = "Clock Generator - use sparingly, continually activates top block",
	tiles = {"basic_machine_clock_generator.png"},
	groups = {cracky = 3},
	sounds = default.node_sound_wood_defaults(),
	after_place_node = function(pos, placer)
		local name = placer:get_player_name()
		if minetest.find_node_near(pos, 15, {"basic_machines:clockgen"}) then
			minetest.set_node(pos, {name = "air"})
			minetest.add_item(pos, "basic_machines:clockgen")
			minetest.chat_send_player(name, "Clock Generator: Interference from nearby clock generator detected.")
			return
		end

		local meta = minetest.get_meta(pos)
		local privs = minetest.get_player_privs(name)
		if privs.machines then meta:set_int("machines", 1) end

		meta:set_string("owner", name)
		meta:set_string("infotext", "Clock Generator (owned by "..name.."): Place machine to be activated on top")
	end
})


-- DISTRIBUTOR --
local get_distributor_form = function(pos, name)
	if name == "" then return end
	local meta = minetest.get_meta(pos)
	local privs = minetest.get_player_privs(name)
	local cant_build = minetest.is_protected(pos, name)
	-- meta:get_string("owner") ~= name and
	if not privs.privs and cant_build then
		return
	end

	local p = {}; local active = {}
	local n = meta:get_int("n")
	local delay = meta:get_float("delay")
	for i = 1, n do
		p[i] = {x = meta:get_int("x"..i), y = meta:get_int("y"..i), z = meta:get_int("z"..i)}
		active[i] = meta:get_int("active"..i)
	end

	local form =
		"size[7,"..(0.75 + n * 0.75).."]label[0,-0.25;"..minetest.colorize("lawngreen", "Target: x y z, Mode: -2=only OFF, -1=NOT input, 0/1=input, 2=only ON").."]"
	for i = 1, n do
		local y1, y2 = 0.5 + (i - 1) * 0.75, 0.25 + (i - 1) * 0.75
		form = form..(
			"field[0.25,"..y1..";1,1;x"..i..";;"..p[i].x.."]field[1.25,"..y1..";1,1;y"..i..";;"..p[i].y.."]field[2.25,"..y1..";1,1;z"..i..";;"..p[i].z.."]field[ 3.25,"..y1..";1,1;active"..i..";;"..active[i]..
			"]button[4,"..y2..";1.5,1;SHOW"..i..";SHOW "..i.."]button_exit[5.25,"..y2..";1,1;SET"..i..";SET]button[6.25,"..y2..";1,1;X"..i..";X]")
	end

	local y = 0.25 + n * 0.75
	return form..(
		"label[0.25,"..(0.4 + n * 0.75)..";"..minetest.colorize("lawngreen", "Delay").."]field[1.25,"..(0.5 + n * 0.75)..";1,1;delay;;"..delay..
		"]button_exit[2.98,"..y..";1,1;OK;OK]button[4.25,"..y..";1,1;ADD;ADD]button[6.25,"..y..";1,1;help;help]")
end

minetest.register_node("basic_machines:distributor", {
	description = "Distributor - can forward signal up to 16 different targets",
	tiles = {"distributor.png"},
	groups = {cracky = 3},
	sounds = default.node_sound_wood_defaults(),
	after_place_node = function(pos, placer)
		local meta = minetest.get_meta(pos)
		local name = placer:get_player_name()
		meta:set_string("infotext", "Distributor. Right click/punch to set it up.")
		meta:set_string("owner", name); meta:set_int("public", 0)
		for i = 1, 10 do
			meta:set_int("x"..i, 0); meta:set_int("y"..i, 1); meta:set_int("z"..i, 0); meta:set_int("active"..i, 1) -- target i
		end
		meta:set_int("n", 2) -- how many targets initially
		meta:set_float("delay", 0) -- delay when transmitting signal

		meta:set_int("public", 0) -- can other ppl set it up?
		punchset[name] = {node = "", state = 0}
	end,

	effector = {
		action_on = function(pos, node, ttl)
			if type(ttl) ~= "number" then ttl = 1 end
			if not (ttl > 0) then return end
			local meta = minetest.get_meta(pos)

			local t0 = meta:get_int("t")
			local t1 = minetest.get_gametime()
			local T = meta:get_int("T") -- temperature

			if t0 > t1 - machines_minstep then -- activated before natural time
				T = T + 1
			else
				if T > 0 then
					T = T - 1
					if t1 - t0 > 5 then T = 0 end -- reset temperature if more than 5s elapsed since last punch
				end

			end
			meta:set_int("T", T)
			meta:set_int("t", t1) -- update last activation time

			if T > 2 then -- overheat
				minetest.sound_play("default_cool_lava", {pos = pos, max_hear_distance = 16, gain = 0.25})
				meta:set_string("infotext", "Overheat: Temperature "..T)
				return
			end

			local delay = minetest.get_meta(pos):get_float("delay")

			local activate = function()
				local posf = {}; local active = {}
				local n = meta:get_int("n"); local delay = meta:get_float("delay")
				for i = 1, n do
					posf[i] = vector.add(pos, {x = meta:get_int("x"..i), y = meta:get_int("y"..i), z = meta:get_int("z"..i)})
					active[i] = meta:get_int("active"..i)
				end

				local table, node

				for i = 1, n do
					if active[i] ~= 0 then
						node = minetest.get_node(posf[i]); if not node.name then return end -- error
						table = minetest.registered_nodes[node.name]

						if table and table.effector then -- check if all elements exist, safe cause it checks from left to right
							-- alternative way: overkill
							-- ret = pcall(function() if not table.effector then end end) -- exception handling to determine if structure exists

							local effector = table.effector
							local active_i = active[i]
							if (active_i == 1 or active_i == 2) and effector.action_on then -- normal OR only forward input ON
								effector.action_on(posf[i], node, ttl - 1)
							elseif active_i == -1 and effector.action_off then
								effector.action_off(posf[i], node, ttl - 1)
							end
						end

					end
				end
			end
			if delay > 0 then
				minetest.after(delay, activate)
			elseif delay == 0 then
				activate()
			else -- delay < 0 - do random activation: delay = -500 means 500/1000 chance to activate
				if math.random(1000) <= -delay then
					activate()
				end
			end
		end,

		action_off = function(pos, node, ttl)
			if type(ttl) ~= "number" then ttl = 1 end
			if not (ttl > 0) then return end
			local meta = minetest.get_meta(pos)

			local t0 = meta:get_int("t")
			local t1 = minetest.get_gametime()
			local T = meta:get_int("T") -- temperature

			if t0 > t1 - machines_minstep then -- activated before natural time
				T = T + 1
			else
				if T > 0 then T = T - 1 end
			end
			meta:set_int("T", T)
			meta:set_int("t", t1) -- update last activation time

			if T > 2 then -- overheat
				minetest.sound_play("default_cool_lava", {pos = pos, max_hear_distance = 16, gain = 0.25})
				meta:set_string("infotext", "Overheat: Temperature "..T)
				return
			end
			local delay = minetest.get_meta(pos):get_float("delay")

			local activate = function()
				local posf = {}; local active = {}
				local n = meta:get_int("n")
				for i = 1, n do
					posf[i] = vector.add(pos, {x = meta:get_int("x"..i), y = meta:get_int("y"..i), z = meta:get_int("z"..i)})
					active[i] = meta:get_int("active"..i)
				end

				local node, table

				for i = 1, n do
					if active[i] ~= 0 then
						node = minetest.get_node(posf[i]); if not node.name then return end -- error
						table = minetest.registered_nodes[node.name]
						if table and table.effector then
							local effector = table.effector
							if (active[i] == 1 or active[i] == -2) and effector.action_off then -- normal OR only forward input OFF
								effector.action_off(posf[i], node, ttl - 1)
							elseif (active[i] == -1) and effector.action_on then
								effector.action_on(posf[i], node, ttl - 1)
							end
						end
					end
				end
			end

			if delay > 0 then minetest.after(delay, activate) else activate() end
		end
	},
	on_rightclick = function(pos, node, player, itemstack, pointed_thing)
		local name = player:get_player_name()
		local form = get_distributor_form(pos, name)
		if form then minetest.show_formspec(name, "basic_machines:distributor_"..minetest.pos_to_string(pos), form) end
	end
})


-- LIGHT --
minetest.register_node("basic_machines:light_off", {
	description = "Light off",
	tiles = {"light_off.png"},
	groups = {cracky = 3},
	effector = {
		action_on = function(pos, node, ttl)
			minetest.swap_node(pos,{name = "basic_machines:light_on"})
			local meta = minetest.get_meta(pos)
			local deactivate = meta:get_int("deactivate")

			if deactivate > 0 then
				-- meta:set_int("active", 0)
				minetest.after(deactivate, function()
					-- if meta:get_int("active") ~= 1 then -- was not activated again, so turn it off
						minetest.swap_node(pos, {name = "basic_machines:light_off"}) -- turn off again
						-- meta:set_int("active", 0)
					-- end
				end)
			end
		end
	}
})

minetest.register_node("basic_machines:light_on", {
	description = "Light on",
	tiles = {"light.png"},
	groups = {cracky = 3},
	light_source = default.LIGHT_MAX,
	after_place_node = function(pos, placer)
		local meta = minetest.get_meta(pos)
		local deactivate = meta:get_int("deactivate")
		meta:set_string("formspec",
			"size[2,2]field[0.25,0.5;2,1;deactivate;deactivate after;"..deactivate.."]button_exit[0,1;1,1;OK;OK]")
	end,
	on_receive_fields = function(pos, formname, fields, player)
		if minetest.is_protected(pos, player:get_player_name()) then return end
		if fields.deactivate then
			local meta = minetest.get_meta(pos)
			local deactivate = tonumber(fields.deactivate) or 0
			if deactivate < 0 or deactivate > 600 then deactivate = 0 end
			meta:set_int("deactivate", deactivate)
			meta:set_string("formspec",
				"size[2,2]field[0.25,0.5;2,1;deactivate;deactivate after;"..deactivate.."]button_exit[0,1;1,1;OK;OK]")
		end
	end,

	effector = {
		action_off = function(pos, node, ttl)
			minetest.swap_node(pos, {name = "basic_machines:light_off"})
		end,
		action_on = function(pos, node, ttl)
			local meta = minetest.get_meta(pos)
			local count = tonumber(meta:get_string("infotext")) or 0
			meta:set_string("infotext", count + 1) -- increase activate count
		end
	}
})


punchset.known_nodes = {["basic_machines:detector"] = true, ["basic_machines:keypad"] = true, ["basic_machines:mover"] = true}

-- SETUP BY PUNCHING
minetest.register_on_punchnode(function(pos, node, puncher, pointed_thing)
	local name = puncher:get_player_name(); if name == "" then return end
	if punchset[name] == nil then -- set up punchstate
		punchset[name] = {}
		punchset[name].node = ""
		punchset[name].pos1 = {x = 0, y = 0, z = 0}; punchset[name].pos2 = {x = 0, y = 0, z = 0}; punchset[name].pos = {x = 0, y = 0, z = 0}
		punchset[name].state = 0 -- 0 ready for punch, 1 ready for start position, 2 ready for end position
		return
	end

	-- check for known node names in case of first punch
	if punchset[name].state == 0 and not punchset.known_nodes[node.name] then return end
	-- from now on only punches with mover/keypad/... or setup punches

	if punchset.known_nodes[node.name] then -- check if player is suppose to be able to punch interact
		if node.name ~= "basic_machines:keypad" then -- keypad is supposed to be punch interactive!
			if minetest.is_protected(pos, name) then return end
		end
	end

	if node.name == "basic_machines:mover" then -- mover init code
		if punchset[name].state == 0 then
			-- if not puncher:get_player_control().sneak then
				-- return
			-- end
			minetest.chat_send_player(name, "MOVER: Now punch source1, source2, end position to set up mover.")
			punchset[name].node = node.name; punchset[name].pos = {x = pos.x, y = pos.y, z = pos.z}
			punchset[name].state = 1
			return
		end
	end

	if punchset[name].node == "basic_machines:mover" then -- mover code, not first punch
		if minetest.is_protected(pos, name) then
			minetest.chat_send_player(name, "MOVER: Punched position is protected. Aborting.")
			punchset[name].node = ""; punchset[name].state = 0
			return
		end

		local meta = minetest.get_meta(punchset[name].pos);	if not meta then return end
		local range = meta:get_float("upgrade") or 1; range = range * max_range

		if punchset[name].state == 1 then
			local privs = minetest.get_player_privs(name)
			if not privs.privs and (math.abs(punchset[name].pos.x - pos.x) > range or math.abs(punchset[name].pos.y - pos.y) > range or math.abs(punchset[name].pos.z - pos.z) > range) then
				minetest.chat_send_player(name, "MOVER: Punch closer to mover. Reseting.")
				punchset[name].state = 0; return
			end

			if punchset[name].pos.x == pos.x and punchset[name].pos.y == pos.y and punchset[name].pos.z == pos.z then
				minetest.chat_send_player(name, "MOVER: Punch something else. Aborting.")
				punchset[name].state = 0; return
			end

			punchset[name].pos1 = {x = pos.x, y = pos.y, z = pos.z}; punchset[name].state = 2
			machines.pos1[name] = punchset[name].pos1; machines.mark_pos1(name) -- mark position
			minetest.chat_send_player(name, "MOVER: Source1 position for mover set. Punch again to set source2 position.")
			return
		end

		if punchset[name].state == 2 then
			local privs = minetest.get_player_privs(name)
			if not privs.privs and (math.abs(punchset[name].pos.x - pos.x) > range or math.abs(punchset[name].pos.y - pos.y) > range or math.abs(punchset[name].pos.z - pos.z) > range) then
				minetest.chat_send_player(name, "MOVER: Punch closer to mover. Reseting.")
				punchset[name].state = 0; return
			end

			if punchset[name].pos.x == pos.x and punchset[name].pos.y == pos.y and punchset[name].pos.z == pos.z then
				minetest.chat_send_player(name, "MOVER: Punch something else. Aborting.")
				punchset[name].state = 0; return
			end

			punchset[name].pos11 = {x = pos.x, y = pos.y, z = pos.z}; punchset[name].state = 3
			machines.pos11[name] = {x = pos.x, y = pos.y, z = pos.z}
			machines.mark_pos11(name) -- mark pos11
			minetest.chat_send_player(name, "MOVER: Source2 position for mover set. Punch again to set target position.")
			return
		end

		if punchset[name].state == 3 then
			if punchset[name].node ~= "basic_machines:mover" then punchset[name].state = 0; return end
			local privs = minetest.get_player_privs(name)

			local elevator_mode = false
			if (punchset[name].pos.x == pos.x and punchset[name].pos.z == pos.z) or
				(punchset[name].pos.x == pos.x and punchset[name].pos.y == pos.y) or
				(punchset[name].pos.y == pos.y and punchset[name].pos.z == pos.z)
			then -- check if elevator mode
				local ecost = math.abs(punchset[name].pos.y - pos.y) + math.abs(punchset[name].pos.x - pos.x) + math.abs(punchset[name].pos.z - pos.z)
				if ecost > 3 then -- trying to make elevator?
					local meta = minetest.get_meta(punchset[name].pos)
					if meta:get_string("mode") == "object" then -- only if object mode
						-- count number of diamond blocks to determine if elevator can be set up with this height distance
						local inv = meta:get_inventory()
						local upgrade = 0
						if inv:get_stack("upgrade", 1):get_name() == "default:diamondblock" then
							upgrade = (inv:get_stack("upgrade", 1):get_count()) or 0
						end

						local requirement = math.floor(ecost / 100) + 1
						if upgrade < requirement then
							minetest.chat_send_player(name, "MOVER: Error while trying to make elevator. Need at least "..requirement.." diamond block(s) in upgrade (1 for every 100 distance).")
							punchset[name].state = 0; return
						else
							elevator_mode = true
							meta:set_int("upgrade", upgrade + 1)
							meta:set_int("elevator", 1)
							minetest.chat_send_player(name, "MOVER: Elevator setup completed, upgrade level "..upgrade)
							meta:set_string("infotext", "ELEVATOR, Activate to use.")
						end

					end

				end

			end

			if not privs.privs and not elevator_mode and (math.abs(punchset[name].pos.x - pos.x) > range or math.abs(punchset[name].pos.y - pos.y) > range or math.abs(punchset[name].pos.z - pos.z) > range) then
				minetest.chat_send_player(name, "MOVER: Punch closer to mover. Aborting.")
				punchset[name].state = 0; return
			end

			punchset[name].pos2 = {x = pos.x, y = pos.y, z = pos.z}; punchset[name].state = 0
			machines.pos2[name] = punchset[name].pos2; machines.mark_pos2(name) -- mark pos2

			minetest.chat_send_player(name, "MOVER: End position for mover set.")

			local x0 = punchset[name].pos1.x - punchset[name].pos.x
			local y0 = punchset[name].pos1.y - punchset[name].pos.y
			local z0 = punchset[name].pos1.z - punchset[name].pos.z
			local meta = minetest.get_meta(punchset[name].pos)

			local x1 = punchset[name].pos11.x - punchset[name].pos.x
			local y1 = punchset[name].pos11.y - punchset[name].pos.y
			local z1 = punchset[name].pos11.z - punchset[name].pos.z

			local x2 = punchset[name].pos2.x - punchset[name].pos.x
			local y2 = punchset[name].pos2.y - punchset[name].pos.y
			local z2 = punchset[name].pos2.z - punchset[name].pos.z

			if x0 > x1 then x0, x1 = x1, x0 end -- this ensures that x0 <= x1
			if y0 > y1 then y0, y1 = y1, y0 end
			if z0 > z1 then z0, z1 = z1, z0 end
			meta:set_int("x1", x1); meta:set_int("y1", y1); meta:set_int("z1", z1)
			meta:set_int("x0", x0); meta:set_int("y0", y0); meta:set_int("z0", z0)
			meta:set_int("x2", x2); meta:set_int("y2", y2); meta:set_int("z2", z2)

			meta:set_int("pc", 0); meta:set_int("dim", (x1 - x0 + 1) * (y1 - y0 + 1) * (z1 - z0 + 1))
			return
		end
	end

	-- KEYPAD
	if node.name == "basic_machines:keypad" then -- keypad init/usage code
		local meta = minetest.get_meta(pos)
		local tpos = {x = meta:get_int("x0"), y = meta:get_int("y0"), z = meta:get_int("z0")}
		if not vector.equals(tpos, {x = 0, y = 0, z = 0}) then -- already configured
			local tnode = minetest.get_node(vector.add(pos, tpos))
			if tnode.name == "basic_machines:mover" then meta:set_string("puncher", name) end
			check_keypad(pos, name) -- not setup, just standard operation
		else
			if minetest.is_protected(pos, name) then return minetest.chat_send_player(name, "KEYPAD: You must be able to build to set up keypad.") end
			-- if meta:get_string("owner") ~= name then minetest.chat_send_player(name, "KEYPAD: Only owner can set up keypad.") return end
			if punchset[name].state == 0 then
				minetest.chat_send_player(name, "KEYPAD: Now punch the target block.")
				punchset[name].node = node.name; punchset[name].pos = {x = pos.x, y = pos.y, z = pos.z}
				punchset[name].state = 1
				return
			end
		end
	end

	if punchset[name].node == "basic_machines:keypad" then -- keypad setup code
		if minetest.is_protected(pos, name) then
			minetest.chat_send_player(name, "KEYPAD: Punched position is protected. Aborting.")
			punchset[name].node = ""; punchset[name].state = 0
			return
		end

		if punchset[name].state == 1 then
			local meta = minetest.get_meta(punchset[name].pos)
			local x = pos.x - punchset[name].pos.x
			local y = pos.y - punchset[name].pos.y
			local z = pos.z - punchset[name].pos.z
			if math.abs(x) > max_range or math.abs(y) > max_range or math.abs(z) > max_range then
					minetest.chat_send_player(name, "KEYPAD: Punch closer to keypad. Reseting.")
					punchset[name].state = 0; return
			end

			machines.pos1[name] = pos
			machines.mark_pos1(name) -- mark pos1

			meta:set_int("x0", x); meta:set_int("y0", y); meta:set_int("z0", z)
			punchset[name].state = 0
			minetest.chat_send_player(name, "KEYPAD: Keypad target set with coordinates "..x.." "..y.." "..z)
			meta:set_string("infotext", "Punch keypad to use it.")
			return
		end
	end

	-- DETECTOR "basic_machines:detector"
	if node.name == "basic_machines:detector" then -- detector init code
		-- local meta = minetest.get_meta(pos)

		-- meta:get_string("owner")~= name
		if minetest.is_protected(pos, name) then minetest.chat_send_player(name, "DETECTOR: You must be able to build to set up detector.") return end
		if punchset[name].state == 0 then
			minetest.chat_send_player(name, "DETECTOR: Now punch the source block.")
			punchset[name].node = node.name
			punchset[name].pos = {x = pos.x, y = pos.y, z = pos.z}
			punchset[name].state = 1
			return
		end
	end

	if punchset[name].node == "basic_machines:detector" then
		if minetest.is_protected(pos, name) then
			minetest.chat_send_player(name, "DETECTOR: Punched position is protected. Aborting.")
			punchset[name].node = ""; punchset[name].state = 0
			return
		end

		if punchset[name].state == 1 then
			if math.abs(punchset[name].pos.x - pos.x) > max_range or math.abs(punchset[name].pos.y - pos.y) > max_range or math.abs(punchset[name].pos.z - pos.z) > max_range then
				minetest.chat_send_player(name, "DETECTOR: Punch closer to detector. Aborting.")
				punchset[name].state = 0; return
			end
			minetest.chat_send_player(name, "DETECTOR: Now punch the target machine.")
			punchset[name].pos1 = {x = pos.x, y = pos.y, z = pos.z}
			machines.pos1[name] = pos; machines.mark_pos1(name) -- mark pos1
			punchset[name].state = 2
			return
		end

		if punchset[name].state == 2 then
			if math.abs(punchset[name].pos.x - pos.x) > max_range or math.abs(punchset[name].pos.y - pos.y) > max_range or math.abs(punchset[name].pos.z - pos.z) > max_range then
				minetest.chat_send_player(name, "DETECTOR: Punch closer to detector. Aborting.")
				punchset[name].state = 0; return
			end

			if punchset[name].pos.x == pos.x and punchset[name].pos.y == pos.y and punchset[name].pos.z == pos.z then
				minetest.chat_send_player(name, "DETECTOR: Punch something else. Aborting.")
				punchset[name].state = 0; return
			end

			minetest.chat_send_player(name, "DETECTOR: Setup complete.")
			machines.pos2[name] = pos; machines.mark_pos2(name) -- mark pos2
			local x = punchset[name].pos1.x - punchset[name].pos.x
			local y = punchset[name].pos1.y - punchset[name].pos.y
			local z = punchset[name].pos1.z - punchset[name].pos.z
			local meta = minetest.get_meta(punchset[name].pos)
			meta:set_int("x0", x); meta:set_int("y0", y); meta:set_int("z0", z)
			x = pos.x - punchset[name].pos.x; y = pos.y - punchset[name].pos.y; z = pos.z - punchset[name].pos.z
			meta:set_int("x2", x); meta:set_int("y2", y); meta:set_int("z2", z)
			punchset[name].state = 0
			return
		end
	end

	if punchset[name].node == "basic_machines:distributor" then
		if minetest.is_protected(pos, name) then
			minetest.chat_send_player(name, "DISTRIBUTOR: Punched position is protected. Aborting.")
			punchset[name].node = ""
			punchset[name].state = 0; return
		end

		if punchset[name].state > 0 then
			if math.abs(punchset[name].pos.x - pos.x) > 2 * max_range or math.abs(punchset[name].pos.y - pos.y) > 2 * max_range or math.abs(punchset[name].pos.z - pos.z) > 2 * max_range then
				minetest.chat_send_player(name, "DISTRIBUTOR: Punch closer to distributor. Aborting.")
				punchset[name].state = 0; return
			end
			minetest.chat_send_player(name, "DISTRIBUTOR: Target set.")
			local meta = minetest.get_meta(punchset[name].pos)
			local x = pos.x - punchset[name].pos.x
			local y = pos.y - punchset[name].pos.y
			local z = pos.z - punchset[name].pos.z
			local j = punchset[name].state

			meta:set_int("x"..j, x); meta:set_int("y"..j, y); meta:set_int("z"..j, z)
			if x == 0 and y == 0 and z == 0 then meta:set_int("active"..j, 0) end
			machines.pos1[name] = pos; machines.mark_pos1(name) -- mark pos1
			punchset[name].state = 0
			return
		end
	end
end)

-- FORM PROCESSING for all machines
minetest.register_on_player_receive_fields(function(player, formname, fields)
	-- MOVER
	local fname = "basic_machines:mover_"
	if string.sub(formname, 0, string.len(fname)) == fname then
		local pos_s = string.sub(formname, string.len(fname) + 1); local pos = minetest.string_to_pos(pos_s)
		local name = player:get_player_name(); if name == "" then return end
		local meta = minetest.get_meta(pos)
		local privs = minetest.get_player_privs(name)
		if minetest.is_protected(pos, name) and not privs.privs or not fields then return end -- only builder can interact

		if fields.help == "help" then
			local text = "version "..basic_machines.version.."\nSETUP: For interactive setup "..
			"punch the mover and then punch source1, source2, target node (follow instructions). Put charged battery within distance 1 from mover. For advanced setup right click mover. Positions are defined by x y z coordinates (see top of mover for orientation). Mover itself is at coordinates 0 0 0. "..
			"\n\nMODES of operation: normal (just teleport block), dig (digs and gives you resulted node - good for harvesting farms), drop "..
			"(drops node on ground), object (teleportation of player and objects. distance between source1/2 defines teleport radius). by setting filter you can specify move time for objects or names for players. "..
			"By setting 'filter' only selected nodes are moved.\nInventory mode can exchange items between node inventories. You need to select inventory name for source/target from the dropdown list on the right and enter node to be moved into filter."..
			"\n*advanced* You can reverse start/end position by setting reverse nonzero. This is useful for placing stuff at many locations-planting. If you put reverse = 2/3 in transport mode it will disable parallel transport but will still do reverse effect with 3. If you activate mover with OFF signal it will toggle reverse."..
			"\n\n FUEL CONSUMPTION depends on blocks to be moved and distance. For example, stone or tree is harder to move than dirt, harvesting wheat is very cheap and and moving lava is very hard."..
			"\n\n UPGRADE mover by moving mese blocks in upgrade inventory. Each mese block increases mover range by 10, fuel consumption is divided by (number of mese blocks)+1 in upgrade. Max 10 blocks are used for upgrade. Dont forget to click OK to refresh after upgrade. "..
			"\n\n Activate mover by keypad/detector signal or mese signal (if mesecons mod) ."

			minetest.show_formspec(name, "basic_machines:help_mover",
				"size[6,7]textarea[0,0;6.5,8.5;help;MOVER HELP;"..text.."]")

			return
		end

		if fields.altgui then -- alternate gui without dropdown menu which causes crash for ios tablet users
			local x0, y0, z0 = tonumber(fields.x0) or 0, tonumber(fields.y0) or -1, tonumber(fields.z0) or 0
			local x1, y1, z1 = tonumber(fields.x1) or 0, tonumber(fields.y1) or -1, tonumber(fields.z1) or 0
			local x2, y2, z2 = tonumber(fields.x2) or 0, tonumber(fields.y2) or 1, tonumber(fields.z2) or 0
			local upgrade = meta:get_float("upgrade"); if upgrade > 0 then upgrade = upgrade - 1 end
			local list_name = "nodemeta:"..pos.x..','..pos.y..','..pos.z
			-- local range = meta:get_float("upgrade") or 1; range = range * max_range

			minetest.show_formspec(name, "basic_machines:mover_"..minetest.pos_to_string(pos),
				"size[8,9.5]"..
				"field[0.25,0.5;1,1;x0;source1;"..x0.."]field[1.25,0.5;1,1;y0;;"..y0.."]field[2.25,0.5;1,1;z0;;"..z0.."]"..
				"field[3.25,0.5;1.5,1;inv1;inv1;"..meta:get_string("inv1").."]"..
				"field[0.25,1.5;1,1;x1;source2;"..x1.."]field[1.25,1.5;1,1;y1;;"..y1.."]field[2.25,1.5;1,1;z1;;"..z1.."]"..
				"field[3.25,1.5;1,1;reverse;reverse;"..meta:get_int("reverse").."]"..
				"field[0.25,2.5;1,1;x2;target;"..x2.."]field[1.25,2.5;1,1;y2;;"..y2.."]field[2.25,2.5;1,1;z2;;"..z2.."]"..
				"field[3.25,2.5;1.5,1;inv2;inv2;"..meta:get_string("inv2").."]"..
				"field[0.25,3.6;3,1;mode;mode;"..meta:get_string("mode").."]"..
				"button[3,3.25;1,1;help;help] button_exit[4,3.25;1,1;OK;OK]"..
				"label[4,4;upgrade .. "..upgrade.."]"..
				"field[0.25,4.7;3,1;prefer;filter;"..meta:get_string("prefer").."]"..
				"list["..list_name..";filter;3,4.4;1,1;]"..
				"list["..list_name..";upgrade;4,4.4;1,1;]"..
				"list[current_player;main;0,5.5;8,4;]"..
				"listring["..list_name..";upgrade]"..
				"listring[current_player;main]"..
				"listring["..list_name..";filter]"..
				"listring[current_player;main]"
			)

			return
		end

		if fields.OK == "OK" then
			local x0, y0, z0 = tonumber(fields.x0) or 0, tonumber(fields.y0) or -1, tonumber(fields.z0) or 0
			local x1, y1, z1 = tonumber(fields.x1) or 0, tonumber(fields.y1) or -1, tonumber(fields.z1) or 0
			local x2, y2, z2 = tonumber(fields.x2) or 0, tonumber(fields.y2) or 1, tonumber(fields.z2) or 0

			-- did the numbers change from last time?
			if meta:get_int("x0") ~= x0 or meta:get_int("y0") ~= y0 or meta:get_int("z0") ~= z0 or
				meta:get_int("x1") ~= x1 or meta:get_int("y1") ~= y1 or meta:get_int("z1") ~= z1 or
				meta:get_int("x2") ~= x2 or meta:get_int("y2") ~= y2 or meta:get_int("z2") ~= z2
			then
				-- are new numbers inside bounds?
				if not privs.privs and (math.abs(x1) > max_range or math.abs(y1) > max_range or math.abs(z1) > max_range or math.abs(x2) > max_range or math.abs(y2) > max_range or math.abs(z2) > max_range) then
					minetest.chat_send_player(name, "MOVER: All coordinates must be between "..-max_range.." and "..max_range..". For increased range set up positions by punching"); return
				end
			end

			-- local range = meta:get_float("upgrade") or 1; range = range * max_range

			local x = x0; x0 = math.min(x, x1); x1 = math.max(x, x1)
			local y = y0; y0 = math.min(y, y1); y1 = math.max(y, y1)
			local z = z0; z0 = math.min(z, z1); z1 = math.max(z, z1)

			if minetest.is_protected(vector.add(pos, {x = x0, y = y0, z = z0}), name) then
				minetest.chat_send_player(name, "MOVER: Position is protected. Aborting.")

				return
			end

			if minetest.is_protected(vector.add(pos, {x = x1, y = y1, z = z1}), name) then
				minetest.chat_send_player(name, "MOVER: Position is protected. Aborting.")

				return
			end

			meta:set_int("x0", x0); meta:set_int("y0", y0); meta:set_int("z0", z0)
			meta:set_int("x1", x1); meta:set_int("y1", y1); meta:set_int("z1", z1)
			meta:set_int("dim", (x1 - x0 + 1) * (y1 - y0 + 1) * (z1 - z0 + 1))
			meta:set_int("x2", x2); meta:set_int("y2", y2); meta:set_int("z2", z2)

			if fields.mode then
				local mode = fields.mode
				if mode ~= meta:get_string("mode") then
					-- input validation
					if check_mover_filter(mode, fields.prefer or "", meta:get_int("reverse"), name) or check_target_chest(mode, pos, meta) then
						meta:set_string("mode", mode)
					else
						local intelligence = (mode ~= "normal" and mode ~= "dig") and "must have enough intelligence or" or "must be"
						minetest.chat_send_player(name, "MOVER: Wrong filter - "..intelligence.." name of existing minetest block")
					end
				end
			end

			-- filter
			local prefer = fields.prefer or ""
			if meta:get_string("prefer") ~= prefer then
				local mode = meta:get_string("mode")
				-- input validation
				if check_mover_filter(mode, prefer, meta:get_int("reverse"), name) or check_target_chest(mode, pos, meta) then
					meta:set_string("prefer", prefer)
				else
					local intelligence = (mode ~= "normal" and mode ~= "dig") and "must have enough intelligence or" or "must be"
					minetest.chat_send_player(name, "MOVER: Wrong filter - "..intelligence.." name of existing minetest block")
				end
			end

			if fields.reverse then
				meta:set_string("reverse", fields.reverse)
			end

			if fields.inv1 then
				meta:set_string("inv1", fields.inv1)
			end

			if fields.inv2 then
				meta:set_string("inv2", fields.inv2)
			end

			-- notification
			meta:set_string("infotext", "Mover block. Set up with source coordinates "..x0..","..y0..","..z0.." -> "..x1..","..y1..","..z1.." and target coord "..x2..","..y2..","..z2..". Put charged battery next to it and start it with keypad/mese signal.")

			if meta:get_float("fuel") < 0 then meta:set_float("fuel", 0) end -- reset block

			-- display battery
			local fpos = find_and_connect_battery(pos)

			if not fpos then
				minetest.chat_send_player(name, "MOVER: Please put battery nearby")
			else
				minetest.chat_send_player(name, "MOVER: Battery found - displaying mark 1")
				machines.pos1[name] = fpos;	machines.mark_pos1(name)
			end
		elseif fields.mode then
			local mode = fields.mode
			if not check_mover_filter(mode, meta:get_string("prefer"), meta:get_string("reverse"), name) and not check_target_chest(mode, pos, meta) then
				local intelligence = (mode ~= "normal" and mode ~= "dig") and "must have enough intelligence or" or "must be"
				minetest.chat_send_player(name, "MOVER: Wrong filter - "..intelligence.." name of existing minetest block")

				return -- input validation
			end

			meta:set_string("mode", mode)

			minetest.show_formspec(name, "basic_machines:mover_"..minetest.pos_to_string(pos),
				get_mover_form(pos, name))

			return
		end

		return
	end


	-- KEYPAD
	fname = "basic_machines:keypad_"
	if string.sub(formname, 0, string.len(fname)) == fname then
		local pos_s = string.sub(formname, string.len(fname) + 1); local pos = minetest.string_to_pos(pos_s)
		local name = player:get_player_name(); if name == "" then return end
		local meta = minetest.get_meta(pos)
		local privs = minetest.get_player_privs(name)
		if minetest.is_protected(pos, name) and not privs.privs or not fields then return end -- only builder can interact

		if fields.help then
			local text = "target : represents coordinates (x, y, z) relative to keypad. (0, 0, 0) is keypad itself, (0, 1, 0) is one node above, (0, -1, 0) one node below. X coordinate axes goes from east to west, Y from down to up, Z from south to north."..
			"\n\npassword: enter password and press OK. Password will be encrypted. Next time you use keypad you will need to enter correct password to gain access."..
				"\n\nrepeat: number to control how many times activation is repeated after initial punch"..

				"\n\ntext: if set then text on target node will be changed. In case target is detector/mover, filter settings will be changed. Can be used for special operations."..

				"\n\n1=OFF, 2=ON, 3=TOGGLE control the way how target node is activated"..

			"\n**************************************************\nusage\n"..

				"\nJust punch (left click) keypad, then the target block will be activated."..
				"\nTo set text on other nodes (text shows when you look at node) just target the node and set nonempty text. Upon activation text will be set. When target node is another keypad, its \"text\" field will be set. When targets is mover/detector, its \"filter\" field will be set. To clear \"filter\" set text to \"@\". When target is distributor, you can change i-th target of distributor to mode mode with \"i mode\""..

				"\n\nkeyboard : to use keypad as keyboard for text input write \"@\" in \"text\" field and set any password. Next time keypad is used it will work as text input device."..

				"\n\ndisplaying messages to nearby players (up to 5 blocks around keypad's target): set text to \"!text\". Upon activation player will see \"text\" in their chat."..

				"\n\nplaying sound to nearby players : set text to \"$sound_name\""..

				"\n\nadvanced: "..
				"\ntext replacement : Suppose keypad A is set with text \"@some @. text @!\" and there are blocks on top of keypad A with infotext '1' and '2'. Suppose we target B with A and activate A. Then text of keypad B will be set to \"some 1. text 2!\""..
				"\nword extraction: Suppose similiar setup but now keypad A is set with text \"%1\". Then upon activation text of keypad B will be set to 1.st word of infotext"

			minetest.show_formspec(name, "basic_machines:help_keypad",
				"size[6,7]textarea[0,0;6.5,8.5;help;KEYPAD HELP;"..minetest.formspec_escape(text).."]")

			return
		end

		if fields.OK == "OK" then
			local x0, y0, z0 = tonumber(fields.x0) or 0, tonumber(fields.y0) or 1, tonumber(fields.z0) or 0
			local pass, mode = fields.pass or "", tonumber(fields.mode) or 1

			if minetest.is_protected(vector.add(pos, {x = x0, y = y0, z = z0}), name) then
				minetest.chat_send_player(name, "KEYPAD: Position is protected. Aborting.")
				return
			end

			if not privs.privs and (math.abs(x0) > max_range or math.abs(y0) > max_range or math.abs(z0) > max_range) then
				minetest.chat_send_player(name, "KEYPAD: All coordinates must be between "..-max_range.." and "..max_range); return
			end
			meta:set_int("x0", x0); meta:set_int("y0", y0); meta:set_int("z0", z0)

			if fields.pass then
				if fields.pass ~= "" and string.len(fields.pass) <= 16 then -- dont replace password with hash which is longer - 27 chars
					pass = minetest.get_password_hash(pos.x, pass..pos.y); pass = minetest.get_password_hash(pos.y, pass..pos.z)
					meta:set_string("pass", pass)
				end
			end

			if fields.text then
				meta:set_string("text", fields.text)
				if string.find(fields.text, "!") then minetest.log("action", string.format("%s set up keypad for message display at %s", name, minetest.pos_to_string(pos))) end
			end

			meta:set_int("iter", math.min(tonumber(fields.iter) or 1, 500)); meta:set_int("mode", mode)
			meta:set_string("infotext", "Punch keypad to use it.")
			if pass ~= "" then
				if fields.text ~= "@" then
					meta:set_string("infotext", meta:get_string("infotext")..". Password protected.")
				else
					meta:set_string("infotext", "Punch keyboard to use it.")
				end
			end

		end

		return
	end

	fname = "basic_machines:check_keypad_"
	if string.sub(formname, 0, string.len(fname)) == fname then
		local pos_s = string.sub(formname, string.len(fname) + 1); local pos = minetest.string_to_pos(pos_s)
		local name = player:get_player_name(); if name == "" then return end
		local meta = minetest.get_meta(pos)

		if fields.OK == "OK" then
			local pass
			pass = fields.pass or ""

			if meta:get_string("text") == "@" then -- keyboard mode
				meta:set_string("input", pass)
				meta:set_int("count", 1)
				use_keypad(pos, machines_TTL, 0)
				return
			end

			pass = minetest.get_password_hash(pos.x, pass..pos.y); pass = minetest.get_password_hash(pos.y, pass..pos.z)

			if pass ~= meta:get_string("pass") then
				minetest.chat_send_player(name, "ACCESS DENIED. WRONG PASSWORD.")
				return
			end
			minetest.chat_send_player(name, "ACCESS GRANTED.")

			if meta:get_int("count") <= 0 then -- only accept new operation requests if idle
				meta:set_int("count", meta:get_int("iter"))
				meta:set_int("active_repeats", 0)
				use_keypad(pos, machines_TTL, 0)
			else
				meta:set_int("count", 0)
				meta:set_string("infotext", "Operation aborted by user. Punch to activate.") -- reset
			end

			return
		end
	end


	-- DETECTOR
	fname = "basic_machines:detector_"
	if string.sub(formname, 0, string.len(fname)) == fname then
		local pos_s = string.sub(formname, string.len(fname) + 1); local pos = minetest.string_to_pos(pos_s)
		local name = player:get_player_name(); if name == "" then return end
		local meta = minetest.get_meta(pos)
		local privs = minetest.get_player_privs(name)
		if (minetest.is_protected(pos, name) and not privs.privs) or not fields then return end -- only builder

		if fields.help == "help" then
			local text = "SETUP: right click or punch and follow chat instructions. With detector you can detect nodes, objects, players, or items inside inventories."..
			"If detector activates it will trigger machine at target position.\n\nThere are 4 modes of operation - node/player/object/inventory detection. Inside node/player/object "..
			"write node/player/object name. If you detect players/objects you can specify range of detection. If you want detector to activate target precisely when its not triggered set NOT to 1\n\n"..
			"For example, to detect empty space write air, to detect tree write default:tree, to detect ripe wheat write farming:wheat_8, for flowing water write default:water_flowing ... "..
			"If source position is chest it will look into it and check if there are items inside. If mode is inventory it will check for items in specified inventory of source node."..
			"\n\nADVANCED: you can select second source and then select AND/OR from the right top dropdown list to do logical operations. You can also filter output signal:\n -2=only OFF, -1=NOT, 0/1=normal, 2=only ON, 3 only if changed"..
			" 4 = if target keypad set its text to detected object name"

			minetest.show_formspec(name, "basic_machines:help_detector",
				"size[5.5,5.5]textarea[0,0;6,7;help;DETECTOR HELP;"..text.."]")

			return
		end

		if fields.OK == "OK" then
			local x0, y0, z0 = tonumber(fields.x0) or 0, tonumber(fields.y0) or 0, tonumber(fields.z0) or 0
			local x1, y1, z1 = tonumber(fields.x1) or 0, tonumber(fields.y1) or 0, tonumber(fields.z1) or 0
			local x2, y2, z2 = tonumber(fields.x2) or 0, tonumber(fields.y2) or 0, tonumber(fields.z2) or 0

			if minetest.is_protected(vector.add(pos, {x = x0, y = y0, z = z0}), name) then
				minetest.chat_send_player(name, "DETECTOR: Position is protected. Aborting.")

				return
			end

			if minetest.is_protected(vector.add(pos, {x = x2, y = y2, z = z2}), name) then
				minetest.chat_send_player(name, "DETECTOR: Position is protected. Aborting.")

				return
			end

			if not privs.privs and (math.abs(x0) > max_range or math.abs(y0) > max_range or math.abs(z0) > max_range or math.abs(x1) > max_range or math.abs(y1) > max_range or math.abs(z1) > max_range) then
				minetest.chat_send_player(name, "DETECTOR: All coordinates must be between "..-max_range.." and "..max_range); return
			end

			if fields.inv1 then
				meta:set_string("inv1", fields.inv1)
			end

			meta:set_int("x0", x0); meta:set_int("y0", y0); meta:set_int("z0", z0)
			meta:set_int("x1", x1); meta:set_int("y1", y1); meta:set_int("z1", z1)
			meta:set_int("x2", x2); meta:set_int("y2", y2); meta:set_int("z2", z2)

			meta:set_int("r", math.min((tonumber(fields.r) or 1), 10))
			meta:set_int("NOT", tonumber(fields.NOT) or 0)
			meta:set_string("node", fields.node or "")
			meta:set_string("mode", fields.mode or "node")
			meta:set_string("op", fields.op or "")
		end

		return
	end


	-- DISTRIBUTOR
	fname = "basic_machines:distributor_"
	if string.sub(formname, 0, string.len(fname)) == fname then
		local pos_s = string.sub(formname, string.len(fname) + 1); local pos = minetest.string_to_pos(pos_s)
		local name = player:get_player_name(); if name == "" then return end
		local meta = minetest.get_meta(pos)
		local privs = minetest.get_player_privs(name)
		if (minetest.is_protected(pos, name) and not privs.privs) or not fields then return end -- only builder
		-- minetest.chat_send_all("formname "..formname.." fields "..dump(fields))

		if fields.OK == "OK" then
			local posf = {}; local active = {}
			local n = meta:get_int("n")
			for i = 1, n do
				posf[i] = {
					x = tonumber(fields["x"..i]) or meta:get_int("x"..i),
					y = tonumber(fields["y"..i]) or meta:get_int("y"..i),
					z = tonumber(fields["z"..i]) or meta:get_int("z"..i)
				}
				active[i] = tonumber(fields["active"..i]) or 0

				if (not (privs.privs) and math.abs(posf[i].x) > 2 * max_range or math.abs(posf[i].y) > max_range or math.abs(posf[i].z) > 2 * max_range) then
					minetest.chat_send_player(name, "DISTRIBUTOR: All coordinates must be between "..-2 * max_range.." and "..2 * max_range)

					return
				end

				meta:set_int("x"..i, posf[i].x); meta:set_int("y"..i, posf[i].y); meta:set_int("z"..i, posf[i].z)
				if vector.equals(posf[i], {x = 0, y = 0, z = 0}) then
					meta:set_int("active"..i, 0); -- no point in activating itself
				else
					meta:set_int("active"..i, active[i])
				end
				if fields.delay then
					meta:set_float("delay", tonumber(fields.delay) or 0)
				end
			end
		end

		if fields["ADD"] then
			local n = meta:get_int("n")
			if n < 16 then meta:set_int("n", n + 1) end -- max 16 outputs

			minetest.show_formspec(name, "basic_machines:distributor_"..minetest.pos_to_string(pos),
				get_distributor_form(pos, name))

			return
		end

		-- SHOWING TARGET
		local j = -1; local n = meta:get_int("n")
		for i = 1, n do if fields["SHOW"..i] then j = i end end
		-- show j - th point
		if j > 0 then
			local posf = {
				x = meta:get_int("x"..j) or 0,
				y = meta:get_int("y"..j) or 0,
				z = meta:get_int("z"..j) or 0
			}
			machines.pos1[name] = vector.add(pos, posf)
			machines.mark_pos1(name)

			return
		end

		-- SETUP TARGET
		j = -1
		for i = 1, n do if fields["SET"..i] then j = i end end
		-- set up j - th point
		if j > 0 then
			punchset[name].node = "basic_machines:distributor"
			punchset[name].state = j
			punchset[name].pos = pos
			minetest.chat_send_player(name, "DISTRIBUTOR: Punch the position to set target "..j)

			return
		end

		-- REMOVE TARGET
		if n > 0 then
			j = -1
			for i = 1, n do if fields["X"..i] then j = i end end
			-- remove j - th point
			if j > 0 then
				for i = j, n - 1 do
					meta:set_int("x"..i, meta:get_int("x"..(i + 1)))
					meta:set_int("y"..i, meta:get_int("y"..(i + 1)))
					meta:set_int("z"..i, meta:get_int("z"..(i + 1)))
					meta:set_int("active"..i, meta:get_int("active"..(i + 1)))
				end

				meta:set_int("n", n - 1)

				minetest.show_formspec(name, "basic_machines:distributor_"..minetest.pos_to_string(pos),
					get_distributor_form(pos, name))

				return
			end
		end

		if fields.help == "help" then
			local text = "SETUP: to select target nodes for activation click SET then click target node.\n"..
			"You can add more targets with ADD. To see where target node is click SHOW button next to it.\n\n"..
			"4 numbers in each row represent (from left to right) : first 3 numbers are target coordinates x y z,\n"..
			"last number (MODE) controls how signal is passed to target. For example, to only pass OFF signal use -2,\n"..
			"to only pass ON use 2, -1 negates the signal, 1 = pass original signal, 0 blocks signal\n"..
			"delay option adds delay to activations, in seconds. With negative delay activation is randomized with probability -delay/1000.\n"..
			"ADVANCED: you can use distributor as an event handler - it listens to events like interact attempts and chat around distributor.\n"..
			"First you need to place distributor at position (x, y, z) in world, such that the coordinates are of the form (20*i, 20*j+1, 20*k) for\n"..
			"some integers i, j, k. Then you need to configure first row of numbers in distributor:\n"..
			"by putting 0 as MODE it will start to listen. First number x = 0/1 controls if node listens to failed interact attempts around it, second\n"..
			"number y = -1/0/1 controls listening to chat (-1 additionaly mutes chat)"

			minetest.show_formspec(name, "basic_machines:help_distributor",
				"size[5.5,5.5]textarea[0,0;6,7;help;DISTRIBUTOR HELP;"..text.."]")

			return
		end

	end
end)

--[[
-- CRAFTS --

minetest.register_craft({
	output = "basic_machines:keypad",
	recipe = {
		{"default:stick"},
		{"default:wood"}
	}
})

minetest.register_craft({
	output = "basic_machines:mover",
	recipe = {
		{"default:mese_crystal", "default:mese_crystal", "default:mese_crystal"},
		{"default:mese_crystal", "default:mese_crystal", "default:mese_crystal"},
		{"default:stone", "basic_machines:keypad", "default:stone"}
	}
})

minetest.register_craft({
	output = "basic_machines:detector",
	recipe = {
		{"default:mese_crystal", "default:mese_crystal"},
		{"default:mese_crystal", "default:mese_crystal"},
		{"basic_machines:keypad", ""}
	}
})

minetest.register_craft({
	output = "basic_machines:light_on",
	recipe = {
		{"default:torch", "default:torch"},
		{"default:torch", "default:torch"}
	}
})

minetest.register_craft({
	output = "basic_machines:distributor",
	recipe = {
		{"default:steel_ingot"},
		{"default:mese_crystal"},
		{"basic_machines:keypad"}
	}
})

minetest.register_craft({
	output = "basic_machines:clockgen",
	recipe = {
		{"default:diamondblock"},
		{"basic_machines:keypad"}
	}
})
--]]