local Skull = require("lib.skull")
local Color = require("lib.color")



local SCALE = 0.85
models.glasses.hat:scale(SCALE,SCALE,SCALE)


local DEFAULT_TINT = vectors.hexToRGB("#c7cfdd")

---@type SkullIdentity|{}
local identity = {
	name = "Glasses",
	id = "glasses",
	modelHat = models.glasses.hat,
	modelHud = Skull.makeIcon(textures["textures.item_icons"],2,1),
	modelItem = models.glasses.hat,
	
	processHat = {
		ON_ENTER = function (skull, model)
			local ok,value = pcall(tonumber,skull.params[1] or skull.vars.eye_height)
			model:setPos(0,ok and value or 2)
			
			local color
			if skull.vars.color then
				local ok, value = pcall(Color.parseColor,skull.vars.glasses_tint)
				color = ok and value.xyz or DEFAULT_TINT
			else
				color = DEFAULT_TINT
			end
			model.Glass:setColor(color)
			model.Lens:setColor((color-1)*0.5+1)
		end,
		ON_PROCESS = function (skull, model, delta)
			local crot = client:getCameraRot()
			local shift = -(crot.y / 360)*10 - crot.x / 30
			model.Lens:setUV(0,shift)
		end
	}
}

Skull.registerIdentity(identity)