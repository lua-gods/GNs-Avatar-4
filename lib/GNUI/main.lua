
--[[______   __
  / ____/ | / /  by: GNanimates / https://gnon.top / Discord: @gn68s
 / / __/  |/ / name: GNUI API
/ /_/ / /|  /  desc: 
\____/_/ |_/ source: link ]]

local Box = require("./prims/box") ---@type GNUI.BoxAPI
local Sprite = require("./visuals/sprite") ---@type GNUI.SpriteAPI
local Screen = require("./prims/screen") ---@type GNUI.ScreenAPI

local Event = require("../event") ---@type Event
local config = require("./config") ---@type GNUI.Config

local Draw  = require("./backend/draw")  ---@type GNUI.DrawBackendAPI
local Input = require("./backend/input") ---@type GNUI.InputBackendAPI


---@class GNUIAPI
local API = {
	box = Box, ---@type GNUI.BoxAPI
	sprite = Sprite, ---@type GNUI.SpriteAPI
	screen = Screen, ---@type GNUI.ScreenAPI
	--Renderer = require("./renderer"), ---@type GNUI.RenderAPI
}



local screen
---Returns a screen thats preconfigured to work on the screen
function API.getScreen()
	if not screen then -- Screen Instantiation
		screen = Screen.new()
		Input.WINDOW_RESIZED:register(function (winSize)
			screen:setExtent(0,0,winSize.x,winSize.y)
		end)
	end
	return screen
end

return API