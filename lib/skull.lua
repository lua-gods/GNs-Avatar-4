--[[______   __
  / ____/ | / /  by: GNanimates / https://gnon.top / Discord: @gn68s
 / / __/  |/ / name: SKULL SYSTEM SERVICE
/ /_/ / /|  /  desc: handles all the skull instances
\____/_/ |_/ source: https://github.com/lua-gods/GNs-Figura-Avatar-4/blob/main/lib/skull.lua ]]

local modelUtils = require("lib.modelUtils")


local ZERO = vec(0,0,0)
local UP = vec(0,1,0)
local SKULL_DECAY_TIME = 1000

-- this is used to avoid using world render when I am offline
local SKULL_PROCESS = models:newPart("SkullRenderer","SKULL")
SKULL_PROCESS:newBlock("forceRenderer"):block("minecraft:emerald_block"):scale(0,0,0)
models:newPart("SkullHider","SKULL"):newBlock("forceHide"):block("minecraft:redstone_block"):scale(0,0,0)


local skullIdentities = {}        ---@type table<string,SkullIdentity>
local skullSupportIdentities = {} ---@type table<string,SkullIdentity>

local time = client:getSystemTime()
local STARTUP_STALL = 20

---@class SkullAPI
local SkullAPI = {}



local id = 0
---@param texture Texture
---@param iconX number
---@param iconY number
---@return ModelPart
function SkullAPI.makeIcon(texture,iconX,iconY)
	id = id + 1
	iconX = iconX or 0
	iconY = iconY or 0
	
	local model = models:newPart("Icon"..id)
	model:setParentType("SKULL")
	:rot(38,-45,0)
	:pos(5.58,13.65,5.58)
	model:newSprite("Icon")
	:texture(texture,16,16)
	:setRenderType("CUTOUT_EMISSIVE_SOLID")
	:setDimensions(64,64)
	:setUVPixels(iconX*16,iconY*16)
	return model
end


--[────────────────────────-< Instance Class Declarations >-────────────────────────]--


---@class SkullInstance
---@field params {} # Note: does not exist for blocks
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
---@field modelBlock ModelPart|{[1]:ModelPart}
---@field modelHat ModelPart|{[1]:ModelPart}
---@field modelHud ModelPart|{[1]:ModelPart}
---@field modelItem ModelPart|{[1]:ModelPart}
---
---@field noModelBlockDeepCopy boolean
---@field noModelHatDeepCopy boolean
---@field noModelHudDeepCopy boolean
---@field noModelItemDeepCopy boolean
---
---@field processBlock SkullProcessBlock
---@field processHat SkullProcessHat
---@field processHud SkullProcessHud
---@field processEntity SkullProcessEntity
---@field [any] any
local SkullIdentity = {}
SkullIdentity.__index = SkullIdentity


local placeholderID = 0
local function modelIdentityPeprocess(model)
	if model then
		if model[1] then
			return modelIdentityPeprocess(model[1])
		end
		return model:setParentType("SKULL"):setVisible(false)
	else
		return models:newPart("Placeholder"..placeholderID,"SKULL"):setVisible(false)
	end
end


local identityCache = {}

---@param item ItemStack
---@return {name:string,params:string[],hash:string}[]
local function parseItem(item)
	local sourceString = item:getName()
	if identityCache[sourceString] then
		return identityCache[sourceString]
	end

	local identities = {}
	local json = sourceString:gsub("\n","")
	
	--[[ Turned off because this is already done by Minecraft's json parser, kept just in case
	-- convert text to double quoted strings
	json = json:gsub("[^,:%[%]%(%)%{%}]+",function (str)
		return (tonumber(str) and str or '"'..str..'"')
	end)
	--]]
	
	for i = 1, 2, 1 do -- needs to be ran twice because of overlapping match sequence
		-- convert lone string entry to a key with an empty array
		json = (","..json..","):gsub("(,[^:,]+),",function (str)
			return str..":[],"
		end):sub(2,-2)
	end
	json = "{"..json.."}"
	local ok, result = pcall(parseJson,json)
	
	if not ok then -- insert fallback identity here
		return {
			{
				name="default",
				params={},
				hash="default"
			}
		}
	end
	
	for name, params in pairs(result) do
		local name = name
		table.insert(identities, {
			name = name,
			params = params,
			hash = name
		})
	end
	
	
	--for identityString in (item:getName():gsub('\\.', escapeCharMap)..","):gmatch("([^,]+),") do
	--	local params = {}
	--	for param in (identityString..';'):gmatch('([^;]*);') do
	--	   table.insert(params, (param:gsub('\\.', unescapeCharMap)))
	--	end
	--	local name = table.remove(params, 1)
	--	table.insert(identities, {
	--		name = name,
	--		params = params or {},
	--		hash = identityString,
	--	})
	--end
	
	identityCache[sourceString] = identities
	return identities
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


---@param item ItemStack
local function getItemParams(item)
	
end


---@param cfg SkullIdentity|{}
function SkullAPI.registerIdentity(cfg)
	local root = models:newPart(cfg.name.."root")

	local identity = {
		name = cfg.name,
		support = cfg.support,

		modelBlock = modelIdentityPeprocess(cfg.modelBlock),
		modelHat   = modelIdentityPeprocess(cfg.modelHat),
		modelHud   = modelIdentityPeprocess(cfg.modelHud),
		modelItem  = modelIdentityPeprocess(cfg.modelItem),

		noModelBlockDeepCopy = (cfg.modelBlock and cfg.modelBlock[1]) and true or false,
		noModelHatDeepCopy =   (cfg.modelHat and cfg.modelHat[1]) and true or false,
		noModelHudDeepCopy =   (cfg.modelHud and cfg.modelHud[1]) and true or false,
		noModelItemDeepCopy =  (cfg.modelItem and cfg.modelItem[1]) and true or false,

		processBlock =   applyPlaceholders(cfg.processBlock),
		processHat   =   applyPlaceholders(cfg.processHat),
		processHud   =   applyPlaceholders(cfg.processHud),
		processEntity  = applyPlaceholders(cfg.processEntity),
	}
	--root:addChild(identity.modelBlock)
	--root:addChild(identity.modelHat)
	--root:addChild(identity.modelHud)
	--root:addChild(identity.modelItem)

	setmetatable(identity,SkullIdentity)
	skullIdentities[cfg.name] = identity
	if identity.support then
		skullSupportIdentities[identity.support] = identity
	end
	return identity
end


--[────────-< Entity Instance >-────────]--
---@class SkullInstanceEntity : SkullInstance
---@field entity Entity
---@field isFirstPerson boolean
---@field params {}
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
		model = (self.noModelItemDeepCopy and modelUtils.shallowCopy(self.modelItem) or modelUtils.deepCopy(self.modelItem)):setVisible(true):moveTo(models),
	}
	setmetatable(instance,SkullInstance)
	return instance
end

--[────────-< Block Instance >-────────]--
---@class SkullInstanceBlock : SkullInstance
---@field blockModel ModelPart
---@field params string
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
		model = (self.noModelBlockDeepCopy and modelUtils.shallowCopy(self.modelBlock) or modelUtils.deepCopy(self.modelBlock)):setVisible(true):moveTo(models),
	}
	setmetatable(instance,SkullInstance)
	return instance
