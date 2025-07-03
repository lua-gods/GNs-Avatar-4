---@diagnostic disable: param-type-mismatch
--[[______	 __
	/ ____/ | / /	by: GNanimates / https://gnon.top / Discord: @gn68s
 / / __/	|/ / name: Nineslice
/ /_/ / /|	/	desc: made specifically for GNUI
\____/_/ |_/ source: link ]]
local default_texture = textures["1x1white"] or textures:newTexture("1x1white",1,1):setPixel(0,0,vec(1,1,1))
local cfg = require("./config")
local eventLib,utils = cfg.event, cfg.utils

local update = {}


---@class Nineslice.Style
---@field texture Texture # the texture of the sprite
---@field uv Vector4 # the UV of the texture in the sprite, in the form (x,y,z,w) with each unit is a pixel
---
---@field color Vector3 # The tint applied to the sprite.
---@field alpha number # The opacity of the sprite.
---@field scale number # The scale of the borders of a 9-slice.
---
---@field renderType ModelPart.renderType # the render type of the sprite.
---@field border Vector4 # the thickness of the border in the form (left, top, right, bottom)
---@field expand Vector4 # the expansion of the border in the form (left, top, right, bottom)
---
---@field excludeMiddle boolean # if true, the middle of the sprite will not be rendered
---@field DepthOffset number # the depth offset of the sprite
---@field visible boolean # if true, the sprite will be rendered


---@class ModelPart.Nineslice # a representation of a sprite / 9-slice sprite in GNUI
---@field style Nineslice.Style # the texture of the sprite
---@field STYLE_CHANGED Event
---@field Modelpart ModelPart? # the `ModelPart` used to handle where to display debug features and the sprite.
---@field MODELPART_CHANGED Event
---@field pos Vector2 # the position of the sprite.
---@field size Vector2 # the size of the sprite.
---@field package _queue_update boolean
local Nineslice = {}
Nineslice.__index = Nineslice
Nineslice.__type = "Sprite"

local sprite_next_free = 0
---@return ModelPart.Nineslice
function Nineslice.new(data)
	local new = {}
	setmetatable(new,Nineslice)
	new.texture = default_texture
	new.TEXTURE_CHANGED = eventLib.new()
	new.MODELPART_CHANGED = eventLib.new()
	new.pos = vec(0,0)
	new.DepthOffset = 0
	--new.uv = vec(0,0,1,1)
	new.size = vec(0,0)
	new.a = 1
	new.color = vec(1,1,1)
	new.scale = 1
	new.DIMENSIONS_CHANGED = eventLib.new()
	new.renderTasks = {}
	new.renderType = "CUTOUT"
	new.borderThickness = vec(0,0,0,0)
	new.expand = vec(0,0,0,0)
	new.BORDER_THICKNESS_CHANGED = eventLib.new()
	new.BORDER_EXPAND_CHANGED = eventLib.new()
	new.excludeMiddle = false
	new.visible = true
	new.id = sprite_next_free
	sprite_next_free = sprite_next_free + 1
	
	new.TEXTURE_CHANGED:register(function ()
		new:deleteRenderTasks()
		new:buildRenderTasks()
		new:update()
	end,cfg.internal_events_name)

	new.BORDER_THICKNESS_CHANGED:register(function ()
		new:deleteRenderTasks()
		new:buildRenderTasks()
	end,cfg.internal_events_name)
	
	new.DIMENSIONS_CHANGED:register(function ()
		new:update()
	end,cfg.internal_events_name)
	
	if data then
		for key, value in pairs(data) do
			local setter = "set"..key:gsub("^.",string.upper)
			if new[setter] then
				new[setter](new,value)
			else
				new[key] = value
			end
		end
	end
	
	return new
end

---Sets the modelpart to parent to.
---@param part ModelPart?
---@return ModelPart.Nineslice
function Nineslice:setModelpart(part)
	self:deleteRenderTasks()
	self.Modelpart = part
	
	if self.Modelpart then
		self:buildRenderTasks()
	end
	self.MODELPART_CHANGED:invoke(self.Modelpart)
	return self
end


---Sets the displayed image texture on the sprite.
---@param texture Texture
---@return ModelPart.Nineslice
function Nineslice:setTexture(texture)
	if type(texture) ~= "Texture" then error("Invalid texture, recived "..type(texture)..".",2) end
	self.texture = texture
	local dim = texture:getDimensions()
	if not self.uv then
		self.uv = vec(0,0,dim.x-1,dim.y-1)
	end
	self.TEXTURE_CHANGED:invoke(self,self.texture)
	return self
