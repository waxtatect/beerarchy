--[[
painting - in-game painting for minetest

THIS MOD CODE AND TEXTURES ARE LICENSED
			  <3 TO YOU <3
	  UNDER TERMS OF WTFPL LICENSE

2012, 2013, 2014 obneq aka jin xi

picture is drawn using a nodebox to draw the canvas
and an entity which has the painting as its texture.
this texture is created by minetests internal image
compositing engine (see tile.cpp).]]

painting = {}

local canvases = {}

painting.register_canvas = function(self, name, size)
	canvases[name] = size
end

dofile(minetest.get_modpath("painting") .. "/crafts.lua")

minetest.register_alias("canvas", "painting:canvas_16")

local colors = {}
local hexcols = {
	black = "000000",
	blue = "000cff",
	brown = "964b00",
	cyan = "00ffea",
	dark_green = "006400",
	dark_grey = "7b7b7b",
	green = "0cff00",
	grey = "bebebe",
	magenta = "fc00ff",
	orange = "ff6c00",
	pink = "ffc0cb",
	red = "ff0000",
	violet = "8a00ff",
	white = "ffffff",
	yellow = "fff000"
}
local revcolors = {
	"white", "dark_green", "grey", "red", "brown", "cyan", "orange", "violet",
	"dark_grey", "pink", "green", "magenta", "yellow", "black", "blue"
}

painting.get_hexcols = function(self)
	return hexcols
end

painting.get_revcolors = function(self)
	return revcolors
end

for i, color in ipairs(revcolors) do
	colors[color] = i
end

local thickness = 0.1

