local Skull = require("lib.skull")
local Color = require("lib.color")

local Line = require("lib.line")

local MAX_BOUNCE = 500

local face2dir = {
   ["north"] = vec(0,0,1),
   ["east"]  = vec(1,0,0),
   ["south"] = vec(0,0,-1),
   ["west"]  = vec(-1,0,0),
   ["up"]    = vec(0,1,0),
   ["down"]  = vec(0,-1,0),
}

---@param dir Vector3
---@param normal Vector3
---@return unknown
local function reflect(dir, normal)
	return dir - 2 * dir:dot(normal) * normal
end
local SCALE = 0.845

models.lazer.hat:scale(SCALE,SCALE,SCALE)

---@type SkullIdentity|{}
local identity = {
	name = "layser",
	modelBlock = models.lazer.hat,
	modelHat = models.lazer.hat,
	modelHud = Skull.makeIcon(models.lazer.icon),
	modelItem = models.lazer.hat,
	
	processHat = {
		ON_ENTER = function (skull, model)
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
				local to = pos + dir * 16
				local block,hit,side = raycast:block(pos,to)
				if (to-hit):length() > 0.1 then
					points[i+1] = hit
					pos = hit
					dir = reflect(dir, face2dir[side]):normalize()
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