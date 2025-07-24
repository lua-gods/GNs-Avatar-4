local utils = require("../utils") ---@type GNUI.UtilsAPI


---@class GNUI.Visual.LineAPI
local LineAPI = {}


---@class GNUI.Visual.Line : GNUI.Visual
---@field points Vector2[]
---@field protected lastPointCount integer
local Line = {}
Line.__index = Line


function LineAPI.new()
	local self = {
		points = {},
	}
	setmetatable(self,Line)
	return self
end


---@param i integer
---@param x number|Vector2
---@param y number?
function Line:setPoint(i,x,y)
	local lastPointCount = #self.points
	if i > 0 and i < #self.points + 1 then
		local pos = utils.vec2(x,y)
		self.points[i] = pos
	else
		error("Point "..i.." out of range")
	end
end

---@param box GNUI.Box
---@param draw GNUI.DrawBackend
function Line:init(box,draw)
	
end

---@param box GNUI.Box
---@param draw GNUI.DrawBackend
function Line:update(box,draw)
	if self.lastPointCount ~= #self.points then
		self.lastPointCount = #self.points
		self:free(box,draw)
		self:init(box,draw)
	end
	
	-- TODO: draw points
end

---@param box GNUI.Box
---@param draw GNUI.DrawBackend
function Line:free(box,draw)
	
end


return LineAPI