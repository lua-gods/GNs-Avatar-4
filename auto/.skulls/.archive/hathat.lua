---@diagnostic disable: param-type-mismatch
local Skull = require("lib.skull")
local Color = require("lib.color")

local ambient = Color.parseColor("#00396d").rgb
local albedo = Color.parseColor("#c54f4f").rgb
local specular = Color.parseColor("#ffeb78").rgb


---@type SkullIdentity|{}
local identity = {
	name = "hathat",
	id = "hathat",
	modelBlock = models.skull.hat,
	modelHud = models.skull.hat,
}

identity.processHud = {
	ON_READY = function(skull, model)
		model.cylinder:setScale(1, 8, 1)
		model.top:setPos(0, 8, 0)
		model.ribbon.shade1:setColor(math.lerp(albedo, ambient,0.5))
		model.ribbon.shade2:setColor(math.lerp(albedo, ambient,0.25))
		model.ribbon.shade3:setColor(albedo)
		model.ribbon.shade4:setColor(math.lerp(albedo, specular,0.25))
		model.ribbon.shade5:setColor(math.lerp(albedo, specular,0.5))
	end,
}


Skull.registerIdentity(identity)
