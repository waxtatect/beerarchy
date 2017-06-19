local players = {}
local playerLastUsedPos = {}
local playerLastUsedPosQueue = {}
ranking = {}

local skippy = 0
local skippy2 = 0

dofile(minetest.get_modpath("00_bt_ranking").."/rankings.lua")

ranking.get_rank_raw = function(player, rankName)
	local inv = player:get_inventory()
	if not inv then return nil end
	return inv:get_stack("ranking", ranks[rankName].index):get_count()
end

ranking.set_rank_raw = function(player, rankName, value)
	local inv = player:get_inventory()
	local name = player:get_player_name()
	if not inv then return nil end
	inv:set_stack("ranking", ranks[rankName].index, ItemStack( { name = ":", count = value } ))
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
end)

minetest.register_on_leaveplayer(function(player)
	local name = player:get_player_name()
	players[name] = nil
	minetest.after(300, clearPlayerPos, player:get_player_name())
end)

function clearPlayerPos(playerName)
	local playerFound = false
	for _,player in ipairs(minetest.get_connected_players()) do
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
minerNodes = {}
minerNodes["default:stone_with_coal"] = 1
minerNodes["default:coalblock"] = 2
minerNodes["moreores:mineral_tin"] = 1
minerNodes["default:stone_with_iron"] = 2
minerNodes["default:stone_with_copper"] = 2
minerNodes["moreores:mineral_silver"] = 3
minerNodes["default:stone_with_gold"] = 3
minerNodes["default:stone_with_mese"] = 4
minerNodes["default:stone_with_diamond"] = 5
minerNodes["default:mese"] = 6
minerNodes["default:diamondblock"] = 8
minerNodes["moreores:mineral_mithril"] = 10
minerNodes["nyancat:nyancat_rainbow"] = 20
minerNodes["nyancat:nyancat"] = 50

farmNodes = {}

farmNodes["default:cactus"] = 1
farmNodes["default:papyrus"] = 1

-- Mining and farming events using the above tables to determine the scores
minetest.register_on_dignode(function(pos, oldnode, digger)
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
	end
end)

buildNodes = {}

buildNodes["default:stone"] = 2
buildNodes["default:cobble"] = 1
buildNodes["default:stonebrick"] = 2
buildNodes["default:stone_block"] = 4
buildNodes["default:mossycobble"] = 1

buildNodes["default:desert_stone"] = 2
buildNodes["default:desert_cobble"] = 1
buildNodes["default:desert_stonebrick"] = 2
buildNodes["default:desert_stone_block"] = 4

buildNodes["default:sandstone"] = 1
buildNodes["default:sandstonebrick"] = 2
buildNodes["default:sandstone_block"] = 4
buildNodes["default:desert_sandstone"] = 1
buildNodes["default:desert_sandstone_brick"] = 2
buildNodes["default:desert_sandstone_block"] = 4
buildNodes["default:silver_sandstone"] = 1
buildNodes["default:silver_sandstone_brick"] = 2
buildNodes["default:silver_sandstone_block"] = 4

buildNodes["default:obsidian"] = 5
buildNodes["default:obsidianbrick"] = 10
buildNodes["default:obsidian_block"] = 20

buildNodes["default:tree"] = 1
buildNodes["default:wood"] = 2
buildNodes["default:jungletree"] = 1
buildNodes["default:junglewood"] = 2
buildNodes["default:pine_tree"] = 1
buildNodes["default:pine_wood"] = 2
buildNodes["default:acacia_tree"] = 1
buildNodes["default:acacia_wood"] = 2
buildNodes["default:aspen_tree"] = 1
buildNodes["default:aspen_wood"] = 2

buildNodes["default:tinblock"] = 2
buildNodes["default:steelblock"] = 3
buildNodes["default:copperblock"] = 4
buildNodes["default:bronzeblock"] = 5
buildNodes["default:goldblock"] = 6
buildNodes["default:mese"] = 8
buildNodes["default:diamondblock"] = 10

buildNodes["default:chest"] = 2
buildNodes["default:bookshelf"] = 4
buildNodes["default:sign_wall_wood"] = 2
buildNodes["default:sign_wall_steel"] = 3
buildNodes["default:ladder_wood"] = 2
buildNodes["default:ladder_steel"] = 3
buildNodes["default:fence_wood"] = 3
buildNodes["default:fence_acacia_wood"] = 3
buildNodes["default:fence_junglewood"] = 3
buildNodes["default:fence_pine_wood"] = 3
buildNodes["default:fence_aspen_wood"] = 3
buildNodes["default:glass"] = 2
buildNodes["default:obsidian_glass"] = 4
buildNodes["default:brick"] = 2
buildNodes["default:meselamp"] = 4
buildNodes["default:mese_post_light"] = 5

