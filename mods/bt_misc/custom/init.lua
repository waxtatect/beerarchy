--
-- /privs
--

minetest.override_chatcommand("privs", {
	params = "",
	description = "",
	func = function(caller, param)
		return true
	end
})

--
-- 3d_armor
--

local admin = minetest.settings:get("name")

local function on_punched(player, hitter, time_from_last_punch, tool_capabilities)
	if player:get_player_name() ~= admin then
		local wielded = hitter:get_wielded_item():get_name()
		if hitter and hitter:is_player() and
			(wielded == "aerotest:sword" or wielded == "default:stick")
		then
			local name, armor_inv = armor:get_valid_player(player, "[custom]")
			if not name then
				return
			end
			minetest.after(0.1, function(armor_inv, player)
				local drop_all, change = math.random(23) == 1, false
				for i = 1, armor_inv:get_size("armor") do
					local stack = armor_inv:get_stack("armor", i)
					if stack:get_count() > 0 and stack:get_name():find("_admin") then
						if drop_all or math.random(9) == 1 then
							change = true
							armor:run_callbacks("on_unequip", player, i, stack)
							armor_inv:set_stack("armor", i, nil)
							armor.drop_armor(player:get_pos(), stack)
						end
					end
				end
				if change then
					armor:save_armor_inventory(player)
					armor:set_player_armor(player)
				end
				hbhunger.hunger[name] = 0
				hbhunger.poisonings[name] = 1
				hbhunger.set_hunger_raw(player)
			end, armor_inv, player)
		end
	end
end

minetest.override_item("3d_armor:helmet_admin", {on_punched = on_punched})
minetest.override_item("3d_armor:chestplate_admin", {on_punched = on_punched})
minetest.override_item("3d_armor:leggings_admin", {on_punched = on_punched})
minetest.override_item("3d_armor:boots_admin", {on_punched = on_punched})
minetest.override_item("shields:shield_admin", {on_punched = on_punched})

--
-- beds
--

if minetest.settings:get_bool("enable_bed_respawn_custom", true) then
	-- respawn player at bed if enabled and valid position is found
	minetest.register_on_respawnplayer(function(player)
		local name = player:get_player_name()
		local pos = beds.spawn[name]
		if pos then
			if minetest.get_node(pos).name == "air" then
				player:set_pos(pos)
			else
				player:set_pos({x = pos.x, y = pos.y - 0.5, z = pos.z})
			end
			return true
		end
	end)
end

minetest.register_chatcommand("clearbed", {
	description = "Momentarily clear bed respawn position",
	func = function(name, param)
		local player = minetest.get_player_by_name(name)
		if player and player:is_player() then
			local bed_pos = beds.spawn[name]
			if bed_pos then
				beds.spawn[name] = nil
				-- beds.save_spawns()
				minetest.chat_send_player(name, ("Bed respawn at %s removed until rejoin"):format(
					minetest.pos_to_string(vector.round(bed_pos))))
			end
		end
	end
})

--
-- default
--

minetest.clear_craft({output = "default:chest_locked"})

minetest.override_item("default:pick_bronze", {
	tool_capabilities = {
		full_punch_interval = 1.0,
		max_drop_level = 1,
		groupcaps = {
			cracky = {times={[1]=4.00, [2]=1.60, [3]=0.80}, uses=30, maxlevel=2}
		},
		damage_groups = {fleshy=4}
	}
})

minetest.override_item("default:shovel_bronze", {
	tool_capabilities = {
		full_punch_interval = 1.1,
		max_drop_level = 1,
		groupcaps = {
			crumbly = {times={[1]=1.50, [2]=0.90, [3]=0.40}, uses=40, maxlevel=2}
		},
		damage_groups = {fleshy=3}
	}
})

minetest.override_item("default:axe_bronze", {
	tool_capabilities = {
		full_punch_interval = 1.0,
		max_drop_level = 1,
		groupcaps = {
			choppy={times={[1]=2.50, [2]=1.40, [3]=1.00}, uses=30, maxlevel=2}
		},
		damage_groups = {fleshy=4}
	}
})

minetest.override_item("default:axe_diamond", {
	tool_capabilities = {
		full_punch_interval = 0.9,
		max_drop_level = 1,
		groupcaps = {
			choppy={times={[1]=2.10, [2]=0.90, [3]=0.50}, uses=30, maxlevel=2}
		},
		damage_groups = {fleshy=7}
	}
})

minetest.override_item("default:sword_bronze", {
	tool_capabilities = {
		full_punch_interval = 0.8,
		max_drop_level = 1,
		groupcaps = {
			snappy={times={[1]=2.5, [2]=1.20, [3]=0.35}, uses=40, maxlevel=2}
		},
		damage_groups = {fleshy=6}
	}
})

minetest.register_tool(":default:sword_admin", {
	description = "Admin Sword",
	inventory_image = "default_tool_adminsword.png",
	wield_scale = {x = 1, y = 1.6, z = 1},
	range = 5,
	tool_capabilities = {
		full_punch_interval = 0.1,
		max_drop_level = 3,
		groupcaps = {
			snappy = {times={[1] = 0.30, [2] = 0.20, [3] = 0.10}, uses = 0, maxlevel = 3}
		},
		damage_groups = {fleshy = 10000}
	},
	sound = {breaks = "default_tool_breaks"},
	groups = {sword = 1, not_in_creative_inventory = 1},
	on_drop = function(itemstack, dropper, pos)
		return
	end,
	after_use = function(itemstack, user, node, digparams)
		return itemstack
	end
})

minetest.register_alias("adminsword", "default:sword_admin")

--
-- fire
--

if minetest.settings:get_bool("enable_fire_custom") then
	-- Ignite neighboring nodes, add basic flames
	minetest.register_abm({
		label = "Ignite flame",
		nodenames = {"group:flammable"},
		neighbors = {"group:igniter"},
		interval = 10,
		chance = 100,
		catch_up = false,
		action = function(pos)
			local p = minetest.find_node_near(pos, 1, {"air"})
			if p then
				minetest.set_node(p, {name = "fire:basic_flame"})
			end
		end
	})

	-- Remove flammable nodes around basic flame
	minetest.register_abm({
		label = "Remove flammable nodes",
		nodenames = {"fire:basic_flame"},
		neighbors = "group:flammable",
		interval = 5,
		chance = 15,
		catch_up = false,
		action = function(pos)
			local p = minetest.find_node_near(pos, 1, {"group:flammable"})
			if not p then
				return
			end
			local flammable_node = minetest.get_node(p)
			local def = minetest.registered_nodes[flammable_node.name]
			if def.on_burn then
				def.on_burn(p)
			else
				minetest.remove_node(p)
				minetest.check_for_falling(p)
			end
		end
	})
end