
-- decoration function
local function register_plant(name, min, max, placeon, spawnby, num, enabled)

	if enabled ~= true then
		return
	end

	minetest.register_decoration({
		deco_type = "simple",
		place_on = placeon,
		sidelen = 16,
		noise_params = {
			offset = -0.0059,
			scale = 0.006,
			spread = {x = 100, y = 100, z = 100},
--			seed = math.random(0, 1000000000),
			seed = 329,
			octaves = 3,
			persist = 0.6
		},
		y_min = min,
		y_max = max,
		decoration = "farming:" .. name,
		spawn_by = spawnby,
		num_spawn_by = num,
	})
end


-- add crops to mapgen
register_plant("potato_3", 0, 1500, {"default:dirt_with_grass"}, "", -1, farming.potato)
register_plant("tomato_7", 0, 1000, {"default:dirt_with_grass"}, "", -1, farming.tomato)
register_plant("corn_7", 0, 1000, {"default:dirt_with_grass"}, "", -1, farming.corn)
register_plant("coffee_5", 1001, 5000, {"default:dirt_with_grass"}, "", -1, farming.coffee)
register_plant("raspberry_4", 0, 1000, {"default:dirt_with_grass"}, "", -1, farming.raspberry)
register_plant("rhubarb_3", 0, 5000, {"default:dirt_with_grass"}, "", -1, farming.rhubarb)
register_plant("blueberry_4", 0, 2000, {"default:dirt_with_grass"}, "group:water", 1, farming.blueberry)
register_plant("beanbush", 0, 1000, {"default:dirt_with_grass"}, "", -1, farming.beans)
register_plant("grapebush", 0, 1000, {"default:dirt_with_grass"}, "", -1, farming.grapes)
register_plant("carrot_8", 0, 3000, {"default:dirt_with_grass"}, "", -1, farming.carrot)
register_plant("cucumber_4", 0, 1000, {"default:dirt_with_grass"}, "", -1, farming.cucumber)
register_plant("melon_8", 0, 200, {"default:dirt_with_grass"}, "group:water", 1, farming.melon)
register_plant("pumpkin_8", 0, 500, {"default:dirt_with_grass"}, "", -1, farming.pumpkin)
register_plant("hemp_7", 0, 5000, {"default:dirt_with_rainforest_litter"}, "", -1, farming.hemp)

--[[if minetest.get_mapgen_params().mgname == "v6" then

	register_plant("carrot_8", 1, 30, "group:water", 1, farming.carrot)
	register_plant("cucumber_4", 1, 20, "group:water", 1, farming.cucumber)
	register_plant("melon_8", 1, 20, "group:water", 1, farming.melon)
	register_plant("pumpkin_8", 1, 20, "group:water", 1, farming.pumpkin)
else
	-- v7 maps have a beach so plants growing near water is limited to 6 high
	register_plant("carrot_8", 1, 6, "", -1, farming.carrot)
	register_plant("cucumber_4", 1, 6, "", -1, farming.cucumber)
	register_plant("melon_8", 1, 6, "", -1, farming.melon)
	register_plant("pumpkin_8", 1, 6, "", -1, farming.pumpkin)
end

if farming.hemp then
minetest.register_decoration({
	deco_type = "simple",
	place_on = {"default:dirt_with_grass", "default:dirt_with_rainforest_litter"},
	sidelen = 16,
	noise_params = {
		offset = 0,
		scale = 0.06,
		spread = {x = 100, y = 100, z = 100},
		seed = 420,
		octaves = 3,
		persist = 0.6
	},
	y_min = 5,
	y_max = 35,
	decoration = "farming:hemp_7",
	spawn_by = "group:tree",
	num_spawn_by = 1,
})
end
]]--
