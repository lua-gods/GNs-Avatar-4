local Skull = require("lib.skull")
local Color = require("lib.color")


local SCALE = 0.845

models.cappie.hat:scale(SCALE,SCALE,SCALE)


---@type SkullIdentity|{}
local identity = {
	name = "Cappie",
	id = "cappie",
	modelBlock = models.cappie.hat,
	modelHat = models.cappie.hat,
	modelHud = Skull.makeIcon(textures["textures.item_icons"],0,0),
	modelEntity = models.cappie.hat,
}

Skull.registerIdentity(identity)