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
	
	windowBorderTopRight = {
		normal = GNUI.newSprite(atlas,3,7,5,9),
		hover = GNUI.newSprite(atlas,3,1,5,3),
	},
	
	windowBorderTop = {
		normal = GNUI.newSprite(atlas,3,7,3,9),
		hover = GNUI.newSprite(atlas,3,1,3,3),
	},
	
	windowBorderTopLeft = {
		normal = GNUI.newSprite(atlas,1,7,3,9),
		hover = GNUI.newSprite(atlas,1,1,3,3),
	},
	
	windowBorderRight = {
		normal = GNUI.newSprite(atlas,3,9,5,9),
		hover = GNUI.newSprite(atlas,3,3,5,3),
	},
	
	windowBorderBottomRight = {
		normal = GNUI.newSprite(atlas,3,9,5,11),
		hover = GNUI.newSprite(atlas,3,3,5,5),
	},
	
	windowBorderBottom = {
		normal = GNUI.newSprite(atlas,3,9,3,11),
		hover = GNUI.newSprite(atlas,3,3,3,5),
	},
	
	windowBorderBottomLeft = {
		normal = GNUI.newSprite(atlas,1,9,3,11),
		hover = GNUI.newSprite(atlas,1,3,3,5),
	},
	
	windowBorderLeft = {
		normal = GNUI.newSprite(atlas,1,9,3,9),
		hover = GNUI.newSprite(atlas,1,3,3,3),
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