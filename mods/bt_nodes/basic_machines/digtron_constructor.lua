-- rnd 2016:

-- CONSTRUCTOR machine: used to make all other basic_machines

basic_machines.digtron_craft_recipes = {
--[[
	-- Protectors
	["protection logo"] = {
		item = "protector:protect2",
		description = "Protector force field",
		craft = {"basic_machines:control_logic_unit 4", "underworlds:hot_stone 4", "moreores:mithril_block 4"},
		tex = "protector_logo"
	},

	["protected chest"] = {
		item = "protector:chest",
		description = "Force field protected chest",
		craft = {"basic_machines:control_logic_unit", "underworlds:hot_stone", "moreores:mithril_block", "default:wood 8"},
		tex = "default_protected_chest_front"
	},

	["protected door wood"] = {
		item = "protector:door_wood",
		description = "Force field protected wooden door",
		craft = {"basic_machines:control_logic_unit", "underworlds:hot_stone", "moreores:mithril_block", "default:wood 6"},
		tex = "doors_protected_wood"
	},
--]]
	-- Advanced devices
	["rapid bow"] = {
		item = "throwing:bow_rapid",
		description = "MTG9000 rapid fire heavy crossbow Mk II",
		craft = {"basic_machines:control_logic_unit 4", "underworlds:hot_stone 4", "default:mese 4", "moreores:mithril_block 4", "integral:moon_juice 8"},
		tex = "throwing_bow_rapid"
	},

	-- Digtron
	["digtron core"] = {
		item = "digtron:digtron_core",
		description = "Core unit for building digtrons",
		craft = {"basic_machines:control_logic_unit 4", "underworlds:hot_stone 4", "default:mese"},
		tex = "digtron_core"
	},

	["controller"] = {
		item = "digtron:controller",
		description = "Manual controller",
		craft = {"basic_machines:control_logic_unit 4", "digtron:digtron_core", "default:mese"},
		tex = "digtron_control"
	},

	["auto controller"] = {
		item = "digtron:auto_controller",
		description = "Automatic controller",
		craft = {"basic_machines:control_logic_unit 8", "digtron:digtron_core 2", "basic_machines:generator", "default:mese"},
		tex = "digtron_auto_control"
	},

	["builder"] = {
		item = "digtron:builder",
		description = "Builds node in front of the unit",
		craft = {"basic_machines:control_logic_unit 4", "digtron:digtron_core", "default:mese 4"},
		tex = "digtron_builder"
	},

	["light"] = {
		item = "digtron:light",
		description = "Light to put on digtrons",
		craft = {"basic_machines:control_logic_unit", "digtron:digtron_core", "default:torch 4"},
		tex = "digtron_light"
	},

	["digger"] = {
		item = "digtron:digger",
		description = "Digs node in front of the unit",
		craft = {"basic_machines:control_logic_unit 4", "digtron:digtron_core", "default:diamondblock 4", "default:mese 4", "moreores:mithril_block 4"},
		tex = "digtron_intermittent_motor"
	},

	["soft digger"] = {
		item = "digtron:soft_digger",
		description = "Digs soft nodes in front of the unit",
		craft = {"basic_machines:control_logic_unit 2", "digtron:digtron_core", "default:diamondblock 2", "default:mese 2", "moreores:mithril_block 2"},
		tex = "digtron_motor"
	},

	["inventory"] = {
		item = "digtron:inventory",
		description = "Inventory module to store dug or construction materials",
		craft = {"digtron:structure", "digtron:digtron_core", "default:chest"},
		tex = "digtron_storage"
	},

	["fuelstore"] = {
		item = "digtron:fuelstore",
		description = "Fuel storage to power the digger heads and builders",
		craft = {"digtron:structure 2", "digtron:digtron_core", "default:chest", "default:steel_ingot 4"},
		tex = "digtron_fuelstore"
	},

	["combined storage"] = {
		item = "digtron:combined_storage",
		description = "Combined storage for materials and fuel",
		craft = {"digtron:structure 4", "digtron:digtron_core", "default:chest", "default:steel_ingot 8"},
		tex = "digtron_combined_storage"
	},

	["pusher"] = {
		item = "digtron:pusher",
		description = "Pushes the digtron in a certain direction",
		craft = {"basic_machines:control_logic_unit 2", "digtron:digtron_core", "default:mese 2"},
		tex = "digtron_pusher"
	},

	["axle"] = {
		item = "digtron:axle",
		description = "Axle",
		craft = {"digtron:digtron_core", "moreores:mithril_ingot 4", "default:mese"},
		tex = "digtron_axel_side"
	},

	["empty crate"] = {
		item = "digtron:empty_crate",
		description = "Crate in which the digtron can be stored",
		craft = {"basic_machines:control_logic_unit 8", "digtron:digtron_core", "digtron:structure", "default:steel_ingot 8"},
		tex = "digtron_crate"
	},
	-- Structural
	["structure"] = {
		item = "digtron:structure",
		description = "Digtron structural component",
		craft = {"digtron:digtron_core", "default:steelblock 4", "default:steel_ingot 8"},
		tex = "digtron_crossbrace"
	},

	["panel"] = {
		item = "digtron:panel",
		description = "Digtron panel",
		craft = {"digtron:digtron_core", "default:steel_ingot 8"},
		tex = "digtron_plate"
	},

	["edge panel"] = {
		item = "digtron:edge_panel",
		description = "Digtron edge panel",
		craft = {"digtron:digtron_core", "default:steel_ingot 6"},
		tex = "digtron_plate"
	},

	["corner panel"] = {
		item = "digtron:corner_panel",
		description = "Digtron corner panel",
		craft = {"digtron:digtron_core", "default:steel_ingot 10"},
		tex = "digtron_plate"
	}
}

