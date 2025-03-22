
---A singleton class for handling colors.
---@class Color
Color = {}

---Parses a color from different formats into a Vector4.
---@overload fun(hex : string): Vector4
---@overload fun(rgb : Vector3): Vector4
---@param r number
---@param g number
---@param b number
---@param a number
---@return Vector4
Color.parseColor = function (r,g,b,a)
	local t = type(r)
	if t == "string" then
		if r:find("^#") or r:match("%x%x%x%x%x%x") then
			return vectors.hexToRGB(r):augmented()
		else
			error("Unknown color: \""..r.."\"",2)
		end
	elseif t == "Vector3" then return r:augmented()
	elseif t == "Vector4" then return r
	elseif t == "number" and type(g) == "number" and type(b) == "number" then return vec(r,g,b,a or 1)
	else error("Invalid Color parameter, expected Vector3, (number, number, number) or Hexcode, instead got "..t,2)
	end
end

return Color