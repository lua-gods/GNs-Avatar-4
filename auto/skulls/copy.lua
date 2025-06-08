local Skull = require("lib.skull")

local identity = Skull.registerIdentity{
	name = "Copy",
	modelItem = models.skull.entity,
	
	processHat = {
		ON_ENTER = function (skull, model)
			print(skull.params)
		end
	}
}

