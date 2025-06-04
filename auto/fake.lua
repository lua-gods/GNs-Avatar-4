# host only
if not host:isHost() then return end


local GNUI = require("lib.GNUI.main")
local screen = GNUI.getScreenCanvas()

local box = GNUI.newBox()
screen:addChild(box)

box
:setAnchor(0,0,1,0.2)
:setTextOffset(-6,39)
:setTextAlign(1,0)
:setDefaultTextColor("#dddddd")
:setTextEffect("SHADOW")


local t = 0
events.TICK:register(function ()
	t = t + 1
	if t > 20 then
		t = 0
		box:setText(math.random(7804,7947).." fps")
	end
end)