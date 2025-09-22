---@diagnostic disable: assign-type-mismatch
local GNUI = require("../../GNUI/main") ---@type GNUIAPI 
local Theme = require("../../GNUI/theme") ---@type GNUI.ThemeAPI

local Box = require("../../GNUI/widget/box") ---@type GNUI.BoxAPI
local Button = require("../../GNUI/widget/button") ---@type GNUI.ButtonAPI
local Stack = require("../../GNUI/widget/panes/stack") ---@type GNUI.Pane.StackAPI
local Window = require("./window") ---@type GNUI.Desktop.WindowAPI
local Event = require("../../event")
local TextField = require("../../GNUI/widget/textField") ---@type GNUI.TextFieldAPI
local Slider = require("../../GNUI/widget/slider") ---@type GNUI.SliderAPI

local Tween = require("../../tween") or {}  ---@type Tween

local DOUBLE_CLICK_TIME = 300

local CLR_ENTRY_HOVER = Theme.getStyle("Box","entry_hovered","default")
local CLR_ENTRY = Theme.getStyle("Box","entry","default")
local CLR_ENTRY_SECONDARY = Theme.getStyle("Box","entry_secondary","default")

local ICON_FOLDER = Theme.getStyle("Box","icon","iconFolder")

local ICONS  = {
		{type={"ogg","mp3","wav","midi","mid","nbs"},icon=Theme.getStyle("Box","icon","iconSound")},
		{type={"txt","csv"},icon=Theme.getStyle("Box","icon","iconText")},
		{type={"png","jpg","bmp","jpeg","webp","gif"},icon=Theme.getStyle("Box","icon","iconImage")},
		{type={"lua","luau"},icon=Theme.getStyle("Box","icon","iconLua")},
		{type={"json","yaml","toml"},icon=Theme.getStyle("Box","icon","iconJson")},
		{type={"nbt"},icon=Theme.getStyle("Box","icon","iconNBT")},
		{type={"mp4","mkv","webm","mov"},icon=Theme.getStyle("Box","icon","iconVideo")},
}

local ICON_HASH = {}
for _,entry in ipairs(ICONS) do
	for _,type in ipairs(entry.type) do
		ICON_HASH[type] = entry.icon
	end
end

---@class GNUI.Desktop.FileDialogAPI
local FileDialogAPI = {}

---@class GNUI.Desktop.FileDialog : GNUI.Desktop.Window
---@field entryList GNUI.Box
---@field slider GNUI.Slider
---@field stack GNUI.Pane.Stack
---@field pathInput GNUI.TextField
---@field confirmBtn GNUI.Button
---@field fileNameField GNUI.TextField
---@field dir string
---@field fileName string?
---@field CONFIRMED Event
local FileDialog = {}
FileDialog.__index = function (t,i) return rawget(t,i) or FileDialog[i] or Window.__metamethods[i] or Box.__index(t,i) end

