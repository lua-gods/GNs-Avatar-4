local Skull = require("lib.skull")
local statue = require("auto.statue")



---@type SkullIdentity|{}
local identity = {
	name = "Statue",
	id = "statue",
	modelBlock = statue,
	modelHat = statue,
	modelHud = statue,
	modelEntity = statue,
}

Skull.registerIdentity(identity)