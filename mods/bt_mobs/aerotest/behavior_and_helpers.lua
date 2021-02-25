local abs = math.abs
local atan = math.atan
local cos = math.cos
local deg = math.deg
local max = math.max
local min = math.min
local pi = math.pi
local rad = math.rad
local random = aerotest.random -- math.random
local sqrt = math.sqrt
local tan = math.tan

local timetot = 0
local timetrgt = 30

-- Entity for showing positions in debug
minetest.register_entity("aerotest:pos", {
	initial_properties = {
		visual = "cube",
		collide_with_objects = false,
		visual_size = {x = 1.1, y = 1.1},
		textures = {
			"aerotest_pos.png", "aerotest_pos.png",
			"aerotest_pos.png", "aerotest_pos.png",
			"aerotest_pos.png", "aerotest_pos.png"
		},
		collisionbox = {-0.55, -0.55, -0.55, 0.55, 0.55, 0.55},
		physical = false
	}
})

-- Show temp marker
local function temp_show(pos, time, pillar)
	if not pos then return end
	if not time then time = 5 end
	local step = 1
	if not pillar then pillar = 1 end
	if pillar < 0 then step = -1 end
	for i = 1, pillar, step do
		local obj = minetest.add_entity(
			{x = pos.x, y = pos.y + i, z = pos.z}, "aerotest:pos")
		minetest.after(time, function(obj) obj:remove() end, obj)
	end
end

-- Find if there is a node between pos1 and pos2
-- water = true means water = obstacle
-- returns distance to obstacle in nodes or nil
local function find_collision(pos1, pos2, water)
	local ray = minetest.raycast(pos1, pos2, false, water)
	local dist = nil
	for pointed_thing in ray do
		if pointed_thing.type == "node" then
			dist = math.floor(vector.distance(pos1, pointed_thing.under))
			break
		end
	end
	return dist
end

-- Radar function for obstacles lying in front of an entity
-- use water = true if water should be an obstacle
local function radar(pos, yaw, radius, water)
	if not radius or radius < 1 then radius = 16 end
	local left, right = 0, 0
	if not water then water = false end
	for j = 0, 3, 1 do
		for i = 0, 4, 1 do
			local pos2 = mobkit.pos_translate2d(pos, yaw + (i * pi / 16), radius)
			local pos3 = mobkit.pos_translate2d(pos, yaw - (i * pi / 16), radius)
			if find_collision(pos, {x = pos2.x, y = pos2.y + j * 2, z = pos2.z}, water) then
				left = left + 5 - i
			end
			if find_collision(pos, {x = pos3.x, y = pos3.y + j * 2, z = pos3.z}, water) then
				right = right + 5 - i
			end
		end
	end
	local up, down = 0, 0
	for j = -4, 4, 1 do
		for i = -3, 3, 1 do
			local k = i
			local pos2 = mobkit.pos_translate2d(pos, yaw + (i * pi / 16), radius)
			local collide = find_collision(pos, {x = pos2.x, y = pos2.y + j, z = pos2.z}, water)
			if k < 0 then k = k * - 1 end
			if collide and j <= 0 then
				down = down + math.floor((7 + j - k) * collide / radius * 2)
			elseif collide and j >= 0 then
				up = up + math.floor((7 - j - k) * collide / radius * 2)
			end
		end
	end
	local under = find_collision(pos, {x = pos.x, y = pos.y - radius, z = pos.z}, water)
	if not under then under = radius end
	local above = find_collision(pos, {x = pos.x, y = pos.y + radius, z = pos.z}, water)
	if not above then above = radius end
	return left, right, up, down, under, above
end

aerotest.prey = {}

function aerotest.find_attacker(pos, radius)
	if not radius then radius = 5 end

	local all_objects = minetest.get_objects_inside_radius(pos, radius)
	if #all_objects == 0 then
		return
	end

	for _, obj in ipairs(all_objects) do
		local entity = obj:get_luaentity()
		if entity and string.match(entity.name, "arrow") then
			local shooter = entity.shooter_name or throwing and throwing.playerArrows[obj]
			if shooter then
				local attacker = minetest.get_player_by_name(shooter)
				return attacker
			end
		end
	end
