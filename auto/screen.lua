local GNUI = require("lib.GNUI.main")

local screen = GNUI.getScreen()

local box = GNUI.box.new({
	anchor = vec(0.25,0.25,0.5,0.5),
	--extent = vec(10,10,100,100),
	parent = screen
})