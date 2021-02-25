integral = {}
integral.version = "1.0"

integral.path = minetest.get_modpath("integral")


function integral.table_copy(orig)
	local orig_type = type(orig)
	local copy_t
	if orig_type == 'table' then
		copy_t = {}
		for orig_key, orig_value in next, orig, nil do
			copy_t[integral.table_copy(orig_key)] = integral.table_copy(orig_value)
		end
		setmetatable(copy_t, integral.table_copy(getmetatable(orig)))
	else -- number, string, boolean, etc
		copy_t = orig
	end
	return copy_t
end


dofile(integral.path .. "/nodes.lua")
dofile(integral.path .. "/mapgen.lua")
dofile(integral.path .. "/integrites.lua")

minetest.register_on_generated(integral.generate)