end

function aerotest.register_prey(name)
	if not name then return end
	aerotest.prey[name] = 1
end
--[[
-- Find the position with highest y value
local function cleanup(nodes)
	if not nodes or #nodes < 2 then return end
	for i = #nodes, 2, -1 do
		if nodes[i].y > nodes[i - 1].y then
			table.remove(nodes, i - 1)
		elseif nodes[i].y < nodes[i - 1].y then
			table.remove(nodes, i)
		end
	end

	for i = #nodes, 1, -1 do
		local arr = minetest.find_nodes_in_area(
			{x = nodes[i].x - 1, y = nodes[i].y, z = nodes[i].z - 1},
			{x = nodes[i].x + 1, y = nodes[i].y + 1, z = nodes[i].z + 1},
			{"air"})
		if #arr < 12 then table.remove(nodes, i) end
		if not nodes then break end
	end
	return nodes
end
--]]
-- Jump in vector direction
function aerotest.lq_jump2vec(self, go)
	if not go then return true end
	local init = true
	self.object:set_velocity(go)

	local function func(self)
		if init then
			mobkit.animate(self, "start")
		end

		local speed = vector.length(self.object:get_velocity())
		if abs(speed) < 1 and not init then
			return true
		end
		init = false
	end
	mobkit.queue_low(self, func)
end

-- Is take off possible
function aerotest.find_takeoff(self)
	local pos = mobkit.get_stand_pos(self) -- self.object:get_pos()
	pos.y = pos.y + 0.5
	local yaw = self.object:get_yaw()
	local startangle = 0
	local found = false
	local pos2 = {}

	local step = 0
	for angle = 0, 359, 10 do
		startangle = yaw + rad(angle)
		local pos2 = mobkit.pos_translate2d(pos, startangle, 20)
		pos2 = mobkit.pos_shift(pos2, {y = 6})
		if not find_collision(pos, pos2, true) then
			if found then
				step = step + 1
			end
			found = true
		else
			if step > 1 then
				startangle = startangle - rad(10 * (step + 1) / 2) -- find the center of the gap
				break
			end
			found = false
		end
	end
	found = found and not find_collision(pos, mobkit.pos_shift(pos, {y = 4}), true) -- check overhead

	return found, startangle, pos2
end

-- Throw a coin
local function leftorright()
	local rnd = random()
	if rnd > 0.5 then return true else return false end
end

-- Add function to remember previously taken decisions
local function chose_turn(self, a, b)
	local remember = mobkit.recall(self, "turn")
	if not remember then
		if leftorright() then
			remember = "1"
			mobkit.remember(self, "time", self.time_total)
			mobkit.remember(self, "turn", "1")
		else
			remember = "0"
			mobkit.remember(self, "time", self.time_total)
			mobkit.remember(self, "turn", "0")
		end
	end

	if a > b then
		mobkit.remember(self, "turn", "1")
		mobkit.remember(self, "time", self.time_total)
		return false
	elseif a < b then
		mobkit.remember(self, "turn", "0")
		mobkit.remember(self, "time", self.time_total)
		return true
	else
		if remember == "0" then return true else return false end
	end
end

-- Ask Termos what these functions do
local function pitchroll2pitchyaw(aoa, roll)
	if roll == 0.0 then return aoa, 0 end
	-- assumed vector x = 0, y = 0, z = 1
	local p1 = tan(aoa)
	local y = cos(roll) * p1
	local x = sqrt(p1^2 - y^2)
	local pitch = atan(y)
	local yaw = atan(x) * math.sign(roll)
	return pitch, yaw
end

