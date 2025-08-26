---@class utilsTable
local utilsTable = {}

---@generic tbl
---@param tbl tbl
---@param func fun(key: any, value: any): any
---@return tbl
function utilsTable.forEach(tbl,func)
	local out = {}
	for key, value in pairs(tbl) do
		out[key] = func(value,key) or value
	end
	return out
end


return utilsTable