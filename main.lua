local asyncPairs = require("lib.asyncPairs")



--[[ <- separate to enable
figuraMetatables.HostAPI.__index.isHost = function () return false end
--]]


--[ [ <- separate to enable
for key, path in ipairs(listFiles("auto")) do
	require(path)
end
--]]
