local GNUI = require("../../GNUI/main") ---@type GNUIAPI
local Theme = require("../../GNUI/theme") ---@type GNUI.ThemeAPI

local Box = require("../../GNUI/widget/box") ---@type GNUI.BoxAPI
local Button = require("../../GNUI/widget/button") ---@type GNUI.ButtonAPI
local Stack = require("../../GNUI/widget/panes/stack") ---@type GNUI.Pane.StackAPI
local Event = require("../../event")

Theme.loadTheme(require("../styles/default/gndesktop")) -- loads the default theme 
local trueScreen = GNUI:getScreen()



local SNAP_MARGIN = 10



---@class GNUI.Desktop.WindowAPI
local WindowAPI = {}


---@class GNUI.Desktop.Window : GNUI.Box
---@field boxTitlebar GNUI.Box
---@field ON_REQUEST_CLOSE Event
---@field ON_CLOSE Event
local Window = {}
Window.__index = function (t,i)
	return rawget(t,i) or Window[i] or Box.__index(t,i)
end
Window.__type = "GNUI.Desktop.Window"


---@param window GNUI.Desktop.Window
---@param controller GNUI.Box
---@param keybind GNUI.keyCode
---@return function
local function registerDrag(window,controller,keybind)
	return function (event)
		if event.key == keybind then
			if event.state == 1 then
				local offset = window:getPos() - window.Parent.MousePos
				controller.MOUSE_MOVED:register(function (event)
					local pos = event.pos + offset
					
					if pos.x < SNAP_MARGIN then pos.x = 0 end
					if pos.y < SNAP_MARGIN then pos.y = 0 end
					
					window:setPos(pos)
				end,"GNUI.Move")
			else
				controller.MOUSE_MOVED:remove("GNUI.Move")
			end
		end
	end
end


---@param screen GNUI.Canvas?
function WindowAPI.new(screen,variant)
	screen = screen or trueScreen
	local self = Box.new(screen,"none")
	setmetatable(self,Window)
	self:setSprite(Theme.getStyle(self, "backdrop", variant))
	self.ON_REQUEST_CLOSE = Event.new()
	self.ON_CLOSE = Event.new()
	---@cast self GNUI.Desktop.Window
	
	local titlebar = Box.new(self,"none")
	self.boxTitlebar = titlebar
	titlebar:setPadding(1,0,0,1)
	
	local right = Stack.new(titlebar)
	right:setStackDirection("LEFT")
	:setAnchor(1,0,1,1)
	:setGrowDirection(-1,0)
	titlebar:setAnchor(0,0,1,0):setSize(0,Theme.getStyle(self, "titlebar_height", variant))
	titlebar:setSprite(Theme.getStyle(self, "titlebar", variant))
	
	
	titlebar.INPUT:register(registerDrag(self,titlebar,"key.mouse.left"))
	self.INPUT:register(registerDrag(self,self,"key.keyboard.left.alt"))
	
	local closeBtn = Button.new(right,"windowClose"):forceAspectRatio(1,"HEIGHT")
	closeBtn.PRESSED:register(function ()
		local flush = self.ON_REQUEST_CLOSE:invoke()
		local close = true
		for index, value in ipairs(flush) do
			if value then close = false end
		end
		if close then
			self:close()
		end
	end)
	
	return self
end


function Window:close()
	self.ON_CLOSE:invoke()
	self:free()
end


return WindowAPI