end

--[────────-< Hat Instance >-────────]--
---@class SkullInstanceHat : SkullInstance
---@field item ItemStack
---@field entity Entity
---@field params {}
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
		model = (self.noModelHatDeepCopy and modelUtils.shallowCopy(self.modelHat) or modelUtils.deepCopy(self.modelHat)):setVisible(true):moveTo(models),
	}
	setmetatable(instance,SkullInstance)
	return instance
end

--[────────-< HUD Instance >-────────]--
---@class SkullInstanceHud : SkullInstance
---@field item ItemStack
---@field params {}

---@class SkullProcessHud
---@field ON_ENTER fun(skull: SkullInstanceHud, model: ModelPart)?
---@field ON_PROCESS fun(skull: SkullInstanceHud, model: ModelPart, delta: number)?
---@field ON_EXIT fun(skull: SkullInstanceHud, model: ModelPart)?

function SkullIdentity:newHudInstance()
	local instance = {
		identity = self,
		lastSeen = time,
		model = (self.noModelHudDeepCopy and modelUtils.shallowCopy(self.modelHud) or modelUtils.deepCopy(self.modelHud)):setVisible(true):moveTo(models),
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

local lastDrawInstances = {}

events.SKULL_RENDER:register(function (delta, block, item, entity, ctx)
	if STARTUP_STALL then return end

	local instance

	local drawInstances = {}


	if ctx == "BLOCK" then --[────────────────────-< 🔴 BLOCK >-────────────────────]--

		local pos = block:getPos()
		local id = pos.x.. "," ..pos.y .. "," .. pos.z

		instance = blockInstances[id] ---@cast instance SkullInstanceBlock


		if not blockInstances[id] then -- new instance
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
			
			local NBT = block:getEntityData()
			
			local str = ""
			
			if NBT 
			and NBT.SkullOwner 
			and NBT.SkullOwner.Properties 
			and NBT.SkullOwner.Properties.textures then
				for index, entry in ipairs(NBT.SkullOwner.Properties.textures) do
					if entry.Value then
						str = str..entry.Value
					end
				end
			end
			local buffer = data:createBuffer(#str)
			
			buffer:writeBase64(str)
			buffer:setPosition(0)
			instance.params = buffer
			
			--instance.params = 

			local blockModel = instance.model
			:newPart("blockModelArm")
			:rot(0,-rot)
			:newPart("blockModel")
			:pos(vec(-8,0,-8) + (isWall and matrix:applyDir(0,-4,-4) or ZERO))
			instance.blockModel = blockModel

			blockInstances[id] = instance

			instance.hash = id
			instance.identity.processBlock.ON_ENTER(instance,instance.model)
		else
			instance.lastSeen = time
		end
		drawInstances[#drawInstances+1] = instance
	elseif ctx == "HEAD" then --[────────────────────────-< 🟡 HAT / HEAD >-────────────────────────]--

		local uuid = entity:getUUID()
		local rawName = item:getName()

		for i, identityString in ipairs(parseItem(item)) do
			local identify = uuid..","..identityString.hash
			instance = hatInstances[identify] ---@cast instance SkullInstanceEntity

			if not instance then -- new instance
				instance = skullIdentities[identityString.name] or skullIdentities.default
				instance = instance:newHatInstance()
				instance.entity = entity
				instance.vars = playerVars[uuid] or {}
				instance.item = item
				instance.uuid = uuid
				instance.params = identityString.params
				instance.hash = identityString.hash
				instance.identity.processHat.ON_ENTER(instance,instance.model)
				hatInstances[identify] = instance
			else
				instance.lastSeen = time
			end
			drawInstances[#drawInstances+1] = instance
		end
		--[────────────────────────-< 🟠 ENTITY >-────────────────────────]--
	elseif ctx == "ITEM_ENTITY" or ctx:find("HAND$") then
		local uuid = entity:getUUID()

		for i, identityString in ipairs(parseItem(item)) do
			local identify = uuid..","..identityString.hash
			instance = entityInstances[identify] ---@cast instance SkullInstanceEntity
			if not instance then -- new instance
				instance = (skullIdentities[identityString.name] or skullIdentities.default):newEntityInstance()
				instance.entity = entity
				instance.vars = playerVars[uuid] or {}
				instance.item = item
				instance.uuid = uuid
				instance.params = identityString.params
				instance.hash = identify
				instance.identity.processEntity.ON_ENTER(instance,instance.model)
				entityInstances[identify] = instance
			else
				instance.lastSeen = time
			end
			drawInstances[#drawInstances+1] = instance
		end
	else --[────────────────────────-< 🟢 HUD >-────────────────────────]--
		for i, identityString in ipairs(parseItem(item)) do
			instance = hudInstances[identityString.hash] ---@cast instance SkullInstanceEntity
			if not instance then -- new instance
				instance = skullIdentities[identityString.name] or skullIdentities.default
				instance = instance:newHudInstance()
				instance.item = item
				instance.params = identityString.params
				instance.hash = identityString.hash
				instance.identity.processHud.ON_ENTER(instance,instance.model)
				hudInstances[identityString.hash] = instance
			else
				instance.lastSeen = time
			end
			drawInstances[#drawInstances+1] = instance
		end
	end

	for _, value in ipairs(lastDrawInstances) do
		if value.model then
			value.model:setVisible(false)
		else
			lastDrawInstances[_] = nil
		end
	end
	for _, value in ipairs(drawInstances) do
		if value.model then
			value.model:setVisible(true)
		else
			drawInstances[_] = nil
		end
	end

	lastDrawInstances = drawInstances
	lastInstance = instance
end)


SKULL_PROCESS.preRender = function (delta, context, part)
	--if client:getViewer():getUUID() == "dc912a38-2f0f-40f8-9d6d-57c400185362" then
	--	print("hello")
	--end
	playerVars = world.avatarVars()
	SKULL_PROCESS:setVisible(false)
	time = client:getSystemTime()
	delta = client:getFrameTime()

	if next(blockInstances) then
		---@param instance SkullInstanceBlock
		for key, instance in pairs(blockInstances) do
			instance.identity.processBlock.ON_PROCESS(instance,instance.model,delta)
			if (not world.getBlockState(instance.pos).id:find("head$")) then
				instance.queueFree = true
				instance.identity.processBlock.ON_EXIT(instance,instance.model)
				instance.model:remove()
				instance.model = nil
				blockInstances[key] = nil
			end
		end
	end

	if next(hatInstances) then
		---@param instance SkullInstanceHat
		for key, instance in pairs(hatInstances) do
			instance.matrix = instance.model and instance.model:partToWorldMatrix() or matrices.mat4()
			instance.vars = playerVars[instance.uuid] or {}
			instance.identity.processHat.ON_PROCESS(instance,instance.model,delta)
			if time - instance.lastSeen > SKULL_DECAY_TIME then
				instance.queueFree = true
				instance.identity.processHat.ON_EXIT(instance,instance.model)
				instance.model:remove()
				instance.model = nil
				hatInstances[key] = nil
			end
		end
	end
	if next(entityInstances) then
		---@param instance SkullInstanceEntity
		for key, instance in pairs(entityInstances) do
			if instance.model then
				instance.matrix = instance.model:partToWorldMatrix()
				instance.vars = playerVars[instance.uuid] or {}
				instance.identity.processEntity.ON_PROCESS(instance,instance.model,delta)
				if time - instance.lastSeen > 100 then
					instance.queueFree = true
					instance.identity.processEntity.ON_EXIT(instance,instance.model)
					instance.model:remove()
					instance.model = nil
					entityInstances[key] = nil
					--print("MANAGEMENT SKULL FREE", instance.identity)
				end
			else
				entityInstances[key] = nil
			end
		end
	end

	if next(hudInstances) then
		---@param instance SkullInstanceHud
		for key, instance in pairs(hudInstances) do
			instance.identity.processHud.ON_PROCESS(instance,instance.model,delta)
			if time - instance.lastSeen > SKULL_DECAY_TIME then
				instance.queueFree = true
				instance.identity.processHud.ON_EXIT(instance,instance.model)
				instance.model:remove()
				instance.model = nil
				hudInstances[key] = nil
			end
		end
	end
end


SKULL_PROCESS.midRender	 = function (delta, context, part)
	STARTUP_STALL = STARTUP_STALL - 1
	if STARTUP_STALL < 0 then
		STARTUP_STALL = nil
		SKULL_PROCESS.midRender = nil
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