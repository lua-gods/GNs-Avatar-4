local MiniMacro = require("lib.MiniMacro")
local modelUtils = require("lib.modelUtils")
local DiffTable = require("lib.diffTable")


local time = client:getSystemTime()


---@class SkullInstance
---@field identity SkullIdentity
---@field model ModelPart
---@field lastSeen integer
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
		lastSeen = time,
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

-- this is used to avoid using world render when I am offline
local modelSkullRenderer = models:newPart("SkullRenderer","SKULL")
modelSkullRenderer:newBlock("forceRenderer"):scale(0,0,0):block("minecraft:emerald_block")


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

local blockInstances = DiffTable.new(function (id,identity, block, pos)
	instance = identity:newBlockInstance() ---@type SkullInstanceBlock
	instance.block = block
	instance.pos = pos
	
	instance.identity.processBlock.ON_ENTER(instance,instance.model,0)
	return instance
end)


local queueRenderProcess = false

events.WORLD_RENDER:register(function ()
	modelSkullRenderer:setVisible(true)
end)



local lastInstance ---@type SkullInstance
local lastName


events.SKULL_RENDER:register(function (delta, block, item, entity, ctx)
	local name = item and item:getName() or "DEFAULT"
	local state = 
	   ctx == "BLOCK" and 1
	or ctx == "HEAD" and 2
	or ctx == "OTHER" and 4 or 3
	
	if name ~= lastName or true then
		lastName = name
		local identity = skullIdentities[name] or skullIdentities.Default
		if lastInstance then
			lastInstance.model:setVisible(false)
		end
		if state == 1 then -- BLOCK
			local pos = block:getPos()
			local id = pos.x .. "," .. pos.y .. "," .. pos.z
			
			local instance = blockInstances[id] ---@cast instance SkullInstanceBlock
			
			if not blockInstances[id] then -- new instance
				instance = blockInstances:set(id,identity,block,pos)
			else
				instance.lastSeen = time
			end
			instance.model:setVisible(true)
			lastInstance = instance
		end
	end
end)

modelSkullRenderer.preRender = function (delta, context, part)
	modelSkullRenderer:setVisible(false)
	time = client:getSystemTime()
	delta = client:getFrameTime()
	
	if next(blockInstances.data) then
		---@param instance SkullInstanceBlock
		for key, instance in pairs(blockInstances.data) do
			if time - instance.lastSeen > 1000 or (not world.getBlockState(instance.pos).id:find("head$")) then
				instance.identity.processBlock.ON_EXIT(instance,instance.model,delta)
				instance.model:remove()
				blockInstances:set(key,nil)
			end
			instance.identity.processBlock.PROCESS(instance,instance.model,delta)
		end
	end
end

return SkullAPI