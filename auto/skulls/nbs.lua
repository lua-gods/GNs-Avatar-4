local Skull = require("lib.skull")
local Color = require("lib.color")

local NBS = require("lib.nbs")
local Tween = require("lib.tween")

---@type SkullIdentity|{}
local identity = {
	name = "nbs",
	support="minecraft:jukebox",
	modelBlock = models.skull.block,
	modelHat = models.skull.block,
	modelHud = Skull.makeIcon(textures["textures.item_icons"],1,1),
	modelItem = models.skull.entity,
}

local HALF = vec(0.5,0.5,0.5)

identity.processBlock = {
	---@param skull SkullInstanceBlock
	---@param model ModelPart
	ON_ENTER = function (skull, model)
		local musicPlayer = NBS.newMusicPlayer():setPos(skull.pos + vec(0.5,0.5,0.5))
		local track = NBS.parseBuffer(skull.params)
		skull.params:close()
		musicPlayer:setTrack(track):play()
		
		skull.musicPlayer = musicPlayer
		skull.track = track
		skull.squish = 1
		skull.notes = {}
		---@param note NBS.Noteblock
		musicPlayer.NOTE_PLAYED:register(function (note)
			skull.notes[#skull.notes+1] = particles:newParticle("minecraft:note",skull.pos + HALF + skull.dir*0.25,vectors.vec3((note.instrument)/24,0,0)):setVelocity(skull.matrix:applyDir(-note.key%24/24-0.5,0,0.2)):setLifetime(100)
			skull.squish = math.min(skull.squish, 1 - note.volume)
		end)
	end,
	
	ON_PROCESS = function (skull, model, delta)
		for key, p in pairs(skull.notes) do
			---@cast p Particle
			if not p:isAlive() then
				skull.notes[key] = nil
			end
			p:setVelocity(p:getVelocity():add(0,0.005,0))
		end
		skull.squish = (skull.squish - 1) * 0.9 + 1
		local inv = 1/skull.squish
		skull.model:setScale(inv,skull.squish,inv)
	end,
	
	ON_EXIT = function (skull, model)
		skull.musicPlayer:stop()
		skull.musicPlayer = nil
	end
}

Skull.registerIdentity(identity)
