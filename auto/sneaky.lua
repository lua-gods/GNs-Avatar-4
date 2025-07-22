local wasSneaking = false

require("lib.animation")

events.TICK:register(function ()
	local isSneaking = player:isSneaking()
	if wasSneaking ~= isSneaking then
		wasSneaking = isSneaking
		
		if isSneaking then
			models.player:play("player.DanceKazotskykick")
		else
			models.player:stop()
		end
	end
end)