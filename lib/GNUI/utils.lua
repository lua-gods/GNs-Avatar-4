---@diagnostic disable: assign-type-mismatch
---@class GNUI.UtilsAPI
local utils = {}

--[────────────────────────────────────────-< Vector4 Utilities >-────────────────────────────────────────]--

---Returns the same vector but the `X` `Y` are the **min** and `Z` `W` are the **max**.	
---vec4(1,2,0,-1) --> vec4(0,-1,1,2)
---@param vec4 Vector4
---@return Vector4
function utils.vec4MinMax(vec4)
	return vec(
		math.min(vec4.x,vec4.z),
		math.min(vec4.y,vec4.w),
		math.max(vec4.x,vec4.z),
		math.max(vec4.y,vec4.w)
	)
end


---Gets the size of a vec4
---@param vec4 Vector4
---@return Vector2
function utils.vec4GetSize(vec4)
	return (vec4.zw - vec4.xy) ---@type Vector2
end

--[────────────────────────────────────────-< Vectors >-────────────────────────────────────────]--

---@param posx number|Vector2
---@param y number?
---@return Vector2
function utils.vec2(posx,y)
	local ta, tb = type(posx), type(y)
	if ta == "Vector2" then
		return posx:copy()
	elseif ta == "number" and tb == "number" then
		return vec(posx,y)
	else
		error("Invalid Vector2 parameter, expected Vector2 or (number, number), instead got ("..ta..", "..tb..")")
	end
end

---@param posx number|Vector3
---@param y number?
---@param z number?
---@return Vector3
function utils.vec3(posx,y,z)
	local ta, tb, tc = type(posx), type(y), type(z)
	
	if ta == "Vector3" then
		return posx:copy()
	elseif ta == "number" and tb == "number" and tc == "number" then
		return vec(posx,y,z)
	else
		error("Invalid Vector3 parameter, expected Vector3 or (number, number, number), instead got ("..ta..", "..tb..", "..tc..")")
	end
end

---@param posx number|Vector2|Vector4
---@param y (number|Vector2)?
---@param z number?
---@param w number?
---@return Vector4
function utils.vec4(posx,y,z,w)
	local ta, tb, tc, td = type(posx), type(y), type(z), type(w)
	
	if ta == "Vector4" then
		return posx:copy()
	elseif ta == "number" and tb == "number" and tc == "number"	and td == "number" then
		return vectors.vec4(posx,y,z,w)
	elseif ta == "Vector2" and tb == "Vector2" then
		return vec(posx.x,posx.y,y.x,y.y)
	else
		error("Invalid Vector4 parameter, expected Vector4 or (number, number, number, number), instead got ("..ta..", "..tb..", "..tc.. ", "..td..")")
	end
end


--[────────────────────────────────────────-< Copy >-────────────────────────────────────────]--

local function deepCopy(original)
	local copy = {}
	local meta = getmetatable(original)
	if meta then
		setmetatable(copy,meta)
	end
	for key, value in pairs(original) do
		if type(value) == "table" then
			value = utils.deepCopy(value)
		end
		
		if type(value):find("Vector") then
			value = value:copy()
		end
		copy[key] = value
	end
	return copy
end

function utils.deepCopy(tbl)
	return deepCopy(tbl)
end

---@generic tbl
---@param tbl tbl
---@return tbl
function utils.shallowCopy(tbl)
	local copy = {}
	for key, value in pairs(tbl) do
		copy[key] = value
	end
	return copy
end


return utils