end

---Sets the position of the Sprite, relative to its parent.
---@param xpos number
---@param y number
---@return ModelPart.Nineslice
function Nineslice:setPos(xpos,y)
	self.pos = utils.vec2(xpos,y)
	self.DIMENSIONS_CHANGED:invoke(self,self.pos,self.size)
	return self
end

---Tints the Sprite multiplicatively
---@param r number|Vector3
---@param g number?
---@param b number?
---@return ModelPart.Nineslice
function Nineslice:setColor(r,g,b)
	self.color = utils.vec3(r,g,b)
	self.DIMENSIONS_CHANGED:invoke(self,self.pos,self.size)
	return self
end


---@param a number
---@return ModelPart.Nineslice
function Nineslice:setOpacity(a)
	self.a = math.clamp(a or 1,0,1)
	self.DIMENSIONS_CHANGED:invoke(self,self.pos,self.size)
	return self
end
Nineslice.setAlpha = Nineslice.setOpacity

---Sets the size of the sprite duh.
---@param xpos number|Vector2
---@param y number?
---@return ModelPart.Nineslice
function Nineslice:setSize(xpos,y)
	self.size = utils.vec2(xpos,y)
	self.DIMENSIONS_CHANGED:invoke(self,self.pos,self.size)
	return self
end

---@param scale number
---@return ModelPart.Nineslice
function Nineslice:setScale(scale)
	self.scale = scale
	self.BORDER_THICKNESS_CHANGED:invoke(self,self.borderThickness)
	return self
end

-->====================[ Border ]====================<--

---Sets the top border thickness.
---@param units number?
---@return ModelPart.Nineslice
function Nineslice:setBorderTop(units)
	self.borderThickness.y = units or 0
	self.BORDER_THICKNESS_CHANGED:invoke(self,self.borderThickness)
	return self
end

---Sets the left border thickness.
---@param units number?
---@return ModelPart.Nineslice
function Nineslice:setBorderLeft(units)
	self.borderThickness.x = units or 0
	self.BORDER_THICKNESS_CHANGED:invoke(self,self.borderThickness)
	return self
end

---Sets the down border thickness.
---@param units number?
---@return ModelPart.Nineslice
function Nineslice:setBorderBottom(units)
	self.borderThickness.w = units or 0
	self.BORDER_THICKNESS_CHANGED:invoke(self,self.borderThickness)
	return self
end

---Sets the right expansion.
---@param units number?
---@return ModelPart.Nineslice
function Nineslice:setBorderRight(units)
	self.borderThickness.z = units or 0
	self.BORDER_THICKNESS_CHANGED:invoke(self,self.borderThickness)
	return self
end




---Sets the expansion.
---@param left number?
---@param top number?
---@param right number|Vector2
---@param bottom number|Vector2|Vector3
---@return ModelPart.Nineslice
function Nineslice:setExpand(left,top,right,bottom)
	local expand = utils.vec4(
	left or self.expand.x,
	top or self.expand.y,
	right or self.expand.z,
	bottom or self.expand.w)
	self.expand = expand
	self.BORDER_EXPAND_CHANGED:invoke(self,self.expand)
	return self
end

---Sets the top expansion.
---@param units number?
---@return ModelPart.Nineslice
function Nineslice:setExpandTop(units)
	self.expand.y = units or 0
	self.BORDER_EXPAND_CHANGED:invoke(self,self.expand)
	return self
end

---Sets the left expansion.
---@param units number?
---@return ModelPart.Nineslice
function Nineslice:setExpandLeft(units)
	self.expand.x = units or 0
	self.BORDER_EXPAND_CHANGED:invoke(self,self.expand)
	return self
end

---Sets the down expansion.
---@param units number?
---@return ModelPart.Nineslice
function Nineslice:setExpandBottom(units)
	self.expand.w = units or 0
	self.BORDER_EXPAND_CHANGED:invoke(self,self.expand)
	return self
end

---Sets the right expansion.
---@param units number?
---@return ModelPart.Nineslice
function Nineslice:setExpandRight(units)
	self.expand.z = units or 0
	self.BORDER_EXPAND_CHANGED:invoke(self,self.expand)
	return self
