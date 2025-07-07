--[[______   __
  / ____/ | / /  by: GNanimates / https://gnon.top / Discord: @gn68s
 / / __/  |/ / name: GN Class Library
/ /_/ / /|  /  desc: automatically creates getters, setters and events dynamically
\____/_/ |_/ source: link ]]
--[[ Things to do when applying to an existing class:
 - replace rawget(table,index) with rawget(table.__tbl,index)
 - replace rawset(table,index,value) with rawset(table.__tbl,index,value)
]]

local Events = require("./event") ---@module "lib.event"


---@class GN.Class
---@field __tbl table
---@field __metatable table
---@field __eventsLookup table
local class = {}

---@param t table
---@param i string
class.__index = function (t,i)
	local mt = rawget(t,"__metatable")
	local out = mt and mt.__index(t.__tbl,i) or rawget(t.__tbl,i)
	if out ~= nil then return out end
	
	local name = i:match((i:find("^[gs]et") and "..." or "").."(.*)"):gsub("^%u",string.lower)
	if i:find("^get") then --[────────-< Getter >-────────]--
		local m = function (self,...)
			return rawget(self.__tbl,name)
		end
		rawset(mt,i,m)
		return m
	elseif i:find("^set") then --[────────-< Setter >-────────]--
		return function (self,value)
			rawset(self.__tbl,name,value)
			local e = rawget(t,"__eventsLookup")[name]
			if e then
				e:invoke(value)
			end
		end
	else -- possible event
		if i:find("_CHANGED$") then
			local propertyName = i:sub(1,-9):lower():gsub('_%w',string.upper):gsub('_','')
			-- rawget(t.__tbl,propertyName) <- limit to existing properties (unused)
			local e = Events.new()
			rawget(t,"__eventsLookup")[propertyName] = e
			rawset(t.__tbl,i,e)
			return e
		end
	end
end


---@param t GN.Class
---@param i string
class.__newindex = function (t,i,v)
	local mt = rawget(t,"__metatable")
	local event = rawget(t.__tbl,i:gsub("^%u",string.lower):gsub("(%u)","_%1"):upper().."_CHANGED")
	local setterMethod = "set"..i:gsub("^.",string.upper)
	
	-- this allows setting values into the table without using rawset in the methods themselves.
	local isInMethod = rawget(t,"__inMethod")
	if not isInMethod and t[setterMethod] then
		rawset(t,"__inMethod",true)
		t[setterMethod](t,v)
	else
		rawset(t,"__inMethod",false)
		rawset(t.__tbl,i,v)
		if event then event:invoke(v) end
	end
	
end

function class.apply(tbl,metamethod)
	local proxy
	if not tbl.__tbl then
		tbl = tbl or {}
		proxy = {
			__tbl = tbl,
			__eventsLookup = {},
			__metatable = metamethod or getmetatable(tbl)
		}
	else
		proxy = tbl
	end
	return setmetatable(proxy,class)
end


return class