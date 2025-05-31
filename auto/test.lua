local Macros = require("lib.macros")

local macro = Macros.new(function (events, ...)
	
	-- triggers when the player is loaded and the macro is enabled
	events.ENTITY_INIT:register(function ()
		print("INIT")
	end)
	
	events.RENDER:register(function ()
		print("tick")
	end)
	
	-- triggers when the macro is disabled
	events.ON_EXIT:register(function ()
		print("end")
	end)
end)


events.TICK:register(function ()
	macro:setActive(player:isSneaking())
end)
