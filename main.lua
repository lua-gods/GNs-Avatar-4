local asyncPairs = require("lib.asyncPairs")


figuraMetatables.HostAPI.__index.isHost = function () return false end

for key, path in ipairs(listFiles("auto")) do
	require(path)
end
