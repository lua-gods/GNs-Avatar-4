local Skull = require("lib.skull")
local Color = require("lib.color")

local NBS = require("lib.nbs")

---@type SkullIdentity|{}
local identity = {
	name = "Note Block Studio Player",
	id = "nbs",
	support="minecraft:jukebox",
	modelBlock = models.disc,
	modelHat = models.skull.block,
	modelHud = Skull.makeIcon(textures["textures.item_icons"],3,0),
	modelItem = Skull.makeExtrudedIcon(textures["textures.item_icons"],3,0),
}


local HALF = vec(0.5,0.5,0.5)

identity.processBlock = {
	---@param skull SkullInstanceBlock
	---@param model ModelPart
	ON_ENTER = function (skull, model)
		if not (#skull.params[1] > 0) then return end
		skull.model:scale(1.01)
		local musicPlayer = NBS.newMusicPlayer():setPos(skull.matrix:apply() + vec(0.5,0.5,0.5)):setAttenuation(2)
		
		if skull.isWall then
			model:setRot(90,0,0):setPos(0,4,3)
		end
		
		local buffer = data:createBuffer(#skull.params[1])
		buffer:setPosition(0)
		buffer:writeBase64(skull.params[1])
		buffer:setPosition(0)
		local track = NBS.parseBuffer(buffer)
		buffer:close()
		track.loop = true
		musicPlayer:setTrack(track):play()
		
		local scale = 1/track.loudest
		
		skull.musicPlayer = musicPlayer
		skull.track = track
		--skull.squish = 1
		---@param note NBS.Noteblock
		musicPlayer.NOTE_PLAYED:register(function (note)
			if note.volume > 0.001 then
				particles:newParticle("minecraft:note",skull.matrix:apply() + HALF ,vec((note.instrument)/24,0,0))
				:setVelocity(skull.matrix:applyDir(note.key/24-2,0,(note.instrument)/24-0.5)*0.4)
				:scale(note.volume*scale*0.5)
				:setLifetime(40)
				:setGravity(-0.5)
				--skull.squish = math.min(skull.squish, 1 - note.volume)
			end
		end)
		skull.speed = 1
		skull.lastPower = 0
		skull.isActive = true
		musicPlayer.TRACK_FINISHED:register(function ()
		skull.isActive = false
		end)
		skull.t = 0
	end,
	
	ON_PROCESS = function (skull, model, deltaFrame, deltaTick)
		if not (#skull.params[1] > 0) then return end
		if skull.isActive then
			skull.t = skull.t + deltaFrame * 200 * skull.speed
			skull.model.base:setRot(0,math.floor(skull.t/50)*90,0)
			local f = math.floor((skull.t/50 % 1) * 3)
			skull.model.base.face1:setVisible(f == 0)
			skull.model.base.face2:setVisible(f == 1)
			skull.model.base.face3:setVisible(f == 2)
			skull.musicPlayer:setPos(skull.matrix:apply())
			local power = world.getRedstonePower(skull.supportPos)
			if skull.lastPower ~= power then
				if power == 15 then
					skull.musicPlayer:pause()
					skull.speed = 0
				else
					local speed = (power/14) * 10 + 1
					skull.musicPlayer:play():setSpeed(speed)
					skull.speed = speed
				end
				skull.lastPower = power
			end
		end
		
		--skull.squish = (skull.squish - 1) * 0.9 + 1
		--local inv = 1/skull.squish
		--skull.model:setScale(inv,skull.squish,inv)
		
	end,
	
	ON_EXIT = function (skull, model)
		if not (#skull.params[1] > 0) then return end
		skull.musicPlayer:stop()
		skull.musicPlayer = nil
	end
}


Skull.registerIdentity(identity)
