local GNUI = require"library.GNUI.main"
local TextField = require"library.GNUI.element.textField"

local screen = GNUI.getScreenCanvas()
--GNUI.showBoundingBoxes()

local input = TextField.new(screen,true)
:setAnchor(0.5,0.5)
:setDimensions(-50,-10,50,10)