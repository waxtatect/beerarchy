-- arrows
mobs:register_arrow("horror:fireball", {
   visual = "sprite",
   visual_size = {x = 0.5, y = 0.5},
   textures = {"horror_fireball.png"},
   velocity = 8,
   tail = 1, -- enable tail
   tail_texture = "horror_steam.png",

   hit_player = function(self, player)
	  player:punch(self.object, 1.0, {
		 full_punch_interval = 1.0,
		 damage_groups = {fleshy = 3},
	  }, nil)
   end,

   hit_mob = function(self, player)
	  player:punch(self.object, 1.0, {
		 full_punch_interval = 1.0,
		 damage_groups = {fleshy = 3},
	  }, nil)
   end,

   hit_node = function(self, pos, node)
	  self.object:remove()
   end
})

mobs:register_arrow("horror:fireball_2", {
   visual = "sprite",
   visual_size = {x = 1, y = 1},
   textures = {"horror_fireshot.png"},
   velocity = 8,
   tail = 0, -- enable tail
   tail_texture = "horror_steam.png",

   hit_player = function(self, player)
	  player:punch(self.object, 1.0, {
		 full_punch_interval = 1.0,
		 damage_groups = {fleshy = 2},
	  }, nil)
   end,

   hit_mob = function(self, player)
	  player:punch(self.object, 1.0, {
		 full_punch_interval = 1.0,
		 damage_groups = {fleshy = 2},
	  }, nil)
   end,

   hit_node = function(self, pos, node)
	  self.object:remove()
   end
})

mobs:register_arrow("horror:rocket", {
	visual = "sprite",
	visual_size = {x = 1, y = 1},
	textures = {"horror_rocket.png"},
	velocity = 6,
	tail = 1,
	tail_texture = "horror_rocket_smoke.png",
	tail_size = 10,
	glow = 5,
	expire = 0.1,

	-- direct hit, no fire... just plenty of pain
	hit_player = function(self, player)
		player:punch(self.object, 1.0, {
			full_punch_interval = 1.0,
			damage_groups = {fleshy = 8},
		}, nil)
		tnt.boom(self.object:get_pos(), { radius = 2, damage_radius = 3, ignore_protection = false, ignore_on_blast = false })
	end,

	hit_mob = function(self, player)
		player:punch(self.object, 1.0, {
			full_punch_interval = 1.0,
			damage_groups = {fleshy = 8},
		}, nil)
		tnt.boom(self.object:get_pos(), { radius = 2, damage_radius = 3, ignore_protection = false, ignore_on_blast = false })
	end,

	-- node hit, bursts into flame
	hit_node = function(self, pos, node)
		tnt.boom(pos, { radius = 2, damage_radius = 3, ignore_protection = false, ignore_on_blast = false })
	end
})

-- mobs, eggs and spawning
mobs:register_mob("horror:hellbaron", {
	type = "monster",
	passive = false,
	attacks_monsters = true,
	damage = 3,
	knock_back = false,
	reach = 2,
	attack_type = "dogshoot",
	shoot_interval = 2.5,
	dogshoot_switch = 2,
	dogshoot_count = 0,
	dogshoot_count_max =5,
	arrow = "horror:fireball_2",
	shoot_offset = 0.5,
	hp_min = 200,
	hp_max = 400,
	armor = 400,
	collisionbox = {-0.5, 0, -0.6, 0.6, 3, 0.6},
	visual = "mesh",
	mesh = "hellbaron.b3d",
	textures = {
		{"horror_hellbaron.png"}
	},
	blood_amount = 80,
	blood_texture = "horror_blood_effect.png",
	visual_size = {x=1, y=1},
	makes_footstep_sound = true,
	walk_velocity = 2,
	run_velocity = 3.5,
	jump = true,
	drops = {
		{name = "moreores:mithril_block", chance = 1, min = 1, max = 5},
		{name = "mobs:lava_orb", chance = 1, min = 1, max = 1}
	},
	water_damage = 0,
	lava_damage = 0,
	light_damage = 0,
	view_range = 20,
	animation = {
		speed_normal = 10,
		speed_run = 20,
		walk_start = 51,
		walk_end = 75,
		stand_start = 1,
		stand_end = 25,
		run_start = 51,
		run_end = 75,
		punch_start = 25,
		punch_end = 50,
		shoot_start = 25,
		shoot_end = 50
	}
})

