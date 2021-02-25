throwing = {}
throwing.playerArrows = {}
local playerCooldown = {}

minetest.register_on_joinplayer(function(player)
	playerCooldown[player:get_player_name()] = 0.0
end)

minetest.register_on_leaveplayer(function(player)
	playerCooldown[player:get_player_name()] = nil
end)

-- creative check
local creative_cache = minetest.settings:get_bool("creative_mode")
local function creative(name)
	return creative_cache or minetest.check_player_privs(name,
		{creative = true})
end

local arrows = {
	{"throwing:arrow"		  , "throwing:arrow_entity"},
	{"throwing:arrow_mithril" , "throwing:arrow_mithril_entity"},
	{"throwing:arrow_fire"	  , "throwing:arrow_fire_entity"},
	{"throwing:arrow_teleport", "throwing:arrow_teleport_entity"},
	{"throwing:arrow_dig"	  , "throwing:arrow_dig_entity"},
	{"throwing:arrow_build"	  , "throwing:arrow_build_entity"},
	{"throwing:arrow_tnt"	  , "throwing:arrow_tnt_entity"},
	{"throwing:arrow_nyan"	  , "throwing:arrow_nyan_entity"},
	{"throwing:arrow_admin"	  , "throwing:arrow_admin_entity"}
}

local cooldowns = {
	["throwing:bow_wood"] = 2.5,
	["throwing:bow_stone"] = 1.5,
	["throwing:bow_steel"] = 0.5,
	["throwing:bow_mithril"] = 0.2,
	["throwing:bow_rapid"] = 0,
	["throwing:bow_admin"] = 0,
	["throwing:arrow"] = 0.5,
	["throwing:arrow_nyan"] = 0.2,
	["throwing:arrow_mithril"] = 0.2,
	["throwing:arrow_fire"] = 5.0,
	["throwing:arrow_tnt"] = 8.0,
	["throwing:arrow_teleport"] = 2.0,
	["throwing:arrow_dig"] = 0.5,
	["throwing:arrow_build"] = 1.0,
	["throwing:arrow_admin"] = 0.1
}

local throwing_shoot_arrow = function(itemstack, player)
	local playername = player:get_player_name()
	if playerCooldown[playername] == 0.0 then
		local playerpos = player:get_pos()

		if playerpos.x < -32000 or 32000 < playerpos.x or
			playerpos.y < -32000 or 32000 < playerpos.y or
			playerpos.x < -32000 or 32000 < playerpos.x
		then
			minetest.log("error", "[throwing] " .. playername .. " position out of bounds " .. minetest.pos_to_string(playerpos))
			return false
		end

		for _, arrow in ipairs(arrows) do
			local inv = player:get_inventory()
			if inv:get_stack("main", player:get_wield_index() + 1):get_name() == arrow[1] then
				if not creative(playername) then
					inv:remove_item("main", arrow[1])
				end

				local bowCooldown = cooldowns[inv:get_stack("main", player:get_wield_index()):get_name()]
				local arrowCooldown = cooldowns[inv:get_stack("main", player:get_wield_index() + 1):get_name()]

				local obj = minetest.add_entity({
					x = playerpos.x, y = playerpos.y + 1.5, z = playerpos.z}, arrow[2])
				throwing.playerArrows[obj] = playername
				local dir = player:get_look_dir()

				if bowCooldown == 0 then -- Rapid fire bow
					obj:set_velocity({x = dir.x*20, y = dir.y*20, z = dir.z*20})
					obj:set_acceleration({x = dir.x*-1, y = -5, z = dir.z*-1})
					obj:set_yaw(player:get_look_horizontal()-math.pi/2)
					minetest.sound_play("throwing_heavy", {pos = playerpos, gain = 0.5}, true)
				else
					obj:set_velocity({x = dir.x*19, y = dir.y*19, z = dir.z*19})
					obj:set_acceleration({x = dir.x*-3, y = -10, z = dir.z*-3})
					obj:set_yaw(player:get_look_horizontal()-math.pi/2)
					minetest.sound_play("throwing_light", {pos = playerpos, gain = 0.5}, true)
				end

				if obj:get_luaentity().player == "" then
					obj:get_luaentity().player = player
				end
				obj:get_luaentity().node = inv:get_stack("main", 1):get_name()

				local totalCooldown = 1 -- Default
				if bowCooldown == 0 then -- Rapid fire bow
					totalCooldown = 0.2
				elseif bowCooldown and arrowCooldown then -- For some f#$!ing reason these can be nil?? -_-
					totalCooldown = bowCooldown + arrowCooldown
				end

				playerCooldown[playername] = totalCooldown

				minetest.after(totalCooldown, function(playername)
					if playerCooldown[playername] then
						minetest.sound_play("throwing_reload", {to_player = playername, gain = 0.5}, true)
						playerCooldown[playername] = 0.0
					end
				end, playername)
				return true
			end
		end
	end
	return false
