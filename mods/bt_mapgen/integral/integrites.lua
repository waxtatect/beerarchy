-- Spider by AspireMint (fishyWET (CC-BY-SA 3.0 license for texture)

integral.search_replace = function(pos, search_rate, replace_what, replace_with)
	if math.random(search_rate) > 1 then
		return
	end

	local p1 = vector.subtract(pos, 1)
	local p2 = vector.add(pos, 1)

	--look for nodes
	local nodelist = minetest.find_nodes_in_area(p1, p2, replace_what)

	if #nodelist > 0 then
		for key,value in pairs(nodelist) do
			minetest.set_node(value, {name = replace_with})
			break  -- only one at a time
		end
	end

end

mobs:register_mob("integral:integrite", {
	description = "Integrite Worker",
	type = "monster",
	passive = false,
	attack_type = "dogfight",
	attacks_monsters = true,
	reach = 2,
	damage = 1,
	hp_min = 5,
	hp_max = 10,
	armor = 200,
	collisionbox = {-0.32, -0.0, -0.25, 0.25, 0.25, 0.25},
	visual = "mesh",
	mesh = "integral_spider.x",
	drawtype = "front",
	textures = {
		{"mobs_spider.png"}
	},
	visual_size = {x = 1.5, y = 1.5},
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
		{name = "mobs:meat_raw", chance = 2, min = 1, max = 1},
		{name = "default:mese_crystal_fragment", chance = 5, min = 1, max = 1}
	},
	water_damage = 1,
	lava_damage = 5,
	light_damage = 0,
	fall_damage = 0,
	lifetimer = 360,
	follow = nil,
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
	replace_rate = 50,
	replace_what = {"mobs:cobweb", "integral:glowing_fungal_wood", "integral:sap"},
	replace_with = "air",
	replace_offset = -1,
	do_custom = function(self)
		integral.integrite_tunneling(self, "worker")
		integral.climb(self)
		integral.search_replace(self.object:get_pos(), 50, {"integral:integral_wood"}, "integral:glowing_fungal_wood")
		integral.search_replace(self.object:get_pos(), 2000, {"air"}, "mobs:cobweb")
	end
})

mobs:register_mob("integral:integrite_soldier", {
	description = "Integrite Soldier",
	type = "monster",
	passive = false,
	attack_type = "dogfight",
	attacks_monsters = true,
	reach = 2,
	damage = 3,
	hp_min = 10,
	hp_max = 20,
	armor = 200,
	collisionbox = {-0.5, 0.0, -0.4, 0.4, 0.4, 0.4},
	visual = "mesh",
	mesh = "integral_spider.x",
	drawtype = "front",
	textures = {
		{"integrite_soldier.png"}
	},
	visual_size = {x = 2.5, y = 2.5},
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
		{name = "mobs:meat_raw", chance = 2, min = 1, max = 2},
		{name = "default:mese_crystal_fragment", chance = 3, min = 1, max = 1}
	},
	water_damage = 1,
	lava_damage = 5,
	light_damage = 0,
	fall_damage = 0,
	lifetimer = 360,
	follow = nil,
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
	replace_rate = 50,
	replace_what = {"integral:glowing_fungal_wood", "integral:sap"},
	replace_with = "air",
	replace_offset = -1,
	do_custom = function(self)
		integral.climb(self)
		integral.search_replace(self.object:get_pos(), 3000, {"air"}, "mobs:cobweb")
	end
})

function integral.climb(self)
	if self.state == "stand" and math.random() < 0.2 then
		if self.fall_speed == 2 then
			self.fall_speed = -2
		else
			self.fall_speed = 2
		end
	elseif self.state == "attack" and self.fall_speed ~= -2 then
		self.fall_speed = -2
	end
end

mobs:register_mob("integral:integrite_queen", {
	description = "Integrite Queen",
	type = "monster",
	passive = false,
	attack_type = "dogfight",
	attacks_monsters = true,
	reach = 2,
	damage = 2,
	hp_min = 15,
	hp_max = 30,
	armor = 200,
	collisionbox = {-0.6, 0.0, -0.5, 0.5, 0.4, 0.5},
	visual = "mesh",
	mesh = "integral_spider.x",
	drawtype = "front",
	textures = {
		{"integrite_queen.png"},
	},
	visual_size = {x = 3.5, y = 3.5},
	makes_footstep_sound = false,
	sounds = {
		random = "mobs_spider",
		attack = "mobs_spider",
	},
	walk_velocity = 1,
	run_velocity = 3,
	jump = true,
	view_range = 15,
	floats = 0,
	drops = {
		{name = "mobs:meat_raw", chance = 2, min = 1, max = 3},
		{name = "default:mese_crystal_fragment", chance = 1, min = 1, max = 1},
	},
	water_damage = 1,
	lava_damage = 5,
	light_damage = 0,
	fall_damage = 0,
	lifetimer = 360,
	follow = nil,
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
		punch_end = 90,
	},
	replace_rate = 50,
	replace_what = {"integral:glowing_fungal_wood", "integral:sap"},
	replace_with = "air",
	replace_offset = -1,
	do_custom = function(self)
		integral.climb(self)
		integral.integrite_summon(self)
		integral.search_replace(self.object:get_pos(), 3000, {"air"}, "mobs:cobweb")
	end,
})

