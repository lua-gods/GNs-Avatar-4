local GNUI = require("../../GNUI/main") ---@type GNUIAPI
local Theme = require("../../GNUI/theme") ---@type GNUI.ThemeAPI

local Box = require("../../GNUI/widget/box") ---@type GNUI.BoxAPI
local Button = require("../../GNUI/widget/button") ---@type GNUI.ButtonAPI
local Stack = require("../../GNUI/widget/panes/stack") ---@type GNUI.Pane.StackAPI

Theme.loadTheme(require("../styles/default/gndesktop")) -- loads the default theme 

local realScreen = GNUI:getScreen()

---@class GNUI.Desktop.WindowAPI
---@field boxTitlebar GNUI.Box
local WindowAPI = {}


---@class GNUI.Desktop.Window
local Window = {}
Window.__index = function (t,i)
	return rawget(t,i) or Window[i] or Box.__index(t,i)
end
Window.__type = "GNUI.Desktop.Window"

---@param screen GNUI.Canvas?
function WindowAPI.new(screen,variant)
	screen = screen or realScreen
	local new = Box.new(screen,"none")
	setmetatable(new,Window)
	new:setSprite(Theme.getStyle(new, "backdrop", variant))
	
	local titlebar = Box.new(new,"none")
	new.boxTitlebar = titlebar
	titlebar:setPadding(1,0,0,1)
	
	local right = Stack.new(titlebar)
	right:setStackDirection("LEFT")
	:setAnchor(1,0,1,1)
	:setGrowDirection(-1,0)
	titlebar:setAnchor(0,0,1,0):setSize(0,Theme.getStyle(new, "titlebar_height", variant))
	titlebar:setSprite(Theme.getStyle(new, "titlebar", variant))
	
	for i = 1, 5, 1 do
		local closeBtn = Button.new(right,"windowClose"):forceAspectRatio(1,"HEIGHT")
	end
	
	
	return new
end


return WindowAPI