# flags: host_only


local GNUI = require("lib.GNUI.main")

local screen = GNUI.getScreen()

local Box = require("lib.GNUI.widget.box")
local Button = require("lib.GNUI.widget.button")
local TextField = require("lib.GNUI.widget.textField")
local Slider = require("lib.GNUI.widget.slider")
local Stack = require("lib.GNUI.widget.panes.stack")

local SIZE = 14


local Window = require("lib.GNUI-desktop.widget.window")
local FileDialog = require("lib.GNUI-desktop.widget.fileDialog")


local toolbar = Stack.new(screen)
:setStackDirection("RIGHT")
:setAnchor(0.5,0.5)
:setPos(0,-SIZE)
:setSize(0,SIZE)

local apps = {}
for index, value in ipairs(listFiles("auto.apps")) do
	---@type GNUI.App
	local appData = require(value)
	local btn = Button.new(toolbar,"none")
	local boxIcon = Box.new(btn)
	btn:setCustomMinimumSize(SIZE,SIZE)
	btn.ModelPart:newText("s"):setText("."):setPos(0,10000,0)
	local icon
	icon = boxIcon.ModelPart
		:newItem("icon")
		:item(appData.icon)
		:displayMode("GUI")
	
	
	icon
	:setPos(-8,-8,100)
	:scale(1)
	
	local label = Box.new(btn)
	label
	:setText(appData.name)
	:setPos(1,-8)
	:setCustomMinimumSize(100,10)
	:setTextEffect("OUTLINE")
	btn.PRESSED:register(function()
		appData.start()
	end)
	
	label:setVisible(false)
	
	btn.MOUSE_PRESSENCE_CHANGED:register(function (hover)
		label:setVisible(hover)
	end)
	
	apps[appData.name] = appData
end


---@class GNUI.App
---@field name string
---@field icon Minecraft.itemID
---@field start fun()


local key = keybinds:fromVanilla("figura.config.action_wheel_button")

local onCursor = false

toolbar:setVisible(onCursor)

key.press = function ()
	onCursor = not onCursor
	toolbar:setVisible(onCursor)
	host.unlockCursor = onCursor
	renderer.renderCrosshair = not onCursor
	return true
end