---@class MacroAPI
local MacrosAPI = {}


---@class Macros
---@field isActive boolean
---@field events MacroEventsAPI
---@field package init fun(events: MacroEventsAPI)
local Macros = {}
Macros.__index = Macros



function Macros:toggle(active)
	if self.isActive ~= active then
		self.isActive = active
		if active then
			self.init(self.events)
		end
	end
end


---@class MacroEventsAPI : EventsAPI
---@field ON_FREE Event
local MacroEventsAPI = {}


---@param init fun(events: MacroEventsAPI)
---@return Macros
function MacrosAPI.new(init)
	local new = {
		init = init,
		isActive = false,
		events = setmetatable({
			ON_FREE = Signal.new()
		}, MacroEventsAPI),
}
	return setmetatable(new, Macros)
end

MacroEventsAPI.__index = function (t, k)
	if not rawget(t, k) then
		local signal = Signal.new()
		rawset(t, k, signal)
		--if v and type(v) == "function" then signal:register(v) end
	end
	return rawget(t, k)
end


---@type MacroAPI
_G.Macros = MacrosAPI

local test = MacrosAPI.new(function (events)
	print(events.TICK.register(events.TICK,function () end))
	--events.TICK:register(function ()end)
end)

test:toggle(true)