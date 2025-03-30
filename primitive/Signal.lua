---A Signal is a list of functions that can be invoked.
---@class Signal
Signal = {}
Signal.__index = Signal

function Signal.new() return setmetatable({}, Signal) end

Signal.newEvent = Signal.new

function Signal:register(func, name) self[#self + 1] = {name or func, func} end

function Signal:clear() for key in pairs(self) do self[key] = nil end end

function Signal:remove(name) for id, value in pairs(self) do if value[1] == name then self[id] = nil end end end

function Signal:getRegisteredCount(name)
	local c = 0
	if not name then return #self end
	for id, value in pairs(self) do if value[1] == name then c = c + 1 end end
	return c
end

function Signal:__call(...)
	local flush = {}
	for _, func in pairs(self) do flush[#flush + 1] = {func(...)} end
	return flush
end

---@type fun(self: Signal, ...: any): any[]
Signal.invoke = Signal.__call

function Signal.__index(t, i) return rawget(t, i) or rawget(t, i:upper()) or Signal[i] end

function Signal.__newindex(t, i, v) rawset(t, type(i) == "string" and t[i:upper()] or i, v) end

return Signal