
---@diagnostic disable: invisible
--[[______   __
  / ____/ | / /  by: GNanimates / https://gnon.top / Discord: @gn68s
 / / __/  |/ / name: GNUI RenderAPI [Figura 0.1.6]
/ /_/ / /|  /  desc: handles all the rendering
\____/_/ |_/ source: link ]]
local utils  = require("../utils") ---@type GNUI.UtilsAPI
local Event = require("../../event") ---@type Event

---@class GNUI.DrawBackendAPI
local DrawBackend = {}



---@class GNUI.DrawBackend
---@field screen GNUI.Screen
---[────────-< Figura >-────────]--
---@field part ModelPart
local RenderInstance = {}
RenderInstance.__index = RenderInstance


local nextFree = 0
---@param screen GNUI.Screen
function DrawBackend.newDrawBackend(screen)
	local self = {
		screen = screen,
		part = models:newPart("GNUIRenderInstance#"..nextFree,"HUD")
	}
	nextFree = nextFree + 1
	setmetatable(self,RenderInstance)
	self.screen = screen
	return self
end


---Sets the target box for the visuals to rely on.
---@param box GNUI.Box
function DrawBackend:setTargetBox(box)
	
end


-- TODO: box tracking for visuals drawing


return DrawBackend