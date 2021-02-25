-----------------------------------------------------------------------------------------------
-- original by wulfsdad (http://forum.minetest.net/viewtopic.php?id=4375)
-- rewrited by Mossmanikin (https://forum.minetest.net/viewtopic.php?id=6480)
-- this version rewrited by Crabman77
-- License (code & textures): 	WTFPL
-- Contains code from: 		animal_clownfish, animal_fish_blue_white, fishing (original), stoneage
-- Looked at code from:		default, farming
-- Dependencies: 			default
-- Supports:				animal_clownfish, animal_fish_blue_white, animal_rat, mobs
-----------------------------------------------------------------------------------------------
local mname = "fishing"
local WP = minetest.get_worldpath() .. "/" .. mname .. "/"
local MP = minetest.get_modpath(mname) .. "/"

minetest.mkdir(WP)

fishing = {
	baits = {},
	contest = {},
	files = {
		contest = WP .. "fishing_contest.txt",
		planned = WP .. "fishing_planned.txt",
		settings = WP .. "fishing_settings.txt",
		trophies = WP .. "fishing_trophies.txt"
	},
	func = {},
	hungry = {},
	planned = {},
	prizes = {},
	registered_trophies = {},
	settings = {},
	trophies = {},
	version = "1.0.0"
}

local files = fishing.files
local func = fishing.func
local settings = fishing.settings

func.S = minetest.get_translator("fishing")

-- default settings
fishing.contest = {
	bobber_nb = 4,
	contest = false,
	duration = 3600,
	nb_fish = {},
	planned_contest = false,
	warning_said = false
}
fishing.settings = {
	bobber_view_range = 7,
	escape_chance = 5,
	fish_chance = 60,
	have_true_fish = false,
	message = true,
	new_worms_source = true,
	shark_chance = 50,
	simple_deco_fishing_pole = true,
	treasure_chance = 5,
	treasure_enable = true,
	wear_out = true,
	worm_chance = 66,
	worm_is_mob = true
}
if minetest.get_modpath("mobs_fish") or minetest.get_modpath("mobs_sharks") then
	settings.have_true_fish = true
end

dofile(MP .. "baits.lua")
dofile(MP .. "baitball.lua")
dofile(MP .. "bobber.lua")
dofile(MP .. "bobber_shark.lua")
dofile(MP .. "crafting.lua")
dofile(MP .. "fishes.lua")
dofile(MP .. "functions.lua")
dofile(MP .. "poles.lua")
dofile(MP .. "prizes.lua")
dofile(MP .. "trophies.lua")
dofile(MP .. "worms.lua")

-- load settings files
func.load(files.contest, "contest")
func.load(files.settings, "settings")
func.load_planned()
func.load_trophies()

func.tick()
if fishing.contest.planned_contest then
	func.planned_tick()
end
func.hungry_random()
func.request_save(true)
-----------------------------------------------------------------------------------------------
minetest.log("action", "[" .. mname .. "] Version " .. fishing.version .. " loaded.")
-----------------------------------------------------------------------------------------------