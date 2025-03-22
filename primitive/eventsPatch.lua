local subscribers = {}


-- patch index
local lastEvent ---@type string
local ogEventsAPIIndex = figuraMetatables.EventsAPI.__index
figuraMetatables.EventsAPI.__index = function(self, key)
	lastEvent = key
	return ogEventsAPIIndex(self, key)
end

-- patch register
local ogEventsIndexRegister = figuraMetatables.Event.__index.register
figuraMetatables.Event.__index.register = function(self, func, name)
	local priority = 0
	
	-- get priority if it exists
	if name then
		priority = tonumber(name:match("^(-?[0-9]+):")) or 0
	end
	
	-- if event doesn't exist, create it
	if not subscribers[lastEvent] then
		local event = {
			subs={[priority]={}},
			layers={priority},
		}
		subscribers[lastEvent] = event
		ogEventsIndexRegister(self, function (...)
			local flush = {}
			if lastEvent == "KEY_PRESS" then
				print("Event: " .. lastEvent)
				printTable(subscribers[lastEvent])
			end
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
	if not subscribers[lastEvent].layers[priority] then
		local layers = subscribers[lastEvent].layers
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
	
	subscribers[lastEvent].subs[priority] = subscribers[lastEvent].subs[priority] or {}
	subscribers[lastEvent].subs[priority][name or #subscribers[lastEvent].subs[priority] + 1] = func
	return self
end

-- patch getRegisteredCount
local ogRegisteredCount = figuraMetatables.Event.__index.getRegisteredCount
figuraMetatables.Event.__index.getRegisteredCount = function(self, name)
	local subs = subscribers[lastEvent]
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

-- patch remove
local ogRemove = figuraMetatables.Event.__index.remove
figuraMetatables.Event.__index.remove = function(self, name)
	local subs = subscribers[lastEvent]
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