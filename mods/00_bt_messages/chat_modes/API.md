# `chat_modes` API

Other mods can implement additional chat modes.

You can implement a new chat mode by calling

	chat_modes.register(modename, modedef)

* `modename` - the name of the mode, as will be supplied to the `/chatmode` as first argument
* `modedef` - a table containing the mode definition

## `modedef` definition

The mode definition must include the following table fields:

* `help`
	* a string -- brief summary of the options
* `can_register(playername, params_array)`
	* optional
	* checks whether the player can switch to the mode, given the parameters
	* does not register the player - simply performs the check and returns a boolean
	* returns `true` if the registration would normally succeed
* `register(playername, params_array)`
	* a handler function that is called any time a user switches chat modes. It is expected that the handler will register the player as having activated the mode, according to its parameters.
* `deregister(playername)`
	* a handler function that is called any time a user switches chat modes. It is expected that the handler will remove the player from the list of players registered against this mode.
* `getPlayers(playername, message)`
	* a handler function that returns a list of players.
	* This function is responsible for determining which players should receive the message.
	* The message content is provided for extra flexibility.

## Example file

An example file is provided in `example_mode.lua`

You can copy this file to your own mod to make use of `chat_modes`'s facilities.

## Example of `modedef`

The following (fairly pointless) module will send a mesasge to some players, depending on an inverse probability. It does not check for the validity of the parameter passed during registration.

	local probplayers = {}

	chat_modes.register_mode("maybesay", {
		help = "<prob> -- send a message to all, with a probability <prob> of sending the message at all.",

		register = function(playername, params)
			probplayers[playername] = int(params[1]) or 10
		end,

		deregister = function(playername)
			probplayers[playername] = nil
		end,

		getPlayers = function(playername, message)
			local targetplayers = {}

			for _,player in pairs(minetest.get_connected_players() ) do
				if player:get_player_name() == playername then
					continue
				end

				if math.random(1, probplayers[playername] ) == 1 then
					targetplayers[#targetplayers] = player
				end
			end

			return targetplayers
		end,
	})


## Interceptors

It is possible to register interceptor handlers - these are functions which ALWAYS run, after the mode handler, but before the message dispatch.

The handler takes as arguments the name of the sender of the message, the message contents, and the list of target players.

If the handler returns false, then the message dispatch will not run, and the message will not be sent.

Otherwise, the handler must return a list of players - even if that is just the original list of players it received. This allows the interceptor to remove players from the list if it deems it necessary.

For example, this (pointless) interceptor can decline to send messages from players with "corpse" in their name (by returning false to prevent sending the message at all), or prevent delivery of messages to players with "corpse" in their name (by returning a subset of the originally received targets)

	chat_modes.register_interceptor("no corpses", function(sender, message, targets)
		if string.match(sender, "corpse") then
			minetest.chat_send_player("corpses cannot talk!")
			return false
		end

		local newtargets = {}
		local corpses = ""
		local i = 1
		for _,player in pairs(targets) do
			if not string.match(player:get_player_name(), "corpse") then
				newtargets[i] = player
				i = i+1
				corpses = corpses..player..", "
			end
		end

		minetest.chat_send_player("DO not wake corpses"..corpses.." they cannot chat!")

		return newtargets
	end)
