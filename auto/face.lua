
local BLINK_RANGE = vec(1,10) * 20
local ANIM_X = animations.player.eyeHorizontal
local ANIM_Y = animations.player.eyeVertical
local ANIM_BLINK = animations.player.eyeBlink

local MODEL_HEAD = models.player.Base.Torso.Head
MODEL_HEAD:setParentType("None")

ANIM_X:speed(0):play()
ANIM_Y:speed(0):play()
local blinkTime = 0

events.TICK:register(function ()
	blinkTime = blinkTime - 1
	if blinkTime <= 0 then
		blinkTime = math.random(BLINK_RANGE.x,BLINK_RANGE.y)
		ANIM_BLINK:stop():play()
	end
end)



events.RENDER:register(function (delta, ctx)
	MODEL_HEAD:setPos(0,player:isCrouching() and -4 or 0)
	
	-- avoid recalculating in the shadow pass
	if ctx == "OTHER" or ctx == "FIRST_PERSON" or ctx == "PAPERDOLL" then return end 
	local rot = vanilla_model.BODY:getOriginRot()._y - vanilla_model.HEAD:getOriginRot().xy
	rot.y = ((rot.y + 180) % 360 - 180) / -50
	rot.x = rot.x / -90
	---@cast rot Vector2
	
	MODEL_HEAD:setRot(rot.x*45,rot.y*22.5,rot.y*15*-rot.x)
	ANIM_X:setTime(rot.y*0.5+0.5)
	ANIM_Y:setTime(rot.x*0.5+0.5)
end)



animations.player.breathing:play():speed(0.3)