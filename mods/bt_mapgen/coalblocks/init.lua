minetest.register_ore({
	ore_type       = "sheet",
	ore            = "default:coalblock",
	wherein        = "default:stone",
	clust_scarcity = 2*2*2,
	clust_num_ores = 64,
	clust_size     = 8,
	y_min		   = 700,
	y_max		   = 1000,
	noise_params   = {offset=0, scale=1, spread={x=100, y=100, z=100}, seed=23, octaves=3, persist=0.70}
})

minetest.register_ore({
	ore_type       = "sheet",
	ore            = "default:coalblock",
	wherein        = "default:desert_stone",
	clust_scarcity = 2*2*2,
	clust_num_ores = 64,
	clust_size     = 8,
	y_min		   = 700,
	y_max		   = 1000,
	noise_params   = {offset=0, scale=1, spread={x=100, y=100, z=100}, seed=23, octaves=3, persist=0.70}
})

minetest.register_ore({
	ore_type       = "sheet",
	ore            = "default:coalblock",
	wherein        = "default:sandstone",
	clust_scarcity = 2*2*2,
	clust_num_ores = 64,
	clust_size     = 8,
	y_min		   = 700,
	y_max		   = 1000,
	noise_params   = {offset=0, scale=1, spread={x=100, y=100, z=100}, seed=23, octaves=3, persist=0.70}
})

minetest.register_ore({
	ore_type       = "sheet",
	ore            = "default:coalblock",
	wherein        = "default:stone",
	clust_scarcity = 4*4*4,
	clust_num_ores = 128,
	clust_size     = 16,
	y_min		   = 2000,
	y_max		   = 3000,
	noise_params   = {offset=0, scale=1, spread={x=100, y=100, z=100}, seed=23, octaves=5, persist=0.70}
})

minetest.register_ore({
	ore_type       = "sheet",
	ore            = "default:coalblock",
	wherein        = "default:desert_stone",
	clust_scarcity = 4*4*4,
	clust_num_ores = 128,
	clust_size     = 16,
	y_min		   = 2000,
	y_max		   = 3000,
	noise_params   = {offset=0, scale=1, spread={x=100, y=100, z=100}, seed=23, octaves=5, persist=0.70}
})

minetest.register_ore({
	ore_type       = "sheet",
	ore            = "default:coalblock",
	wherein        = "default:sandstone",
	clust_scarcity = 4*4*4,
	clust_num_ores = 128,
	clust_size     = 16,
	y_min		   = 2000,
	y_max		   = 3000,
	noise_params   = {offset=0, scale=1, spread={x=100, y=100, z=100}, seed=23, octaves=5, persist=0.70}
})