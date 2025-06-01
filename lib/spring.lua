-- 2nd-order system library
-- source: https://www.youtube.com/watch?v=KPoeNZZ6H4

---@class Spring
---@field pos number
---@field lpos number
---@field accel number
---@field target number
---@field ltarget number
---@field f number
---@field z number
---@field r number
---@field package next Spring?
---@field package prev Spring?
local Spring = {}
Spring.__index = Spring

local first
local last

local TAU = math.pi*2
local PI = math.pi

---@param cfg {pos?: number, vel?: number,f?: number,z?: number,r?: number}
function Spring.new(cfg)
	local s = {
		pos = cfg.pos or 0,
		vel = cfg.vel or 0,
		f = cfg.f or 1,
		z = cfg.z or 0.05,
		r = cfg.r or 0,
		target = 0,
		ltarget = 0,
		accel = 0,
	}
	-- compute constraints
	s.k1 = s.z / (PI * s.f)
	s.k2 = 1 / ((2 * PI * s.f) * (TAU * s.f))
	s.k3 = s.r * s.z / (TAU * s.f)
	
	setmetatable(s, Spring)
	if not first then first = s last = s
	else s.prev = last last.next = s last = s end
	return s
end



function Spring.update(t)
	t = math.min(t, 0.1)
	local s = first
	while s do
		
		local taccel = 0
		if not s.ltarget then
			taccel = (s.target - s.ltarget) / t
		end
		s.ltarget = s.target
		
		s.pos = s.pos + t * s.vel
		s.vel = s.vel + t * (s.target + s.k3*taccel - s.pos - s.k1*s.vel - s.k1*s.vel) / s.k2
		
		s = s.next
	end
end


function Spring:free()
	self.prev.next = self.next
	self.next.prev = self.prev
end

local lastSystemTime = client:getSystemTime()
events.RENDER:register(function ()
	local systemTime = client:getSystemTime()
	local delta = (systemTime - lastSystemTime) / 1000
	Spring.update(delta)
end)

return Spring