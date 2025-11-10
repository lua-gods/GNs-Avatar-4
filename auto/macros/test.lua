---@type GNsAvatar.Macro
return {
	name = "Test Macro",
	config = {
		{
			text = "Boolean",
			type = "BOOLEAN",
		},
		{
			text = "Number",
			type = "NUMBER",
			min = 0,
			max = 100,
			step = 5,
			default_value = 50
		},
		{
			text = "String",
			type = "STRING",
			default_value = "Hello World"
		},
		{
			text = "Button",
			type = "BUTTON",
		},
		{
			text = "Lorem Ipsum Dolor Sit Amet",
			type = "LABEL",
		}
	},
	init=function (events, props)
		
	end
}