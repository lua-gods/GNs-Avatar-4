
local GNUI = require"library.GNUI.main"
local Theme = require"library.GNUI.theme"

local quickTween = require"library.quickTween"

Screen.new({
	name = "menu",
	background=true
},function (events,screen)
	local ribbon = GNUI.newBox(screen)
	:setAnchor(0,0,1,0)
	:setDimensions(0,0,0,20)
	Theme.style(ribbon,"Background")
	quickTween.up(ribbon,20)
	
	local actionBar = GNUI.newBox(screen)
	:setAnchor(0,1,1,1)
	:setDimensions(0,-20,0,0)
	Theme.style(actionBar,"Background")
	quickTween.down(actionBar,20)
end)