local Skull = require("lib.skull")
local Color = require("lib.color")


local SCALE = 0.845

models.fez.hat:scale(SCALE,SCALE,SCALE)


---@type SkullIdentity|{}
local identity = {
	name = "Fez Hat",
	id = "fez",
	modelBlock = models.fez.hat,
	modelHat = models.fez.hat,
	modelHud = Skull.makeIcon(textures["textures.item_icons"],1,0),
	modelItem = models.fez.hat,
	
	processHat = {
		ON_ENTER = function (skull, model)
		end
	}
}

Skull.registerIdentity(identity)