end


---Sets the padding for all sides.
---@param left number?
---@param top number?
---@param right number?
---@param bottom number?
---@return ModelPart.Nineslice
function Nineslice:setBorderThickness(left,top,right,bottom)
	self.borderThickness.x = left	or 0
	self.borderThickness.y = top	 or 0
	self.borderThickness.z = right	or 0
	self.borderThickness.w = bottom or 0
	self.BORDER_THICKNESS_CHANGED:invoke(self,self.borderThickness)
	return self
end

---Sets the UV region of the sprite.
--- if x2 and y2 are missing, they will use x and y as a substitute
---@param x number|Vector2|Vector4
---@param y number|Vector2
---@param x2 number?
---@param y2 number?
---@return ModelPart.Nineslice
function Nineslice:setUV(x,y,x2,y2)
	self.uv = utils.vec4(x,y,x2 or x,y2 or y)
	self.DIMENSIONS_CHANGED:invoke(self.borderThickness)
	return self
end

---Sets the render type of your sprite
---@param renderType ModelPart.renderType
---@return ModelPart.Nineslice
function Nineslice:setRenderType(renderType)
	self.renderType = renderType
	self:deleteRenderTasks()
	self:buildRenderTasks()
	return self
end

---Set to true if you want a hole in the middle of your ninepatch
---@param toggle boolean
---@return ModelPart.Nineslice
function Nineslice:setExcludeMiddle(toggle)
	self.excludeMiddle = toggle
	return self
end

function Nineslice:copy()
	local copy = {}
	for key, value in pairs(self) do
		if type(value):find("Vector") then
			value = value:copy()
		end
		copy[key] = value
	end
	return Nineslice.new(copy)
end

function Nineslice:setVisible(visibility)
	self.visible = visibility
	self:update()
	return self
end

function Nineslice:setDepthOffset(offset_units)
	self.DepthOffset = offset_units
	return self
end

