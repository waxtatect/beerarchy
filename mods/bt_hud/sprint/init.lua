--[[
Sprint mod for Minetest by GunshipPenguin

To the extent possible under law, the author(s)
have dedicated all copyright and related and neighboring rights
to this software to the public domain worldwide. This software is
distributed without any warranty.
--]]

sprint = {
	method = 1,
	speed = 1.8,
	jump = 1.1,
	stamina = 20,
	timeout = 0.5, -- Only used if sprint.method = 0
	hudbars_used = false
}

if minetest.get_modpath("hudbars") then
	hb.register_hudbar("sprint", 0xFFFFFF, "Stamina",
		{bar = "sprint_stamina_bar.png", icon = "sprint_stamina_icon.png"},
		sprint.stamina, sprint.stamina, false)
	sprint.hudbars_used = true
end

local MP = minetest.get_modpath("sprint") .. "/"

if sprint.method == 0 then
	dofile(MP .. "wsprint.lua")
elseif sprint.method == 1 then
	dofile(MP .. "esprint.lua")
else
	minetest.log("error", "[sprint] sprint.method is not set properly, using e to sprint.")
	dofile(MP .. "esprint.lua")
end