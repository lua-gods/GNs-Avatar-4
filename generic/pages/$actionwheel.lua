local GNUI = require"library.GNUI.main"
local TextField = require"library.GNUI.element.textField"

local key = keybinds:fromVanilla("figura.config.action_wheel_button")

Screen.new("actionwheel")

local container

function key.press()
	local currentScreen = Screen.getCurrentScreen()
	if currentScreen.name == "default" then
		Screen.setScreen("actionwheel")
		host:setUnlockCursor(true)
		
		container = events.newContainer()
		container.ENTITY_INIT:register(function ()
		end)
		container.TICK:register(function ()
		end)
		container.ENTITY_EXIT:register(function ()
		end)
	else
		container:free()
		Screen.setScreen("default")
		host:setUnlockCursor(false)
	end
	return true
end