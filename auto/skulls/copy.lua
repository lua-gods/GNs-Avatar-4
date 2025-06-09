local Skull = require("lib.skull")

local process = {
		ON_ENTER = function (skull, model)
			model
			:newItem("hat")
			:item(([[minecraft:player_head{"SkullOwner":"%s","display":{"Name":'{"text":"%s"}'}}]])
			:format(skull.params[1] or "", skull.params[2] or ""))
			:pos(0,8,0)
			--:scale(0.845,0.845,0.845)
		end
	}

local identity = Skull.registerIdentity{
	name = "Copy",
	
	processHat = process,
	processHud = process,
	processEntity = process,
}

--minecraft:player_head{"SkullOwner":"AuriaFoxGirl","display":{"Name":'{"text":"balls"}'}}