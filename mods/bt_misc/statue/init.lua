minetest.register_entity("statue:statue", {
	hp_min = 1000,
	hp_max = 1000,
	physical = false,
	visual = "mesh",
	mesh = "3d_armor_character.b3d",
	on_punch = function(self, puncher, time_from_last_punch, tool_capabilities, dir)
		return true
	end
})

minetest.register_node("statue:pedestal", {
	description = "Statue",
	tiles = {"nyancat_side.png", "nyancat_side.png", "nyancat_side.png",
		"nyancat_side.png", "nyancat_back.png", "nyancat_front.png"},
	paramtype = "light",
	light_source = default.LIGHT_MAX,
	groups = {cracky = 2, oddly_breakable_by_hand = 1},
	is_ground_content = false,
	after_place_node = function(pos, placer, itemstack, pointed_thing)
		local obj = minetest.add_entity({x = pos.x, y = pos.y + 7.65, z = pos.z}, "statue:statue")
		if obj then
			player_api.set_model(obj, "3d_armor_character.b3d")
			local name = placer:get_player_name()
			player_api.set_textures(obj, {
				armor.textures[name].skin,
				armor.textures[name].armor .. (playerOverlayTextures[name] or ""),
				armor.textures[name].wielditem
			})
			obj:set_properties({visual_size = {x = 8, y = 8}})
			obj:set_armor_groups({immortal = 1})
		end
	end,
	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		pos.y = pos.y + 7.65
		for _, obj in ipairs(minetest.get_objects_inside_radius(pos, 0.1)) do
			local ent = obj:get_luaentity()
			if ent and ent.name == "statue:statue" then
				obj:remove()
			end
		end
	end,
	on_blast = function() end
})