basic_machines.digtron_craft_recipe_order = { -- order in which nodes appear
--	"protection logo",
--	"protected chest",
--	"protected door wood",
	"rapid bow",
	"digtron core",
	"controller",
	"auto controller",
	"digtron core",
	"controller",
	"auto controller",
	"builder",
	"light",
	"digger",
	"soft digger",
	"inventory",
	"fuelstore",
	"combined storage",
	"pusher",
	"axle",
	"empty crate",
	"structure",
	"panel",
	"edge panel",
	"corner panel"
}

local constructor_process = function(pos, player)
	local name = player:get_player_name()
	local meta = minetest.get_meta(pos)
	local craft = basic_machines.digtron_craft_recipes[meta:get_string("craft")]
	if not craft then return end
	local item = craft.item
	local craftlist = craft.craft

	local inv = meta:get_inventory()
	if not basic_machines.creative(name) then
		for _, v in pairs(craftlist) do
			if not inv:contains_item("main", ItemStack(v)) then
				meta:set_string("infotext", "#CRAFTING: you need "..v.." to craft "..craft.item)
				return
			end
		end

		for _, v in pairs(craftlist) do
			inv:remove_item("main", ItemStack(v))
		end
	end
	inv:add_item("main", ItemStack(item))

	if player then
		if name == meta:get_string("owner") then
			ranking.increase_rank(player, "intelligence", 10)
		end
	else
		local owner = minetest.get_player_by_name(meta:get_string("owner"))
		if owner then
			ranking.increase_rank(owner, "intelligence", 10)
		end
	end
end

local constructor_update_meta = function(pos)
	local meta = minetest.get_meta(pos)
	local craft = meta:get_string("craft")

	local description = basic_machines.digtron_craft_recipes[craft]
	local tex = ""

	if description then
		tex = description.tex
		local i = 0

		local inv = meta:get_inventory() -- set up craft list
		for _, v in pairs(description.craft) do
			i = i + 1
			inv:set_stack("recipe", i, ItemStack(v))
		end

		for j = i + 1, 6 do
			inv:set_stack("recipe", j, ItemStack(""))
		end

		description = description.description
	end

	meta:set_string("formspec",
		"size[8,10]"..
		"textlist[0,0;3,1.5;craft;"..table.concat(basic_machines.digtron_craft_recipe_order, ",")..
			";"..(meta:get_int("selected") or 1).."]"..
		"button[3.5,1;1.25,0.75;CRAFT;CRAFT]"..
		"image[3.65,0;1,1;"..tex..".png]"..
		"label[0,1.85;"..(description or "").."]"..
		"list[context;recipe;5,0;3,2;]"..
		"label[0,2.3;put crafting materials here]"..
		"list[context;main;0,2.7;8,3;]"..
		-- "list[context;dst;5,0;3,2;]"..
		"label[0,5.5;player inventory]"..
		"list[current_player;main;0,6;8,4;]"..
		"listring[context;main]"..
		"listring[current_player;main]"
	)
