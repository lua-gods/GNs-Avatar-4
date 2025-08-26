local ball = vec(0,2,0)

events.RENDER:register(function (delta, ctx, matrix)
	if ctx == "RENDER" then
		models.player:setPos(ball * (player:isCrouching() and 1 or 0))
	end
end)