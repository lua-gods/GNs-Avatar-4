local Skull = require("lib.skull")
local Color = require("lib.color")

models.skull.hat:scale(1.1, 1.1, 1.1)


local dark = Color.parseColor("#00396d").rgb
local default = Color.parseColor("#5ac54f").rgb

---@return Vector3
local function shade(clr, w)
	---@diagnostic disable-next-line: return-type-mismatch
	return math.lerp(dark, clr, w)
end


--[[@@@

if block.id == "minecraft:player_head" then
	if floor.id:match("stairs") and floor.properties and floor.properties.half == "bottom" then
		model:setPos(sitOffset)
	else
		local pos = 0
		local shape = floor:getOutlineShape()
		for _, v in ipairs(shape) do
			if v[1].xz <= vec2Half and v[2].xz >= vec2Half then
				pos = math.max(pos, v[2].y)
			end
		end
		if #shape >= 1 then
			model:setPos(0, pos * 16 - 16, 0)
		else
			model:setPos(0, 0, 0)
		end
	end
else
	model:setPos(0, 0, 0)
end

--]]


---@type SkullIdentity|{}
local identity = {
	name = "hathat",
	modelBlock = models.skull.hat,
	modelHat = models.skull.hat,
	modelHud = models.skull.hat,
	modelItem = models.skull.hat,
}

local sitOffset = vec(0, -8, -2) -- where should plushie move when its placed on stairs
local VEC2HALF = vec(0.5, 0.5)

identity.processEntity = {
	ON_ENTER = function(skull, model, delta)
		local color = default
		model.cylinder:setScale(1, 1, 1)
		for i = 1, 4, 1 do
			model.ribbon["shade" .. i]:setColor(shade(color, i / 4))
		end
	end,
	
	ON_EXIT = function(skull, model)
	end
}
identity.processBlock = identity.processEntity
identity.processHat = identity.processEntity
identity.processHud = identity.processEntity


Skull.registerIdentity(identity)
