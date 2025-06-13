local Skull = require("lib.skull")


local Tween = require("lib.tween")

local S = 1/16
local SCALE = 4

local oldTween = require("lib.oldTween")

---@type SkullIdentity|{}
local identity = {
	name = "Sunflower",
	support = "minecraft:soul_sand",
	modelBlock = models.skull.block:setPrimaryRenderType("CUTOUT_CULL"),
	
	processBlock = {
		ON_ENTER = function (skull, model)
			skull.toggle = false
			skull.start = true
		end,
		ON_PROCESS = function (skull, model)
			local i = 0
			
			if skull.start then
				skull.toggle = not skull.toggle
				skull.start = false
				for easingName in pairs(Tween.easings) do
					local demodel = skull.model:newBlock(easingName)
					demodel:block("minecraft:grass_block"):scale(S * SCALE)
					i = i + 1
					local o = i * 4
					Tween.new{
						from = (skull.toggle and 0 or SCALE),
						to = (skull.toggle and SCALE or 0),
						duration = 1,
						easing = easingName,
						tick = function (v, t)
							demodel:pos(o,v,0)
						end,
						onFinish = function ()
							skull.start = true
						end
					}
				end
			end
		end
	}
}

Skull.registerIdentity(identity)