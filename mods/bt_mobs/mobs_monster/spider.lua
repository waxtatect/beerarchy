local S = mobs.intllib

local get_velocity = function(self)

	local v = self.object:get_velocity()

	-- sanity check
	if not v then return 0 end

	return (v.x * v.x + v.z * v.z) ^ 0.5
end

-- Spider by AspireMint (fishyWET (CC-BY-SA 3.0 license for texture)

mobs:register_mob("mobs_monster:spider", {
	docile_by_day = true,
	group_attack = true,
	type = "monster",
	passive = false,
	attack_type = "dogfight",
	reach = 2,
	damage = 3,
	hp_min = 20,
	hp_max = 40,
	armor = 200,
	collisionbox = {-0.9, -0.01, -0.7, 0.7, 0.6, 0.7},
	visual_size = {x = 7, y = 7},
	visual = "mesh",
	mesh = "mobs_spider.x",
	textures = {
		{"mobs_spider.png"},
	},
	makes_footstep_sound = false,
	sounds = {
		random = "mobs_spider",
		attack = "mobs_spider"
	},
	walk_velocity = 1,
	run_velocity = 3,
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
	},
	-- custom function to make spiders climb vertical facings
	do_custom = function(self, dtime)
		-- quarter second timer
		self.spider_timer = (self.spider_timer or 0) + dtime
		if self.spider_timer < 0.25 then
			return
		end
		self.spider_timer = 0

		-- need to be stopped to go onwards
		if get_velocity(self) > 0.5 then
			self.disable_falling = nil
			return
		end

		local pos = self.object:get_pos()
		local yaw = self.object:get_yaw()

		-- sanity check
		if not yaw then return end

		pos.y = pos.y + self.collisionbox[2] - 0.2

		local dir_x = -math.sin(yaw) * (self.collisionbox[4] + 0.5)
		local dir_z = math.cos(yaw) * (self.collisionbox[4] + 0.5)
		local nod = minetest.get_node_or_nil({
			x = pos.x + dir_x,
			y = pos.y + 0.5,
			z = pos.z + dir_z
		})

		-- get current velocity
		local v = self.object:get_velocity()

		-- can only climb solid facings
		if not nod or not minetest.registered_nodes[nod.name]
		or not minetest.registered_nodes[nod.name].walkable then
			self.disable_falling = nil
			v.y = 0
			self.object:set_velocity(v)
			return
		end

		-- turn off falling if attached to facing
		self.disable_falling = true

		-- move up facing
		v.x = 0 ; v.y = 0
		v.y = self.jump_height
		mobs:set_animation(self, "jump")
		self.object:set_velocity(v)
	end,
	-- make spiders jump at you on attack
	custom_attack = function(self, pos)
		local vel = self.object:get_velocity()

		self.object:set_velocity({
			x = vel.x * self.run_velocity,
			y = self.jump_height * 1.5,
			z = vel.z * self.run_velocity
		})

		self.pausetimer = 0.5

		return true -- continue rest of attack function
	end
})

local spawn_on = "default:desert_stone"

if minetest.get_modpath("ethereal") then
	spawn_on = "ethereal:crystal_dirt"
else
	minetest.register_alias("ethereal:crystal_spike", "default:sandstone")
end

mobs:spawn({
	name = "mobs_monster:spider",
	nodes = { "default:desert_stone", "default:dirt", "default:dirt_with_dry_grass", "default:dirt_with_grass" },
	min_light = 0,
	max_light = 12,
	chance = 7000,
	active_object_count = 1,
	min_height = -50,
	max_height = 31000
})

mobs:spawn({
	name = "mobs_monster:spider",
	nodes = { "underworlds:hot_brass", "underworlds:polluted_dirt" },
	min_light = 0,
	max_light = 12,
	chance = 5000,
	active_object_count = 1,
	max_height = 0
})

mobs:register_egg("mobs_monster:spider", S("Spider"), "mobs_cobweb.png", 1)

mobs:alias_mob("mobs:spider", "mobs_monster:spider") -- compatibility

-- cobweb
minetest.register_node(":mobs:cobweb", {
	description = S("Cobweb"),
	drawtype = "plantlike",
	visual_scale = 1.2,
	tiles = {"mobs_cobweb.png"},
	inventory_image = "mobs_cobweb.png",
	paramtype = "light",
	sunlight_propagates = true,
	liquid_viscosity = 11,
	liquidtype = "source",
	liquid_alternative_flowing = "mobs:cobweb",
	liquid_alternative_source = "mobs:cobweb",
	liquid_renewable = false,
	liquid_range = 0,
	walkable = false,
	groups = {snappy = 1, disable_jump = 1},
	drop = "farming:string",
	sounds = default.node_sound_leaves_defaults()
})

minetest.register_craft({
	output = "mobs:cobweb",
	recipe = {
		{"farming:string", "", "farming:string"},
		{"", "farming:string", ""},
		{"farming:string", "", "farming:string"}
	}
})