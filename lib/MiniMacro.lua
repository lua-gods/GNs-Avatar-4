
local Event = require("lib.event")

local placeholder = function () end

---@class MiniMacro
---@field isActive boolean
---@field ON_ENTER fun(...)
---@field PROCESS fun(...)
---@field ON_EXIT fun(...)
local MiniMacro = {}
MiniMacro.__index = MiniMacro

---@param onEnter fun(...)?
---@param process fun(...)?
---@param onExit fun(...)?
---@return MiniMacro
function MiniMacro.new(onEnter,process,onExit)
	local self = {
		ON_ENTER = onEnter or placeholder,
		PROCESS = process or placeholder,
		ON_EXIT = onExit or placeholder,
	}
	return setmetatable(self, MiniMacro)
end


return MiniMacro