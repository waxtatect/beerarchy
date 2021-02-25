function integral.clone_node(name)
	local node = minetest.registered_nodes[name]
	local node2 = integral.table_copy(node)
	return node2
end

minetest.register_node("integral:integral_bark", {
	description = "Integral Bark",
	tiles = {"default_tree.png"},
	is_ground_content = false,
	groups = {tree = 1, choppy = 2, oddly_breakable_by_hand = 1, integral = 1},
	sounds = default.node_sound_wood_defaults()
})

minetest.register_node("integral:integral_wood", {
	description = "Integral Wood",
	tiles = {"integral_integral_wood.png"},
	is_ground_content = false,
	groups = {tree = 1, choppy = 2, flammable = 3, integral = 1},
	sounds = default.node_sound_wood_defaults()
})

minetest.register_node("integral:integral_ironwood", {
	description = "Integral Ironwood",
	tiles = {"integral_integral_wood.png^[colorize:#B7410E:80"},
	is_ground_content = false,
	groups = {tree = 1, choppy = 2, level=1, integral = 1},
	sounds = default.node_sound_wood_defaults()
})

minetest.register_node("integral:integral_diamondwood", {
	description = "Integral Diamondwood",
	tiles = {"integral_integral_wood.png^[colorize:#5D8AA8:80"},
	is_ground_content = false,
	groups = {tree = 1, choppy = 2, level=2, integral = 1},
	sounds = default.node_sound_wood_defaults()
})

minetest.register_node("integral:petrified_wood", {
	description = "Petrified Wood",
	tiles = {"ores_petrified_wood.png"},
	groups = {cracky = 3, stone = 1},
	sounds = default.node_sound_stone_defaults()
})

minetest.register_node("integral:petrified_integrite", {
	description = "Petrified Integrite",
	drawtype = "mesh",
	mesh = "integral_spider.x",
	visual_scale = 0.2,
	tiles = {"mobs_spider.png"},
	paramtype = "light",
	is_ground_content = false,
	groups = {cracky = 3},
	sounds = default.node_sound_stone_defaults()
})

minetest.register_node("integral:petrified_bee", {
	description = "Petrified Bee",
	drawtype = "mesh",
	mesh = "mobs_bee.x",
	visual_scale = 0.1,
	tiles = {"mobs_bee.png"},
	paramtype = "light",
	is_ground_content = false,
	groups = {cracky = 3},
	sounds = default.node_sound_stone_defaults()
})

minetest.register_node("integral:petrified_cow", {
	description = "Petrified Cow",
	drawtype = "mesh",
	mesh = "mobs_cow.x",
	visual_scale = 0.3,
	tiles = {"mobs_cow.png"},
	paramtype = "light",
	is_ground_content = false,
	groups = {cracky = 3},
	sounds = default.node_sound_stone_defaults()
})

minetest.register_node("integral:petrified_kitten", {
	description = "Petrified Kitten",
	drawtype = "mesh",
	mesh = "mobs_kitten.b3d",
	visual_scale = 0.1,
	tiles = {"mobs_kitten_striped.png"},
	paramtype = "light",
	is_ground_content = false,
	groups = {cracky = 3},
	sounds = default.node_sound_stone_defaults()
})

minetest.register_node("integral:petrified_sheep", {
	description = "Petrified Sheep",
	drawtype = "mesh",
	mesh = "mobs_sheep.b3d",
	visual_scale = 0.1,
	tiles = {"mobs_sheep_base.png"},
	paramtype = "light",
	is_ground_content = false,
	groups = {cracky = 3},
	sounds = default.node_sound_stone_defaults()
})

minetest.register_node("integral:amber", {
	description = "Amber",
	drawtype = "glasslike",
	paramtype = "light",
	sunlight_propagates = true,
	tiles = {"integral_amber.png"},
	inventory_image = minetest.inventorycube("integral_amber.png"),
	light_source = 1,
	use_texture_alpha = "blend",
	is_ground_content = false,
	groups = {cracky = 3, level=2},
	sounds = default.node_sound_stone_defaults()
})

