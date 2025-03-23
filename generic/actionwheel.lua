local GNUI = require"library.GNUI.main"
local TextField = require"library.GNUI.element.textField"

local key = keybinds:fromVanilla("figura.config.action_wheel_button")

Screen.new("actionwheel")

function key.press()
	local currentScreen = Screen.getCurrentScreen()
	if currentScreen.name == "default" then
		Screen.setScreen("actionwheel")
	elseif currentScreen.name == "actionwheel" then
		Screen.setScreen("default")
	end
	return true
end