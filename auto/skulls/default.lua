local SkullAPI = require("lib.skull")
local SkullUtils = require("lib.skullUtils")
local MiniMacro = require("lib.MiniMacro")

local identity = SkullAPI.registerIdentity{
	name = "Default",
	modelBlock = models.skull.block,
	modelHat = models.skull.hat,
	modelHud = SkullUtils.makeIcon(models.skull.icon:getTextures()[1]),
	modelItem = models.skull.entity,
	
	processBlock = MiniMacro.new()
}