minetest.register_node("integral:syrup", {
	description = "Integral Syrup",
	drawtype = "plantlike",
	tiles = {"integral_syrup.png"},
	inventory_image  = "integral_syrup.png",
	paramtype = "light",
	walkable = false,
	selection_box = {
		type = "fixed",
		fixed = {-0.25, -0.5, -0.25, 0.25, 0.25, 0.25}
	},
	groups = {vessel = 1, dig_immediate = 3, attached_node = 1},
	on_use = minetest.item_eat(2, "vessels:glass_bottle"),
	sounds = default.node_sound_glass_defaults()
})

if not basic_machines then
	minetest.register_craftitem("integral:charcoal", {
		description = "Charcoal Briquette",
		inventory_image = "default_coal_lump.png",
		groups = {coal = 1}
	})

	minetest.register_craft({
		type = "fuel",
		recipe = "integral:charcoal",
		burntime = 50
	})
end

minetest.register_craft({
	type = "cooking",
	output = "default:sand",
	recipe = "integral:integral_bark"
})

minetest.register_craft({
	type = "cooking",
	output = "default:iron_lump",
	recipe = "integral:integral_ironwood"
})

minetest.register_craft({
	type = "cooking",
	output = "default:diamond",
	recipe = "integral:integral_diamondwood"
})

if not basic_machines then
	minetest.register_craft({
		type = "cooking",
		output = "integral:charcoal",
		recipe = "group:tree"
	})

	minetest.register_craft({
		output = 'default:torch 4',
		recipe = {
			{'integral:charcoal'},
			{'group:stick'}
		}
	})
end

minetest.register_craft({
	output = 'integral:syrup',
	type = "shapeless",
	recipe = {
		'vessels:glass_bottle',
		'integral:bucket_sap'
	},
	replacements = {{'integral:bucket_sap', 'bucket:bucket_empty'},}
})

minetest.register_craft( {
	output = "vessels:glass_bottle 10",
	recipe = {
		{"integral:amber", "", "integral:amber"},
		{"integral:amber", "", "integral:amber"},
		{"", "integral:amber", ""}
	}
})

minetest.register_node("integral:weightless_water", {
	description = "Weightless Water",
	inventory_image = minetest.inventorycube("default_water.png"),
	drawtype = "liquid",
	tiles = {
		{
			name = "default_water_source_animated.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 2.0
			}
		},
		{
			name = "default_water_source_animated.png",
			backface_culling = true,
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 2.0
			}
		}
	},
	use_texture_alpha = "blend", -- alpha = 160,
	paramtype = "light",
	walkable = false,
	pointable = false,
	diggable = false,
	buildable_to = true,
	is_ground_content = false,
	drop = "",
	drowning = 1,
	liquidtype = "source",
	liquid_alternative_flowing = "integral:weightless_water",
	liquid_alternative_source = "integral:weightless_water",
	liquid_viscosity = 1,
	liquid_range = 0,
	post_effect_color = {a = 120, r = 30, g = 60, b = 90},
	groups = {water = 3, liquid = 3, cools_lava = 1}
})

minetest.register_node("integral:sap", {
	description = "Sap",
	inventory_image = minetest.inventorycube("default_water.png^[colorize:#FF7E00:B0"),
	drawtype = "liquid",
	tiles = {
		{
			name = "integral_sap_source_animated.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 2.0
			}
		},
		{
			name = "integral_sap_source_animated.png",
			backface_culling = true,
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 2.0
			}
		}
	},
	use_texture_alpha = "blend", -- alpha = 160,
	paramtype = "light",
	walkable = false,
	pointable = false,
	diggable = false,
	buildable_to = true,
	is_ground_content = false,
	drop = "",
	drowning = 1,
	liquidtype = "source",
	liquid_alternative_flowing = "integral:sap",
	liquid_alternative_source = "integral:sap",
	liquid_viscosity = 15,
	liquid_range = 0,
	post_effect_color = {a = 120, r = 255, g = 191, b = 0},
	groups = {liquid = 3}
})

