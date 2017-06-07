-- ENVIRO block: change physics and skybox for players
-- note: nonadmin players are limited in changes ( cant change skybox and have limits on other allowed changes)

-- rnd 2016:

local enviro_update_form = function (pos)

		local meta = minetest.get_meta(pos);


		local x0,y0,z0;
		x0=meta:get_int("x0");y0=meta:get_int("y0");z0=meta:get_int("z0");

		local r = meta:get_int("r");
		local speed,jump, g, sneak;
		speed = meta:get_float("speed");jump = meta:get_float("jump");
		g = meta:get_float("g"); sneak = meta:get_int("sneak");
		local list_name = "nodemeta:"..pos.x..','..pos.y..','..pos.z;

		local form  =
		"size[8,8.5]" ..  -- width, height
		"field[0.25,0.5;1,1;x0;target;"..x0.."] field[1.25,0.5;1,1;y0;;"..y0.."] field[2.25,0.5;1,1;z0;;"..z0.."]"..
		"field[3.25,0.5;1,1;r;radius;"..r.."]"..
		--speed, jump, gravity,sneak
		"field[0.25,1.5;1,1;speed;speed;"..speed.."]"..
		"field[1.25,1.5;1,1;jump;jump;".. jump.."]"..
		"field[2.25,1.5;1,1;g;gravity;"..g.."]"..
		"field[3.25,1.5;1,1;sneak;sneak;"..sneak.."]"..
		"button_exit[3.25,3.25;1,1;OK;OK]"..
		"list["..list_name..";fuel;3.25,2.25;1,1;]"..
		"list[current_player;main;0,4.5;8,4;]";
		meta:set_string("formspec",form);

end

-- enviroment changer
minetest.register_node("basic_machines:enviro", {
	description = "Changes enviroment for players around target location",
	tiles = {"enviro.png"},
	drawtype = "allfaces",
	paramtype = "light",
	param1=1,
	groups = {cracky=3, mesecon_effector_on = 1},
	sounds = default.node_sound_wood_defaults(),
	after_place_node = function(pos, placer)
		local meta = minetest.env:get_meta(pos)
		meta:set_string("infotext", "Right click to set it. Activate by signal.")
		meta:set_string("owner", placer:get_player_name()); meta:set_int("public",1);
		meta:set_int("x0",0);meta:set_int("y0",0);meta:set_int("z0",0); -- target
		meta:set_float("speed",1);
		meta:set_float("jump",1);
		meta:set_float("g",1);
		meta:set_int("sneak",1);
		meta:set_int("admin",0);
		local name = placer:get_player_name();
		meta:set_string("owner",name);
		local privs = minetest.get_player_privs(name);
		if privs.privs then meta:set_int("admin",1) end

		local inv = meta:get_inventory();
		inv:set_size("fuel",1*1);

		enviro_update_form(pos);
	end,

	mesecons = {effector = {
		action_on = function (pos, node,ttl)
			local meta = minetest.get_meta(pos);
			local admin = meta:get_int("admin");

			local inv = meta:get_inventory(); local stack = ItemStack("default:diamond 1");

			if inv:contains_item("fuel", stack) then
				inv:remove_item("fuel", stack);
			else
				meta:set_string("infotext","Error. Insert diamond in fuel inventory")
				return
			end

			local x0,y0,z0,r,speed,jump,g,sneak;
			x0=meta:get_int("x0"); y0=meta:get_int("y0");z0=meta:get_int("z0"); -- target
			r= meta:get_int("r",5);
			speed=meta:get_float("speed");jump=	meta:get_float("jump");
			g=meta:get_float("g");sneak=meta:get_int("sneak"); if sneak~=0 then sneak = true else sneak = false end

			local players = minetest.get_connected_players();
			for _,player in pairs(players) do
				local pos1 = player:getpos();
				local dist = math.sqrt((pos1.x-pos.x)^2 + (pos1.y-pos.y)^2 + (pos1.z-pos.z)^2 );
				if dist<=r then

					player:set_physics_override({speed=speed,jump=jump,gravity=g,sneak=sneak})

				end
			end

			-- attempt to set acceleration to balls, if any around
			local objects =  minetest.get_objects_inside_radius(pos, r)

			for _,obj in pairs(objects) do
				if obj:get_luaentity() then
					local obj_name = obj:get_luaentity().name or ""
					if obj_name == "basic_machines:ball" then
						obj:setacceleration({x=0,y=-g,z=0});
					end
				end

			end




		end
	}
	},


	on_receive_fields = function(pos, formname, fields, sender)

		local name = sender:get_player_name();if minetest.is_protected(pos,name) then return end

		if fields.OK then
			local privs = minetest.get_player_privs(sender:get_player_name());
			local meta = minetest.get_meta(pos);
			local x0=0; local y0=0; local z0=0;
			--minetest.chat_send_all("form at " .. dump(pos) .. " fields " .. dump(fields))
			if fields.x0 then x0 = tonumber(fields.x0) or 0 end
			if fields.y0 then y0 = tonumber(fields.y0) or 0 end
			if fields.z0 then z0 = tonumber(fields.z0) or 0 end
			if not privs.privs and (math.abs(x0)>10 or math.abs(y0)>10 or math.abs(z0) > 10) then return end

			meta:set_int("x0",x0);meta:set_int("y0",y0);meta:set_int("z0",z0);
			if fields.r then
				local r = tonumber(fields.r) or 0;
				if r > 10 and not privs.privs then return end
				meta:set_int("r", r)
			end
			if fields.g then
				local g = tonumber(fields.g) or 1;
				if (g<0.1 or g>40) and not privs.privs then return end
				meta:set_float("g", g)
			end
			if fields.speed then
				local speed = tonumber(fields.speed) or 1;
				if (speed>1 or speed < 0) and not privs.privs then return end
				meta:set_float("speed", speed)
			end
			if fields.jump then
				local jump = tonumber(fields.jump) or 1;
				if (jump<0 or jump>2) and not privs.privs then return end
				meta:set_float("jump", jump)
			end
			if fields.sneak then
				meta:set_int("sneak", tonumber(fields.sneak) or 0)
			end


			enviro_update_form(pos);
		end
	end,

	allow_metadata_inventory_take = function(pos, listname, index, stack, player)
		local meta = minetest.get_meta(pos);
		local privs = minetest.get_player_privs(player:get_player_name());
		if meta:get_string("owner")~=player:get_player_name() and not privs.privs then return 0 end
		return stack:get_count();
	end,

	allow_metadata_inventory_put = function(pos, listname, index, stack, player)
		local meta = minetest.get_meta(pos);
		local privs = minetest.get_player_privs(player:get_player_name());
		if meta:get_string("owner")~=player:get_player_name() and not privs.privs then return 0 end
		return stack:get_count();
	end,

})


-- DEFAULT (SPAWN) PHYSICS VALUE/SKYBOX

local reset_player_physics = function(player)
	if player then
		player:set_physics_override({speed=1,jump=1,gravity=1}) -- value set for extreme test space spawn
	end
end

-- restore default values/skybox on respawn of player
minetest.register_on_respawnplayer(reset_player_physics)


-- RECIPE: extremely expensive

-- minetest.register_craft({
	-- output = "basic_machines:enviro",
	-- recipe = {
		-- {"basic_machines:generator", "basic_machines:clockgen","basic_machines:generator"},
		-- {"basic_machines:generator", "basic_machines:generator","basic_machines:generator"},
		-- {"basic_machines:generator", "basic_machines:generator", "basic_machines:generator"}
	-- }
-- })
