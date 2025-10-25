--models.player.Base.Torso.Head.Face.Sclera
--:setPrimaryRenderType("EMISSIVE_SOLID")
--:setColor(0.7,0.7,0.7)


animations.player.Blink:speed(9)
local blinkTimer = 0

events.TICK:register(function ()
	blinkTimer = blinkTimer - 1
	if blinkTimer <= 0 then
		blinkTimer = math.random(0.5,5) * 20
		animations.player.Blink:stop():play()
	end
end)