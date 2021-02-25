-- ENVIRO block: change physics for players
-- note: nonadmin players are limited in changes

-- rnd 2016:

local use_player_monoids = minetest.global_exists("player_monoids")

if use_player_monoids then
	-- Sneak monoid. Effect values are sneak booleans.
	basic_machines.player_sneak = player_monoids.make_monoid({
		combine = function(p, q) return p or q end,
		fold = function(elems)
			for _, v in pairs(elems) do
				if v then return true end
			end

			return false
		end,
		identity = false,
		apply = function(can_sneak, player)
			local ov = player:get_physics_override()
			ov.sneak = can_sneak
			player:set_physics_override(ov)
		end
	})
end

local enviro_update_form = function (pos)
	local meta = minetest.get_meta(pos)
	local list_name = "nodemeta:"..pos.x..','..pos.y..','..pos.z

	meta:set_string("formspec", ([[
		size[8,8.5]
		field[1.25,0.3;1,1;x0;target;%i]
		field[2.25,0.3;1,1;y0;;%i]
		field[3.25,0.3;1,1;z0;;%i]
		field[4.25,0.3;1,1;r;radius;%i]
		field[1.25,1.3;1,1;speed;speed;%.2f]
		field[2.25,1.3;1,1;jump;jump;%.2f]
		field[3.25,1.3;1,1;g;gravity;%.2f]
		field[4.25,1.3;1,1;sneak;sneak;%i]
		button_exit[6,0;1,1;OK;OK]
		button[6,1;1,1;help;help]
		label[6,2.3;FUEL]
		list[%s;fuel;6,2.8;1,1;]
		list[current_player;main;0,4.35;8,1;]
		list[current_player;main;0,5.58;8,3;8]
		listring[%s;fuel]
		listring[current_player;main]
		default.get_hotbar_bg(0,4.35)
	]]):format(
		meta:get_int("x0"), meta:get_int("y0"), meta:get_int("z0"), meta:get_int("r"),
		meta:get_float("speed"), meta:get_float("jump"), meta:get_float("g"), meta:get_int("sneak"),
		list_name, list_name
	))
end