function aerotest.lq_fly_aoa(self, lift, aoa, roll, acc, anim)
	aoa = rad(aoa)
	roll = rad(roll)
	local hpitch = 0
	local hyaw = 0
	local caoa = 0
	local laoa = nil
	local croll = roll
	local lroll = nil
	local lastrot = nil
	local init = true
	local func = function(self)
		local rotation = self.object:get_rotation()
		local vel = self.object:get_velocity()
		local vrot = mobkit.dir_to_rot(vel, lastrot)
		lastrot = vrot
		if init then
			if anim then mobkit.animate(self, anim) end
			init = false
		end

		local accel = self.object:get_acceleration()

		-- gradual changes
		if abs(roll-rotation.z) > 0.5 * self.dtime then
			croll = rotation.z + 0.5 * self.dtime * math.sign(roll - rotation.z)
		end

		if croll ~= lroll then
			hpitch, hyaw = pitchroll2pitchyaw(aoa, croll)
			lroll = croll
		end

		local hrot = {x = vrot.x + hpitch, y = vrot.y - hyaw, z = croll}
		self.object:set_rotation(hrot)
		local hdir = mobkit.rot_to_dir(hrot)
		local cross = vector.cross(vel, hdir)
		local lift_dir = vector.normalize(vector.cross(cross, hdir))

		local daoa = deg(aoa)
		local lift_coefficient = 0.24 * abs(daoa) * (1 / (0.025 * daoa + 1))^4 * math.sign(aoa)	-- homegrown formula
		local lift_val = lift * vector.length(vel)^2 * lift_coefficient

		local lift_acc = vector.multiply(lift_dir, lift_val)
		lift_acc = vector.add(vector.multiply(minetest.yaw_to_dir(rotation.y), acc), lift_acc)

		self.object:set_acceleration(vector.add(accel, lift_acc))
	end
	mobkit.queue_low(self, func)
end

function aerotest.lq_fly_pitch(self, lift, pitch, roll, acc, anim)
	pitch = rad(pitch)
	roll = rad(roll)
	local cpitch = pitch
	local croll = roll
	local hpitch = 0
	local hyaw = 0
	local lpitch = nil
	local lroll = nil
	local lastrot = nil
	local init = true

	local func = function(self)
		if init then
			if anim then mobkit.animate(self, anim) end
			init = false
		end
		local rotation = self.object:get_rotation()
		local accel = self.object:get_acceleration()
		local vel = self.object:get_velocity()
		local speed = vector.length(vel)
		local vdir = vector.normalize(vel)
		local vrot = mobkit.dir_to_rot(vel, lastrot)
		lastrot = vrot

		-- gradual changes
		if abs(roll - rotation.z) > 0.5 * self.dtime then
			croll = rotation.z + 0.5 * self.dtime * math.sign(roll - rotation.z)
		end
		if abs(pitch - rotation.x) > 0.5 * self.dtime then
			cpitch = rotation.x + 0.5 * self.dtime * math.sign(pitch - rotation.x)
		end

		if cpitch ~= lpitch or croll ~= lroll then
			hpitch, hyaw = pitchroll2pitchyaw(cpitch, croll)
			lpitch = cpitch lroll = croll
		end

		local aoa = deg(-vrot.x + cpitch)						-- angle of attack
		local hrot = {x = hpitch, y = vrot.y - hyaw, z = croll}	-- hull rotation
		self.object:set_rotation(hrot)
		local hdir = mobkit.rot_to_dir(hrot)					-- hull dir

		local cross = vector.cross(hdir, vel)
		local lift_dir = vector.normalize(vector.cross(hdir, cross))

		local lift_coefficient = 0.24 * max(aoa, 0) * (1 / (0.025 * max(aoa, 0) + 1))^4	-- homegrown formula
		-- local lift_val = mobkit.minmax(lift * speed^2 * lift_coefficient, speed / self.dtime)
		-- local lift_val = max(lift * speed^2 * lift_coefficient, 0)
		local lift_val = min(lift * speed^2 * lift_coefficient, 20)

		local lift_acc = vector.multiply(lift_dir, lift_val)
		lift_acc = vector.add(vector.multiply(minetest.yaw_to_dir(rotation.y), acc), lift_acc)
		accel = vector.add(accel, lift_acc)
		accel = vector.add(accel, vector.multiply(vdir, -speed * speed * 0.02)) -- drag
		accel = vector.add(accel, vector.multiply(hdir, acc))					-- propeller

		self.object:set_acceleration(accel)
	end
	mobkit.queue_low(self, func)
