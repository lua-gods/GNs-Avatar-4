---@diagnostic disable: assign-type-mismatch
local GNUI = require("../../GNUI/main") ---@type GNUIAPI
local Theme = require("../../GNUI/theme") ---@type GNUI.ThemeAPI

local Box = require("../../GNUI/widget/box") ---@type GNUI.BoxAPI
local Button = require("../../GNUI/widget/button") ---@type GNUI.ButtonAPI
local Stack = require("../../GNUI/widget/panes/stack") ---@type GNUI.Pane.StackAPI
local Event = require("../../event")

Theme.loadTheme(require("../styles/default/gndesktop")) -- loads the default theme 
local trueScreen = GNUI:getScreen()



local SNAP_MARGIN = 0



---@class GNUI.Desktop.WindowAPI
local WindowAPI = {}


---@class GNUI.Desktop.Window : GNUI.Box
---@field boxTitlebar GNUI.Box
---@field Content GNUI.Box
---@field ON_REQUEST_CLOSE Event
---@field ON_CLOSE Event
local Window = {}
Window.__index = function (t,i)
	return rawget(t,i) or Window[i] or Box.__index(t,i)
end
Window.__type = "GNUI.Desktop.Window"
WindowAPI.__metamethods = Window

---@param window GNUI.Desktop.Window
---@param controller GNUI.Box
---@param keybind GNUI.keyCode
---@return function
local function registerDrag(window,controller,keybind)
	return function (event)
		if event.key == keybind then
			if event.state == 1 then
				local offset = window:getPos() - window.Parent.MousePos
				local parentSize = window.Parent:getFinalSize()
				controller.MOUSE_MOVED:register(function (event)
					local pos = event.pos + offset
					
					if pos.x < SNAP_MARGIN then pos.x = 0 end
					if pos.y < SNAP_MARGIN then pos.y = 0 end
					if pos.x+window.Size.x > parentSize.x-SNAP_MARGIN then
						pos.x = parentSize.x-window.Size.x
					end
					if pos.y+window.Size.y > parentSize.y-SNAP_MARGIN then
						pos.y = parentSize.y-window.Size.y
					end
					
					window:setPos(pos)
				end,"GNUI.Move")
			else
				controller.MOUSE_MOVED:remove("GNUI.Move")
			end
		end
	end
end

---@param window GNUI.Desktop.Window
---@param controller GNUI.Box
---@return function
local function registerResize(window,controller,x,y)
	return function (event)
		if event.key == "key.mouse.left" then
			if event.state == 1 then
				local offset = window.Dimensions - window.Parent.MousePos.xyxy
				controller.MOUSE_MOVED:register(function (event)
					local pos = event.pos.xyxy + offset
					local dim = window.Dimensions:copy()
					if x > 0 then dim.x = pos.x end
					if x < 0 then dim.z = pos.z end
					if y < 0 then dim.y = pos.y end
					if y > 0 then dim.w = pos.w end
					window:setDimensions(dim)
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
	local backdrop = Theme.getStyle(self, "backdrop", variant)
	self:setSprite(backdrop)
	self.ON_REQUEST_CLOSE = Event.new()
	self.ON_CLOSE = Event.new()
	
	local TITLEBAR_HEIGHT = Theme.getStyle(self, "titlebar_height", variant)
	
	---@cast self GNUI.Desktop.Window
	
	local drgGRP = GNUI.newBox(self)
	:setDimensions(backdrop.Padding:copy():mul(-1,-1,1,1))
	:maxAnchor()
	
	--[────────-< Titlebar >-────────]--
	
	local titlebar = Box.new(self,"none")
	self.boxTitlebar = titlebar
	titlebar:setPadding(1,0,0,1)
	
	local right = Stack.new(titlebar)
	right:setStackDirection("LEFT")
	:setAnchor(1,0,1,1)
	:setGrowDirection(-1,0)
	titlebar:setAnchor(0,0,1,0):setSize(0,TITLEBAR_HEIGHT)
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
	
	
	--[────────-< Draggers >-────────]--
	
	
	if true then
		-- top left
		local dragTL = Button.new(drgGRP,"windowBorderTopLeft")
		:setSize(3,3)
		dragTL.INPUT:register(registerResize(self,dragTL,1,-1))
		
		-- top
		local dragT = Button.new(drgGRP,"windowBorderTop")
		:setAnchor(0,0,1,0)
		:setDimensions(3,0,-3,3)
		dragT.INPUT:register(registerResize(self,dragT,0,-1))
		
		-- top right
		local dragTR = Button.new(drgGRP,"windowBorderTopRight")
		:setAnchor(1,0,1,0)
		:setDimensions(-3,0,0,3)
		dragTR.INPUT:register(registerResize(self,dragTR,-1,-1))
		
		-- right
		local dragR = Button.new(drgGRP,"windowBorderRight")
		:setAnchor(1,0,1,1)
		:setDimensions(-3,3,0,-3)
		dragR.INPUT:register(registerResize(self,dragR,-1,0))
		
		-- bottom right
		local dragBR = Button.new(drgGRP,"windowBorderBottomRight")
		:setAnchor(1,1,1,1)
		:setDimensions(-3,-3,0,0)
		dragBR.INPUT:register(registerResize(self,dragBR,-1,1))
		
		-- bottom
		local dragB = Button.new(drgGRP,"windowBorderBottom")
		:setAnchor(0,1,1,1)
		:setDimensions(3,-3,-3,0)
		dragB.INPUT:register(registerResize(self,dragB,0,1))
		
		-- bottom left
		local dragBL = Button.new(drgGRP,"windowBorderBottomLeft")
		:setAnchor(0,1,0,1)
		:setDimensions(0,-3,3,0)
		dragBL.INPUT:register(registerResize(self,dragBL,1,1))
		
		local dragL = Button.new(drgGRP,"windowBorderLeft")
		:setAnchor(0,0,0,1)
		:setDimensions(0,3,3,-3)
		dragL.INPUT:register(registerResize(self,dragL,1,0))
	end
	
	local content = Box.new(self,"none")
	content
	:setAnchor(0,0,1,1)
	:setDimensions(0,TITLEBAR_HEIGHT,0,0)
	self.Content = content
	
	return self
end


---@param title string
---@generic self
---@param self self
---@return self
function Window:setTitle(title)
	---@cast self GNUI.Desktop.Window
	self.boxTitlebar:setText(title)
	return self
end


function Window:close()
	self.ON_CLOSE:invoke()
	self:free()
end


return WindowAPI