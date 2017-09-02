minetest.register_craftitem("throwing:arrow_admin", {
	description = "Admin Arrow",
	inventory_image = "throwing_arrow_admin.png",
	groups = {not_in_creative_inventory=1},
})

minetest.register_node("throwing:arrow_admin_box", {
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			-- Shaft
			{-6.5/17, -1.5/17, -1.5/17, 6.5/17, 1.5/17, 1.5/17},
			--Spitze
			{-4.5/17, 2.5/17, 2.5/17, -3.5/17, -2.5/17, -2.5/17},
			{-8.5/17, 0.5/17, 0.5/17, -6.5/17, -0.5/17, -0.5/17},
			--Federn
			{6.5/17, 1.5/17, 1.5/17, 7.5/17, 2.5/17, 2.5/17},
			{7.5/17, -2.5/17, 2.5/17, 6.5/17, -1.5/17, 1.5/17},
			{7.5/17, 2.5/17, -2.5/17, 6.5/17, 1.5/17, -1.5/17},
			{6.5/17, -1.5/17, -1.5/17, 7.5/17, -2.5/17, -2.5/17},

			{7.5/17, 2.5/17, 2.5/17, 8.5/17, 3.5/17, 3.5/17},
			{8.5/17, -3.5/17, 3.5/17, 7.5/17, -2.5/17, 2.5/17},
			{8.5/17, 3.5/17, -3.5/17, 7.5/17, 2.5/17, -2.5/17},
			{7.5/17, -2.5/17, -2.5/17, 8.5/17, -3.5/17, -3.5/17},
		}
	},
	tiles = {"throwing_arrow_admin.png", "throwing_arrow_admin.png", "throwing_arrow_admin_back.png", "throwing_arrow_admin_front.png", "throwing_arrow_admin_2.png", "throwing_arrow_admin.png"},
	groups = {not_in_creative_inventory=1},
})

local THROWING_ARROW_ENTITY={
	physical = false,
	timer=0,
	visual = "wielditem",
	visual_size = {x=0.1, y=0.1},
	textures = {"throwing:arrow_admin_box"},
	lastpos={},
	collisionbox = {0,0,0,0,0,0},
}

THROWING_ARROW_ENTITY.on_step = function(self, dtime)
	self.timer=self.timer+dtime
	local pos = self.object:getpos()
	local node = minetest.env:get_node(pos)

	if self.timer>0.2 then
		local objs = minetest.env:get_objects_inside_radius({x=pos.x,y=pos.y,z=pos.z}, 2)
		for k, obj in pairs(objs) do
			if obj:get_luaentity() ~= nil then
				if obj:get_luaentity().name ~= "throwing:arrow_admin_entity" and obj:get_luaentity().name ~= "__builtin:item" then
					local blast = false
					if throwing.playerArrows[self.object] then
						minetest.log("action", "Admin Arrow fired by "..throwing.playerArrows[self.object].." at "..minetest.serialize(pos))
						local player = minetest.get_player_by_name(throwing.playerArrows[self.object])
						if player and player:get_player_control()["aux1"] then blast = true end
					end

					if blast then
						local all_objects = minetest.get_objects_inside_radius({x=self.lastpos.x, y=self.lastpos.y, z=self.lastpos.z}, 8)
						local _,obj
						for _,obj in ipairs(all_objects) do
							obj:punch(self.object, 1.0, {
								full_punch_interval=1.0,
								damage_groups={fleshy=10000},
							}, nil)
						end

						throwing.playerArrows[self.object] = nil
						self.object:remove()

						tnt.boom(pos, { radius = 8, damage_radius = 8, ignore_protection = true, ignore_on_blast = false })
					else
						obj:punch(self.object, 1.0, {
							full_punch_interval=1.0,
							damage_groups={fleshy=10000},
						}, nil)
					end
				end
			else
				local blast = false
				if throwing.playerArrows[self.object] then
					minetest.log("action", "Admin Arrow fired by "..throwing.playerArrows[self.object].." at "..minetest.serialize(pos))
					local player = minetest.get_player_by_name(throwing.playerArrows[self.object])
					if player and player:get_player_control()["aux1"] then blast = true end
				end

				if blast then
					local all_objects = minetest.get_objects_inside_radius({x=self.lastpos.x, y=self.lastpos.y, z=self.lastpos.z}, 8)
					local _,obj
					for _,obj in ipairs(all_objects) do
						obj:punch(self.object, 1.0, {
							full_punch_interval=1.0,
							damage_groups={fleshy=10000},
						}, nil)
					end

					throwing.playerArrows[self.object] = nil
					self.object:remove()

					tnt.boom(pos, { radius = 8, damage_radius = 8, ignore_protection = true, ignore_on_blast = false })
				else
					obj:punch(self.object, 1.0, {
						full_punch_interval=1.0,
						damage_groups={fleshy=10000},
					}, nil)
				end
			end
		end
	end

	if self.lastpos.x~=nil then
		if node.name ~= "air" then
			local blast = false
			if throwing.playerArrows[self.object] then
				minetest.log("action", "Admin Arrow fired by "..throwing.playerArrows[self.object].." at "..minetest.serialize(pos))
				local player = minetest.get_player_by_name(throwing.playerArrows[self.object])
				if player and player:get_player_control()["aux1"] then blast = true end
			end

			if blast then
				local all_objects = minetest.get_objects_inside_radius({x=self.lastpos.x, y=self.lastpos.y, z=self.lastpos.z}, 8)
				local _,obj
				for _,obj in ipairs(all_objects) do
					obj:punch(self.object, 1.0, {
						full_punch_interval=1.0,
						damage_groups={fleshy=10000},
					}, nil)
				end

				throwing.playerArrows[self.object] = nil
				self.object:remove()

				tnt.boom(pos, { radius = 8, damage_radius = 8, ignore_protection = false, ignore_on_blast = false })
			else
				throwing.playerArrows[self.object] = nil
				self.object:remove()
			end
		end
	end
	self.lastpos={x=pos.x, y=pos.y, z=pos.z}
end

minetest.register_entity("throwing:arrow_admin_entity", THROWING_ARROW_ENTITY)
