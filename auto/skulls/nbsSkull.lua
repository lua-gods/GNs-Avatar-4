local Skull = require("lib.skull")
local Color = require("lib.color")

local NBS = require("lib.nbs")
local Tween = require("lib.tween")

---@type SkullIdentity|{}
local identity = {
	name = "Note Block Studio Player",
	id = "nbs",
	support="minecraft:jukebox",
	modelBlock = models.skull.block,
	modelHat = models.skull.block,
	modelHud = Skull.makeIcon(textures["textures.item_icons"],3,0),
	modelItem = Skull.makeExtrudedIcon(textures["textures.item_icons"],3,0),
}

local zlib = require("lib.zlib")

local HALF = vec(0.5,0.35,0.5)

identity.processBlock = {
	---@param skull SkullInstanceBlock
	---@param model ModelPart
	ON_ENTER = function (skull, model)
		if not (#skull.params[1] > 0) then return end
		local musicPlayer = NBS.newMusicPlayer():setPos(skull.matrix:apply() + vec(0.5,0.5,0.5)):setAttenuation(2)
		
		
		local buffer = data:createBuffer(#skull.params[1])
		buffer:setPosition(0)
		buffer:writeBase64(skull.params[1])
		buffer:setPosition(0)
		local track = NBS.parseBuffer(buffer)
		buffer:close()
		musicPlayer:setTrack(track):play()
		
		local scale = 1/track.loudest
		
		skull.musicPlayer = musicPlayer
		skull.track = track
		skull.squish = 1
		skull.notes = {}
		---@param note NBS.Noteblock
		musicPlayer.NOTE_PLAYED:register(function (note)
			if note.volume > 0.001 then
				skull.notes[#skull.notes+1] = particles:newParticle("minecraft:end_rod",skull.matrix:apply()  + HALF + skull.matrix:applyDir(0,0,1):normalize() *0.25)
				:setVelocity(skull.matrix:applyDir(note.key/24-2,0,0.2+(note.instrument)/24)*0.25)
				:setColor(vectors.hsvToRGB((note.instrument)/24,1,(note.key % 12) > 6 and 1 or 0.7))
				:scale(note.volume*scale*0.5)
				:setLifetime(320)
				:setGravity(-0.1)
				skull.squish = math.min(skull.squish, 1 - note.volume)
			end
		end)
	end,
	
	ON_PROCESS = function (skull, model, delta)
		skull.musicPlayer:setPos(skull.matrix:apply())
		if not (#skull.params[1] > 0) then return end
		skull.squish = (skull.squish - 1) * 0.9 + 1
		local inv = 1/skull.squish
		skull.model:setScale(inv,skull.squish,inv)
	end,
	
	ON_EXIT = function (skull, model)
		if not (#skull.params[1] > 0) then return end
		skull.musicPlayer:stop()
		skull.musicPlayer = nil
	end
}

identity.processHat = identity.processBlock

Skull.registerIdentity(identity)
