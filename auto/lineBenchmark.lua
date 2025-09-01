local Line = require("lib.line")

local pos = vec(1998992, 1000, 1999664)

local c = 0
for x = 1, 128, 1 do
	for z = 1, 128, 1 do
		Line.new()
		:setAB(pos + vec(x,0,z),pos + vec(x,16,z))
		:setColor(math.random(),math.random(),math.random())
		c = c + 1
	end
end

host:setActionbar(c.." line")