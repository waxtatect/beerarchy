ranks = {}

--
-- 10001 * 2  = 20000			hunter
-- 10001 * 1  = 10000			farmer
-- 5001  * 2  = 10000			miner
-- 2001  * 10 = 20000 = 60k		builder

-- 28000 * 1  = 28000			traveler
-- 20001 * 3  = 60000 = 148k	mountaineer

-- 5001  * 4  = 20000 = 168k	caving

-- 1000  * 7  = 7000  = 175k	intelligence

-- 175000 / 1000 = 175

-- Overall experience rank based on time on server
-- and other points

-- 20000 * 2  20000   20000 * 2   20000 * 10   30000   25000 * 3   24000 * 4   5000 * 7
-- 40000      20000   40000       200000       30000   75000       96000       35000     = 350000
--
ranks["experience"] = {
	code = "experience",
	name = "Experience",
	index = 1,
	levels = {
		{ min = 0,    max = 1,     name = "Baby"},				-- +1
		{ min = 2,    max = 4,     name = "N00b"},				-- +2
		{ min = 5,    max = 9,     name = "Newfag"},			-- +4
		{ min = 10,   max = 16,    name = "Mostly harmless"},	-- +6
		{ min = 17,   max = 25,    name = "Outsider"},			-- +8
		{ min = 26,   max = 36,    name = "Familiar face"},		-- +10
		{ min = 37,   max = 49,    name = "Local"},				-- +12
		{ min = 50,   max = 66,    name = "Oldfag"},			-- +16
		{ min = 67,   max = 87,    name = "Vetrain"},			-- +20
		{ min = 88,   max = 112,   name = "Elder"},				-- +24
		{ min = 113,  max = 141,   name = "The great"},			-- +28
		{ min = 142,  max = 174,   name = "Ancient one"},		-- +32
		{ min = 175,  max = 215,   name = "Legendary"},			-- +40
		{ min = 216,  max = 264,   name = "Demi god"},			-- +48
		{ min = 265,  max = 346,   name = "God"},				-- +82
		{ min = 347,  max = 460,   name = "Titan"},				-- +114
		{ min = 461,  max = 999,   name = "Primordial Being"},
		{ min = 1000, max = 1600,  name = "Chaos"},
		{ min = 1601, max = 1703,  name = "Of Unknown Origin"},
		{ min = 1704, max = 65535, name = "The True Definition of Cheater"},
	}
}
ranks[1] = ranks["experience"]

-- Number of mobs (monsters or animals) killed
ranks["hunter"] = {
	code = "hunter",
	name = "Hunting",
	index = 2,
	weight = 10,
	levels = {
		{ min = 0,     max = 50,    name = "Annoying vegan"},
		{ min = 51,    max = 100,   name = "Clumsy"},
		{ min = 101,   max = 200,   name = "Chaser"},
		{ min = 201,   max = 500,   name = "Trapper"},
		{ min = 501,   max = 1000,  name = "Ranger"},
		{ min = 1001,  max = 2000,  name = "Master of the hunt"},
		{ min = 2001,  max = 5000,  name = "Bird of prey"},
		{ min = 5001,  max = 10000, name = "Carnivorous predator"},
		{ min = 10001, max = 20000, name = "Dread of the beast"},
		{ min = 20001, max = 65535, name = "Terror of all that is living"},
	}
}
ranks[2] = ranks["hunter"]

-- Number of crops planted and harvested
ranks["farmer"] = {
	code = "farmer",
	name = "Farming",
	index = 3,
	weight = 1,
	levels = {
		{ min = 0,     max = 200,   name = "Herbicide"},
		{ min = 201,   max = 500,   name = "Fertilizer"},
		{ min = 501,   max = 1000,  name = "Serf"},
		{ min = 1001,  max = 2000,  name = "Peasant"},
		{ min = 2001,  max = 5000,  name = "Farmer"},
		{ min = 5001,  max = 10000, name = "Agricultural wizard"},
		{ min = 10001, max = 20000, name = "Biosphere engineer"},
		{ min = 20001, max = 65535, name = "Terraformer"},
	}
}
ranks[3] = ranks["farmer"]

-- Number of non-plant nodes dug
ranks["miner"] = {
	code = "miner",
	name = "Mining",
	index = 4,
	weight = 2,
	levels = {
		{ min = 0,     max = 500,   name = "Booger"},
		{ min = 501,   max = 1000,  name = "Pothole"},
		{ min = 1001,  max = 2000,  name = "Miner"},
		{ min = 2001,  max = 5000,  name = "Demolition man"},
		{ min = 5001,  max = 10000, name = "Human drill"},
		{ min = 10001, max = 20000, name = "The Rock"},
		{ min = 20001, max = 65535, name = "Digtron master"},
	}
}
ranks[4] = ranks["miner"]

