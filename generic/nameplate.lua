local name = "GNanimates"

local from = vectors.hexToRGB(  "#d3fc7e"  )
local to = vectors.hexToRGB(    "#33984b"  )

local output = {}

local lname = #name
for i = 1, lname, 1 do
	local w = i/lname
	output[i] = {color="#"..vectors.rgbToHex(math.lerp(from,to,w)),text=name:sub(i,i)}
end

table.insert(output,1,{"${badges}:@gn:"})
nameplate.ALL:setText(toJson(output))

output[1] = {"${badges}:@gn: "}

nameplate.ENTITY:setOutline(true)
nameplate.ENTITY:setBackgroundColor(0,0,0,0)
nameplate.LIST:setText(toJson(output))