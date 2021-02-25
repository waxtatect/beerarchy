armor:register_armor("moontest_spacesuit:helmet_space", {
	description = "Space Helmet",
	inventory_image = "moontest_spacesuit_inv_helmet_space.png",
	groups = {armor_head = 5, armor_heal = 0, armor_use = 75}
})
armor:register_armor("moontest_spacesuit:chestplate_space", {
	description = "Space Chestplate",
	inventory_image = "moontest_spacesuit_inv_chestplate_space.png",
	groups = {armor_torso = 8, armor_heal = 0, armor_use = 75}
})
armor:register_armor("moontest_spacesuit:pants_space", {
	description = "Space Pants",
	inventory_image = "moontest_spacesuit_inv_pants_space.png",
	groups = {armor_legs = 7, armor_heal = 0, armor_use = 75}
})
armor:register_armor("moontest_spacesuit:boots_space", {
	description = "Space Boots",
	inventory_image = "moontest_spacesuit_inv_boots_space.png",
	groups = {armor_feet = 4, armor_heal = 0, armor_use = 75}
})

local tin_ingot = "default:tin_ingot"
if minetest.registered_items["moreores:tin_ingot"] then
	tin_ingot = "moreores:tin_ingot"
end

minetest.register_craft({
	output = "moontest_spacesuit:helmet_space",
	recipe = {
		{"default:glass", "default:glass", "default:glass"},
		{"default:glass", "integral:moon_juice", "default:glass"},
		{"moreores:mithril_ingot", "default:mese", "moreores:mithril_ingot"}
	}
})
minetest.register_craft({
	output = "moontest_spacesuit:chestplate_space",
	recipe = {
		{"moreores:mithril_ingot", "default:mese", "moreores:mithril_ingot"},
		{tin_ingot, "default:mese", tin_ingot},
		{"moreores:mithril_ingot", "default:mese", "moreores:mithril_ingot"}
	}
})
minetest.register_craft({
	output = "moontest_spacesuit:pants_space",
	recipe = {
		{"moreores:mithril_ingot", "default:mese", "moreores:mithril_ingot"},
		{tin_ingot, "", tin_ingot},
		{"moreores:mithril_ingot", "", "moreores:mithril_ingot"}
	}
})
minetest.register_craft({
	output = "moontest_spacesuit:boots_space",
	recipe = {
		{"moreores:mithril_ingot", "", "moreores:mithril_ingot"},
		{tin_ingot, "", tin_ingot}
	}
})

local skippy = 0
local admin = minetest.settings:get("name")

minetest.register_globalstep(function(dtime)
	skippy = skippy + 1
	if skippy < 10 then
		return
	end
	skippy = 0

	for _, player in ipairs(minetest.get_connected_players()) do
		local player_name = player:get_player_name()
		if player:is_player() and player_name ~= admin then
			if player:get_pos().y > 5000 and player:get_pos().y < 10001 then
				local inv = minetest.get_inventory({type = "detached", name = player_name .. "_armor"})
				if not (inv:contains_item("armor", "moontest_spacesuit:helmet_space") and inv:contains_item("armor", "moontest_spacesuit:chestplate_space") and inv:contains_item("armor", "moontest_spacesuit:pants_space") and inv:contains_item("armor", "moontest_spacesuit:boots_space")) then
					if player:get_hp() > 0 then
						player:set_hp(player:get_hp() - 2)
					end
				end
			elseif player:get_pos().y > 10000 then
				local inv = minetest.get_inventory({type = "detached", name = player_name .. "_armor"})
				if not (inv:contains_item("armor", "moontest_spacesuit:helmet_space") and inv:contains_item("armor", "moontest_spacesuit:chestplate_space") and inv:contains_item("armor", "moontest_spacesuit:pants_space") and inv:contains_item("armor", "moontest_spacesuit:boots_space")) then
					if player:get_hp() > 0 then
						player:set_hp(player:get_hp() - 8)
					end
				end
			end
		end
	end
end)

--[[
--currently broken
minetest.register_globalstep(function(dtime)
	for _, player in ipairs(minetest.get_connected_players()) do
		if math.random() < 0.1 then -- spacesuit restores breath
			if player:is_player() then
				local inv = minetest.get_inventory({type = "detached", name = player:get_player_name() .. "_armor"})
				if inv:contains_item("armor", "moontest_spacesuit:helmet_space") and inv:contains_item("armor", "moontest_spacesuit:chestplate_space") and inv:contains_item("armor", "moontest_spacesuit:pants_space") and inv:contains_item("armor", "moontest_spacesuit:boots_space") then
					player:set_breath(10)
				end
			end
		end
	end
end)
--]]