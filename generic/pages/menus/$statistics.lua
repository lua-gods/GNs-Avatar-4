
local GNUI = require"library.GNUI.main"
local Theme = require"library.GNUI.theme"
local Button = require"library.GNUI.element.button"

local quickTween = require"library.quickTween"

Screen.new({
	name = "menu.statistics"
},function (events, screen)
	screen:setText(math.random())
end)