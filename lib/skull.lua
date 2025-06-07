--[[______   __
  / ____/ | / /  by: GNanimates / https://gnon.top / Discord: @gn68s
 / / __/  |/ / name: SKULL SYSTEM SERVICE
/ /_/ / /|  /  desc: handles all the skull instances
\____/_/ |_/ source: https://github.com/lua-gods/GNs-Figura-Avatar-4/blob/main/lib/skull.lua ]]

local modelUtils = require("lib.modelUtils")


local ZERO = vec(0,0,0)
local UP = vec(0,1,0)
local SKULL_DECAY_TIME = 100000

-- this is used to avoid using world render when I am offline
local SKULL_PROCESS = models:newPart("SkullRenderer","SKULL")
SKULL_PROCESS:newBlock("forceRenderer"):scale(0,0,0):block("minecraft:emerald_block")


local skullIdentities = {}        ---@type table<string,SkullIdentity>
local skullSupportIdentities = {} ---@type table<string,SkullIdentity>

local time = client:getSystemTime()
local startupStall = 20

---@class SkullAPI
local SkullAPI = {}


local id = 0
---@param iconModelTextureSource ModelPart
function SkullAPI.makeIcon(iconModelTextureSource)
	id = id + 1
	local model = models:newPart("Icon"..id)
	model:setParentType("SKULL")
	:rot(38,-45,0)
	:pos(5.58,13.65,5.58)
	model:newSprite("Icon"):texture(textures[next(iconModelTextureSource:getAllVertices())],16,16):setRenderType("CUTOUT_EMISSIVE_SOLID")
	return model
end


--[────────────────────────-< Instance Class Declarations >-────────────────────────]--


---@class SkullInstance
---@field identity SkullIdentity
---@field queueFree boolean
---@field model ModelPart
---@field lastSeen integer
---@field matrix Matrix4
---@field [any] any
local SkullInstance = {}
SkullInstance.__index = SkullInstance


--[────────────────────────────────────────-< Skull Identity >-────────────────────────────────────────]--


---@class SkullIdentity
---@field name string
---@field support Minecraft.blockID
---
---@field modelBlock ModelPart
---@field modelHat ModelPart
---@field modelHud ModelPart
---@field modelItem ModelPart
---
---@field processBlock SkullProcessBlock
---@field processHat SkullProcessHat
---@field processHud SkullProcessHud
---@field processEntity SkullProcessEntity
---@field [any] any
local SkullIdentity = {}
SkullIdentity.__index = SkullIdentity


local function modelIdentityPeprocess(model)
	return model:setParentType("SKULL"):setVisible(false)
end

local PROCESS_PLACEHOLDER = {
	ON_ENTER = function ()end,
	ON_PROCESS = function ()end,
	ON_EXIT = function ()end
}

local function applyPlaceholders(tbl)
	tbl = tbl or {}
	tbl.ON_ENTER = tbl.ON_ENTER or PROCESS_PLACEHOLDER.ON_ENTER
	tbl.ON_PROCESS = tbl.ON_PROCESS or PROCESS_PLACEHOLDER.ON_PROCESS
	tbl.ON_EXIT = tbl.ON_EXIT or PROCESS_PLACEHOLDER.ON_EXIT
	return tbl
end

---@param cfg SkullIdentity|{}
function SkullAPI.registerIdentity(cfg)
	local root = models:newPart(cfg.name.."root")
	
	local identity = {
		name = cfg.name:lower(),
		support = cfg.support,
		
		modelBlock = modelIdentityPeprocess(cfg.modelBlock),
		modelHat   = modelIdentityPeprocess(cfg.modelHat),
		modelHud   = modelIdentityPeprocess(cfg.modelHud),
		modelItem  = modelIdentityPeprocess(cfg.modelItem),
		
		processBlock =   applyPlaceholders(cfg.processBlock),
		processHat   =   applyPlaceholders(cfg.processHat),
		processHud   =   applyPlaceholders(cfg.processHud),
		processEntity  = applyPlaceholders(cfg.processEntity),
	}
	root:addChild(identity.modelBlock)
	root:addChild(identity.modelHat)
	root:addChild(identity.modelHud)
	root:addChild(identity.modelItem)
	
	setmetatable(identity,SkullIdentity)
	skullIdentities[cfg.name:lower()] = identity
	if identity.support then
		skullSupportIdentities[identity.support] = identity
	end
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


--[────────-< Entity Instance >-────────]--
---@class SkullInstanceEntity : SkullInstance
---@field entity Entity
---@field isFirstPerson boolean
---@field isHand boolean

---@class SkullProcessEntity
---@field ON_ENTER fun(skull: SkullInstanceEntity, model: ModelPart)?
---@field ON_PROCESS fun(skull: SkullInstanceEntity, model: ModelPart, delta: number)?
---@field ON_EXIT fun(skull: SkullInstanceEntity, model: ModelPart)?

---@return SkullInstanceEntity
function SkullIdentity:newEntityInstance()
	local instance = {
		identity = self,
		lastSeen = time,
		model = modelUtils.deepCopy(self.modelItem):setVisible(true):moveTo(models),
	}
	setmetatable(instance,SkullInstance)
	return instance
end

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

---@class SkullProcessBlock
---@field ON_ENTER fun(skull: SkullInstanceBlock, model: ModelPart)?
---@field ON_PROCESS fun(skull: SkullInstanceBlock, model: ModelPart, delta: number)?
---@field ON_EXIT fun(skull: SkullInstanceBlock, model: ModelPart)?

--- Creates an instance with the only data being nessesary to a block.
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

--[────────-< Hat Instance >-────────]--
---@class SkullInstanceHat : SkullInstance
---@field item ItemStack
---@field entity Entity
---@field uuid string
---@field vars table

---@class SkullProcessHat
---@field ON_ENTER fun(skull: SkullInstanceHat, model: ModelPart)?
---@field ON_PROCESS fun(skull: SkullInstanceHat, model: ModelPart, delta: number)?
---@field ON_EXIT fun(skull: SkullInstanceHat, model: ModelPart)?

function SkullIdentity:newHatInstance()
	local instance = {
		identity = self,
		lastSeen = time,
		model = modelUtils.deepCopy(self.modelHat):setVisible(true):moveTo(models),
	}
	setmetatable(instance,SkullInstance)
	return instance
end

--[────────-< HUD Instance >-────────]--
---@class SkullInstanceHud : SkullInstance
---@field item ItemStack

---@class SkullProcessHud
---@field ON_ENTER fun(skull: SkullInstanceHud, model: ModelPart)?
---@field ON_PROCESS fun(skull: SkullInstanceHud, model: ModelPart, delta: number)?
---@field ON_EXIT fun(skull: SkullInstanceHud, model: ModelPart)?

function SkullIdentity:newHudInstance()
	local instance = {
		identity = self,
		lastSeen = time,
		model = modelUtils.deepCopy(self.modelHud):setVisible(true):moveTo(models),
	}
	setmetatable(instance,SkullInstance)
	return instance
end


--[────────────────────────────────────────-< PROCESSING >-────────────────────────────────────────]--

local blockInstances = {}
local hatInstances = {}
local hudInstances = {}
local entityInstances = {}

local playerVars = {}

events.WORLD_RENDER:register(function ()
	SKULL_PROCESS:setVisible(true)
end)

local lastInstance ---@type SkullInstance

events.SKULL_RENDER:register(function (delta, block, item, entity, ctx)
	
	if startupStall then return end
	if lastInstance then
		lastInstance.model:setVisible(false)
	end
	
	local instance
	
	if ctx == "BLOCK" then --[────────────────────-< BLOCK >-────────────────────]--
		
		local pos = block:getPos()
		local id = pos.x.. "," ..pos.y .. "," .. pos.z
		
		instance = blockInstances[id] ---@cast instance SkullInstanceBlock
		
		
		if not instance then -- new instance
			local isWall = block.id:find("wall_head$") and true or false
			local rot = isWall and (({north=180,south=0,east=90,west=270})[block.properties.facing]) or ((tonumber(block.properties.rotation) * -22.5 + 180) % 360)
			local matrix = matrices.mat4():rotateY(rot):translate(pos)
			local dir = matrix:applyDir(0,0,1)
			
			local support = world.getBlockState(pos - (isWall and dir or UP))
			local identity = skullSupportIdentities[support.id] or skullIdentities.default
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
			
			instance.identity.processBlock.ON_ENTER(instance,instance.model)
		else
			instance.lastSeen = time
		end
	elseif ctx == "HEAD" then --[────────────────────────-< HAT / HEAD >-────────────────────────]--
		local uuid = entity:getUUID()
		local name = item:getName():lower()
		local identify = uuid..","..name
		instance = hatInstances[identify] ---@cast instance SkullInstanceEntity
		
		if not instance then -- new instance
			instance = skullIdentities[name] or skullIdentities.default
			instance = instance:newHatInstance()
			instance.entity = entity
			instance.vars = playerVars[uuid] or {}
			instance.item = item
			instance.uuid = uuid
			instance.identity.processHat.ON_ENTER(instance,instance.model)
			hatInstances[identify] = instance
			lastInstance = instance
		else
			instance.lastSeen = time
		end
	elseif ctx == "ITEM_ENTITY" or ctx:find("HAND$") then
		local uuid = entity:getType() ~= "minecraft:player" and entity:getUUID() or item:getName():lower()
		instance = entityInstances[uuid] ---@cast instance SkullInstanceEntity
		
		if not instance then -- new instance
			local parameters = {}
			for param in item:getName():lower():gmatch("([^,]+)") do
				parameters[#parameters+1] = tonumber(param) or param
			end
			local name = parameters[1]
			table.remove(parameters,1)
			instance = skullIdentities[name] or skullIdentities.default
			
			instance = instance:newEntityInstance()
			instance.entity = entity
			instance.vars = playerVars[uuid] or {}
			instance.item = item
			instance.uuid = uuid
			instance.identity.processEntity.ON_ENTER(instance,instance.model)
			entityInstances[uuid] = instance
			lastInstance = instance
		else
			instance.lastSeen = time
		end
	else --[────────────────────────-< HUD >-────────────────────────]--
	local name = item:getName():lower():match("^([^,]+)")
		name = skullIdentities[name] and name or "default"
		instance = hudInstances[name] ---@cast instance SkullInstanceEntity
		if not instance then -- new instance
			instance = skullIdentities[name]
			instance = instance:newHudInstance()
			instance.item = item
			instance.identity.processHud.ON_ENTER(instance,instance.model)
			hudInstances[name] = instance
			lastInstance = instance
		else
			instance.lastSeen = time
		end
	end
	if instance then
		instance.model:setVisible(true)
	end
	lastInstance = instance
end)


SKULL_PROCESS.postRender = function (delta, context, part)
	playerVars = world.avatarVars()
	SKULL_PROCESS:setVisible(false)
	time = client:getSystemTime()
	delta = client:getFrameTime()
	
	if next(blockInstances) then
		---@param instance SkullInstanceBlock
		for key, instance in pairs(blockInstances) do
			if time - instance.lastSeen > SKULL_DECAY_TIME or (not world.getBlockState(instance.pos).id:find("head$")) then
				instance.queueFree = true
				instance.identity.processBlock.ON_EXIT(instance,instance.model)
				instance.model:remove()
				blockInstances[key] = nil
			end
			instance.identity.processBlock.ON_PROCESS(instance,instance.model,delta)
		end
	end
	
	if next(hatInstances) then
		---@param instance SkullInstanceHat
		for key, instance in pairs(hatInstances) do
			if time - instance.lastSeen > SKULL_DECAY_TIME then
				instance.queueFree = true
				instance.identity.processHat.ON_EXIT(instance,instance.model)
				instance.model:remove()
				hatInstances[key] = nil
			end
			instance.matrix = instance.model:partToWorldMatrix()
			instance.vars = playerVars[instance.uuid] or {}
			instance.identity.processHat.ON_PROCESS(instance,instance.model,delta)
		end
	end
	
	if next(entityInstances) then
		---@param instance SkullInstanceEntity
		for key, instance in pairs(entityInstances) do
			if time - instance.lastSeen > 100 then
				instance.queueFree = true
				instance.identity.processEntity.ON_EXIT(instance,instance.model)
				instance.model:remove()
				entityInstances[key] = nil
			end
			instance.matrix = instance.model:partToWorldMatrix()
			instance.vars = playerVars[instance.uuid] or {}
			instance.identity.processEntity.ON_PROCESS(instance,instance.model,delta)
		end
	end
	
	if next(hudInstances) then
		---@param instance SkullInstanceHud
		for key, instance in pairs(hudInstances) do
			if time - instance.lastSeen > SKULL_DECAY_TIME then
				instance.queueFree = true
				instance.identity.processHud.ON_EXIT(instance,instance.model)
				instance.model:remove()
				hudInstances[key] = nil
			end
			instance.identity.processHud.ON_PROCESS(instance,instance.model,delta)
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


---@param pos Vector3
---@return SkullInstanceBlock?
function SkullAPI.getSkull(pos)
	local block = blockInstances[SkullAPI.toID(pos)]
	if block and not block.queueFree then
		return block
	end
end


function SkullAPI.getSkullIdentities()
	return skullIdentities
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