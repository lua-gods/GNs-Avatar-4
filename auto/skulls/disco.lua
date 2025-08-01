local Skull = require("lib.skull")

local SCALE = 10
local source = models.disco:scale(SCALE,SCALE,SCALE)--:setOpacity(0.3)
source:setPrimaryRenderType("EYES")

require("lib.animation")

---@type SkullIdentity|{}
local identity = {
	support = "minecraft:note_block",
	name = "cappie",
	modelBlock = source,

	processBlock = {
		ON_ENTER = function (skull, model)
			local beams = {}
			for i = 1, 5, 1 do
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

Skull.registerIdentity(identity)