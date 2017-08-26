local S
if minetest.get_modpath("intllib") then
	S = intllib.Getter(minetest.get_current_modname())
else
	S = function(s) return s end
end

minetest.register_craftitem("doc_encyclopedia:encyclopedia", {
	description = S("Encyclopedia"),
	_doc_items_longdesc = S("Allows you to access the help."),
	_doc_items_usagehelp = S("Wield it, then leftclick to access the help."),
	_doc_items_hidden = false,
	stack_max = 1,
	inventory_image = "doc_encyclopedia_encyclopedia.png",
	wield_image = "doc_encyclopedia_encyclopedia.png",
	wield_scale = { x=1, y=1, z=2.25 },
	on_use = function(itemstack, user)
		doc.show_doc(user:get_player_name())
	end,
	groups = { book=1 },
})

minetest.register_craft({
	output = "doc_encyclopedia:encyclopedia",
	recipe = {
		{"group:stick", "group:stick", ""},
		{"group:stick", "", "group:stick"},
		{"group:stick", "group:stick", ""},
	}
})

-- Bonus recipe for Minetest Game
if minetest.get_modpath("default") then
	minetest.register_craft({
		output = "doc_encyclopedia:encyclopedia",
		recipe = {
			{ "default:book" },
			{ "default:book" },
			{ "default:book" },
		}
	})
end

minetest.register_craft({
	type = "fuel",
	recipe = "doc_encyclopedia:encyclopedia",
	burntime = 6,
})
