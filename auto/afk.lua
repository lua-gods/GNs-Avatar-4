local afkTime = 0

function pings.emote(name)
	animations.player[name]:stop():play()
end

if host:isHost() then
	events.TICK:register(function ()
		if (player:getPos() - player:getPos(2)):length() == 0 then
			afkTime = afkTime + 1
			if afkTime > 20 * 5 then
				host:setActionbar("isAFK")
				if math.random() < 0.005 and not animations.player.Sleepy1:isPlaying() then
					pings.emote("Sleepy1")
				end
			end
		else
			afkTime = 0
		end
	end)
end