---@class GNUI.Render.Sprite.Quad : GNUI.Render.Sprite
local Quad = {}
Quad.__index = Quad


function Quad.new()
	local self = {
		pos = vec(0,0),
		size = vec(0,0)
	}
	setmetatable(self, Quad)
	return self
end


---comment
---@param x number
---@param y number
---@generic self
---@param self self
---@return self
function Quad:setPos(x,y)
	---@cast self Quad
	self.pos = vec(x,y)
	return self
end