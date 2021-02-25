minetest.register_craftitem("throwing:arrow_tnt", {
	description = "TNT Arrow",
	inventory_image = "throwing_arrow_tnt.png"
})

minetest.register_node("throwing:arrow_tnt_box", {
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			-- Shaft
			{-6.5/17, -1.5/17, -1.5/17, 6.5/17, 1.5/17, 1.5/17},
			-- Spitze
			{-4.5/17, 2.5/17, 2.5/17, -3.5/17, -2.5/17, -2.5/17},
			{-8.5/17, 0.5/17, 0.5/17, -6.5/17, -0.5/17, -0.5/17},
			-- Federn
			{6.5/17, 1.5/17, 1.5/17, 7.5/17, 2.5/17, 2.5/17},
			{7.5/17, -2.5/17, 2.5/17, 6.5/17, -1.5/17, 1.5/17},
			{7.5/17, 2.5/17, -2.5/17, 6.5/17, 1.5/17, -1.5/17},
			{6.5/17, -1.5/17, -1.5/17, 7.5/17, -2.5/17, -2.5/17},

			{7.5/17, 2.5/17, 2.5/17, 8.5/17, 3.5/17, 3.5/17},
			{8.5/17, -3.5/17, 3.5/17, 7.5/17, -2.5/17, 2.5/17},
			{8.5/17, 3.5/17, -3.5/17, 7.5/17, 2.5/17, -2.5/17},
			{7.5/17, -2.5/17, -2.5/17, 8.5/17, -3.5/17, -3.5/17}
		}
	},
	tiles = {
		"throwing_arrow_tnt.png",
		"throwing_arrow_tnt.png",
		"throwing_arrow_tnt_back.png",
		"throwing_arrow_tnt_front.png",
		"throwing_arrow_tnt_2.png",
		"throwing_arrow_tnt.png"
	},
	groups = {not_in_creative_inventory = 1}
})

local THROWING_ARROW_ENTITY = {
	physical = false,
	timer = 0,
	visual = "wielditem",
	visual_size = {x = 0.1,  y = 0.1},
	textures = {"throwing:arrow_tnt_box"},
	lastpos = {},
	collisionbox = {0, 0, 0, 0, 0, 0}
}

local admin = minetest.settings:get("name")

local toughNodes = {
	["default:obsidian"] = "default:obsidian",
	["default:obsidian_block"] = "default:obsidian_block",
	["default:obsidian_glass"] = "default:obsidian_glass",
	["default:obsidianbrick"] = "default:obsidianbrick",
	["doors:door_obsidian_glass_a"] = "doors:door_obsidian_glass_a",
	["doors:door_obsidian_glass_b"] = "doors:door_obsidian_glass_b",
	["doors:door_obsidian_glass_c"] = "doors:door_obsidian_glass_c",
	["doors:door_obsidian_glass_d"] = "doors:door_obsidian_glass_d",
	["protector:chest"] = "protector:chest",
	["protector:door_steel_b_1"] = "protector:door_steel_b_1",
	["protector:door_steel_b_2"] = "protector:door_steel_b_2",
	["protector:door_steel_t_1"] = "protector:door_steel_t_1",
	["protector:door_steel_t_2"] = "protector:door_steel_t_2",
	["protector:door_wood_b_1"] = "protector:door_wood_b_1",
	["protector:door_wood_b_2"] = "protector:door_wood_b_2",
	["protector:door_wood_t_1"] = "protector:door_wood_t_1",
	["protector:door_wood_t_2"] = "protector:door_wood_t_2",
	["protector:protect"] = "protector:protect",
	["protector:protect2"] = "protector:protect2",
	["protector:trapdoor"] = "protector:trapdoor",
	["protector:trapdoor_steel"] = "protector:trapdoor_steel",
	["stairs:slab_obsidian"] = "stairs:slab_obsidian",
	["stairs:slab_obsidian"] = "stairs:slab_obsidian",
	["stairs:slab_obsidian_block"] = "stairs:slab_obsidian_block",
	["stairs:slab_obsidianbrick"] = "stairs:slab_obsidianbrick",
	["stairs:stair_obsidian"] = "stairs:stair_obsidian",
	["stairs:stair_obsidian_block"] = "stairs:stair_obsidian_block",
	["stairs:stair_obsidianbrick"] = "stairs:stair_obsidianbrick"
}

local function punch_objects(pos, object, damage)
	local all_objects = minetest.get_objects_inside_radius(
		{x = pos.x, y = pos.y, z = pos.z}, 3)
	for _, obj in ipairs(all_objects) do
		if obj:get_player_name() ~= admin then
			obj:punch(object, 1.0, {
				full_punch_interval = 1.0,
				damage_groups = {fleshy = damage}
			}, nil)
		end
	end
