local rad = math.rad
local random = aerotest.random

-- Drop on death what is definded in the entity table
local function handle_drops(self)
	if not self.drops then return end

	for _, item in ipairs(self.drops) do
		local amount = random (item.min or 1, item.max or 1)
		local chance = random(100)
		local pos = self.object:get_pos()
		pos.y = pos.y + self.collisionbox[5] + 1

		if chance < (100 / item.chance) then
			local itemstack = ItemStack({name = item.name, count = amount})
			if item.name == "aerotest:sword" then
				local names = aerotest.names
				itemstack:get_meta():set_string("description", names[random(#names)])
			end
			minetest.add_item(pos, itemstack)
		end
	end
end

local function update_nametag(self)
	if not self or not self.object then return end
	self.object:set_nametag_attributes({
		color = '#ff7373',
		text = tostring(math.floor(self.hp)) .. "%hp " .. tostring(math.floor(self.hunger)) .. "%st"
	})
end

local meat_raw = mobs and "mobs:meat_raw" or water_life and "water_life:meat_raw"

-- The eagle itself
minetest.register_entity('aerotest:eagle', {
	physical = true,
	collisionbox = {-0.3, 0, -0.3, 0.3, 0.8, 0.3},
	visual = "mesh",
	visual_size = {x = 2, y = 2},
	mesh = "aerotest_eagle.b3d",
	textures = {"aerotest_eagle.png"},
	makes_footstep_sound = false,
	timeout = -5, -- 24h
	buoyancy = 0.7,
	static_save = false,
	view_range = aerotest.abr * 32, -- 32 because mobkit's self.near_objects only checks until half self.view_range !!!
	max_hp = 100,
	hunger = 100,
	xhaust = 100,
	max_speed = 1,
	jump_height = 2,
	owner = "",
	drops = {
		{name = meat_raw, chance = 2, max = 3},
		{name = "default:diamond", chance = 4, max = 2},
		{name = "aerotest:sword", chance = 10}
	},
	animation = {
		idle = {range = {x = 0, y = 89}, speed = 10, loop = true},
		start = {range = {x = 90, y = 127}, speed = 20, loop = true},
		land = {range = {x = 142, y = 90}, speed = -10, loop = false},
		fly = {range = {x = 143, y = 163}, speed = 20, loop = true},
		glide = {range = {x = 165, y = 185}, speed = 20, loop = true}
	},
	sounds = {cry = "aerotest_eagle"},
	action = "idle",
	attack = {range = 0.8, damage_groups = {fleshy = 7}},

	on_step = mobkit.stepfunc,
	on_activate = mobkit.actfunc,
	get_staticdata = mobkit.statfunc,

	logic = function(self)
		self.hunger = mobkit.recall(self, "hunger") or 100
		self.xhaust = mobkit.recall(self, "xhaust") or 100

		if (self.action == "fly" or self.action == "glide") and aerotest.arrows then
			local eagle = self.object:get_pos()
			local attacker = aerotest.find_attacker(eagle, 3)
			if attacker then
				mobkit.clear_queue_low(self)
				mobkit.clear_queue_high(self)
				aerotest.hq_hunt(self, 50, attacker)
			end
		end

		if self.hp <= 0 or self.hunger <= -25 then
			mobkit.clear_queue_high(self)
			handle_drops(self)
			-- mobkit.make_sound(self, "death")
			mobkit.hq_die(self)
			return
		end

		if mobkit.timer(self, aerotest.hunt_intervall) and aerotest.hunter then
			if self.action == "fly" or self.action == "glide" then
				local gotone = aerotest.look_for_prey(self)
				if gotone then
					mobkit.clear_queue_low(self)
					mobkit.clear_queue_high(self)
					aerotest.hq_hunt(self, 1, gotone)
				end
			end
		end

		if mobkit.timer(self, 1) then
			if self.action == "fly" or self.action == "glide" then
				local player = mobkit.get_nearby_player(self)
				if player and player:is_player() then
					local center = player:get_pos()
					local eagle = self.object:get_pos()
					center.y = eagle.y
					if vector.distance(center, eagle) > (aerotest.abr * 16 - 10) then
						mobkit.clear_queue_low(self)
						mobkit.clear_queue_high(self)
						aerotest.hq_keepinrange(self, 10, center)
					end
				end
			end

			local meal = random(100)
			if (meal > self.hunger) and aerotest.hunter then -- and not self.action == "range" then
				local gotone = aerotest.look_for_prey(self)
				if gotone then
					mobkit.clear_queue_low(self)
					mobkit.clear_queue_high(self)
					aerotest.hq_hunt(self, 10, gotone)
				end
			end

			if aerotest.radar_debug then
				update_nametag(self)
			end

			if random(100) < 2 then mobkit.make_sound(self, 'cry') end
			local pos = self.object:get_pos()
			local player = mobkit.get_nearby_player(self)
			if self.action == "idle" and
				player and vector.distance(pos, player:get_pos()) < 8 and not aerotest.radar_debug
			then
				mobkit.clear_queue_low(self)
				mobkit.clear_queue_high(self)
				aerotest.hq_takeoff(self, rad(random(360)), 10) -- panic takeoff
				-- aerotest.hq_idle(self, 10, true)
			end
			if vector.length(self.object:get_velocity()) < 2 and
				self.action ~= "idle" and self.action ~= "search"
			then --[[self.object:remove() end]]
				mobkit.clear_queue_low(self)
				mobkit.clear_queue_high(self)
				mobkit.hurt(self, 5)
				if aerotest.radar_debug then
					update_nametag(self)
				end
				aerotest.hq_idle(self, 1)
			end
			mobkit.remember(self, "hunger", self.hunger)
			mobkit.remember(self, "xhaust", self.xhaust)
		end
		if mobkit.is_queue_empty_high(self) then
			if self.action == "idle" then
				if self.isinliquid then
					local yaw = self.object:get_yaw()
					aerotest.hq_takeoff(self, yaw, 5)
				elseif not self.isonground then
					aerotest.hq_climb(self, 1)
				else
					aerotest.hq_idle(self, 1)
				end
			else
				aerotest.hq_climb(self, 1)
			end
		end
	end,

	on_punch = function(self, puncher, time_from_last_punch, tool_capabilities, dir)
		if mobkit.is_alive(self) then
			if time_from_last_punch < 1 then return end
			local hvel = vector.multiply(vector.normalize({x = dir.x, y = 0, z = dir.z}), 4)
			self.object:set_velocity({x = hvel.x, y = 2, z = hvel.z})

			mobkit.hurt(self, tool_capabilities.damage_groups.fleshy or 1)

			if aerotest.radar_debug then
				update_nametag(self.object)
			end
			if self.isonground or self.isinliquid then
				mobkit.clear_queue_high(self)
				aerotest.hq_takeoff(self, rad(random(360)), 20, 6)
			end

			if self.hp <= 0 and ranking then
				if puncher:is_player() then
					local score = math.ceil(self.max_hp / 10)
					if score > 50 then score = 50 end
					ranking.increase_rank(puncher, "hunter", score)
				elseif throwing then
					local shooter = throwing.playerArrows[puncher]
					if shooter then
						local score = math.ceil(self.max_hp / 10) + 5
						if score > 50 then score = 50 end
						ranking.increase_rank(minetest.get_player_by_name(shooter), "hunter", score) -- Something extra for shooting arrows
					end
				end
			end
		end
	end
})

aerotest.names = {
	"Akita Yoshinobu", "Dyrnwyn", "Johnny Corkscrew", "Vorpal Sword", "Seraph Blades", "Glorious",
	"Chance", "Blackfyre", "Brightroar", "Dark Sister", "Lightbringer", "Needle", "Glamdring", "Sting",
	"Cortana", "Heosphorous", "Phaesphoros", "Maellartach", "The Crystal Sword", "Flarecore", "Dragnipur",
	"Hadhafang", "Zirael", "Spike Sword", "Master Sword", "Dragon Buster", "The Ice Sword", "Zangetsu"
}

-- https://bitbucket.org/minetest_gamers/diamonds/src/master/
minetest.register_tool("aerotest:sword", {
	description = "Super Diamond Sword",
	groups = {sword = 1, not_in_creative_inventory = 1},
	inventory_image = "aerotest_sword.png",
	range = 5,
	light_source = 8,
	tool_capabilities = {
		full_punch_interval = 0.4,
		max_drop_level = 3,
		groupcaps = {
			fleshy = {times = {[1] = 1.9, [2] = 0.5, [3] = 0.2}, uses = 700, maxlevel = 3},
			snappy = {times = {[1] = 1.8, [2] = 0.6, [3] = 0.2}, uses = 650, maxlevel = 3},
			choppy = {times = {[3] = 0.55}, uses = 600, maxlevel = 0}
		},
		damage_groups = {fleshy = 12}
	}
})