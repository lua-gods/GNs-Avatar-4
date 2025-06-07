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


local SCALE = 0.845

models.cappie.hat:scale(SCALE,SCALE,SCALE)


---@type SkullIdentity|{}
local identity = {
	name = "Cappie",
	modelBlock = models.cappie.hat,
	modelHat = models.cappie.hat,
	modelHud = Skull.makeIcon(models.cappie.icon),
	modelItem = models.cappie.hat,
	
	processHat = {
		ON_ENTER = function (skull, model)
		end
	}
}

Skull.registerIdentity(identity)