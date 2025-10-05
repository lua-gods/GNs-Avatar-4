---@diagnostic disable: param-type-mismatch
local Skull = require("lib.skull")


local SCALE = 0.8


local NBS = require("lib.nbs")
local track = NBS.loadFromPath("sunny")

local Tween = require("lib.tween")

animations.sunflower.idle:speed(0.5):play()
models.sunflower.blocko:setPrimaryRenderType("CUTOUT")
---@type SkullIdentity|{}
local identity = {
	name = "Sunflower",
	id = "sunflower",
	support = "minecraft:flower_pot",
	modelBlock = {models.sunflower.blocko:scale(SCALE,SCALE,SCALE):setPos(0,-10,0)},
	modelHat = {models.sunflower.blocko},
	modelHud = {models.sunflower.blocko},
	modelItem = {models.sunflower.blocko},
	
	processBlock = {
		ON_READY = function (skull, model)
			skull.music = NBS.newMusicPlayer():setTrack(track):play()
			--skull.music:setPos(skull.pos + vec(0.5,0.5,0.5))
			---@param note NBS.Noteblock
			skull.music.NOTE_PLAYED:register(function (note)
				skull.tween = Tween.new{
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
		ON_PROCESS=function (skull, model, delta)
			skull.music:setPos(skull.model:partToWorldMatrix():apply())
		end,
		ON_EXIT = function (skull, model)
			if skull.tween then
				skull.tween:skip()
			end
			skull.music:stop()
		end
	},
	
	processHud = {
		ON_READY = function (skull, model)
			model:rot(50,-45,0):pos(0,-4,0)
		end
	},
	processEntity = {
		ON_READY = function (skull, model)
			
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