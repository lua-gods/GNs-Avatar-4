---@diagnostic disable: invisible
--[[______   __
  / ____/ | / /  by: GNanimates / https://gnon.top / Discord: @gn68s
 / / __/  |/ / name: GNUI RenderAPI [Figura 0.1.6]
/ /_/ / /|  /  desc: handles all the rendering
\____/_/ |_/ source: link ]]
local utils = require"./utils" ---@type GNUI.UtilsAPI



---@class GNUI.RenderAPI
local RenderAPI = {}


---@class GNUI.RenderState
---@field box GNUI.Box
---@field model ModelPart
---@field protected __index function
local Renderer = {}
Renderer.__index = function (t,k)
	return rawget(t,k) or Renderer[k]
end

local nextFree = 0

local renderStates = {} ---@type table<GNUI.Box, GNUI.RenderState>
local queueUpdate = {} ---@type table<GNUI.Box, GNUI.RenderState>

---@param box GNUI.Box
local function setup(box)
	nextFree = nextFree + 1
	
	--[────────────────────────-< Figura Specific Code >-────────────────────────]--
	local model = models:newPart("Display"..nextFree,"HUD"):light(15,15)
	model:setParentType("HUD")
	
	local renderState = {
		box = box,
		model = model,
		dirt = model:newBlock("dirt"):block("minecraft:glass"):scale(1,1,0)
	}
	renderStates[box] = renderState
	
	box.FLAG_UPDATE_CHANGED:register(function (update)
		if update then queueUpdate[box] = renderState end
	end)
	
	box.DIMENSIONS_CHANGED:register(function (dim)
		local size = utils.vec4GetSize(dim)*0.0625
		local pOffset = box.parent and box.parent.dimensions.xy or vec(0,0)
		
		renderState.dirt:scale(-size.x,-size.y,1)
		renderState.model:setPos(-dim.x+pOffset.x,-dim.y+pOffset.y)
	end)
	
	---@param parent GNUI.Box?
	box.PARENT_CHANGED:register(function (parent)
		if parent then
			local parentRenderState = renderStates[parent]
			renderState.model:moveTo(parentRenderState.model):setParentType("None")
		end
	end)
	
	box.flagUpdate = true
	
	--[────────────────────────-< End of Figura Code >-────────────────────────]--
	
	for i, child in ipairs(box:getChildren()) do
		setup(child)
	end
end

--[────────────────────────-< Figura Specific Code >-────────────────────────]--

models:newPart("GNUI.process","WORLD").midRender = function ()
	for box, renderState in pairs(queueUpdate) do
		box.flagUpdate = false
		box:update()
		for key, child in pairs(box:getChildren()) do
			child.flagUpdate = true
		end
	end
end

--[────────────────────────-< End of Figura Code >-────────────────────────]--


---@param box GNUI.Box
function RenderAPI.setup(box) setup(box) end

return RenderAPI