end

-- Back to my code
-- hq functions self explaining
function aerotest.hq_climb(self, property)
	self.hunger = self.hunger - 1
	mobkit.remember(self, "hunger", self.hunger)
	mobkit.remember(self, "xhaust", self.xhaust)
	local func = function(self)
		if mobkit.timer(self, 1) then
			local remember = mobkit.recall(self, "time")
			if remember then
				if self.time_total - remember > 15 then
					mobkit.forget(self, "turn")
					mobkit.forget(self, "time")
				end
			end
			self.action = "fly"
			local pos = self.object:get_pos()
			local yaw = self.object:get_yaw()

			local left, right, up, down, under, above = radar(pos, yaw, 32, true)

			if (down < 3) and (under >= 30) then
				aerotest.hq_glide(self, property)
				return true
			end
			if left > 3 or right > 3 then
				local lift = 0.6
				local pitch = 8
				local roll = 6
				local acc = 1.2
				-- roll = (max(left, right) / 30 * 3) + (down / 100) * 3 + roll
				roll = (max(left, right) / 30 * 7.5)
				lift = lift + (down - up) / 400
				pitch = pitch + (down - up) / 30
				-- lift = lift + (down / 100) - (up / 100)
				local turn = chose_turn(self, left, right)
				if turn then
					mobkit.clear_queue_low(self)
					aerotest.lq_fly_pitch(self, lift, pitch, roll * - 1, acc, 'fly')
				else
					mobkit.clear_queue_low(self)
					aerotest.lq_fly_pitch(self, lift, pitch, roll, acc, 'fly')
				end
			end
		end
		if mobkit.timer(self, 15) then mobkit.clear_queue_low(self) end
		if mobkit.is_queue_empty_low(self) then aerotest.lq_fly_pitch(self, 0.6, 8, (random(2) - 1.5) * 30, 1.2, 'fly') end
	end
	mobkit.queue_high(self, func, property)
end

function aerotest.hq_glide(self, property)
	self.hunger = self.hunger - 0.5
	mobkit.remember(self, "hunger", self.hunger)
	mobkit.remember(self, "xhaust", self.xhaust)
	local func = function(self)
		if mobkit.timer(self, 1) then
			self.action = "glide"
			local remember = mobkit.recall(self, "time")
			if remember then
				if self.time_total - remember > 15 then
					mobkit.forget(self, "turn")
					mobkit.forget(self, "time")
				end
			end
			local pos = self.object:get_pos()
			local yaw = self.object:get_yaw()
			local left, right, up, down, under, above = radar(pos, yaw, 32, true)
			if  (down > 10) or (under < 20) then
				aerotest.hq_climb(self, property)
				return true
			end
			if left > 3 or right > 3 then
				local lift = 0.6
				local pitch = 8
				local roll = 0
				local acc = 1.2
				-- roll = (max(left, right) / 30 * 3) + (down / 100) * 3 + roll
				roll = (max(left, right) / 30 * 7.5)
				local turn = chose_turn(self, left, right)
				if turn then
					mobkit.clear_queue_low(self)
					aerotest.lq_fly_pitch(self, lift, pitch, roll * -1, acc, 'glide')
				else
					mobkit.clear_queue_low(self)
					aerotest.lq_fly_pitch(self, lift, pitch, roll, acc, 'glide')
				end
			end
		end
		if mobkit.timer(self, 20) then mobkit.clear_queue_low(self) end
		if mobkit.is_queue_empty_low(self) then aerotest.lq_fly_pitch(self, 0.6, -4, (random(2) - 1.5) * 30, 0, 'glide') end
		end
	mobkit.queue_high(self, func, property)
end