end

local function get_ignore_protection(player_name)
	local player = minetest.get_player_by_name(player_name)
	if player and player:get_player_control()["aux1"] then
		return true
	end
	return false
end

THROWING_ARROW_ENTITY.on_step = function(self, dtime)
	self.timer = self.timer + dtime
	local pos = self.object:get_pos()
	local name = throwing.playerArrows[self.object]
	local is_admin = name == admin and name or nil
	local ignore_protection = get_ignore_protection(name)
	local node = minetest.get_node(pos)

	if self.timer > 0.2 then
		local objs = minetest.get_objects_inside_radius({x = pos.x, y = pos.y, z = pos.z}, 2)
		for k, obj in pairs(objs) do
			if obj:get_luaentity() then
				if obj:get_luaentity().name ~= "throwing:arrow_tnt_entity" and obj:get_luaentity().name ~= "__builtin:item" then
					local extra_damage, extra_radius = 0, 0
					if name then
						extra_damage = ranking.playerXP[name] + math.random(0, 5)
						extra_radius = math.floor((ranking.playerXP[name] + 1) / 8) + math.random(-1, 0)
						if math.random(20) == 1 then
							extra_damage = extra_damage + math.random(5, 10)
							extra_radius = extra_radius + 1
						end
					end
					local damage = 3 + extra_damage
					if obj:get_player_name() ~= admin then
						obj:punch(self.object, 1.0, {
							full_punch_interval = 1.0,
							damage_groups = {fleshy = damage}
						}, nil)
					end
					if not minetest.is_protected(pos, is_admin) then
						tnt.boom(self.lastpos, {
							radius = 3 + extra_radius, damage_radius = 5 + extra_radius, ignore_protection = ignore_protection, ignore_on_blast = false
						})
					end
					throwing.playerArrows[self.object] = nil
					self.object:remove()
				end
			else
				local extra_damage, extra_radius = 0, 0
				if name then
					extra_damage = ranking.playerXP[name] + math.random(0, 5)
					extra_radius = math.floor((ranking.playerXP[name] + 1) / 8) + math.random(-1, 0)
					if math.random(20) == 1 then
						extra_damage = extra_damage + math.random(5, 10)
						extra_radius = extra_radius + 1
					end
				end
				local damage = 5 + extra_damage
				if obj:get_player_name() ~= admin then
					obj:punch(self.object, 1.0, {
						full_punch_interval = 1.0,
						damage_groups = {fleshy = damage}
					}, nil)
				end
				if not minetest.is_protected(pos, is_admin) then
					tnt.boom(self.lastpos, {
						radius = 3 + extra_radius, damage_radius = 5 + extra_radius, ignore_protection = ignore_protection, ignore_on_blast = false
					})
				end
				throwing.playerArrows[self.object] = nil
				self.object:remove()
			end
		end
	end

	if self.lastpos.x then
		if node.name ~= "air" then
			if toughNodes[node.name] or minetest.find_node_near({x = pos.x, y = pos.y, z = pos.z}, 2, toughNodes) then
				local extra_damage = 0
				if name then
					extra_damage = ranking.playerXP[name] + math.random(0, 1)
				end
				local damage = 5 + extra_damage
				punch_objects(self.lastpos, self.object, damage)

				if not minetest.is_protected(self.lastpos, is_admin) then
					tnt.boom(self.lastpos, {
						radius = 3, damage_radius = 3, ignore_protection = ignore_protection, ignore_on_blast = false
					})
				end
				throwing.playerArrows[self.object] = nil
				self.object:remove()
			else
				local extra_damage, extra_radius = 0, 0
				if name then
					extra_damage = ranking.playerXP[name] + math.random(0, 1)
					extra_radius = math.floor((ranking.playerXP[name] + 1) / 8) + math.random(-1, 0)
					if math.random(20) == 1 then
						extra_damage = extra_damage + math.random(1, 2)
						extra_radius = extra_radius + 1
					end
				end
				local damage = 1 + extra_damage
				punch_objects(self.lastpos, self.object, damage)

				if not minetest.is_protected(pos, is_admin) then
					tnt.boom(self.lastpos, {
						radius = 3 + extra_radius, damage_radius = 5 + extra_radius, ignore_protection = ignore_protection, ignore_on_blast = false
					})
				end
				throwing.playerArrows[self.object] = nil
				self.object:remove()
			end
		end
	end
	self.lastpos = {x = pos.x, y = pos.y, z = pos.z}
end

minetest.register_entity("throwing:arrow_tnt_entity", THROWING_ARROW_ENTITY)

minetest.register_craft({
	output = "throwing:arrow_tnt 1",
	recipe = {
		{"default:obsidian_shard", "default:obsidian_shard", "tnt:tnt"}
	}
})