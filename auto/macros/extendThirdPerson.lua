---@type GNsAvatar.Macro
return {
	name = ":camera: Offset 3rd Person Cam",
	config = {
		{
			text = "Extends the 3rd Person Camera further",
			type = "LABEL",
		},
		{
			text = "Distance",
			type = "NUMBER",
			min = 3,
			max = 200,
			step = 1,
			default_value = 3
		},
		
	},
	init=function (events, props)
		
		local function apply()
			local dist = props[2].value - 3
			renderer:setCameraPos(0,0,dist)
		end
		apply()
		
		props[2].VALUE_CHANGED:register(apply)
	end
}