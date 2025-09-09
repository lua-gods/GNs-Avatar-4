---@diagnostic disable: assign-type-mismatch, return-type-mismatch
-- DEPENDENCIES
local GNUI = require("./GNUI/main") ---@module "lib.GNUI.main"
local Macros = require("./macros") ---@module "lib.macros"

---@class GNUI.Book : GNUI.Box
---@field currentPage GNUI.Page?
---@field pages table<string,GNUI.Page>
local Book = {}
Book.__index = function(t,k)
	return rawget(t,k) or Book[k] or GNUI.box[k]
end
Book.__type = "GNUI.Book"

---@return GNUI.Book
function Book.newBook()
	local self = GNUI.newBox()
	self.pages = {}
	setmetatable(self,Book)
	return self
end

---@class GNUI.Page
---@field macro Macro
local Page = {}
Page.__index = function(t,k)
	return rawget(t,k) or Page[k]
end

---@param name string
---@param init fun(events: MacroEventsAPI,...)|Macro
---@return GNUI.Page
function Book:newPage(name,init)
	local macro
	if type(init) ~= "function" then
		macro = init
	else
		macro = Macros.new(init)
	end
	local page = {
		macro = macro,
	}
	
	setmetatable(page,Page)
	self.pages[name] = page
	return page
end

---Sets the current page to be displayed
---@param name string?
---@return GNUI.Book
function Book:setPage(name)
	if self.currentPage then
		self.currentPage.macro:setActive(false)
		self.currentPage.screen:free()
	end
	self.currentPage = self.pages[name]
	if self.currentPage then
		local screen = GNUI.newBox()
		self:addChild(screen)
		screen:maxAnchor()
		self.currentPage.screen = screen
		self.currentPage.macro:setActive(true,screen)
	end
	local hasPage = self.currentPage and true or false
	--renderer:setPostEffect(hasPage and "blur" or nil)
	--renderer:setRenderHUD(not hasPage)
	host:setUnlockCursor(hasPage)
	
	return self
end


---@param name string
---@return GNUI.Page
function Book:getPage(name)
	return self.pages[name] or error(name.." page does not exist")
end


return {newBook = Book.newBook}