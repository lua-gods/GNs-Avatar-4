---@diagnostic disable: missing-fields, undefined-field
require"primitive.Signal"

---@type table<string, {subs: table<number, table<any, fun(...)>>, layers: table<number>}>[]
local subscribers = {}
-- patch index
local lastContainer ---@type ContainedEventsAPI
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
		local subs
		if lastContainer and lastContainer.subscribers then
			subs = lastContainer.subscribers
		else
			subs = subscribers
		end
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
			end,lastContainer and lastContainer.id or nil)
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
-- patch register
figuraMetatables.Event.__index.register = registryOverride(figuraMetatables.Event.__index.register)

-- patch ENTITY_EXIT
local EntityExitAPI = {
	register = registryOverride(extraEvents.ENTITY_EXIT.register)
}
extraEvents.ENTITY_EXIT = setmetatable({},{__index = function (table, key)
	lastEvent = "ENTITY_EXIT"
	return EntityExitAPI[key] or rawget(extraEvents.ENTITY_EXIT, key) or Signal[key]
end})


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

-- patch ENTITY_EXIT
EntityExitAPI.remove = removeOverride(extraEvents.ENTITY_EXIT.remove)

extraEvents.ENTITY_EXIT = setmetatable({},{__index = function (table, key)
	return EntityExitAPI[key] or rawget(extraEvents.ENTITY_EXIT, key) or Signal[key]
end})

-->==========[ Extra APIs ]==========<--
local ogEvents = events

---@class EventsAPI
---@field ENTITY_EXIT Event
local eventsExtraAPI = {}
eventsExtraAPI.__index = function(table, key)
	lastContainer = nil
	return rawget(eventsExtraAPI, key) or ogEvents[key]
end


---@class ContainedEventsAPI : EventsAPI
local ContainedEventsAPI = {}

function ContainedEventsAPI.__index(table, key)
	lastContainer = table
	return rawget(table, key) or ContainedEventsAPI[key] or ogEvents[key]
end

-- Deletes all the registered events for the container.
function ContainedEventsAPI:free()
	for eventName, _ in pairs(self.subscribers) do
		if eventName == "ENTITY_EXIT" then
			for key, subscriber in pairs(extraEvents.ENTITY_EXIT) do
				if subscriber[1] == self.id then
					subscriber[2]()
					break
				end
			end
		end
		if type(events[eventName]) == "Event" then
			ogRemove(events[eventName],self.id) -- Figura Events
		else
			events[lastEvent]:remove(events[eventName],self.id) -- Lua Events
		end
	end
end


---@return ContainedEventsAPI
eventsExtraAPI.newContainer = function ()
	id = id + 1
	local container = {
		id = "proxy"..id,
		subscribers = {}
	}
	
	return setmetatable(container,ContainedEventsAPI)
end

---@type EventsAPI
events = setmetatable({},eventsExtraAPI)