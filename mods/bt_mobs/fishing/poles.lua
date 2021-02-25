-----------------------------------------------------------------------------------------------
-- Fishing Pole
-----------------------------------------------------------------------------------------------
local baits = fishing.baits
local contest = fishing.contest
local func = fishing.func
local S = func.S
local settings = fishing.settings

fishing.poles = {
	wood = {
		bobber_max = 2,
		desc = S("Fishing Pole"),
		groups = {pole = 1, flammable = 2},
		groups_deco = {not_in_creative_inventory = 1, flammable = 2},
		name = "wood",
		max_use = 30
	},
	perfect = {
		bobber_max = 5,
		desc = S("Perfect Fishing Pole"),
		groups = {pole = 1},
		groups_deco = {not_in_creative_inventory = 1},
		name = "perfect",
		max_use = 1500
	}
}

for _, pole in pairs(fishing.poles) do
	local bobbermax = pole.bobber_max
	minetest.register_tool("fishing:pole_" .. pole.name, {
		description = pole.desc,
		groups = pole.groups,
		inventory_image = "fishing_pole_" .. pole.name .. ".png",
		wield_image = "fishing_pole_" .. pole.name .. ".png",
		stack_max = 1,
		liquids_pointable = true,
		on_use = function (itemstack, user, pointed_thing)
			if pointed_thing and pointed_thing.under then
				local pt = pointed_thing
				local node = minetest.get_node_or_nil(pt.under)
				if not node or string.find(node.name, "water_source") == nil then return end
				local player_name = user:get_player_name()
				local inv = user:get_inventory()
				local bait = inv:get_stack("main", user:get_wield_index() + 1):get_name()
				if baits[bait] == nil then return end

				local objs = minetest.get_objects_inside_radius(pt.under, 1)
				for m, obj in pairs(objs) do
					if obj:get_luaentity() and string.find(obj:get_luaentity().name, "fishing:bobber") then
						if settings.message then
							minetest.chat_send_player(player_name, S("Sorry, there is another bobber!"))
						end
						return
					end
				end

				-- if contest then player must have only 2 boober
				local bobber_nb, bobber_max = 0, nil
				if contest.contest then
					bobber_max = contest.bobber_nb
				else
					bobber_max = bobbermax
				end
				-- player has others bobbers?
				for m, obj in pairs(minetest.get_objects_inside_radius(pt.under, 20)) do
					if obj:get_luaentity() and string.find(obj:get_luaentity().name, "fishing:bobber") then
						if obj:get_luaentity().owner == player_name then
							bobber_nb = bobber_nb + 1
						end
					end
				end
				if bobber_nb >= bobber_max then
					if settings.message then
						minetest.chat_send_player(player_name, S("You don't have mores @1 bobbers!", bobber_max))
					end
					return
				end

				local nodes = 1
				for _, k in pairs({{1, 0}, {-1, 0}, {0, 1}, {0, -1}}) do
					local node_name = minetest.get_node({x=pt.under.x+k[1], y=pt.under.y, z=pt.under.z+k[2]}).name
					if node_name and string.find(node_name, "water_source")
						and minetest.get_node({x=pt.under.x+k[1], y=pt.under.y+1, z=pt.under.z+k[2]}).name == "air"
					then
						nodes = nodes + 1
					end
				end
				-- if water == -3 nodes
				if nodes < 2 then
					if settings.message then
						minetest.chat_send_player(player_name, S("You don't fishing in a bottle!"))
					end
					return
				end
				local new_pos = {x=pt.under.x, y=pt.under.y+(45/64), z=pt.under.z}
				local ent = minetest.add_entity({interval = 1, x=new_pos.x, y=new_pos.y, z=new_pos.z}, baits[bait].bobber)
				if not ent then return end
				local luaentity = ent:get_luaentity()
				local node = minetest.get_node_or_nil(pt.under)
				if node and node.name == "default:river_water_source" then
					luaentity.water_type = "rivers"
				else
					luaentity.water_type = "sea"
				end
				luaentity.owner = player_name
				luaentity.bait = bait
				luaentity.old_pos = new_pos
				luaentity.old_pos2 = true
				if not func.creative(player_name) then
					inv:remove_item("main", bait)
				end
				minetest.sound_play("fishing_bobber2", {pos = new_pos, gain = 0.5}, true)
				if settings.wear_out and not func.creative(player_name) then
					itemstack:add_wear(65535 / (pole.max_use - 1))
					return itemstack
				end
			end
			return
		end,
		on_place = function(itemstack, placer, pointed_thing)
			if not settings.simple_deco_fishing_pole then return end
			local pt = pointed_thing
			local pt_under_name = minetest.get_node(pt.under).name
			if string.find(pt_under_name, "water_") == nil then
				local wear = itemstack:get_wear()
				local direction = minetest.dir_to_facedir(placer:get_look_dir())
				local dir = minetest.facedir_to_dir(direction)
				local p = vector.add(pt.above, dir)
				local n2 = minetest.get_node_or_nil(p)
				local def = n2 and minetest.registered_items[n2.name]
				if not def or not def.buildable_to then
					return
				end
				minetest.set_node(pt.above, {name = "fishing:pole_" .. pole.name .. "_deco", param2 = direction})
				local meta = minetest.get_meta(pt.above)
				meta:set_int("wear", wear)
				if not func.creative(placer:get_player_name()) then
					itemstack:take_item()
				end
			end
			return itemstack
		end
	})
	minetest.register_node("fishing:pole_" .. pole.name .. "_deco", {
		description = pole.desc,
		inventory_image = "fishing_pole_" .. pole.name .. ".png",
		wield_image = "fishing_pole.png^[transformFXR270",
		drawtype = "nodebox",
		paramtype = "light",
		paramtype2 = "facedir",
		tiles = {
			"fishing_pole_" .. pole.name .. "_simple.png",
			"fishing_pole_" .. pole.name .. "_simple.png",
			"fishing_pole_" .. pole.name .. "_simple.png",
			"fishing_pole_" .. pole.name .. "_simple.png^[transformFX"
		},
		groups = pole.groups_deco,
		node_box = {
			type = "fixed",
			fixed = {
				{0, -1/2, 0, 0, 1/2, 1}
			}
		},
		selection_box = {
			type = "fixed",
			fixed = {
				{-1/16, -1/2, 0, 1/16, 1/2, 1}
			}
		},
		sounds = default.node_sound_wood_defaults(),
		on_dig = function(pos, node, digger)
			if digger:is_player() and digger:get_inventory() then
				local meta = minetest.get_meta(pos)
				local wear_out = meta:get_int("wear")
				digger:get_inventory():add_item("main", {name = "fishing:pole_" .. pole.name, count = 1, wear = wear_out})
			end
			minetest.remove_node(pos)
		end
	})
end