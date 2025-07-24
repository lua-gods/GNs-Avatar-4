local modelBase = models:newPart("skullHandler","SKULL")
local blockTask = modelBase:newBlock("dirt"):block("dirt"):pos(-4,0,-4):scale(0.5)


local renderInstances = {}
local firstRender = false


events.WORLD_RENDER:register(function (delta)
	firstRender = true
end)


events.SKULL_RENDER:register(function (delta, block, item, entity, ctx)
	if firstRender then
		renderInstances = {}
		firstRender = false
	end
	local type = block and 0 or ctx == "HEAD" and 1 or 2
	blockTask:block(({"diamond_block","emerald_block","gold_block","iron_block"})[type+1])
	renderInstances[#renderInstances+1] = {}
end)