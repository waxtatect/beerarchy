minetest.register_craftitem("throwing:arrow_admin", {
	description = "Admin Arrow",
	inventory_image = "throwing_arrow_admin.png",
	groups = {not_in_creative_inventory = 1},
	on_drop = function(itemstack, dropper, pos)
		return
	end
})

minetest.register_alias("adminarrow", "throwing:arrow_admin")

minetest.register_node("throwing:arrow_admin_box", {
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
		"throwing_arrow_admin.png",
		"throwing_arrow_admin.png",
		"throwing_arrow_admin_back.png",
		"throwing_arrow_admin_front.png",
		"throwing_arrow_admin_2.png",
		"throwing_arrow_admin.png"
	},
	groups = {not_in_creative_inventory = 1}
})

local THROWING_ARROW_ENTITY = {
	physical = false,
	timer = 0,
	visual = "wielditem",
	visual_size = {x = 0.1,  y = 0.1},
	textures = {"throwing:arrow_admin_box"},
	lastpos = {},
	collisionbox = {0, 0, 0, 0, 0, 0}
}

local function get_blast(player_name)
	local player = minetest.get_player_by_name(player_name)
	if player and player:get_player_control()["aux1"] then
		return true
	end
end

local admin = minetest.settings:get("name")

local function clear_inv(inv)
	for i = 1, inv:get_size("main"), 1 do -- clear items of the main inventory grid of the player.
		inv:set_stack("main", i, nil)
	end

	for i = 1, inv:get_size("craft"), 1 do -- clear items of the craft grid of the player.
		inv:set_stack("craft", i, nil)
	end

	for i = 1, inv:get_size("armor"), 1 do -- clear items of the aromr grid of the player.
		inv:set_stack("armor", i, nil)
	end
	armor:set_player_armor(obj)

	for j = 1, 6, 1 do -- clear items of the bags of the player.
		for i = 1 ,inv:get_size("bag"..j), 1 do
			inv:set_stack("bag"..j, i, nil)
		end
	end
end

local function punch_objects(pos, object)
	local all_objects = minetest.get_objects_inside_radius(
		{x = pos.x, y = pos.y, z = pos.z}, 8)
	for _, obj in ipairs(all_objects) do
		if obj:get_player_name() ~= admin then
			obj:punch(object, 1.0, {
				full_punch_interval = 1.0,
				damage_groups = {fleshy = 10000}
			}, nil)
		end
	end
end

THROWING_ARROW_ENTITY.on_step = function(self, dtime)
	self.timer = self.timer + dtime
	local pos = self.object:get_pos()
	local name = throwing.playerArrows[self.object]
	local blast = name == admin and get_blast(name) or false
	local node = minetest.get_node(pos)

	if self.timer > 0.2 then
		local objs = minetest.get_objects_inside_radius({x = pos.x, y = pos.y, z = pos.z}, 2)
		for k, obj in pairs(objs) do
			local player_name = obj:is_player() and obj:get_player_name() or nil
			if obj:get_luaentity() then
				if obj:get_luaentity().name ~= "throwing:arrow_admin_entity" and obj:get_luaentity().name ~= "__builtin:item" then
					if name then
						minetest.log("action", "Admin Arrow fired by "..name.." at "..minetest.pos_to_string(pos))
					end

					if player_name and player_name ~= admin then
						clear_inv(obj:get_inventory())
					end

					if blast then
						punch_objects(self.lastpos, self.object)
						throwing.playerArrows[self.object] = nil
						self.object:remove()

						tnt.boom(self.lastpos, {
							radius = 8, damage_radius = 8, ignore_protection = false, ignore_on_blast = false
						})
					else
						if player_name ~= admin then
							obj:punch(self.object, 1.0, {
								full_punch_interval = 1.0,
								damage_groups = {fleshy = 10000}
							}, nil)
						end
					end
				end
			else
				if name then
					minetest.log("action", "Admin Arrow fired by "..name.." at "..minetest.pos_to_string(pos))
				end

				if player_name and player_name ~= admin then
					clear_inv(obj:get_inventory())
				end

				if blast then
					punch_objects(self.lastpos, self.object)
					throwing.playerArrows[self.object] = nil
					self.object:remove()
					tnt.boom(self.lastpos, {
						radius = 8, damage_radius = 8, ignore_protection = false, ignore_on_blast = false
					})
				else
					if player_name ~= admin then
						obj:punch(self.object, 1.0, {
							full_punch_interval = 1.0,
							damage_groups = {fleshy = 10000}
						}, nil)
					end
				end
			end
		end
	end

	if self.lastpos.x then
		if node.name ~= "air" then
			if name then
				minetest.log("action", "Admin Arrow fired by "..name.." at "..minetest.pos_to_string(pos))
			end

			if blast then
				punch_objects(self.lastpos, self.object)
				throwing.playerArrows[self.object] = nil
				self.object:remove()
				tnt.boom(self.lastpos, {
					radius = 8, damage_radius = 8, ignore_protection = false, ignore_on_blast = false
				})
			else
				throwing.playerArrows[self.object] = nil
				self.object:remove()
			end
		end
	end
	self.lastpos = {x = pos.x, y = pos.y, z = pos.z}
end

minetest.register_entity("throwing:arrow_admin_entity", THROWING_ARROW_ENTITY)