mobs:spawn({
	name = "horror:hellbaron",
	nodes = {"underworlds:hot_cobble"},
	chance = 15000,
	active_object_count = 2,
	max_height = -5800
})
mobs:spawn({
	name = "horror:hellbaron",
	nodes = {"default:obsidian"},
	chance = 2000,
	active_object_count = 1,
	max_height = -13540
})

mobs:register_egg("horror:hellbaron", "Hell Baron", "default_dirt.png", 1)

mobs:register_mob("horror:spider", {
	type = "monster",
	passive = false,
	reach = 2,
	damage = 2,
	knock_back = false,
	attack_type = "dogfight",
	hp_min = 80,
	hp_max = 120,
	armor = 130,
	collisionbox = {-0.7, 0, -0.7, 0.7, 1.5, 0.7},
	visual = "mesh",
	mesh = "hspider.b3d",
	textures = {
		{"hspider.png"}
	},
	blood_amount = 80,
	blood_texture = "horror_blood_effect.png",
	visual_size = {x=3, y=3},
	makes_footstep_sound = true,
	walk_velocity = 2.5,
	run_velocity = 3.1,
	sounds = {
		random = "mobs_spider",
		attack = "mobs_spider"
	},
	jump = true,
	on_die = function(self, pos)
		minetest.add_entity({ x = pos.x, y = pos.y, z = pos.z }, "horror:mini_spider")
		minetest.add_entity({ x = pos.x - 1, y = pos.y, z = pos.z }, "horror:mini_spider")
		minetest.add_entity({ x = pos.x + 1, y = pos.y, z = pos.z }, "horror:mini_spider")
		minetest.add_entity({ x = pos.x - 1, y = pos.y, z = pos.z - 1 }, "horror:mini_spider")
		minetest.add_entity({ x = pos.x + 1, y = pos.y, z = pos.z - 1 }, "horror:mini_spider")
		minetest.add_entity({ x = pos.x - 1, y = pos.y, z = pos.z + 1 }, "horror:mini_spider")
		minetest.add_entity({ x = pos.x + 1, y = pos.y, z = pos.z + 1 }, "horror:mini_spider")
		minetest.add_entity({ x = pos.x, y = pos.y + 1, z = pos.z }, "horror:mini_spider")
		minetest.add_entity({ x = pos.x - 1, y = pos.y + 1, z = pos.z }, "horror:mini_spider")
		minetest.add_entity({ x = pos.x + 1, y = pos.y + 1, z = pos.z }, "horror:mini_spider")
		minetest.add_entity({ x = pos.x - 1, y = pos.y + 1, z = pos.z - 1 }, "horror:mini_spider")
		minetest.add_entity({ x = pos.x + 1, y = pos.y + 1, z = pos.z - 1 }, "horror:mini_spider")
		minetest.add_entity({ x = pos.x - 1, y = pos.y + 1, z = pos.z + 1 }, "horror:mini_spider")
		minetest.add_entity({ x = pos.x + 1, y = pos.y + 1, z = pos.z + 1 }, "horror:mini_spider")
	end,
	drops = {
		{name = "mobs:meat_raw", chance = 2, min = 1, max = 1},
		{name = "farming:string", chance = 1, min = 3, max = 6},
		{name = "default:mese", chance = 20, min = 1, max = 2}
	},
	water_damage = 0,
	lava_damage = 2,
	light_damage = 0,
	replace_rate = 20,
	replace_what = {"air"},
	replace_with = "horror:spiderweb_decaying",
	view_range = 14,
	animation = {
		speed_normal = 10,
		speed_run = 15,
		walk_start = 45,
		walk_end = 65,
		run_start = 45,
		run_end = 65,
		stand_start = 1,
		stand_end = 20,
		punch_start = 20,
		punch_end = 40
	}
})

