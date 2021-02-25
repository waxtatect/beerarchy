vines = {
	name = 'vines',
	translator = minetest.get_translator("vines"),
	recipes = {}
}

local MP = minetest.get_modpath(vines.name) .. "/"

dofile(MP .. "aliases.lua")
dofile(MP .. "crafts.lua")
dofile(MP .. "functions.lua")
dofile(MP .. "nodes.lua")
dofile(MP .. "vines.lua")
dofile(MP .. "shear.lua")

print("[Vines] Loaded!")