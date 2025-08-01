local Skull = require("lib.skull")
local Color = require("lib.color")

local MAX_STACK_SIZE = 32

function hash(str)
	local hash = 0
	for i = 1, #str do
		local c = str:byte(i)
		hash = (hash * math.pi + c) % 100000 -- keep it within 5 digits
	end
	return hash
end


models.skull.hat:scale(1.1,1.1,1.1)

---@type SkullIdentity|{}
local identity = {
	name = "macaroni",
	modelBlock = models.cappie.hat,
	modelHat = models.cappie.hat,
	modelHud = Skull.makeIcon(models.cappie.icon),
	modelItem = models.cappie.hat,
}

identity.processEntity ={
	ON_PROCESS = function (skull, model, delta)
		for i = 1, 4000, 1 do
			vec(0,0,0,0)
		end
	end
}




Skull.registerIdentity(identity)