mobs:spawn({
	name = "horror:spider",
	nodes = {"underworlds:polluted_dirt"},
	chance = 35000,
	active_object_count = 2,
	max_height = -4000
})
mobs:spawn({
	name = "horror:spider",
	nodes = {"default:stone"},
	chance = 15000,
	active_object_count = 1,
	max_height = -13540
})

mobs:register_egg("horror:spider", "Giant Spider", "default_obsidian.png", 1)

mobs:register_mob("horror:mini_spider", {
	group_attack = true,
	type = "monster",
	passive = false,
	attack_type = "dogfight",
	reach = 2,
	damage = 2,
	hp_min = 10,
	hp_max = 20,
	armor = 50,
	collisionbox = {-0.9, -0.01, -0.7, 0.7, 0.6, 0.7},
	visual = "mesh",
	mesh = "mobs_spider.x",
	textures = {
		{"mobs_spider.png"}
	},
	visual_size = {x = 2, y = 2},
	makes_footstep_sound = false,
	sounds = {
		random = "mobs_spider",
		attack = "mobs_spider"
	},
	walk_velocity = 2,
	run_velocity = 5,
	jump = true,
	view_range = 15,
	floats = 0,
	drops = {
		{name = "farming:string", chance = 1, min = 1, max = 2},
		{name = "mobs:leather", chance = 10, min = 0, max = 2}
	},
	water_damage = 5,
	lava_damage = 5,
	light_damage = 0,
	animation = {
		speed_normal = 15,
		speed_run = 15,
		stand_start = 1,
		stand_end = 1,
		walk_start = 20,
		walk_end = 40,
		run_start = 20,
		run_end = 40,
		punch_start = 50,
		punch_end = 90
	}
})

mobs:register_mob("horror:cyberdemon", {
	type = "monster",
	passive = false,
	attacks_monsters = true,
	damage = 3,
	knock_back = false,
	reach = 2,
	attack_type = "dogshoot",
	shoot_interval = 1.5,
	dogshoot_switch = 2,
	dogshoot_count = 1,
	dogshoot_count_max = 5,
	arrow = "horror:rocket",
	shoot_offset = -0.5,
	hp_min = 100,
	hp_max = 200,
	armor = 200,
	collisionbox = {-0.5, 0, -0.6, 0.6, 3, 0.6},
	visual = "mesh",
	mesh = "cyberdemon.b3d",
	textures = {
		{"horror_cyberdemon.png"}
	},
	blood_amount = 80,
	blood_texture = "horror_blood_effect.png",
	visual_size = {x=1, y=1},
	makes_footstep_sound = true,
	walk_velocity = 2,
	run_velocity = 3.5,
	jump = true,
	drops = {
		{name = "moreores:mithril_block", chance = 1, min = 1, max = 5},
		{name = "mobs:lava_orb", chance = 1, min = 1, max = 1},
		{name = "throwing:arrow_tnt", chance = 1, min = 1, max = 10},
		{name = "throwing:bow_mithril", chance = 10, min = 1, max = 1}
	},
	water_damage = 0,
	lava_damage = 0,
	light_damage = 0,
	view_range = 20,
	animation = {
		speed_normal = 10,
		speed_run = 15,
		walk_start = 20,
		walk_end = 40,
		run_start = 20,
		run_end = 40,
		stand_start = 64,
		stand_end = 80,
		shoot_start = 1,
		shoot_end = 15
	}
})

mobs:spawn({
	name = "horror:cyberdemon",
	nodes = {"default:obsidian"},
	chance = 35000,
	active_object_count = 2,
	max_height = -13600
})

mobs:register_egg("horror:cyberdemon", "Cyberdemon", "wool_red.png", 1)

