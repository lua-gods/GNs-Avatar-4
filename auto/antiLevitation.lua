# flags: host_only

local lvel = vec(0,0,0)
events.TICK:register(function()
	local nbt = player:getNbt()
	local effets = nbt.ActiveEffects or {}
	for index, value in ipairs(effets) do
		if value.Id == 25 then -- levitation
			local vel = vec(table.unpack(player:getNbt().Motion))
			local accel = vel - lvel
			if accel.y > 0.1 then
				vel.y = lvel.y
				host:setVelocity(vel)
				host:sendChatCommand("effect clear @s levitation")
			end
			lvel = vel
			return
		end
	end
end)