local S = fishing.func.S

-- baitball
minetest.register_craftitem("fishing:baitball", {
	description = S("Bait Ball"),
	inventory_image = "fishing_baitball.png",
	stack_max = 99
})

minetest.register_craft({
	type = "shapeless",
	output = "fishing:baitball 20",
	recipe = {"farming:flour", "farming:corn", "bucket:bucket_water"},
	replacements = {{"bucket:bucket_water", "bucket:bucket_empty"}}
})

-- baitball_shark
minetest.register_craftitem("fishing:baitball_shark", {
	description = S("Shark Bait Ball"),
	inventory_image = "fishing_baitball_shark.png",
	stack_max = 99
})

minetest.register_craft({
	type = "shapeless",
	output = "fishing:baitball_shark 20",
	recipe = {"group:shark_bait", "group:shark_bait"}
})