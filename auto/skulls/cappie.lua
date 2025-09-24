local Skull = require("lib.skull")
local Color = require("lib.color")


local SCALE = 0.845

models.cappie.hat:scale(SCALE,SCALE,SCALE)


---@type SkullIdentity|{}
local identity = {
	name = "cappie",
	modelBlock = models.cappie.hat,
	modelHat = models.cappie.hat,
	modelHud = Skull.makeIcon(textures["textures.item_icons"],0,0),
	modelItem = models.cappie.hat,
	
	processHat = {
		ON_ENTER = function (skull, model)
		end
	}
}

Skull.registerIdentity(identity)