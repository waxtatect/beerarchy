
local S = mobs.intllib


-- Kitten by Jordach / BFD

mobs:register_mob("mobs_animal:kitten", {
	type = "npc",
	passive = false,
	owner_loyal = true,
	group_attack = true,
	attacks_monsters = true,
	friendly_fire = true,
	attack_type = "dogshoot",
	shoot_interval = 0.5,
	dogshoot_switch = 1,
	dogshoot_count_max = 1,
	arrow = "horror:fireball_2",
	shoot_offset = 2,
	reach = 3,
	damage = 8,
	hp_min = 5000,
	hp_max = 5000,
	armor = 5000,
	water_damage = 0,
	lava_damage = 0,
	light_damage = 0,
	fall_damage	= 0,
	collisionbox = {-0.3, -0.3, -0.3, 0.3, 0.1, 0.3},
	visual = "mesh",
	visual_size = {x = 0.5, y = 0.5},
	mesh = "mobs_kitten.b3d",
	textures = {
		{"mobs_kitten_striped.png"},
		{"mobs_kitten_splotchy.png"},
		{"mobs_kitten_ginger.png"},
		{"mobs_kitten_sandy.png"},
	},
	makes_footstep_sound = false,
	sounds = {
		random = "mobs_kitten",
	},
	walk_velocity = 0.6,
	run_velocity = 8,
	jump = true,
	jump_height = 6,
	drops = {
		{name = "farming:string", chance = 5, min = 1, max = 1},
	},
	animation = {
		speed_normal = 42,
		stand_start = 97,
		stand_end = 192,
		walk_start = 0,
		walk_end = 96,
	},
	follow = {"mobs_animal:rat", "fishing:bluewhite_raw", "fishing:carp_raw", "fishing:catfish_raw", "fishing:clownfish_raw", "fishing:exoticfish_raw",
			  "fishing:fish_cooked", "fishing:fish_raw", "fishing:perch_raw", "fishing:pike_cooked", "fishing:pike_raw"},
	view_range = 16,
	on_rightclick = function(self, clicker)

		if mobs:feed_tame(self, clicker, 200, true, true) then
			return
		end

		mobs:protect(self, clicker)
		mobs:capture_mob(self, clicker, 50, 50, 90, false, nil)
	end,
})


mobs:spawn({
	name = "mobs_animal:kitten",
	nodes = {"default:dirt_with_grass", "ethereal:grove_dirt"},
	min_light = 12,
	chance = 60000,
	min_height = 0,
	max_height = 31000,
	day_toggle = true,
})


mobs:register_egg("mobs_animal:kitten", S("Cash's World Overlord Kitten"), "mobs_kitten_inv.png", 0)


mobs:alias_mob("mobs:kitten", "mobs_animal:kitten") -- compatibility