buildNodes["stairs:slab_acacia_wood"] = 3
buildNodes["stairs:stair_acacia_wood"] = 4
buildNodes["stairs:slab_aspen_wood"] = 3
buildNodes["stairs:stair_aspen_wood"] = 4
buildNodes["stairs:slab_brick"] = 3
buildNodes["stairs:stair_brick"] = 4
buildNodes["stairs:slab_bronzeblock"] = 5
buildNodes["stairs:stair_bronzeblock"] = 7
buildNodes["stairs:slab_cobble"] = 2
buildNodes["stairs:stair_cobble"] = 3
buildNodes["stairs:slab_copperblock"] = 6
buildNodes["stairs:stair_copperblock"] = 8
buildNodes["stairs:slab_desert_cobble"] = 2
buildNodes["stairs:stair_desert_cobble"] = 3
buildNodes["stairs:slab_desert_sandstone"] = 2
buildNodes["stairs:stair_desert_sandstone"] = 3
buildNodes["stairs:slab_desert_sandstone_block"] = 4
buildNodes["stairs:stair_desert_sandstone_block"] = 5
buildNodes["stairs:slab_desert_sandstone_brick"] = 3
buildNodes["stairs:stair_desert_sandstone_brick"] = 4
buildNodes["stairs:slab_desert_stone"] = 3
buildNodes["stairs:stair_desert_stone"] = 4
buildNodes["stairs:slab_desert_stone_block"] = 4
buildNodes["stairs:stair_desert_stone_block"] = 5
buildNodes["stairs:slab_desert_stonebrick"] = 3
buildNodes["stairs:stair_desert_stonebrick"] = 4
buildNodes["stairs:slab_goldblock"] = 7
buildNodes["stairs:stair_goldblock"] = 9
buildNodes["stairs:slab_ice"] = 4
buildNodes["stairs:stair_ice"] = 5
buildNodes["stairs:slab_junglewood"] = 3
buildNodes["stairs:stair_junglewood"] = 4
buildNodes["stairs:slab_mossycobble"] = 3
buildNodes["stairs:stair_mossycobble"] = 4
buildNodes["stairs:slab_obsidian"] = 10
buildNodes["stairs:stair_obsidian"] = 12
buildNodes["stairs:slab_obsidian_block"] = 12
buildNodes["stairs:stair_obsidian_block"] = 14
buildNodes["stairs:slab_obsidianbrick"] = 14
buildNodes["stairs:stair_obsidianbrick"] = 16
buildNodes["stairs:slab_pine_wood"] = 3
buildNodes["stairs:stair_pine_wood"] = 4
buildNodes["stairs:slab_sandstone"] = 3
buildNodes["stairs:stair_sandstone"] = 4
buildNodes["stairs:slab_sandstone_block"] = 4
buildNodes["stairs:stair_sandstone_block"] = 5
buildNodes["stairs:slab_sandstonebrick"] = 3
buildNodes["stairs:stair_sandstonebrick"] = 4
buildNodes["stairs:slab_silver_sandstone"] = 3
buildNodes["stairs:stair_silver_sandstone"] = 4
buildNodes["stairs:slab_silver_sandstone_block"] = 4
buildNodes["stairs:stair_silver_sandstone_block"] = 5
buildNodes["stairs:slab_silver_sandstone_brick"] = 3
buildNodes["stairs:stair_silver_sandstone_brick"] = 4
buildNodes["stairs:slab_snowblock"] = 3
buildNodes["stairs:stair_snowblock"] = 4
buildNodes["stairs:slab_steelblock"] = 4
buildNodes["stairs:stair_steelblock"] = 6
buildNodes["stairs:slab_stone"] = 4
buildNodes["stairs:stair_stone"] = 5
buildNodes["stairs:slab_stone_block"] = 5
buildNodes["stairs:stair_stone_block"] = 6
buildNodes["stairs:slab_stonebrick"] = 5
buildNodes["stairs:stair_stonebrick"] = 6
buildNodes["stairs:slab_straw"] = 4
buildNodes["stairs:stair_straw"] = 5
buildNodes["stairs:slab_wood"] = 3
buildNodes["stairs:stair_wood"] = 4

-- Builder ranking based on place node event
minetest.register_on_placenode(function(pos, newnode, placer, oldnode, itemstack, pointed_thing)
	if minerNodes[newnode.name] then
		if not playerLastUsedPos[placer:get_player_name()] then
			playerLastUsedPos[placer:get_player_name()] = {}
		end
		if not playerLastUsedPosQueue[placer:get_player_name()] then
			playerLastUsedPosQueue[placer:get_player_name()] = {}
		end
		if not playerLastUsedPos[placer:get_player_name()][minetest.serialize(pos)] then
			ranking.increase_rank(placer, "builder", 1)
			playerLastUsedPos[placer:get_player_name()][minetest.serialize(pos)] = true
			table.insert(playerLastUsedPosQueue[placer:get_player_name()], minetest.serialize(pos))
			if #playerLastUsedPosQueue[placer:get_player_name()] > 500 then
				local posstring = table.remove(playerLastUsedPosQueue[placer:get_player_name()], 1)
				playerLastUsedPos[placer:get_player_name()][posstring] = nil
			end
		else
			print("Position was already used. Not scoring.")
		end
	end
end)

