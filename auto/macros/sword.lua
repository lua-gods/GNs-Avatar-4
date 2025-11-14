---@type GNsAvatar.Macro

SWORD_PITCH = 1

return {
	name = ":mci_iron_sword: Sword Modifier",
	config = {
		{
			text = "Scale",
			type = "NUMBER",
			min = 0.1,
			max = 10,
			step = 0.1,
			default_value = 1
		},
	},
	init=function (events, props)
		
		local function apply()
			local speed = 1 / props[1].value
			models.player.Roll:scale(props[1].value)
			models.player.VFX:scale(props[1].value)
			animations.player.swordAttack1:setSpeed(speed)
			animations.player.swordAttack2:setSpeed(speed)
			animations.player.sword:setSpeed(speed)
			SWORD_PITCH = speed
		end
		
		props[1].VALUE_CHANGED:register(apply)
		apply()
		
		events.ON_EXIT:register(function ()
			SWORD_PITCH = 1
			models.player.Roll:scale()
			models.player.VFX:scale()
			animations.player.swordAttack1:setSpeed()
			animations.player.swordAttack2:setSpeed()
			animations.player.sword:setSpeed()
		end)
	end
}

