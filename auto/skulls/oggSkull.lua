local Skull = require("lib.skull")
local Color = require("lib.color")


---@type SkullIdentity|{}
local identity = {
	name = "OGG Vorbis Player",
	id = "ogg",
	support="minecraft:jukebox",
	modelBlock = models.skull.disc,
	modelHat = models.skull.disc,
	modelHud = Skull.makeIcon(textures["textures.item_icons"],3,0),
	modelEntity = Skull.makeExtrudedIcon(textures["textures.item_icons"],3,0),
}





local HALF = vec(0.5,0.5,0.5)

identity.processBlock = {
	---@param skull SkullInstanceBlock
	---@param model ModelPart
	ON_READY = function (skull, model)
		if not (#skull.params[1] > 0) then return end
		skull.model:scale(1.01)
		if skull.isWall then
			model:setRot(90,0,0):setPos(0,4,3)
		end
		
		local buffer = data:createBuffer(#skull.params[1])
		buffer:setPosition(0)
		buffer:writeBase64(skull.params[1])
		buffer:setPosition(0)
		sounds:newSound(skull.hash,buffer:readBase64(buffer:available()))
		skull.music = sounds:playSound(skull.hash):setPos(skull.matrix:apply()):setLoop(true)
		skull.t = 0
		skull.speed = 1
		skull.lastPower = 0
	end,
	
	ON_PROCESS = function (skull, model, deltaFrame, deltaTick)
		if not (#skull.params[1] > 0) then return end
		skull.t = skull.t + deltaFrame * 200 * skull.speed
		skull.model.base:setRot(0,math.floor(skull.t/50)*90,0)
		local f = math.floor((skull.t/50 % 1) * 3)
		skull.model.base.face1:setVisible(f == 0)
		skull.model.base.face2:setVisible(f == 1)
		skull.model.base.face3:setVisible(f == 2)
		skull.music:setPos(skull.matrix:apply() + HALF)
		local power = world.getRedstonePower(skull.supportPos)
		if skull.lastPower ~= power then
			skull.lastPower = power
			
			if power ~= 0 then
				skull.speed = 0
				skull.music:stop()
			else
				local speed = (power/14) * 10 + 1
				skull.speed = speed
				skull.music:play()
			end
		end
	end,
	
	ON_EXIT = function (skull, model)
		if not (#skull.params[1] > 0) then return end
		skull.music:stop()
		skull.music = nil
	end
}


Skull.registerIdentity(identity)