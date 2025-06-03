local MiniMacro = require("lib.MiniMacro")
local modelUtils = require("lib.modelUtils")

---@class SkullInstance
---@field identity SkullIdentity
---@field model ModelPart
local SkullInstance = {}
SkullInstance.__index = SkullInstance


---@class SkullInstanceEntity : SkullInstance
---@field itemEntity Entity

---@class SkullInstanceBlock : SkullInstance
---@field block BlockState
---@field pos Vector3
---@field dir Vector3
---@field offset Vector3
---@field support BlockState

---@class SkullInstanceHat : SkullInstance
---@field entity Entity
---@field vars table

---@class SkullInstanceHud : SkullInstance
---@field item ItemStack



---@class SkullIdentity
---@field name string
---
---@field modelBlock ModelPart
---@field modelHat ModelPart
---@field modelHud ModelPart
---@field modelItem ModelPart
---
---@field processBlock MiniMacro
---@field processHat MiniMacro
---@field processHud MiniMacro
---@field processItem MiniMacro
local SkullIdentity = {}
SkullIdentity.__index = SkullIdentity


function SkullIdentity:newInstance()
	local instance = {
		identity = self,
		modelBlock = modelUtils.deepCopy(self.modelBlock):setVisible(true),
		modelHat   = modelUtils.deepCopy(self.modelHat):setVisible(true),
		modelHud   = modelUtils.deepCopy(self.modelHud):setVisible(true),
		modelItem  = modelUtils.deepCopy(self.modelItem):setVisible(true),
	}
	setmetatable(instance,SkullInstance)
	return instance
end

---@return SkullInstanceBlock
function SkullIdentity:newBlockInstance()
	local instance = {
		identity = self,
		model = modelUtils.deepCopy(self.modelBlock):setVisible(true):moveTo(models),
	}
	setmetatable(instance,SkullInstance)
	return instance
end

---@class SkullAPI
local SkullAPI = {}

---@type table<string,SkullIdentity>
local skullIdentities = {}


local function modelIdentityPeprocess(model)
	return model:setParentType("SKULL"):setVisible(false)
end


---@param cfg SkullIdentity|{}
function SkullAPI.registerIdentity(cfg)
	local root = models:newPart(cfg.name.."root")
	
	local identity = {
		modelBlock = modelIdentityPeprocess(cfg.modelBlock),
		modelHat   = modelIdentityPeprocess(cfg.modelHat),
		modelHud   = modelIdentityPeprocess(cfg.modelHud),
		modelItem  = modelIdentityPeprocess(cfg.modelItem),
		
		processBlock = cfg.processBlock or MiniMacro.new(),
		processHat   = cfg.processHat   or MiniMacro.new(),
		processHud   = cfg.processHud   or MiniMacro.new(),
		processItem  = cfg.processItem  or MiniMacro.new(),
	}
	root:addChild(identity.modelBlock)
	root:addChild(identity.modelHat)
	root:addChild(identity.modelHud)
	root:addChild(identity.modelItem)
	
	setmetatable(identity,SkullIdentity)
	skullIdentities[cfg.name] = identity
	return identity
end

local skullBlockInstance = {}
local skullHatInstance = {}
local skullHudInstance = {}
local skullItemInstance = {}

events.WORLD_RENDER:register(function ()
	skullBlockInstance = {}
	skullHatInstance = {}
	skullHudInstance = {}
	skullItemInstance = {}
end)

local lastInstance ---@type SkullInstance
local lastState = 0
local lastName
events.SKULL_RENDER:register(function (delta, block, item, entity, ctx)
	local name = item and item:getName() or "DEFAULT"
	local state = 
	   ctx == "BLOCK" and 1
	or ctx == "HEAD" and 2
	or ctx == "OTHER" and 4 or 3
	
	if name ~= lastName or state ~= lastState then
		lastName = name
		lastState = state
		local identity = skullIdentities[name] or skullIdentities.Default
		if lastInstance then
			lastInstance.model:setVisible(false)
		end
		if state == 1 then -- BLOCK
			local pos = block:getPos()	
			local id = pos.x .. "," .. pos.y .. "," .. pos.z
			
			local instance = skullBlockInstance[id]
			
			if not instance then -- new instance
				instance = identity:newBlockInstance() ---@type SkullInstanceBlock
				instance.block = block
				instance.pos = pos
				
				skullBlockInstance[id] = instance
				instance.identity.processBlock.ON_ENTER(instance,instance.model)
				instance.identity.processBlock.PROCESS(instance,instance.model)
			else -- existing instance
				instance.identity.processBlock.PROCESS(instance,instance.model)
			end
			instance.model:setVisible(true)
			lastInstance = instance
		end
	end
end)

return SkullAPI