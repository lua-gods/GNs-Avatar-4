--[[______   __
  / ____/ | / /  by: GNanimates / https://gnon.top / Discord: @gn68s
 / / __/  |/ / name: GNUI Box
/ /_/ / /|  /  desc: representation of a box on the screen
\____/_/ |_/ source: link ]]

--local Class = require"../GNClass"
local Event = require("../../event") ---@type Event
local utils = require("../utils") ---@type GNUI.UtilsAPI
local Sprite = require("../visuals/sprite") ---@type GNUI.SpriteAPI
local config = require("../config") ---@type GNUI.Config


---@class GNUI.BoxAPI
local BoxAPI = {}

---@class GNUI.Box
---@field protected extent Vector4
---@field EXTENT_CHANGED Event
---@field protected anchor Vector4
---@field ANCHOR_CHANGED Event
---@field protected dimensions Vector4
---@field DIMENSIONS_CHANGED Event
---@field protected sprite GNUI.Quad.Style?
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
---@field protected __index function
local Box = {}
Box.__index = function(t,k)
	local ret = rawget(t,k) or Box[k]
	if ret then
		return ret
	elseif k:find("^get*") then -- Getter fallback
		local propertyName = k:match("^get(.+)"):gsub("^%u",string.lower)
		local function method(self)
			return self[propertyName]
		end
		BoxAPI[k] = method
		return method
	end
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
	new.visuals = {}
	new.screen = nil         new.SCREEN_CHANGED = Event.new()
	new.parent = nil         new.PARENT_CHANGED = Event.new()
	new.childIndex = 0       new.CHILD_INDEX_CHANGED = Event.new()
	new.flagUpdate = false   new.FLAGGED_UPDATE = Event.new()
	new.CHILD_ADDED = Event.new() new.CHILD_REMOVED = Event.new()
	new.lineLayers = {}
	setmetatable(new,Box)
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

---Returns the extent of this box
---@return Vector4
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


---Returns the anchor of this box.
---@return Vector4
function Box:getAnchor()
	return self.anchor
end


---Returns the dimensions of this box
---@return Vector4
function Box:getDimensions()
	return self.dimensions
end




---@generic self
---@param self self
---@return self
function Box:setParent(parent)
	---@cast self GNUI.Box
	if parent then
		if not self.parent then
			local lastParent = self.parent
			self.parent = parent
			self.screen = parent.screen
			if parent then
				self.childIndex = #parent.children + 1
				parent.children[self.childIndex] = self
			else
				self.childIndex = -1
			end
			if lastParent ~= parent then
				self.PARENT_CHANGED:invoke(parent,lastParent)
			end
			self.parent:update()
		else
			error("Box already has a parent",2)
		end
	else
		self.parent = nil
		self.screen = nil
	end
	return self
end


---Returns the parent of this box.
---@return GNUI.Box?
function Box:getParent()
	return self.parent
end


---@generic self
---@param self self
---@return self
---@param child GNUI.Box
function Box:addChild(child)
	---@cast self GNUI.Box
	if not child.parent then
		child:setParent(self)
		self.CHILD_ADDED:invoke(child)
		self:update()
	else
		error("Child already has a parent",2)
	end
	return self
end


---Returns a list of the children of this box.
---@return GNUI.Box[]
function Box:getChildren()
	return utils.shallowCopy(self.children)
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
		self.CHILD_REMOVED:invoke(child)
		self:update()
	else
		error("Child does not have this as parent",2)
	end
	return self
end


---@generic self
---@param self self
---@return self
---@param children GNUI.Box[]
function Box:setChildren(children)
	---@cast self GNUI.Box
	
	local beingRemoved = {}
	local beingAdded = {}
	-- create a fast lookup table
	for index, value in ipairs(self.children) do
		beingRemoved[value] = true
	end
	
	-- remove ones that are still in the list
	-- and add the ones that are not
	for _, child in pairs(children) do
		if beingRemoved[child] then
			beingRemoved[child] = nil
		else
			beingAdded[child] = true
		end
	end
	
	for _, child in pairs(beingRemoved) do self:removeChild(child) end
	self.children = {}
	for _, child in pairs(beingAdded) do self:addChild(child) end
	self:update()
	return self
end


---Returns the number of children of this box
---@return integer
function Box:getChildCount()
	---@cast self GNUI.Box
	return #self.children
end


function Box:update()
	if self.flagUpdate or not self.screen then return end
	self.flagUpdate = true
	
	--for _, child in ipairs(self.children) do child:update(true) end
	self.screen:queryUpdate(self)
	for _, child in ipairs(self.children) do child:update() end
end


---Called before the parent is updated.
---@generic self
---@param self self
---@return self
function Box:forcePreUpdate()
	-- TODO: min size goes here
	return self
end


---Updates the box dimensions.
---@generic self
---@param self self
---@return self
function Box:forcePostUpdate()
	---@cast self GNUI.Box
	--printTblColor(self)
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
	self.flagUpdate = false
	return self
end


function Box:update()
	
end


BoxAPI.methods = Box
return BoxAPI