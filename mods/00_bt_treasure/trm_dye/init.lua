local colors = {"white", "grey", "black", "red", "orange", "yellow", "lime", "green", "aqua", "cyan", "sky_blue", "blue", "violet", "magenta"}
for i=1,#colors do
	treasurer.register_treasure("dye:"..colors[i], 0.0117, 1, {1,6}, nil, "crafting_component" )
end
