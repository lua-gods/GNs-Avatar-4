local isHost = host:isHost() and true
local function loadFiles(path)
	for key, script in pairs(listFiles(path)) do
		if isHost then
			require(script)
		else
			if not script:find("%.%$[^$]+$") then
				require(script)
			end
		end
	end
end
loadFiles("class")
loadFiles("primitive")
loadFiles("generic")