---@param screen GNUI.Canvas
---@return GNUI.Desktop.Window
function FileDialogAPI.new(screen)
	local self = Window.new(screen)
	self:setSize(300,200)
	:setTitle(":folder: File Dialog")
	:setPos(20,20)
	
	---@cast self GNUI.Desktop.FileDialog
	
	self.CONFIRMED = Event.new()
	
	local list = Box.new(self.Content)
	:setAnchor(0,0,1,1)
	:setDimensions(11*4,11,-80,0)
	self.entryList = list
	
	local slider = Slider.new(self.Content,{
		min = 0,
		max = 10,
		value = 0,
		step=0.5,
		isVertical=true,
		showNumber=false
	})
	:setAnchor(1,0,1,1)
	:setSize(5,-11)
	:setPos(-80-5,11)
	self.slider = slider
	slider.VALUE_CHANGED:register(function (value)
		Tween.new{
			from = list.ChildrenOffset.y,
			to = value*-11,
			tick = function (v, t)
				list:setChildrenOffset(0,v)
			end,
			easing = "outQuad",
			duration = 0.05,
			id = "fileDialogList"..self.id
		}
	end)
	
	local leftSideBar = Box.new(self.Content,"background")
	:setAnchor(0,0,0,1)
	:setSize(11*4,0)
	self.leftSideBar = leftSideBar
	
	local navStack = Stack.new(leftSideBar)
	:setAnchor(0,0,1,0)
	:setSize(0,11)
	:setStackDirection("RIGHT")
	
	local undoButton = Button.new(navStack):setSize(11,0):setText("<")
	local redoButton = Button.new(navStack):setSize(11,0):setText(">")
	local upDirButton = Button.new(navStack):setSize(11,0):setText("^")
	local idkButton = Button.new(navStack):setSize(11,0):setText("-")
	
	upDirButton.PRESSED:register(function ()
		self:setDirectory(self.dir:sub(1,((self.dir:find("[^/]+/$") or 2)-1) or 1))
	end)
	
	local rightSidebar = Box.new(self.Content,"background")
	:setAnchor(1,0,1,1)
	:setSize(80,0)
	:setPos(-80,0)
	self.rightSidebar = rightSidebar
	
	local pathInput = TextField.new(self.Content)
	:setAnchor(0,0,1,0)
	:setSize(-80-11*4,11)
	:setPos(11*4,0)
	self.pathInput = pathInput
	
	pathInput.FIELD_CONFIRMED:register(function (path)
		self:setDirectory(path)
	end)
	
	
	local icon = Box.new(rightSidebar)
	icon:setSize(80,80)
	:setSprite(Theme.getStyle(icon,"icon","iconFolder"))
	:setMargin(5,5,5,5)
	
	local fileNameField = TextField.new(self.Content)
	:setAnchor(0,1,1,1)
	:setSize(-80-11*4,11)
	:setPos(11*4,-11)
	self.fileNameField = fileNameField
	
	fileNameField.FIELD_CONFIRMED:register(function (name) 
		self:selectFile(name)
	end)
	
	
	local confirmBtn = Button.new(rightSidebar)
	:setAnchor(0,1,1,1)
	:setPos(0,-12)
	:setSize(0,12)
	:setText("Confirm")
	self.confirmBtn = confirmBtn
	
	confirmBtn.PRESSED:register(function ()
		if self.dir and self.fileName then
			self.CONFIRMED:invoke(self.dir..self.fileName,self.fileName,self.dir)
			self:close()
		end
	end)
	
	setmetatable(self,FileDialog)
	self:setDirectory("")
	
	list.INPUT:register(function (event)
		if event.key == "key.mouse.scroll" then
			slider.INPUT:invoke(event)
		end
	end)
	
	return self
end

function FileDialog:setDirectory(dir)
	if not file:isPathAllowed(dir) then return self end
	self.pathInput:setTextField(dir)
	
	local entries = file:list(dir)
	if not entries then return self end
	self.dir = dir
	self.slider:setMax(#entries):setValue(0)
	self.entryList:purgeAllChildren()
	
	table.sort(entries, function(a, b)
		local isADir = file:isDirectory(dir..a)
		if isADir ~= file:isDirectory(dir..b) then
			return isADir and true or false
		end
		return a:lower() < b:lower()
	end)
	
	for i, name in ipairs(entries) do
		local entry = Box.new(self.entryList,"solid")
		:setAnchor(0,0,1,0)
		:setPos(0,11*(i-1))
		:setSize(0,11)
		:setTextOffset(9,1)
		:setTextAlign(0,0.5)
		:setText(name)
		:setClipOnParent(true)
		:setTextBehavior("TRIM")
		
		local icon = GNUI.newBox(entry)
		:setSize(7,7)
		:setPos(1,0)
		
		local isDirectory = false
		
		local fileType = name:match("%.([^.]+)$")
		if fileType then
			icon:setSprite(ICON_HASH[fileType] and ICON_HASH[fileType]:copy())
		else
			isDirectory = true
			icon:setSprite(ICON_FOLDER:copy())
		end
		
		local lastLeftClick = 0
		
		entry.INPUT:register(function (event)
			if event.key == "key.mouse.scroll" then
				self.slider.INPUT:invoke(event)
			end
			if event.key == "key.mouse.left" and event.state == 1 then
				if isDirectory then
					local time = client:getSystemTime()
					if time - lastLeftClick < DOUBLE_CLICK_TIME then
						if isDirectory then
							self:setDirectory(dir..name.."/")
						end
					end
					lastLeftClick = time
				else
					self:selectFile(name)
				end
				playUISound("minecraft:ui.button.click",1,1)
			end
		end)
		
		entry.MOUSE_PRESSENCE_CHANGED:register(function (isHovering)
			if isHovering then
				entry:setColor(CLR_ENTRY_HOVER)
			else
				if i % 2 == 0 then
					entry.sprite:setColor(CLR_ENTRY)
				else
					entry.sprite:setColor(CLR_ENTRY_SECONDARY)
				end
			end
		end)
		
		if i % 2 == 0 then
			entry.sprite:setColor(CLR_ENTRY)
		else
			entry.sprite:setColor(CLR_ENTRY_SECONDARY)
		end
	end
end

function FileDialog:selectFile(name)
	self.fileNameField:setTextField(name)
	self.fileName = name
end

return FileDialogAPI