mobs:register_mob("horror:manticore", {
	type = "monster",
	passive = false,
	attacks_monsters = true,
	damage = 2,
	knock_back = false,
	reach = 3,
	attack_type = "dogfight",
	hp_min = 30,
	hp_max = 45,
	armor = 130,
	collisionbox = {-0.5, -0.5, -0.6, 0.6, 0.6, 0.6},
	visual = "mesh",
	mesh = "manticore.b3d",
	textures = {
		{"manticore.png"}
	},
	blood_amount = 80,
	blood_texture = "horror_blood_effect.png",
	visual_size = {x=3, y=3},
	makes_footstep_sound = true,
	walk_velocity = 2.5,
	run_velocity = 3.5,
	jump = true,
	drops = {
		{name = "default:diamond", chance = 20, min = 1, max = 1}
	},
	water_damage = 2,
	lava_damage = 0,
	light_damage = 0,
	view_range = 20,
	animation = {
		speed_normal = 10,
		speed_run = 20,
		walk_start = 1,
		walk_end = 11,
		stand_start = 1,
		stand_end = 11,
		run_start = 1,
		run_end = 11,
		punch_start = 11,
		punch_end = 26
   }
})

mobs:spawn({
	name = "horror:manticore",
	nodes = {"underworlds:hot_cobble"},
	chance = 15000,
	active_object_count = 2,
	max_height = -3200
})

mobs:register_egg("horror:manticore", "Manticore", "default_dirt.png", 1)

mobs:register_mob("horror:mothman", {
	type = "monster",
	passive = false,
	attacks_monsters = true,
	damage = 2,
	knock_back = false,
	reach = 3,
	attack_type = "dogfight",
	hp_min = 30,
	hp_max = 45,
	armor = 80,
	collisionbox = {-0.3, -0.3, -0.3, 0.3, 0.3, 0.3},
	visual = "mesh",
	mesh = "mothman.b3d",
	textures = {
		{"mothman.png"}
	},
	blood_amount = 60,
	blood_texture = "horror_blood_effect.png",
	visual_size = {x=3, y=3},
	makes_footstep_sound = true,
	walk_velocity = 2,
	run_velocity = 4,
	jump = true,
	fly = true,
	do_custom = function(self)
		local apos = self.object:get_pos()
		local part = minetest.add_particlespawner({
			amount = 1,
			time = 0.3,
			minpos = {x=apos.x-0.3, y=apos.y-0.3, z=apos.z-0.3},
			maxpos = {x=apos.x+0.3, y=apos.y-0.3, z=apos.z+0.3},
			minvel = {x=-0, y=-0, z=-0},
			maxvel = {x=0, y=0, z=0},
			minacc = {x=0,y=-1,z=0},
			maxacc = {x=0.5,y=-1,z=0.5},
			minexptime = 3,
			maxexptime = 5,
			minsize = 3,
			maxsize = 5,
			collisiondetection = false,
			texture = "horror_dust.png"
		})
	end,
	fall_speed = 0,
	stepheight = 5,
	drops = {
		{name = "moreores:mithril_ingot", chance = 20, min = 1, max = 1}
	},
	water_damage = 2,
	lava_damage = 0,
	light_damage = 0,
	view_range = 20,
	animation = {
		speed_normal = 20,
		speed_run = 33,
		walk_start = 1,
		walk_end = 11,
		stand_start = 1,
		stand_end = 11,
		run_start = 1,
		run_end = 11,
		punch_start = 1,
		punch_end = 11
   }
})

mobs:spawn({
	name = "horror:mothman",
	nodes = {"underworlds:hot_cobble"},
	chance = 15000,
	active_object_count = 2,
	max_height = -3200
})
mobs:spawn({
	name = "horror:mothman",
	nodes = {"default:stone"},
	chance = 15000,
	active_object_count = 1,
	max_height = -13540
})

mobs:register_egg("horror:mothman", "Mothman", "horror_orb.png", 1)