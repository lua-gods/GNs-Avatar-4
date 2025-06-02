local portrait = models.playerHead.plushie
:copy("port")
:setVisible(true)
:setParentType("Portrait")
:scale(1,0.5,1)
models:addChild(portrait)

events.TICK:register(function ()
	portrait:rot(0,world.getTime())
end)