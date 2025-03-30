---@diagnostic disable: return-type-mismatch
local GNUI = require"library.GNUI.main"
local canvas = GNUI.getScreenCanvas()
local Box = require"library.GNUI.primitives.box"


local screens = {}
local currentScreen ---@type Screen


---@class ScreenAPI
local ScreenAPI = {}
ScreenAPI.__index = ScreenAPI


---@class Screen : GNUI.Box
---@field name string
---@field events Macros
---@field background boolean
local Screen = {}
Screen.__type = "Screen"
Screen.__index = function (self, key)
	return rawget(self, key) or Box[key]
end

---@class Screen.metadata
---@field name string
---@field background boolean?

---@param a Screen
---@param b Screen
function Screen.__eq(a, b)
	return a.name == b.name
end


---@param init fun(events: MacroEventsAPI)?
---@param meta Screen.metadata
---@return Screen
function ScreenAPI.new(meta,init)
	init = init or function () end
	meta = meta or {}
	
	local background = true
	if type(meta.background) ~= "nil" and meta.background == false then
		background = false
	end
	
	local new = GNUI.newBox(canvas):setAnchorMax()
	new.name = meta.name
	new.events = Macros.new(init)
	new.background = background
	
	if screens[new.name] then
		error("A page with the name '"..new.name.."' already exists.",2)
	end
	
	new = setmetatable(new,Screen)
	screens[new.name] = new
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
			currentScreen.events:toggle(false)
		end
		renderer:setPostEffect(screen.background and "blur" or nil)
		renderer:setRenderHUD(not screen.background)
		currentScreen = screen
		
		currentScreen.events:toggle(true)
		currentScreen:setVisible(true)
	end
end



ScreenAPI.new({name="default",background=false})
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