
---@type GNsAvatar.Macro
return {
	name = ":apple: Player Scale Modifier",
	config = {
		{
			text = "Scale",
			type = "NUMBER",
			min = 0.1,
			max = 16,
			step = 0.25,
			default_value = 1
		},
	},
	init=function (events, props)
		
		local function apply()
			local scale = props[1].value
			models.player:scale(scale)
		end
		
		props[1].VALUE_CHANGED:register(apply)
		apply()
		
		if host:isHost() then
			events.WORLD_TICK:register(function ()
				local scale = props[1].value
				local EYE_HEIGHT = player:getEyeHeight()
				renderer:offsetCameraPivot(0,EYE_HEIGHT*(scale-1))
				renderer:eyeOffset(0,EYE_HEIGHT*(scale-1))
			end)
		end
		
		events.ON_EXIT:register(function ()
			models.player:scale()
			renderer:offsetCameraPivot()
			renderer:eyeOffset()
		end)
	end
}