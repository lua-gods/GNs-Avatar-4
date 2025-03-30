---@diagnostic disable: missing-fields, undefined-field
require"primitive.Signal"

---@type table<string, {subs: table<number, table<any, fun(...)>>, layers: table<number>}>[]
local subscribers = {}
-- patch index
local lastEvent ---@type string
local id = 0 ---@type integer
local extraEvents = {
	ENTITY_EXIT = Signal
}

local ogEventsAPIIndex = figuraMetatables.EventsAPI.__index
figuraMetatables.EventsAPI.__index = function(self, key)
	lastEvent = key
	return extraEvents[key] or ogEventsAPIIndex(self, key)
end

local wasLoaded = false
events.WORLD_RENDER:register(function ()
	local isLoaded = player:isLoaded()
	if isLoaded ~= wasLoaded then
		wasLoaded = isLoaded
		if not isLoaded then
			extraEvents.ENTITY_EXIT:invoke()
		end
	end
end)
local registryOverride = function (ogRegistry)
	return function(self, func, name)
		local subs = subscribers
		local priority = 0
		
		-- get priority if it exists
		if name then
			priority = tonumber(name:match("^(-?[0-9]+):")) or 0
		end
		
		-- if event doesn't exist, create it
		if not subs[lastEvent] then
			local event = {
				subs={[priority]={}},
				layers={priority},
			}
			subs[lastEvent] = event
			
			-- invoke ENTITY_INIT when player is already loaded PATCH
			if lastEvent == "ENTITY_INIT" and player:isLoaded() then func() end
			
			ogRegistry(self, function (...)
				local flush = {}
				for _, layerID in ipairs(event.layers) do
					for _, hook in pairs(event.subs[layerID]) do
						local result = {hook(...)}
						flush = #result > 0 and result or flush -- if result has elements, use it, otherwise use flush
					end
				end
				return table.unpack(flush)
			end)
		end
		-- if priority doesn't exist, insertion sort it.
		if not subs[lastEvent].layers[priority] then
			local layers = subs[lastEvent].layers
			local inserted = false
			for i = 1, #layers, 1 do
				if layers[i] >= priority then
					if layers[i] ~= priority then -- if the priority doesn't exist
						table.insert(layers, i, priority)
					end
					inserted = true
					break
				end
			end
			if not inserted then
				table.insert(layers, priority)
			end
		end
		
		subs[lastEvent].subs[priority] = subs[lastEvent].subs[priority] or {}
		subs[lastEvent].subs[priority][name or #subs[lastEvent].subs[priority] + 1] = func
		return self
	end
end
local ogRegister = figuraMetatables.Event.__index.register
-- patch register
figuraMetatables.Event.__index.register = registryOverride(ogRegister)


-- patch getRegisteredCount
local ogRegisteredCount = figuraMetatables.Event.__index.getRegisteredCount
figuraMetatables.Event.__index.getRegisteredCount = function(self, name)
	local subs
	if self.subscribers then
		subs = self.subscribers[lastEvent]
	else
		subs = subscribers[lastEvent]
	end
	if subs then
		local c = 0
		for _, layerID in ipairs(subs.layers) do
			for _, _ in pairs(subs.subs[layerID]) do
				c = c + 1
			end
		end
		return c
	else
		return ogRegisteredCount(self, name)
	end
end

local removeOverride = function (ogRemove)
	return function(self, name)
		local subs
		if self.subscribers then
			subs = self.subscribers[lastEvent]
		else
			subs = subscribers[lastEvent]
		end
		
		if subs then
			for _, layerID in ipairs(subs.layers) do
				for key, hook in pairs(subs.subs[layerID]) do
					if key == name then
						subs.subs[layerID][key] = nil
					end
				end
			end
		end
		return ogRemove(self, name)
	end
end
-- patch remove
local ogRemove = figuraMetatables.Event.__index.remove
figuraMetatables.Event.__index.remove = removeOverride(figuraMetatables.Event.__index.remove)