bucket.register_liquid(
	"integral:weightless_water",
	"integral:weightless_water",
	"integral:bucket_water",
	"bucket_water.png",
	"Weightless Water Bucket",
	{tool = 1, water_bucket = 1}
)

bucket.register_liquid(
	"integral:sap",
	"integral:sap",
	"integral:bucket_sap",
	"bucket_sap.png",
	"Bucket of Sap",
	{tool = 1}
)

integral.last_teleport = {}
local function teleport(pos, node, puncher, pointed_thing)
	if puncher and puncher:is_player() then
		local name = puncher:get_player_name()
		local v = vector.subtract(pos, pointed_thing.above)
		local v2 = integral.table_copy(pos)

		local m = math.max(math.abs(v.x), math.abs(v.y), math.abs(v.z))
		if math.abs(v.x) == m then
			if v.x > 0 then
				v2.x = v2.x + 1000
			else
				v2.x = v2.x - 1000
			end
		elseif math.abs(v.z) == m then
			if v.z > 0 then
				v2.z = v2.z + 1000
			else
				v2.z = v2.z - 1000
			end
		end

		if pos.y < 100 then
			local n = integral.get_ground_root_number(pos.x, pos.y, pos.z)
			if math.abs(v.y) == m then
				v2 = integral.get_tree_root_coords(v2.x, v2.y, v2.z, n)
			else
				v2 = integral.get_ground_root_coords(v2.x, v2.y, v2.z, n)
			end
		else
			local n = integral.get_tree_root_number(pos.x, pos.y, pos.z)
			if math.abs(v.y) == m then
				v2 = integral.get_ground_root_coords(v2.x, v2.y, v2.z, n)
			else
				v2 = integral.get_tree_root_coords(v2.x, v2.y, v2.z, n)
			end
		end

		local t = os.clock()
		if (not integral.last_teleport[name]) or t - integral.last_teleport[name] > 1 then
			integral.last_teleport[name] = t
			puncher:set_pos(v2)
		end
	end
end

minetest.register_node("integral:integral_root", {
	description = "Integral Root",
	tiles = {"integral_integral_wood.png^[colorize:#000000:80"},
	is_ground_content = false,
	groups = {tree = 1, level = 4},
	on_punch = teleport
})


-- Make some new leaves with the same properties.
local newnode = integral.clone_node("default:leaves")
newnode.description = "Integral Leaves"
newnode.tiles = {"default_leaves.png^[noalpha"}
newnode.groups.leafdecay = 0
newnode.drop = nil
minetest.register_node("integral:leaves1", newnode)
newnode.description = "Integral Leaves"
newnode.tiles = {"default_leaves.png^[colorize:#FF0000:15^[noalpha"}
newnode.groups.leafdecay = 0
newnode.drop = nil
minetest.register_node("integral:leaves2", newnode)
newnode.description = "Integral Leaves"
newnode.tiles = {"default_leaves.png^[colorize:#FFFF00:15^[noalpha"}
newnode.groups.leafdecay = 0
newnode.drop = nil
minetest.register_node("integral:leaves3", newnode)
newnode.description = "Integral Leaves"
newnode.tiles = {"default_leaves.png^[colorize:#00FFFF:15^[noalpha"}
newnode.groups.leafdecay = 0
newnode.drop = nil
minetest.register_node("integral:leaves4", newnode)
newnode.description = "Integral Leaves"
newnode.tiles = {"default_leaves.png^[colorize:#00FF00:15^[noalpha"}
minetest.register_node("integral:leaves5", newnode)
newnode.groups.leafdecay = 0
newnode.drop = nil


