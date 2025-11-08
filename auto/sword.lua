local GNanim = require("lib.GNanimClassic")

local animState = GNanim.new():setBlendTime(0.0)


local ANIM_IDLE = animations.player.sword
local ANIM_ATTACK = animations.player.swordAttack1
local ANIM_ATTACK_TWO = animations.player.swordAttack2

local alternate = false

models.player.Roll.Sword.glow:setPrimaryRenderType("EMISSIVE_SOLID")
models.player.VFX.Smear1.Smear1Spin:setPrimaryRenderType("EYES"):setColor(0.8,0.8,0.8)
animState:setAnimation(ANIM_IDLE)


events.TICK:register(function ()
	local heldItem = player:getHeldItem()
	local isHoldingSword = heldItem.id:find("_sword$")
	if isHoldingSword and player:getSwingArm() and player:getSwingTime() == 0 then
		animState:setAnimation(alternate and ANIM_ATTACK_TWO or ANIM_ATTACK,true)
		alternate = not alternate
		sounds["sounds.swing"]:pitch(math.lerp(0.9,1.1,math.random())):pos(player:getPos()):play()
	end
end)