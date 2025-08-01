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

local dark = Color.parseColor("#00396d").rgb
local default = Color.parseColor("#5ac54f").rgb

---@return Vector3
local function shade(clr,w)
---@diagnostic disable-next-line: return-type-mismatch
	return math.lerp(dark,clr,w)
end




---@type SkullIdentity|{}
local identity = {
	name = "default",
	modelBlock = models.skull.block,
	modelHat = models.skull.hat,
	modelHud = Skull.makeIcon(models.skull.icon),
	modelItem = models.skull.entity
}


identity.processHat = {
---@param skull SkullInstanceHat
---@param model ModelPart
ON_ENTER = function (skull, model)
end,

---@param skull SkullInstanceHat
---@param model ModelPart
ON_PROCESS = function (skull, model,delta)
	local vars = skull.vars
	local height = vars.hatHeight or 1
	local color = vars.color and Color.parseColor(vars.color).xyz or default
	model.cylinder:setScale(1,height,1)
	for i = 1, 4, 1 do
		model.ribbon["shade"..i]:setColor(shade(color,i/4))
	end
end,

---@param skull SkullInstanceHat
---@param model ModelPart
ON_EXIT = function (skull, model)
	
end}



Skull.registerIdentity(identity)