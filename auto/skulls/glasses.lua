local Skull = require("lib.skull")
local Color = require("lib.color")


function hash(str)
	local hash = 0
	for i = 1, #str do
		local c = str:byte(i)
		hash = (hash * math.pi + c) % 100000 -- keep it within 5 digits
	end
	return hash
end


local SCALE = 0.85
models.glasses.hat:scale(SCALE,SCALE,SCALE)


---@type SkullIdentity|{}
local identity = {
	name = "glasses",
	modelHat = models.glasses.hat,
	modelHud = Skull.makeIcon(models.glasses.icon),
	modelItem = models.glasses.hat,
	
	processHat = {
		ON_ENTER = function (skull, model)
			local ok,value = pcall(tonumber,skull.params[1] or skull.vars.eye_height)
			model:setPos(0,ok and value or 2)
		end,
		ON_PROCESS = function (skull, model, delta)
			local cpos = vectors.toCameraSpace(skull.matrix:apply(0,0,0))
			local shift = (-cpos.x-cpos.y)*2
			model.Lens:setUV(0,shift)
		end
	}
}

Skull.registerIdentity(identity)