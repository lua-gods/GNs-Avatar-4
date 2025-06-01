local asyncPairs = require("lib.asyncPairs")

for key, path in ipairs(listFiles("auto")) do
	require(path)
end