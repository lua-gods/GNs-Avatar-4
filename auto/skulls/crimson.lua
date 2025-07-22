local Skull = require("lib.skull")

local source = models.player:copy("playerClone")


function hash(str)
	local hash = 0
	for i = 1, #str do
		local c = str:byte(i)
		hash = (hash * math.pi + c) % 100000 -- keep it within 5 digits
	end
	return hash
end



---@param modelPart ModelPart
---@param func fun(modelPart:ModelPart)
local function apply(modelPart,func)
	func(modelPart)
	for _, child in ipairs(modelPart:getChildren()) do
		apply(child,func)
	end
end

require("lib.animation")

local speed = 120 / 120

local dances = {}

for key, value in pairs(animations:getAnimations()) do
	local name = value:getName()
	if name:find("^Dance") then
		dances[#dances+1] = name
	end
end

---@type SkullIdentity|{}
local identity = {
	support = "minecraft:crimson_planks",
	name = "Cappie",
	modelBlock = source,
	modelHat = models.cappie.hat,
	modelHud = Skull.makeIcon(models.cappie.icon),
	modelItem = models.cappie.hat,
	
	processBlock = {
		ON_ENTER = function (skull, model)
			apply(model, function (modelPart)
				modelPart:setParentType("None")
			end)
			model:setParentType("SKULL")
			model:play("player."..dances[math.floor(hash(skull.pos:toString()) * 100) % #dances + 1])
			model:setSpeed(speed)
		end,
		ON_EXIT = function (skull, model)
			model:stop()
		end
	}
}

Skull.registerIdentity(identity)