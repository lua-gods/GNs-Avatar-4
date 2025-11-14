---@type GNsAvatar.Macro
return {
	name = ":mci_brush:Color",
	config = {
		{
			text = "Colors the player",
			type = "LABEL",
		},
		{
			text = "Hue",
			type = "NUMBER",
			min = 0,
			max = 100,
			step = 5,
			default_value = 0
		},
		{
			text = "Saturation",
			type = "NUMBER",
			min = 0,
			max = 100,
			step = 5,
			default_value = 100
		},
		{
			text = "Value",
			type = "NUMBER",
			min = 0,
			max = 100,
			step = 5,
			default_value = 100
		},
	},
	init=function (events, props)
		
		local function applyColor()
			models.player:setColor(vectors.hsvToRGB(
			props[2].value/100,
			props[3].value/100,
			props[4].value/100
		))
		end
		
		props[2].VALUE_CHANGED:register(applyColor)
		props[3].VALUE_CHANGED:register(applyColor)
		props[4].VALUE_CHANGED:register(applyColor)
		applyColor()
		
		events.ON_EXIT:register(function ()
			models.player:setColor()
		end)
	end
}

