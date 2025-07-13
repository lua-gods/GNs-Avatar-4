local Skull = require("lib.skull")

local process = {
		ON_ENTER = function (skull, model)
			local itemString = ([[minecraft:player_head{"SkullOwner":"%s","display":{"Name":%s}}]])
			:format(skull.params[1] or "", toJson(toJson(skull.params[2] or "")))
			local ok, result = pcall(world.newItem, itemString)
			if not ok then
				result = "minecraft:barrier"
			end
			model
			:newItem("hat")
			:item(result)
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

--minecraft:player_head{"SkullOwner":"AuriaFoxGirl","display":{"Name":'{"text":"furry"}'}}