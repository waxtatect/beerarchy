playerOverlayTextures = {}

dofile(minetest.get_modpath("painted_3d_armor") .. "/crafts.lua")

minetest.register_alias("painted_3d_armor:armor_canvas", "painted_3d_armor:armor_canvas_6x6")

local playerOverlays = {}
local playerShields = {}
local playerChestplates = {}

-- Whether to overlay the banner on top of the player skin in case the player does not
-- wear a chest plate. If true, the banner will be shown on top of the skin and the
-- player will have to manually remove the painted canvas from the armor inventory. If
-- false, no banner is shown on the player's torso when the chest plate is not worn
local overlayOnSkin = true

local armorTextureSize = {w = 64, h = 32}
local armorPreviewTextureSize = {w = 32, h = 64}

minetest.register_on_leaveplayer(function(player)
	local name = player:get_player_name()
	if name then
		playerOverlayTextures[name] = nil
		playerOverlays[name] = nil
		playerShields[name] = nil
		playerChestplates[name] = nil
	end
end)

table.insert(armor.elements, "banner")

local hexcols = painting:get_hexcols()
local revcolors = painting:get_revcolors()

local function to_imagestring(data, res, offsetx, offsety, scale)
	if not data or not res then
		return
	end

	if not scale then
		scale = 1
	elseif scale < 1 then
		scale = 1
	end

	scale = math.floor(scale)

	local t, n = {("[combine:%ix%i"):format(res * scale, res * scale)}, 2

	for x = 0, (res - 1) * scale, scale  do
		local xs = data[x / scale]
		for y = 0, (res - 1) * scale, scale do
			for i = 0, scale - 1 do
				for j = 0, scale - 1 do
					t[n] = (":%i,%i=painting_white.png\\^[colorize\\:#%s")
						:format(x + i + offsetx, y + j + offsety, hexcols[revcolors[xs[y / scale]]])
					n = n + 1
				end
			end
		end
	end
	if n - 1 == 1 then
		minetest.log("error", "[painted_3d_armor] no texels")
		return "painting_white.png"
	end

	return table.concat(t)
end

local function get_data(player, stack)
	local data = minetest.deserialize(stack:get_metadata())
	if not data or not (type(data.res) == "number" and data.res <= 24) then
		local name, armor_inv = armor:get_valid_player(player, "[paintedcanvas]")
		if not name then
			return
		end
		local drop = {}
		for i = 1, armor_inv:get_size("armor") do
			local stack = armor_inv:get_stack("armor", i)
			if stack:get_count() > 0 and stack:get_name() == "painting:paintedcanvas" then
				table.insert(drop, stack)
				armor:set_inventory_stack(player, i, nil)
			end
		end
		local inv = player:get_inventory()
		for _, stack in ipairs(drop) do
			if inv:room_for_item("main", stack) then
				inv:add_item("main", stack)
			else
				armor.drop_armor(player:get_pos(), stack)
			end
		end
		data = nil
	end
	return data
end

local function set_painting(player, stack)
	local name = player:get_player_name()
	local data = get_data(player, stack)

	local chestplate_overlay = "^"..to_imagestring(data.grid, data.res, 21 * data.res / 6, 23 * data.res / 6, 1)
	-- local chestplate_preview_overlay = "^"..to_imagestring(data.grid, data.res, 10 * data.res / 6, 22 * data.res / 6, 2)
	local shield_overlay = "^"..to_imagestring(data.grid, data.res, 5 * data.res / 6, 5 * data.res / 6, 1)
	-- local shield_preview_overlay = "^"..to_imagestring(data.grid, data.res, 23 * data.res / 6, 37 * data.res / 6, 1)

	local total_overlay = ""
	-- local total_preview_overlay = ""

	if playerChestplates[name] then
		total_overlay = chestplate_overlay
		-- total_preview_overlay = chestplate_preview_overlay
	elseif (not playerChestplates[name]) and overlayOnSkin then
		total_overlay = chestplate_overlay
		-- total_preview_overlay = chestplate_preview_overlay
	end

	if playerShields[name] then
		total_overlay = total_overlay..shield_overlay
		-- total_preview_overlay = total_preview_overlay..shield_preview_overlay
	end

	if armor.textures[name] then
		player_api.set_textures(player, {
			armor.textures[name].skin,
			armor.textures[name].armor.."^[resize:"
			..tostring(armorTextureSize.w * data.res / 6).."x"
			..tostring(armorTextureSize.h * data.res / 6)..total_overlay,
			armor.textures[name].wielditem
		})
		playerOverlayTextures[name] = "^[resize:"..tostring(armorTextureSize.w * data.res / 6).."x"..tostring(armorTextureSize.h * data.res / 6)..total_overlay
