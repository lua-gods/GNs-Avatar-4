---@class EventLib
Event = {}
Event.__index = Event

function Event.new() return setmetatable({}, Event) end

Event.newEvent = Event.new

function Event:register(func, name) self[#self + 1] = {name or func, func} end

function Event:clear() for key in pairs(self) do self[key] = nil end end

function Event:remove(name) for id, value in pairs(self) do if value[1] == name then self[id] = nil end end end

function Event:getRegisteredCount(name)
	local c = 0
	if not name then return #self end
	for id, value in pairs(self) do if value[1] == name then c = c + 1 end end
	return c
end

function Event:__len() return #self end

function Event:__call(...)
	local flush = {}
	for _, func in pairs(self) do flush[#flush + 1] = {func(...)} end
	return flush
end

---@type fun(self: EventLib, ...: any): any[]
Event.invoke = Event.__call

function Event.__index(t, i) return rawget(t, i) or rawget(t, i:upper()) or Event[i] end

function Event.__newindex(t, i, v) rawset(t, type(i) == "string" and t[i:upper()] or i, v) end

return Event