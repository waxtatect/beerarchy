-- rnd 2016:

-- CONSTRUCTOR machine: used to make all other basic_machines

basic_machines.electronics_craft_recipes = {

["control_logic_unit"] = {
	item = "basic_machines:control_logic_unit",
	description = "Chip to control digtrons",
	craft = { "default:diamond", "default:mese_crystal", "default:gold_ingot", "default:copper_ingot", "default:silver_sand"},
	tex = "basic_machines_control_logic_unit"
},

["precision_component"] = {
	item = "fun_tools:precision_component",
	description = "Precision component",
	craft = { "basic_machines:control_logic_unit", "default:steel_ingot", "default:diamond", "default:copper_ingot"},
	tex = "fun_tools_component"
},

["internal_combustion_engine"] = {
	item = "fun_tools:internal_combustion_engine",
	description = "Internal Combustion Engine",
	craft = { "basic_machines:control_logic_unit", "fun_tools:precision_component 4", "default:steelblock"},
	tex = "fun_tools_engine"
},

["gps"] = {
	item = "gps:gps",
	description = "GPS",
	craft = { "basic_machines:control_logic_unit 2", "default:steel_ingot 4", "default:stick"},
	tex = "gps_item"
},

["flare_gun"] = {
	item = "fun_tools:flare_gun",
	description = "Flare gun",
	craft = { "default:mese_crystal", "tnt:gunpowder", "default:steel_ingot 3", "default:stick"},
	tex = "fun_tools_flare_gun"
},

["chainsaw"] = {
	item = "fun_tools:chainsaw",
	description = "Chainsaw",
	craft = { "basic_machines:control_logic_unit", "fun_tools:precision_component 2", "fun_tools:internal_combustion_engine", "default:steel_ingot 3", "default:coalblock"},
	tex = "fun_tools_chainsaw"
},

["jackhammer"] = {
	item = "fun_tools:jackhammer",
	description = "Jackhammer",
	craft = { "basic_machines:control_logic_unit", "fun_tools:precision_component 2", "fun_tools:internal_combustion_engine", "default:diamond", "default:coalblock"},
	tex = "fun_tools_jackhammer"
},

["elevator"] = {
	item = "travelnet:elevator",
	description = "Elevator",
	craft = { "basic_machines:control_logic_unit 2", "fun_tools:precision_component 2", "fun_tools:internal_combustion_engine", "default:glass 2", "default:steel_ingot 6"},
	tex = "travelnet_elevator_inv"
},

["travelnet"] = {
	item = "travelnet:travelnet",
	description = "Travelnet",
	craft = { "basic_machines:control_logic_unit 4", "fun_tools:precision_component 2", "default:mese", "default:glass 6", "default:steel_ingot 2"},
	tex = "travelnet_inv"
}

}

basic_machines.electronics_craft_recipe_order = { -- order in which nodes appear
	"control_logic_unit",
	"precision_component",
	"internal_combustion_engine",
	"gps",
	"flare_gun",
	"chainsaw",
	"jackhammer",
	"elevator",
	"travelnet"
}


local constructor_process = function(pos, player)

			local meta = minetest.get_meta(pos);
			local craft = basic_machines.electronics_craft_recipes[meta:get_string("craft")];
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
					ranking.increase_rank(player, "intelligence", 2)
				end
			else
				local owner = minetest.get_player_by_name(meta:get_string("owner"))
				if owner then
					ranking.increase_rank(player, "intelligence", 2)
				end
			end

end

local constructor_update_meta = function(pos)
		local meta = minetest.get_meta(pos);
		local list_name = "nodemeta:"..pos.x..','..pos.y..','..pos.z
		local craft = meta:get_string("craft");

		local description = basic_machines.electronics_craft_recipes[craft];
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
		for _,v in ipairs(basic_machines.electronics_craft_recipe_order) do
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


minetest.register_node("basic_machines:electronics_constructor", {
	description = "Electronics Constructor: used to make electronics and small electronic devices",
	tiles = {"grinder.png","default_furnace_top.png", "electronics_constructor.png","electronics_constructor.png","electronics_constructor.png","electronics_constructor.png"},
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
				for _,v in ipairs(basic_machines.electronics_craft_recipe_order) do
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
	output = "basic_machines:electronics_constructor",
	recipe = {
		{"default:silver_sandstone_block","default:mese","default:silver_sandstone_block"},
		{"default:mese","default:diamondblock","default:mese"},
		{"default:silver_sandstone_block","default:mese","default:silver_sandstone_block"},
	}
})
