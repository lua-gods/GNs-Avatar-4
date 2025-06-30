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


local SCALE = 0.9

models.sunglasses.hat:scale(SCALE,SCALE,SCALE)


---@type SkullIdentity|{}
local identity = {
	name = "Sunglasses",
	modelBlock = models.sunglasses.hat,
	modelHat = models.sunglasses.hat,
	modelHud = Skull.makeIcon(models.sunglasses.icon),
	modelItem = models.sunglasses.hat,
	
	processHat = {
		ON_ENTER = function (skull, model)
			model:setPos(0,skull.vars.eye_height or skull.params[1] or 2)
		end
	}
}

Skull.registerIdentity(identity)