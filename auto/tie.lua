---@diagnostic disable: assign-type-mismatch, undefined-field
local Spring = require("lib.spring")

local tie = models.player.Base.Torso.Body.Tie
local boign = Spring.newVec2(1.2,vec(0.1,0.1),0)
local UP = vec(0,1,0)



local lpos = vec(0,0,0)
local lvel = vec(0,0,0)
local lbyaw
events.TICK:register(function ()
	local mat = tie:partToWorldMatrix()
	local pos = mat:apply(0,0,0)
	local vel = vectors.rotateAroundAxis(player:getBodyYaw()+180,pos-lpos,UP) --vectors.rotateAroundAxis(player:getBodyYaw()+180,player:getVelocity(),UP)
	local accel = (vel - lvel):clampLength(0,0.1)
	lvel = vel
	lpos = pos
	
	local byaw = math.rad(player:getBodyYaw())
	local accelByaw = byaw - (lbyaw or byaw)
	lbyaw = byaw
	boign.target = mat:applyDir(0,-16,2).xz
	boign.vel = (boign.vel - accel.xz * 20 + vec(accelByaw*-0.5,accel.y*20))
end)

local function skew(dir,shift)
	local skew = dir.xz:length()
	local mat = matrices.mat3()
	mat.c2 = -dir + UP - UP*skew^2
	mat = mat:augmented()
	mat:translate(mat:apply(-shift)):translate(shift)
	return mat
end

local historyMat = {}

local MUL = vec(-1,0,1)*20

events.RENDER:register(function (delta, ctx, matrix)
	if ctx == "RENDER" then
		if boign.pos.y > 0 then
			boign.pos = boign.pos.x_
			boign.vel = boign.vel.x_
		end
		table.insert(historyMat,1,boign.pos.x_y)
		if #historyMat > 20 then
			historyMat[21] = nil
		end
		tie:setRot(historyMat[1].z_x*MUL)
		tie.Tie1:setRot((historyMat[5] or historyMat[1]).z_x*MUL)
		tie.Tie1.Tie2:setRot((historyMat[10] or historyMat[1]).z_x*MUL)
		tie.Tie1.Tie2.Tie3:setRot((historyMat[15] or historyMat[1]).z_x*MUL)
		tie.Tie1.Tie2.Tie3.Tie4:setRot((historyMat[20] or historyMat[1]).z_x*MUL)
		--tie:setMatrix(skew(historyMat[1],tie:getTruePivot()))
		--tie.Tie1:setMatrix(skew(historyMat[5] or historyMat[1],tie.Tie1:getTruePivot()))
		--tie.Tie1.Tie2:setMatrix(skew(historyMat[10] or historyMat[1],tie.Tie1.Tie2:getTruePivot()))
		--tie.Tie1.Tie2.Tie3:setMatrix(skew(historyMat[15] or historyMat[1],tie.Tie1.Tie2.Tie3:getTruePivot()))
		--tie.Tie1.Tie2.Tie3.Tie4:setMatrix(skew(historyMat[20] or historyMat[1],tie.Tie1.Tie2.Tie3.Tie4:getTruePivot()))
	end
end)