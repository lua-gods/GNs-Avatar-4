local Macros = require("lib.macros")
local Spring = require("lib.spring")

local recoilSpring = Spring.new({
	f = 0.2,
	z = 0.5,
	r = 0,
})

local model = models.boat
model:setPos(0,8,0):setVisible(false)
renderer:setRenderVehicle(false)

local function pitch(speed)
	speed = speed * 2
	local div = 1
	for i = 1, 10, 1 do
		if speed/div > 1.2 then
			div = div + 1
		else
			break
		end
	end
	return speed / div
end

---@param events MacroEventsAPI
---@param vehicle Entity
local Motorcycle = Macros.new(function (events, vehicle)
	local engine = sounds["engine"]:loop(true):play()
	model:setVisible(true)
	models.player:setPos(0,12,-2):setRot(0,0,0)
	
	models.player.Base.Torso:setRot(-25,0,0)
	models.player.Base.Torso.LeftArm:setRot(60,0,0)
	models.player.Base.Torso.RightArm:setRot(60,0,0)
	models.player.Base.LeftLeg:setRot(-20,0,0)
	models.player.Base.RightLeg:setRot(-20,0,0)
	models.player.Base.Torso.Head:setRot(25,0,0)
	model:setRot(0,0,0)
	
	local lvel = vec(0,0,0)
	local vel = vec(0,0,0)
	local ltravel = 0
	local travel = 0
	
	local recoil = 1
	
	local engineRPM = 0
	
	events.TICK:register(function ()
		lvel = vel
		vel = vectors.rotateAroundAxis(player:getBodyYaw(),vehicle:getVelocity(),vec(0,1,0))
		
		ltravel = travel
		travel = travel + vel.z
	end)
	
	events.RENDER:register(function (delta, ctx, matrix)
		if (ctx == "RENDER" or ctx == "FIRST_PERSON") and player:isLoaded() then
			local ppos = player:getPos(delta)
			local t = math.lerp(ltravel,travel,delta)
			local v = math.lerp(lvel,vel,delta)
			local tilt = (v.x/math.max(v.z,0.5)) * -15
			
			local mat = matrices.mat4()
			mat:rotateY(-vehicle:getRot(delta).y)
			mat:translate(vehicle:getPos(delta))
			
			models.boat.Hed:setRot(22.5,tilt*2,0)
			models.boat.Hed.ShockAbsorber.Wheel:setRot(t * -128, 0, 0)
			models.boat.SwingArm.Wheel2:setRot(t * -128 * 1.2, 0, 0)
			models.boat.SwingArm:setRot(recoil*-15,0,0)
			models.boat.Hed.ShockAbsorber:setPos(0,math.max(recoil*-10,0.1),0)
			engine:pos(ppos)
			
			local accel = vel.xz:length()-lvel.xz:length()
			
			recoilSpring.vel = recoilSpring.vel + accel * 2
			recoil = math.clamp(recoilSpring.pos * 3,-0.5,2)
			if accel > 0 then -- is Throttling
				engineRPM = math.lerp(0.3,1.7,pitch(vel.xz:length()))
				
				local block = world.getBlockState(mat:apply(0,-0.01,-0.5))
				if block:hasCollision() then
					particles:newParticle("minecraft:block "..block.id,mat:apply((math.random()-0.5)*0.5,0,-0.5))
				end
			else
				engineRPM = math.max(engineRPM-0.01,0.3)
			end
			engine:pitch(engineRPM)
			models.player:setRot(-math.abs(tilt)*0.5 + recoil*15,-tilt,tilt)
			models.boat:setRot(-math.abs(tilt)*0.5 + recoil*15,-tilt,tilt)
		end
	end)
	
	events.ON_EXIT:register(function ()
		models.player:setPos(0,0,0)
		model:setVisible(false)
		engine:stop()
		
		models.player.Base.Torso:setRot()
		models.player.Base.Torso.LeftArm:setRot()
		models.player.Base.Torso.RightArm:setRot()
		models.player.Base.LeftLeg:setRot()
		models.player.Base.RightLeg:setRot()
		models.player.Base.Torso.Head:setRot()
	end)
end)

events.TICK:register(function ()
	local vehicle = player:getVehicle()
	Motorcycle:setActive(vehicle and true or false, vehicle)
end)
