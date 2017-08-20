minetest.register_entity("00_bt_statue:statue", {
	hp_min = 1000,
	hp_max = 1000,
	physical = false,
	visual = "mesh",
	mesh = "3d_armor_character.b3d",
	on_punch = function(self, puncher, time_from_last_punch, tool_capabilities, dir)
		self.object:set_hp(1000)
	end
})

minetest.register_node("00_bt_statue:pedestal", {
	description = "Nyan Cat",
	tiles = {"nyancat_side.png", "nyancat_side.png", "nyancat_side.png",
		"nyancat_side.png", "nyancat_back.png", "nyancat_front.png"},
	paramtype = "light",
	light_source = default.LIGHT_MAX,
	groups = {cracky = 2},
	is_ground_content = false,
	after_place_node = function(pos, placer, itemstack, pointed_thing)
		local obj = minetest.add_entity( {x = pos.x, y = pos.y + 7.65, z = pos.z}, "00_bt_statue:statue")
		if obj then
			default.player_set_model(obj, "3d_armor_character.b3d")
			local name = placer:get_player_name()
			default.player_set_textures(obj, {
				armor.textures[name].skin,
				armor.textures[name].armor..(playerOverlayTextures[name] or ""),
				armor.textures[name].wielditem,
			})
			obj:set_properties({visual_size = { x = 8, y = 8 }})
			obj:set_armor_groups({immortal=65535})
		end
	end,
})
