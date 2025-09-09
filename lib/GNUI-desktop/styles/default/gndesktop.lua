---@diagnostic disable: undefined-doc-name, undefined-field
--[[______   __
  / ____/ | / /  by: GNanimates / https://gnon.top / Discord: @gn68s
 / / __/  |/ / name: 
/ /_/ / /|  /  desc: 
\____/_/ |_/ source: link ]]


local GNUI = require "../../../GNUI/main" ---@type GNUIAPI
local atlas = textures[(...):gsub("/",".") ..".gndesktop"]

---@type GNUI.Theme
local theme = {}

--[────────────────────────────────────────-< Box >-────────────────────────────────────────]--
--[────────────────────────────────────────-< Button >-────────────────────────────────────────]--
theme.Button = {
	windowClose = {
		normal = GNUI.newSprite(atlas,31,1,41,12 ,1,1,1,1, 0,0,1,0),
		hover  = GNUI.newSprite(atlas,31,14,41,25 ,1,1,1,1, 0,0,1,0),
	},
	windowMaximize = {
		normal = GNUI.newSprite(atlas,19,1,29,12 ,1,1,1,1, 0,0,1,0),
		hover  = GNUI.newSprite(atlas,19,14,29,25 ,1,1,1,1, 0,0,1,0),
	},
	
}

theme.Window = {
	default = {
		backdrop = GNUI.newSprite(atlas,1,7,5,11, 2,2,2,2)
		:setPadding(1,1,1,1),
		backdrop_selected = GNUI.newSprite(atlas,1,1,5,5, 2,2,2,2),
		titlebar = GNUI.newSprite(atlas,1,13,3,16, 1,1,1,2),
		titlebar_height = 12,
	}
}

return theme