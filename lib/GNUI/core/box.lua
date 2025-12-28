local util = require("../../gnutil") ---@type GNUtil

---@class GNUI.BoxAPI
local BoxAPI = {}

---@alias FitMode string
---| "FIXED"
---| "FIT"
---| "FILL"



---@class GNUI.Box
---
---@field dim Vector4
---@field size Vector2
---@field sizeFit {x:FitMode,y:FitMode}
---@field minSize Vector2
---@field maxSize Vector2
---@field finalDim Vector4
---
---@field parent GNUI.Box?
---@field childIndex integer
---@field children GNUI.Box[]
---@field childAlign Vector2
---
---@field visible boolean
local Box = {}
Box.__index = Box


function BoxAPI.new(data)
	local self = {
		dim = vec(0,0,0,0),
		size = vec(0,0),
		sizeFit = {x="FIXED",y="FIXED"},
		minSize = vec(0,0),
		maxSize = vec(0,0),
		finalDim = vec(0,0,0,0),
		
		parent = nil,
		childIndex = 0,
		children = {},
		childAlign = vec(0,0),
		
		visible = true
	}
	
	setmetatable(self, Box)
	return self
end


---Sets the position of the box
---@overload fun(self: GNUI.Box ,pos : Vector2): GNUI.Box
---@param x number
---@param y number
---@generic self
---@param self self
---@return self
function Box:setPos(x,y)
	---@cast self GNUI.Box
	self.dim.xy = util.vec2(x,y)
	return self
end


---Sets the size of the box
---@overload fun(self: GNUI.Box ,size : Vector2): GNUI.Box
---@param x number
---@param y number
---@generic self
---@param self self
---@return self
function Box:setSize(x,y)
	---@cast self GNUI.Box
	self.size = util.vec2(x,y)
	return self
end


return BoxAPI