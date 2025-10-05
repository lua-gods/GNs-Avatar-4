local Skull = require("lib.skull")
local statue = require("auto.statue")



---@type SkullIdentity|{}
local identity = {
	name = "Statue",
	id = "statue",
	modelBlock = statue,
	modelHat = statue,
	modelHud = statue,
	modelItem = statue,
}

Skull.registerIdentity(identity)