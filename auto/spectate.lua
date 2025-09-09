local wasSpectating = false
events.TICK:register(function ()
	local isSPectating = player:getGamemode() == "SPECTATOR"
	if wasSpectating ~= isSPectating then
		wasSpectating = isSPectating
		models.player:setVisible(not isSPectating)
		nameplate.ENTITY:setVisible(not isSPectating)
	end
end)