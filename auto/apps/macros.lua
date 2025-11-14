---@diagnostic disable: assign-type-mismatch

local Event = require("lib.event")
local Macros = require("lib.macros")


---@alias GNsAvatar.Macros.Option.Type string
---| "BOOLEAN"
---| "NUMBER"
---| "STRING"
---| "BUTTON"
---| "LABEL"


---@class GNsAvatar.Macro
---@field name string
---@field init fun(events: MacroEventsAPI,props: {value:any,VALUE_CHANGED:Event}[])
---@field config (GNsAvatar.Macros.Option.Boolean|GNsAvatar.Macros.Option.Number|GNsAvatar.Macros.Option.String|GNsAvatar.Macros.Option.Button|GNsAvatar.Macros.Option.Label)[]
---@field props {value:any,VALUE_CHANGED:Event}[]?
---@field package isActive boolean?
---@field package macro Macro?
---@field package boxEntries GNUI.Button?
---@field package boxTitleButton GNUI.Button?
---@field package boxStatusText GNUI.Box?
---@field package id integer?

---@class GNsAvatar.Macros.Option
---@field text string

---@class GNsAvatar.Macros.Option.Boolean : GNsAvatar.Macros.Option
---@field type "BOOLEAN"
---@field default_value boolean

---@class GNsAvatar.Macros.Option.Number : GNsAvatar.Macros.Option
---@field type "NUMBER"
---@field default_value number
---@field min number
---@field max number
---@field step number

---@class GNsAvatar.Macros.Option.String : GNsAvatar.Macros.Option
---@field type "STRING"
---@field default_value string

---@class GNsAvatar.Macros.Option.Button : GNsAvatar.Macros.Option
---@field type "BUTTON"

---@class GNsAvatar.Macros.Option.Label : GNsAvatar.Macros.Option
---@field type "LABEL"



---@type GNsAvatar.Macro[]
local macros = {}

for index, path in ipairs(listFiles("auto.macros")) do
	local macro = require(path) ---@type GNsAvatar.Macro
	macros[index] = macro
	if macro.init then
		macro.id = index
		macro.macro = Macros.new(macro.init)
	end
	
	local props = {}
	for j, conf in ipairs(macro.config) do
		local prop = {
			value = nil,
			VALUE_CHANGED = Event.new()
		}
		local t = conf.type
		if t == "BOOLEAN" then
			prop.value = conf.default_value or false
		elseif t == "NUMBER" then
			prop.value = conf.default_value or 0
		elseif t == "STRING" then
			prop.value = ""
		end
		props[j] = prop
	end
	macro.props = props
end




--[────────────────────────-< Sync >-────────────────────────]--

---@param id integer
---@param toggle boolean
function pings.GNsAvatarMacroToggle(id,toggle)
	macros[id].macro:setActive(toggle,macros[id].props)
end

function pings.GNsAvatarMacroPropSync(id,propID,value)
	macros[id].props[propID].value = value
	macros[id].props[propID].VALUE_CHANGED:invoke(value)
end

if not host:isHost() then return end
--[────────────────────────-< Utils >-────────────────────────]--

---@param btn GNUI.Button
local function booleanButton(btn,enabled)
	if enabled then
		btn:setText("On"):setColor(0.3,1,0.3)
	else
		btn:setText("Off"):setColor(1,0.3,0.3)
	end
end


---@param macro GNsAvatar.Macro
---@param active boolean
local function toggleMacro(macro,active)
	if macro.isActive ~= active then
		macro.isActive = active
		macro.macro:setActive(active,macro.props)
		macro.boxEntries:setVisible(active)
		macro.boxStatusText:setText(active and ":mcb_redstone_torch:" or ":mcb_redstone_torch_unlit:")
		pings.GNsAvatarMacroToggle(macro.id,active)
	end
end

--[────────────────────────-< More UI >-────────────────────────]--

local GNUI = require("lib.GNUI.main")

