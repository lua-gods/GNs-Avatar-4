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

models.fez.hat:scale(SCALE,SCALE,SCALE)


---@type SkullIdentity|{}
local identity = {
	name = "fez",
	modelBlock = models.fez.hat,
	modelHat = models.fez.hat,
	modelHud = Skull.makeIcon(models.fez.icon),
	modelItem = models.fez.hat,
	
	processHat = {
		ON_ENTER = function (skull, model)
		end
	}
}

Skull.registerIdentity(identity)