

if not host:isHost() then return end

local GNUI = require("lib.GNUI.main")

local screen = GNUI.getScreen()

local Box = require("lib.GNUI.widget.box")
local Button = require("lib.GNUI.widget.button")
local TextField = require("lib.GNUI.widget.textField")
local Slider = require("lib.GNUI.widget.slider")
local Stack = require("lib.GNUI.widget.panes.stack")



local Window = require("lib.GNUI-desktop.widget.window")
local FileDialog = require("lib.GNUI-desktop.widget.fileDialog")


local key = keybinds:fromVanilla("figura.config.action_wheel_button")

local onCursor = false

key.press = function ()
	host.unlockCursor = onCursor
	onCursor = not onCursor
	return true
end