minetest.register_craft({
	output = 'default:wood 4',
	recipe = {{'integral:integral_wood'}}
})

do
	local r = {name="integral:integral_root", param1=255, force_place = true}
	local a = {name="air", param1=255, force_place = true}
	local o = {name="air", param1=0}

	integral.integral_root_schematic = {
		size = {x = 5, y = 4, z = 5},
		data = {
				o, o, o, o, o,
				o, o, r, o, o,
				o, o, r, o, o,
				o, o, o, o, o,
				o, o, r, o, o,
				o, o, a, o, o,
				o, o, a, o, o,
				o, o, r, o, o,
				o, r, r, r, o,
				r, a, a, a, r,
				r, a, a, a, r,
				o, r, r, r, o,
				o, o, r, o, o,
				o, o, a, o, o,
				o, o, a, o, o,
				o, o, r, o, o,
				o, o, o, o, o,
				o, o, r, o, o,
				o, o, r, o, o,
				o, o, o, o, o
		}
	}
end

-- Glowing fungal wood provides an eerie light.
minetest.register_node("integral:glowing_fungal_wood", {
	description = "Glowing Fungal Wood",
	tiles = {"integral_integral_wood.png^vmg_glowing_fungal.png",},
	is_ground_content = false,
	drop = {items={ {items={"integral:integral_wood"},}, {items={"integral:glowing_fungus",},},},},
	light_source = 8,
	groups = {tree = 1, choppy = 2, flammable = 2, oddly_breakable_by_hand = 1},
	sounds = default.node_sound_wood_defaults()
})

minetest.register_node("integral:moon_amber", {
	description = "Moon Amber",
	drawtype = "glasslike",
	paramtype = "light",
	sunlight_propagates = true,
	tiles = {"integral_amber.png"},
	inventory_image = minetest.inventorycube("integral_amber.png"),
	use_texture_alpha = "blend",
	is_ground_content = false,
	light_source = default.LIGHT_MAX,
	groups = {cracky = 3, level=2},
	sounds = default.node_sound_stone_defaults()
})

minetest.register_craft({
	output = "integral:moon_amber",
	type = "shapeless",
	recipe = {
		"integral:moon_juice",
		"integral:amber"
	}
})

if minetest.global_exists("valc") then
	minetest.register_alias("integral:glowing_fungus", "valleys_c:glowing_fungus")
	minetest.register_alias("integral:moon_juice", "valleys_c:moon_juice")
	minetest.register_alias("integral:moon_glass", "valleys_c:moon_glass")
	minetest.register_alias("integral:glowing_dirt", "valleys_c:glowing_dirt")
	minetest.register_alias("integral:glowing_soil", "valleys_c:glowing_soil")
	minetest.register_alias("integral:glowing_soil_wet", "valleys_c:glowing_soil_wet")
