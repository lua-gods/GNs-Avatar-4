local GNUI = require("lib.GNUI.main")

local Box = GNUI.box
local Sprite = GNUI.sprite

local screen = GNUI.getScreen()

local boxy = Box.new()
boxy:setExtent(50,50,100,100)

local sprite = Sprite.new()


sprite:setTexture(textures["textures.nineslice"])

boxy:setSprite(sprite)
boxy:setParent(screen) -- TODO: remove and see

events.WORLD_RENDER:register(function (delta)
	local time = client:getSystemTime() / 200
	boxy:setExtent(
		math.lerp(50,100,math.sin(time) * 0.5 + 0.5),
		math.lerp(50,100,math.cos(time) * 0.5 + 0.5),
		math.lerp(150,300,math.cos(time) * 0.5 + 0.5),
		math.lerp(150,300,math.sin(time) * 0.5 + 0.5)
	)
end)
