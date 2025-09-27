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
	name = "Default",
	id = "default",
	modelBlock = models.skull.block,
	modelHat = models.skull.hat,
	modelHud = Skull.makeIcon(textures["textures.item_icons"],1,1),
	modelItem = models.skull.entity,
}

local sitOffset = vec(0, -8, -2) -- where should plushie move when its placed on stairs
local VEC2HALF = vec(0.5, 0.5)

identity.processHat = {
	ON_PROCESS = function(skull, model, delta)
		local vars = skull.vars
		local height = vars.hatHeight or 0.6
		local color
		if vars.color then
			local ok, value = pcall(Color.parseColor,vars.color)
			color = ok and value.xyz or default
		else
			color = default
		end
		model.cylinder:setScale(1, height, 1)
		for i = 1, 4, 1 do
			model.ribbon["shade" .. i]:setColor(shade(color, i / 4))
		end
	end,
	
	ON_EXIT = function(skull, model)
	end
}

identity.processBlock = {
	ON_ENTER = function(skull, model)
		local floor = skull.support
		if not skull.isWall then
			if floor.id:find("stairs$") and floor.properties and floor.properties.half == "bottom" then
				model:setPos(sitOffset)
			elseif not floor.id:find("player_head$") then
				local pos = 0
				local shape = floor:getOutlineShape()
				for _, v in ipairs(shape) do
					if v[1].xz <= VEC2HALF and v[2].xz >= VEC2HALF then
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
	end,
}



Skull.registerIdentity(identity)