function aerotest.hq_keepinrange(self, property, pos, radius)
	if not radius then radius = aerotest.abr * 16 end
	self.hunger = self.hunger - 0.5
	mobkit.remember(self, "hunger", self.hunger)
	mobkit.remember(self, "xhaust", self.xhaust)
	local func = function(self)
		if mobkit.timer(self, 1) then
			self.action = "range"
			local diff = 0
			local turn = false
			local mobpos = self.object:get_pos()
			pos.y = mobpos.y
			local yaw = self.object:get_yaw() + pi
			local tgtyaw = minetest.dir_to_yaw(vector.subtract(pos, mobpos)) + pi

			if yaw < tgtyaw then
				diff = tgtyaw - yaw
				turn = true
			elseif yaw > tgtyaw then
				diff = yaw - tgtyaw
				turn = false
			end

			local distance = math.floor(vector.distance(pos, mobpos))
			local left, right, up, down, under, above = radar(mobpos, yaw, 32, true)

			local lift = 0.6
			local pitch = 2
			local roll = 35
			local acc = 0.6
			-- local heading = mobkit.pos_translate2d(mobpos, yaw, 10)
			-- local togo = mobkit.pos_translate2d(mobpos, tgtyaw, 5)
			-- temp_show(heading, 1)
			-- temp_show(togo, 1, 3)
			if diff > pi and diff < 2 * pi then turn = not turn end

			if left > 6 or right > 6 then turn = chose_turn(self, left, right) end -- forget everything if there is sth on radar

			if turn then
				mobkit.clear_queue_low(self)
				aerotest.lq_fly_pitch(self, lift, pitch, roll * -1, acc, 'glide')
			else
				mobkit.clear_queue_low(self)
				aerotest.lq_fly_pitch(self, lift, pitch, roll, acc, 'glide')
			end

			if distance <= radius / 3 then
				aerotest.hq_climb(self, 1)
				return true
			end
		end

	end
	mobkit.queue_high(self, func, property)
end

-- Just hanging around
function aerotest.hq_idle(self, property, now)
	local init = true
	local func = function(self)
		if init then mobkit.animate(self, "idle") end

		if mobkit.timer(self, 1) or now then
			self.action = "idle"

			local pos = mobkit.get_stand_pos(self) -- self.object:get_pos()
			pos.y = pos.y + 0.5
			local yaw = self.object:get_yaw()
			local startangle = 0
			local found = false
			local pos2 = {}

			local wait = random(10) + 5

			if mobkit.timer(self, wait) or now then
				found, startangle, pos2 = aerotest.find_takeoff(self)
				found = found and not find_collision(pos, mobkit.pos_shift(pos, {y = 4}), true) -- check overhead
				if not found and aerotest.radar_debug then
					minetest.chat_send_all("Nothing Found !")
				end
				if found then
					if aerotest.radar_debug then
						pos2 = mobkit.pos_shift(mobkit.pos_translate2d(pos, startangle, 20), {y = 4})
						temp_show(pos2, 10)
					end
					mobkit.lq_turn2pos(self, pos2)
					-- TAKEOFF
					aerotest.hq_takeoff(self, startangle, property)
					return true
				elseif self.isinliquid then
					local yaw = self.object:get_yaw()
					aerotest.hq_takeoff(self, yaw, property, 12)
					return true
				else
					aerotest.hq_wayout(self, property + 1)
				end
			end
		end
		init = false
	end
	mobkit.queue_high(self, func, property)
end

-- Take off
function aerotest.hq_takeoff(self, startangle, property, yforce)
	self.hunger = self.hunger - 2
	mobkit.remember(self, "hunger", self.hunger)
	mobkit.remember(self, "xhaust", self.xhaust)
	local func = function(self)
		if not yforce then yforce = 8 end
		self.object:set_yaw(startangle)
		if mobkit.timer(self , 1) then
			mobkit.clear_queue_low(self)
			self.action = "takeoff"
			local pos = mobkit.get_stand_pos(self)
			if self.isonground or self.isinliquid then
				local tpos = pos
				mobkit.remember(self, "tpos", pos)
				mobkit.animate(self, "start")
				pos = mobkit.pos_translate2d(pos, startangle, 4)
				self.object:add_velocity({x = 0, y = yforce, z = 0})
				self.object:set_yaw(startangle)
			else
				local rpos = mobkit.recall(self, "tpos") or pos
				local vdist = vector.distance(rpos, pos)
				if vdist > 8 then
					mobkit.forget(self, "tpos")
					aerotest.hq_climb(self, property)
					return true
				end
			end

			aerotest.lq_fly_pitch(self, 1.8, 15, 0, 1.4, 'fly')
			-- aerotest.lq_fly_aoa(self, 0.6, 15, 0, 2.4, 'fly')
		end
	end
	mobkit.queue_high(self, func, property)
