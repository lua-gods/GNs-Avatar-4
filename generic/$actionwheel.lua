local GNUI = require"library.GNUI.main"
local TextField = require"library.GNUI.element.textField"

local key = keybinds:fromVanilla("figura.config.action_wheel_button")

for _, path in pairs(listFiles("generic.pages")) do
	require(path)
end

function key.press()
	local currentScreen = Screen.getCurrentScreen()
	if currentScreen.name == "default" then
		Screen.setScreen("menu")
		host:setUnlockCursor(true)
	else
		Screen.setScreen("default")
		host:setUnlockCursor(false)
	end
	return true
end

