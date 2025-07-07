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

--[ [ <- separate to enable
for key, path in ipairs(listFiles("auto",true)) do
	--host:setClipboard(getScript(path))
	require(path)
end
--]]
