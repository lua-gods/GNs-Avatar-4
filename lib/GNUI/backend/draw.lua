
---@diagnostic disable: invisible
--[[______   __
  / ____/ | / /  by: GNanimates / https://gnon.top / Discord: @gn68s
 / / __/  |/ / name: GNUI RenderAPI [Figura 0.1.6]
/ /_/ / /|  /  desc: handles all the rendering
\____/_/ |_/ source: link ]]
local utils  = require("../utils") ---@type GNUI.UtilsAPI
local Event = require("../../event") ---@type Event

---@class GNUI.DrawBackendAPI
local DrawBackendAPI = {}

---@class GNUI.DrawBackend
---@field screen GNUI.Screen
---@field targetBox GNUI.Box?
---[────────-< Figura >-────────]--
---@field part ModelPart
---@field renderStates table<GNUI.Box,GNUI.DrawBackend.Renderstate.Figura>
local DrawBackend = {}
DrawBackend.__index = DrawBackend


---@class GNUI.DrawBackend.Renderstate.Figura
---@field part ModelPart


local nextFree = 0
---@param screen GNUI.Screen
function DrawBackendAPI.newDrawBackend(screen)
	local self = {
		screen = screen,
		part = models:newPart("GNUIRenderInstance#"..nextFree,"HUD")
	}
	nextFree = nextFree + 1
	setmetatable(self,DrawBackend)
	self.screen = screen
	return self
end


local nextSetupFree = 0
---@param box GNUI.Box
function DrawBackend:getBoxRenderstate(box)
	local data = self.renderStates[box]
	if data then
		return self.renderStates[box]
	else
		
		local new = {
			part = self.part:newPart("box#"..nextSetupFree)
		}
		
		self.renderStates[box] = new
		nextSetupFree = nextSetupFree + 1
		return self.renderStates[box]
	end
end


---Sets the target box for the visuals to rely on.
---@param box GNUI.Box
function DrawBackend:setTargetBox(box)
	self.targetBox = box
	local renderState = self:getBoxRenderstate(box)
end


-- TODO: box tracking for visuals drawing


return DrawBackendAPI