---@diagnostic disable: assign-type-mismatch
--[[______   __
  / ____/ | / /  by: GNanimates / https://gnon.top / Discord: @gn68s
 / / __/  |/ / name: SKULL SYSTEM SERVICE
/ /_/ / /|  /  desc: handles all the skull instances
\____/_/ |_/ source: https://github.com/lua-gods/GNs-Figura-Avatar-4/blob/main/lib/skull.lua ]]

local modelUtils = require("lib.modelUtils")


local ZERO = vec(0,0,0)
local UP = vec(0,1,0)
local SKULL_DECAY_TIME = 100

local IS_MAX = avatar:getMaxWorldRenderCount() > 200000 -- 200k
local COMPRESS = true
local CHUNK_SIZE = 2^15

local zlib = require("lib.zlib")

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

---@param texture Texture
---@param iconX number
---@param iconY number
---@return ModelPart
function SkullAPI.makeExtrudedIcon(texture,iconX,iconY)
	id = id + 1
	iconX = iconX or 0
	iconY = iconY or 0
	
	local model = models:newPart("Icon"..id)
	:setPos(3,17,9)
	:rot(38,-45,0)
	model:setParentType("SKULL")
	for i = 1, 50, 1 do
		local task = model:newSprite("Icon"..i)
		:setPos(0,0,i/50)
		:texture(texture,16,16)
		:setRenderType("CUTOUT_EMISSIVE_SOLID")
		:setDimensions(64,64)
		:setUVPixels(iconX*16,iconY*16)
		if i > 0 and i < 10 then
			task:setColor(0.9,0.9,0.9)
		end
	end
	return model
end


--[────────────────────────-< Instance Class Declarations >-────────────────────────]--


---@class SkullInstance
---@field params {}
---@field identity SkullIdentity
---@field queueFree boolean
---@field model ModelPart
---@field lastSeen integer
---@field matrix Matrix4
---@field isReady boolean
---@field [string] string
local SkullInstance = {}
SkullInstance.__index = function (t,i)
	return rawget(t,i) or rawget(t,"identity")[i] or SkullInstance[i]
end


--[────────────────────────────────────────-< Skull Identity >-────────────────────────────────────────]--


---@class SkullIdentity
---@field name string
---@field id string
---@field support Minecraft.blockID
---
---@field modelBlock ModelPart|{[1]:ModelPart}
---@field modelHat ModelPart|{[1]:ModelPart}
---@field modelHud ModelPart|{[1]:ModelPart}
---@field modelEntity ModelPart|{[1]:ModelPart}
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
---@field [string] string
local SkullIdentity = {}
SkullIdentity.__index = function (t,i)
	return rawget(t,i) or SkullIdentity[i]
end

local modelUtils = require("lib.modelUtils")

local function modelIdentityPeprocess(model)
	if type(model) == "table" then
		model = model[1]
	end
	if model then
		model:setVisible(false)
		local baseModel = models:newPart("base"):remove()
		local copy = modelUtils.deepCopy(model)
		copy:setParentType("SKULL")
		return copy
	end
end
local texDataCache = {}


---Checks if the given array of identities exist.
---@param identities table<string,table>
---@return boolean
local function areIdentitiesValid(identities)
	for key, value in pairs(identities) do
		if not skullIdentities[key] then
			return false
		end
	end
	return true
end


---@param nbt table
local function parseTexture(identities,nbt,hash)
	local texData
	if texDataCache[hash] then
		for _, value in pairs(texDataCache[hash]) do
			table.insert(identities,value)
		end
		return
	end
	
	
	local texStr = ""
	
	local c = 0
	if nbt 
	and nbt.SkullOwner
	and nbt.SkullOwner.Properties
	and nbt.SkullOwner.Properties.textures then
		for index, entry in ipairs(nbt.SkullOwner.Properties.textures) do
			if entry.Value then
				c = c + 1
				if c > 1 then
					texStr = texStr..entry.Value
				end
			end
		end
	end
	if texDataCache[texStr] then
		texData = texDataCache[texStr]
	else
		if texStr and #texStr > 0 then
			local buffer = data:createBuffer(#texStr)
			
			buffer:writeBase64(texStr)
			buffer:setPosition(0)
			local str = buffer:readByteArray(buffer:available())
			if COMPRESS then
				str = zlib.Deflate.Decompress(str)
			end
			local ok, result = pcall(parseJson,str) --parseJson(str)
			if not ok then return
			else
				texData = result
			end
			texDataCache[str] = texData
		else
			texData = {}
		end
	end
	if type(texData) == "table" then
		local added = {}
		for id, params in pairs(texData) do
			local entry = {
				id = id,
				params = type(params) == "table" and params or {},
				hash = id
			}
			table.insert(identities, entry)
			table.insert(added, entry)
		end
		texDataCache[hash] = added
	end
end

local identityCache = {}
local function processWIthPreservedStrings(input, middleApply)
	local placeholders = {}
	local parts = {}
	local n = #input
	local i = 1
	local counter = 0

	while i <= n do
		local c = input:sub(i, i)
		if c == '"' then
			-- start of quoted string
			i = i + 1
			local buf = {}
			while i <= n do
				local ch = input:sub(i, i)
				if ch == "\\" then
					-- keep the backslash and the escaped character together
					local nextc = input:sub(i + 1, i + 1)
					table.insert(buf, "\\")
					if i + 1 <= n then
						table.insert(buf, nextc)
						i = i + 2
					else
						-- trailing backslash at end of input
						i = i + 1
					end
				elseif ch == '"' then
					-- closing quote (unescaped)
					i = i + 1
					break
				else
					table.insert(buf, ch)
					i = i + 1
				end
			end

			counter = counter + 1
			local key = "___STR_REPLACEMENT_" .. counter .. "___"
			placeholders[counter] = table.concat(buf)    -- content without outer quotes, escapes preserved
			table.insert(parts, key)
		else
			table.insert(parts, c)
			i = i + 1
		end
	end

	local without_strings = table.concat(parts)

	-- Apply
	local processed = middleApply(without_strings)

	-- Restore placeholders
	local restored = processed:gsub("___STR_REPLACEMENT_(%d+)___", function(idx)
		local k = tonumber(idx)
		return '"' .. (placeholders[k] or "") .. '"'
	end)

	return restored
end

local function cleanEntries(tbl)
	for key, value in pairs(tbl) do
		local t = type(value)
		if t == "table" then
			cleanEntries(value)
		elseif t == "string" then
			if t:find("^\".*\"$") then
				t = t:sub(-2,2)
			end
		end
	end
end

---@param name string
local function parseName(identities,name)
	local json = name:gsub("\n","")
	--[[ Turned off because this is already done by Minecraft's json parser, kept just in case
	-- convert text to double quoted strings
	json = json:gsub("[^,:%[%]%(%)%{%}]+",function (str)
		return (tonumber(str) and str or '"'..str..'"')
	end)
	--]]
	
	for i = 1, 1, 1 do -- needs to be ran twice because of overlapping match sequence
		json = processWIthPreservedStrings(json,function (s)
		return (","..s..","):gsub("(,[^:%[%]\"_,]+),",function (str)
			return str..":[],"
		end):sub(2,-2)
	end)
	end
	
	json = "{"..json.."}"
	local ok,result = pcall(parseJson,json)
	if ok then
		for id, params in pairs(result) do
			--cleanEntries(params)
			table.insert(identities, {
				id = id,
				params = type(params) == "table" and params or {},
				hash = id
			})
		end
	end
end


---@param item ItemStack
---@return {id:string,params:string[],hash:string}[]
local function readItem(item)
	local sourceString = item:toStackString()
	if identityCache[sourceString] then
		return identityCache[sourceString]
	end
	
	local identities = {}
	
	parseTexture(identities,item.tag,sourceString)
	parseName(identities,item:getName())
	
	if #identities == 0 then
		identities = {
			{
				id="default",
				params={},
				hash="default"
			}
		}
	end
	
	identityCache[sourceString] = identities
	return identities
end


local u1,u2,u3,u4 = client.uuidToIntArray("e4b91448-3b58-4c1f-8339-d40f75ecacc4")
---@param identityArray table
function SkullAPI.makeSkull(identityArray,customName)
	
	local str = toJson(identityArray)
	if COMPRESS then
		str = zlib.Deflate.Compress(str,{level=1})
	end
	local buffer = data:createBuffer(#str)
	buffer:writeByteArray(str)
	buffer:setPosition(0)
	
	local data = buffer:readBase64(buffer:available())
	local textures = {
		-- first texture is the tophat texture for the head to fallback into
		{Signature="jO6gPIP5+XJhM7XpLCaDQgBkLfdczmWROb90w1h2PlhxMOf2Xc9LpC1LnidJkwusKnVY33wCT7tNwJrVLocDRnafFQ/NSQwZJs4cbDGp7o9sZ4gV8eoMY1bX2xiF9o+KwwCOXbL5ufxYWHSLxzj88goiYD0yrYu7W8rplWviPrpkQThWJEo9f0KmMDVJR3ubZ2YQhZIqvRgNsjubX/rejLXxaP5w2EwPWoB+kmH7sbXUZQCPU1ZCEkCfRSg5l0aIz4Ie2fQr3Er8/gHHoiILV/vpv0Le2de2Cn4hcF/XqTQJIhYELkMhL8Jlt5RR463Av7yD4+sSkEJDk2ByFhNOL2I9aNW+AJD4zRbtbT85+kTVd5fWzaOOnzz7Dq32T0k5zLEGnELz16gc/OYqjvPHmQHKva5lLad37r4HLiGxrUR9PfTLownsKtl9S0toMXkyMzH7psqqhtwNHXGrKdhqfEBwJ7KsBC1Bsds8dK70KC23mQxziTgD5rXKjcaxFm+B2yLicNzm5mwJZ2wYCfE07kEf0D/KeSdxT4i9zeNz6/PWO8vA9otIB4maywnhuWHS8Xco7V1TCEQEa/xuwT2HFImLXISiLeBfTaByWk9qeT72oFjcIWmxNnU9ZtYdwW2UpDLMEv0U9pkrbFW03rJQdvXIzUO2Zp8S8OdjooxsAAo=",Value="ewogICJ0aW1lc3RhbXAiIDogMTc1ODk3NDEzMDAwNSwKICAicHJvZmlsZUlkIiA6ICJlNGI5MTQ0ODNiNTg0YzFmODMzOWQ0MGY3NWVjYWNjNCIsCiAgInByb2ZpbGVOYW1lIiA6ICJHTlVJIiwKICAic2lnbmF0dXJlUmVxdWlyZWQiIDogdHJ1ZSwKICAidGV4dHVyZXMiIDogewogICAgIlNLSU4iIDogewogICAgICAidXJsIiA6ICJodHRwOi8vdGV4dHVyZXMubWluZWNyYWZ0Lm5ldC90ZXh0dXJlLzhmMzIzYmM5ODc5NjBhMTY0MWJmNzBiMzQyMTQ2NjRkZTlhMjNjYzRiMTQ0YzMzYWVmMWY5ZmM2MjA4NjUwNTciCiAgICB9CiAgfQp9"}
	}
	-- split the string to 32kb chunks
	for i=1, #data, CHUNK_SIZE+1 do
		table.insert(textures, {Value = string.sub(data, i, i+CHUNK_SIZE)})
	end
	
	local name = toJson({text=customName or "GN's Head",italic=false,color="yellow"})
	
	---@type Minecraft.RawJSONText.Component[]
	local lore = {
		{text="-- Modes -- ",italic=false,color="gray"}
	}
	for name, data in pairs(identityArray) do
		lore[#lore+1] = {text=name,italic=false,color="gray"}
	end
	
	table.insert(lore, {text="---------- ",italic=false,color="gray"})
	
	for index, value in ipairs(lore) do
		lore[index] = toJson(value)
	end
	
	local item = ([=[minecraft:player_head{display:{Name:%s,Lore:%s},SkullOwner:{Id:[I;%s,%s,%s,%s],Properties:{textures:%s}}}]=]):format(toJson(name),toJson(lore),u1,u2,u3,u4,toJson(textures))
	return item
end

local function give(item)
	if player:isLoaded() then
		local id = player:getNbt().SelectedItemSlot
		sounds:playSound("minecraft:entity.item.pickup",client:getCameraPos():add(client:getCameraDir()),1,1)
		host:setSlot("hotbar."..id,item)
	end
end

writeSkull = function (identityArray,customName)
	local ok, result = pcall(SkullAPI.makeSkull,identityArray,customName)
	if ok then
		give(result)
	else
		warn(ok)
	end
end

avatar:store("makeSkull",function (identityArray,customName)
	local ok, result = pcall(SkullAPI.makeSkull,identityArray,customName)
	if ok then
		return result
	else
		warn(ok)
	end
end)


---Returns the skull identity to use with the given name  
---This exist to allow fallback manipulation
---@param id string
---@return SkullIdentity
function SkullAPI.getIdentity(id)
	return skullIdentities[id] or skullIdentities.default
end


local PROCESS_PLACEHOLDER = {
	ON_INIT = function ()end,
	ON_READY = function ()end,
	ON_PROCESS = function ()end,
	ON_EXIT = function ()end
}

local function applyPlaceholders(tbl)
	tbl = tbl or {}
	tbl.ON_INIT = tbl.ON_INIT or PROCESS_PLACEHOLDER.ON_INIT
	tbl.ON_READY = tbl.ON_READY or PROCESS_PLACEHOLDER.ON_READY
	tbl.ON_PROCESS = tbl.ON_PROCESS or PROCESS_PLACEHOLDER.ON_PROCESS
	tbl.ON_EXIT = tbl.ON_EXIT or PROCESS_PLACEHOLDER.ON_EXIT
	return tbl
end


---@param cfg SkullIdentity|{}
function SkullAPI.registerIdentity(cfg)
	local root = models:newPart(cfg.name.."root")

	local identity = cfg

		identity.modelBlock = modelIdentityPeprocess(cfg.modelBlock)
		identity.modelHat   = modelIdentityPeprocess(cfg.modelHat)
		identity.modelHud   = modelIdentityPeprocess(cfg.modelHud)
		identity.modelEntity  = modelIdentityPeprocess(cfg.modelEntity)

		identity.processBlock =   applyPlaceholders(cfg.processBlock)
		identity.processHat   =   applyPlaceholders(cfg.processHat)
		identity.processHud   =   applyPlaceholders(cfg.processHud)
		identity.processEntity  = applyPlaceholders(cfg.processEntity)
	
	--root:addChild(identity.modelBlock)
	--root:addChild(identity.modelHat)
	--root:addChild(identity.modelHud)
	--root:addChild(identity.modelItem)

	setmetatable(identity,SkullIdentity)
	skullIdentities[cfg.id] = identity
	if identity.support then
		skullSupportIdentities[identity.support] = identity
	end
	return identity
end

local emptyPlcaeholderID = 0
local function prepareInstance(identity,modelType)
	local model
	if modelType == 1 then
		model = identity.modelEntity
	elseif modelType == 2 then
		model = identity.modelBlock
	elseif modelType == 3 then
		model = identity.modelHat
	else
		model = identity.modelHud
	end
	if not model then
		model = model or models:newPart("emptyPlcaeholder"..emptyPlcaeholderID)
		emptyPlcaeholderID = emptyPlcaeholderID + 1 % 2^32
	end
	local instance = {
		lastSeen = time,
		identity = identity,
		model = modelUtils.deepCopy(model):setVisible(true):moveTo(models),
	}
	return instance
end

--[────────-< Entity Instance >-────────]--
---@class SkullInstanceEntity : SkullInstance
---@field entity Entity
---@field isFirstPerson boolean
---@field params {}
---@field isHand boolean

---@class SkullProcessEntity
---@field ON_INIT fun(skull: SkullInstanceEntity, model: ModelPart)?
---@field ON_READY fun(skull: SkullInstanceEntity, model: ModelPart)?
---@field ON_PROCESS fun(skull: SkullInstanceEntity, model: ModelPart, deltaFrame: number, deltaTick: number)?
---@field ON_EXIT fun(skull: SkullInstanceEntity, model: ModelPart)?

---@return SkullInstanceEntity
function SkullIdentity:newEntityInstance()
	local instance = prepareInstance(self, 1)
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
---@field ON_INIT fun(skull: SkullInstanceBlock, model: ModelPart)?
---@field ON_READY fun(skull: SkullInstanceBlock, model: ModelPart)?
---@field ON_PROCESS fun(skull: SkullInstanceBlock, model: ModelPart, deltaFrame:number, deltaTick: number)?
---@field ON_EXIT fun(skull: SkullInstanceBlock, model: ModelPart)?

--- Creates an instance with the only data being nessesary to a block.
---@return SkullInstanceBlock
function SkullIdentity:newBlockInstance()
	local instance = prepareInstance(self, 2)
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
---@field ON_INIT fun(skull: SkullInstanceHat, model: ModelPart)?
---@field ON_READY fun(skull: SkullInstanceHat, model: ModelPart)?
---@field ON_PROCESS fun(skull: SkullInstanceHat, model: ModelPart, deltaFrame:number, deltaTick: number)?
---@field ON_EXIT fun(skull: SkullInstanceHat, model: ModelPart)?


function SkullIdentity:newHatInstance()
	local instance = prepareInstance(self, 3)
	setmetatable(instance,SkullInstance)
	return instance
end

--[────────-< HUD Instance >-────────]--
---@class SkullInstanceHud : SkullInstance
---@field item ItemStack
---@field params {}

---@class SkullProcessHud
---@field ON_INIT fun(skull: SkullInstanceHud, model: ModelPart)?
---@field ON_READY fun(skull: SkullInstanceHud, model: ModelPart)?
---@field ON_PROCESS fun(skull: SkullInstanceHud, model: ModelPart, deltaFrame:number, deltaTick: number)?
---@field ON_EXIT fun(skull: SkullInstanceHud, model: ModelPart)?

function SkullIdentity:newHudInstance()
	local instance = prepareInstance(self, 4)
	setmetatable(instance,SkullInstance)
	return instance
end


--[────────────────────────────────────────-< PROCESSING >-────────────────────────────────────────]--

local blockInstances = {}
local hatInstances = {}
local hudInstances = {}
local entityInstances = {}

local playerVars = {}


local lastDrawInstances = {}

events.SKULL_RENDER:register(function (delta, block, item, entity, ctx)
	if STARTUP_STALL then return end

	local instance

	local drawInstances = {}


	if ctx == "BLOCK" then --[────────────────────-< 🔴 BLOCK >-────────────────────]--

		local pos = block:getPos()
		local id = pos.x.. "," ..pos.y .. "," .. pos.z

		local isWall = block.id:find("wall_head$") and true or false
		local rot = isWall and (({north=180,south=0,east=90,west=270})[block.properties.facing]) or ((tonumber(block.properties.rotation) * -22.5 + 180) % 360)
		local matrix = matrices.mat4():rotateY(rot):translate(pos)
		local dir = matrix:applyDir(0,0,1)
		
		local identities = {}
		parseTexture(identities,block:getEntityData(),block:toStateString())
		
		if #identities == 0 then
			identities = {
				{
					id="default",
					hash="default"
				}
			}
		end
		
		for i, identity in ipairs(identities) do
			local fullHash = id..","..identity.hash
			instance = blockInstances[id] ---@cast instance SkullInstanceBlock
			if not instance then -- new instance
				instance = SkullAPI.getIdentity(identity.id):newBlockInstance() ---@type SkullInstanceBlock
				instance.block = block
				instance.pos = pos
				instance.isWall = isWall
				instance.rot = rot
				instance.dir = dir
				instance.matrix = matrix
				instance.params = identity.params
				instance.hash = fullHash
				instance.supportPos = pos - (isWall and dir or UP)
				instance.support = world.getBlockState(pos - (isWall and dir or UP))
				blockInstances[id] = instance
				local ok, err = pcall(instance.identity.processBlock.ON_INIT, instance,instance.model)
				if not ok then warn(err) end
			else
				instance.lastSeen = time
			end
			drawInstances[#drawInstances+1] = instance
		end
	elseif ctx == "HEAD" then --[────────────────────────-< 🟡 HAT / HEAD >-────────────────────────]--

		local uuid = entity:getUUID()

		for i, identity in ipairs(readItem(item)) do
			local identify = uuid..","..identity.hash
			instance = hatInstances[identify] ---@cast instance SkullInstanceEntity
			if not instance then -- new instance
				instance = SkullAPI.getIdentity(identity.id):newHatInstance()
				instance.matrix = instance.model:partToWorldMatrix()
				instance.entity = entity
				instance.vars = playerVars[uuid] or {}
				instance.item = item
				instance.uuid = uuid
				instance.params = identity.params
				instance.hash = identity.hash
				local ok, err = pcall(instance.identity.processHat.ON_INIT,instance,instance.model)
				if not ok then warn(err) end
				hatInstances[identify] = instance
			else
				instance.lastSeen = time
			end
			drawInstances[#drawInstances+1] = instance
		end
		--[────────────────────────-< 🟠 ENTITY >-────────────────────────]--
	elseif ctx == "ITEM_ENTITY" or ctx:find("HAND$") then
		local uuid = entity:getUUID()

		for i, identity in ipairs(readItem(item)) do
			local identify = uuid..","..identity.hash
			instance = entityInstances[identify] ---@cast instance SkullInstanceEntity
			if not instance then -- new instance
				instance = SkullAPI.getIdentity(identity.id):newEntityInstance()
				instance.entity = entity
				instance.vars = playerVars[uuid] or {}
				instance.item = item
				instance.uuid = uuid
				instance.params = identity.params
				instance.hash = identify
				local ok, err = pcall(instance.identity.processEntity.ON_INIT,instance,instance.model)
				if not ok then warn(err) end
				entityInstances[identify] = instance
			else
				instance.lastSeen = time
			end
			drawInstances[#drawInstances+1] = instance
		end
	else --[────────────────────────-< 🟢 HUD >-────────────────────────]--
		for i, identity in ipairs(readItem(item)) do
			instance = hudInstances[identity.hash] ---@cast instance SkullInstanceEntity
			if not instance then -- new instance
				instance = SkullAPI.getIdentity(identity.id):newHudInstance()
				instance.item = item
				instance.params = identity.params
				instance.hash = identity.hash
				local ok, err = pcall(instance.identity.processHud.ON_INIT,instance,instance.model)
				if not ok then warn(err) end
				hudInstances[identity.hash] = instance
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


local lastTime = client:getSystemTime()
local process = function (deltaTick)
	SKULL_PROCESS:setVisible(false)
	playerVars = world.avatarVars()
	time = client:getSystemTime()
	local deltaFrame = (time - lastTime)/1000
	lastTime = time
	deltaTick = client:getFrameTime()

	if next(blockInstances) then
		---@param ins SkullInstanceBlock
		for key, ins in pairs(blockInstances) do
			if ins.isReady then
				local ok, err = pcall(ins.identity.processBlock.ON_PROCESS, ins,ins.model,deltaFrame,deltaTick)
				if not ok then warn(err) end
			else
				ins.isReady = true
				local ok, err = pcall(ins.identity.processBlock.ON_READY, ins,ins.model,deltaFrame,deltaTick)
				if not ok then warn(err) end
			end
			if (not world.getBlockState(ins.pos).id:find("head$")) then
				ins.queueFree = true
				local ok, err = pcall(ins.identity.processBlock.ON_EXIT, ins,ins.model)
				if not ok then warn(err) end
				ins.model:remove()
				ins.model = nil
				blockInstances[key] = nil
			end
		end
	end

	if next(hatInstances) then
		---@param ins SkullInstanceHat
		for key, ins in pairs(hatInstances) do
			ins.matrix = ins.model and ins.model:partToWorldMatrix() or matrices.mat4()
			ins.vars = playerVars[ins.uuid] or {}
			if ins.isReady then
				local ok, err = pcall(ins.identity.processHat.ON_PROCESS, ins,ins.model,deltaFrame,deltaTick)
				if not ok then warn(err) end
			else
				ins.isReady = true
				local ok, err = pcall(ins.identity.processHat.ON_READY, ins,ins.model,deltaFrame,deltaTick)
				if not ok then warn(err) end
			end
			if time - ins.lastSeen > SKULL_DECAY_TIME then
				ins.queueFree = true
				local ok, err = pcall(ins.identity.processHat.ON_EXIT, ins,ins.model)
				if not ok then warn(err) end
				ins.model:remove()
				ins.model = nil
				hatInstances[key] = nil
			end
		end
	end
	if next(entityInstances) then
		---@param ins SkullInstanceEntity
		for key, ins in pairs(entityInstances) do
			if ins.model then
				ins.matrix = ins.model:partToWorldMatrix()
				ins.vars = playerVars[ins.uuid] or {}
				if ins.isReady then
					local ok, err = pcall(ins.identity.processEntity.ON_PROCESS, ins,ins.model,deltaFrame,deltaTick)
					if not ok then warn(err) end
				else
					ins.isReady = true
					local ok, err = pcall(ins.identity.processEntity.ON_READY, ins,ins.model,deltaFrame,deltaTick)
					if not ok then warn(err) end
				end
				if time - ins.lastSeen > 100 then
					ins.queueFree = true
					local ok, err = pcall(ins.identity.processEntity.ON_EXIT, ins,ins.model)
					if not ok then warn(err) end
					ins.identity.processEntity.ON_EXIT(ins,ins.model)
					ins.model:remove()
					ins.model = nil
					entityInstances[key] = nil
				end
			else
				entityInstances[key] = nil
			end
		end
	end

	if next(hudInstances) then
		---@param ins SkullInstanceHud
		for key, ins in pairs(hudInstances) do
			if ins.isReady then
				local ok, err = pcall(ins.identity.processHud.ON_PROCESS, ins,ins.model,deltaTick)
				if not ok then warn(err) end
			else
				ins.isReady = true
				local ok, err = pcall(ins.identity.processHud.ON_READY, ins,ins.model,deltaTick)
				if not ok then warn(err) end
			end
			if time - ins.lastSeen > SKULL_DECAY_TIME then
				ins.queueFree = true
				ins.identity.processHud.ON_EXIT(ins,ins.model)
				ins.model:remove()
				ins.model = nil
				hudInstances[key] = nil
			end
		end
	end
end


if IS_MAX then
	events.WORLD_RENDER:register(function (delta)
		process(delta)
		SKULL_PROCESS:setVisible(true)
	end)
else
	SKULL_PROCESS.preRender = process
	events.WORLD_RENDER:register(function ()
		SKULL_PROCESS:setVisible(true)
	end)
end


SKULL_PROCESS.midRender	 = function (delta, context, part)
	STARTUP_STALL = STARTUP_STALL - 1
	if STARTUP_STALL < 0 then
		STARTUP_STALL = nil
		SKULL_PROCESS.midRender = nil
	end
end

--[────────────────────────-< Generic APIs >-────────────────────────]--

---@param pos Vector3
---@return SkullInstanceBlock?
function SkullAPI.getSkull(pos)
	local block = blockInstances[SkullAPI.toID(pos)]
	if block and not block.queueFree then
		return block
	end
end


---@return table<string, SkullIdentity>
function SkullAPI.getSkullIdentities()
	return skullIdentities
end


---@return table<string, SkullInstanceBlock>
function SkullAPI.getSkullBlockInstances()
	return blockInstances
end


---@param pos Vector3
---@return string
function SkullAPI.toID(pos)
	return pos.x.. "," ..pos.y .. "," .. pos.z
end


return SkullAPI