-- Number of non-plant nodes placed
ranks["builder"] = {
	code = "builder",
	name = "Building",
	index = 5,
	weight = 10,
	levels = {
		{ min = 0,     max = 200,   name = "Stick stacker"},
		{ min = 201,   max = 500,   name = "Mud hut maker"},
		{ min = 501,   max = 1000,  name = "Carpenter"},
		{ min = 1001,  max = 2000,  name = "Mason"},
		{ min = 2001,  max = 5000,  name = "Civil engineer"},
		{ min = 5001,  max = 10000, name = "Architect"},
		{ min = 10001, max = 20000, name = "Grand visionary"},
		{ min = 20001, max = 65535, name = "Monumental builder"},
	}
}
ranks[5] = ranks["builder"]

-- Distance from spawn (x=0,z=0) traveled
ranks["traveler"] = {
	code = "traveler",
	name = "Traveling",
	index = 6,
	weight = 1,
	levels = {
		{ min = 0,     max = 800,   name = "Hermit"},
		{ min = 801,   max = 1600,  name = "Homesick"},
		{ min = 1601,  max = 2400,  name = "Errands runner"},
		{ min = 2401,  max = 5000,  name = "Hiker"},
		{ min = 5001,  max = 10000, name = "Traveler"},
		{ min = 10001, max = 20000, name = "Nomad"},
		{ min = 20001, max = 30000, name = "Cosmopolitan"},
		{ min = 30001, max = 65535, name = "Ecumenopolitan"},
	}
}
ranks[6] = ranks["traveler"]

-- Highest elevation/ altitude reached from z=0
ranks["mountaineer"] = {
	code = "mountaineer",
	name = "Mountaineering",
	index = 7,
	weight = 3,
	levels = {
		{ min = 0,     max = 100,   name = "Acrophobe"},
		{ min = 101,   max = 200,   name = "Puddle jumper"},
		{ min = 201,   max = 500,   name = "Tree climber"},
		{ min = 501,   max = 1000,  name = "Scrambler"},
		{ min = 1001,  max = 2000,  name = "Mountaineer"},
		{ min = 2001,  max = 5000,  name = "Alpinist"},
		{ min = 5001,  max = 10000, name = "Cosmonaut"},
		{ min = 10001, max = 15000, name = "Astronaut"},
		{ min = 15001, max = 20000, name = "Galactic explorer"},
		{ min = 20001, max = 25000, name = "Master of the Universe"},
		{ min = 25001, max = 65535, name = "Emperor of the Multiverse"},
	}
}
ranks[7] = ranks["mountaineer"]

-- Lowest depth reached from z=0
ranks["caving"] = {
	code = "caving",
	name = "Caving",
	index = 8,
	weight = 4,
	levels = {
		{ min = 0,     max = 200,   name = "Afraid of the dark"},
		{ min = 201,   max = 500,   name = "Caveman"},
		{ min = 501,   max = 1000,  name = "Spelunkologist"},
		{ min = 1001,  max = 2000,  name = "Returned from the dead"},
		{ min = 2001,  max = 6000,  name = "Satan's pall"},
		{ min = 6001,  max = 12000, name = "Hellraiser"},
		{ min = 12001, max = 24000, name = "Monster of the deep"},
		{ min = 24001, max = 65535, name = "Lord of the Inferno"},
	}
}
ranks[8] = ranks["caving"]

-- Intelligence for construction of certain items
ranks["intelligence"] = {
	code = "intelligence",
	name = "Intelligence",
	index = 9,
	weight = 7,
	levels = {
		{ min = 0,      max = 50,    name = "Retard"},
		{ min = 51,     max = 100,   name = "Preschooler"},
		{ min = 101,    max = 150,   name = "Student"},
		{ min = 151,    max = 200,   name = "Graduate"},
		{ min = 201,    max = 400,   name = "Professor"},
		{ min = 401,    max = 600,   name = "Megamind"},
		{ min = 601,    max = 800,   name = "Bionic Brain"},
		{ min = 801,    max = 1000,  name = "Oracle of Wisdom"},
		{ min = 1001,   max = 5000,  name = "Master of Machinery"},
		{ min = 5001,   max = 65535, name = "Uomo Universalis"},
	}
}
ranks[9] = ranks["intelligence"]
