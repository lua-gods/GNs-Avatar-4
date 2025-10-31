---@diagnostic disable: undefined-field
if not events.ERROR then return end
local BetterErrorAPI = require("lib.betterError")


events.ERROR:register(function (error)
	local json = BetterErrorAPI.parseError(error)
	printJson(toJson(json))
	goofy:stopAvatar()
	return true
end)
