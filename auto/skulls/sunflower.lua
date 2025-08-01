local Skull = require("lib.skull")


function hash(str)
	local hash = 0
	for i = 1, #str do
		local c = str:byte(i)
		hash = (hash * math.pi + c) % 100000 -- keep it within 5 digits
	end
	return hash
end

local SCALE = 0.8


local NBS = require("lib.nbs")
local track = NBS.loadTrack("sunny")

local Tween = require("lib.tween")

animations.sunflower.idle:speed(0.5):play()
models.sunflower.blocko:setPrimaryRenderType("CUTOUT")
---@type SkullIdentity|{}
local identity = {
	name = "sunflower",
	support = "minecraft:flower_pot",
	modelBlock = {models.sunflower.blocko:scale(SCALE,SCALE,SCALE):setPos(0,-10,0)},
	modelHat = {models.sunflower.blocko},
	modelHud = {models.sunflower.blocko},
	modelItem = {models.sunflower.blocko},
	
	processBlock = {
		ON_ENTER = function (skull, model)
			skull.music = NBS.newMusicPlayer():setTrack(track):play()
			skull.music:setPos(skull.pos + vec(0.5,0.5,0.5))
			---@param note NBS.Noteblock
			skull.music.NOTE_PLAYED:register(function (note)
				Tween.new{
					from=1-note.volume*0.5,
					to=1,
					duration=0.5,
					easing="outSine",
					tick=function (v, t)
						local s = 1/v
						skull.model:scale(s,v,s)
					end,
					id=skull.identity
				}
			end)
		end,
		ON_EXIT = function (skull, model)
			skull.music:stop()
		end
	},
	
	processHat = {
		ON_ENTER = function (skull, model)
			skull.music = NBS.newMusicPlayer():setTrack(track):play()
			model:setPos(0,8,0)
			skull.music.NOTE_PLAYED:register(function (note)
				Tween.new{
					from=0.8,
					to=1,
					duration=0.5,
					easing="outSine",
					tick=function (v, t)
						local s = 1/v
						skull.model:scale(s*0.6,v*0.6,s*0.6)
					end,
					id=skull.identity
				}
			end)
		end,
		ON_PROCESS = function (skull, model, delta)
			skull.music:setPos(skull.matrix:apply(0,0,0))
		end,
		ON_EXIT = function (skull, model)
			skull.music:stop()
		end
	},
	processHud = {
		ON_ENTER = function (skull, model)
			model:rot(50,-45,0):pos(0,-4,0)
		end
	},
	processEntity = {
		ON_ENTER = function (skull, model)
			
			if skull.isHand then
				model:setPos(0,0,0):scale(0.5,0.5,0.5)
			else
				model:setPos(0,0,0)
			end
		end,
		ON_PROCESS = function (skull, model, delta)
		end
	}
}

Skull.registerIdentity(identity)