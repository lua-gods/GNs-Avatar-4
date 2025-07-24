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


---@param draw GNUI.DrawBackend
function Line:init(draw)
	
end

---@param draw GNUI.DrawBackend
function Line:update(draw)
	if self.lastPointCount ~= #self.points then
		self.lastPointCount = #self.points
		self:free(draw)
		self:init(draw)
	end
	
	-- TODO: draw points
end

---@param draw GNUI.DrawBackend
function Line:free(draw)
	
end


return LineAPI