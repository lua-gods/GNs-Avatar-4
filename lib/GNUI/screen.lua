--[[______   __
  / ____/ | / /  by: GNanimates / https://gnon.top / Discord: @gn68s
 / / __/  |/ / name: GNUI Screen
/ /_/ / /|  /  desc: handles all the inputs
\____/_/ |_/ source: link ]]

local Box = require("./box") ---@type GNUI.BoxAPI
local Class = require"../GNClass"

---@class GNUI.ScreenAPI
local ScreenAPI = {}

---@class GNUI.Screen : GNUI.Box
---@field display GNUI.RenderState
---@field protected __index function
local Screen = {}
Screen.__index = function(t,k)
	return rawget(t,k) or Screen[k] or Box.methods[k]
end
Screen.__type = "GNUI.Box.Screen"


---@param cfg (GNUI.Screen|{})?
---@return GNUI.Screen
function ScreenAPI.new(cfg)
	local new = Class.apply(Box.new(cfg),Screen) ---@cast new GNUI.Screen
	-- TODO
	return new
end


ScreenAPI.methods = Screen
return ScreenAPI