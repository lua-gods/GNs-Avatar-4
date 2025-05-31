---@class MacroAPI
local MacrosAPI = {}

require("event")

---@class Macros
---@field isActive boolean
---@field events MacroEventsAPI
---@field id string
---@field package init fun(events: MacroEventsAPI,...)
local Macros = {}
Macros.__index = Macros



function Macros:toggle(active,...)
	if self.isActive ~= active then
		self.isActive = active
		if active then
			self.init(self.events,...)
			for name, value in pairs(self.events) do
				if events[name] then
					events[name]:register(function (...)
						value:invoke(...)
					end, self.id)
				end
			end
		else
			---@diagnostic disable-next-line: undefined-field
			self.events.ON_FREE:invoke(...)
			for name in pairs(self.events) do
				if events[name] then
					events[name]:remove(self.id)
				end
			end
		end
	end
end


---@class MacroEventsAPI : EventsAPI
---@field ON_FREE Event
local MacroEventsAPI = {}


---@param init fun(events: MacroEventsAPI,...)
---@return Macros
function MacrosAPI.new(init)
	local new = {
		init = init,
		isActive = false,
		id = client.intUUIDToString(client.generateUUID()),
		events = setmetatable({
			ON_FREE = Events.new()
		}, MacroEventsAPI),
}
	return setmetatable(new, Macros)
end

MacroEventsAPI.__index = function (t, k)
	if not rawget(t, k) then
		local signal = Events.new()
		rawset(t, k, signal)
		--if v and type(v) == "function" then signal:register(v) end
	end
	return rawget(t, k)
end


---@type MacroAPI
_G.Macros = MacrosAPI