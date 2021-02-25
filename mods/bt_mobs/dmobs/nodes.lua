--Golem

minetest.register_node("dmobs:golemstone", {
	description = "Golem Stone",
	tiles = {"dmobs_golem_stone.png",},
	groups = {cracky=1},
	on_construct = function(pos, node, _)
		local node1 = minetest.get_node({x=pos.x, y=pos.y-1, z=pos.z}).name
		local node2 = minetest.get_node({x=pos.x, y=pos.y-2, z=pos.z}).name
		local node3 = minetest.get_node({x=pos.x, y=pos.y+1, z=pos.z}).name
		if node1 == "default:stone" and node2 == "default:stone" and node3 == "air" then
			minetest.add_entity(pos, "dmobs:golem_friendly")
			minetest.remove_node({x=pos.x, y=pos.y-1, z=pos.z})
			minetest.remove_node({x=pos.x, y=pos.y-2, z=pos.z})
			minetest.remove_node({x=pos.x, y=pos.y, z=pos.z})
		end
	end
})