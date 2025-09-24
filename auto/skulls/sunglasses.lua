local Skull = require("lib.skull")
local Color = require("lib.color")



local SCALE = 0.9

models.sunglasses.hat:scale(SCALE,SCALE,SCALE)


---@type SkullIdentity|{}
local identity = {
	name = "sunglasses",
	modelBlock = models.sunglasses.hat,
	modelHat = models.sunglasses.hat,
	modelHud = Skull.makeIcon(textures["textures.item_icons"],2,0),
	modelItem = models.sunglasses.hat,
	
	processHat = {
		ON_ENTER = function (skull, model)
			model:setPos(0,tonumber(skull.params[1] or skull.vars.eye_height) or 2)
		end
	}
}

Skull.registerIdentity(identity)