function Nineslice:update()
	if not self._queue_update then
		self._queue_update = true
		update[#update+1] = self
	end
end

function Nineslice:deleteRenderTasks()
	if self.Modelpart then
		for _, task in pairs(self.renderTasks) do
			self.Modelpart:removeTask(task:getName())
		end
	end
	return self
end

function Nineslice:free()
	self:deleteRenderTasks()
	return self
end

function Nineslice:buildRenderTasks()
	if not self.Modelpart then return self end
	local b = self.borderThickness
	local d = self.texture:getDimensions()
	self.is_nineslice = not (b.x == 0 and b.y == 0 and b.z == 0 and b.w == 0)
	if not self.is_nineslice then -- not 9-Slice
		self.renderTasks[1] = self.Modelpart:newSprite(self.id.."slice"):setTexture(self.texture,d.x,d.y)
	else
		self.renderTasks = {
			self.Modelpart:newSprite(self.id.."slice_tl"),
			self.Modelpart:newSprite(self.id.."slice_t" ),
			self.Modelpart:newSprite(self.id.."slice_tr"),
			self.Modelpart:newSprite(self.id.."slice_ml"),
			self.Modelpart:newSprite(self.id.."slice_m" ),
			self.Modelpart:newSprite(self.id.."slice_mr"),
			self.Modelpart:newSprite(self.id.."slice_bl"),
			self.Modelpart:newSprite(self.id.."slice_b" ),
			self.Modelpart:newSprite(self.id.."slice_br"),
		}
		for i = 1, 9, 1 do
			self.renderTasks[i]:setTexture(self.texture,d.x,d.y):setVisible(false)
		end
	end
	self:update()
end

function Nineslice:updateRenderTasks()
	if not self.Modelpart then return self end
	local res = self.texture:getDimensions()
	local uv = self.uv:copy():add(0,0,1,1)
	local s = self.scale
	local pos = vec(self.pos.x+self.expand.x*s,self.pos.y+self.expand.y*s,self.DepthOffset)
	local size = self.size+(self.expand.xy+self.expand.zw)*s
	if not self.is_nineslice then
		self.renderTasks[1]
		:setPos(pos)
		:setScale(size.x/res.x,size.y/res.y,0)
		:setColor(self.color:augmented(self.a))
		:setRenderType(self.renderType)
		:setUVPixels(
			uv.x,
			uv.y
		):region(
			uv.z-uv.x,
			uv.w-uv.y
		):setVisible(self.visible)
	else
		local sborder = self.borderThickness*self.scale --scaled border, used in rendering
		local border = self.borderThickness				 --border, used in UVs
		local uvsize = vec(uv.z-uv.x,uv.w-uv.y)
		for _, task in pairs(self.renderTasks) do
			task
			:setColor(self.color:augmented(self.a))
			:setRenderType(self.renderType)
		end
		self.renderTasks[1]
		:setPos(
			pos
		):setScale(
			sborder.x/res.x,
			sborder.y/res.y,0
		):setUVPixels(
			uv.x,
			uv.y
		):region(
			border.x,
			border.y
		):setVisible(self.visible)
		
		self.renderTasks[2]
		:setPos(
			pos.x-sborder.x,
			pos.y,
			pos.z
		):setScale(
			(size.x-sborder.z-sborder.x)/res.x,
			sborder.y/res.y,0
		):setUVPixels(
			uv.x+border.x,
			uv.y
		):region(
			uvsize.x-border.x-border.z,
			border.y
		):setVisible(self.visible)

		self.renderTasks[3]
		:setPos(
			pos.x-size.x+sborder.z,
			pos.y,
			pos.z
		):setScale(
			sborder.z/res.x,sborder.y/res.y,0
		):setUVPixels(
			uv.z-border.z,
			uv.y
		):region(
			border.z,
			border.y
		):setVisible(self.visible)

		self.renderTasks[4]
		:setPos(
			pos.x,
			pos.y-sborder.y,
			pos.z
		):setScale(
			sborder.x/res.x,
			(size.y-sborder.y-sborder.w)/res.y,0
		):setUVPixels(
			uv.x,
			uv.y+border.y
		):region(
			border.x,
			uvsize.y-border.y-border.w
		):setVisible(self.visible)
		if not self.excludeMiddle then
			self.renderTasks[5]
			:setPos(
				pos.x-sborder.x,
				pos.y-sborder.y,
				pos.z
			)
			:setScale(
				(size.x-sborder.x-sborder.z)/res.x,
				(size.y-sborder.y-sborder.w)/res.y,0
			):setUVPixels(
				uv.x+border.x,
				uv.y+border.y
			):region(
				uvsize.x-border.x-border.z,
				uvsize.y-border.y-border.w
			):setVisible(self.visible)
		else
			self.renderTasks[5]:setVisible(false)
		end

		self.renderTasks[6]
		:setPos(
			pos.x-size.x+sborder.z,
			pos.y-sborder.y,
			pos.z
		)
		:setScale(
			sborder.z/res.x,
			(size.y-sborder.y-sborder.w)/res.y,0
		):setUVPixels(
			uv.z-border.z,
			uv.y+border.y
		):region(
			border.z,
			uvsize.y-border.y-border.w
		):setVisible(self.visible)
		
		
		self.renderTasks[7]
		:setPos(
			pos.x,
			pos.y-size.y+sborder.w,
			pos.z
		)
		:setScale(
			sborder.x/res.x,
			sborder.w/res.y,0
		):setUVPixels(
			uv.x,
			uv.w-border.w
		):region(
			border.x,
			border.w
		):setVisible(self.visible)

		self.renderTasks[8]
		:setPos(
			pos.x-sborder.x,
			pos.y-size.y+sborder.w,
			pos.z
		):setScale(
			(size.x-sborder.z-sborder.x)/res.x,
			sborder.w/res.y,0
		):setUVPixels(
			uv.x+border.x,
			uv.w-border.w
		):region(
			uvsize.x-border.x-border.z,
			border.w
		):setVisible(self.visible)

		self.renderTasks[9]
		:setPos(
			pos.x-size.x+sborder.z,
			pos.y-size.y+sborder.w,
			pos.z
		):setScale(
			sborder.z/res.x,
			sborder.w/res.y,0
		):setUVPixels(
			uv.z-border.z,
			uv.w-border.w
		):region(
			border.z,
			border.w
		):setVisible(self.visible)
	end
end

function Nineslice.updateAll()
	if #update > 0 then
		for i = 1, #update, 1 do
		 update[i]:updateRenderTasks()
		 update[i]._queue_update = nil
		end
		update = {}
 	end
end

models:newPart("GNUI:Nineslice").midRender = function ()
	Nineslice.updateAll()
end

return Nineslice