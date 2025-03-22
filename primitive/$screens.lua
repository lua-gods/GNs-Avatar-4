---@diagnostic disable: return-type-mismatch
local GNUI = require"library.GNUI.main"
local screen = GNUI.getScreenCanvas()
local Box = require"library.GNUI.primitives.box"

local pages = {}
local currentPage


---@class GNUI.Screen : GNUI.Box
---@field name string
---@field ON_ENTER Signal
---@field ON_EXIT Signal
---@field background boolean
Page = {}
Page.__index = function (self, key)
	return rawget(self, key) or Page[key] or Box[key]
end

---@param name string
---@param background boolean?
---@return GNUI.Screen
function Page.new(name,background)
	if type(background) == "nil" then background = true end
	
	local new = GNUI.newBox(screen)
	new.name = name
	new.ON_ENTER = Signal.new()
	new.ON_EXIT = Signal.new()
	new.background = background and true or false
	if pages[name] then
		error("A page with the name '"..name.."' already exists.",2)
	end
	pages[name] = new
	setmetatable(new,Page)
	return new
end


function Page.setPage(name)
	local page = pages[name]
	if not pages[name] then
		page = pages.default
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
Page.new("default")
Page.setPage("default")