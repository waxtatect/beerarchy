minetest.register_craftitem("throwing:arrow_tnt", {
	description = "TNT Arrow",
	inventory_image = "throwing_arrow_tnt.png",
})

minetest.register_node("throwing:arrow_tnt_box", {
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
	tiles = {"throwing_arrow_tnt.png", "throwing_arrow_tnt.png", "throwing_arrow_tnt_back.png", "throwing_arrow_tnt_front.png", "throwing_arrow_tnt_2.png", "throwing_arrow_tnt.png"},
	groups = {not_in_creative_inventory=1},
})

local THROWING_ARROW_ENTITY={
	physical = false,
	timer=0,
	visual = "wielditem",
	visual_size = {x=0.1, y=0.1},
	textures = {"throwing:arrow_tnt_box"},
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
				if obj:get_luaentity().name ~= "throwing:arrow_tnt_entity" and obj:get_luaentity().name ~= "__builtin:item" then
					local extra_damage = 0
					local extra_radius = 0
					if throwing.playerArrows[self.object] then
						extra_damage = ranking.playerXP[throwing.playerArrows[self.object]] + math.random(0, 5)
						extra_radius = math.floor((ranking.playerXP[throwing.playerArrows[self.object]] + 1) / 8) + math.random(-1, 0)
						if math.random(20) == 1 then
							extra_damage = extra_damage + math.random(5, 10)
							extra_radius = extra_radius + 1
						end
					end
					local damage = 5 + extra_damage
					obj:punch(self.object, 1.0, {
						full_punch_interval=1.0,
						damage_groups={fleshy=damage},
					}, nil)
					tnt.boom(pos, { radius = 3 + extra_radius, damage_radius = 5 + extra_radius, ignore_protection = false, ignore_on_blast = false })
					throwing.playerArrows[self.object] = nil
					self.object:remove()
				end
			else
				local extra_damage = 0
				local extra_radius = 0
				if throwing.playerArrows[self.object] then
					extra_damage = ranking.playerXP[throwing.playerArrows[self.object]] + math.random(0, 5)
					extra_radius = math.floor((ranking.playerXP[throwing.playerArrows[self.object]] + 1) / 8) + math.random(-1, 0)
					if math.random(20) == 1 then
						extra_damage = extra_damage + math.random(5, 10)
						extra_radius = extra_radius + 1
					end
				end
				local damage = 5 + extra_damage
				obj:punch(self.object, 1.0, {
					full_punch_interval=1.0,
					damage_groups={fleshy=damage},
				}, nil)
				tnt.boom(pos, { radius = 3 + extra_radius, damage_radius = 5 + extra_radius, ignore_protection = false, ignore_on_blast = false })
				throwing.playerArrows[self.object] = nil
				self.object:remove()
			end
		end
	end

	if self.lastpos.x~=nil then
		if node.name ~= "air" then
			local extra_damage = 0
			local extra_radius = 0
			if throwing.playerArrows[self.object] then
				extra_damage = ranking.playerXP[throwing.playerArrows[self.object]] + math.random(0, 1)
				extra_radius = math.floor((ranking.playerXP[throwing.playerArrows[self.object]] + 1) / 8) + math.random(-1, 0)
				if math.random(20) == 1 then
					extra_damage = extra_damage + math.random(1, 2)
					extra_radius = extra_radius + 1
				end
			end
			local damage = 1 + extra_damage

			local all_objects = minetest.get_objects_inside_radius({x=pos.x, y=pos.y, z=pos.z}, 5 + extra_radius)
			local _,obj
			for _,obj in ipairs(all_objects) do
				obj:punch(self.object, 1.0, {
					full_punch_interval=1.0,
					damage_groups={fleshy=damage},
				}, nil)
			end

			throwing.playerArrows[self.object] = nil
			self.object:remove()
			tnt.boom(self.lastpos, { radius = 3, damage_radius = 5, ignore_protection = false, ignore_on_blast = true })
		end
	end
	self.lastpos={x=pos.x, y=pos.y, z=pos.z}
end

minetest.register_entity("throwing:arrow_tnt_entity", THROWING_ARROW_ENTITY)

minetest.register_craft({
	output = "throwing:arrow_tnt 1",
	recipe = {
		{"default:obsidian_shard", "default:obsidian_shard", "tnt:tnt"},
	},
	replacements = {
		{"bucket:bucket_lava", "bucket:bucket_empty"}
	}
})
