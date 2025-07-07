
--[[______   __
  / ____/ | / /  by: GNanimates / https://gnon.top / Discord: @gn68s
 / / __/  |/ / name: GNUI API
/ /_/ / /|  /  desc: 
\____/_/ |_/ source: link ]]

local Box = require("./box") ---@type GNUI.BoxAPI
local Sprite = require("./sprite") ---@type GNUI.SpriteAPI
local Screen = require("./screen") ---@type GNUI.ScreenAPI
local Event = require("../event") ---@type Event

---@class GNUIAPI
local API = {
	box = Box, ---@type GNUI.BoxAPI
	sprite = Sprite, ---@type GNUI.SpriteAPI
	screen = Screen, ---@type GNUI.ScreenAPI
	--Renderer = require("./renderer"), ---@type GNUI.RenderAPI
	
	WINDOW_RESIZED=Event.new()
}

if host:isHost() then
	local lastWinSize = vec(0,0)
	events.WORLD_RENDER:register(function (delta)
		local winSize = client:getScaledWindowSize()
		if winSize ~= lastWinSize then
			lastWinSize = winSize
			API.WINDOW_RESIZED:invoke(winSize)
		end
	end)
end

local screen
function API.getScreen()
	if not screen then -- Screen Instantiation
		screen = Screen.new()
		
		API.WINDOW_RESIZED:register(function (winSize)
			screen:setExtent(winSize.x*0.5,0,winSize.x,winSize.y)
		end)
	end
	return screen
end

return API