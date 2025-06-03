local asyncPairs = require("lib.asyncPairs")

asyncPairs(listFiles("auto/skulls"),function (path)
	require(path)
end)