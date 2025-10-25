local NAME = "GNanimates"


local icanhasnewemojis = false

nameplate.ENTITY:setOutline(true):setBackgroundColor(0,0,0,0)

-- check if the new emojis exist
local ogText = nameplate.ENTITY:getText()
local ok, result = pcall(nameplate.ENTITY.setText,nameplate.ENTITY,("A"):rep(63)..":back:")
if ok then icanhasnewemojis = true end
nameplate.ENTITY:setText(ogText)
-- end of test


-- gradient generation
local HEX_FROM = "#d3fc7e"
local HEX_TO = "#33984b"

local from = vectors.hexToRGB(HEX_FROM)
local to = vectors.hexToRGB(HEX_TO)


-- prefix
local final = {
	{text="${badges}:@gn:"},
	{text=":back::@gn_band:",color=HEX_FROM},
	{text=" "},
}

if not icanhasnewemojis then
	table.remove(final,2)
end

local shift = #final
local lname = #NAME
for i = 1, lname, 1 do
	local w = i/lname
	final[i+shift] = {
		color="#"..vectors.rgbToHex(math.lerp(from,to,w)),
		text=NAME:sub(i,i),
	}
end

nameplate.LIST:setText(toJson(final))


final[icanhasnewemojis and 3 or 2].text = ""

local json = toJson(final)
nameplate.ENTITY:setText(json)
nameplate.CHAT:setText(json)