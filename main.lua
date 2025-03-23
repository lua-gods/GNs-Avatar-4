local isHost = host:isHost() and true
local function loadFiles(path)
	for key, script in pairs(listFiles(path,true)) do
		if isHost then
			require(script)
		else
			if not script:find("%.%$[^$]+$") then
				require(script)
			end
		end
	end
end
loadFiles("primitive")
loadFiles("class")
loadFiles("generic")