local baits = fishing.baits
local S = fishing.func.S

-- fish bait
-- bait_corn
minetest.register_craftitem("fishing:bait_corn", {
	description = S("Bait Corn"),
	inventory_image = "fishing_bait_corn.png"
})

baits["fishing:bait_corn"] = {
	bait = "fishing:bait_corn",
	bobber = "fishing:bobber_fish_entity",
	texture = "fishing_bait_corn.png",
	hungry = 50
}

-- bait_bread
minetest.register_craftitem("fishing:bait_bread", {
	description = S("Bait Bread"),
	inventory_image = "fishing_bait_bread.png"
})

baits["fishing:bait_bread"] = {
	bait = "fishing:bait_bread",
	bobber = "fishing:bobber_fish_entity",
	texture = "fishing_bait_bread.png",
	hungry = 50
}

-- bait_worm
baits["fishing:bait_worm"] = {
	bait = "fishing:bait_worm",
	bobber = "fishing:bobber_fish_entity",
	texture = "fishing_bait_worm.png",
	hungry = 50
}

-- shark bait
-- bait_fish
baits["fishing:fish_raw"] = {
	bait = "fishing:fish_raw",
	bobber = "fishing:bobber_shark_entity",
	texture = "fishing_fish_raw.png",
	hungry = 50
}

baits["fishing:clownfish_raw"] = {
	bait = "fishing:clownfish_raw",
	bobber = "fishing:bobber_shark_entity",
	texture = "fishing_clownfish_raw.png",
	hungry = 50
}

baits["fishing:bluewhite_raw"] = {
	bait = "fishing:bluewhite_raw",
	bobber = "fishing:bobber_shark_entity",
	texture = "fishing_bluewhite_raw.png",
	hungry = 50
}

baits["fishing:exoticfish_raw"] = {
	bait = "fishing:exoticfish_raw",
	bobber = "fishing:bobber_shark_entity",
	texture = "fishing_exoticfish_raw.png",
	hungry = 50
}

if minetest.get_modpath("mobs_fish") then
	baits["mobs_fish:clownfish"] = {
		bait = "mobs_fish:clownfish",
		bobber = "fishing:bobber_shark_entity",
		hungry = 50
	}

	baits["mobs_fish:tropical"] = {
		bait = "mobs_fish:tropical",
		bobber = "fishing:bobber_shark_entity",
		hungry = 50
	}
end