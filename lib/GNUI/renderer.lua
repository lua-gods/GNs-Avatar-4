
---@diagnostic disable: invisible
--[[______   __
  / ____/ | / /  by: GNanimates / https://gnon.top / Discord: @gn68s
 / / __/  |/ / name: GNUI RenderAPI [Figura 0.1.6]
/ /_/ / /|  /  desc: handles all the rendering
\____/_/ |_/ source: link ]]
local utils = require"./utils" ---@type GNUI.UtilsAPI


---@class GNUI.RenderAPI
local RenderAPI = {}


local nextFree = 0

---@class GNUI.RenderState.Figura.UpdateFlags
---@field dimensions boolean
---@field sprite boolean

---@class GNUI.RenderState
---@field box GNUI.Box
---@field model ModelPart
---@field dirt BlockTask
---@field sprite SpriteTask
---@field updateFlags GNUI.RenderState.Figura.UpdateFlags
---@field protected __index function
local RenderState = {}
RenderState.__index = function (t,k)
	return rawget(t,k) or RenderState[k]
end

function RenderState:resize()
	local spriteData = self.box.sprite
	if self.sprite then
		local res = self.box.sprite.texture:getDimensions()
		local UV = spriteData.uv:copy():add(0,0,1,1)
		local scale = 1 --self.Scale
		local visible = true --self.box.visible
		local size = utils.vec4GetSize(self.box.dimensions)
		local pos = vec(spriteData.expand.x*scale,spriteData.expand.y*scale,0)
		local size = size+(spriteData.expand.xy+spriteData.expand.zw)*scale
		local sBorder = spriteData.border*scale --scaled border, used in rendering
		local border = spriteData.border				 --border, used in UVs
		local uvSize = vec(UV.z-UV.x,UV.w-UV.y)
		for _, task in pairs(self.sprite) do
			task
			:setColor(vec(1,1,1):augmented(1))
		end
		self.sprite[1]
		:setPos(
			pos
		):setScale(
			sBorder.x/res.x,
			sBorder.y/res.y,0
		):setUVPixels(
			UV.x,
			UV.y
		):region(
			border.x,
			border.y
		):setVisible(visible)
		
		self.sprite[2]
		:setPos(
			pos.x-sBorder.x,
			pos.y,
			pos.z
		):setScale(
			(size.x-sBorder.z-sBorder.x)/res.x,
			sBorder.y/res.y,0
		):setUVPixels(
			UV.x+border.x,
			UV.y
		):region(
			uvSize.x-border.x-border.z,
			border.y
		):setVisible(visible)
	
		self.sprite[3]
		:setPos(
			pos.x-size.x+sBorder.z,
			pos.y,
			pos.z
		):setScale(
			sBorder.z/res.x,sBorder.y/res.y,0
		):setUVPixels(
			UV.z-border.z,
			UV.y
		):region(
			border.z,
			border.y
		):setVisible(visible)
	
		self.sprite[4]
		:setPos(
			pos.x,
			pos.y-sBorder.y,
			pos.z
		):setScale(
			sBorder.x/res.x,
			(size.y-sBorder.y-sBorder.w)/res.y,0
		):setUVPixels(
			UV.x,
			UV.y+border.y
		):region(
			border.x,
			uvSize.y-border.y-border.w
		):setVisible(visible)
		self.sprite[5]
		:setPos(
			pos.x-sBorder.x,
			pos.y-sBorder.y,
			pos.z
		)
		:setScale(
			(size.x-sBorder.x-sBorder.z)/res.x,
			(size.y-sBorder.y-sBorder.w)/res.y,0
		):setUVPixels(
			UV.x+border.x,
			UV.y+border.y
		):region(
			uvSize.x-border.x-border.z,
			uvSize.y-border.y-border.w
		):setVisible(visible)
	
		self.sprite[6]
		:setPos(
			pos.x-size.x+sBorder.z,
			pos.y-sBorder.y,
			pos.z
		)
		:setScale(
			sBorder.z/res.x,
			(size.y-sBorder.y-sBorder.w)/res.y,0
		):setUVPixels(
			UV.z-border.z,
			UV.y+border.y
		):region(
			border.z,
			uvSize.y-border.y-border.w
		):setVisible(visible)
		
		
		self.sprite[7]
		:setPos(
			pos.x,
			pos.y-size.y+sBorder.w,
			pos.z
		)
		:setScale(
			sBorder.x/res.x,
			sBorder.w/res.y,0
		):setUVPixels(
			UV.x,
			UV.w-border.w
		):region(
			border.x,
			border.w
		):setVisible(visible)
	
		self.sprite[8]
		:setPos(
			pos.x-sBorder.x,
			pos.y-size.y+sBorder.w,
			pos.z
		):setScale(
			(size.x-sBorder.z-sBorder.x)/res.x,
			sBorder.w/res.y,0
		):setUVPixels(
			UV.x+border.x,
			UV.w-border.w
		):region(
			uvSize.x-border.x-border.z,
			border.w
		):setVisible(visible)
	
		self.sprite[9]
		:setPos(
			pos.x-size.x+sBorder.z,
			pos.y-size.y+sBorder.w,
			pos.z
		):setScale(
			sBorder.z/res.x,
			sBorder.w/res.y,0
		):setUVPixels(
			UV.z-border.z,
			UV.w-border.w
		):region(
			border.z,
			border.w
		):setVisible(visible)
	end
