local casts = {}

local LENGTH = 5

local ray_count = 500
for i = 1, ray_count, 1 do
   local t = i / ray_count
   local inclination = math.acos(1 - 2 * t)
   local azimuth = 2 * math.pi * 0.618033 * i
   local dir = vectors.vec3(
      math.sin(inclination) * math.sin(azimuth),
      -math.cos(inclination),
      math.sin(inclination) * math.cos(azimuth)
   )
   casts[i] = (dir * vec(1,0.8,1)):normalized()
end

---@param dirVec Vector3
---@return Vector3
local function dir2Angle(dirVec)
	local yaw = math.atan2(dirVec.x, dirVec.z)
	local pitch = math.atan2(dirVec.y, dirVec.xz:length())
	return vec(-math.deg(pitch), -math.deg(yaw), 0)
end


events.WORLD_RENDER:register(function ()
	local pos = player:getPos()
	local average = vec(0,0,0)
	local count = 0
	local minDist = math.huge
	
	for index, dir in ipairs(casts) do
		local block, hitpos, side = raycast:block(pos,pos + dir*LENGTH)
		local dist = (pos - hitpos):length()
		if dist < LENGTH-0.1 then
			count = count + 1
			minDist = math.min(minDist,dist)
			average = average + dir
		end
	end
	
	average = average / math.max(count,1)
	if player:getPose() == "FALL_FLYING" then
		if count > 1 then
			host:setVelocity((average * -0.2 / math.max(minDist,0.1)) + vec(table.unpack(player:getNbt().Motion)))
		end
	end
end)