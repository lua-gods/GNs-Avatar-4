events.TICK:register(function ()
	if player:isInWater() and player:getPose() == "STANDING" then
		host:setVelocity(player:getVelocity()*0.8)
	end
end)