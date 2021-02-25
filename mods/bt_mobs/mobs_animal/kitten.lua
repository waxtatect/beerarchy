local S = mobs.intllib
local hairball = minetest.settings:get_bool("mobs_hairball", true)

-- Kitten by Jordach / BFD

mobs:register_mob("mobs_animal:kitten", {
	stepheight = 2.1,
	type = "npc",
	attack_type = "dogshoot",
	jump_height = 6,
	hp_min = 5000,
	hp_max = 5000,
	collisionbox = {-0.3, -0.3, -0.3, 0.3, 0.1, 0.3},
	visual = "mesh",
	visual_size = {x = 0.5, y = 0.5},
	mesh = "mobs_kitten.b3d",
	view_range = 16,
	walk_velocity = 0.6,
	run_velocity = 8,
	damage = 8,
	fall_damage	= 0,
	drops = {
		{name = "farming:string", chance = 5, min = 1, max = 1}
	},
	armor = 5000,
	arrow = "horror:fireball_2",
	shoot_interval = 0.5,
	sounds = {random = "mobs_kitten"},
	animation = {
		speed_normal = 42,
		stand_start = 97,
		stand_end = 192,
		walk_start = 0,
		walk_end = 96,
		stoodup_start = 0,
		stoodup_end = 0
	},
	follow = {"mobs_animal:rat", "fishing:bluewhite_raw", "fishing:carp_raw", "fishing:catfish_raw", "fishing:clownfish_raw", "fishing:exoticfish_raw",
			  "fishing:fish_cooked", "fishing:fish_raw", "fishing:perch_raw", "fishing:pike_cooked", "fishing:pike_raw"},
	knock_back = false,
	shoot_offset = 2,
	reach = 3,
	textures = {
		{"mobs_kitten_striped.png"},
		{"mobs_kitten_splotchy.png"},
		{"mobs_kitten_ginger.png"},
		{"mobs_kitten_sandy.png"}
	},
	dogshoot_switch = 1,
	dogshoot_count_max = 1,
	group_attack = true,
	attacks_monsters = true,
	friendly_fire = true,
	owner_loyal = true,
	on_rightclick = function(self, clicker)
		if mobs:feed_tame(self, clicker, 200, true, true) then return end
		if mobs:protect(self, clicker) then return end
		-- by pressing sneak key and right-clicking owner can switch between staying and walking
		if clicker:get_player_control().sneak and self.owner and self.owner == clicker:get_player_name() then
			local kitten_name = self.name:split(":")[2]:gsub("^%l", string.upper)
			if self.nametag and self.nametag ~= "" and not (self.nametag == ("♥ " .. self.health .. " / " .. self.hp_max)) then
				kitten_name = self.nametag
			end
			if self.order ~= "stand" then
				self.attack = nil
				self.order = "stand"
				self.state = "stand"
				self:set_velocity(0)
				self:set_animation("stand")
				minetest.chat_send_player(self.owner, S("@1 stands still.", kitten_name))
			else
				self.order = ""
				minetest.chat_send_player(self.owner, S("@1 will move.", kitten_name))
			end
			return
		end
		if mobs:capture_mob(self, clicker, 50, 50, 50, false, nil) then return end
	end,
	do_custom = function(self, dtime)
		if not hairball then
			return
		end

		self.hairball_timer = (self.hairball_timer or 0) + dtime
		if self.hairball_timer < 10 then
			return
		end
		self.hairball_timer = 0

		if self.child
			or math.random(1, 250) > 1
		then
			return
		end

		local pos = self.object:get_pos()

		minetest.add_item(pos, "mobs:hairball")

		minetest.sound_play("default_dig_snappy", {
			pos = pos,
			gain = 1.0,
			max_hear_distance = 5
		})
	end
})

local spawn_on = "default:dirt_with_grass"

if minetest.get_modpath("ethereal") then
	spawn_on = "ethereal:grove_dirt"
end

mobs:spawn({
	name = "mobs_animal:kitten",
	nodes = {spawn_on},
	neighbors = {"group:grass"},
	min_light = 14,
	interval = 60,
	chance = 60000,
	min_height = 0,
	max_height = 31000,
	day_toggle = true
})

mobs:register_egg("mobs_animal:kitten", S("Cash's World Overlord Kitten"), "mobs_kitten_inv.png", 0)

mobs:alias_mob("mobs:kitten", "mobs_animal:kitten") -- compatibility

local hairball_items = {
	"default:stick", "default:coal_lump", "default:dry_shrub", "flowers:rose",
	"mobs_animal:rat", "default:grass_1", "farming:seed_wheat", "dye:green", "",
	"farming:seed_cotton", "default:flint", "default:sapling", "dye:white", "",
	"default:clay_lump", "default:paper", "default:dry_grass_1", "dye:red", "",
	"farming:string", "mobs:chicken_feather", "default:acacia_bush_sapling", "",
	"default:bush_sapling", "default:copper_lump", "default:iron_lump", "",
	"dye:black", "dye:brown", "default:obsidian_shard", "default:tin_lump"
}

minetest.register_craftitem(":mobs:hairball", {
	description = S("Hairball"),
	inventory_image = "mobs_hairball.png",
	on_use = function(itemstack, user, pointed_thing)
		local pos = user:get_pos()
		local dir = user:get_look_dir()
		local newpos = {x = pos.x + dir.x, y = pos.y + dir.y + 1.5, z = pos.z + dir.z}
		local item = hairball_items[math.random(1, #hairball_items)]

		if item ~= "" then
			minetest.add_item(newpos, {name = item})
		end

		minetest.sound_play("default_place_node_hard", {
			pos = newpos,
			gain = 1.0,
			max_hear_distance = 5
		}, true)

		itemstack:take_item()

		return itemstack
	end
})