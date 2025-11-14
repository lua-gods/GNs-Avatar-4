---@type GNsAvatar.Macro
return {
	name = ":mci_arrow: Projectile Shower",
	config = {
		{
			text = "Shoot the item being held",
			type = "LABEL",
		},
		{
			text = "Power",
			type = "NUMBER",
			min = 0,
			max = 100,
			step = 10,
			default_value = 60
		},
		{
			text = "Scatter Angle",
			type = "NUMBER",
			min = 0,
			max = 180,
			step = 10,
			default_value = 30
		},
		
	},
	init=function (events, props)
		events.TICK:register(function ()
		end)
	end
}