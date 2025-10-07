local Skull = require("lib.skull")
local Color = require("lib.color")


models.skull.hat:scale(1.1,1.1,1.1)


local DISTANCE = 6


---@type SkullIdentity|{}
local identity = {
	name = "Sound Speeder",
	id = "sound_speeder",
	support = "minecraft:white_wool",
	modelBlock = models.skull.block,
	modelHat = models.skull.hat,
	modelEntity = models.skull.entity
}

identity.processBlock = {
---@param skull SkullInstanceBlock
---@param model ModelPart
ON_READY = function (skull, model)
	model:setColor(0,0,1)
	skull.sounds = {}
	events.ON_PLAY_SOUND:register(function (id, pos, volume, pitch, loop, category, path)
		local dist = (pos-skull.pos):length()
		if path and dist < DISTANCE then
			local s = sounds[id]:pos(pos):volume(volume):pitch(pitch):play()
			skull.sounds[#skull.sounds+1] = {
				sound = s,
				pitch = pitch,
				dist = dist,
			}
			return true
		end
	end,skull.hash)
end,

---@param skull SkullInstanceBlock
---@param model ModelPart
ON_PROCESS = function (skull, model,delta)
	local t = client:getSystemTime() / 500
	local s = 1+(t % 0.25)
	model:scale(1/s,s,1/s)
	---@param value {sound: Sound, pitch: number}
	for key, value in pairs(skull.sounds) do
		if value.pitch > 20 then
			value.sound:stop()
			skull.sounds[key] = nil
		else
			value.pitch = value.pitch + 0.01 / value.dist
			value.sound:setPitch(value.pitch)
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