local NAME = "GNanimates"

if math.random() < 0.05 then
	NAME = "GNaminates"
end

local from = vectors.hexToRGB("#d3fc7e")
local to = vectors.hexToRGB("#33984b")

local output = {}

local lname = #NAME
for i = 1, lname, 1 do
	local w = i/lname
	output[i] = {
		color="#"..vectors.rgbToHex(math.lerp(from,to,w)),
		text=NAME:sub(i,i),
	}
end

table.insert(output,1,{"${badges}:@gn:"})
nameplate.ALL:setText(toJson(output))

output[1] = {"${badges}:@gn: "}

nameplate.ENTITY:setOutline(true):setBackgroundColor(0,0,0,0)
nameplate.LIST:setText(toJson(output))