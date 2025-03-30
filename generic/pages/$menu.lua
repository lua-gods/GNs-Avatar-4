local GNUI = require"library.GNUI.main"
local Theme = require"library.GNUI.theme"
Screen.new({
	name = "menu",
	background=false
},function (events,screen)
	local ribbon = GNUI.newBox(screen)
	:setAnchor(0,0,1,1)
	:setDimensions(0,0,10,0)
	Theme.style(ribbon,"Background")
end)