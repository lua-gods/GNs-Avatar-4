#host

if not host:isHost() then return end

local GNUI = require("lib.GNUI.main")
GNUI.debugMode()
local screen = GNUI.getScreen()

local Button = require("lib.GNUI.widget.button")
local TextField = require("lib.GNUI.widget.textField")
local Slider = require("lib.GNUI.widget.slider")

local btn = Button.new(screen)
:setPos(16,16)
:setSize(100,20)
:setText("Hello World")


local txf = TextField.new(screen)
:setPos(16,46)
:setSize(100,100)


local sld = Slider.new(screen,{
	min = 0,
	max = 100,
	step = 1,
	value = 50,
})
:setPos(16,164)
:setSize(100,20)