end

-- Find a way out
function aerotest.hq_wayout(self, property)
	local func = function(self)
		if self.isinliquid then return true end
		if mobkit.timer(self, 1) then
			self.action = "search"
			if mobkit.is_queue_empty_low(self) and self.isonground then
				local pos = mobkit.get_stand_pos(self)
				pos.y = pos.y + 0.5
				local yaw = self.object:get_yaw()
				local yawstep = 5
				local tgtyaw = {score = 0, yaw = rad(0), dist = 0, hypo = 0}
				local score = 0
				local forward =  10
				local a = 0
				local g = 0
				local left, right, up, down, under, above = radar(pos, yaw, forward, true)
				local alpha = math.floor(math.atan(2))

				for round = 0, 359, yawstep do
					left, right, up, down, under, above = radar(pos, rad(round), forward, true)
					local ground = mobkit.pos_translate2d(pos, rad(round), forward)
					local angled = mobkit.pos_shift(mobkit.pos_translate2d(pos, rad(round), forward), {y = forward * 2})
					g = find_collision(pos, ground, true) or forward
					a = find_collision(pos, angled, true) or forward

					score = g + a + 100 - up + down

					if score > 0 then
						if tgtyaw.score < score then
							tgtyaw.score = score
							tgtyaw.yaw = rad(round)
							tgtyaw.dist = g
							tgtyaw.hypo = a
							score = 0
						end
					end
				end

				local go, tt = {}, {}
				if above > 2 then
					local ankat = math.floor(math.cos(alpha) * tgtyaw.hypo)
					go = vector.subtract(mobkit.pos_translate2d(pos, tgtyaw.yaw, ankat), pos)
					tt = vector.subtract(mobkit.pos_translate2d(pos, tgtyaw.yaw + rad(180), ankat), pos)
					local shift = math.floor(math.sin(alpha) * tgtyaw.hypo)
					go = mobkit.pos_shift(go, {y = shift})

					if go then
						mobkit.lq_turn2pos(self, tt)
						aerotest.lq_jump2vec(self, go)
					end
				else
					local go = mobkit.pos_translate2d(pos, tgtyaw.yaw, tgtyaw.dist)
					if go then
						mobkit.dumbstep(self, 0, go, 1, 2)
					end
				end
			end
		end
		if aerotest.find_takeoff(self) then return true end
	end
	mobkit.queue_high(self, func, property)
