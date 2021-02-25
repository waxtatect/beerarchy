if dmobs.regulars then
	-- baddies
	mobs:spawn({
		name = "dmobs:golem",
		nodes = {"default:stone", "default:snow", "default:snowblock", "default:ice"},
		max_light = 7,
		chance = 16000,
		active_object_count = 5000
	})
	mobs:spawn({
		name = "dmobs:golem",
		nodes = {"default:obsidian"},
		max_light = 14,
		chance = 2000,
		active_object_count = 1,
		max_height = -13540
	})
end

-- dragons

mobs:spawn({
	name = "dmobs:dragon",
	nodes = {"default:leaves", "default:dirt_with_grass"},
	min_light = 10,
	chance = 5000000,
	active_object_count = 2
})
mobs:spawn({
	name = "dmobs:dragon",
	nodes = {"default:leaves", "default:dirt_with_grass"},
	chance = 1000,
	active_object_count = 2,
	max_height = -18400
})

if dmobs.dragons then
	mobs:spawn({
		name = "dmobs:dragon2",
		nodes = {"default:pine_needles"},
		min_light = 10,
		chance = 5000000,
		active_object_count = 2
	})
	mobs:spawn({
		name = "dmobs:dragon2",
		nodes = {"default:pine_needles"},
		chance = 50000,
		active_object_count = 2,
		max_height = -18400
	})
	mobs:spawn({
		name = "dmobs:dragon3",
		nodes = {"default:acacia_leaves", "default:dirt_with_dry_grass"},
		min_light = 10,
		chance = 5000000,
		active_object_count = 2
	})
	mobs:spawn({
		name = "dmobs:dragon3",
		nodes = {"default:acacia_leaves", "default:dirt_with_dry_grass"},
		chance = 50000,
		active_object_count = 2,
		max_height = -18400
	})
	mobs:spawn({
		name = "dmobs:dragon4",
		nodes = {"default:jungleleaves"},
		min_light = 10,
		chance = 5000000,
		active_object_count = 2
	})
	mobs:spawn({
		name = "dmobs:dragon4",
		nodes = {"default:jungleleaves"},
		chance = 50000,
		active_object_count = 2,
		max_height = -18400
	})
	mobs:spawn({
		name = "dmobs:waterdragon",
		nodes = {"default:water_source"},
		min_light = 10,
		chance = 5000000,
		active_object_count = 1,
		day_toggle = false
	})
	mobs:spawn({
		name = "dmobs:waterdragon",
		nodes = {"default:water_source"},
		chance = 50000,
		active_object_count = 1,
		max_height = -18400
	})
	mobs:spawn({
		name = "dmobs:wyvern",
		nodes = {"default:leaves"},
		min_light = 10,
		chance = 5000000,
		active_object_count = 1,
		day_toggle = false
	})
	mobs:spawn({
		name = "dmobs:wyvern",
		nodes = {"default:leaves"},
		chance = 50000,
		active_object_count = 1,
		max_height = -18400
	})
	mobs:spawn({
		name = "dmobs:dragon_great",
		nodes = {"default:silver_sand"},
		chance = 5000000,
		active_object_count = 1,
		day_toggle = false
	})
	mobs:spawn({
		name = "dmobs:dragon_great",
		nodes = {"default:desert_sand"},
		chance = 50000,
		active_object_count = 1,
		max_height = -18400
	})
end