-- rnd 2016:

-- CONSTRUCTOR machine: used to make all other basic_machines

basic_machines.digtron_craft_recipes = {

-- Protectors

--[[["protection_logo"] = {
	item = "protector:protect2",
	description = "Protector force field",
	craft = { "basic_machines:control_logic_unit 4", "underworlds:hot_stone 4", "moreores:mithril_block 4" },
	tex = "protector_logo"
},

["protected_chest"] = {
	item = "protector:chest",
	description = "Force field protected chest",
	craft = { "basic_machines:control_logic_unit", "underworlds:hot_stone", "moreores:mithril_block", "default:wood 8" },
	tex = "default_protected_chest_front"
},

["protected_door_wood"] = {
	item = "protector:door_wood",
	description = "Force field protected wooden door",
	craft = { "basic_machines:control_logic_unit", "underworlds:hot_stone", "moreores:mithril_block", "default:wood 6" },
	tex = "doors_protected_wood"
},
]]--

-- Advanced devices

["rapid_bow"] = {
	item = "throwing:bow_rapid",
	description = "MTG9000 rapid fire heavy crossbow Mk II",
	craft = { "basic_machines:control_logic_unit 4", "underworlds:hot_stone 4", "default:mese 4", "moreores:mithril_block 4", "integral:moon_juice 8" },
	tex = "throwing_bow_rapid"
},

-- Digtron

["digtron_core"] = {
	item = "digtron:digtron_core",
	description = "Core unit for building digtrons",
	craft = { "basic_machines:control_logic_unit 4", "underworlds:hot_stone 4", "default:mese" },
	tex = "digtron_core"
},

["controller"] = {
	item = "digtron:controller",
	description = "Manual controller",
	craft = { "basic_machines:control_logic_unit 4", "digtron:digtron_core", "default:mese" },
	tex = "digtron_control"
},

["auto_controller"] = {
	item = "digtron:auto_controller",
	description = "Automatic controller",
	craft = { "basic_machines:control_logic_unit 8", "digtron:digtron_core 2", "basic_machines:generator", "default:mese" },
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
	craft = {"basic_machines:control_logic_unit 4", "digtron:digtron_core", "default:diamondblock 4","default:mese 4","moreores:mithril_block 4"},
	tex = "digtron_intermittent_motor"
},

["soft_digger"] = {
	item = "digtron:soft_digger",
	description = "Digs soft nodes in front of the unit",
	craft = {"basic_machines:control_logic_unit 2", "digtron:digtron_core", "default:diamondblock 2","default:mese 2","moreores:mithril_block 2"},
	tex = "digtron_motor"
},

["inventory"] = {
	item = "digtron:inventory",
	description = "Inventory module to store dug or construction materials",
	craft = { "digtron:structure", "digtron:digtron_core", "default:chest" },
	tex = "digtron_storage"
},

["fuelstore"] = {
	item = "digtron:fuelstore",
	description = "Fuel storage to power the digger heads and builders",
	craft = { "digtron:structure 2", "digtron:digtron_core", "default:chest", "default:steel_ingot 4" },
	tex = "digtron_fuelstore"
},

["combined_storage"] = {
	item = "digtron:combined_storage",
	description = "Combined storage for materials and fuel",
	craft = { "digtron:structure 4", "digtron:digtron_core", "default:chest", "default:steel_ingot 8" },
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
	craft = { "digtron:digtron_core", "moreores:mithril_ingot 4", "default:mese" },
	tex = "digtron_axel_side"
},

["empty_crate"] = {
	item = "digtron:empty_crate",
	description = "Crate in which the digtron can be stored",
	craft = {"basic_machines:control_logic_unit 8", "digtron:digtron_core", "digtron:structure", "default:steel_ingot 8"},
	tex = "digtron_crate"
},

-- Structural

["structure"] = {
	item = "digtron:structure",
	description = "Digtron structural component",
	craft = { "digtron:digtron_core", "default:steelblock 4", "default:steel_ingot 8" },
	tex = "digtron_crossbrace"
},

["panel"] = {
	item = "digtron:panel",
	description = "Digtron panel",
	craft = { "digtron:digtron_core", "default:steel_ingot 8" },
	tex = "digtron_plate"
},

["edge_panel"] = {
	item = "digtron:edge_panel",
	description = "Digtron edge panel",
	craft = { "digtron:digtron_core", "default:steel_ingot 6" },
	tex = "digtron_plate"
},

["corner_panel"] = {
	item = "digtron:corner_panel",
	description = "Digtron corner panel",
	craft = { "digtron:digtron_core", "default:steel_ingot 10" },
	tex = "digtron_plate"
},

}

basic_machines.digtron_craft_recipe_order = { -- order in which nodes appear
--	"protection_logo",
--	"protected_chest",
--	"protected_door_wood",
	"rapid_bow",
	"digtron_core",
	"controller",
	"auto_controller",
	"digtron_core",
	"controller",
	"auto_controller",
	"builder",
	"light",
	"digger",
	"soft_digger",
	"inventory",
	"fuelstore",
	"combined_storage",
	"pusher",
	"axle",
	"empty_crate",
	"structure",
	"panel",
	"edge_panel",
	"corner_panel"
}


local constructor_process = function(pos, player)

			local meta = minetest.get_meta(pos);
			local craft = basic_machines.digtron_craft_recipes[meta:get_string("craft")];
			if not craft then return end
			local item = craft.item;
			local craftlist = craft.craft;

			local inv = meta:get_inventory();
			for _,v in pairs(craftlist) do
				if not inv:contains_item("main", ItemStack(v)) then
					meta:set_string("infotext", "#CRAFTING: you need " .. v .. " to craft " .. craft.item)
					return
				end
			end

			for _,v in pairs(craftlist) do
				inv:remove_item("main", ItemStack(v));
			end
			inv:add_item("main", ItemStack(item));

			if player then
				if player:get_player_name() == meta:get_string("owner") then
					ranking.increase_rank(player, "intelligence", 10)
				end
			else
				local owner = minetest.get_player_by_name(meta:get_string("owner"))
				if owner then
					ranking.increase_rank(player, "intelligence", 10)
				end
			end

