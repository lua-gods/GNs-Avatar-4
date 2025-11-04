---@diagnostic disable: param-type-mismatch
local Skull = require("lib.skull")
local Color = require("lib.color")



---@type SkullIdentity|{}
local identity = {
	name = "Default",
	id = {"default","tophat"},
	modelBlock = models.skull.plushie.block,
	modelHat = models.skull.plushie.hat,
	modelHud = Skull.toIcon(models.skull.plushie.icon),
	modelEntity = models.skull.plushie.entity,
}

--[────────────────────────-< Hat >-────────────────────────]--

local COLOR_AMBIENT = Color.parseColor("#00396d").rgb
local COLOR_ALBEDO = Color.parseColor("#5ac54f").rgb
local COLOR_SPECULAR = Color.parseColor("#ffffff").rgb
models.skull.plushie.hat:scale(1.1, 1.1, 1.1)

identity.processHat = {
	ON_PROCESS = function(skull, model, delta)
		local vars = skull.vars
		local height = vars.hatHeight or skull.params.height or 8
		local color
		
		if skull.params.color then
			local ok, value = pcall(Color.parseColor,skull.params.color)
			color = ok and value.xyz or COLOR_ALBEDO
		else
			if vars.color then
				local ok, value = pcall(Color.parseColor,vars.color)
				color = ok and value.xyz or COLOR_ALBEDO
			else
				color = COLOR_ALBEDO
			end
		end
		
		model.cylinder:setScale(1, height, 1)
		model.top:setPos(0, height, 0)
		model.ribbon.shade1:setColor(math.lerp(color, COLOR_AMBIENT,0.5))
		model.ribbon.shade2:setColor(math.lerp(color, COLOR_AMBIENT,0.25))
		model.ribbon.shade3:setColor(color)
		model.ribbon.shade4:setColor(math.lerp(color, COLOR_SPECULAR,0.25))
		model.ribbon.shade5:setColor(math.lerp(color, COLOR_SPECULAR,0.5))
	end,
	
	ON_EXIT = function(skull, model)
	end
}

identity.processHud = {
	ON_PROCESS = function(skull, model, delta)
		local height = (skull.params.height or 8)-5
		local color
		
		if skull.params.color then
			local ok, value = pcall(Color.parseColor,skull.params.color)
			color = ok and value.xyz or COLOR_ALBEDO
		else
			color = COLOR_ALBEDO
		end
		model.top:setPos(0, height, 0)
		model.middle:setScale(1, height+2, 1)
		model.band:setColor(color)
	end
}

--[────────────────────────-< Block >-────────────────────────]--

local SIT_OFFSET = vec(0, -8, -2) -- where should plushie move when its placed on stairs
local VEC2HALF = vec(0.5, 0.5)

identity.processBlock = {
	ON_INIT = function(skull, model)
		local floor = skull.support
		if not skull.isWall then
			if floor.id:find("stairs$") and floor.properties and floor.properties.half == "bottom" then
				model:setPos(SIT_OFFSET)
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
