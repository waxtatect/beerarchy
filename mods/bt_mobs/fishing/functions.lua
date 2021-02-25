local baits = fishing.baits
local contest = fishing.contest
local files = fishing.files
local func = fishing.func
local planned = fishing.planned
local prizes = fishing.prizes
local S = func.S

-- creative check
local creative_cache = minetest.settings:get_bool("creative_mode")
function func.creative(name)
	return creative_cache or minetest.check_player_privs(name,
		{creative = true})
end

-- load settings
function func.load(file, table)
	local input, file_settings = io.open(file, "r"), {}
	if input then
		file_settings = minetest.deserialize(input:read("*all")); input:close()
		if file_settings and type(file_settings) == "table" then
			local settings = fishing[table]
			for setting, value in pairs(file_settings) do
				settings[setting] = settings[setting] ~= nil and value
			end
		end
	end
end

-- load planned contests
function func.load_planned()
	local input, planned_settings = io.open(files.planned, "r"), {}
	if input then
		planned_settings = minetest.deserialize(input:read("*all")); input:close()
		if planned_settings and type(planned_settings) == "table" then
			for i, p in pairs(planned_settings) do
				if p["wday"] and p["hour"] and p["min"] and p["duration"] then
					table.insert(planned, {["wday"]=p["wday"], ["hour"]=p["hour"], ["min"]=p["min"], ["duration"]=p["duration"]})
				end
			end
		end
	end
end

-- load trophies
function func.load_trophies()
	local input = io.open(files.trophies, "r")
	if input then
		fishing.trophies = minetest.deserialize(input:read("*all")); input:close()
		if not fishing.trophies or type(fishing.trophies) ~= "table" then
			fishing.trophies = {}
		end
	end
end

-- save content
function func.save(file, table)
	local output, err = io.open(file, "w")
	if output then
		output:write(minetest.serialize(fishing[table])); output:close()
	else
		minetest.log("error", "open(" .. file .. ", 'w') failed: " .. err)
	end
end

function func.scheduled_save()
	minetest.log("action", "[fishing] Scheduled save. Saving trophies.")
	func.save(files.trophies, "trophies")
end

function func.request_save(init)
	if not init then
		minetest.after(5, func.scheduled_save)
	end
	minetest.after(1800, func.request_save)
end

function func.timetostr(time)
	local countdown = time
	local answer = ""
	if countdown >= 3600 then
		local hours = math.floor(countdown / 3600)
		countdown = countdown % 3600
		answer = hours .. "h"
	end
	if countdown >= 60 then
		local minutes = math.floor(countdown / 60)
		countdown = countdown % 60
		answer = answer .. minutes .. "m"
	else
		answer = answer .. "0m"
	end
	local seconds = countdown
	answer = answer .. math.floor(seconds) .. "s"
	return answer
end

minetest.register_on_joinplayer(function(player)
	local player_name = player:get_player_name()
	if contest.contest then
		minetest.chat_send_player(player_name, S("A fishing contest is in progress. (remaining time @1)", func.timetostr(contest.duration)))
	end
end)

minetest.register_on_shutdown(function()
	minetest.log("action", "[fishing] Server shuts down. Saving trophies.")
	func.save(files.trophies, "trophies")
end)

function func.start_contest(duration)
	contest.contest = true
	contest.duration = duration
	contest.nb_fish = {}
	contest.warning_said = false
	minetest.chat_send_all(S("Attention, Fishing contest start (duration @1)!!!", func.timetostr(duration)))
	minetest.sound_play("fishing_contest_start", {gain = 0.8}, true)
	func.tick()
end

function func.show_result()
	minetest.after(3, function()
		local formspec = func.get_stat()
		for _, player in pairs(minetest.get_connected_players()) do
			local player_name = player:get_player_name()
			if player_name then
				minetest.show_formspec(player_name, "fishing:classement", formspec)
			end
		end
	end)
end