end

local constructor_update_meta = function(pos)
		local meta = minetest.get_meta(pos);
		local list_name = "nodemeta:"..pos.x..','..pos.y..','..pos.z
		local craft = meta:get_string("craft");

		local description = basic_machines.digtron_craft_recipes[craft];
		local tex;

		if description then
			tex = description.tex;
			local i = 0;
			local itex;

			local inv = meta:get_inventory(); -- set up craft list
			for _,v in pairs(description.craft) do
				i=i+1;
				inv:set_stack("recipe", i, ItemStack(v))
			end

			for j = i+1,6 do
				inv:set_stack("recipe", j, ItemStack(""))
			end

			description = description.description

		else
			description = ""
			tex = ""
		end


		local textlist = " ";

		local selected = meta:get_int("selected") or 1;
		for _,v in ipairs(basic_machines.digtron_craft_recipe_order) do
			textlist = textlist .. v .. ", ";

		end

		local form  =
			"size[8,10]"..
			"textlist[0,0;3,1.5;craft;" .. textlist .. ";" .. selected .."]"..
			"button[3.5,1;1.25,0.75;CRAFT;CRAFT]"..
			"image[3.65,0;1,1;".. tex .. ".png]"..
			"label[0,1.85;".. description .. "]"..
			"list[context;recipe;5,0;3,2;]"..
			"label[0,2.3;Put crafting materials here]"..
			"list[context;main;0,2.7;8,3;]"..
			--"list[context;dst;5,0;3,2;]"..
			"label[0,5.5;player inventory]"..
			"list[current_player;main;0,6;8,4;]"..
			"listring[context;main]"..
			"listring[current_player;main]";
		meta:set_string("formspec", form);
end


minetest.register_node("basic_machines:digtron_constructor", {
	description = "Advanced Constructor: used to make advaned devices and the digtron construction and excavation vehicles",
	tiles = {"grinder.png","default_furnace_top.png", "digtron_constructor.png","digtron_constructor.png","digtron_constructor.png","digtron_constructor.png"},
	groups = {cracky=3, mesecon_effector_on = 1},
	sounds = default.node_sound_wood_defaults(),
	after_place_node = function(pos, placer)
		local meta = minetest.get_meta(pos);
		meta:set_string("infotext", "Constructor: To operate it insert materials, select item to make and click craft button.")
		meta:set_string("owner", placer:get_player_name());
		meta:set_string("craft","keypad")
		meta:set_int("selected",1);
		local inv = meta:get_inventory();inv:set_size("main", 24);--inv:set_size("dst",6);
		inv:set_size("recipe",8);
	end,

	on_rightclick = function(pos, node, player, itemstack, pointed_thing)
		local meta = minetest.get_meta(pos);
		local privs = minetest.get_player_privs(player:get_player_name());
		if minetest.is_protected(pos, player:get_player_name()) and not privs.privs then return end -- only owner can interact with recycler
		constructor_update_meta(pos);
	end,

	allow_metadata_inventory_put = function(pos, listname, index, stack, player)
		if listname == "recipe" then return 0 end
		local meta = minetest.get_meta(pos);
		local privs = minetest.get_player_privs(player:get_player_name());
		if meta:get_string("owner")~=player:get_player_name() and not privs.privs then return 0 end
		return stack:get_count();
	end,

	allow_metadata_inventory_take = function(pos, listname, index, stack, player)
		if listname == "recipe" then return 0 end
		local privs = minetest.get_player_privs(player:get_player_name());
		if minetest.is_protected(pos, player:get_player_name()) and not privs.privs then return 0 end
		return stack:get_count();
	end,

	on_metadata_inventory_put = function(pos, listname, index, stack, player)
		if listname == "recipe" then return 0 end
		local privs = minetest.get_player_privs(player:get_player_name());
		if minetest.is_protected(pos, player:get_player_name()) and not privs.privs then return 0 end
		return stack:get_count();
	end,

	allow_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
		return 0;
	end,

	mesecons = {effector = {
		action_on = function (pos, node,ttl)
			if type(ttl)~="number" then ttl = 1 end
			if ttl<0 then return end -- machines_TTL prevents infinite recursion
			constructor_process(pos, nil);
		end
		}
	},

	on_receive_fields = function(pos, formname, fields, sender)

		if minetest.is_protected(pos, sender:get_player_name())  then return end
		local meta = minetest.get_meta(pos);

		if fields.craft then
			if string.sub(fields.craft,1,3)=="CHG" then
				local sel = tonumber(string.sub(fields.craft,5)) or 1
				meta:set_int("selected",sel);

				local i = 0;
				for _,v in ipairs(basic_machines.digtron_craft_recipe_order) do
					i=i+1;
					if i == sel then meta:set_string("craft",v); break; end
				end
			else
				return
			end
		end

		if fields.CRAFT then
			constructor_process(pos, sender);
		end

		constructor_update_meta(pos);
	end,

})


minetest.register_craft({
	output = "basic_machines:digtron_constructor",
	recipe = {
		{"basic_machines:constructor","default:mese","basic_machines:constructor"},
		{"underworlds:hot_stone","default:diamondblock","underworlds:hot_stone"},
		{"basic_machines:electronics_constructor","default:mese","basic_machines:electronics_constructor"},
	}
})
