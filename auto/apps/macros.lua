
local Box = require("lib.GNUI.widget.box")
local Button = require("lib.GNUI.widget.button")
local TextField = require("lib.GNUI.widget.textField")
local Slider = require("lib.GNUI.widget.slider")
local Stack = require("lib.GNUI.widget.panes.stack")

local Window = require("lib.GNUI-desktop.widget.window")
local FileDialog = require("lib.GNUI-desktop.widget.fileDialog")

local macros = {}

for index, value in ipairs(listFiles("auto.macros")) do
	macros[index] = require(value)
end

---@type GNUI.App
return {
	name = "Macros",
	icon = "minecraft:knowledge_book",
	start = function ()
	end
}