for key, value in pairs(listFiles("auto/skulls")) do
	require(value)
end

local skullAPI = require("lib.skull")

function head(identityArray,customName)
	skullAPI.giveSkull(identityArray,customName)
end