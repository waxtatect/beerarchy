minetest.register_craftitem("throwing:arrow_dig", {
	description = "Dig Arrow",
	inventory_image = "throwing_arrow_dig.png"
})

minetest.register_node("throwing:arrow_dig_box", {
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
		"throwing_arrow_dig.png",
		"throwing_arrow_dig.png",
		"throwing_arrow_dig_back.png",
		"throwing_arrow_dig_front.png",
		"throwing_arrow_dig_2.png",
		"throwing_arrow_dig.png"
	},
	groups = {not_in_creative_inventory = 1}
})

local THROWING_ARROW_ENTITY = {
	physical = false,
	timer = 0,
	visual = "wielditem",
	visual_size = {x = 0.1,  y = 0.1},
	textures = {"throwing:arrow_dig_box"},
	lastpos = {},
	collisionbox = {0, 0, 0, 0, 0, 0}
}

local function addEffect(pos, node)
	if not node or node.name == "ignore" then return end
	minetest.sound_play("default_dug_node", {pos = pos, gain = 1, max_hear_distance = 2 * 64}, true)
	local node_tiles = minetest.registered_nodes[node.name].tiles
	if node_tiles then
		local texture = node_tiles[1]
		if type(texture) ~= "string" then return end
		minetest.add_particlespawner({
			amount = 7,
			time = 0.1,
			minpos = pos,
			maxpos = pos,
			minvel = {x = -5, y = -5, z = -5},
			maxvel = {x = 5, y = 5,  z = 5},
			minacc = {x = 0, y = -8, z = 0},
			maxacc = {x = 0, y = -8, z = 0},
			minexptime = 0.8,
			maxexptime = 2.0,
			minsize = 4,
			maxsize = 6,
			texture = texture,
			collisiondetection = true
		})
	end
end

local admin = minetest.settings:get("name")

THROWING_ARROW_ENTITY.on_step = function(self, dtime)
	self.timer = self.timer + dtime
	local pos = self.object:get_pos()
	local name = throwing.playerArrows[self.object]
	local protection_bypass = name == admin and name or nil
	local player = minetest.get_player_by_name(name)
	local node = minetest.get_node(pos)

	if self.timer > 0.2 then
		local objs = minetest.get_objects_inside_radius({x = pos.x, y = pos.y, z = pos.z}, 1)
		for k, obj in pairs(objs) do
			if obj:get_luaentity() then
				if obj:get_luaentity().name ~= "throwing:arrow_dig_entity" and obj:get_luaentity().name ~= "__builtin:item" then
					if not minetest.is_protected(pos, protection_bypass) then
						minetest.add_item(pos, 'throwing:arrow_dig')
						addEffect(pos, node)
						minetest.node_dig(pos, node, player)
					end
					throwing.playerArrows[self.object] = nil
					self.object:remove()
				end
			else
				if not minetest.is_protected(pos, protection_bypass) then
					minetest.add_item(pos, 'throwing:arrow_dig')
					addEffect(pos, node)
					minetest.node_dig(pos, node, player)
				end
				throwing.playerArrows[self.object] = nil
				self.object:remove()
			end
		end
	end

	if self.lastpos.x then
		if node.name ~= "air" then
			if not minetest.is_protected(pos, protection_bypass) then
				addEffect(pos, node)
				minetest.node_dig(pos, node, player)
			end
			throwing.playerArrows[self.object] = nil
			self.object:remove()
		end
	end
	self.lastpos = {x = pos.x, y = pos.y, z = pos.z}
end

minetest.register_entity("throwing:arrow_dig_entity", THROWING_ARROW_ENTITY)

minetest.register_craft({
	output = 'throwing:arrow_dig',
	recipe = {
		{'default:stick', 'default:stick', 'default:pick_steel'}
	}
})