else
	minetest.register_node("integral:glowing_fungus", {
		description = "Glowing Fungus",
		drawtype = "plantlike",
		paramtype = "light",
		tiles = {"vmg_glowing_fungus.png"},
		inventory_image = "vmg_glowing_fungus.png",
		groups = {dig_immediate = 3, attached_node = 1}
	})

	-- The fungus can be made into juice and then into glowing glass.
	minetest.register_node("integral:moon_juice", {
		description = "Moon Juice",
		drawtype = "plantlike",
		paramtype = "light",
		tiles = {"vmg_moon_juice.png"},
		inventory_image = "vmg_moon_juice.png",
		groups = {dig_immediate = 3, attached_node = 1},
		sounds = default.node_sound_glass_defaults()
	})

	minetest.register_node("integral:moon_glass", {
		description = "Moon Glass",
		drawtype = "glasslike",
		tiles = {"default_glass.png",},
		inventory_image = minetest.inventorycube("default_glass.png"),
		is_ground_content = true,
		light_source = default.LIGHT_MAX,
		groups = {cracky=3},
		sounds = default.node_sound_glass_defaults()
	})

	minetest.register_craft({
		output = "integral:moon_juice",
		recipe = {
			{"integral:glowing_fungus", "integral:glowing_fungus", "integral:glowing_fungus"},
			{"integral:glowing_fungus", "integral:glowing_fungus", "integral:glowing_fungus"},
			{"integral:glowing_fungus", "vessels:glass_bottle", "integral:glowing_fungus"}
		}
	})

	minetest.register_craft({
		output = "integral:moon_glass",
		type = "shapeless",
		recipe = {
			"integral:moon_juice",
			"integral:moon_juice",
			"default:glass"
		}
	})

	minetest.register_node("integral:glowing_dirt", {
		description = "Glowing Dirt",
		tiles = {"default_dirt.png"},
		groups = {crumbly = 3, soil = 1},
		light_source = default.LIGHT_MAX,
		sounds = default.node_sound_dirt_defaults(),
		soil = {
			base = "integral:glowing_dirt",
			dry = "integral:glowing_soil",
			wet = "integral:glowing_soil_wet"
		}
	})

	minetest.register_node("integral:glowing_soil", {
		description = "Glowing Soil",
		tiles = {"default_dirt.png^farming_soil.png", "default_dirt.png"},
		drop = "integral:glowing_dirt",
		groups = {crumbly=3, not_in_creative_inventory=1, soil=2, grassland = 1, field = 1},
		sounds = default.node_sound_dirt_defaults(),
		light_source = default.LIGHT_MAX,
		soil = {
			base = "integral:glowing_dirt",
			dry = "integral:glowing_soil",
			wet = "integral:glowing_soil_wet"
		}
	})

	minetest.register_node("integral:glowing_soil_wet", {
		description = "Wet Glowing Soil",
		tiles = {"default_dirt.png^farming_soil_wet.png", "default_dirt.png^farming_soil_wet_side.png"},
		drop = "integral:glowing_dirt",
		groups = {crumbly=3, not_in_creative_inventory=1, soil=3, wet = 1, grassland = 1, field = 1},
		sounds = default.node_sound_dirt_defaults(),
		light_source = default.LIGHT_MAX,
		soil = {
			base = "integral:glowing_dirt",
			dry = "integral:glowing_soil",
			wet = "integral:glowing_soil_wet"
		}
	})

	minetest.register_craft({
		output = "integral:glowing_dirt",
		type = "shapeless",
		recipe = {
			"integral:moon_juice",
			"default:dirt"
		}
	})
end

local neighbors = {"air", "mobs:cobweb"}
local grow_not = {"integral:integral_bark"}
for i = 1, 4 do
	grow_not[#grow_not + 1] = "integral:leaves" .. i
end
minetest.register_abm({
	label = "Integral tree spreading",
	nodenames = {"group:integral"},
	neighbors = neighbors,
	interval = 900,
	chance = 125,
	action = function(pos, node)
		local n1 = minetest.find_node_near(pos, 1, grow_not)
		if not n1 and pos.y > 150 and pos.y < 1650 then
			local n2 = minetest.find_node_near(pos, 10, "integral:integral_bark")
			if not n2 then
				return
			end
			local n = minetest.find_node_near(pos, 1, neighbors)
			local t = {"air"}; table.insert_all(t, grow_not)
			local count = #minetest.find_nodes_in_area(vector.add(n2, 3), vector.subtract(n2, 3), t)
			if math.abs(n.y - n2.y) < 4 and count > 211  then -- 7 * 7 * 7 / 1.618
				local r = math.random(100)
				if r < 2 then
					minetest.set_node(n, {name = "integral:integral_diamondwood"})
				elseif r < 5 then
					minetest.set_node(n, {name = "integral:integral_ironwood"})
				else
					minetest.set_node(n, {name = "integral:integral_wood"})
				end
			end
		end
	end
})