local players = {}
local playerLastPos = {}
local playerLastUsedPos = {}
local playerLastUsedPosQueue = {}

ranking = {}
ranking.playerXP = {}

local skippy = 0
local skippy2 = 0

dofile(minetest.get_modpath("ranking").."/rankings.lua")

ranking.get_rank_raw = function(player, rankName)
	local inv = player:get_inventory()
	if not inv then return nil end
	return inv:get_stack("ranking", ranks[rankName].index):get_count()
end

ranking.set_rank_raw = function(player, rankName, value)
	local inv = player:get_inventory()
	local name = player:get_player_name()
	if not inv then return nil end
	local newval = value
	if newval > 65535 then newval = 65535 end
	inv:set_stack("ranking", ranks[rankName].index, ItemStack( { name = ":", count = newval } ))
	return true
end

ranking.get_ranks = function(player)
	local output = ""

	for i = 1, #ranks do
		local xp = ranking.get_rank_raw(player, ranks[i].code)
		local xpName = "No level found, check ranking mod and tables"
		local levels = ranks[i].levels

		for j = 1, #levels do
			if xp >= levels[j].min and xp <= levels[j].max then
				xpName = levels[j].name
				break
			end
		end
		output = output .. ranks[i].name .. ": " .. xpName .. " (" .. xp .. "); "
	end
	return output
end

ranking.increase_rank = function(player, rankName, value)
	local curval = ranking.get_rank_raw(player, rankName)
	ranking.set_rank_raw(player, rankName, curval + value)
end

