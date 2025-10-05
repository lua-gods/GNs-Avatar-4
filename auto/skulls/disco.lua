local Skull = require("lib.skull")

local SCALE = 10
local source = models.disco:scale(SCALE,SCALE,SCALE)--:setOpacity(0.3)
source:setPrimaryRenderType("EYES")

require("lib.animation")

---@type SkullIdentity|{}
local identity = {
	support = "minecraft:note_block",
	name = "Disco Ball",
	id = "disco",
	modelBlock = source,
	modelHat = source,
	modelHud = Skull.makeIcon(textures["textures.item_icons"],3,1),

	processBlock = {
		ON_INIT = function (skull, model)
			local beams = {}
			for i = 1, skull.params.count or 5, 1 do
				local beam = model.Beam:copy("beam#"..i):setColor(math.random(),math.random(),math.random())
				beams[i] = beam

				beam:play("disco.loop")
				local rot = vec(math.random(0,360),math.random(0,360),math.random(0,360))
				beam:setRot(rot)
				model:addChild(beam)
			end
			skull.beams = beams
		end
	}
}
identity.processHat = {ON_READY = identity.processBlock.ON_READY}

Skull.registerIdentity(identity)