--[[ why the last [colorize applies to the whole preview,
	"image[2.5,"..(fy - 0.25)..";2,4;"..armor.textures[name].preview.."]".. doesn't support modifiers ?
		armor.textures[name].preview = armor.textures[name].preview.."^[resize:"
			..tostring(armorPreviewTextureSize.w * data.res / 6).."x"
			..tostring(armorPreviewTextureSize.h * data.res / 6)..total_preview_overlay--]]
	end
end

local function set_banner(player, stack)
	local name = player:get_player_name()
	local data = stack:get_metadata()

	local chestplate_overlay = data:gsub("%(", "(c_"):gsub("mask%:", "mask:c_")
	local chestplate_preview_overlay = data:gsub("%(", "(cp_"):gsub("mask%:", "mask:cp_")
	local shield_overlay = data:gsub("%(", "(s_"):gsub("mask%:", "mask:s_")
	local shield_preview_overlay = data:gsub("%(", "(sp_"):gsub("mask%:", "mask:sp_")

	local total_overlay = ""
	local total_preview_overlay = ""

	if playerChestplates[name] then
		total_overlay = chestplate_overlay
		total_preview_overlay = chestplate_preview_overlay
	elseif (not playerChestplates[name]) and overlayOnSkin then
		total_overlay = chestplate_overlay
		total_preview_overlay = chestplate_preview_overlay
	end

	if playerShields[name] then
		total_overlay = total_overlay.."^"..shield_overlay
		total_preview_overlay = total_preview_overlay.."^"..shield_preview_overlay
	end

	if armor.textures[name] then
		player_api.set_textures(player, {
			armor.textures[name].skin,
			armor.textures[name].armor.."^[resize:"
			..tostring(armorTextureSize.w * 8).."x"
			..tostring(armorTextureSize.h * 8).."^"..total_overlay,
			armor.textures[name].wielditem,
		})
		playerOverlayTextures[name] = "^[resize:"..tostring(armorTextureSize.w * 8).."x"..tostring(armorTextureSize.h * 8).."^"..total_overlay

		armor.textures[name].preview = armor.textures[name].preview.."^[resize:"
			..tostring(armorPreviewTextureSize.w * 4).."x"
			..tostring(armorPreviewTextureSize.h * 4).."^"..total_preview_overlay
	end
end

local function set_image(player, stack)
	local name = player:get_player_name()
	local image_name = "_"..name.."_banner.png"

	local banner = io.open(minetest.get_modpath("painted_3d_armor").."/textures/"..image_name, "r")
	image_name = banner and image_name or "default_banner.png"
	if banner then
		io.close(banner)
	else
		minetest.chat_send_player(name, "Banner not found, using default model")
	end

	local chestplate_overlay = "^[combine:18x36:87,88="..image_name
	local chestplate_preview_overlay = "^[combine:18x36:23,40="..image_name.."^[resize:128x256"
	local shield_overlay = "^[combine:18x36:23,16="..image_name
	local shield_preview_overlay = "^[combine:18x36:93,144="..image_name

	local total_overlay = ""
	local total_preview_overlay = ""

	if playerChestplates[name] then
		total_overlay = chestplate_overlay
		total_preview_overlay = chestplate_preview_overlay
	elseif (not playerChestplates[name]) and overlayOnSkin then
		total_overlay = chestplate_overlay
		total_preview_overlay = chestplate_preview_overlay
	end

	if playerShields[name] then
		total_overlay = total_overlay..shield_overlay
		total_preview_overlay = total_preview_overlay..shield_preview_overlay
	end

	if armor.textures[name] then
		player_api.set_textures(player, {
			armor.textures[name].skin,
			armor.textures[name].armor.."^[resize:256x128"..total_overlay,
			armor.textures[name].wielditem,
		})
		playerOverlayTextures[name] = "^[resize:256x128"..total_overlay

		armor.textures[name].preview = armor.textures[name].preview.."^[resize:64x128"..total_preview_overlay
	end
end

armor:register_on_equip(
	function(player, index, stack)
		if player then
			if	stack:get_name() == "painting:paintedcanvas" and get_data(player, stack) or
				stack:get_name() == "painted_3d_armor:banner_armor" or
				stack:get_name() == "painted_3d_armor:image_armor"
			then
				playerOverlays[player:get_player_name()] = stack
			else
				local tool = minetest.registered_tools[stack:get_name()]
				if tool and tool.groups.armor_shield then
					playerShields[player:get_player_name()] = true
				elseif tool and tool.groups.armor_torso then
					playerChestplates[player:get_player_name()] = true
				end
			end
		end
	end
)

armor:register_on_update(
	function(player)
		if player then
			local name = player:get_player_name()
			local stack = playerOverlays[name]
			if stack then
				if stack:get_name() == "painting:paintedcanvas" then
					set_painting(player, stack)
				elseif stack:get_name() == "painted_3d_armor:banner_armor" then
					set_banner(player, stack)
				elseif stack:get_name() == "painted_3d_armor:image_armor" then
					set_image(player, stack)
				end
			end
		end
	end
)

wieldview.update_wielded_item = function(self, player)
	if not player then
		return
	end
	local name = player:get_player_name()
	local stack = player:get_wielded_item()
	local item = stack:get_name()
	if not item then
		return
	end
	if self.wielded_item[name] then
		if self.wielded_item[name] == item then
			return
		end
		armor.textures[name].wielditem = self:get_item_texture(item)
		armor:update_player_visuals(player)
		armor:run_callbacks("on_update", player)
	end
	self.wielded_item[name] = item
end

armor:register_on_unequip(
	function(player, index, stack)
		if player then
			if	stack:get_name() == "painting:paintedcanvas" or
				stack:get_name() == "painted_3d_armor:banner_armor" or
				stack:get_name() == "painted_3d_armor:image_armor"
			then
				playerOverlays[player:get_player_name()] = nil
			else
				local tool = minetest.registered_tools[stack:get_name()]
				if tool and tool.groups.armor_shield then
					playerShields[player:get_player_name()] = nil
				elseif tool and tool.groups.armor_torso then
					playerChestplates[player:get_player_name()] = nil
				end
			end
		end
	end
)

--canvas inventory items
for _, v in ipairs({6, 12, 24}) do
	minetest.register_craftitem(("painted_3d_armor:armor_canvas_%sx%s"):format(v, v), {
		description = ("Armor canvas %sx%s"):format(v, v),
		inventory_image = "default_paper.png",
		stack_max = 99
	})
end

minetest.registered_craftitems["painting:paintedcanvas"].groups.armor_banner = 1

if banners then
	minetest.register_craftitem("painted_3d_armor:banner_armor",
		{
			drawtype = "mesh",
			mesh = "banner_support.x",
			inventory_image = "banner_sheet.png",
			description = "Armor banner",
			groups = {armor_banner = 1},
			on_use = function(i, p, pt)
				banners.banner_on_use(i, p, pt)
			end
		}
	)

	minetest.register_craftitem("painted_3d_armor:image_armor",
		{
			drawtype = "mesh",
			wield_image = "banner_sheet.png",
			inventory_image = "banner_sheet.png",
			description = "Armor image",
			groups = {armor_banner = 1}
		}
	)
end