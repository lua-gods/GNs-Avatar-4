--[[______   __
  / ____/ | / /  by: GNanimates / https://gnon.top / Discord: @gn68s
 / / __/  |/ / name: GN Class Library
/ /_/ / /|  /  desc: automatically creates getters and setters and events
\____/_/ |_/ source: link ]]

local Events = require("./event") ---@module "lib.event"


---@class Class
local class = {}

---@param t table
---@param i string
class.__index = function (t,i)
	local out = rawget(t,i)
	if out then return out end
	
	local name = i:match((i:find("^[gs]et") and "..." or "").."(.*)"):lower()
	if i:find("^get") then -- getter
		return function (self,...)
			return rawget(self,name)
		end
	elseif i:find("^set") then -- setter
		return function (self,value)
			local e = rawget(t,"__eventsLookup")[name]
			if e then
				e:invoke(value)
			end
			rawset(self,name,value)
		end
	else -- possible event
		if i:find("_CHANGED$") then
			local propertyName = i:sub(1,-9):lower():gsub('_%w',string.upper):gsub('_','')
			if rawget(t,propertyName) then
				local e = Events.new()
				rawget(t,"__eventsLookup")[propertyName] = e
				rawset(t,i,e)
				return e
			end
		end
	end
end

function class.apply(tbl)
	tbl.__eventsLookup = {}
	return setmetatable(tbl,class)
end


return class