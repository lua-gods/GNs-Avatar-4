local Skull = require("lib.skull")

local source = require("auto.statue")

source.Base.Torso.Head.Face.Leye.LPupil:setUVPixels(-0.6,0)
source.Base.Torso.Head.Face.Reye.RPupil:setUVPixels(0.6,0)

local function hash(str)
	local hash = 0
	for i = 1, #str do
		local c = str:byte(i)
		hash = (hash * math.pi + c) % 100000 -- keep it within 5 digits
	end
	return hash
end


require("lib.animation")

local speed = 120 / 120

local danceByID = {}
local danceByName = {}

for key, value in pairs(animations:getAnimations()) do
	local name = value:getName()
	if name:find("^Dance") then
	danceByName[name] = value
	danceByID[#danceByID+1] = name
	end
end

---@type SkullIdentity|{}
local identity = {
	support = "minecraft:crimson_planks",
	name = "Statue Emotes",
	id = "statue_dance",
	modelBlock = source,
	modelHat = source,
	modelHud = source,
	modelItem = source,
	
	processBlock = {
		ON_READY = function (skull, model)
			model:setParentType("SKULL")
			model:play("player."..danceByID[math.floor(hash(skull.pos:toString()) * 100) % #danceByID + 1])
			model:setSpeed(speed)
		end,
		ON_EXIT = function (skull, model)
			model:stop()
		end
	}
}

local processETC = {
	---comment
	---@param skull SkullInstance
	---@param model ModelPart
	ON_INIT = function (skull, model)
		
		local name = skull.params[1]
		model:setParentType("SKULL")
		if danceByName[name] then
			model:play("player."..name)
		else
			model:play("player."..danceByID[3])
		end
		
		model:setSpeed(speed)
	end,
	ON_EXIT = function (skull, model)
		model:stop()
	end
}

identity.processHud = processETC
identity.processHat = processETC
identity.processEntity = processETC

Skull.registerIdentity(identity)