# flags: host_only
local Macros = require("lib.macros")

local keys = {
	ctrl = keybinds:newKeybind("dash","key.keyboard.left.control"),
	shift = keybinds:newKeybind("dash","key.keyboard.left.shift"),
}


local a = Macros.new(function (events, ...)
	
	local isDash = false
	events.WORLD_TICK:register(function ()
		if keys.ctrl:isPressed() and keys.shift:isPressed() then
			host:setVelocity(player:getLookDir() * 0.15 + vec(table.unpack(player:getNbt().Motion)))
		end
	end)
end)

a:setActive(true)