integral.integrite_summon = function(self)
	local hp = self.object:get_hp()
	if hp < (self.health / 2) and self.state == "attack" and math.random(4) == 1 then
		local pos = self.object:get_pos()
		local p1 = vector.subtract(pos, 1)
		local p2 = vector.add(pos, 1)

		--look for nodes
		local nodelist = minetest.find_nodes_in_area(p1, p2, "air")

		if #nodelist > 0 then
			for key,value in pairs(nodelist) do
				minetest.add_entity(value, "integral:integrite_soldier")
				print("Integrite queen summons reinforcement.")
				return  -- only one at a time
			end
		end
	end
end

integral.integrite_tunneling = function(self, type)
	-- Types are available for fine-tuning.
	if type == nil then
		type = "worker"
	end

	local diggable_nodes = {"integral:integral_wood",  "integral:glowing_fungal_wood", "integral:sap"}
	-- This translates yaw into vectors.
	local cardinals = {{x=0,y=0,z=0.75}, {x=-0.75,y=0,z=0}, {x=0,y=0,z=-0.75}, {x=0.75,y=0,z=0}}
	local pos = self.object:get_pos()

	if self.state == "tunnel" then
		-- Yaw is stored as one of the four cardinal directions.
		if not self.digging_dir then
			self.digging_dir = math.random(0,3)
		end

		-- Turn him roughly in the right direction.
		self.object:set_yaw(self.digging_dir * math.pi * 0.5)

		-- Get a pair of coordinates that should cover what's in front of him.
		local p = vector.add(pos, cardinals[self.digging_dir+1])
		p.y = p.y + 0.25  -- What's this about?
		local p1 = vector.add(p, -0.3)
		local p2 = vector.add(p, 0.3)

		-- Get any diggable nodes in that area.
		local np_list = minetest.find_nodes_in_area(p1, p2, diggable_nodes)

		if #np_list > 0 then
			-- Dig it.
			for _, np in pairs(np_list) do
				minetest.remove_node(np)
			end
		end

		if math.random() < 0.2 then
			local d = {-1,1}
			self.digging_dir = (self.digging_dir + d[math.random(2)]) % 4
		end

		mobs:set_animation(self, "walk")
		mobs:set_velocity(self, self.walk_velocity)
	elseif self.state == "room" then  -- Dig a room.
		if not self.room_radius then
			self.room_radius = 1
		end

		mobs:set_animation(self, "stand")
		mobs:set_velocity(self, 0)

		-- Work from the inside, out.
		for r = 1,self.room_radius do
			-- Get a pair of coordinates that form a room.
			local p1 = vector.add(pos, -r)
			local p2 = vector.add(pos, r)
			-- But not below him.
			p1.y = pos.y

			local np_list = minetest.find_nodes_in_area(p1, p2, diggable_nodes)

			-- I wanted to leave the outer layer incomplete, but this
			--  actually tends to make it look worse.
			if r >= self.room_radius and #np_list == 0 then
				self.room_radius = math.random(1,2) + math.random(0,1)
				self.state = "stand"
				break
			end

			if #np_list > 0 then
				-- Dig it.
				minetest.remove_node(np_list[math.random(#np_list)])
				break
			end
		end
	end

	if self.state == "stand" and math.random() < 0.03 then
		self.state = "tunnel"
	elseif self.state == "tunnel" and math.random() < 0.01 then
		self.state = "room"
	elseif self.state == "tunnel" and math.random() < 0.1 then
		self.state = "stand"
	end
end

mobs:spawn({
	name = "integral:integrite",
	nodes = {"integral:integral_wood"},
	chance = 500,
	active_object_count = 10
})
mobs:spawn({
	name = "integral:integrite_soldier",
	nodes = {"integral:glowing_fungal_wood"},
	chance = 500,
	active_object_count = 10
})
mobs:spawn({
	name = "integral:integrite_queen",
	nodes = {"integral:glowing_fungal_wood"},
	chance = 4000,
	active_object_count = 10
})

mobs:register_egg("integral:integrite", "Integrite Worker", "mobs_cobweb.png", 1)
mobs:register_egg("integral:integrite_soldier", "Integrite Soldier", "mobs_cobweb.png", 1)
mobs:register_egg("integral:integrite_queen", "Integrite Queen", "mobs_cobweb.png", 1)

minetest.register_abm({
	label = "Integral cobweb sweeping",
	nodenames = {"mobs:cobweb"},
	neighbors = {"group:integral"},
	interval = 500,
	chance = 25,
	action = function(pos, node)
		minetest.set_node(pos, {name = "air"})
	end
})