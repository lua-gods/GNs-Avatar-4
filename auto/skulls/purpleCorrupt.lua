local Skull = require("lib.skull")
local Color = require("lib.color")


models.skull.hat:scale(1.1,1.1,1.1)

local DOWN = vec(0,-1,0)
local DISTANCE = 6


---@type SkullIdentity|{}
local identity = {
	name = "Sound Scrubber",
	id="sound_scrubber",
	support = "minecraft:purple_wool",
	modelBlock = models.skull.block,
	modelHat = models.skull.hat,
	modelItem = models.skull.entity
}

identity.processBlock = {
---@param skull SkullInstanceBlock
---@param model ModelPart
ON_ENTER = function (skull, model)
	model:setColor(0.1,0.1,0.1)
	skull.sounds = {}
	events.ON_PLAY_SOUND:register(function (id, pos, volume, pitch, loop, category, path)
		if path and (pos-skull.pos):length() < DISTANCE then
			local s = sounds[id]:pos(pos):volume(volume):pitch(pitch):play()
			skull.sounds[#skull.sounds+1] = {
				sound = s,
				soundRef = sounds[id]:pos(pos):volume(0):pitch(pitch):play(),
				pitch = pitch,
				hasPitchCorrected = false
			}
			return true
		end
	end,skull.hash)
end,



---@param skull SkullInstanceBlock
---@param model ModelPart
ON_PROCESS = function (skull, model,delta)
	local t = client:getSystemTime()
	
	math.randomseed(t)
	math.random()
	math.random()
	math.random()
	math.random()
	local w = math.random()-0.5
	local s = w * 0.5 + 1
	model:scale(1/s,s,1/s)
	---@param value {sound: Sound, pitch: number}
	for key, value in pairs(skull.sounds) do
		if not value.soundRef:isPlaying() and value.hasPitchCorrected then
			skull.sounds[key] = nil
		else
			value.hasPitchCorrected = true
			value.sound:stop():play()
		end
	end
end,

---@param skull SkullInstanceBlock
---@param model ModelPart
ON_EXIT = function (skull, model)
	events.ON_PLAY_SOUND:remove(skull.hash)
	for key, value in pairs(skull.sounds) do
		value.sound:stop()
	end
end}



Skull.registerIdentity(identity)