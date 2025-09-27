local Skull = require("lib.skull")
local Color = require("lib.color")



local SCALE = 0.845

models.fez.hat:scale(SCALE,SCALE,SCALE)

---@type SkullIdentity|{}
local identity = {
	name = "Sign",
	id = "sign",
	
	processHud = {
		ON_ENTER = function (skull, model)
			model:newItem("icon"):item("minecraft:oak_sign"):pos(0,4,0)
		end
	},
	
	processHat = {
		ON_ENTER = function (skull, model)
			local sign = model:newBlock("sign"):pos(-8,6,-8)
			local ok,err = pcall(sign.block,sign,"minecraft:"..skull.params[1].."_sign")
			if not ok then
				sign:block("oak_sign")
			end
			for i = 1, 4, 1 do
				model:newText("line"..i):text('{"text":'..toJson(skull.params[i+1] or "")..',"color":"black"}'):alignment("CENTER")
				:pos(0,22.7-(i-1)*1.7,-0.68)
				:scale(0.16)
			end
			
			for i = 1, 4, 1 do
				model:newText("line"..(i+4)):text('{"text":'..toJson(skull.params[i+5] or "")..',"color":"black"}'):alignment("CENTER")
				:pos(0,22.7-(i-1)*1.7,0.68)
				:rot(0,180,0)
				:scale(0.16)
			end
		end
	}
}

Skull.registerIdentity(identity)