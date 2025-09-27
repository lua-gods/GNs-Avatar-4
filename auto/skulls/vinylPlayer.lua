local Skull = require("lib.skull")
local Color = require("lib.color")

local NBS = require("lib.nbs")
local Tween = require("lib.tween")

---@type SkullIdentity|{}
local identity = {
	name = "Vinyl Record Player",
	id = "vinyl_player",
	support="minecraft:jukebox",
	modelBlock = models.vinyl_record_player,
	modelHat = models.vinyl_record_player,
	modelHud = models.vinyl_record_player,
	modelItem = models.vinyl_record_player,
}


function identity.playSong()
	
end


Skull.registerIdentity(identity)
