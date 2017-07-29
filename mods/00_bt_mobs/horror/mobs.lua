
--arrows
mobs:register_arrow("horror:fireball", {
   visual = "sprite",
   visual_size = {x = 0.5, y = 0.5},
   textures = {"horror_fireball.png"},
   velocity = 8,
   tail = 1, -- enable tail
   tail_texture = "horror_steam.png",

   hit_player = function(self, player)
      player:punch(self.object, 1.0, {
         full_punch_interval = 1.0,
         damage_groups = {fleshy = 3},
      }, nil)
   end,

   hit_mob = function(self, player)
      player:punch(self.object, 1.0, {
         full_punch_interval = 1.0,
         damage_groups = {fleshy = 3},
      }, nil)
   end,

   hit_node = function(self, pos, node)
      self.object:remove()
   end,
})

mobs:register_arrow("horror:fireball_2", {
   visual = "sprite",
   visual_size = {x = 1, y = 1},
   textures = {"horror_fireshot.png"},
   velocity = 8,
   tail = 0, -- enable tail
   tail_texture = "horror_steam.png",

   hit_player = function(self, player)
      player:punch(self.object, 1.0, {
         full_punch_interval = 1.0,
         damage_groups = {fleshy = 2},
      }, nil)
   end,

   hit_mob = function(self, player)
      player:punch(self.object, 1.0, {
         full_punch_interval = 1.0,
         damage_groups = {fleshy = 2},
      }, nil)
   end,

   hit_node = function(self, pos, node)
      self.object:remove()
   end,
})

local destructive = false

--[[
if destructive == true then
mobs:register_arrow("horror:fireball_3", {
   visual = "sprite",
   visual_size = {x = 1, y = 1},
   textures = {"horror_fireshot.png"},
   velocity = 5,
   tail = 1, -- enable tail
   tail_texture = "horror_flame2.png",

   hit_player = function(self, player)
      player:punch(self.object, 1.0, {
         full_punch_interval = 1.0,
         damage_groups = {fleshy = 2},
      }, nil)
   end,

   hit_mob = function(self, player)
      player:punch(self.object, 1.0, {
         full_punch_interval = 1.0,
         damage_groups = {fleshy = 2},
      }, nil)
   end,

   hit_node = function(self, pos, node)
      mobs:explosion(pos, 1, 1, 1)
   end,
})

mobs:register_arrow("horror:rocket", {
   visual = "sprite",
   visual_size = {x = 0.5, y = 0.5},
   textures = {"horror_rocket.png"},
   velocity = 8,
   tail = 1, -- enable tail
   tail_texture = "horror_rocket_smoke.png",

   hit_player = function(self, player)
      player:punch(self.object, 1.0, {
         full_punch_interval = 1.0,
         damage_groups = {fleshy = 3},
      }, nil)
   end,

   hit_mob = function(self, player)
      player:punch(self.object, 1.0, {
         full_punch_interval = 1.0,
         damage_groups = {fleshy = 3},
      }, nil)
   end,

   hit_node = function(self, pos, node)
      mobs:explosion(pos, 2, 1, 1)
   end,
})
else

mobs:register_arrow("horror:fireball_3", {
   visual = "sprite",
   visual_size = {x = 1, y = 1},
   textures = {"horror_fireshot.png"},
   velocity = 3,
   tail = 1, -- enable tail
   tail_texture = "horror_flame2.png",

   hit_player = function(self, player)
      player:punch(self.object, 1.0, {
         full_punch_interval = 1.0,
         damage_groups = {fleshy = 2},
      }, nil)
   end,

   hit_mob = function(self, player)
      player:punch(self.object, 1.0, {
         full_punch_interval = 1.0,
         damage_groups = {fleshy = 2},
      }, nil)
   end,

   hit_node = function(self, pos, node)
      self.object:remove()
   end,
})

mobs:register_arrow("horror:rocket", {
   visual = "sprite",
   visual_size = {x = 0.5, y = 0.5},
   textures = {"horror_rocket.png"},
   velocity = 8,
   tail = 1, -- enable tail
   tail_texture = "horror_rocket_smoke.png",

   hit_player = function(self, player)
      player:punch(self.object, 1.0, {
         full_punch_interval = 1.0,
         damage_groups = {fleshy = 3},
      }, nil)
   end,

   hit_mob = function(self, player)
      player:punch(self.object, 1.0, {
         full_punch_interval = 1.0,
         damage_groups = {fleshy = 3},
      }, nil)
   end,

   hit_node = function(self, pos, node)
      self.object:remove()
   end,
})
end

mobs:register_arrow("horror:fireball_4", {
   visual = "sprite",
   visual_size = {x = 1, y = 1},
   textures = {"horror_plasma.png"},
   velocity = 6,
   tail = 0, -- enable tail
   tail_texture = "horror_steam.png",

   hit_player = function(self, player)
      player:punch(self.object, 1.0, {
         full_punch_interval = 1.0,
         damage_groups = {fleshy = 3},
      }, nil)
   end,

   hit_mob = function(self, player)
      player:punch(self.object, 1.0, {
         full_punch_interval = 1.0,
         damage_groups = {fleshy = 3},
      }, nil)
   end,

   hit_node = function(self, pos, node)
      self.object:remove()
   end,
})
]]--

