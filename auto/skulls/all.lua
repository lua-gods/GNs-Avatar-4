local Skull = require("lib.skull")


---@type SkullIdentity|{}
local identity = {
	name = "All",
	id = "all",
}

local ENV = {
	sin = math.sin,
	cos = math.cos,
	tan = math.tan,
	asin = math.asin,
	acos = math.acos,
	atan = math.atan,
	atan2 = math.atan2,
	ceil = math.ceil,
	floor = math.floor,
	round = math.round,
	clamp = math.clamp,
}

local function makeEnv(table)
	for index, value in pairs(ENV) do
		table[index] = value
	end
	return table
end


identity.processBlock = {
	ON_INIT = function (skull, model)
		local env = makeEnv({
				pos = skull.pos,
				rot = skull.rot,
				dir = skull.dir,
				t = 0,
			})
		if skull.params.rotx then skull.rotx = load("return "..skull.params.rotx,skull.hash,env) end
		if skull.params.roty then skull.roty = load("return "..skull.params.roty,skull.hash,env) end
		if skull.params.rotz then skull.rotz = load("return "..skull.params.rotz,skull.hash,env) end
		
		if skull.params.posx then skull.posx = load("return "..skull.params.posx,skull.hash,env) end
		if skull.params.posy then skull.posy = load("return "..skull.params.posy,skull.hash,env) end
		if skull.params.posz then skull.posz = load("return "..skull.params.posz,skull.hash,env) end
		
		skull.env = env
	end,
	ON_PROCESS = function (skull, model, deltaFrame, deltaTick)
		skull.env.t = skull.env.t + deltaFrame
		local rot = vec(
			skull.rotx and skull.rotx() or 0,
			skull.roty and skull.roty() or 0,
			skull.rotz and skull.rotz() or 0
			)
		skull.baseModel:setRot(rot)
	end
}

Skull.registerIdentity(identity)