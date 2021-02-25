local path = minetest.get_modpath("mobs_animal") .. "/"

mobs.intllib = minetest.get_translator("mobs_animal")

-- Animals

dofile(path .. "chicken.lua") -- JKmurray
dofile(path .. "cow.lua") -- KrupnoPavel
dofile(path .. "rat.lua") -- PilzAdam
dofile(path .. "sheep.lua") -- PilzAdam
dofile(path .. "warthog.lua") -- KrupnoPavel
dofile(path .. "bee.lua") -- KrupnoPavel
dofile(path .. "bunny.lua") -- ExeterDad
dofile(path .. "kitten.lua") -- Jordach/BFD
dofile(path .. "penguin.lua") -- D00Med
dofile(path .. "panda.lua") -- AspireMint

print("[MOD] Mobs Redo Animals loaded")