minetest.register_on_joinplayer(function(player)
	local name = player:get_player_name()
	local inv = player:get_inventory()
	inv:set_size("ranking", #ranks)
	players[name] = player

	if not playerLastUsedPos then
		playerLastUsedPos[name] = {}
	end
	if not playerLastUsedPosQueue then
		playerLastUsedPosQueue[name] = {}
	end

	local xplevels = ranks["experience"].levels
	local xp = ranking.get_rank_raw(player, "experience")

	for i = 1, #xplevels do
		if xp >= xplevels[i].min and xp <= xplevels[i].max then
			ranking.playerXP[name] = i
			break
		end
	end

end)

minetest.register_on_leaveplayer(function(player)
	local name = player:get_player_name()
	players[name] = nil
	ranking.playerXP[name] = nil
	minetest.after(300, clearPlayerPos, player:get_player_name())
end)

function clearPlayerPos(playerName)
	local playerFound = false
	for _, player in ipairs(minetest.get_connected_players()) do
		if playerName == player:get_player_name() then
		playerFound = true
		end
	end
	if not playerFound then
		playerLastUsedPos[playerName] = nil
		playerLastUsedPosQueue[playerName] = nil
	end
end

-- Mining scores
minerNodes = {
	["default:coalblock"] = 2,
	["default:diamondblock"] = 8,
	["default:mese"] = 6,
	["default:stone_with_coal"] = 1,
	["default:stone_with_copper"] = 2,
	["default:stone_with_diamond"] = 5,
	["default:stone_with_gold"] = 3,
	["default:stone_with_iron"] = 2,
	["default:stone_with_mese"] = 4,
	["moreores:mineral_mithril"] = 10,
	["moreores:mineral_silver"] = 3,
	["moreores:mineral_tin"] = 1,
	["nyancat:nyancat"] = 50,
	["nyancat:nyancat_rainbow"] = 20
}

farmNodes = {
	["default:cactus"] = 1,
	["default:papyrus"] = 1,
	["farming:barley_5"] = 1,
	["farming:barley_6"] = 2,
	["farming:beanpole_5"] = 3,
	["farming:blueberry_4"] = 2,
	["farming:carrot_7"] = 1,
	["farming:carrot_8"] = 2,
	["farming:cocoa_3"] = 1,
	["farming:cocoa_4"] = 2,
	["farming:coffee_5"] = 1,
	["farming:corn_7"] = 1,
	["farming:corn_8"] = 2,
	["farming:cotton_6"] = 1,
	["farming:cotton_7"] = 2,
	["farming:cotton_8"] = 3,
	["farming:cotton_wild"] = 1,
	["farming:cucumber_4"] = 1,
	["farming:grapes_8"] = 3,
	["farming:hemp_6"] = 2,
	["farming:hemp_7"] = 5,
	["farming:hemp_8"] = 10,
	["farming:melon_8"] = 20,
	["farming:mint_4"] = 2,
	["farming:pineapple_8"] = 7,
	["farming:potato_3"] = 1,
	["farming:potato_4"] = 1,
	["farming:pumpkin_8"] = 2,
	["farming:raspberry_4"] = 2,
	["farming:rhubarb_3"] = 2,
	["farming:tomato_7"] = 1,
	["farming:tomato_8"] = 1,
	["farming:wheat_6"] = 1,
	["farming:wheat_7"] = 2,
	["farming:wheat_8"] = 3
}

-- Mining and farming events using the above tables to determine the scores
minetest.register_on_dignode(function(pos, oldnode, digger)
	if not digger then
		return
	end
	if pos and minerNodes[oldnode.name] then
		if not playerLastUsedPos[digger:get_player_name()] then
			playerLastUsedPos[digger:get_player_name()] = {}
		end
		if not playerLastUsedPosQueue[digger:get_player_name()] then
			playerLastUsedPosQueue[digger:get_player_name()] = {}
		end
		if not playerLastUsedPos[digger:get_player_name()][minetest.serialize(pos)] then
			ranking.increase_rank(digger, "miner", minerNodes[oldnode.name])
			playerLastUsedPos[digger:get_player_name()][minetest.serialize(pos)] = true
			table.insert(playerLastUsedPosQueue[digger:get_player_name()], minetest.serialize(pos))
			if #playerLastUsedPosQueue[digger:get_player_name()] > 500 then
				local posstring = table.remove(playerLastUsedPosQueue[digger:get_player_name()], 1)
				playerLastUsedPos[digger:get_player_name()][posstring] = nil
			end
		end
	elseif pos and farmNodes[oldnode.name] then
		if not playerLastUsedPos[digger:get_player_name()] then
			playerLastUsedPos[digger:get_player_name()] = {}
		end
		if not playerLastUsedPosQueue[digger:get_player_name()] then
			playerLastUsedPosQueue[digger:get_player_name()] = {}
		end
		if not playerLastUsedPos[digger:get_player_name()][minetest.serialize(pos)] then
			ranking.increase_rank(digger, "farmer", farmNodes[oldnode.name])
			playerLastUsedPos[digger:get_player_name()][minetest.serialize(pos)] = true
			table.insert(playerLastUsedPosQueue[digger:get_player_name()], minetest.serialize(pos))
			if #playerLastUsedPosQueue[digger:get_player_name()] > 500 then
				local posstring = table.remove(playerLastUsedPosQueue[digger:get_player_name()], 1)
				playerLastUsedPos[digger:get_player_name()][posstring] = nil
			end
		end
	end
end)

buildNodes = {}

buildNodes["default:cobble"] = 1
buildNodes["default:mossycobble"] = 1
buildNodes["default:stone"] = 2
buildNodes["default:stone_block"] = 4
buildNodes["default:stonebrick"] = 2

buildNodes["default:desert_cobble"] = 1
buildNodes["default:desert_stone"] = 2
buildNodes["default:desert_stone_block"] = 4
buildNodes["default:desert_stonebrick"] = 2

buildNodes["default:desert_sandstone"] = 1
buildNodes["default:desert_sandstone_block"] = 4
buildNodes["default:desert_sandstone_brick"] = 2
buildNodes["default:sandstone"] = 1
buildNodes["default:sandstone_block"] = 4
buildNodes["default:sandstonebrick"] = 2
buildNodes["default:silver_sandstone"] = 1
buildNodes["default:silver_sandstone_block"] = 4
buildNodes["default:silver_sandstone_brick"] = 2

buildNodes["default:obsidian"] = 5
buildNodes["default:obsidian_block"] = 20
buildNodes["default:obsidianbrick"] = 10

buildNodes["default:acacia_tree"] = 1
buildNodes["default:acacia_wood"] = 2
buildNodes["default:aspen_tree"] = 1
buildNodes["default:aspen_wood"] = 2
buildNodes["default:jungletree"] = 1
buildNodes["default:junglewood"] = 2
buildNodes["default:pine_tree"] = 1
buildNodes["default:pine_wood"] = 2
buildNodes["default:tree"] = 1
buildNodes["default:wood"] = 2

buildNodes["default:bronzeblock"] = 5
buildNodes["default:copperblock"] = 4
buildNodes["default:diamondblock"] = 10
buildNodes["default:goldblock"] = 6
buildNodes["default:mese"] = 8
buildNodes["default:steelblock"] = 3
buildNodes["default:tinblock"] = 2

buildNodes["default:bookshelf"] = 4
buildNodes["default:brick"] = 2
buildNodes["default:chest"] = 2
buildNodes["default:fence_acacia_wood"] = 3
buildNodes["default:fence_aspen_wood"] = 3
buildNodes["default:fence_junglewood"] = 3
buildNodes["default:fence_pine_wood"] = 3
buildNodes["default:fence_rail_acacia_wood"] = 3
buildNodes["default:fence_rail_aspen_wood"] = 3
buildNodes["default:fence_rail_junglewood"] = 3
buildNodes["default:fence_rail_pine_wood"] = 3
buildNodes["default:fence_rail_wood"] = 3
buildNodes["default:fence_wood"] = 3
buildNodes["default:glass"] = 2
buildNodes["default:ladder_steel"] = 3
buildNodes["default:ladder_wood"] = 2
buildNodes["default:mese_post_light"] = 5
buildNodes["default:meselamp"] = 4
buildNodes["default:obsidian_glass"] = 4
buildNodes["default:sign_wall_steel"] = 3
buildNodes["default:sign_wall_wood"] = 2

buildNodes["stairs:slab_acacia_wood"] = 3
buildNodes["stairs:slab_aspen_wood"] = 3
buildNodes["stairs:slab_brick"] = 3
buildNodes["stairs:slab_bronzeblock"] = 5
buildNodes["stairs:slab_cobble"] = 2
buildNodes["stairs:slab_copperblock"] = 6
buildNodes["stairs:slab_desert_cobble"] = 2
buildNodes["stairs:slab_desert_sandstone"] = 2
buildNodes["stairs:slab_desert_sandstone_block"] = 4
buildNodes["stairs:slab_desert_sandstone_brick"] = 3
buildNodes["stairs:slab_desert_stone"] = 3
buildNodes["stairs:slab_desert_stone_block"] = 4
buildNodes["stairs:slab_desert_stonebrick"] = 3
buildNodes["stairs:slab_goldblock"] = 7
buildNodes["stairs:slab_ice"] = 4
buildNodes["stairs:slab_junglewood"] = 3
buildNodes["stairs:slab_mossycobble"] = 3
buildNodes["stairs:slab_obsidian"] = 10
buildNodes["stairs:slab_obsidian_block"] = 12
buildNodes["stairs:slab_obsidianbrick"] = 14
buildNodes["stairs:slab_pine_wood"] = 3
buildNodes["stairs:slab_sandstone"] = 3
buildNodes["stairs:slab_sandstone_block"] = 4
buildNodes["stairs:slab_sandstonebrick"] = 3
buildNodes["stairs:slab_silver_sandstone"] = 3
buildNodes["stairs:slab_silver_sandstone_block"] = 4
buildNodes["stairs:slab_silver_sandstone_brick"] = 3
buildNodes["stairs:slab_snowblock"] = 3
buildNodes["stairs:slab_steelblock"] = 4
buildNodes["stairs:slab_stone"] = 4
buildNodes["stairs:slab_stone_block"] = 5
buildNodes["stairs:slab_stonebrick"] = 5
buildNodes["stairs:slab_straw"] = 4
buildNodes["stairs:slab_wood"] = 3
buildNodes["stairs:stair_acacia_wood"] = 4
buildNodes["stairs:stair_aspen_wood"] = 4
buildNodes["stairs:stair_brick"] = 4
buildNodes["stairs:stair_bronzeblock"] = 7
buildNodes["stairs:stair_cobble"] = 3
buildNodes["stairs:stair_copperblock"] = 8
buildNodes["stairs:stair_desert_cobble"] = 3
buildNodes["stairs:stair_desert_sandstone"] = 3
buildNodes["stairs:stair_desert_sandstone_block"] = 5
buildNodes["stairs:stair_desert_sandstone_brick"] = 4
buildNodes["stairs:stair_desert_stone"] = 4
buildNodes["stairs:stair_desert_stone_block"] = 5
buildNodes["stairs:stair_desert_stonebrick"] = 4
buildNodes["stairs:stair_goldblock"] = 9
buildNodes["stairs:stair_ice"] = 5
buildNodes["stairs:stair_junglewood"] = 4
buildNodes["stairs:stair_mossycobble"] = 4
buildNodes["stairs:stair_obsidian"] = 12
buildNodes["stairs:stair_obsidian_block"] = 14
buildNodes["stairs:stair_obsidianbrick"] = 16
buildNodes["stairs:stair_pine_wood"] = 4
buildNodes["stairs:stair_sandstone"] = 4
buildNodes["stairs:stair_sandstone_block"] = 5
buildNodes["stairs:stair_sandstonebrick"] = 4
buildNodes["stairs:stair_silver_sandstone"] = 4
buildNodes["stairs:stair_silver_sandstone_block"] = 5
buildNodes["stairs:stair_silver_sandstone_brick"] = 4
buildNodes["stairs:stair_snowblock"] = 4
buildNodes["stairs:stair_steelblock"] = 6
buildNodes["stairs:stair_stone"] = 5
buildNodes["stairs:stair_stone_block"] = 6
buildNodes["stairs:stair_stonebrick"] = 6
buildNodes["stairs:stair_straw"] = 5
buildNodes["stairs:stair_wood"] = 4

-- Builder ranking based on place node event
minetest.register_on_placenode(function(pos, newnode, placer, oldnode, itemstack, pointed_thing)
	if buildNodes[newnode.name] then
		if not playerLastUsedPos[placer:get_player_name()] then
			playerLastUsedPos[placer:get_player_name()] = {}
		end
		if not playerLastUsedPosQueue[placer:get_player_name()] then
			playerLastUsedPosQueue[placer:get_player_name()] = {}
		end
		if not playerLastUsedPos[placer:get_player_name()][minetest.serialize(pos)] then
			ranking.increase_rank(placer, "builder", buildNodes[newnode.name])
			playerLastUsedPos[placer:get_player_name()][minetest.serialize(pos)] = true
			table.insert(playerLastUsedPosQueue[placer:get_player_name()], minetest.serialize(pos))
			if #playerLastUsedPosQueue[placer:get_player_name()] > 500 then
				local posstring = table.remove(playerLastUsedPosQueue[placer:get_player_name()], 1)
				playerLastUsedPos[placer:get_player_name()][posstring] = nil
			end
		else
--			print("Position was already used. Not scoring.")
		end
	end
end)

-- Global step handled rankings such as distance
minetest.register_globalstep(function(dtime)
	if skippy >= 100 then
		skippy = 0
		for k, v in pairs(players) do
			ranking.score_distance(v)
			ranking.score_experience(v)
		end
	end
	if skippy2 >= 1000 then
		skippy2 = 0
		for _, player in ipairs(minetest.get_connected_players()) do
			local name = player:get_player_name()
			if not (playerLastUsedPos[player:get_player_name()]) then
				playerLastUsedPos[player:get_player_name()] = {}
			end
			if not (playerLastUsedPosQueue[player:get_player_name()]) then
				playerLastUsedPosQueue[player:get_player_name()] = {}
			end
			if #playerLastUsedPosQueue[player:get_player_name()] > 1 then
--				print("Removing element from last used positions array")
				local posstring = table.remove(playerLastUsedPosQueue[name], 1)
				playerLastUsedPos[name][posstring] = nil
			end
		end
	end
	skippy = skippy + 1
	skippy2 = skippy2 + 1
end)

-- Traveling, caving and mountaineering loop
ranking.score_distance = function(player)
	if not player then
		return
	end

	local pos = player:get_pos()

	if not pos then
		return
	end

	local lastPos = playerLastPos[player:get_player_name()]

	if pos.x < -32000 or pos.x > 32000 or
		pos.y < -32000 or pos.y > 32000 or
		pos.z < -32000 or pos.z > 32000
	then
		if lastPos then
			player:set_pos({x = lastPos.x, y = lastPos.y, z = lastPos.z})
		elseif beds.spawn[player:get_player_name()] then
			lastPos = beds.spawn[player:get_player_name()]
			player:set_pos({x = lastPos.x, y = lastPos.y, z = lastPos.z})
		end
	else
		playerLastPos[player:get_player_name()] = pos
	end

	if lastPos then
		local xzDistance = math.sqrt( ( (pos.x - lastPos.x) ^ 2) + ( ( pos.z - lastPos.z) ^ 2) )

		if xzDistance <= 100 then
			ranking.increase_rank(player, "traveler", math.ceil(xzDistance / 10))
		end

		if (pos.y >= 0 and lastPos.y >= 0 and pos.y > lastPos.y and pos.y - lastPos.y < 100) then
			ranking.increase_rank(player, "mountaineer", math.ceil((pos.y - lastPos.y) / 10))
		end

		if (pos.y < 0 and lastPos.y < 0 and pos.y < lastPos.y and math.abs(pos.y) - math.abs(lastPos.y) < 100) then
			ranking.increase_rank(player, "caving", math.abs(   math.ceil( (math.abs(pos.y) - math.abs(lastPos.y) ) / 10)   ))
		end
	end
end

craftNodes = {}
craftNodes["basic_machines:electronics_constructor"] = 2
craftNodes["basic_machines:constructor"] = 5
craftNodes["basic_machines:digtron_constructor"] = 10

craftLevels = {}
levelMessages = {}
levelMessages[1] = ""

levelMessages[2] = "You have unlocked steel tools and armor"

craftLevels["default:sword_steel"] = 2
craftLevels["default:hoe_steel"] = 2
craftLevels["default:axe_steel"] = 2
craftLevels["default:shovel_steel"] = 2
craftLevels["default:pick_steel"] = 2
craftLevels["3d_armor:boots_steel"] = 2
craftLevels["3d_armor:chestplate_steel"] = 2
craftLevels["3d_armor:helmet_steel"] = 2
craftLevels["3d_armor:leggings_steel"] = 2
craftLevels["shields:shield_steel"] = 2

levelMessages[3] = "You have unlocked bronze tools and armor"

craftLevels["default:sword_bronze"] = 5
-- craftLevels["default:hoe_bronze"] = 5
craftLevels["default:axe_bronze"] = 5
craftLevels["default:shovel_bronze"] = 5
craftLevels["default:pick_bronze"] = 5
craftLevels["3d_armor:boots_bronze"] = 5
craftLevels["3d_armor:chestplate_bronze"] = 5
craftLevels["3d_armor:helmet_bronze"] = 5
craftLevels["3d_armor:leggings_bronze"] = 5
craftLevels["shields:shield_bronze"] = 5

levelMessages[4] = "You have unlocked mese and silver tools and basic bow and arrows"

craftLevels["default:sword_mese"] = 10
-- craftLevels["default:hoe_mese"] = 10
craftLevels["default:axe_mese"] = 10
craftLevels["default:shovel_mese"] = 10
craftLevels["default:pick_mese"] = 10
craftLevels["moreores:sword_silver"] = 10
craftLevels["moreores:shovel_silver"] = 10
craftLevels["moreores:pick_silver"] = 10
craftLevels["throwing:bow_wood"] = 10
craftLevels["throwing:bow_stone"] = 10
craftLevels["throwing:arrow"] = 10

levelMessages[5] = "You have unlocked diamond tools and armor"

craftLevels["default:sword_diamond"] = 17
-- craftLevels["default:hoe_diamond"] = 17
craftLevels["default:axe_diamond"] = 17
craftLevels["default:shovel_diamond"] = 17
craftLevels["default:pick_diamond"] = 17
craftLevels["3d_armor:boots_diamond"] = 17
craftLevels["3d_armor:chestplate_diamond"] = 17
craftLevels["3d_armor:helmet_diamond"] = 17
craftLevels["3d_armor:leggings_diamond"] = 17
craftLevels["shields:shield_diamond"] = 17

levelMessages[6] = "You have unlocked steel bow, dig and build arrows, and the electronics and small devices constructor"

craftLevels["basic_machines:electronics_constructor"] = 26
craftLevels["throwing:bow_steel"] = 26
craftLevels["throwing:arrow_dig"] = 26
craftLevels["throwing:arrow_build"] = 26

levelMessages[7] = "You have unlocked fire arrows and the basic machines constructor"

craftLevels["basic_machines:constructor"] = 37
craftLevels["throwing:arrow_fire"] = 37

levelMessages[8] = "You have unlocked mithril tools and armor"

craftLevels["moreores:sword_mithril"] = 50
craftLevels["moreores:hoe_mithril"] = 50
craftLevels["moreores:axe_mithril"] = 50
craftLevels["moreores:shovel_mithril"] = 50
craftLevels["moreores:pick_mithril"] = 50
craftLevels["3d_armor:boots_mithril"] = 50
craftLevels["3d_armor:chestplate_mithril"] = 50
craftLevels["3d_armor:helmet_mithril"] = 50
craftLevels["3d_armor:leggings_mithril"] = 50
craftLevels["shields:shield_mithril"] = 50

levelMessages[9] = "You have unlocked the spacesuit, mithril bow and arrows, and the teleport arrow"

craftLevels["moontest_spacesuit:boots_space"] = 67
craftLevels["moontest_spacesuit:chestplate_space"] = 67
craftLevels["moontest_spacesuit:helmet_space"] = 67
craftLevels["moontest_spacesuit:pants_space"] = 67
craftLevels["throwing:bow_mithril"] = 67
craftLevels["throwing:arrow_mithril"] = 67
craftLevels["throwing:arrow_teleport"] = 67

levelMessages[10] = "You have unlocked the digtron constructor"

craftLevels["basic_machines:digtron_constructor"] = 88

levelMessages[11] = "You have unlocked TNT arrows and the powerful Nyan Cat arrows. All crafts unlocked!"

craftLevels["throwing:arrow_tnt"] = 113
craftLevels["throwing:arrow_nyan"] = 113

-- Intelligence ranking based on crafting using the above machines
minetest.register_on_craft(function(itemstack, player, old_craft_grid, craft_inv)
	if craftLevels[itemstack:get_name()] and ranking.get_rank_raw(player, "experience") < craftLevels[itemstack:get_name()] then
		minetest.sound_play("ranking_error", {to_player = player:get_player_name(), gain = 0.5}, true)
		minetest.chat_send_player(player:get_player_name(), "You cannot craft this yet, you need at least "..craftLevels[itemstack:get_name()].." experience")

		for i = 1, player:get_inventory():get_size("craft") do
			player:get_inventory():set_stack("craft", i, old_craft_grid[i])
		end

		itemstack:clear()
	end

	local craftedItem = itemstack:get_name()
	if craftNodes[craftedItem] then
		ranking.increase_rank(player, "intelligence", craftNodes[craftedItem])
	end
end)

-- Traveling, caving and mountaineering loop
ranking.score_experience = function(player)
	if not player then
		return
	end

	local pos = player:get_pos()

	if not pos then
		return
	end

	local totalxp = 0

	for i = 1, #ranks do
		if (ranks[i].code ~= "experience") then
			local xp = ranking.get_rank_raw(player, ranks[i].code)
			local weightedxp = xp * ranks[i].weight
			totalxp = totalxp + weightedxp
		end
	end

	local newtotalxp = totalxp / 1000
	local oldtotalxp = ranking.get_rank_raw(player, "experience")
	ranking.set_rank_raw(player, "experience", math.floor(newtotalxp))

	local xplevels = ranks["experience"].levels

	for j = 1, #xplevels do
		if oldtotalxp < xplevels[j].min and newtotalxp >= xplevels[j].min then
			-- XP has increase, trigger on_xp_increase event!
			ranking.on_xp_increase(player, j)
			break
		end
	end

end

giftTable = {}
giftTable[1] = {} -- Baby
giftTable[2] = {"wool:white 3"} -- N00b
giftTable[3] = {"default:sword_mese"} -- Newfag
giftTable[4] = {"moreores:sword_mithril"} --Mostly harmless
giftTable[5] = {"default:mese"} -- Outsider
giftTable[6] = {"default:diamondblock"} -- Familiar face
giftTable[7] = {"unified_inventory:bag_medium"} -- Local
giftTable[8] = {"integral:moon_juice 4"} -- Oldfag
giftTable[9] = {"throwing:bow_mithril"} -- Vetrain
giftTable[10] = {"throwing:arrow_mithril 32"} -- Elder
giftTable[11] = {"underworlds:hot_stone 32"} -- The great
giftTable[12] = {"underworlds:hot_stone 64"} -- Ancient one
giftTable[13] = {"basic_machines:enviro", "throwing:arrow_mithril 32"} -- Legendary
giftTable[14] = {"moreores:mithril_block 64"} -- Demi god
giftTable[15] = {"protector:protect2 8",  "protector:chest 2", "protector:door_wood 2", "protector:trapdoor 2"} -- God
giftTable[16] = {"protector:protect2 8",  "protector:chest 2", "protector:door_wood 2", "protector:trapdoor 2", "fishing:fish_raw 200"} -- Titan
giftTable[17] = {"protector:protect2 16",  "protector:chest 4", "protector:door_wood 4", "protector:trapdoor 4"} -- Primordial Being
giftTable[18] = {"protector:protect2 32",  "protector:chest 8", "protector:door_steel 8", "protector:trapdoor_steel 8", "farming:melon_8 4"} -- Chaos
giftTable[19] = {"protector:protect2 64",  "protector:chest 16", "protector:door_wood 8", "protector:trapdoor 8",
				  "protector:door_steel 8", "protector:trapdoor_steel 8"} -- Of Unknown Origin
giftTable[20] = {"farming:joint"} -- The True Definition of Cheater

local admin = minetest.settings:get("name")

-- Give gift on reaching certain XP level
ranking.on_xp_increase = function(player, xplevel)
	if player:get_player_name() ~= admin then
		local stacks = giftTable[xplevel]
		for i = 1, #stacks do
			local stack = ItemStack(stacks[i])
			local inv = player:get_inventory()

			if inv:room_for_item("main", stack) then
				inv:add_item("main", stack)
			else
				minetest.add_item(player:get_pos(), stack)
			end
		end

		local msg = string.char(0x1b).."(c@#00ff00)"..player:get_player_name()..
					" has reached the level of: "..ranks["experience"].levels[xplevel].name
		ranking.playerXP[player:get_player_name()] = xplevel

		minetest.sound_play("ranking_level", {to_player = player:get_player_name(), gain = 2.0}, true)
		minetest.chat_send_all(msg)
		if levelMessages[xplevel] then
			minetest.chat_send_player(player:get_player_name(), levelMessages[xplevel])
		end
	end
end

minetest.register_chatcommand("rank", {
	params = "<player>",
	description = "Show rankings for given player in a form. Leave player empty to display own stats.",
	func = function(name, param)
		local player
		local specialPlayer

		if param == "" then
			player = minetest.get_player_by_name(name)
			if not player then
				return false, "FATAL: Player object for own player "..name..
							  "is nil, this should never happen."
			end
		elseif param == "SatanicBibleBot" then
			specialPlayer = "SatanicBibleBot"
		elseif param == admin then
			specialPlayer = "ADMIN"
		else
			player = minetest.get_player_by_name(param)
			if not player then
				return false, "ERROR: Player "..param.." not found or player not online."
			end
		end

		local playerName
		if specialPlayer then
			playerName = specialPlayer
		else
			playerName = player:get_player_name()
		end

		local formspec = "size[10,"..((#ranks + 2)/2).."]"
		formspec = formspec.."label[0,0;Rankings of "..playerName.."]"

		for i = 1, #ranks do
			local xp

			if player then
				xp = ranking.get_rank_raw(player, ranks[i].code)
			end

			local xpName = "No level found, check ranking mod and tables"
			local levels = ranks[i].levels
			local nextLevel = ""

			for j = 1, #levels do
				if not specialPlayer then
					if xp >= levels[j].min and xp <= levels[j].max then
						xpName = levels[j].name
						if j < #levels then
							nextLevel = "Next level starts at "..levels[j + 1].min
						else
							nextLevel = "Maximum level reached!!"
						end
						break
					end
				else
					xp = "N.a."
					nextLevel = "N.a."
					if i == 1 then
						if specialPlayer == "ADMIN" then
							xpName = "Lord administrator of this world"
						elseif specialPlayer == "SatanicBibleBot" then
							xpName = "Prince of Darkness, Lord or Evil, Almighty Ruler of Hell"
						end
					else
						xpName = "N.a."
					end
				end
			end
			if not nextLevel then
				nextLevel = "ERROR (guard against crash)"
			end
			formspec = formspec..	"label[0,"..(i/2)..";"..ranks[i].name..":]"..
									"label[2,"..(i/2)..";"..xpName.." ("..xp..")]"..
									"label[7.5,"..(i/2)..";"..nextLevel.."]"
		end

		formspec = formspec.."button_exit[7.5,"..((#ranks + 1)/2)..";2.5,1;exit;Exit]"

		minetest.show_formspec(name, "ranking:rank_form", formspec)

		return true
	end
})