--butterflies

local function define_pos(pos, v)
	return {
		x = -math.sin(v * pos.y),
		y = math.cos(v * pos.x),
		z = -math.sin(v * pos.y)
	}
end

minetest.register_entity("dmobs:butterfly", {
	visual = "mesh",
	mesh = "butterfly.b3d",
	physical = true,
	textures = {"dmobs_butterfly.png"},
	visual_size = {x = 0.3, y = 0.3},
	on_activate = function(self)
		local num = math.random(1, 4)
		self.object:set_properties({textures = {"dmobs_butterfly" .. num .. ".png"}})
		self.object:set_animation({x = 1, y = 10}, 20, 0)
		self.object:set_yaw(math.pi + num)
		minetest.after(10, function() self.object:remove() end)
	end,
	on_step = function(self)
		local num = math.random(-math.pi, math.pi)
		local pos = self.object:get_pos()
		local vec = self.object:get_velocity()
		self.object:set_yaw(math.pi + num)
		self.object:set_velocity(define_pos(pos, 12))
		self.object:set_acceleration(define_pos(vec, 6))
	end,
	collisionbox = {0, 0, 0, 0, 0.1, 0}
})

minetest.register_abm({
	label = "Butterfly spawn",
	nodenames = {"group:flower"},
	interval = 10,
	chance = 10,
	action = function(pos, node, active_object_count, active_object_count_wider)
		minetest.add_entity({x = pos.x, y = pos.y + 0.3, z = pos.z}, "dmobs:butterfly")
	end
})