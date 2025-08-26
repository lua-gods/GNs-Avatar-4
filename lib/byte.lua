local api = {}

---@param bitFlags boolean[]
---@return string
function api.packPing(bitFlags)
   local data = {}
   for i = 1, #bitFlags, 8 do
      local n = 0
      for k = 0, 7 do
         if bitFlags[i + k] then
            n = n + bit32.lshift(1, k)
         end
      end
      table.insert(data, string.char(n))
   end
   return table.concat(data)
end

---@param bitFlags string
---@return boolean[]
function api.unpackPing(bitFlags)
	local data = {}
   for i = 1, #bitFlags do
      local j = i * 8 - 7
      local n = bitFlags:byte(i)
      for k = 0, 7 do
			data[j + k] = bit32.band(n, 2 ^ k) >= 1
      end
   end
	return data
end

return api