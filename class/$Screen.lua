---@diagnostic disable: return-type-mismatch
local GNUI = require"library.GNUI.main"
local canvas = GNUI.getScreenCanvas()
local Box = require"library.GNUI.primitives.box"


local screens = {}
local currentScreen


---@class ScreenAPI
local ScreenAPI = {}
ScreenAPI.__index = ScreenAPI


---@class Screen : GNUI.Box
---@field name string
---@field ON_ENTER Signal
---@field ON_EXIT Signal
---@field background boolean
local Screen = {}
Screen.__type = "Screen"
Screen.__index = function (self, key)
	return rawget(self, key) or Box[key]
end


---@param a Screen
---@param b Screen
function Screen.__eq(a, b)
	return a.name == b.name
end


---@param name string
---@param background boolean?
---@return Screen
function ScreenAPI.new(name,background)
	if type(background) == "nil" then background = true end
	
	local new = GNUI.newBox(canvas):setAnchorMax()
	new.name = name
	new.ON_ENTER = Signal.new()
	new.ON_EXIT = Signal.new()
	new.background = background and true or false
	
	if screens[name] then
		error("A page with the name '"..name.."' already exists.",2)
	end
	
	new = setmetatable(new,Screen)
	screens[name] = new
	return new
end


function ScreenAPI.setScreen(name)
	local screen = screens[name]
	if not screens[name] then
		screen = screens.default
		warn("Page '"..name.."' does not exist. Defaulting to 'default' page.")
	end
	if currentScreen ~= screen then
		if currentScreen then
			currentScreen:setVisible(false)
			currentScreen.ON_EXIT:invoke()
		end
		renderer:setPostEffect(screen.background and "blur" or nil)
		currentScreen = screen
		
		currentScreen.ON_ENTER:invoke()
		currentScreen:setVisible(true)
	end
end



ScreenAPI.new("default",false)
ScreenAPI.setScreen("default")



---Returns the page with the given name, or the default page if no name is given.
---@param name string?
---@return Screen
function ScreenAPI.getScreen(name)
	return screens[name or "default"]
end


---Returns a table containing the names of all pages.
---@return string[]
function ScreenAPI.getScreens()
	local names = {}
	for name in pairs(screens) do
		table.insert(names,name)
	end
	return names
end


---@return Screen
function ScreenAPI.getCurrentScreen()
	return currentScreen
end

_G.Screen = ScreenAPI