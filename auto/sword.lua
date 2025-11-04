
local Dust = require("lib.dust")

local ANIM_IDLE = animations.player.sword
local ANIM_ATTACK = animations.player.swordAttack1
ANIM_ATTACK:speed(0.6)

models.player.Roll.Sword.glow:setPrimaryRenderType("EMISSIVE_SOLID")
models.player.VFX:setSecondaryRenderType("EYES")
models.player.VFX:setSecondaryTexture("PRIMARY")



local MODEL_GLARE = models.player.VFX.Glare
MODEL_GLARE.cube:setParentType("CAMERA"):setPrimaryRenderType("EMISSIVE")

Dust.registerIdentity("glare",MODEL_GLARE)


events.TICK:register(function ()
	Dust.spawn("glare",player:getPos(),vec(math.random(),math.random(),math.random()))
	local heldItem = player:getHeldItem()
	local isHoldingSword = heldItem.id:find("_sword$")
	if isHoldingSword and player:getSwingArm() and player:getSwingTime() == 0 then
		ANIM_ATTACK:stop():play()
	end
end)