--mobs, eggs and spawning
mobs:register_mob("horror:hellbaron", {
   type = "monster",
   passive = false,
   attacks_monsters = true,
   damage = 3,
   reach = 2,
   attack_type = "dogshoot",
   shoot_interval = 2.5,
	dogshoot_switch = 2,
	dogshoot_count = 0,
	dogshoot_count_max =5,
   arrow = "horror:fireball_2",
   shoot_offset = 0.5,
   hp_min = 200,
   hp_max = 400,
   armor = 400,
   collisionbox = {-0.5, 0, -0.6, 0.6, 3, 0.6},
   visual = "mesh",
   mesh = "hellbaron.b3d",
   textures = {
      {"horror_hellbaron.png"},
   },
   blood_amount = 80,
   blood_texture = "horror_blood_effect.png",
   visual_size = {x=1, y=1},
   makes_footstep_sound = true,
   walk_velocity = 2,
   run_velocity = 3.5,
   jump = true,
   drops = {
      {name = "moreores:mithril_block", chance = 1, min = 1, max = 5},
	  {name = "mobs:lava_orb", chance = 1, min = 1, max = 1},
   },
   water_damage = 0,
   lava_damage = 0,
   light_damage = 0,
   view_range = 20,
   animation = {
      speed_normal = 10,
      speed_run = 20,
      walk_start = 51,
      walk_end = 75,
      stand_start = 1,
      stand_end = 25,
      run_start = 51,
      run_end = 75,
      punch_start = 25,
      punch_end = 50,
	  shoot_start = 25,
	  shoot_end = 50,
   },
})

mobs:register_spawn("horror:hellbaron", {"underworlds:hot_cobble"}, 20, 0, 15000, 2, -5800)
mobs:register_spawn("horror:hellbaron", {"default:obsidian"}, 20, 0, 1000, 1, -19800)

--mobs:register_egg("horror:hellbaron", "Hell Baron", "default_dirt.png", 1)

--[[mobs:register_mob("horror:dragon", {
   type = "monster",
   passive = false,
   attacks_monsters = true,
   damage = 8,
   reach = 3,
   attack_type = "dogshoot",
   shoot_interval = 3.5,
   arrow = "horror:fireball",
   shoot_offset = 1,
   hp_min = 50,
   hp_max = 85,
   armor = 90,
   collisionbox = {-0.6, -0.9, -0.6, 0.6, 0.6, 0.6},
   visual = "mesh",
   mesh = "dragon_new.b3d",
   textures = {
      {"horror_dragon.png"},
   },
   blood_amount = 90,
   blood_texture = "horror_blood_effect.png",
   visual_size = {x=3, y=3},
   makes_footstep_sound = true,
   sounds = {
      shoot_attack = "mobs_fireball",
   },
   walk_velocity = 3,
   run_velocity = 5,
   jump = true,
   fly = true,
   drops = {
      {name = "mobs:lava_orb", chance = 2, min = 1, max = 3},
      {name = "default:diamond", chance = 2, min = 1, max = 3},
   },
   fall_speed = 0,
   stepheight = 10,
   water_damage = 2,
   lava_damage = 0,
   light_damage = 0,
   view_range = 20,
   animation = {
      speed_normal = 10,
      speed_run = 20,
      walk_start = 1,
      walk_end = 22,
      stand_start = 1,
      stand_end = 22,
      run_start = 1,
      run_end = 22,
      punch_start = 22,
      punch_end = 47,
   },
})

mobs:register_spawn("horror:dragon", {"default:pine_needles",}, 20, 0, 35000, 200, 31000)

mobs:register_egg("horror:dragon", "Zombie Dragon", "horror_orb.png", 1)
]]--
