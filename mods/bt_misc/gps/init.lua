--
-- Mod GPS
--

gps = {version = "1.0.0"}

-- Destinations set limit that a player can have on GPS
-- Definir limite de Destinos que um jogador pode ter no gps
local LIMITE = 16

-- Time (in seconds) between each check inventory to see if this with a GPS
-- Tempo (em segundos) entre cada verificacao de inventario para saber se esta com um gps
local TEMPO = 5

-- Tradutor de String
local S = minetest.get_translator("gps")

-- Verificar texto sem caracteres
check_null_valid_text = function(s)
	if s == nil then return false end
	for char in string.gmatch(s, ".") do
		return true
	end
	return false
end

-- Caracteres validos
local valid_chars = {
	-- Maiusculos
	["A"] = true,
	["B"] = true,
	["C"] = true,
	["D"] = true,
	["E"] = true,
	["F"] = true,
	["G"] = true,
	["H"] = true,
	["I"] = true,
	["J"] = true,
	["K"] = true,
	["L"] = true,
	["M"] = true,
	["N"] = true,
	["O"] = true,
	["P"] = true,
	["Q"] = true,
	["R"] = true,
	["S"] = true,
	["T"] = true,
	["U"] = true,
	["V"] = true,
	["W"] = true,
	["X"] = true,
	["Y"] = true,
	["Z"] = true,
	-- Minusculos
	["a"] = true,
	["b"] = true,
	["c"] = true,
	["d"] = true,
	["e"] = true,
	["f"] = true,
	["g"] = true,
	["h"] = true,
	["i"] = true,
	["j"] = true,
	["k"] = true,
	["l"] = true,
	["m"] = true,
	["n"] = true,
	["o"] = true,
	["p"] = true,
	["q"] = true,
	["r"] = true,
	["s"] = true,
	["t"] = true,
	["u"] = true,
	["v"] = true,
	["w"] = true,
	["x"] = true,
	["y"] = true,
	["z"] = true,
	-- Numeros
	["0"] = true,
	["1"] = true,
	["2"] = true,
	["3"] = true,
	["4"] = true,
	["5"] = true,
	["6"] = true,
	["7"] = true,
	["8"] = true,
	["9"] = true,
	-- Caracteres especiais
	[" "] = true
}

-- Verificar nome do grupo
check_text = function(text)
	-- Verifica comprimento
	if string.len(text) > 30 or string.len(text) == 0 then
		return false
	end

	-- Verifica se existe ao menos um caracter valido
	if check_null_valid_text(text) == false then
		return false
	end

	-- Verifica caracteres validos
	local text_valido = ""
	for char in string.gmatch(text, ".") do
		if valid_chars[char] then
			text_valido = text_valido .. char
		end
	end
	if text ~= text_valido then
		return false
	end

	return true
end

--
-----
--------

-- Banco de dados
local path = minetest.get_worldpath()
local pathbd = path .. "/gps"

-- Cria o diretorio caso nao exista ainda
local function mkdir(pathbd)
	if minetest.mkdir then
		minetest.mkdir(pathbd)
	else
		os.execute('mkdir "' .. pathbd .. '"')
	end
end
mkdir(pathbd)

local registros = {}

-- Carregar na memoria dados de um jogador
local carregar_dados = function(name)
	local input = io.open(pathbd .. "/gps_"..name, "r")
	if input then
		registros[name] = minetest.deserialize(input:read("*l"))
		io.close(input)
		return true
	else
		return false
	end
end

-- Salvar registros de trabalhos
local salvar_dados = function(name)
	local output = io.open(pathbd .. "/gps_"..name, "w")
	output:write(minetest.serialize(registros[name]))
	io.close(output)
end

-- Tirar dados de jogadores que sairem do servidor
minetest.register_on_leaveplayer(function(player)
	local name = player:get_player_name()
	registros[name] = nil
end)

-- Registra apenas novos jogadores
minetest.register_on_newplayer(function(player)
	local name = player:get_player_name()
	registros[name] = {
		string = "",
		destinos = {}
	}
	salvar_dados(name)
	carregar_dados(player:get_player_name())
end)

-- Carrega dados de jogadores que conectam
minetest.register_on_joinplayer(function(player)
	if carregar_dados(player:get_player_name()) == false then
		local name = player:get_player_name()
		registros[name] = {
			string = "",
			destinos = {}
		}
		salvar_dados(name)
		carregar_dados(name)
	end
end)
-- Fim

--------
-----
--

--
-----
--------

