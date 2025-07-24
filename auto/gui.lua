local GNUI = require("lib.GNUI.main")

local screen = GNUI.getScreen()

local box = GNUI.box.new()

box:setAnchor(0.25,0.25,0.5,0.5)
screen:addChild(box)

box.DIMENSIONS_CHANGED:register(function (dim)
	print(dim)
end)