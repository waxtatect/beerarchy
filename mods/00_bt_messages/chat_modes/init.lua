--[[

Chat Modes for Minetest

This mod add multiple modes in which players can chat.

It has little use in singleplayer mode, and is off by default.

When installed on a server, you need to add the following to your minetest.conf:

	chat_modes.active = true

See README.md for more information.

--]]

if minetest.setting_getbool("chat_modes.active") then
	dofile( minetest.get_modpath("chat_modes").."/api.lua" )
end
