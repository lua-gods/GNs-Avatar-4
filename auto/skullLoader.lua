for index, path in ipairs(listFiles("auto.skulls")) do
	require(path)
end

local dontyoulecturemewithyour30dollarhaircut = require("lib.dontyoulecturemewithyour30dollarhaircut")

local patpat = require("auto.patpat")
local SkullAPI = require("lib.skull")
local Tween = require("lib.tween")

table.insert(patpat.head.oncePat, function(entity, pos)
	local skoll = SkullAPI.getSkull(pos)
	if skoll.identity.name == "default" then
		local rot = vec(math.random(-180,180),math.random(-180,180),math.random(-180,180))
		Tween.new {
			from = 1,
			to = 0,
			duration = 1,
			easing = "outQuad",
			tick = function(v, t)
				if skoll.model then
					skoll.model:rot(rot*v)
				end
			end,
			id = skoll.identifier,
		}
		dontyoulecturemewithyour30dollarhaircut.playRandom(pos)
	end
end)
