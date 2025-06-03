local Macros = require("lib.macros")

local elytra = Macros.new(function (events)
	events.ENTITY_INIT:register(function ()
		renderer:setRootRotationAllowed(false)
	end)
	
	events.RENDER:register(function (delta, ctx, matrix)
		local rot = player:getRot(delta)
		local byaw = player:getBodyYaw(delta)
		rot.y = (rot.y - byaw - 180) % 360 + 180
		models.player:setRot(0,180-byaw)
		models.player.Base.Torso.Head:setRot(-rot.x-45,0)
	end)
	
	events.ON_EXIT:register(function ()
		renderer:setRootRotationAllowed(true)
		models.player.Base.Torso.Head:setRot()
		models.player:setRot()
	end)
end)

events.TICK:register(function ()
	elytra:setActive(player:getPose() == "FALL_FLYING")
end)