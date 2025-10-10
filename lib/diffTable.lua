---@class diffTable
---@field __ON_ADD fun(key:string,value: string,...:string)
---@field __ON_MODIFY fun(key:string,value: string,...:string)
---@field __ON_REMOVE fun(key:string,value: string,...:string)
---@field data table
---@field lastData table
---@field [string] string
local diffTable = {}
diffTable.__index = function (t,k)
	return rawget(t,k) or t.data[k] or diffTable[k]
end
diffTable.__newindex = function(t,k,v)
	diffTable.set(t,k,v)
end

local function placeholder() end

---@param onAdd (fun(key:string,value: string,...:string):string)?
---@param onRemove (fun(key:string,value: string,...:string):string)?
---@param onModify (fun(key:string,value: string,...:string):string)?
---@return diffTable
function diffTable.new(onAdd, onRemove, onModify)
	local self = {
		__ON_ADD = onAdd or placeholder,
		__ON_REMOVE = onRemove or placeholder,
		__ON_MODIFY = onModify or placeholder,
		data = {},
		lastData = {},
	}
	setmetatable(self, diffTable)
	return self
end

---Does the same as setting an entry into the table, but with additional parameters to pass onto the diff callbacks.
---@param key string
---@param value string
---@param ... string
function diffTable:set(key, value, ...)
	local lastData = self.data[key]
	local ret = {}
	if lastData ~= value then -- if not the same
		--self.data[key] = value
		if type(value) ~= "nil" then -- if data exists
			if lastData == nil then -- if slot was empty
				pData = self.__ON_ADD(key,value,...)
			else -- if the same
				pData = self.__ON_MODIFY(key,value,...)
			end
		else -- if data being set doesn't exist
			pData = self.__ON_REMOVE(key,self.data[key],...)
		end
	end
	self.data[key] = pData
	return pData
end

function diffTable:remove(key,...)
	self:set(key, nil,...)
end


function diffTable:update()
	self.lastData = self.data
	self.data = {}
end



-- UNIT TESTING
--[[  <- separate the two square brackets to enable unit testing

print("============================")

print("Callback Testing")

local diff = diffTable.new(function (key, value, ...)
	print("added", key, value, ...)
end, function (key, value, ...)
	print("removed", key, value, ...)
end, function (key, value, ...)
	print("modified", key, value, ...)
end)


diff:set("foo","bar")

assert(diff.foo == "bar", "foo was not set / metamethod did not reroute the path to the data field")
assert(diff.data.foo == "bar", "data.foo was not set")


diff:set("foo","baz")
assert(diff.foo == "baz", "modify callback did not invoke")
diff:set("foo")
assert(diff.foo == nil, "modify callback did not invoke")
--]]


return diffTable