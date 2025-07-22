local Skull = require("lib.skull")

local SCALE = 10

local source = models.disco:scale(SCALE,SCALE,SCALE):setOpacity(0.3)

source:setPrimaryRenderType("EMISSIVE")

--pcall(source.setPrimaryRenderType,source,"NO_SHADING_BLURRY")

function hash(str)
	local hash = 0
	for i = 1, #str do
		local c = str:byte(i)
		hash = (hash * math.pi + c) % 100000 -- keep it within 5 digits
	end
	return hash
end

require("lib.animation")

local dances = {}

for key, value in pairs(animations:getAnimations()) do
	local name = value:getName()
	if name:find("^Dance") then
		dances[#dances+1] = name
	end
end

---@type SkullIdentity|{}
local identity = {
	support = "minecraft:note_block",
	name = "Cappie",
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