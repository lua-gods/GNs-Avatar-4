local GNUI = require("lib.GNUI.main")
--GNUI.debugMode()
local screen = GNUI.getScreen()
local Box = GNUI.box

local Button = require("lib.GNUI.widget.button")

local btn = Button.new(screen)
:setPos(16,16)
:setSize(100,20)


btn:setText("Hello World")