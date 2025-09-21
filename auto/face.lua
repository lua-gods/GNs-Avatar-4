local Tween = require("lib.tween")

local head = models.player.Base.Torso.Head


local leftPupil = models.player.Base.Torso.Head.Face.Leye.LPupil
local leftEyelash = models.player.Base.Torso.Head.Face.Leye.Leyelash
local leftBrow = models.player.Base.Torso.Head.Face.LBrow

local rightPupil = models.player.Base.Torso.Head.Face.Reye.RPupil
local rightEyelash = models.player.Base.Torso.Head.Face.Reye.Reyelash
local rightBrow = models.player.Base.Torso.Head.Face.RBrow



local BLINK_RANGE = vec(1,10) * 20

head:setParentType("None")



local blinkTime = 0
animations.player.brightEyes:play():speed(0)
events.TICK:register(function ()
	
	blinkTime = blinkTime - 1
	if blinkTime <= 0 then
		blinkTime = math.random(BLINK_RANGE.x,BLINK_RANGE.y)
		animations.player.faceBlink:stop():play()
	end
	
	local pos = player:getPos():add(0,1.5,0)
	
	local time = ((world.getTimeOfDay() + 750) / 24000) % 1
	local light = math.max(world.getSkyLightLevel(pos)/15 * 1-math.clamp(math.cos(time*math.pi)*2,-1,1)*0.5,world.getBlockLightLevel(pos)/30)
	
	animations.player.brightEyes:setTime(light*2)
end)


events.RENDER:register(function (delta, ctx)
	head:setPos(0,player:isCrouching() and -4 or 0)
	
	-- avoid recalculating in the shadow pass
	if ctx == "OTHER" or ctx == "FIRST_PERSON" then return end 
	local rot = vanilla_model.BODY:getOriginRot()._y - vanilla_model.HEAD:getOriginRot().xy
	rot.y = ((rot.y + 180) % 360 - 180) / -50
	rot.x = rot.x / -90
	---@cast rot Vector2
	
	head:setRot(rot.x*45,rot.y*45,rot.y*15*-rot.x)
	
	rightPupil:setUVPixels(math.clamp(rot.y*0.5+0.8,-1,1),rot.x*0.5)
	leftPupil:setUVPixels(math.clamp(rot.y*0.5-0.8,-1,1),rot.x*0.5)
end)



animations.player.breathing:play():speed(0.3)