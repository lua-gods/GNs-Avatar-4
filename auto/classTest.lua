local Class = require("lib.GNClass")


local color = Class.apply({color="red"})

color.COLOR_CHANGED:register(function (c)
	print("Color changed to "..c)
end)

color:setColor("glue")

print(color:getColor())
print(color.color)