function func.end_contest()
	contest.contest = false
	minetest.chat_send_all(S("End of fishing contest."))
	minetest.sound_play("fishing_contest_end", {gain = 0.8}, true)
	func.show_result()
end

-- random hungry by bait type
function func.hungry_random()
	for i, a in pairs(baits) do
		if string.find(i, "fishing:") then
			baits[i]["hungry"] = math.random(15, 80)
		end
	end

	-- to mobs_fish modpack
	if baits["mobs_fish:clownfish"] then
		baits["mobs_fish:clownfish"]["hungry"] = baits["fishing:clownfish_raw"]["hungry"]
	end
	if baits["mobs_fish:tropical"] then
		baits["mobs_fish:tropical"]["hungry"] = baits["fishing:exoticfish_raw"]["hungry"]
	end

	-- change hungry after random time, min 0h30, max 6h00
	minetest.after(math.random(1, 12) * 1800, func.hungry_random)
end

-- return table where mods actived
function func.ignore_mod(list)
	local listOk = {}
	for i, v in ipairs(list) do
		if minetest.get_modpath(v[1]) then
			table.insert(listOk, v)
		end
	end
	return listOk
end

-- return wear tool value (old or new)
function func.wear_value(wear)
	local used = 0
	if wear == "random" then
		used = 2000 * math.random(20, 29)
	elseif wear == "randomtools" then
		used = 65535 / (30 - math.random(15, 29))
	end
	return used
end

-- show notification when a player catches treasure
function func.notify(f_name, treasure)
	local title = S("Lucky @1, he caught the treasure, " .. treasure, f_name)
	for _, player in ipairs(minetest.get_connected_players()) do
		local player_name = player:get_player_name()
		if player_name == f_name then
			minetest.chat_send_player(player_name, S("You caught the treasure, " .. treasure))
		else
			minetest.chat_send_player(player_name, title)
		end
	end
end

function func.add_to_trophies(player, fish, desc)
	if not player or not player:is_player() then return end
	local player_name = player:get_player_name()
	if string.find(fish, "_raw") or prizes["true_fish"]["little"][fish] or prizes["true_fish"]["big"][fish] then
		if string.find(fish, "_raw") then
			local trophies = fishing.trophies
			if trophies[fish] == nil then
				trophies[fish] = {}
			end
			trophies[fish][player_name] = (trophies[fish][player_name] or 0) + 1
			if trophies[fish][player_name]%100 == 0 then
				local fish_name = desc:gsub("^an?%s?%l*%s?", "")
				local nb = trophies[fish][player_name]
				minetest.chat_send_player(player_name, S("You win a new trophy, you have caught @1 " .. fish_name, nb))
				local name = "fishing:trophy_" .. fish
				local inv = player:get_inventory()
				local item = ItemStack({
					name = name,
					count = 1,
					metadata = minetest.serialize({
						fish = fish,
						nb = nb,
						owner = player_name
					})
				})
				item:get_meta():set_string("description", S("Trophy of @1's @2th " .. fish_name:sub(1, -2), player_name, nb))
				if inv and inv:room_for_item("main", name) then
					inv:add_item("main", item)
				else
					minetest.spawn_item(player:get_pos(), item)
				end
			end
		end
		if contest.contest then
			if contest.nb_fish == nil then
				contest.nb_fish = {}
			end
			contest.nb_fish[player_name] = (contest.nb_fish[player_name] or 0) + 1
			minetest.chat_send_all(S("Yeah, @1 caught " .. desc, player_name))
		end
	end
end

