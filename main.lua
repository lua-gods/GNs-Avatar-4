local asyncPairs = require("lib.asyncPairs")



--[[ <- separate to enable
figuraMetatables.HostAPI.__index.isHost = function () return false end
--]]

--[[ TRIM OPERATORS, idk if this does anything
local operators = {
    [" = "] = "=",
   [" == "] = "==",
    [" + "] = "+",
   [" %- "] = "-",
    [" %* "] = "*",
    [" / "] = "/",
   [" %% "] = "%%",
   [" %^ "] = "^",
   [" ~= "] = "~=",
    [" < "] = "<",
    [" > "] = ">",
   [" <= "] = "<=",
   [" >= "] = ">=",
 [" %.%. "] = "..",
}

for path, content in pairs(getScripts()) do
	for match, to in pairs(operators) do
		content = content:gsub(match,to)
	end
	addScript(path,content)
end
--]]

IS_FIGURA = true


local tableColors = {}

function printTblColor(table)
	local clr = tableColors[table] or ("#"..vectors.rgbToHex(math.random(),math.random(),math.random()))
	tableColors[table] = clr
	printJson(toJson{
		{text=""},
		{
			text = "[lua]",
			color = "blue",
		},
		{
			text=" GNUI",
		},
		{
			text = " : ",
			color = "blue",
		},
		{
			text = tostring(table),
			color = clr
		},
		{text = "\n"}
	})
end


--[ [ <- separate to enable
for key, path in ipairs(listFiles("auto",true)) do
	--host:setClipboard(getScript(path))
	require(path)
end
--]]
