local S = vines.translator

minetest.register_craft({
	output = 'vines:rope_block',
	recipe = {
		{'', 'group:wood', ''},
		{'', 'group:vines', ''},
		{'', 'group:vines', ''}
	}
})

minetest.register_craft({
	output = 'vines:shears',
	recipe = {
		{'', 'default:steel_ingot', ''},
		{'group:stick', 'group:wood', 'default:steel_ingot'},
		{'', '', 'group:stick'}
	}
})

minetest.register_craftitem("vines:vines", {
	description = S("Vines"),
	inventory_image = "vines_item.png",
	groups = {vines = 1, flammable = 2}
})