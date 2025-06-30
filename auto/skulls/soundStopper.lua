local Skull = require("lib.skull")
local Color = require("lib.color")


models.skull.hat:scale(1.1,1.1,1.1)


local DISTANCE = 6


---@type SkullIdentity|{}
local identity = {
	name = "Wavey Slow",
	support = "minecraft:black_wool",
	modelBlock = models.skull.block,
	modelHat = models.skull.hat,
	modelHud = Skull.makeIcon(models.skull.icon),
	modelItem = models.skull.entity
}

identity.processBlock = {
---@param skull SkullInstanceBlock
---@param model ModelPart
ON_ENTER = function (skull, model)
	model:setColor(1,0,1)
	skull.sounds = {}
	events.ON_PLAY_SOUND:register(function (id, pos, volume, pitch, loop, category, path)
		local dist = (pos-skull.pos):length()
		if path and dist < DISTANCE then
			local s = sounds[id]:pos(pos):volume(volume):pitch(pitch):play()
			skull.sounds[#skull.sounds+1] = {
				hasPlayed = false,
				sound = s,
				pitch = pitch,
				dist = dist,
			}
			return true
		end
	end,skull.identifier)
end,

---@param skull SkullInstanceBlock
---@param model ModelPart
ON_PROCESS = function (skull, model,delta)
	local t = client:getSystemTime() / 1000
	local s = 0.8-(t % 0.1)
	model:scale(1/s,s,1/s)
	---@param value {sound: Sound, pitch: number}
	for key, value in pairs(skull.sounds) do
		if value.pitch < 0 or (value.sound:isPlaying() and value.hasPlayed) then
			value.sound:stop()
			skull.sounds[key] = nil
		else
			value.hasPlayed = true
			value.pitch = value.pitch - 0.001
			value.sound:setPitch(value.pitch)
		end
	end
end,

---@param skull SkullInstanceBlock
---@param model ModelPart
ON_EXIT = function (skull, model)
	events.ON_PLAY_SOUND:remove(skull.identifier)
	for key, value in pairs(skull.sounds) do
		value.sound:stop()
	end
end}



Skull.registerIdentity(identity)