-- Global step handled rankings such as distance
minetest.register_globalstep(function(dtime)
	if skippy >= 100 then
		skippy = 0
		for k,v in pairs(players) do
			ranking.score_distance(v)
			ranking.score_experience(v)
		end
	end
	if skippy2 >= 1000 then
		skippy2 = 0
		for _,player in ipairs(minetest.get_connected_players()) do
			local name = player:get_player_name()
			if not (playerLastUsedPos[player:get_player_name()]) then
				playerLastUsedPos[player:get_player_name()] = {}
			end
			if not (playerLastUsedPosQueue[player:get_player_name()]) then
				playerLastUsedPosQueue[player:get_player_name()] = {}
			end
			if #playerLastUsedPosQueue[player:get_player_name()] > 1 then
				print("Removing element from last used positions array")
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

	local pos = player:getpos()

	if not pos then
		return
	end

	local xzDistance = math.sqrt( (pos.x ^ 2) + (pos.z ^ 2) )
	local lastxzDistance = ranking.get_rank_raw(player, "traveler")
	if (xzDistance > lastxzDistance) then
		ranking.set_rank_raw(player, "traveler", math.floor(xzDistance) + 1)
	end

	local lastHeight = ranking.get_rank_raw(player, "mountaineer")
	if (pos.y > lastHeight) then
		ranking.set_rank_raw(player, "mountaineer", math.floor(pos.y) + 1)
	end

	local lastDepth = ranking.get_rank_raw(player, "caving")
	if (pos.y < lastDepth) then
		ranking.set_rank_raw(player, "caving", math.abs(math.floor(pos.y) - 1))
	end
end

craftNodes = {}
craftNodes["basic_machines:electronics_constructor"] = 2
craftNodes["basic_machines:constructor"] = 5
craftNodes["basic_machines:digtron_constructor"] = 10

-- Intelligence ranking based on crafting using the above machines
minetest.register_on_craft(function(itemstack, player, old_craft_grid, craft_inv)
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

	local pos = player:getpos()

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

-- Give gift on reaching certain XP level
ranking.on_xp_increase = function(player, xplevel)
	if player:get_player_name() ~= "Beerholder" then
		local stack = ItemStack("protector:protect2")
		local inv = player:get_inventory()

		if inv:room_for_item("main", stack) then
			inv:add_item("main", stack)
		else
			minetest.add_item(player:getpos(), stack)
		end

		local msg = string.char(0x1b).."(c@#00ff00)"..player:get_player_name()..
					" has reached the level of: "..ranks["experience"].levels[xplevel].name

		minetest.sound_play("00_bt_ranking_level", { to_player = player:get_player_name(), gain = 2.0 })
		minetest.chat_send_all(msg)
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
		elseif param == "Beerholder" then
			specialPlayer = "ADMIN"
		else
			player = minetest.get_player_by_name(param)
			if not player then
				return false, "ERROR: Player "..param.." not found."
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
			local nextLevel

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
			formspec = formspec..	"label[0,"..(i/2)..";"..ranks[i].name..":]"..
									"label[2,"..(i/2)..";"..xpName.." ("..xp..")]"..
									"label[7.5,"..(i/2)..";"..nextLevel.."]"
		end

		formspec = formspec.."button_exit[7.5,"..((#ranks + 1)/2)..";2.5,1;exit;Exit]"

		minetest.show_formspec(name, "ranking:rank_form", formspec)

		return true

	end,
})

--
-- Old rank chat command (not formspec based), can probably be removed as the formspec works better
--
--[[minetest.register_chatcommand("rank", {
	params = "<player>",
	description =	"Show rankings for given player. Leave player empty to list own stats.",
	func = function(name, param)
		local output = ""

		local player

		if param == "" then
			player = minetest.get_player_by_name(name)
			if not player then
				return false, "FATAL: Player object for own player "..name..
							  "is nil, this should never happen."
			end
		elseif param == "SatanicBibleBot" then
			return true, "Experience: Prince of Darkness, Lord or Evil, Almighty Ruler of Hell"
		else
			player = minetest.get_player_by_name(param)
			if not player then
				return false, "ERROR: Player "..param.." not found."
			end
		end

		return true, ranking.get_ranks(player)

	end,
})]]--
