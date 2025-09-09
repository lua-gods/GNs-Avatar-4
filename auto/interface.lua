

if not host:isHost() then return end

local GNUI = require("lib.GNUI.main")
--[[
GNUI.showBounds()
--]]
local screen = GNUI.getScreen()

local Box = require("lib.GNUI.widget.box")
local Button = require("lib.GNUI.widget.button")
local TextField = require("lib.GNUI.widget.textField")
local Slider = require("lib.GNUI.widget.slider")
local Stack = require("lib.GNUI.widget.panes.stack")


local Window = require("lib.GNUI-desktop.widget.window")


local wndw = Window.new()

wndw
:setPos(20,20)
:setSize(200,200)

if true then return end

local grp = Box.new(screen,"group")
:setSize(200,200)
:setPos(16,16)
:setText("balls")


local cnt = Stack.new(grp,"group")
:maxAnchor()


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
