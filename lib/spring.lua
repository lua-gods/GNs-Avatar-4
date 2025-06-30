--[[______   __
  / ____/ | / /  by: GNanimates / https://gnon.top / Discord: @gn68s
 / / __/  |/ / name: Spring Library
/ /_/ / /|  /  desc: 
\____/_/ |_/ source: link ]]
-- 2nd-order system library
-- source: https://www.youtube.com/watch?v=KPoeNZZ6H4s

---@class Spring
---@field vel number
---@field pos number
---@field lpos number
---@field accel number
---@field target number
---@field ltarget number
---@field responseSpeed number
---@field dampingCoeficient number
---@field r number
---@field package next Spring?
---@field package prev Spring?
local Spring = {}
Spring.__index = Spring

---@class Spring.Vector3 : Spring
---@field pos Vector3
---@field lpos Vector3
---@field accel Vector3
---@field target Vector3
---@field ltarget Vector3


---@class Spring.Vector2 : Spring
---@field pos Vector2
---@field lpos Vector2
---@field accel Vector2
---@field target Vector2
---@field ltarget Vector2


local springs = {}

local TAU = math.pi*2
local PI = math.pi


---@param responseSpeed number?
---@param dampingCoeficient number?
---@param initialResponseStrength number?
---@return table
function Spring.new(responseSpeed,dampingCoeficient,initialResponseStrength)
	local s = {
		pos = 0,
		vel = 0,
		responseSpeed = responseSpeed or 1,
		dampingCoeficient = dampingCoeficient or 0.05,
		initialResponseStrength = initialResponseStrength or 0,
		target = 0,
		ltarget = 0,
		accel = 0,
	}
	-- compute constraints
	s.k1 = s.dampingCoeficient / (PI * s.responseSpeed)
	s.k2 = 1 / ((2 * PI * s.responseSpeed) * (TAU * s.responseSpeed))
	s.k3 = s.initialResponseStrength * s.dampingCoeficient / (TAU * s.responseSpeed)
	
	setmetatable(s, Spring)
	springs[s] = true
	return s
end

---@param responseSpeed number?
---@param dampingCoeficient number?
---@param initialResponseStrength number?
---@return Spring.Vector3
function Spring.newVec3(responseSpeed,dampingCoeficient,initialResponseStrength)
	local spring = Spring.new(responseSpeed,dampingCoeficient,initialResponseStrength)
	spring.pos = vec(0,0,0)
	spring.vel = vec(0,0,0)
	spring.target = vec(0,0,0)
	spring.ltarget = vec(0,0,0)
	spring.accel = vec(0,0,0)
	return spring
end

---@param responseSpeed number?
---@param dampingCoeficient number?
---@param initialResponseStrength number?
---@return Spring.Vector3
function Spring.newVec2(responseSpeed,dampingCoeficient,initialResponseStrength)
	local spring = Spring.new(responseSpeed,dampingCoeficient,initialResponseStrength)
	spring.pos = vec(0,0)
	spring.vel = vec(0,0)
	spring.target = vec(0,0)
	spring.ltarget = vec(0,0)
	spring.accel = vec(0,0)
	return spring
end


function Spring:free()
	springs[self] = nil
end



local lastTime = client:getSystemTime()
models:newPart("SpringProcessor","WORLD").midRender = function (_, context, part)
	local time = client:getSystemTime()
	local delta = (time - lastTime) / 1000
	lastTime = time
	delta = math.min(delta, 0.1)
	for s in pairs(springs) do
		local taccel = 0
		if not s.ltarget then
			taccel = (s.target - s.ltarget) / delta
		end
		s.ltarget = s.target
		
		s.pos = s.pos + delta * s.vel
		s.vel = s.vel + delta * (s.target + s.k3*taccel - s.pos - s.k1*s.vel - s.k1*s.vel) / s.k2
	end
end

return Spring