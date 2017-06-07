
local function getnextplayers(messageparts)
	local includes = {}
	local i = 1

	-- Consume until found new player names
	while messageparts[1] and messageparts[1]:sub(1,1) ~= '@' do
		table.remove(messageparts, 1)
	end

	-- Get the next set of names
	while messageparts[1] and messageparts[1]:sub(1,1) == '@' do
		local token = table.remove(messageparts, 1)
		includes[i] = token:sub(2, #token)
		i = i+1
	end

	return {includes=includes, mparts=messageparts}
end

local function playping(playername)
	-- TODO - implement sound
	return
end

local function removefrom(players, playername)
	local i = 1
	while players[i] do
		if players[i]:get_player_name() == playername then
			table.remove(players, i)
			break
		end
	end

	return players
end

chat_modes.register_interceptor("atreply", function(sender, message, targets)
	if minetest.setting_getbool("chat_modes.no_at_replies") == false then
		return targets
	end

	local messageparts = message:split(" ")

	local includes = {"triggerone"}
	local i = 1

	-- Players mentioned at start of message
	-- Only send to them
	while messageparts[1] and messageparts[1]:sub(1,1) == '@' do
		local token = table.remove(messageparts, 1)
		local dmstring = "DM from "..sender..": "

		local tname = token:sub(2, #token)
		i = i+1
		chat_modes.chatsend(tname, dmstring..message)
		playping(tname)
	end
	if i > 1 then
		chat_modes.dodebug("DECLINE")
		return false
	end

	while includes[1] do -- hence "triggerone" to do it at least once
		local nextin = getnextplayers(messageparts)
		includes = nextin.includes
		messageparts = nextin.mparts

		local dmstring = "DM from "..sender..": "

		for _,pname in pairs(includes) do
			chat_modes.chatsend(pname, dmstring..message)
			playping(pname)
			targets = removefrom(table.copy(targets), playername)
		end
	end

	chat_modes.dodebug("ALLOW")
	return targets -- Allow processing the rest
end)

