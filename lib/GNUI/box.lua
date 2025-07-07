--[[______   __
  / ____/ | / /  by: GNanimates / https://gnon.top / Discord: @gn68s
 / / __/  |/ / name: GNUI Box
/ /_/ / /|  /  desc: representation of a box on the screen
\____/_/ |_/ source: link ]]

local Class = require"../GNClass"
local Event = require"../event"
local utils = require"./utils" ---@type GNUI.UtilsAPI
local Sprite = require"./sprite" ---@type GNUI.SpriteAPI
local Render = require("lib.GNUI.renderer") ---@type GNUI.RenderAPI



---@class GNUI.BoxAPI
local BoxAPI = {}


---@class GNUI.Box
---@field protected extent Vector4
---@field protected anchor Vector4
---@field protected dimensions Vector4
---@field protected sprite GNUI.Sprite?
---@field protected screen GNUI.Screen?
---@field protected parent GNUI.Box?
---@field protected children GNUI.Box[]
---@field protected childIndex integer
---@field protected flagUpdate boolean
---
---@field EXTENT_CHANGED Event
---@field ANCHOR_CHANGED Event
---@field DIMENSIONS_CHANGED Event
---@field SPRITE_CHANGED Event
---@field SCREEN_CHANGED Event
---@field PARENT_CHANGED Event
---@field CHILDREN_CHANGED Event
---@field FLAG_UPDATE_CHANGED Event
---@field CHILD_INDEX_CHANGED Event
---
---@field getAnchor fun(self: self): Vector4
---@field getExtent fun(self: self): Vector4
---@field getDimensions fun(self: self): Vector4
---@field getSprite fun(self: self): GNUI.Sprite
---@field getScreen fun(self: self): GNUI.Screen
---@field getParent fun(self: self): GNUI.Box?
---@field getChildren fun(self: self): GNUI.Box[]
---@field getChildIndex fun(self: self): integer
---@field getFlagUpdate fun(self: self): boolean
---
---@field protected __index function
local Box = {}
Box.__index = function(t,k)
	return rawget(t,k) or Box[k]
end
Box.__type = "GNUI.Box"

local vec4 = vectors.vec4

---@return GNUI.Box
function BoxAPI.new(cfg)
	cfg = cfg or {}
	local new = Class.apply({},Box)
	new.extent = vec4()
	new.anchor = vec4()
	new.dimensions = vec4()
	new.children = {}
	new.flagUpdate = true
	Render.setup(new)
	for key, value in pairs(cfg) do
		new[key] = value
	end
	
	return new
end


---Sets the extent of the box.
---@param x number|Vector2|Vector4
---@param y number|Vector2?
---@param z number?
---@param w number?
---@return self
function Box:setExtent(x,y,z,w)
	---@cast self GNUI.Box
	self.extent = utils.vec4(x,y,z,w)
	self.flagUpdate = true
	return self
end


---Sets the anchor of the box.
---@param x number|Vector2|Vector4
---@param y number|Vector2?
---@param z number?
---@param w number?
---@generic self
---@param self self
---@return self
function Box:setAnchor(x,y,z,w)
	---@cast self GNUI.Box
	self.anchor = utils.vec4(x,y,z,w)
	self.flagUpdate = true
	return self
end


---@param sprite GNUI.Sprite|Texture
---@generic self
---@param self self
---@return self
function Box:setSprite(sprite)
	---@cast self GNUI.Box
	local t = type(sprite)
	if t == "Texture" then
		self.sprite = Sprite.new(sprite)
	elseif t == "GNUI.Sprite" then
		self.sprite = sprite
	else
		self.sprite = nil
	end
	self.flagUpdate = true
	return self
end


---@generic self
---@param self self
---@return self
function Box:setParent(parent)
	---@cast self GNUI.Box
	if parent then
		parent:addChild(self)
	else
		self.parent = nil
	end
	return self
end


---@generic self
---@param self self
---@return self
function Box:addChild(child)
	---@cast self GNUI.Box
	if child.parent then
		child.parent:removeChild(child)
	end
	child.parent = self
	local childIndex = #self.children + 1
	self.children[childIndex] = child
	child.childIndex = childIndex
	
	self.flagUpdate = true
	return self
end

---@generic self
---@param self self
---@return self
function Box:removeChild(child)
	---@cast self GNUI.Box
	if child.parent == self then
		table.remove(self.children,child.childIndex)
		child:setParent(nil)
		child.childIndex = -1
	end
	return self
end

---@generic self
---@param self self
---@return self
---@param children GNUI.Box[]
function Box:setChildren(children)
	---@cast self GNUI.Box
	for _, child in pairs(children) do
		self:removeChild(child)
	end
	self.children = {}
	for _, child in pairs(children) do
		self:addChild(child)
	end
	self.flagUpdate = true
	return self
end


---Updates the box dimensions.
---@generic self
---@param self self
---@return self
function Box:update()
	---@cast self GNUI.Box
	self.flagUpdate = false
	local dim = self.extent:copy()
	if self.parent then
		local pDim = self.parent:getDimensions()
		dim.x = dim.x + math.lerp(pDim.x,pDim.z,self.anchor.x)
		dim.y = dim.y + math.lerp(pDim.y,pDim.w,self.anchor.y)
		dim.z = dim.z + math.lerp(pDim.x,pDim.z,self.anchor.z)
		dim.w = dim.w + math.lerp(pDim.y,pDim.w,self.anchor.w)
	end
	self.dimensions = dim
	return self
end

BoxAPI.methods = Box
return BoxAPI