end

minetest.register_node("basic_machines:digtron_constructor", {
	description = "Advanced Constructor: Used to make advaned devices and the digtron construction and excavation vehicles",
	tiles = {"grinder.png", "default_furnace_top.png", "digtron_constructor.png", "digtron_constructor.png", "digtron_constructor.png", "digtron_constructor.png"},
	groups = {cracky = 3},
	sounds = default.node_sound_wood_defaults(),
	after_place_node = function(pos, placer)
		local meta = minetest.get_meta(pos)
		meta:set_string("infotext", "Constructor: To operate it insert materials, select item to make and click craft button.")
		meta:set_string("owner", placer:get_player_name())
		meta:set_string("craft", "rapid bow")
		meta:set_int("selected", 1)
		local inv = meta:get_inventory(); inv:set_size("main", 24) -- inv:set_size("dst", 6)
		inv:set_size("recipe", 8)
	end,

	on_rightclick = function(pos, node, player, itemstack, pointed_thing)
		local name = player:get_player_name()
		local privs = minetest.get_player_privs(name)
		if minetest.is_protected(pos, name) and not privs.privs then return end -- only owner can interact with recycler
		constructor_update_meta(pos)
	end,

	allow_metadata_inventory_put = function(pos, listname, index, stack, player)
		if listname == "recipe" then return 0 end
		local meta = minetest.get_meta(pos)
		local name = player:get_player_name()
		local privs = minetest.get_player_privs(name)
		if meta:get_string("owner") ~= name and not privs.privs then return 0 end
		return stack:get_count()
	end,

	allow_metadata_inventory_take = function(pos, listname, index, stack, player)
		if listname == "recipe" then return 0 end
		local name = player:get_player_name()
		local privs = minetest.get_player_privs(name)
		if minetest.is_protected(pos, name) and not privs.privs then return 0 end
		return stack:get_count()
	end,

	on_metadata_inventory_put = function(pos, listname, index, stack, player)
		if listname == "recipe" then return 0 end
		local name = player:get_player_name()
		local privs = minetest.get_player_privs(name)
		if minetest.is_protected(pos, name) and not privs.privs then return 0 end
		return stack:get_count()
	end,

	allow_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
		return 0
	end,

	effector = {
		action_on = function (pos, node, ttl)
			if type(ttl) ~= "number" then ttl = 1 end
			if ttl < 0 then return end -- machines_TTL prevents infinite recursion
			constructor_process(pos, nil)
		end
	},

	on_receive_fields = function(pos, formname, fields, sender)
		if minetest.is_protected(pos, sender:get_player_name()) then return end
		local meta = minetest.get_meta(pos)

		if fields.craft then
			if string.sub(fields.craft, 1, 3) == "CHG" then
				local sel = tonumber(string.sub(fields.craft, 5)) or 1
				meta:set_int("selected", sel)

				local i = 0
				for _, v in ipairs(basic_machines.digtron_craft_recipe_order) do
					i = i + 1
					if i == sel then meta:set_string("craft", v); break end
				end
			else
				return
			end
		end

		if fields.CRAFT then
			constructor_process(pos, sender)
		end

		constructor_update_meta(pos)
	end,

	can_dig = function(pos)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()

		if not inv:is_empty("main") then return false end -- main inv must be empty to be dug

		return true
	end
})

minetest.register_craft({
	output = "basic_machines:digtron_constructor",
	recipe = {
		{"basic_machines:constructor", "default:mese", "basic_machines:constructor"},
		{"underworlds:hot_stone", "default:diamondblock", "underworlds:hot_stone"},
		{"basic_machines:electronics_constructor", "default:mese", "basic_machines:electronics_constructor"}
	}
})