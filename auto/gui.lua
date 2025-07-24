local GNUI = require("lib.GNUI.main")

local screen = GNUI.getScreen()

local box = GNUI.box.new()

screen:addChild(box)
box:setAnchor(0.25,0.25,0.5,0.5)

