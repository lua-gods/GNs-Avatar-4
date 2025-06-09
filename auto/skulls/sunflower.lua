local Skull = require("lib.skull")


function hash(str)
	local hash = 0
	for i = 1, #str do
		local c = str:byte(i)
		hash = (hash * math.pi + c) % 100000 -- keep it within 5 digits
	end
	return hash
end

local SCALE = 0.8


animations.sunflower.idle:speed(0.5):play()

---@type SkullIdentity|{}
local identity = {
	name = "Sunflower",
	support = "minecraft:flower_pot",
	modelBlock = {models.sunflower.blocko:scale(SCALE,SCALE,SCALE):setPos(0,-10,0)},
	modelHat = {models.sunflower.blocko},
	modelHud = {models.sunflower.blocko},
	modelItem = {models.sunflower.blocko},
	
	processHat = {
		ON_ENTER = function (skull, model)
			model:setPos(0,8,0):scale(0.6,0.6,0.6)
		end
	},
	processHud = {
		ON_ENTER = function (skull, model)
			model:rot(50,-45,0):pos(0,-4,0)
		end
	},
	processEntity = {
		ON_ENTER = function (skull, model)
			if skull.isHand then
				model:setPos(0,0,0):scale(0.5,0.5,0.5)
			else
				model:setPos(0,0,0)
			end
		end
	}
}

Skull.registerIdentity(identity)