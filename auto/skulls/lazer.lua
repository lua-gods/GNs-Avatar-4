local Skull = require("lib.skull")
local Color = require("lib.color")

local Line = require("lib.line")

local REACH_DISTANCE = 64
local MAX_BOUNCE = 100

local face2dir = {
   ["north"] = vec(1,1,-1),
   ["east"]  = vec(-1,1,1),
   ["south"] = vec(1,1,-1),
   ["west"]  = vec(-1,1,1),
   ["up"]    = vec(1,-1,1),
   ["down"]  = vec(1,-1,1),
}
local SCALE = 0.845

models.lazer.hat:scale(SCALE,SCALE,SCALE)

---@type SkullIdentity|{}
local identity = {
	name = "Laser",
	id = "laser",
	modelBlock = models.lazer.hat,
	modelHat = models.lazer.hat,
	modelHud = Skull.makeIcon(textures["textures.item_icons"],1,0),
	modelEntity = models.lazer.hat,
	
	processHat = {
		ON_READY = function (skull, model)
			skull.Lines = {}
			for i = 1, MAX_BOUNCE, 1 do
				local group = {
					Line.new():setWidth(0.075):setColor(1,0,0),
					Line.new():setWidth(0.05):setColor(1,1,1):setDepth(-0.01)
				}
				skull.Lines[i] = group
			end
		end,
		ON_PROCESS = function (skull, model, delta)
			local dir = skull.entity:getLookDir()
			local pos = skull.entity:getPos(delta):add(0,skull.entity:getEyeHeight()+0.4)
			local points = {pos}
			
			for i = 1, MAX_BOUNCE, 1 do
				local to = pos + dir * REACH_DISTANCE
				local block,hit,side = raycast:block(pos,to)
				if (to-hit):length() > 0.1 then
					points[i+1] = hit
					pos = hit
					dir = dir * face2dir[side]
				else
					points[i+1] = to
					break
				end
			end
			
			for i = 1, MAX_BOUNCE, 1 do
				local group = skull.Lines[i]
				if points[i] and points[i+1] then
					group[1]:setAB(points[i], points[i+1]):setVisible(true)
					group[2]:setAB(points[i], points[i+1]):setVisible(true)
				else
					group[1]:setVisible(false)
					group[2]:setVisible(false)
				end
			end
		end,
		ON_EXIT = function (skull, model)
			for key, value in pairs(skull.Lines) do
				value[1]:free()
				value[2]:free()
			end
		end
	}
}

Skull.registerIdentity(identity)