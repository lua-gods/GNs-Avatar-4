local Line = require("lib.line")

local pos = vec(1999051, 72, 1999390)

local c = 0
for x = 1, 64, 1 do
	for z = 1, 64, 1 do
		Line.new()
		:setAB(pos + vec(x,0,z),pos + vec(x,16,z))
		:setColor(math.random(),math.random(),math.random())
		c = c + 1
	end
end

host:setActionbar(c.." line")