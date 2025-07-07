--[[______   __
  / ____/ | / /  by: GNanimates / https://gnon.top / Discord: @gn68s
 / / __/  |/ / name: GNUI Sprite
/ /_/ / /|  /  desc: Renderer Subhandler
\____/_/ |_/ source: link ]]


local Class = require"../GNClass" ---@type GN.Class


---@class GNUI.SpriteAPI
local SpriteAPI = {}


---@class GNUI.Sprite
---@field texture Texture
---@field border Vector4
---@field color Vector3
---@field alpha number
---@field protected __index function
local Sprite = {}
Sprite.__index = function (t,k)
	return rawget(t,k) or Sprite[k]
end
Sprite.__type = "GNUI.Sprite"

---@param texture Texture?
---@return GNUI.Sprite
function SpriteAPI.new(texture)
	local new = Class.apply({},Sprite)
	new.texture = texture
	return new
end


return SpriteAPI