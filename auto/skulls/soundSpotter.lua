local Skull = require("lib.skull")
local Color = require("lib.color")

local Line = require('lib.line')

models.skull.hat:scale(1.1,1.1,1.1)

local DOWN = vec(0,-1,0)
local DISTANCE = 32

local rands = {}

for i = 1, 64, 1 do
	rands[i] = vec(math.random()-0.5,math.random()-0.5,math.random()-0.5) * 0.1
end

local function samp(i)
	return rands[i%16+1]
end


---@type SkullIdentity|{}
local identity = {
	name = "Sound Spotter",
	id = "sound_spotter",
	support = "minecraft:orange_wool",
	modelBlock = models.skull.block,
	modelHat = models.skull.hat,
	modelEntity = models.skull.entity
}

identity.processBlock = {
---@param skull SkullInstanceBlock
---@param model ModelPart
ON_READY = function (skull, model)
	model:setColor(1,0.5,0)
	skull.sounds = {}
	events.ON_PLAY_SOUND:register(function (id, pos, volume, pitch, loop, category, path)
		if path and(pos-skull.pos):length() < DISTANCE then
			local s = sounds[id]:pos(pos):volume(0):pitch(pitch):play()
			local data = {
				sound = s,
				hasPitchCorrected = false,
				pos = pos,
			}
			local lines = {}
			for i = 1, 3, 1 do
				lines[i] = Line:new():setColor(1,0.5,0)
			end
			for i = 4, 6, 1 do
				lines[i] = Line:new():setDepth(-0.02):setWidth(0.05)
			end
			data.lines = lines
			skull.sounds[#skull.sounds+1] = data
		end
	end,skull.hash)
end,


---@param skull SkullInstanceBlock
---@param model ModelPart
ON_PROCESS = function (skull, model,delta)
	local t = client:getSystemTime()
	
	skull.model:setRot(0,t*2,0)
	---@param value {sound: Sound, pitch: number}
	for key, value in pairs(skull.sounds) do
		if not value.sound:isPlaying() then
			skull.sounds[key] = nil
			for key, value in pairs(value.lines) do
				value:free()
			end
		else
			local source = skull.pos + vec(0.5,0.5,0.5)
			local target = value.pos
			for i = 1, 3, 1 do
				local line = value.lines[i] ---@type Line
				local a = math.lerp(source,target,(i-1)/3) + samp(i+t)
				local b = math.lerp(source,target,i/3) + samp(i+1+t)
				line:setAB(a,b)
			end
			for i = 1, 3, 1 do
				local line = value.lines[i+3] ---@type Line
				local a = math.lerp(source,target,(i-1)/3) + samp(i+t)
				local b = math.lerp(source,target,i/3) + samp(i+1+t)
				line:setAB(a,b)
			end
		end
	end
end,

---@param skull SkullInstanceBlock
---@param model ModelPart
ON_EXIT = function (skull, model)
	events.ON_PLAY_SOUND:remove(skull.hash)
	for key, value in pairs(skull.sounds) do
		value.sound:stop()
		for key, value in pairs(value.lines) do
			value:free()
		end
	end
end}



Skull.registerIdentity(identity)