end

minetest.register_tool("throwing:bow_wood", {
	description = "Wood Bow",
	inventory_image = "throwing_bow_wood.png",
	stack_max = 1,
	on_use = function(itemstack, user, pointed_thing)
		if throwing_shoot_arrow(itemstack, user, pointed_thing) then
			if not creative(user:get_player_name()) then
				itemstack:add_wear(65535 / 50)
			end
		end
		return itemstack
	end
})

minetest.register_craft({
	output = 'throwing:bow_wood',
	recipe = {
		{'farming:string', 'default:wood', ''},
		{'farming:string', '', 'default:wood'},
		{'farming:string', 'default:wood', ''}
	}
})

minetest.register_tool("throwing:bow_stone", {
	description = "Stone Bow",
	inventory_image = "throwing_bow_stone.png",
	stack_max = 1,
	on_use = function(itemstack, user, pointed_thing)
		if throwing_shoot_arrow(itemstack, user, pointed_thing) then
			if not creative(user:get_player_name()) then
				itemstack:add_wear(65535 / 100)
			end
		end
		return itemstack
	end
})

minetest.register_craft({
	output = 'throwing:bow_stone',
	recipe = {
		{'farming:string', 'default:cobble', ''},
		{'farming:string', '', 'default:cobble'},
		{'farming:string', 'default:cobble', ''}
	}
})

minetest.register_tool("throwing:bow_steel", {
	description = "Steel Bow",
	inventory_image = "throwing_bow_steel.png",
	stack_max = 1,
	on_use = function(itemstack, user, pointed_thing)
		if throwing_shoot_arrow(itemstack, user, pointed_thing) then
			if not creative(user:get_player_name()) then
				itemstack:add_wear(65535 / 200)
			end
		end
		return itemstack
	end
})

minetest.register_craft({
	output = 'throwing:bow_steel',
	recipe = {
		{'farming:string', 'default:steel_ingot', ''},
		{'farming:string', '', 'default:steel_ingot'},
		{'farming:string', 'default:steel_ingot', ''}
	}
})

minetest.register_tool("throwing:bow_mithril", {
	description = "Mithril Bow",
	inventory_image = "throwing_bow_mithril.png",
	stack_max = 1,
	on_use = function(itemstack, user, pointed_thing)
		if throwing_shoot_arrow(itemstack, user, pointed_thing) then
			if not creative(user:get_player_name()) then
				itemstack:add_wear(65535 / 1000)
			end
		end
		return itemstack
	end
})

minetest.register_craft({
	output = 'throwing:bow_mithril',
	recipe = {
		{'farming:string', 'moreores:mithril_ingot', ''},
		{'farming:string', 'moreores:silver_ingot', 'moreores:mithril_ingot'},
		{'farming:string', 'moreores:mithril_ingot', ''}
	}
})

minetest.register_tool("throwing:bow_rapid", {
	description = "MTG9000 rapid fire heavy crossbow Mk II",
	inventory_image = "throwing_bow_rapid.png",
	wield_scale = {x = 1.3, y = 1.3, z = 1.3},
	stack_max = 1,
	on_use = function(itemstack, user, pointed_thing)
		if throwing_shoot_arrow(itemstack, user, pointed_thing) then
			if not creative(user:get_player_name()) then
				itemstack:add_wear(65535 / 100)
			end
		end
		return itemstack
	end
})

minetest.register_tool("throwing:bow_admin", {
	description = "MTG9000 rapid fire heavy crossbow Mk IV admin edition",
	inventory_image = "throwing_bow_admin.png",
	wield_scale = {x = 1.3, y = 1.3, z = 1.3},
	stack_max = 1,
	groups = {not_in_creative_inventory = 1},
	on_drop = function(itemstack, dropper, pos)
		return
	end,
	on_use = function(itemstack, user, pointed_thing)
		throwing_shoot_arrow(itemstack, user, pointed_thing)
		return itemstack
	end
})

minetest.register_alias("adminbow", "throwing:bow_admin")

local MP = minetest.get_modpath("throwing") .. "/"

dofile(MP .. "arrow.lua")
dofile(MP .. "mithril_arrow.lua")
dofile(MP .. "fire_arrow.lua")
dofile(MP .. "teleport_arrow.lua")
dofile(MP .. "dig_arrow.lua")
dofile(MP .. "build_arrow.lua")
dofile(MP .. "tnt_arrow.lua")
dofile(MP .. "rainbow_arrow.lua")
dofile(MP .. "admin_arrow.lua")

minetest.log("action", "throwing loaded")