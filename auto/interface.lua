

if not host:isHost() or true then return end

local GNUI = require("lib.GNUI.main")
--[[
GNUI.debugMode()
--]]
local screen = GNUI.getScreen()

local Button = require("lib.GNUI.widget.button")
local TextField = require("lib.GNUI.widget.textField")
local Slider = require("lib.GNUI.widget.slider")
local Stack = require("lib.GNUI.widget.panes.stack")

local cnt = Stack.new(screen)
:setSize(200,200)
:setPos(16,16)

local btn = Button.new(cnt)
:setSize(0,20)
:setText("Hello World")


local txf = TextField.new(cnt)
:setSize(0,100)


local sld = Slider.new(cnt,{
	min = 0,
	max = 10,
	step = 1,
	value = 4,
})
:setSize(0,10)