end



function RenderState:updateSprite()
	if self.sprite then
		self.sprite:remove()
		self.sprite = nil
	end
	local spriteData = self.box.sprite
	if spriteData then
		local dim = spriteData.texture:getDimensions()
		local spriteTasks = {}
		for i = 1, 9, 1 do
			spriteTasks[i] = self.model
			:newSprite("sprite"..i)
			:setRenderType("CUTOUT_EMISSIVE_SOLID")
			:setTexture(spriteData.texture,dim.x,dim.y)
		end
		self.sprite = spriteTasks
	end
end

local renderStates = {} ---@type table<GNUI.Box, GNUI.RenderState>



local queueUpdate = {} ---@type table<GNUI.Box, GNUI.RenderState>





---@param box GNUI.Box
local function setup(box)
	nextFree = nextFree + 1
	
	--[────────────────────────-< Figura Specific Code >-────────────────────────]--
	local model = models:newPart("Display"..nextFree,"HUD"):light(15,15)
	model:setParentType("HUD")
	
	local rs = {
		box = box,
		model = model,
		dirt = model:newBlock("dirt"):block("minecraft:glass"):setPos(0,0,16),
		updateFlags = {
		}
	}
	setmetatable(rs,RenderState)
	renderStates[box] = rs
	---@cast rs GNUI.RenderState
	
	box.FLAGGED_UPDATE:register(function ()
		queueUpdate[box] = rs
	end)
	
	---@param sprite GNUI.Sprite
	---@param lastSprite GNUI.Sprite
	box.SPRITE_CHANGED:register(function (sprite,lastSprite)
		rs.updateFlags.sprite = true
		rs.updateFlags.dimensions = true
	end)
	
	
	box.DIMENSIONS_CHANGED:register(function (dim)
		local size = utils.vec4GetSize(dim)
		local pOffset = box.parent and box.parent.dimensions.xy or vec(0,0)
		rs.dirt:scale(-size.x*0.0625,-size.y*0.0625)
		rs.model:setPos(-dim.x+pOffset.x,-dim.y+pOffset.y)
		rs.updateFlags.dimensions = true
	end)
	
	
	---@param parent GNUI.Box?
	box.PARENT_CHANGED:register(function (parent)
		if parent then
			local parentRenderState = renderStates[parent]
			rs.model:moveTo(parentRenderState.model):setParentType("None")
		end
	end)
	
	box:update()
	
	--[────────────────────────-< End of Figura Code >-────────────────────────]--
	for i, child in ipairs(box:getChildren()) do
		setup(child)
	end
end

--[────────────────────────-< Figura Specific Code >-────────────────────────]--

models:newPart("GNUI.process","WORLD").midRender = function ()
	for box, renderState in pairs(queueUpdate) do
		box.flagUpdate = false
		box:forceUpdate()
		
		local updateFlags = renderState.updateFlags
		if updateFlags.sprite then
			renderState:updateSprite()
			updateFlags.sprite = false
		end
		
		
		if updateFlags.dimensions then
			renderState:resize()
			updateFlags.dimensions = false
		end
		
		
		for key, child in pairs(box:getChildren()) do
			child:forceUpdate()
		end
	end
	queueUpdate = {}
end

--[────────────────────────-< End of Figura Code >-────────────────────────]--


---@param box GNUI.Box
function RenderAPI.setup(box) setup(box) end

return RenderAPI