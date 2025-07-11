--[[______   __
  / ____/ | / /  by: GNanimates / https://gnon.top / Discord: @gn68s
 / / __/  |/ / name: GNUI Box
/ /_/ / /|  /  desc: representation of a box on the screen
\____/_/ |_/ source: link ]]

--local Class = require"../GNClass"
local Event = require"../event" ---@type Event
local utils = require"./utils" ---@type GNUI.UtilsAPI
local Sprite = require"./sprite" ---@type GNUI.SpriteAPI
local Render = require("lib.GNUI.renderer") ---@type GNUI.RenderAPI


local IMMIDIATE_UPDATE_MODE = false


---@class GNUI.BoxAPI
local BoxAPI = {}


---@class GNUI.Box
---@field protected extent Vector4
---@field EXTENT_CHANGED Event
---@field protected anchor Vector4
---@field ANCHOR_CHANGED Event
---@field protected dimensions Vector4
---@field DIMENSIONS_CHANGED Event
---@field protected sprite GNUI.Sprite?
---@field SPRITE_CHANGED Event
---@field protected screen GNUI.Screen?
---@field SCREEN_CHANGED Event
---@field protected parent GNUI.Box?
---@field PARENT_CHANGED Event
---@field protected children GNUI.Box[]
---@field CHILDREN_CHANGED Event
---@field CHILD_ADDED Event
---@field CHILD_REMOVED Event
---@field protected childIndex integer
---@field CHILD_INDEX_CHANGED Event
---@field protected flagUpdate boolean
---@field FLAGGED_UPDATE Event
---
---@field protected __index function
local Box = {}
Box.__index = function(t,k)
	return rawget(t,k) or Box[k]
end
Box.__type = "GNUI.Box"

local vec4 = vectors.vec4

---@return GNUI.Box
function BoxAPI.new(cfg) --TODO: Bring back config support
	cfg = cfg or {}
	local new = {}
	new.extent = vec4()      new.EXTENT_CHANGED = Event.new()
	new.anchor = vec4()      new.ANCHOR_CHANGED = Event.new()
	new.dimensions = vec4()  new.DIMENSIONS_CHANGED = Event.new()
	new.children = {}        new.CHILDREN_CHANGED = Event.new()
	new.sprite = nil         new.SPRITE_CHANGED = Event.new()
	new.screen = nil         new.SCREEN_CHANGED = Event.new()
	new.parent = nil         new.PARENT_CHANGED = Event.new()
	new.childIndex = 0       new.CHILD_INDEX_CHANGED = Event.new()
	new.flagUpdate = false   new.FLAGGED_UPDATE = Event.new()
	new.CHILD_ADDED = Event.new() new.CHILD_REMOVED = Event.new()
	setmetatable(new,Box)
	Render.setup(new)
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
	self.EXTENT_CHANGED:invoke()
	self.extent = utils.vec4(x,y,z,w)
	self:update()
	return self
end

function Box:getExtent()
	return self.extent
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
	self:update()
	return self
end

function Box:getAnchor()
	return self.anchor
end



function Box:getDimensions()
	return self.dimensions
end


---@param sprite GNUI.Sprite|Texture
---@generic self
---@param self self
---@return self
function Box:setSprite(sprite)
	---@cast self GNUI.Box
	local lastSprite = self.sprite
	local t = type(sprite)
	if t == "Texture" then
		self.sprite = Sprite.new(sprite)
	else
		self.sprite = sprite
	end
	self.SPRITE_CHANGED:invoke(sprite, lastSprite)
	self:update()
	return self
end

function Box:getSprite()
	return self.sprite
end

---@generic self
---@param self self
---@return self
function Box:setParent(parent)
	---@cast self GNUI.Box
	local lastParent = self.parent
	if parent then
		parent:addChild(self)
	else
		self.parent = nil
	end
	if lastParent ~= parent then
		self.PARENT_CHANGED:invoke(parent,lastParent)
	end
	return self
end

function Box:getParent()
	return self.parent
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
	self.CHILD_ADDED:invoke(child)
	self:update()
	return self
end

function Box:getChildren()
	return self.children
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
	self:update()
	return self
end


function Box:update()
	if IMMIDIATE_UPDATE_MODE then
		self:forceUpdate()
	else
		if not self.flagUpdate then
			self.flagUpdate = true
			self.FLAGGED_UPDATE:invoke()
		end
	end
end


---Updates the box dimensions.
---@generic self
---@param self self
---@return self
function Box:forceUpdate()
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
	self.DIMENSIONS_CHANGED:invoke(dim)
	return self
end

BoxAPI.methods = Box
return BoxAPI