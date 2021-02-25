--[[
painting - in-game painting for minetest

THIS MOD CODE AND TEXTURES ARE LICENSED
			  <3 TO YOU <3
	  UNDER TERMS OF WTFPL LICENSE

2012, 2013, 2014 obneq aka jin xi]]

--
-- Painting registration
--

painting:register_canvas("painting:canvas_16", 16)
painting:register_canvas("painting:canvas_32", 32)
-- painting:register_canvas("painting:canvas_64", 64)

--
-- Crafting recipes
--

minetest.register_craft({
	output = 'painting:easel',
	recipe = {
		{'', 'default:wood', ''},
		{'', 'default:wood', ''},
		{'default:stick','', 'default:stick'}
	}
})

minetest.register_craft({
	output = 'painting:canvas_16',
	recipe = {
		{'', '', ''},
		{'', '', ''},
		{'default:paper', '', ''}
	}
})

minetest.register_craft({
	output = 'painting:canvas_32',
	recipe = {
		{'', '', ''},
		{'default:paper', 'default:paper', ''},
		{'default:paper', 'default:paper', ''}
	}
})

--[[
minetest.register_craft({
	output = 'painting:canvas_64',
	recipe = {
		{'default:paper', 'default:paper', 'default:paper'},
		{'default:paper', 'default:paper', 'default:paper'},
		{'default:paper', 'default:paper', 'default:paper'}
	}
})
--]]
--
-- Fuels
--

minetest.register_craft({
	type = "fuel",
	recipe = "painting:easel",
	burntime = 16
})

minetest.register_craft({
	type = "fuel",
	recipe = "painting:canvas_16",
	burntime = 1
})

minetest.register_craft({
	type = "fuel",
	recipe = "painting:canvas_32",
	burntime = 4
})
--[[
minetest.register_craft({
	type = "fuel",
	recipe = "painting:canvas_64",
	burntime = 9
})
--]]