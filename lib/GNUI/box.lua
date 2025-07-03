--[[______   __
  / ____/ | / /  by: GNanimates / https://gnon.top / Discord: @gn68s
 / / __/  |/ / name: GNUI Box
/ /_/ / /|  /  desc: representation of a box on the screen
\____/_/ |_/ source: link ]]

local Class = require"../GNClass"
local Event = require"../event"
local utils = require"./utils" ---@type GNUI.UtilsAPI

---@class GNUI.BoxAPI
local API = {}

---@class GNUI.Box
---@field protected extent Vector4
---@field EXTENT_CHANGED Event
---@field protected anchor Vector4
---@field ANCHOR_CHANGED Event
---@field protected dimensions Vector4
---@field DIMENSIONS_CHANGED Event
---@field protected sprite GNUI.Sprite?
---@field SPRITE_CHANGED Event
---@field protected __index function
local Box = {}
Box.__index = function(t,k)
	return rawget(t,k) or Box[k]
end

---@return GNUI.Box
function API.new()
	local self = Class.apply{
		extent = vec(0,0,0,0),
		anchor = vec(0,0,0,0),
	}
	setmetatable(self,Box)
	return self
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
	self.EXTENT_CHANGED:invoke()
	return self
end


---Returns the current extent of the box.
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
	self.ANCHOR_CHANGED:invoke()
	return self
end


---Returns the current anchor of the box.
---@return Vector4
function Box:getAnchor()
	return self.anchor
end





return API