end
--[[
-- Returns 2D angle from self to target in radians
local function get_yaw_to_object(self, target)
	local pos = mobkit.get_stand_pos(self)
	return minetest.dir_to_yaw(vector.direction(pos, target:get_pos()))
end
--]]
function aerotest.look_for_prey(self)
	local pos = mobkit.get_stand_pos(self)
	local yaw = self.object:get_yaw()
	local prey = minetest.get_objects_inside_radius(pos, aerotest.abr)
	if not prey or #prey < 1 then return end
	--[[
	for i = #prey, 1, -1 do
		local tyaw = get_yaw_to_object(self, prey[i])
		if tyaw > yaw + rad(90) or tyaw < yaw -rad(90) then table.remove(prey, i) end
	end
	if not prey then return end--]]

	for i = #prey, 1, -1 do
		if prey[i]:is_player() then
			table.remove(prey, i)
		else
			local entity = prey[i]:get_luaentity()
			if entity and not aerotest.prey[entity.name] then table.remove(prey, i) end
		end
	end
	if not prey then return end

	for i = #prey, 1, -1 do
		local entity = prey[i]:get_luaentity()
		local tpos = prey[i]:get_pos()
		local dist = vector.distance(pos, tpos)
		if dist < 20 or find_collision(pos, tpos, false) then table.remove(prey, i) end
	end
	if not prey or #prey < 1 then return end

	local badluck = prey[random(#prey)]
	return badluck
end

-- Hunting !
function aerotest.hq_hunt(self, property, target)
	self.hunger = self.hunger - 2
	mobkit.remember(self, "hunger", self.hunger)
	mobkit.remember(self, "xhaust", self.xhaust)
	local func = function(self)
		if not target then
			mobkit.clear_queue_high(self)
			aerotest.hq_climb(self, property)
			return true
		end
		self.action = "hunt"
		local roll = 0
		local pos = self.object:get_pos()
		local yaw = self.object:get_yaw()
		local tgtpos = target:get_pos()
		local tgtyaw = target:get_yaw()
		local tgtspeed = math.floor(vector.length(target:get_velocity() or {x = 0, y = 0, z = 0}))
		if target:is_player() then
			tgtyaw = target:get_look_horizontal()
		end
		if not tgtyaw or not tgtspeed or not mobkit.is_alive(target) or self.isonground or self.isinliquid then
			mobkit.clear_queue_high(self)
			aerotest.hq_climb(self, property)
			return true
		end
		local turn = 0
		local diff = 0
		local lift = 1.2
		local pitch = 5
		local acc = 0.6
		local anim = "fly"
		local truetpos = mobkit.pos_translate2d(tgtpos, tgtyaw, tgtspeed)
		local ddistance = vector.distance(pos,{x = truetpos.x, y = pos.y, z = truetpos.z})
		local alpha = atan((pos.y - truetpos.y) / ddistance)
		local truetyaw = minetest.dir_to_yaw(vector.subtract(truetpos, pos))
		local realdistance = vector.distance(pos, tgtpos)
		local ang2tgt = mobkit.pos_translate2d(pos, truetyaw, 15)

		if yaw < truetyaw then
			diff = truetyaw - yaw
			turn = -1
		elseif yaw > truetyaw then
			diff = yaw - truetyaw
			turn = 1
		end
		if abs(diff) <= 0.1 then
			turn = 0
		end

		if ddistance > 32 then
			roll = 15 * turn
		elseif ddistance > 22 then
			roll = 10 * turn
		elseif ddistance > 12 then
			roll = 5 * turn
		elseif ddistance <= 12 then
			roll = 2 * turn
		end

		if pos.y > truetpos.y + 15 then
			anim = "glide"
			pitch = -8
			acc = 0.8
		end

		if aerotest.radar_debug then
			temp_show(ang2tgt, 1)
			for i = 1, 10, 1 do
				temp_show({x = truetpos.x, y = truetpos.y + i * 2, z = truetpos.z}, 1)
			end
		end
			mobkit.clear_queue_low(self)

			if ddistance < 25 and deg(alpha) > 35 then
				-- mobkit.make_sound(self, 'cry')
				if realdistance > 1.5 then
					aerotest.lq_fly_aoa(self, 0, deg(alpha), roll, 3.2, 'glide')
				elseif realdistance <= 1.5 then
					self.object:set_velocity({x = 0, y = 0, z = 0})
				end
			else
				aerotest.lq_fly_pitch(self, lift, pitch, roll, acc, anim)
			end

			if realdistance <= 1.5 then
				mobkit.make_sound(self, 'cry')
				local ent = target:get_luaentity()
				if aerotest.radar_debug then minetest.chat_send_all("***GOTCHA***") end
				if target:is_player() then target:set_hp(0) end
				mobkit.hurt(ent, 1000)
				mobkit.heal(self, 100)
				self.hunger = 100
				mobkit.remember(self, "hunger", self.hunger)
				mobkit.remember(self, "xhaust", self.xhaust)
				mobkit.clear_queue_high(self)
				mobkit.clear_queue_low(self)
				return true
			end
	end
	mobkit.queue_high(self, func, property)
end