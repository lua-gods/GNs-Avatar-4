local GNUI = require("lib.GNUI.main")

local Sprite = require("lib.GNUI.sprite")
local screen = GNUI.getScreen()


local box = GNUI.box.new({
	--anchor = vec(0.25,0.25,0.3,0.3),
	--extent = vec(10,10,100,100),
	--parent = screen,
	--sprite = textures["textures.tophat_item"]
})

box:setParent(screen)

local sprite = Sprite.new({
	texture = textures["textures.nineslice"],
	border = vec(3,4,4,5),
})
box:setSprite(sprite)

events.WORLD_RENDER:register(function ()
	local time = client:getSystemTime() / 1000
	box:setAnchor(0,0,math.sin(time)*0.25+0.5,math.cos(time)*0.25+0.5)
end)