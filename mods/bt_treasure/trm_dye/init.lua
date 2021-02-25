local colors = dye.dyes
for i = 1, #colors do
	treasurer.register_treasure("dye:"..colors[i][1], 0.0117, 1, {1, 6}, nil, "crafting_component")
end