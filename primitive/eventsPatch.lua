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
		priority = tonumber(name:match("^(-?[0-9]+):"))
	end
	
	-- if event doesn't exist, create it
	if not subscribers[lastEvent] then
		local event = {
			subs={[priority]={}},
			layers={priority},
		}
		subscribers[lastEvent] = event
		
		ogEventsIndexRegister(self, function (...)
			for _, layerID in ipairs(event.layers) do
				for _, hook in pairs(event.subs[layerID]) do
					hook(...)
				end
			end
		end)
	end
	-- if priority doesn't exist, insertion sort it.
	if not subscribers[lastEvent].layers[priority] then
		local layers = subscribers[lastEvent].layers
		local inserted = false
		for i = 1, #layers, 1 do
			if layers[i] > priority then
				table.insert(layers, i, priority)
				inserted = true
				break
			end
		end
		if not inserted then
			table.insert(layers, priority)
		end
	end
	
	subscribers[lastEvent].subs[priority] = subscribers[lastEvent].subs[priority] or {}
	subscribers[lastEvent].subs[priority][name or #subscribers[lastEvent].subs[priority] + 1	] = func
	return self
end

events.TICK:register(function ()
	host:setActionbar("blue")
end,"1:lmao")

events.TICK:register(function ()
	host:setActionbar("orange")
end,"7:lmao")