function func.get_loot()
	if #prizes["stuff"] <= 0 then return end
	local c = math.random(1, prizes["stuff"][#prizes["stuff"]][5])
	for i in pairs(prizes["stuff"]) do
		local min = prizes["stuff"][i][5]
		local chance = prizes["stuff"][i][6]
		local max = min + chance
		if c <= max and c >= min then
			return prizes["stuff"][i]
		end
	end
end

-- Menu: fishing
func.on_show_admin_menu = function(player_name)
	minetest.show_formspec(player_name, "fishing:admin_conf",
		"size[5,5]label[1.7,0;"..S("Fishing Menu").."]"..
		"button[0.5,0.5;4,1;classement;"..S("Contest rankings").."]"..
		"button[0.5,1.5;4,1;contest;"..S("Contests").."]"..
		"button[0.5,2.5;4,1;configuration;"..S("Configuration").."]"..
		"button[0.5,3.5;4,1;hungerinfo;"..S("Hunger info").."]"..
		"button_exit[1,4.5;3,1;close;"..S("Close").."]"
	)
end

local function spairs(t, order)
	-- collect the keys
	local keys = {}
	for k in pairs(t) do keys[#keys + 1] = k end
	-- if order function given, sort by it by passing the table and keys a, b,
	-- otherwise just sort the keys
	if order then
		table.sort(keys, function(a, b) return order(t, a, b) end)
	else
		table.sort(keys)
	end
	-- return the iterator function
	local i = 0
	return function()
		i = i + 1
		if keys[i] then
			return keys[i], t[keys[i]]
		end
	end
end

function func.set_winners(list)
	local win = {}
	-- this uses an custom sorting function ordering by score descending
	for k, v in spairs(list, function(t, a, b) return t[b] < t[a] end) do
		table.insert(win, {["name"]=k, ["nb"]=v})
		if #win >= 15 then
			break
		end
	end
	return win
end

-- Contest rankings
function func.get_stat()
	local winners = {}
	if contest.nb_fish then
		winners = func.set_winners(contest.nb_fish)
	end
	local formspec = {"size[6,8]label[1.5,0;"..S("Fishing contest rankings").."]"}
	local Y = 1.1
	table.insert(formspec, "label[0.5,0.5;"..S("No").."]")
	table.insert(formspec, "label[2,0.5;"..S("Name").."]")
	table.insert(formspec, "label[4.2,0.5;"..S("Fish Total").."]")
	for num, n in ipairs(winners) do
		table.insert(formspec, "label[0.5,"..Y..";"..tostring(num).."]") -- classement
		table.insert(formspec, "label[2,"..Y..";"..n["name"].."]") -- playername
		table.insert(formspec, "label[4.3,"..Y..";"..tostring(n["nb"]).."]") -- nb fishes caught
		Y = Y + 0.4
	end
	table.insert(formspec, "button_exit[2.4,7.5;1.2,1;close;"..S("Close").."]")
	return table.concat(formspec)
end

if minetest.get_modpath("unified_inventory") then
	unified_inventory.register_button("menu_fishing", {
		type = "image",
		image = "fishing_perch_raw.png",
		tooltip = S("Fishing Menu"),
		action = function(player)
			if not player or not player:is_player() then return end
			local player_name = player:get_player_name()
			if minetest.check_player_privs(player_name, {server = true}) then
				func.on_show_admin_menu(player_name)
			else
				minetest.show_formspec(player_name, "fishing:classement", func.get_stat())
			end
		end
	})
end

-- Contests
func.on_show_settings_contest = function(player_name)
	if not fishing.tmp_settings then
		fishing.tmp_settings = {
			bobber_nb = contest.bobber_nb or 2,
			contest = contest.contest or false,
			duration = math.floor(contest.duration) or 3600,
			planned_contest = contest.planned_contest or false,
			reset = false
		}
	end
	local tmp_settings = fishing.tmp_settings
	minetest.show_formspec(player_name, "fishing:contest",
		"size[6.1,8.4]label[1.9,0;"..S("Fishing contest").."]"..
		-- time contest
		"label[2.2,0.5;"..S("Duration (in sec)").."]"..
		"button[0.8,1;1,1;duration;-60]"..
		"button[1.8,1;1,1;duration;-600]"..
		"label[2.7,1.2;"..tostring(tmp_settings.duration).."]"..
		"button[3.5,1;1,1;duration;+600]"..
		"button[4.5,1;1,1;duration;+60]"..
		-- bobber nb
		"label[2,2;"..S("Bobber number limit").."]"..
		"button[1.8,2.5;1,1;bobbernb;-1]"..
		"label[2.9,2.7;"..tostring(tmp_settings.bobber_nb).."]"..
		"button[3.5,2.5;1,1;bobbernb;+1]"..
		-- contest enable
		"label[0.8,3.8;"..S("Enable contest").."]"..
		"button[4.5,3.6;1,1;contest;"..tostring(tmp_settings.contest).."]"..
		-- planned contests enable
		"label[0.8,5.2;"..S("Enable planned contests").."]"..
		"button[4.5,5;1,1;planned_contest;"..tostring(tmp_settings.planned_contest).."]"..
		-- reset
		"label[0.8,6.6;"..S("Reset rankings").."]"..
		"button[4.5,6.4;1,1;reset;"..tostring(tmp_settings.reset).."]"..
		"button_exit[0.8,7.4;1.5,1;abort;"..S("Abort").."]"..
		"button_exit[4,7.4;1.5,1;save;"..S("OK").."]"
	)
end

local inc = function(value, field, min, max)
	local inc = tonumber(field)
	local v = value
	if inc then
		v = value + inc
	end

	if v > max then
		return max
	end
	if v < min then
		return min
	end
	return v
end

local bool = function(field)
	return field ~= "true"
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname == "fishing:contest" then
		if not player or not player:is_player() then return end
		local tmp_settings = fishing.tmp_settings
		local name = player:get_player_name()
		if fields.save then
			if tmp_settings.reset then
				contest.nb_fish = {}
			end
			local progress = contest.contest or false
			contest.bobber_nb = tmp_settings.bobber_nb
			contest.contest = tmp_settings.contest
			contest.duration = tmp_settings.duration
			if not progress and tmp_settings.contest then
				func.start_contest(contest.duration)
			elseif progress and not tmp_settings.contest then
				func.end_contest()
			end
			contest.planned_contest = tmp_settings.planned_contest
			if contest.planned_contest then
				func.planned_tick()
			end
			func.save(files.contest, "contest")
			fishing.tmp_settings = nil
			return
		elseif fields.quit or fields.abort then
			fishing.tmp_settings = nil
			return
		elseif fields.duration then
			tmp_settings.duration = inc(tmp_settings.duration, fields.duration, 120, 14400)
		elseif fields.contest then
			tmp_settings.contest = bool(fields.contest)
		elseif fields.planned_contest then
			tmp_settings.planned_contest = bool(fields.planned_contest)
		elseif fields.bobbernb then
			tmp_settings.bobber_nb = inc(tmp_settings.bobber_nb, fields.bobbernb, 1, 8)
		elseif fields.reset then
			tmp_settings.reset = bool(fields.reset)
		else
			return
		end
		func.on_show_settings_contest(name)
	end
end)

-- Configuration
func.on_show_settings = function(player_name)
	if not fishing.tmp_settings then
		fishing.tmp_settings = table.copy(fishing.settings)
	end
	local tmp_settings = fishing.tmp_settings
	minetest.show_formspec(player_name, "fishing:settings",
		"size[10.8,9]label[4,0;"..S("Fishing configuration").."]"..
		-- fish chance
		"label[1.6,0.5;"..S("Fish chance").."]"..
		"button[0,1;1,1;cfish;-1]"..
		"button[1,1;1,1;cfish;-10]"..
		"label[2.1,1.2;"..tostring(tmp_settings.fish_chance).."]"..
		"button[2.7,1;1,1;cfish;+10]"..
		"button[3.7,1;1,1;cfish;+1]"..
		-- shark chance
		"label[1.5,2;"..S("Shark chance").."]"..
		"button[0,2.5;1,1;cshark;-1]"..
		"button[1,2.5;1,1;cshark;-10]"..
		"label[2.1,2.7;"..tostring(tmp_settings.shark_chance).."]"..
		"button[2.7,2.5;1,1;cshark;+10]"..
		"button[3.7,2.5;1,1;cshark;+1]"..
		-- treasure chance
		"label[1.5,3.5;"..S("Treasure chance").."]"..
		"button[0,4.;1,1;ctreasure;-1]"..
		"button[1,4;1,1;ctreasure;-10]"..
		"label[2.1,4.2;"..tostring(tmp_settings.treasure_chance).."]"..
		"button[2.7,4;1,1;ctreasure;+10]"..
		"button[3.7,4;1,1;ctreasure;+1]"..
		-- worm chance
		"label[7.5,0.5;"..S("Worm chance").."]"..
		"button[6,1;1,1;cworm;-1]"..
		"button[7,1;1,1;cworm;-10]"..
		"label[8.1,1.2;"..tostring(tmp_settings.worm_chance).."]"..
		"button[8.7,1;1,1;cworm;+10]"..
		"button[9.7,1;1,1;cworm;+1]"..
		-- escape chance
		"label[7.4,2;"..S("Escape chance").."]"..
		"button[6,2.5;1,1;cescape;-1]"..
		"button[7,2.5;1,1;cescape;-10]"..
		"label[8.1,2.7;"..tostring(tmp_settings.escape_chance).."]"..
		"button[8.7,2.5;1,1;cescape;+10]"..
		"button[9.7,2.5;1,1;cescape;+1]"..
		-- bobber view range
		"label[7.2,3.5;"..S("Bobbers view range").."]"..
		"button[7,4;1,1;bvrange;-1]"..
		"label[8.1,4.2;"..tostring(tmp_settings.bobber_view_range).."]"..
		"button[8.7,4;1,1;bvrange;+1]"..
		-- messages display
		"label[0,5.7;"..S("Display messages in chat").."]"..
		"button[3.7,5.5;1,1;dmessages;"..tostring(tmp_settings.message).."]"..
		-- poledeco
		"label[0,6.5;"..S("Simple pole deco").."]"..
		"button[3.7,6.3;1,1;poledeco;"..tostring(tmp_settings.simple_deco_fishing_pole).."]"..
		-- wearout
		"label[0,7.3;"..S("Poles wearout").."]"..
		"button[3.7,7.1;1,1;wearout;"..tostring(tmp_settings.wear_out).."]"..
		-- treasure_enable
		"label[6,5.7;"..S("Enable treasure").."]"..
		"button[9.7,5.5;1,1;treasureenable;"..tostring(tmp_settings.treasure_enable).."]"..
		-- new_worms_source
		"label[6,6.5;"..S("New worms source (reboot)").."]"..
		"button[9.7,6.3;1,1;newworms;"..tostring(tmp_settings.new_worms_source).."]"..
		-- worm_is_mob
		"label[6,7.3;"..S("Worm is a mob (reboot)").."]"..
		"button[9.7,7.1;1,1;wormmob;"..tostring(tmp_settings.worm_is_mob).."]"..
		"button_exit[0,8.2;1.5,1;abort;"..S("Abort").."]"..
		"button_exit[9.2,8.2;1.5,1;save;"..S("OK").."]"
	)
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if not player or not player:is_player() then return end
	local player_name = player:get_player_name()
	if formname == "fishing:settings" then
		local tmp_settings = fishing.tmp_settings
		if fields.save then
			fishing.settings = table.copy(tmp_settings)
			func.save(files.settings, "settings")
			fishing.tmp_settings = nil
			return
		elseif fields.quit or fields.abort then
			fishing.tmp_settings = nil
			return
		elseif fields.cfish then
			tmp_settings.fish_chance = inc(tmp_settings.fish_chance, fields.cfish, 1, 100)
		elseif fields.cshark then
			tmp_settings.shark_chance = inc(tmp_settings.shark_chance, fields.cshark, 1, 100)
		elseif fields.ctreasure then
			tmp_settings.treasure_chance = inc(tmp_settings.treasure_chance, fields.ctreasure, 1, 100)
		elseif fields.bvrange then
			tmp_settings.bobber_view_range = inc(tmp_settings.bobber_view_range, fields.bvrange, 4, 20)
		elseif fields.cworm then
			tmp_settings.worm_chance = inc(tmp_settings.worm_chance, fields.cworm, 1, 100)
		elseif fields.cescape then
			tmp_settings.escape_chance = inc(tmp_settings.escape_chance, fields.cescape, 1, 50)
		elseif fields.dmessages then
			tmp_settings.message = bool(fields.dmessages)
		elseif fields.poledeco then
			tmp_settings.simple_deco_fishing_pole = bool(fields.poledeco)
		elseif fields.wearout then
			tmp_settings.wear_out = bool(fields.wearout)
		elseif fields.treasureenable then
			tmp_settings.treasure_enable = bool(fields.treasureenable)
		elseif fields.newworms then
			tmp_settings.new_worms_source = bool(fields.newworms)
		elseif fields.wormmob then
			tmp_settings.worm_is_mob = bool(fields.wormmob)
		else
			return
		end
		func.on_show_settings(player_name)
	elseif formname == "fishing:admin_conf" then
		if fields.classement then
			minetest.show_formspec(player_name, "fishing:classement", func.get_stat())
		elseif fields.contest then
			func.on_show_settings_contest(player_name)
		elseif fields.configuration then
			func.on_show_settings(player_name)
		elseif fields.hungerinfo then
			func.get_hunger_info(player_name)
		end
	end
end)

-- Hunger info
function func.get_hunger_info(player_name)
	local formspec = "size[6,9]label[1.9,0;"..S("Fishing Info Center").."]"
	local y = 0.8
	for i, a in pairs(baits) do
		if string.find(i, "fishing:") then
			formspec = formspec .."item_image_button[1,"..tostring(y)..";1,1;"..tostring(i)..";"..tostring(i)..";]"..
				"label[2.2,"..tostring(y + 0.2)..";"..S("Chance to fish : @1%", tostring(a["hungry"])).."]"
			y = y + 1
		end
	end
	formspec = formspec .. "button_exit[2,8.5;2,1;close;" .. S("Close") .. "]"
	minetest.show_formspec(player_name, "fishing:material_info", formspec)
end

local isint = function(v)
	return v == math.floor(v)
end

local UPDATE_TIME = 1
function func.tick()
	if contest.contest then
		contest.duration = contest.duration - UPDATE_TIME
		if isint(contest.duration / 10) or contest.duration < 0 then
			func.save(files.contest, "contest")
		end
		if contest.duration < 30 and not contest.warning_said then
			minetest.chat_send_all(S("WARNING, Fishing contest will finish in 30 seconds."))
			contest.warning_said = true
		end
		if contest.duration < 0 then
			func.end_contest()
		else
			minetest.after(UPDATE_TIME, func.tick)
		end
	end
end

function func.planned_tick()
	if contest.contest or #planned == 0 then return end
	for i, plan in pairs(planned) do
		local wday = plan.wday
		local hour = plan.hour
		local min = plan.min
		local duration = plan.duration
		local time = os.date("*t", os.time())
		if wday == 0 or wday == time.wday then
			if time.hour == hour and time.min == min then
				minetest.log("action", ("Starting fishing contest at %d:%d duration %d"):format(hour, min, duration))
				func.start_contest(duration)
				break
			end
		end
	end
	minetest.after(50, func.planned_tick)
end

minetest.register_chatcommand("contest_start", {
	params = S("Duration in seconds"),
	description = S("Start contest (admin only)"),
	privs = {server = true},
	func = function(player_name, param)
		if not player_name then return end
		if contest.contest then
			return false, S("Contest already in progress.")
		end
		local duration = tonumber(param) or 3600
		func.start_contest(duration)
		return true, S("Contest started, duration: @1 sec.", duration)
	end
})

minetest.register_chatcommand("contest_stop", {
	description = S("Stop contest (admin only)"),
	privs = {server = true},
	func = function(player_name, param)
		if not player_name then return end
		if not contest.contest then
			return false, S("No contest in progress.")
		end
		func.end_contest()
		return true, S("Contest finished.")
	end
})

minetest.register_chatcommand("contest_add", {
	params = S("Wday Hours Minutes duration (in sec) (ex: 1 15 40 3600)"),
	description = S("Add contest (admin only)"),
	privs = {server = true},
	func = function(player_name, param)
		if not player_name then return end
		local wday, hour, min, duration = param:match("^(%d+)%s(%d+)%s(%d+)%s(%d+)$")
		if ((not wday or not tonumber(wday)) or (not hour or not tonumber(hour)) or (not min and not tonumber(min)) or (not duration or not tonumber(duration))) then
			return false, S("Invalid usage, see /help contest_add.")
		end

		wday = tonumber(wday)
		hour = tonumber(hour)
		min = tonumber(min)
		duration = tonumber(duration)

		if wday < 0 or wday > 7 then
			return false, S("Invalid argument wday, 0-7 (0=all 1=Sunday).")
		end

		if hour < 0 or hour > 23 then
			return false, S("Invalid argument hours, 0-23.")
		end
		if min < 0 or min > 59 then
			return false, S("Invalid argument minutes, 0-59.")
		end

		duration = duration < 120 and 120 or duration > 14400 and 14400

		table.insert(planned, {["wday"]=wday, ["hour"]=hour, ["min"]=min, ["duration"]=duration})
		func.save(files.planned, "planned")
		if contest.planned_contest then
			func.planned_tick()
		end
		return true, S("New contest registered @1 @2:@3 duration @4 sec.", wday, hour, min, duration)
	end
})

minetest.register_chatcommand("contest_del", {
	params = S("List number (shown by contest_show command)"),
	description = S("Delete planned contest (admin only)"),
	privs = {server = true},
	func = function(player_name, param)
		if not player_name then return end
		local i = tonumber(param)
		if not i then
			return false, S("Invalid usage, see /help contest_del.")
		end
		if i < 1 then
			return false, S("Invalid usage, see /help contest_del.")
		end

		local c = planned[i]
		if not c then
			return false, S("Contest not found.")
		end
		table.remove(planned, i)
		func.save(files.planned, "planned")
		return true, S("Contest deleted.")
	end
})

minetest.register_chatcommand("contest_show", {
	description = S("Display planned contests (admin only)"),
	privs = {server = true},
	func = function(player_name, param)
		if not player_name then return end
		local text = "Registered contest:\n"
		for i, plan in pairs(planned) do
			text = text .. S("@1 wday:@2 hour:@3 min:@4, duration @5 sec.\n", i, plan.wday, plan.hour, plan.min, plan.duration)
		end
		return true, text
	end
})

minetest.register_chatcommand("fishing_menu", {
	description = S("Show fishing menu (admin only)"),
	privs = {server = true},
	func = function(player_name, param)
		if not player_name then return end
		func.on_show_admin_menu(player_name)
	end
})

minetest.register_chatcommand("trophy_reset", {
	description = S("Reset player fishes count\nWARNING, once reset, if prizes trophies are replaced, displayed message will be updated consequently"),
	privs = {interact = true},
	func = function(player_name, param)
		if not player_name then return end
		local trophies = fishing.trophies
		for _, trophy in ipairs(fishing.registered_trophies) do
			local fish = trophy[2]
			if trophies[fish] and trophies[fish][player_name] then
				trophies[fish][player_name] = nil
				if next(trophies[fish]) == nil then
					trophies[fish] = nil
				end
			end
		end
		func.request_save()
		return true, S("Fishes count has been reset.")
	end
})

minetest.register_chatcommand("fishing_classement", {
	description = S("Display classement"),
	privs = {interact = true},
	func = function(player_name, param)
		if not player_name then return end
		minetest.show_formspec(player_name, "fishing:classement", func.get_stat())
	end
})