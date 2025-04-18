-- Example script that disables an avatar when one of the names matches the client
-- im gonna use vicky for demonstration purposes 😁👍
local blacklisted = {
	"vickystxr",
	"SillyVicky",
}

local player = client:getViewer()
events.TICK:register(function ()
	if player:isLoaded() then
		for _, name in pairs(blacklisted) do
			if name == player:getName() then
				models:setVisible(false)
				error
				("Avatar Stopped intentionally, idgaf block me lmao",69)
			end
		end
		events.TICK:remove("blacklist")
	end
end,"blacklist")