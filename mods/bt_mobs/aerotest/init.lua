aerotest = {}

aerotest.abo = tonumber(minetest.settings:get('active_object_send_range_blocks')) or 3
aerotest.abr = tonumber(minetest.settings:get('active_block_range')) or 2
aerotest.radar_debug = minetest.settings:get_bool("aerotest_radar_debug", false)
aerotest.bsod = tonumber(minetest.settings:get('block_send_optimize_distance')) or aerotest.abo
aerotest.mbsd = tonumber(minetest.settings:get('max_block_send_distance')) or aerotest.abo
aerotest.aosr = aerotest.abo * 16
aerotest.abr = aerotest.abr * 16

if aerotest.bsod and aerotest.bsod < aerotest.aosr / 16 then
	aerotest.aosr = aerotest.bsod * 16
elseif aerotest.mbsd and aerotest.mbsd < aerotest.aosr / 16 then
	aerotest.aosr = aerotest.mbsd * 16
end

aerotest.hunter = true			   -- false to turn off hunting of prey
aerotest.hunt_intervall = 90	   -- hunting interval in seconds (only checking no prey, no hunt)
aerotest.eagleminheight = 60	   -- eagles start spawning when player is higher than this
aerotest.maxeagle = 2 			   -- max possible eagles at one time in aerotest.aosr
aerotest.spawnchance = 10 		   -- spawnchance in percent
aerotest.spawncheck_frequence = 60 -- each how many seconds is checked for an eagle to spawn

if minetest.get_modpath("rcbows") or minetest.get_modpath("throwing") then
	aerotest.arrows = true
end

math.randomseed(os.time()) -- init random seed

-- Pseudo random generator, init and call function
local randomtable = PcgRandom(math.random(2^23) + 1)

function aerotest.random(min, max)
	if not min and not max then return math.abs(randomtable:next() / 2^31) end
	if not max then
		max = min
		min = 1
	end
	if max and not min then min = 1 end
	return randomtable:next(min, max)
end

local path = minetest.get_modpath("aerotest") .. "/"

dofile(path .. "behavior_and_helpers.lua")
dofile(path .. "chatcommand.lua")
dofile(path .. "entity.lua")
dofile(path .. "spawn.lua")

--
-- Preys registration
--

if minetest.get_modpath("mobs_monster") then
	aerotest.register_prey("mobs_monster:dirt_monster")
	aerotest.register_prey("mobs_monster:sand_monster")
	aerotest.register_prey("mobs_monster:spider")
	aerotest.register_prey("mobs_monster:stone_monster")
end
--[[
if minetest.get_modpath("petz") then
	aerotest.register_prey("petz:kitty")
	aerotest.register_prey("petz:puppy")
	aerotest.register_prey("petz:ducky")
	aerotest.register_prey("petz:lamb")
	aerotest.register_prey("petz:goat")
	aerotest.register_prey("petz:calf")
	aerotest.register_prey("petz:chicken")
	aerotest.register_prey("petz:piggy")
	aerotest.register_prey("petz:pigeon")
	aerotest.register_prey("petz:hamster")
	aerotest.register_prey("petz:chimp")
	aerotest.register_prey("petz:beaver")
	aerotest.register_prey("petz:turtle")
	aerotest.register_prey("petz:frog")
	aerotest.register_prey("petz:penguin")
end

if minetest.get_modpath("water_life") then
	-- aerotest.register_prey("water_life:fish") -- no hunting of watermobs sofar
	-- aerotest.register_prey("water_life:fish_tamed")
	aerotest.register_prey("water_life:snake")
	aerotest.register_prey("water_life:beaver")
	aerotest.register_prey("water_life:gecko")
end

if minetest.get_modpath("wildlife") then
	aerotest.register_prey("wildlife:deer")
	aerotest.register_prey("wildlife:deer_tamed")
end
--]]