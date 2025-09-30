local NAME = "GNSA"

if math.random() < 0.05 then
	NAME = "GMSA"
end

local from = vectors.hexToRGB("#edab50")
local to = vectors.hexToRGB("#8e251d")

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

output[1] = {"${badges}:@scarlet: "}

nameplate.ENTITY:setOutline(true):setBackgroundColor(0,0,0,0)
nameplate.LIST:setText(toJson(output))