local asyncPairs = require("lib.asyncPairs")

asyncPairs(listFiles("auto"), function (path)
	require(path)
end)