--[[______   __
  / ____/ | / /  by: GNanimates / https://gnon.top / Discord: @gn68s
 / / __/  |/ / name: GNUI Screen
/ /_/ / /|  /  desc: handles all the inputs
\____/_/ |_/ source: link ]]

local Box = require("./box") ---@type GNUI.BoxAPI
local utils = require"./utils" ---@type GNUI.UtilsAPI


---@class GNUI.ScreenAPI
local ScreenAPI = {}



---@class GNUI.Screen : GNUI.Box
---@field display GNUI.RenderState
---@field cursorPos Vector2
---@field protected __index function
local Screen = {}
Screen.__index = function(t,k)
	return rawget(t,k) or Screen[k] or Box.methods[k]
end
Screen.__type = "GNUI.Box.Screen"


---@param cfg (GNUI.Screen|{})?
---@return GNUI.Screen
function ScreenAPI.new(cfg)
	local new = setmetatable(Box.new(cfg),Screen) ---@cast new GNUI.Screen
	-- TODO
	return new
end


function Screen:setCursorPos(x,y)
	local pos = utils.vec2(x,y)
end


ScreenAPI.methods = Screen
return ScreenAPI