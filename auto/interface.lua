#host

if not host:isHost() or true then return end

local GNUI = require("lib.GNUI.main")
--GNUI.debugMode()
local screen = GNUI.getScreen()
local Box = GNUI.box

local Button = require("lib.GNUI.widget.button")
local TextField = require("lib.GNUI.widget.textField")

GNUI.debugMode()

--local btn = Button.new(screen)
--:setPos(16,16)
--:setSize(100,20)
--:setText("Hello World")


local txf = TextField.new(screen)
:setPos(16,46)
:setSize(100,100)
