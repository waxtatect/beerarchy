-----------------------------------------------------------------------------------------------
-- Fishing - crabman77's version
-- Rewrited from original Fishing - Mossmanikin's version - Fishes 0.0.4
-- License (code & textures): WTFPL
-----------------------------------------------------------------------------------------------
local S = fishing.func.S
-----------------------------------------------------------------------------------------------
-- Fish
-----------------------------------------------------------------------------------------------
minetest.register_craftitem("fishing:fish_raw", {
	description = S("Fish"),
	groups = {fish_raw = 1, shark_bait = 1},
	inventory_image = "fishing_fish_raw.png",
	on_use = minetest.item_eat(2)
})
-----------------------------------------------------
-- Roasted Fish
-----------------------------------------------------
minetest.register_craftitem("fishing:fish_cooked", {
	description = S("Roasted Fish"),
	inventory_image = "fishing_fish_cooked.png",
	on_use = minetest.item_eat(4)
})
-----------------------------------------------------
-- Sushi
-----------------------------------------------------
minetest.register_craftitem("fishing:sushi", {
	description = S("Sushi (Hoso Maki)"),
	inventory_image = "fishing_sushi.png",
	on_use = minetest.item_eat(6)
})
-----------------------------------------------------------------------------------------------
-- Clownfish
-----------------------------------------------------------------------------------------------
minetest.register_craftitem("fishing:clownfish_raw", {
	description = S("Clownfish"),
	groups = {fish_raw = 1, shark_bait = 1},
	inventory_image = "fishing_clownfish_raw.png",
	on_use = minetest.item_eat(2)
})
-----------------------------------------------------------------------------------------------
-- Bluewhite
-----------------------------------------------------------------------------------------------
minetest.register_craftitem("fishing:bluewhite_raw", {
	description = S("Bluewhite"),
	groups = {fish_raw = 1, shark_bait = 1},
	inventory_image = "fishing_bluewhite_raw.png",
	on_use = minetest.item_eat(2)
})
-----------------------------------------------------------------------------------------------
-- Exoticfish
-----------------------------------------------------------------------------------------------
minetest.register_craftitem("fishing:exoticfish_raw", {
	description = S("Exotic"),
	groups = {fish_raw = 1, shark_bait = 1},
	inventory_image = "fishing_exoticfish_raw.png",
	on_use = minetest.item_eat(2)
})
-----------------------------------------------------------------------------------------------
-- Carp
-----------------------------------------------------------------------------------------------
minetest.register_craftitem("fishing:carp_raw", {
	description = S("Carp"),
	groups = {fish_raw = 1, shark_bait = 1},
	inventory_image = "fishing_carp_raw.png",
	on_use = minetest.item_eat(2)
})
-----------------------------------------------------------------------------------------------
-- Perch
-----------------------------------------------------------------------------------------------
minetest.register_craftitem("fishing:perch_raw", {
	description = S("Perch"),
	groups = {fish_raw = 1, shark_bait = 1},
	inventory_image = "fishing_perch_raw.png",
	on_use = minetest.item_eat(2)
})
-----------------------------------------------------------------------------------------------
-- Catfish
-----------------------------------------------------------------------------------------------
minetest.register_craftitem("fishing:catfish_raw", {
	description = S("Catfish"),
	groups = {fish_raw = 1, shark_bait = 1},
	inventory_image = "fishing_catfish_raw.png",
	on_use = minetest.item_eat(2)
})
-----------------------------------------------------------------------------------------------
-- Whatthef... it's a freakin' Shark!
-----------------------------------------------------------------------------------------------
minetest.register_craftitem("fishing:shark_raw", {
	description = S("Shark"),
	groups = {shark_bait = 1},
	inventory_image = "fishing_shark_raw.png",
	on_use = minetest.item_eat(2)
})
-----------------------------------------------------
-- Roasted Shark
-----------------------------------------------------
minetest.register_craftitem("fishing:shark_cooked", {
	description = S("Roasted Shark"),
	inventory_image = "fishing_shark_cooked.png",
	on_use = minetest.item_eat(6)
})
-----------------------------------------------------------------------------------------------
-- Pike
-----------------------------------------------------------------------------------------------
minetest.register_craftitem("fishing:pike_raw", {
	description = S("Northern Pike"),
	groups = {shark_bait = 1},
	inventory_image = "fishing_pike_raw.png",
	on_use = minetest.item_eat(2)
})
-----------------------------------------------------
-- Roasted Pike
-----------------------------------------------------
minetest.register_craftitem("fishing:pike_cooked", {
	description = S("Roasted Northern Pike"),
	inventory_image = "fishing_pike_cooked.png",
	on_use = minetest.item_eat(6)
})