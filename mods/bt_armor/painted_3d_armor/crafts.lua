--
-- Painting registration
--

painting:register_canvas("painted_3d_armor:armor_canvas_6x6", 6)
painting:register_canvas("painted_3d_armor:armor_canvas_12x12", 12)
painting:register_canvas("painted_3d_armor:armor_canvas_24x24", 24)

--
-- Crafting recipes
--

minetest.register_craft({
	output = "painted_3d_armor:armor_canvas_6x6",
	recipe = {
		{"default:paper", "default:paper", ""},
		{"default:paper", "default:paper", ""},
		{"", "default:paper", ""}
	}
})

minetest.register_craft({
	output = "painted_3d_armor:armor_canvas_12x12",
	recipe = {
		{"default:paper", "default:paper", "default:paper"},
		{"default:paper", "default:paper", "default:paper"},
		{"", "default:paper", ""}
	}
})

minetest.register_craft({
	output = "painted_3d_armor:armor_canvas_24x24",
	recipe = {
		{"default:paper", "default:paper", "default:paper"},
		{"default:paper", "default:paper", "default:paper"},
		{"", "default:paper", "default:paper"}
	}
})

if banners then
	minetest.register_craft({
		output = "painted_3d_armor:banner_armor",
		recipe = {
			{"default:paper", "default:paper", "default:paper"},
			{"default:paper", "banners:wooden_banner", "default:paper"},
			{"", "default:paper", ""}
		}
	})
--[[
	minetest.register_craft({
		output = "painted_3d_armor:image_armor",
		recipe = {
			{"default:paper", "default:paper", "default:paper"},
			{"default:paper", "default:sign_wall_wood", "default:paper"},
			{"", "default:paper", ""}
		}
	})--]]
end

--
-- Fuels
--

minetest.register_craft({
	type = "fuel",
	recipe = "painted_3d_armor:armor_canvas_6x6",
	burntime = 5
})

minetest.register_craft({
	type = "fuel",
	recipe = "painted_3d_armor:armor_canvas_12x12",
	burntime = 7
})

minetest.register_craft({
	type = "fuel",
	recipe = "painted_3d_armor:armor_canvas_24x24",
	burntime = 8
})

if banners then
	minetest.register_craft({
		type = "fuel",
		recipe = "painted_3d_armor:banner_armor",
		burntime = 36
	})

	minetest.register_craft({
		type = "fuel",
		recipe = "painted_3d_armor:image_armor",
		burntime = 16
	})
end