--[[______   __
  / ____/ | / /  by: GNanimates / https://gnon.top / Discord: @gn68s
 / / __/  |/ / name: GNUI Sprite
/ /_/ / /|  /  desc: Renderer Subhandler
\____/_/ |_/ source: link ]]


local Event = require("../../event") ---@type Event
local utils = require("../utils") ---@type GNUI.UtilsAPI


---@class GNUI.QuadAPI
local SpriteAPI = {}


---@class GNUI.Visual.Quad : GNUI.Visual
---@field texture Texture
---@field border Vector4
---@field color Vector3
---@field alpha number
---@field uv Vector4
---@field expand Vector4
---@field scale number
---@field protected __index function
local Sprite = {}
Sprite.__index = function (t,k)
	return rawget(t,k) or Sprite[k]
end
Sprite.__type = "GNUI.Sprite"


---@overload fun(cfg: GNUI.Visual.Quad|{}):GNUI.Visual.Quad
---@param texture Texture?
---@return GNUI.Visual.Quad
function SpriteAPI.new(texture)
	local new = {}
	new.color = vec(1,1,1)
	new.alpha = 1
	new.uv = vec(0,0,1,1)
	new.expand = vec(0,0,0,0)
	new.scale = 1
	setmetatable(new,Sprite)
	
	if type(texture) == "table" then
		for key, value in pairs(texture) do
			local method = "set"..(key):gsub("^%l",string.upper)
			if new[method] then
				new[method](new,value)
			else
				new[key] = value
			end
		end
	end
	return new
end

---@param texture Texture
---@return GNUI.Visual.Quad
function Sprite:setTexture(texture)
	self.texture = texture
	if texture then
		self:setUV(0,0,texture:getDimensions():sub(1,1):unpack())
	end
	return self
end



---@param x1 number|Vector2|Vector4
---@param y1 (number|Vector2)?
---@param x2 number?
---@param y2 number?
function Sprite:setUV(x1,y1,x2,y2)
	---@cast self GNUI.Visual.Quad
---@diagnostic disable-next-line: undefined-field
	self.uv = utils.vec4(x1,y1,x2,y2)
	return self
end


---@param factor number
---@return GNUI.Visual.Quad
function Sprite:setScale(factor)
	self.scale = factor
	return self
end


function Sprite:init(box,draw)
	print(box,draw)
end


return SpriteAPI