-- environment changer
minetest.register_node("basic_machines:enviro", {
	description = "Changes environment for players around target location",
	tiles = {"enviro.png"},
	drawtype = "allfaces",
	paramtype = "light",
	param1 = 1,
	groups = {cracky = 3},
	sounds = default.node_sound_wood_defaults(),
	after_place_node = function(pos, placer)
		local meta = minetest.get_meta(pos)
		meta:set_string("infotext", "Right click to set it. Activate by signal.")
		meta:set_string("owner", placer:get_player_name()); meta:set_int("public", 1)
		meta:set_int("x0", 0); meta:set_int("y0", 0); meta:set_int("z0", 0) -- target
		meta:set_int("r", 0)
		meta:set_float("speed", 1)
		meta:set_float("jump", 1)
		meta:set_float("g", 1)
		meta:set_int("sneak", 1)
		meta:set_int("admin", 0)
		local name = placer:get_player_name()
		meta:set_string("owner", name)
		local privs = minetest.get_player_privs(name)
		if privs.privs then meta:set_int("admin", 1) end
		if privs.machines then meta:set_int("machines", 1) end

		local inv = meta:get_inventory()
		inv:set_size("fuel", 1 * 1)

		enviro_update_form(pos)
	end,

	effector = {
		action_on = function (pos, node, ttl)
			local meta = minetest.get_meta(pos)

			local r = meta:get_int("r"); if r <= 0 then return end
			local inv = meta:get_inventory(); local stack = ItemStack("default:diamond 1")
			local admin = meta:get_int("admin")
			local physics = {
				speed = meta:get_float("speed"),
				jump = meta:get_float("jump"),
				gravity = meta:get_float("g"),
				sneak = meta:get_int("sneak")
			}

			if inv:contains_item("fuel", stack) and not (admin == 1) then
				meta:set_string("infotext", ("#CURRENT SETTINGS Speed=%.2f Jump=%.2f GRAVITY=%.2f Sneak=%i")
					:format(physics.speed, physics.jump, physics.gravity, physics.sneak))
				inv:remove_item("fuel", stack)
			elseif admin == 1 then
				meta:set_string("infotext", ("ADMIN #CURRENT SETTINGS Speed=%.2f Jump=%.2f Gravity=%.2f Sneak=%i")
					:format(physics.speed, physics.jump, physics.gravity, physics.sneak))
			else
				meta:set_string("infotext", "Error. Insert diamond in fuel inventory.")
				return
			end

			local pos_r = {x = meta:get_int("x0"), y = meta:get_int("y0"), z = meta:get_int("z0")}
			local pos0 = vector.add(pos, pos_r)
			local players = minetest.get_connected_players()
			for _, player in pairs(players) do
				local pos1 = player:get_pos()
				local dist = math.sqrt((pos1.x - pos0.x)^2 + (pos1.y - pos0.y)^2 + (pos1.z - pos0.z)^2)
				if dist <= r then
					physics.sneak = physics.sneak == 1 and true or false
					if use_player_monoids then
						player_monoids.speed:add_change(player, physics.speed,
							"basic_machines:physics")
						player_monoids.jump:add_change(player, physics.jump,
							"basic_machines:physics")
						player_monoids.gravity:add_change(player, physics.gravity,
							"basic_machines:physics")
						basic_machines.player_sneak:add_change(player, physics.sneak,
							"basic_machines:physics")
					else
						player:set_physics_override(physics)
					end
				end
			end

			-- attempt to set acceleration to balls, if any around
			local objects = minetest.get_objects_inside_radius(pos, r)
			for _, obj in pairs(objects) do
				if obj:get_luaentity() then
					local obj_name = obj:get_luaentity().name or ""
					if obj_name == "basic_machines:ball" then
						obj:set_acceleration({x = 0, y = -physics.gravity, z = 0})
					end
				end
			end
		end
	},

	on_receive_fields = function(pos, formname, fields, sender)
		local name = sender:get_player_name()
		if not minetest.is_protected(pos, name) and fields.OK then
			local meta = minetest.get_meta(pos)
			meta:set_string("infotext", "Right click to set it. Activate by signal.")
			local privs = minetest.get_player_privs(name)
			local x0, y0, z0 = 0, 0, 0

			if fields.x0 then x0 = tonumber(fields.x0) or 0 end
			if fields.y0 then y0 = tonumber(fields.y0) or 0 end
			if fields.z0 then z0 = tonumber(fields.z0) or 0 end
			if not privs.privs and (math.abs(x0) > 10 or math.abs(y0) > 10 or math.abs(z0) > 10) then return end

			meta:set_int("x0", x0); meta:set_int("y0", y0); meta:set_int("z0", z0)
			if fields.r then
				local r = tonumber(fields.r) or 0
				if (r < 0 or r > 10) and not privs.privs then return end
				meta:set_int("r", r)
			end
			if fields.speed then
				local speed = tonumber(fields.speed) or 1
				if (speed < 0 or speed > 1) and not privs.privs then return end
				meta:set_float("speed", ("%.2f"):format(speed))
			end
			if fields.jump then
				local jump = tonumber(fields.jump) or 1
				if (jump < 0 or jump > 2) and not privs.privs then return end
				meta:set_float("jump", ("%.2f"):format(jump))
			end
			if fields.g then
				local g = tonumber(fields.g) or 1
				if (g < 0.1 or g > 40) and not privs.privs then return end
				meta:set_float("g", ("%.2f"):format(g))
			end
			if fields.sneak then
				local sneak = tonumber(fields.sneak or 0)
				if sneak < 0 or sneak > 1 then return end
				meta:set_int("sneak", tonumber(fields.sneak))
			end

			enviro_update_form(pos)
		elseif fields.help then
			local text = "VALUES\n\n"..
				"Target: Center position of the area to apply environment effects\n"..
				"\t\t\t\t\t\t\t\tx: [-10, 10\\], y: [-10, 10\\], z: [-10, 10\\]\n"..
				"Radius:  [0, 	 10\\]\n"..
				"Speed:   [0.0,   1\\]\n"..
				"Jump: 	  [0.0,   2\\]\n"..
				"Gravity:  [0.1, 40\\]\n"..
				"Sneak:   [0, 	    1\\]"
			minetest.show_formspec(name, "basic_machines:envirohelp",
				"size[6,7]textarea[0,0;6.5,8.5;envirohelp;ENVIRONMENT MODIFICATIONS;"..text.."]")
		end
	end,

	allow_metadata_inventory_take = function(pos, listname, index, stack, player)
		local meta = minetest.get_meta(pos)
		local name = player:get_player_name()
		local privs = minetest.get_player_privs(name)
		if meta:get_string("owner") ~= name and not privs.privs then return 0 end
		return stack:get_count()
	end,

	allow_metadata_inventory_put = function(pos, listname, index, stack, player)
		local meta = minetest.get_meta(pos)
		local name = player:get_player_name()
		local privs = minetest.get_player_privs(name)
		if meta:get_string("owner") ~= name and not privs.privs then return 0 end
		return stack:get_count()
	end,

	can_dig = function(pos, player) -- dont dig if fuel is inside, cause it will be destroyed
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		return inv:is_empty("fuel")
	end
})

-- DEFAULT(SPAWN) PHYSICS VALUES
local reset_player_physics = function(player)
	if player and player:is_player() then
		if use_player_monoids then
			player_monoids.speed:del_change(player, "basic_machines:physics")
			player_monoids.jump:del_change(player, "basic_machines:physics")
			player_monoids.gravity:del_change(player, "basic_machines:physics")
			basic_machines.player_sneak:del_change(player, "basic_machines:physics")
		else
			player:set_physics_override({speed = 1, jump = 1, gravity = 1, sneak = true})
		end
	end
end

-- restore default physics values on respawn of player
minetest.register_on_respawnplayer(reset_player_physics)
--[[
-- RECIPE: extremely expensive
minetest.register_craft({
	output = "basic_machines:enviro",
	recipe = {
		{"basic_machines:generator", "basic_machines:clockgen", "basic_machines:generator"},
		{"basic_machines:generator", "basic_machines:generator", "basic_machines:generator"},
		{"basic_machines:generator", "basic_machines:generator", "basic_machines:generator"}
	}
})
--]]