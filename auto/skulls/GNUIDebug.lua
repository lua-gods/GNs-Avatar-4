local Skull = require("lib.skull")

if not host:isHost() then return end

local GNUI = require("lib.GNUI.main")

---@type SkullIdentity|{}
local identity = {
	name = "GNUI (Debug)",
	id = "gnui",
	modelHat = models.skull.glasses,
	modelHud = Skull.makeIcon(textures["textures.item_icons"],2,1),
	modelEntity = models.skull.glasses,
	
	processBlock = {
		ON_READY = function (skull, model)
			local shadow = GNUI:getScreen().ModelPart:copy("lel"):setParentType("NONE")
			shadow:moveTo(model)
		end
	}
}

Skull.registerIdentity(identity)