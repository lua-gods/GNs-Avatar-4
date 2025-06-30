---copies a table as a new object instead of a reference.
---@param tbl table
---@return table
table.deepCopy = function (tbl)
	local copy = {}
	local meta = getmetatable(tbl)
	if meta then
		setmetatable(copy,meta)
	end
	for key, value in pairs(tbl) do
		if type(value) == "table" then
			value = table.deepCopy(value)
		end
		copy[key] = value
	end
	return copy
end

--- makes a table read-only
--- @param tbl table
table.makeReadOnly = function (tbl)
	local meta = {}
	meta.__index = tbl
	meta.__newindex = function (t,k,v)
		error("Attempt to modify read-only table",2)
	end
	return setmetatable({},meta)
end