local Box = require("lib.GNUI.widget.box")
local Button = require("lib.GNUI.widget.button")
local TextField = require("lib.GNUI.widget.textField")
local Slider = require("lib.GNUI.widget.slider")
local Stack = require("lib.GNUI.widget.panes.stack")

local Window = require("lib.GNUI-desktop.widget.window")
local FileDialog = require("lib.GNUI-desktop.widget.fileDialog")


local window = Window.new()
:setSize(150, 100)
:setPos(50,50)
:setTitle("Macros")


local stack = Stack.new(window.Content)
:setStackDirection("DOWN")
:setAnchor(0,0,1,0)


local function newEntry(macro)
	local titleButton = Button.new(stack,"secondary")
	:setTextAlign(0,0.5)
	:setTextOffset(3,0)
	:setSize(0,14)
	:setText(macro.name)
	macro.boxTitleButton = titleButton
	
	local statusText = Box.new(titleButton)
	:maxAnchor()
	:setCanCaptureCursor(false)
	:setTextAlign(1,0.5)
	:setText(":mcb_redstone_torch:")
	:setTextOffset(-4,0)
	macro.boxStatusText = statusText
	
	local entries = Stack.new(stack)
	:setStackDirection("DOWN")
	:setSpacing(1)
	macro.boxEntries = entries
	
	titleButton.PRESSED:register(function ()
		toggleMacro(macro,not macro.isActive)
		stack:rearangeChildren()
	end)
	toggleMacro(macro,false)
	
	
	local props = {}
	for j, conf in ipairs(macro.config) do
		local prop = macro.props[j]
		local propID = j
		
		local entryBox = Box.new(entries)
		:setSize(0,12)
		entryBox:setText(conf.text):setTextOffset(2,0)
		:setDefaultTextColor("#bebebe")
		
		local t = conf.type
		if t == "BOOLEAN" then
			local ToggleBtn = Button.new(entryBox):setAnchor(0.5,0,1,1)
			
			booleanButton(ToggleBtn,prop.value)
			ToggleBtn.PRESSED:register(function ()
				prop.value = not prop.value
				booleanButton(ToggleBtn,prop.value)
				pings.GNsAvatarMacroPropSync(macro.id,propID,prop.value)
			end)
		elseif t == "NUMBER" then
			local slider = Slider.new(entryBox,{
				min = conf.min or 0,
				max = conf.max or 1,
				value = conf.default_value or 0,
				step = conf.step or 1,
				isVertical = false,
				showNumber = true
			}):setAnchor(0.5,0,1,1)
			
			slider.VALUE_CHANGED:register(function (value)
				prop.value = value
				prop.VALUE_CHANGED:invoke(value)
				pings.GNsAvatarMacroPropSync(macro.id,propID,value)
			end)
			
		elseif t == "STRING" then
			local text = TextField.new(entryBox):setAnchor(0.5,0,1,1)
			local textField = TextField.new(entryBox):setAnchor(0.5,0,1,1)
			textField.FIELD_CONFIRMED:register(function (value)
				prop.value = value
				prop.VALUE_CHANGED:invoke(value)
				pings.GNsAvatarMacroPropSync(macro.id,propID,value)
			end)
			
		elseif t == "BUTTON" then
			local btn = Button.new(entryBox,"secondary"):setAnchor(0,0,1,1)
			btn:setText(conf.text)
			entryBox:setText("")
			btn.PRESSED:register(function ()
				prop.VALUE_CHANGED:invoke()
				pings.GNsAvatarMacroPropSync(macro.id,propID)
			end)
		end
		props[j] = prop
	end
	
	macro.props = props
end


for i, macros in ipairs(macros) do
	newEntry(macros)
end


stack.SIZE_CHANGED:register(function (size)
	window:setSize(window.Size.x,size.y+15)
end)


window.ON_REQUEST_CLOSE:register(function ()
	window:setVisible(false)
end)


window:setVisible(false)

---@type GNUI.App
return {
	name = "Macros",
	icon = "minecraft:knowledge_book",
	start = function ()
		window:setVisible(true)
	end
}