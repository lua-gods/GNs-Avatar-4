---@diagnostic disable: undefined-doc-name, undefined-field
--[[______   __
  / ____/ | / /  by: GNanimates / https://gnon.top / Discord: @gn68s
 / / __/  |/ / name: 
/ /_/ / /|  /  desc: 
\____/_/ |_/ source: link ]]


local GNUI = require "../../main" ---@type GNUIAPI
local atlas = textures[(...):gsub("/",".") ..".gnuiTheme"]

---@type GNUI.Theme
local theme = {}

--[────────────────────────────────────────-< Box >-────────────────────────────────────────]--
--[────────────────────────────────────────-< Button >-────────────────────────────────────────]--
theme.Button = {
	windowClose = {
		normal = GNUI.newSprite(atlas, 7,1,11,7 ,2,2,2,4, 2)
		:setTextAlign(0.5,0.5)
		:setDefaultTextColor("#000000"),
		pressed= GNUI.newSprite(atlas,13,2,17,6 ,2,2,2,2)
		:setTextAlign(0.5,0.5)
		:setDefaultTextColor("#000000")
		:setTextOffset(0,2),
	}
}

return theme