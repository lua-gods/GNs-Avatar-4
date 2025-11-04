
---@type table<Dust.Identity,Dust.Instance[]>
local instances = {}

---@type table<string,Dust.Identity>
local identities = {}

local function deepCopy(part)
	local copy = part:copy(part:getName())
	for key, value in pairs(part:getTask()) do
		copy:addTask(value)
	end
	for _, child in ipairs(part:getChildren()) do
		copy:removeChild(child)
		deepCopy(child):moveTo(copy)
	end
	return copy
end


---@class DustAPI
---@field identities table<string,Dust.Identity>
local DustAPI = {
	identities = {}
}

--[[______   __
  / ____/ | / /  by: GNanimates / https://gnon.top / Discord: @gn68s
 / / __/  |/ / name: DUST LIBRARY
/ /_/ / /|  /  desc: GN's Particle Library
\____/_/ |_/ source: link ]]

---an identity a particle can be when spawned
---@class Dust.Identity
---@field id string
---@field model ModelPart
---@field duration number
---@field process fun(Sandstorm.ParticleInstance)

---an physical representation of a particle
---@class Dust.Instance
---@field identity Dust.Identity
---@field model ModelPart
---@field lpos Vector3
---@field pos Vector3
---@field vel Vector3
---@field age number


---Creates a new process with properties expected from a particle
---@param damping number|Vector3 # between 0 and 1, gets applied to velocity
---@param gravity Vector3 # in m/s
---@return fun(Sandstorm.ParticleInstance)
function DustAPI.newProcessMaterial(damping, gravity)
	gravity = gravity / 20
	return function (p)
		p.vel = (p.vel + gravity)  * damping
		p.pos = p.pos + p.vel
	end
end

--- this gets used when no process is giveth.
local DEFAULT_PROCESS = DustAPI.newProcessMaterial(0.95, vec(0,-1,0))


---Registers a particle template to be spawned later.
---@param id string
---@param model ModelPart # The ModelPart to be displayed when a particle is spawned
---@param duration number? # (in seconds) how long the particle should last, this defaults to 1
---@param process fun(Sandstorm.ParticleInstance)?
function DustAPI.registerIdentity(id, model, duration, process)
	assert(identities[id] == nil, "Particle identity already exists: " .. id)
	assert(model, "No model provided")
	local identity = {
		id = id,
		duration = (duration or 1) * 20,
		model = model,
		process = process or DEFAULT_PROCESS,
	}
	identities[id] = identity
end


---Spawns a particle.
---@param id string
---@param pos Vector3?
---@param vel Vector3?
function DustAPI.spawn(id, pos, vel)
	assert(identities[id], "No such particle identity: " .. id)
	local identity = identities[id]
	instances[identity] = instances[identity] or {}
	
	local instance = {
		identity = identity,
		model = deepCopy(identity.model):setParentType("WORLD"):moveTo(models),
		pos = pos or vec(0,0,0),
		vel = vel or vec(0,0,0),
		age = 0,
	}

	instances[identity][#instances[identity]+1] = instance
	return instance
end


events.TICK:register(function ()
	for identity, particles in pairs(instances) do
		for i, instance in pairs(particles) do
			instance.lpos = instance.pos
			identity.process(instance)
			instance.age = instance.age + 1
			if instance.age > identity.duration then
				instance.model:remove()
				particles[i] = nil
			end
		end
	end
end)


events.RENDER:register(function (delta, ctx, matrix)
	if ctx == "RENDER" or ctx == "FIRST_PERSON" then
		for identity, particles in pairs(instances) do
			for i, p in pairs(particles) do
				p.model:setPos(math.lerp(p.lpos or p.pos, p.pos, delta) * 16)
			end
		end
	end
end)


return DustAPI