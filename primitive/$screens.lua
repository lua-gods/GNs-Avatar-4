---@diagnostic disable: return-type-mismatch
local GNUI = require"library.GNUI.main"
local canvas = GNUI.getScreenCanvas()
local Box = require"library.GNUI.primitives.box"

local screens = {}
local currentPage


---@class GNUI.Screen : GNUI.Box
---@field name string
---@field ON_ENTER Signal
---@field ON_EXIT Signal
---@field background boolean
Screen = {}
Screen.__index = function (self, key)
	return rawget(self, key) or Screen[key] or Box[key]
end

---@param name string
---@param background boolean?
---@return GNUI.Screen
function Screen.new(name,background)
	if type(background) == "nil" then background = true end
	
	local new = GNUI.newBox(canvas)
	new.name = name
	new.ON_ENTER = Signal.new()
	new.ON_EXIT = Signal.new()
	new.background = background and true or false
	if screens[name] then
		error("A page with the name '"..name.."' already exists.",2)
	end
	screens[name] = new
	setmetatable(new,Screen)
	return new
end


function Screen.setPage(name)
	local page = screens[name]
	if not screens[name] then
		page = screens.default
		warn("Page '"..name.."' does not exist. Defaulting to 'default' page.")
	end
	if currentPage ~= page then
		if currentPage then
			currentPage:setVisible(false)
			currentPage.ON_EXIT:invoke()
		end
		
		currentPage = page
		
		currentPage.ON_ENTER:invoke()
		currentPage:setVisible(true)
	end
end

Screen.new("default")
Screen.setPage("default")


---Returns the page with the given name, or the default page if no name is given.
---@param name string?
---@return GNUI.Screen
function Screen.getScreen(name)
	return screens[name or "default"]
end


---Returns a table containing the names of all pages.
---@return string[]
function Screen.getScreens()
	local names = {}
	for name in pairs(screens) do
		table.insert(names,name)
	end
	return names
end