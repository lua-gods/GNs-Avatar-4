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
theme.Box = {
	iconFolder = {icon=GNUI.newSprite(atlas,0,39,6,45)},
	iconSound =  {icon=GNUI.newSprite(atlas,7,39,13,45)},
	iconText =   {icon=GNUI.newSprite(atlas,14,39,20,45)},
	iconImage =  {icon=GNUI.newSprite(atlas,21,39,27,45)},
	iconLua =    {icon=GNUI.newSprite(atlas,28,39,34,45)},
	iconJson =   {icon=GNUI.newSprite(atlas,35,39,41,45)},
	iconNBT =    {icon=GNUI.newSprite(atlas,42,39,48,45)},
	iconVideo =  {icon=GNUI.newSprite(atlas,49,39,55,45)},
	
	
	default = {
		entry = vectors.hexToRGB("#202020"),
		entry_secondary = vectors.hexToRGB("#2e2e2e"),
		entry_hovered = vectors.hexToRGB("#6b6b6b"),
		entry_selected = vectors.hexToRGB("#527e52"),
	}
}
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
		titlebar = GNUI.newSprite(atlas,1,13,3,16, 1,1,1,2)
		:setTextMargin(2,2,2,2)
		:setDefaultTextColor("#0c2e44"),
		titlebar_height = 12,
		content = GNUI.newSprite(atlas,0,0,0,0)
		:setPadding(1,1,1,1),
	}
}
return theme