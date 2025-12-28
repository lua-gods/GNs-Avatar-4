---@class GNUI.RenderAPI
local RenderAPI = {}
RenderAPI.__index = RenderAPI

---An abstract class for all the renderers for GNUI
---@class GNUI.Render
---@field canvas GNUI.Canvas


---A Figura GNUI renderer
---@class GNUI.Render.Figura : GNUI.Render
local Render = {}
Render.__index = Render


---A base class for all sprites for boxes
---@class GNUI.Render.Sprite
---@field pos Vector3
---@field size Vector2


---Creates a new render instance of a
---@param data table|GNUI.Render
function RenderAPI.new(data)
	local self = {
		canvas = data.canvas
	}
	setmetatable(self, RenderAPI)
	return self
end


return RenderAPI