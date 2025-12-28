local util = require("../../gnutil") ---@type GNUtil
local box = require("./box") ---@type GNUI.BoxAPI

---@class GNUI.CanvasAPI
local CanvasAPI = {}


---A root node for boxes
---@class GNUI.Canvas : GNUI.BoxAPI
local Canvas = {}
Canvas.__index = Canvas

---Creates a new canvas for boxes to attach to, this box is special, 
---as it acts as the root node of all boxes
---@return GNUI.Canvas
function CanvasAPI.new()
	local self = {}
	setmetatable(self,Canvas)
	return self
end


return CanvasAPI