local function to_imagestring(data, res)
	if not data or not res then
		minetest.log("error", "[painting] missing data or res")
		return
	end
	local cols = {}
	for x = 0, res - 1 do
		local xs = data[x]
		for y = 0, res - 1 do
			local col = revcolors[xs[y]]
			cols[col] = cols[col] or {}
			cols[col][#cols[col] + 1] = {x, y}
		end
	end
	local t, n = {}, 1
	local groupopen = "([combine:"..res.."x"..res
	for colour, ps in pairs(cols) do
		t[n] = groupopen
		n = n + 1
		for _, p in pairs(ps) do
			local x, y = unpack(p)
			t[n] = ":"..p[1]..","..p[2].."=painting_white.png"
			n = n + 1
		end
		t[n] = "^[colorize:#"..hexcols[colour]..")^"
		n = n + 1
	end
	n = n - 1
	if n == 0 then
		minetest.log("error", "[painting] no texels")
		return "painting_white.png"
	end
	t[n] = t[n]:sub(1, -2)
	return table.concat(t)
end


-- ## picture

-- picture node
local picbox = {
	type = "fixed",
	fixed = {-0.499, -0.499, 0.499, 0.499, 0.499, 0.499 - thickness}
}

minetest.register_node("painting:pic", {
	description = "Picture",
	tiles = {"painting_white.png"},
	inventory_image = "painting_painted.png",
	drawtype = "nodebox",
	sunlight_propagates = true,
	paramtype = "light",
	paramtype2 = "facedir",
	node_box = picbox,
	selection_box = picbox,
	groups = {snappy = 2, choppy = 2, oddly_breakable_by_hand = 2, flammable = 2,
		not_in_creative_inventory = 1},
	on_rotate = false,
	-- handle that right below, don't drop anything
	drop = "",
	on_place = function(itemstack, placer, pointed_thing) return itemstack end,
	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		-- find and remove the entity
		for _, e in pairs(minetest.get_objects_inside_radius(pos, 0.4)) do
			e = e:get_luaentity()

			if e and e.name == "painting:picent" then
				e.object:remove()
			end
		end

		if not oldmetadata.fields["painting:picturedata"] then
			return
		end

		local inv = digger:get_inventory()
		local item = {
			name = "painting:paintedcanvas",
			count = 1,
			metadata = oldmetadata.fields["painting:picturedata"]
		}

		if inv and inv:room_for_item("main", "painting:paintedcanvas") then
			-- put picture data back into inventory as item
			inv:add_item("main", item)
		else
			-- drop picture as item
			minetest.add_item(pos, item)
		end
	end,
	-- copy pictures
	on_punch = function(pos, node, player, pointed_thing)
		local meta = minetest.get_meta(pos)

		if not meta then
			return
		end

		-- compare resolutions of picture and canvas the player wields
		-- if it isn't the same don't copy
		local wielded = player:get_wielded_item():get_name()

		local res = canvases[wielded]

		if not res then
			return
		end

		local picturedata = meta:get_string("painting:picturedata")
		local data = minetest.deserialize(picturedata)

		if not data or not data.res then
			return
		end

		if res ~= data.res then
			minetest.chat_send_player(player:get_player_name(), "This isn't the same canvas type!")
			return
		end

		local inv = player:get_inventory()

		-- remove canvas, add picture
		inv:remove_item("main", {name = wielded, count = 1})
		inv:add_item("main", {
			name = "painting:paintedcanvas", count = 1, metadata = picturedata
		})
	end
})

-- picture texture entity
minetest.register_entity("painting:picent", {
	collisionbox = {0, 0, 0, 0, 0, 0},
	visual = "upright_sprite",
	textures = {"painting_white.png"},
	on_activate = function(self, staticdata)
		local pos = self.object:get_pos()
		local meta = minetest.get_meta(pos)
		local data = meta:get_string("painting:picturedata")

		data = minetest.deserialize(data)

		if not data or not data.grid or not data.res then
			return
		end

		self.object:set_properties({textures = {to_imagestring(data.grid, data.res)}})
	end
})

local dirs = {
	[0] = {x = 0, z = 1},
	[1] = {x = 1, z = 0},
	[2] = {x = 0, z =-1},
	[3] = {x =-1, z = 0}
}


-- ## painting entity

local function dot(v, w)
	return v.x * w.x + v.y * w.y + v.z * w.z
end

local function intersect(pos, dir, origin, normal)
	local t = -(dot(vector.subtract(pos, origin), normal)) / dot(dir, normal)

	return vector.add(pos, vector.multiply(dir, t))
end

local function clamp(num, res)
	if num < 0 then
		return 0
	end

	return math.min(num, res - 1)
end

-- taken from vector_extras to save dependency
local twolines = {}

local twoline = function(x, y)
	local pstr = x.." "..y
	local line = twolines[pstr]

	if line then
		return line
	end

	line = {}

	local n = 1
	local dirx = 1

	if x < 0 then
		dirx = -dirx
	end

	local ymin, ymax = 0, y

	if y < 0 then
		ymin, ymax = ymax, ymin
	end

	local m = y / x -- y/0 works too
	local dir = 1

	if m < 0 then
		dir = -dir
	end

	for i = 0, x, dirx do
		local p1 = math.max(math.min(math.floor((i - 0.5) * m + 0.5), ymax), ymin)
		local p2 = math.max(math.min(math.floor((i + 0.5) * m + 0.5), ymax), ymin)

		for j = p1, p2, dir do
			line[n] = {i, j}

			n = n + 1
		end
	end

	twolines[pstr] = line

	return line
end

local paintbox = {
	[0] = {-0.5,-0.5,0,0.5,0.5,0},
	[1] = {0,-0.5,-0.5,0,0.5,0.5}
}

-- painting as being painted
minetest.register_entity("painting:paintent", {
	collisionbox = {0, 0, 0, 0, 0, 0},
	visual = "upright_sprite",
	textures = {"painting_white.png"},
	on_punch = function(self, puncher)
		local wielded = puncher:get_wielded_item()
		-- check for brush
		local name = wielded:get_name():sub(#"painting:brush_" + 1)

		if not colors[name] then
			return
		end

		--[[get player eye level
		it does not include the client-side offset,
		e.g. bobbing (see view_bobbing_amount)]]
		local ppos = vector.add(puncher:get_pos(), puncher:get_eye_offset())
		ppos.y = ppos.y + puncher:get_properties().eye_height

		local pos = self.object:get_pos()
		local l = puncher:get_look_dir()

		local d = dirs[self.fd]
		local od = dirs[(self.fd + 1) % 4]
		local normal = {x = d.x, y = 0, z = d.z}
		local p = intersect(ppos, l, pos, normal)
		local off = -0.5

		pos = vector.add(pos, {x = off * od.x, y = off, z = off * od.z})
		p = vector.subtract(p, pos)

		-- where it hits the canvas, in fraction given position and direction
		local x, y = math.abs(p.x + p.z), 1 - p.y
		x, y = math.floor(x * self.res), math.floor(y * self.res)
		x, y = clamp(x, self.res), clamp(y, self.res)

		local x0 = self.x0

		if puncher:get_player_control().sneak and x0 then
			local y0 = self.y0
			local line = twoline(x0 - x, y0 - y)

			for _, coord in pairs(line) do
				self.grid[x + coord[1]][y + coord[2]] = colors[name]
			end
		else
			self.grid[x][y] = colors[name]
		end

		self.x0, self.y0 = x, y

		self.object:set_properties({textures = {to_imagestring(self.grid, self.res)}})

		wielded:add_wear(65535 / 256)
		puncher:set_wielded_item(wielded)
	end,
	on_activate = function(self, staticdata)
		local data = minetest.deserialize(staticdata)

		if not data or not data.fd then
			return
		end

		self.fd = data.fd
		self.x0 = data.x0
		self.y0 = data.y0
		self.grid = data.grid
		self.res = data.res

		self.object:set_properties({
			collisionbox = paintbox[self.fd % 2],
			textures = {to_imagestring(self.grid, self.res)}
		})
		self.object:set_armor_groups({immortal = 1})
	end,
	get_staticdata = function(self)
		return minetest.serialize{
			fd = self.fd, x0 = self.x0, y0 = self.y0, grid = self.grid, res = self.res
		}
	end
})


-- ## canvases

-- canvas for drawing
local canvasbox = {
	type = "fixed",
	fixed = {-0.5, -0.5, 0, 0.5, 0.5, thickness}
}

minetest.register_node("painting:canvasnode", {
	description = "Canvas",
	tiles = {"painting_white.png"},
	inventory_image = "painting_painted.png",
	drawtype = "nodebox",
	sunlight_propagates = true,
	paramtype = "light",
	paramtype2 = "facedir",
	node_box = canvasbox,
	selection_box = canvasbox,
	groups = {snappy = 2, choppy = 2, oddly_breakable_by_hand = 2, flammable = 2,
		not_in_creative_inventory = 1},
	on_rotate = false,
	drop = "",
	on_place = function(itemstack, placer, pointed_thing) return itemstack end,
	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		-- get data and remove pixels
		local data = {}

		for _, e in pairs(minetest.get_objects_inside_radius(pos, 0.1)) do
			e = e:get_luaentity()

			if e and e.name == "painting:paintent" and e.grid and e.res then
				data.grid = e.grid
				data.res = e.res
				e.object:remove()
			end
		end

		if data.grid then
			pos.y = pos.y - 1

			minetest.get_meta(pos):set_int("has_canvas", 0)

			local inv = digger:get_inventory()
			local item = {
				name = "painting:paintedcanvas",
				count = 1,
				metadata = minetest.serialize(data)
			}

			if inv and inv:room_for_item("main", "painting:paintedcanvas") then
				digger:get_inventory():add_item("main", item)
			else
				minetest.add_item(pos, item)
			end
		end
	end
})

-- just pure magic
local walltoface = {-1, -1, 1, 3, 0, 2}

-- paintedcanvas picture inventory item
minetest.register_craftitem("painting:paintedcanvas", {
	description = "Painted canvas",
	inventory_image = "painting_painted.png",
	stack_max = 1,
	groups = {snappy = 2, choppy = 2, oddly_breakable_by_hand = 2, flammable = 2,
		not_in_creative_inventory = 1},
	on_place = function(itemstack, placer, pointed_thing)
		local under = pointed_thing.under

		local node = minetest.get_node(under)
		local def = minetest.registered_nodes[node.name]

		if def and def.on_rightclick and not (placer and placer:is_player() and
			placer:get_player_control().sneak)
		then
			return def.on_rightclick(under, node, placer, itemstack, pointed_thing) or
				itemstack
		end

		local pos = pointed_thing.above

		node = minetest.get_node(pos)
		def = minetest.registered_nodes[node.name]

		if not def or not def.buildable_to then
			return itemstack
		end

		if minetest.is_protected(pos, placer:get_player_name()) then
			return itemstack
		end

		local wm = minetest.dir_to_wallmounted(vector.subtract(under, pos))

		local fd = walltoface[wm + 1]

		if fd == -1 then
			return itemstack
		end

		local picturedata = itemstack:get_meta():get_string("")
		local data = minetest.deserialize(picturedata)

		if not data or not data.grid or not data.res then
			return itemstack
		end

		minetest.add_node(pos, {name = "painting:pic", param2 = fd})

		minetest.get_meta(pos):set_string("painting:picturedata", picturedata)

		-- add entity
		local dir = dirs[fd]
		local off = 0.5 - thickness - 0.01

		pos.x = pos.x + dir.x * off
		pos.z = pos.z + dir.z * off

		local p = minetest.add_entity(pos, "painting:picent"):get_luaentity()

		p.object:set_properties({textures = {to_imagestring(data.grid, data.res)}})
		p.object:set_yaw(math.pi * fd / -2)

		return ItemStack("")
	end
})

-- canvas inventory items
for i = 4, 6 do
	minetest.register_craftitem("painting:canvas_" .. 2 ^ i, {
		description = "Canvas " .. 2 ^ i,
		inventory_image = "default_paper.png",
		stack_max = 99
	})
end


-- ## brushes

local function table_copy(t)
	local t2 = {}

	for k, v in pairs(t) do
		t2[k] = v
	end

	return t2
end

local brush = {
	wield_image = "",
	tool_capabilities = {
		full_punch_interval = 1.0,
		max_drop_level = 0,
		groupcaps = {}
	}
}

for color, _ in pairs(hexcols) do
	local brush_new = table_copy(brush)
	local description = color:gsub("^%l", string.upper)
		:gsub("_(%l)", function(a) return " " .. (a):upper() end) .. " brush"

	brush_new.description = description
	brush_new.inventory_image = "painting_brush_stem.png^(painting_brush_head.png^[colorize:#" ..
		hexcols[color]..":255)^painting_brush_head.png"

	minetest.register_tool("painting:brush_" .. color, brush_new)

	minetest.register_craft({
		output = "painting:brush_" .. color,
		recipe = {
			{"dye:" .. color},
			{"default:stick"},
			{"default:stick"}
		}
	})
end


-- ## easel

local function initgrid(res)
	local grid, a, x, y = {}, res - 1, nil

	for x = 0, a do
		grid[x] = {}

		for y = 0, a do
			grid[x][y] = colors["white"]
		end
	end

	return grid
end

local easelbox = {
	type = "fixed",
	fixed = {
		-- feet
		{-0.4, -0.5, -0.5, -0.3, -0.4, 0.5},
		{ 0.3, -0.5, -0.5, 0.4, -0.4, 0.5},
		-- legs
		{-0.4, -0.4, 0.1, -0.3, 1.5, 0.2},
		{ 0.3, -0.4, 0.1, 0.4, 1.5, 0.2},
		-- shelf
		{-0.5, 0.35, -0.3, 0.5, 0.45, 0.1}
	}
}

minetest.register_node("painting:easel", {
	description = "Easel",
	tiles = {"default_wood.png"},
	drawtype = "nodebox",
	sunlight_propagates = true,
	paramtype = "light",
	paramtype2 = "facedir",
	node_box = easelbox,
	selection_box = easelbox,
	groups = {snappy = 2, choppy = 2, oddly_breakable_by_hand = 2, flammable = 1},
	on_punch = function(pos, node, player)
		local wielded = player:get_wielded_item()
		local name = wielded:get_name()

		local res = canvases[name]

		if not res and name ~= "painting:paintedcanvas" then
			return
		end

		local picturedata, data = wielded:get_meta():get_string(""), nil

		if name == "painting:paintedcanvas" then
			data = minetest.deserialize(picturedata)

			if not data or not data.grid or not data.res then
				return
			end
		end

		local fd = node.param2
		local dir = dirs[fd]

		if not dir then
			return
		end

		pos.y = pos.y + 1

		if minetest.get_node(pos).name ~= "air" then
			return
		end

		minetest.add_node(pos, {name = "painting:canvasnode", param2 = fd})

		pos.x = pos.x - 0.01 * dir.x
		pos.z = pos.z - 0.01 * dir.z

		local meta = minetest.get_meta(pos)

		local p = minetest.add_entity(pos, "painting:paintent"):get_luaentity()

		if name == "painting:paintedcanvas" then
			meta:set_string("painting:picturedata", picturedata)
			p.object:set_properties({
				collisionbox = paintbox[fd % 2],
				textures = {to_imagestring(data.grid, data.res)}
			})
			p.grid = data.grid
			p.res = data.res
		else
			p.object:set_properties({collisionbox = paintbox[fd % 2]})
			p.grid = initgrid(res)
			p.res = res
		end
		p.object:set_armor_groups({immortal = 1})
		p.object:set_yaw(math.pi * fd / -2)
		p.fd = fd

		meta:set_int("has_canvas", 1)

		wielded:set_count(wielded:get_count() - 1)
		player:set_wielded_item(wielded)
	end,
	can_dig = function(pos)
		return minetest.get_meta(pos):get_int("has_canvas") == 0
	end
})

minetest.register_alias("easel", "painting:easel")