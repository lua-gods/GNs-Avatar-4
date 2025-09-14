local Tween = require("lib.tween")

local head = models.player.Base.Torso.Head


local leftPupil = models.player.Base.Torso.Head.Face.Leye.LPupil
local leftEyelash = models.player.Base.Torso.Head.Face.Leye.Leyelash
local leftBrow = models.player.Base.Torso.Head.Face.LBrow

local rightPupil = models.player.Base.Torso.Head.Face.Reye.Rpupil
local rightEyelash = models.player.Base.Torso.Head.Face.Reye.Reyelash
local rightBrow = models.player.Base.Torso.Head.Face.RBrow



local BLINK_RANGE = vec(1,10) * 20

head:setParentType("None")



local lastAnimation
---@param animation Animation
local function setEmote(animation)
	if lastAnimation ~= animation then
		lastAnimation = animation
		if lastAnimation then
			Tween.new({
				from = 1,
				to = 0,
				easing = "linear",
				duration = 0.5,
				tick = function (v) lastAnimation:blend(v) end,
				onFinish = function () lastAnimation:stop() end,
				id = "emote"
			})
		end
		if animation then
			Tween.new({
				from = 0,
				to = 1,
				easing = "linear",
				duration = 0.5,
				tick = function (v) animation:blend(v) end,
				onFinish = function () animation:play() end,
				id = "emote"
			})
		end
	end
end


local blinkTime = 0
animations.player.brightEyes:play():speed(0)
local lrot,rot = vec(0,0),vec(0,0)
events.TICK:register(function ()
	lrot = rot
	local vehicle = player:getVehicle()
	rot = player:getRot():sub(0,player:getBodyYaw())
	rot = vanilla_model.BODY:getOriginRot()._y - vanilla_model.HEAD:getOriginRot().xy
	rot.y = ((rot.y + 180) % 360 - 180) / -50
	rot.x = rot.x / -90
	
	--host:setActionbar(rot:toString())
	
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
	if ctx == "OTHER" then return end 
	
	local trot = math.lerp(lrot,rot,delta)
	--v fallback for other contexts
	if ctx ~= "RENDER" then 
		trot = vanilla_model.HEAD:getOriginRot().xy
		trot.y = ((trot.y + 180) % 360 - 180) / 50
		trot.x = trot.x / 90
	end
	
	
	head:setRot(trot.x*45,trot.y*45,trot.y*15*-trot.x)
	
	rightPupil:setUVPixels(math.clamp(trot.y*0.5+0.8,-1,1),trot.x*0.5)
	leftPupil:setUVPixels(math.clamp(trot.y*0.5-0.8,-1,1),trot.x*0.5)
end)



animations.player.breathing:play():speed(0.3)