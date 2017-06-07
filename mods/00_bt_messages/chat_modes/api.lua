
-- Namespace global variable

chat_modes = {}

-- Privs

minetest.register_privilege("cmodeswitch", "Player can switch their chat mode.")

local debug_on = false
function chat_modes.dodebug(message, artefact)
	if not debug_on then return end

	if artefact == nil then
		artefact = ""
	else
		artefact = "Artefact: "..dump(artefact)
	end

	minetest.debug("[32;1mCHATMODES[0m - "..message .. artefact)
end
local dodebug = chat_modes.dodebug


-- ================================
-- Main vairables
dodebug("Loading main variables")

local heuristics = {} -- modestring => mode_definition_table

local interceptors = {} -- name --> function(playername, message, playerlist)

-- Keep track of what mode players are in
local playermodes = {} -- playername => modestring

-- Keep track of players who have deafened themselves
local deafplayers = {}

-- If the user activates chat_modes but does not properly configure it, just activate "shout"
local defaultmode = minetest.setting_get("chat_modes.mode") or "shout"

-- Modes to actually load
local loadmodes = minetest.setting_get("chat_modes.defaults") or "shout,proximity,channel"


-- ================================
-- Public API
dodebug("Exposing API")

function chat_modes.register_mode(modename, mdef)
	-- TODO sanity check the definition !
	heuristics[modename] = mdef
end

function chat_modes.register_interceptor(name, handler)
	interceptors[name] = handler
end

-- Send a player chat, unless the player has set themselves ass deaf
function chat_modes.chatsend(player, message)
	if type(player) ~= "string" then
		player = player:get_player_name()
	end

	if not deafplayers[player] then
		minetest.chat_send_player(player, message)
	end
end

-- ================================
-- Chat mode switcher
dodebug("Define internal switching function")

local function chatmodeswitch(playername, argsarray)
	local oldmodedef = heuristics[ playermodes[playername] ]

	local newmodename = table.remove(argsarray, 1)
	local newmodedef = heuristics[newmodename]

	if not newmodedef then
		minetest.chat_send_player(playername, "No such mode.")
		return
	end

	if newmodedef.can_register and not newmodedef.can_register(playername, argsarray) then
		minetest.chat_send_player(playername, "You cannot switch to that mode with those settings.")
		return
	end

	-- ====

	if oldmodedef.deregister then
		oldmodedef.deregister(playername)
	end

	playermodes[playername] = newmodename
	
	if newmodedef.register then
		newmodedef.register(playername, argsarray)
	end
end

local function argstoarry(arguments)
	return arguments:split(" ")
end


-- ================================
-- General chat utilities
dodebug("Define extra commands")

minetest.register_chatcommand("deaf", {
	description = "Toggle deaf status. If you are deaf (Deaf mode 'on'), you do not receive any chat messages.",
	privs = {shout = true},
	func = function(playername, args)
		if deafplayers[playername] then
			deafplayers[playername] = nil
			minetest.chat_send_player(playername, "Deaf mode OFF")
		else
			deafplayers[playername] = true
			minetest.chat_send_player(playername, "Deaf mode ON")
		end
	end,
})

-- Send message to all, named after the UNIX command of the same name
minetest.register_chatcommand("wall", {
	params = "<compulsory message>",
	description = "Send a message to all players, regardless of chat mode or deaf status - for moderators.",
	privs = {shout = true, basic_privs = true},
	func = function(playername, message)
		minetest.chat_send_all("MODERATOR "..playername..": "..message)
	end,
})



-- ================================
-- Command registration
dodebug("Define main commands")

minetest.register_chatcommand("chatmodeset", {
	privs = {basic_privs = true},
	params = "<player> <chatmode>",
	description = "Set a player's chat mode",
	func = function(playername, params)
		local argsarray = argstoarry(params)
		local tplayername = table.remove(argsarray, 1)

		if minetest.get_player_by_name(tplayername) then
			minetest.chat_send_player(tplayername, playername.." switched your chat: "..table.concat(argsarray, " ") )
			chatmodeswitch(tplayername, argsarray)
		else
			minetest.chat_send_player(playername, "Could not set chat for "..tplayername)
		end
	end
})

minetest.register_chatcommand("chatmode", {
	params = "<chatmode>",
	description = "Set a new chat mode",
	privs = {shout = true, cmodeswitch = true},
	func = function(playername, arguments)
		chatmodeswitch( playername, argstoarry(arguments) )
	end,
})

minetest.register_chatcommand("chatmodes", {
	description = "List available chat modes",
	privs = {shout = true, cmodeswitch = true},
	func = function(playername, params)
		for modename,modedef in pairs(heuristics) do
			local helptext = "(unknown)"
			if modedef.help then
				helptext = modedef.help
			end

			minetest.chat_send_player(playername, modename.." : "..helptext )
		end
		minetest.chat_send_player(playername, "deaf : stop receiving any chats from players")
	end,
})



-- ================================
-- Interception
dodebug("Chat interception")

minetest.register_on_chat_message(function(playername, message)
	if not minetest.get_player_privs(playername, {shout = true}) then
		minetest.chat_send_player(playername, "Chat message send failed. You do not have the 'shout' privilege.")
		return true
	end

	minetest.log("action", "MODAL CHAT: "..message)

	local targetmode = playermodes[playername]
	local modedef = heuristics[ targetmode ]
	
	if not modedef then
		minetest.chat_send_player(playername, "Unknown chat mode.")
		return true
	end

	local valid_players = modedef.getPlayers(playername, message)

	dodebug(playername, {message=message, mode=targetmode, modedef=modedef, sendto = valid_players})

	for handlername,handle in pairs(interceptors) do
		chat_modes.dodebug("Running interceptor "..handlername)
		-- Allow interceptors to kill the message
		local result = handle(playername, message, valid_players)
		if not result then
			return true -- marked as handled
		end

		valid_players = result
	end

	for _,theplayer in pairs(valid_players) do
		local theplayername = theplayer:get_player_name()
		chat_modes.dodebug("trying "..theplayername)
		if theplayername ~= playername then
			chat_modes.chatsend(theplayername, "<"..playername.."> "..message)
		end
	end

	return true
end)



-- ================================
-- Player management
dodebug("Manage players joining and leaving")

minetest.register_on_leaveplayer(function(player, timedout)
	-- Do not discard pref for a timed out player
	if not timedout then
		playermodes[player:get_player_name()] = nil
	end
end)

minetest.register_on_joinplayer(function(player)
	-- Do not reinitialize after a player timeout
	if not playermodes[player:get_player_name()] then
		playermodes[player:get_player_name()] = defaultmode
	end
end)



-- ================================
-- Load defaults
dodebug("Checking for default functions")

if loadmodes then
	dodebug("Default modes found:",loadmodes:split(","))

	for _,modename in pairs(loadmodes:split(",")) do
		dodebug("Loading ",modename)
		dofile(minetest.get_modpath("chat_modes").."/"..modename.."_mode.lua" )
	end
else
	dofile(minetest.get_modpath("chat_modes").."/shout_mode.lua" )
end

-- Load standard interceptors
-- Allow direct pinging
dofile(minetest.get_modpath("chat_modes").."/atreply_interceptor.lua")

dodebug("Loaded chat modes")
