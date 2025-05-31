---A Event is a list of functions that can be invoked.
---@class Event
local Events = {}
Events.__index = Events
function Events.new() return setmetatable({}, Events) end

Events.newEvent = Events.new

function Events:register(func, name) self[#self + 1] = {name or func, func} end

function Events:clear() for key in pairs(self) do self[key] = nil end end

function Events:remove(name) for id, value in pairs(self) do if value[1] == name then self[id] = nil end end end

function Events:getRegisteredCount(name)
	local c = 0
	if not name then return #self end
	for id, value in pairs(self) do if value[1] == name then c = c + 1 end end
	return c
end

function Events:__call(...)
	local flush = {}
	for _, func in pairs(self) do flush[#flush + 1] = {func[2](...)} end
	return flush
end

---@type fun(self: Event, ...: any): any[]
Events.invoke = Events.__call

function Events.__index(t, i) return rawget(t, i) or rawget(t, i:upper()) or Events[i] end

function Events.__newindex(t, i, v) rawset(t, type(i) == "string" and t[i:upper()] or i, v) end

return Events