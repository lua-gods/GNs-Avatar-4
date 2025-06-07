local name = "GNanimates"

local from = vectors.hexToRGB("#d3fc7e")
local to = vectors.hexToRGB("#33984b")

-- {"text":"test","clickEvent":{"action":"suggest_command","value":"test"}}}

local output = {}

local lname = #name
for i = 1, lname, 1 do
	local w = i/lname
	output[i] = {
		color="#"..vectors.rgbToHex(math.lerp(from,to,w)),
		text=name:sub(i,i),
		--hoverEvent={action="show_text",contents=hover},
	}
end

table.insert(output,1,{"${badges}:@gn:"})
nameplate.ALL:setText(toJson(output))

output[1] = {"${badges}:@gn: "}

nameplate.ENTITY:setOutline(true)
nameplate.ENTITY:setBackgroundColor(0,0,0,0)
--nameplate.ENTITY:setPos(-1.3,0,0):setPivot(0,1.7,0)
nameplate.LIST:setText(toJson(output))