-- Craftitem
minetest.register_craftitem("gps:gps", { -- GPS
	description = S("GPS"),
	stack_max = 1,
	inventory_image = "gps_item.png",
	on_use = function(itemstack, user, pointed_thing)
		local name = user:get_player_name()
		minetest.show_formspec(name, "gps:gps", ([[
			size[5,4]
			bgcolor[#08080800]
			background[0,0;5,4;gps_bg.png;true]
			label[0.1,-0.1;%s]
			dropdown[0.1,0.4;5,1;destino;%s;1]
			button_exit[0.1,1.1;1.7,1;ir;%s]
			button_exit[1.7,1.1;1.7,1;desligar;%s]
			button_exit[3.3,1.1;1.6,1;deletar;%s]
			field[0.3,2.9;5,1;nome_destino;%s;%s]
			button_exit[0,3.3;5,1;gravar;%s]
			]]):format(S("Destinations"), registros[name].string, S("Locate"),
				S("Turn Off"), S("Delete"), S("New Destination"),
				S("My Place"), S("Save New Place"))
		)
	end
})
--[[
minetest.register_craft({ -- Receita de GPS
	output = "gps:gps",
	recipe = {
		{"default:steel_ingot", "dye:orange", "default:steel_ingot"},
		{"default:steel_ingot", "default:diamond", "default:steel_ingot"},
		{"default:stick", "default:stick", "default:stick"}
	}
})
--]]
-- Fim
--------
-----
--

-- Atualizar string
local atualizar_string = function(name)
	registros[name].string = ""
	local i = 0
	for destino, pos in pairs(registros[name].destinos) do
		if i > 0 then registros[name].string = registros[name].string .. "," end
		registros[name].string = registros[name].string .. destino
		i = i + 1
	end
end

-- Variavel global de waypoints
local waypoints = {}

-- Verificar Waypoint
local temporizador = 0
minetest.register_globalstep(function(dtime)
	temporizador = temporizador + dtime
	if temporizador >= TEMPO then
		local waypoints_validos = {}
		for name, waypoint in pairs(waypoints) do
			local player = minetest.get_player_by_name(name)
			if not player or not player:get_inventory():contains_item(player:get_wield_list(), "gps:gps") then
				if player then
					player:hud_remove(waypoints[name])
					minetest.chat_send_player(name, S("You need to be with the GPS to go to the destination."))
				end
			else
				waypoints_validos[name] = waypoints[name]
			end
		end
		waypoints = waypoints_validos
		temporizador = 0
	end
end)

-- Adicionar Waypoint
local adicionar_waypoint = function(name, destino)
	local player = minetest.get_player_by_name(name)
	if waypoints[name] then
		player:hud_remove(waypoints[name])
	end
	waypoints[name] = player:hud_add({
		hud_elem_type = "waypoint",
		name = destino,
		number = 16747520,
		world_pos = registros[name].destinos[destino]
	})
end

-- Recebedor de campos
minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname == "gps:gps" then
		local name = player:get_player_name()
		if fields.ir then
			if registros[name].destinos[fields.destino] then
				adicionar_waypoint(name, fields.destino)
				minetest.chat_send_player(name, S("GPS Active. @1 located.", fields.destino))
				minetest.sound_play("gps_beep", {gain = 1.0, max_hear_distance = 3, object = player}, true)
				return true
			else
				minetest.chat_send_player(name, S("No destination found. Set a new."))
				return true
			end
		elseif fields.desligar then
			if waypoints[name] then
				player:hud_remove(waypoints[name])
			end
			minetest.chat_send_player(name, S("GPS turned off."))
			return true
		elseif fields.gravar then
			if fields.nome_destino then
				if not fields.nome_destino:find("{")
					and not fields.nome_destino:find("}")
					and not fields.nome_destino:find(",")
					and not fields.nome_destino:find("\\")
					and not fields.nome_destino:find("\"")
					and check_text(fields.nome_destino)
				then
					if fields.nome_destino == "" then
						minetest.chat_send_player(name, S("No name set to the place. Enter a name."))
						return true
					end
					-- verificar quantos ja tem
					local total = 0
					for destino, pos in pairs(registros[name].destinos) do
						total = total + 1
					end
					if total >= LIMITE then
						minetest.chat_send_player(name, S("Limit is @1 destinations. Delete any of the already existing.", LIMITE))
						return true
					end
					registros[name].destinos[fields.nome_destino] = player:get_pos()
					atualizar_string(name)
					salvar_dados(name)
					minetest.chat_send_player(name, S("@1 has been recorded in your GPS.", fields.nome_destino))
					-- Caso ja tenha e esteja ativo entao ajusta o waypoint visualizado
					if tonumber(waypoints[name]) and player:hud_get(waypoints[name]) then
						local def = player:hud_get(waypoints[name])
						if def.name == fields.nome_destino then adicionar_waypoint(name, fields.nome_destino) end
					end
					return true
				else
					minetest.chat_send_player(name, S("Invalid characters. Try using only letters and numbers in the new name."))
					return true
				end
			else
				minetest.chat_send_player(name, S("No name specified for the new place. Set the name of this place."))
				return true
			end
		elseif fields.deletar then
			if fields.destino and fields.destino ~= "" then
				if tonumber(waypoints[name]) then
					player:hud_remove(waypoints[name])
				end
				local destinos_restantes = {} -- realoca destinos na memoria
				for destino, pos in pairs(registros[name].destinos) do
					if destino ~= fields.destino then
						destinos_restantes[destino] = pos
					end
				end
				registros[name].destinos = destinos_restantes
				atualizar_string(name)
				salvar_dados(name)
				minetest.chat_send_player(name, S("@1 has been deleted.", fields.destino))
				return true
			else
				minetest.chat_send_player(name, S("No destinations to delete."))
				return true
			end
		end
	end
end)

-- Tira waypoint quando o jogador morre
minetest.register_on_dieplayer(function(player)
	if waypoints[player:get_player_name()] then
		player:hud_remove(waypoints[name])
	end
end)