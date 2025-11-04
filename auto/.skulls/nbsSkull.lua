local Skull = require("lib.skull")
local Color = require("lib.color")

local NBS = require("lib.nbs")

---@type SkullIdentity|{}
local identity = {
	name = "Note Block Studio Player",
	id = "nbs",
	support="minecraft:jukebox",
	modelBlock = models.skull.disc,
	modelHat = models.skull.disc,
	modelHud = Skull.makeIcon(textures["textures.item_icons"],3,0),
	modelEntity = Skull.makeExtrudedIcon(textures["textures.item_icons"],3,0),
}


---@param musicPlayer NBS.MusicPlayer
---@param instrument Minecraft.soundID
---@param pos Vector3
---@param key integer
---@param volume integer
---@param attenuation integer
local function customPlay(musicPlayer,instrument,pos,key,volume,attenuation)
	local cpos = client:getCameraPos()
	local pitch=2^(((key-9)/12+musicPlayer.transposition)-3)
	local block,hit = raycast:block(pos+(cpos-pos):normalize()*1.2, cpos)
	if (hit-cpos):lengthSquared() > 0.01 then
		volume = (volume*0.1)
	end
	
	sounds[instrument]
	:pos(pos)
	:pitch(pitch)
	:volume(volume)
	:attenuation(attenuation)
	:play()
end

---@type ChloePianoAPI
local ChloePianoAPI = world.avatarVars()["b0e11a12-eada-4f28-bb70-eb8903219fe5"] or {playSound=function ()end}

-- thankyou 4P5 for the snippet bellow (I stole this)
local NOTES = { "C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B" }

---@param pitch number
---@return string?
local function getNoteName(pitch)
	local note = NOTES[pitch % 12 + 1]
	local octave = math.floor((pitch / 12) - 1)
	if pitch >= 21 and pitch <= 95 then -- A0 to B7
		return note .. octave
	else
		return getNoteName(pitch + (pitch < 21 and 12 or -12))
	end
end

---@type Minecraft.soundID
local PIANO_VALID_INSTRUMENTS = {
	["minecraft:block.note_block.harp"] = -12,
	["minecraft:block.note_block.flute"] = 0,
	["minecraft:block.note_block.bass"] = -24,
	["minecraft:block.note_block.banjo"] = -24,
	["minecraft:block.note_block.xylophone"] = 0,
	["minecraft:block.note_block.pling"] = 0,
	["minecraft:block.note_block.bell"] = 0,
}

---@param pos Vector3
---@return function
local function makePianoCustomPlay(pos)
	return function (musicPlayer,instrument,_,key,volume,attenuation)
		local spos = tostring(pos)
		if PIANO_VALID_INSTRUMENTS[instrument] then
			key = key + PIANO_VALID_INSTRUMENTS[instrument]
			ChloePianoAPI.playSound(getNoteName(key+21),pos,volume*0.1)
		end
	end
end


---@type DrumAPI
local DrumAPI = world.avatarVars()["3dfb6d3b-74e3-4628-9747-1ab586e2fd65"] or {playNote = function () end}


---@param pos Vector3
---@return function
local function makeDrumCustomPlay(pos)
---@param instrument Minecraft.soundID
return function (musicPlayer,instrument,_,key,volume,attenuation)
		local spos = tostring(pos)
		if instrument == "minecraft:block.note_block.basedrum" then
			DrumAPI.playNote(spos,"B1",true,pos,volume)
		elseif instrument == "minecraft:block.note_block.snare" then
			if key > 50 then
				DrumAPI.playNote(spos,"F#2",true,pos,volume)
			elseif key > 40 then
				DrumAPI.playNote(spos,"C#3",true,pos,volume*0.2)
			else
				DrumAPI.playNote(spos,"F#2",true,pos,volume)
			end
		elseif instrument == "minecraft:block.note_block.hat" then
			DrumAPI.playNote(spos,"C#2",true,pos,volume)
		else
			customPlay(musicPlayer,instrument,pos,key,volume,attenuation)
		end
	end
end





local HALF = vec(0.5,0.5,0.5)

identity.processBlock = {
	---@param skull SkullInstanceBlock
	---@param model ModelPart
	ON_READY = function (skull, model)
		if not (#skull.params[1] > 0) then return end
		ChloePianoAPI = world.avatarVars()["b0e11a12-eada-4f28-bb70-eb8903219fe5"] or {}
		DrumAPI = world.avatarVars()["3dfb6d3b-74e3-4628-9747-1ab586e2fd65"]
		skull.model:scale(1.01)
		local musicPlayer = NBS.newMusicPlayer():setPos(skull.matrix:apply() + HALF):setAttenuation(2)
		local supportEntityData = skull.support:getEntityData()
		musicPlayer:setPlayCallback(customPlay)
		
		if supportEntityData 
		and supportEntityData.SkullOwner 
		and supportEntityData.SkullOwner.Id then
			local id = supportEntityData.SkullOwner.Id
			local uuid = client.intUUIDToString(id[1],id[2],id[3],id[4])
			if uuid == "b0e11a12-eada-4f28-bb70-eb8903219fe5"then -- pianos
				musicPlayer:setPlayCallback(makePianoCustomPlay(skull.support:getPos()))
			end
			if uuid == "3dfb6d3b-74e3-4628-9747-1ab586e2fd65" then -- drums
				musicPlayer:setPlayCallback(makeDrumCustomPlay(skull.support:getPos()))
			end
		end
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
			if note.volume > 0.01 then
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
			model.base:setRot(0,math.floor(skull.t/50)*90,0)
			local f = math.floor((skull.t/50 % 1) * 3)
			model.base.face1:setVisible(f == 0)
			model.base.face2:setVisible(f == 1)
			model.base.face3:setVisible(f == 2)
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
