--[[______   __
  / ____/ | / /  by: GNanimates / https://gnon.top / Discord: @gn68s
 / / __/  |/ / name: SKULL SYSTEM SERVICE
/ /_/ / /|  /  desc: handles all the skull instances
\____/_/ |_/ source: https://github.com/lua-gods/GNs-Figura-Avatar-4/blob/main/lib/skull.lua ]]

local MiniMacro = require("lib.MiniMacro")
local modelUtils = require("lib.modelUtils")


local ZERO = vec(0,0,0)
local FORWARD = vec(0,0,1)
local UP = vec(0,1,0)

-- this is used to avoid using world render when I am offline
local SKULL_PROCESS = models:newPart("SkullRenderer","SKULL")
SKULL_PROCESS:newBlock("forceRenderer"):scale(0,0,0):block("minecraft:emerald_block")

---@type table<string,SkullIdentity>
local skullIdentities = {}


local time = client:getSystemTime()
local startupStall = 5

---@class SkullAPI
local SkullAPI = {}


--[────────────────────────-< Instance Class Declarations >-────────────────────────]--


---@class SkullInstance
---@field identity SkullIdentity
---@field model ModelPart
---@field lastSeen integer
---@field matrix Matrix4
---@field [any] any
local SkullInstance = {}
SkullInstance.__index = SkullInstance


--[────────-< Entity Instance >-────────]--
---@class SkullInstanceEntity : SkullInstance
---@field itemEntity Entity

--[────────-< Block Instance >-────────]--
---@class SkullInstanceBlock : SkullInstance
---@field blockModel ModelPart
---@field block BlockState
---@field pos Vector3
---@field isWall boolean
---@field rot number
---@field dir Vector3
---@field offset Vector3
---@field support BlockState

--[────────-< Hat Instance >-────────]--
---@class SkullInstanceHat : SkullInstance
---@field entity Entity
---@field vars table

--[────────-< HUD Instance >-────────]--
---@class SkullInstanceHud : SkullInstance
---@field item ItemStack


--[────────────────────────────────────────-< Skull Identity >-────────────────────────────────────────]--


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


local function modelIdentityPeprocess(model)
	return model:setParentType("SKULL"):setVisible(false)
end

---@param cfg SkullIdentity|{}
function SkullAPI.registerIdentity(cfg)
	local root = models:newPart(cfg.name.."root")
	
	local identity = {
		name = cfg.name,
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


local blockInstances = {}


events.WORLD_RENDER:register(function ()
	SKULL_PROCESS:setVisible(true)
end)

local lastInstance ---@type SkullInstance

events.SKULL_RENDER:register(function (delta, block, item, entity, ctx)
	if startupStall then return end
	if lastInstance then
		lastInstance.model:setVisible(false)
	end
	
	if ctx == "BLOCK" then --[────────────────────-< BLOCK >-────────────────────]--
		
		local pos = block:getPos()
		local id = pos.x.. "," ..pos.y .. "," .. pos.z
		
		local instance = blockInstances[id] ---@cast instance SkullInstanceBlock
		
		
		if not instance then -- new instance
			local isWall = block.id:find("wall_head$") and true or false
			local rot = isWall and (({north=180,south=0,east=90,west=270})[block.properties.facing]) or ((tonumber(block.properties.rotation) * -22.5 + 180) % 360)
			local matrix = matrices.mat4():rotateY(rot):translate(pos)
			local dir = matrix:applyDir(0,0,1)
			
			local support = world.getBlockState(pos - (isWall and dir or UP))
			local identity = skullIdentities[support.id] or skullIdentities.Default
			instance = identity:newBlockInstance() ---@type SkullInstanceBlock
			
			
			instance.support = support
			instance.block   = block
			instance.pos     = pos
			instance.isWall  = isWall
			instance.rot     = rot
			instance.dir     = dir
			instance.matrix  = matrix
			
			local blockModel = instance.model
			:newPart("blockModelArm")
			:rot(0,-rot)
			:newPart("blockModel")
			:pos(vec(-8,0,-8) + (isWall and matrix:applyDir(0,-4,-4) or ZERO))
			instance.blockModel = blockModel
			
			blockInstances[id] = instance
			
			instance.identity.processBlock.ON_ENTER(instance,instance.model,delta)
		else
			instance.lastSeen = time
		end
		instance.model:setVisible(true)
		lastInstance = instance
	end
end)


SKULL_PROCESS.postRender = function (delta, context, part)
	SKULL_PROCESS:setVisible(false)
	time = client:getSystemTime()
	delta = client:getFrameTime()
	
	if next(blockInstances) then
		---@param instance SkullInstanceBlock
		for key, instance in pairs(blockInstances) do
			if time - instance.lastSeen > 1000 or (not world.getBlockState(instance.pos).id:find("head$")) then
				instance.identity.processBlock.ON_EXIT(instance,instance.model,delta)
				instance.model:remove()
				blockInstances[key] = nil
			end
			instance.identity.processBlock.PROCESS(instance,instance.model,delta)
		end
	end
end


SKULL_PROCESS.preRender = function (delta, context, part)
	startupStall = startupStall - 1
	if startupStall < 0 then
		startupStall = nil
		SKULL_PROCESS.preRender = nil
	end
end



function SkullAPI.getSkullBlockInstances()
	return blockInstances
end


---@param pos Vector3
---@return string
function SkullAPI.toID(pos)
	return pos.x.. "," ..pos.y .. "," .. pos.z
end


return SkullAPI