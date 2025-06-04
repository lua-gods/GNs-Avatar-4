local asyncPairs = require("lib.asyncPairs")

require("auto.skulls.default")

asyncPairs(listFiles("auto/skulls"),function (path)
	require(path)
end)