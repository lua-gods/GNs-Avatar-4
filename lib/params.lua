local params={}


---Parses Vector2 variants into a single unified Vector2.
---@overload fun(xy: Vector2): Vector2
---@param x number
---@param y number
---@return Vector2
function params.vec2(x,y)
	local tx,ty=type(x), type(y)
	if (tx == "number" and ty == "number") then
		return vec(x,y)
	elseif (tx == "Vector2" and ty == "nil") then
		---@cast tx Vector2
		return x
	else
		error(("Invalid Vecto2 parameter, expected (number, number), (Vector2), instead got (%s, %s)"):format(tx,ty),2)
	end
end


---Parses Vector3 variants into a single unified Vector3.
---@overload fun(xyz: Vector3): Vector3
---@param x number
---@param y number
---@param z number
---@return Vector3
function params.vec3(x,y,z)
	local tx,ty,tz=type(x), type(y), type(z)
	if (tx == "number" and ty == "number" and tz == "number") then
		return vec(x,y,z)
	elseif (tx == "Vector3" and ty == "nil" and tz == "nil") then
		---@cast tx Vector3
		return x
	else
		error(("Invalid Vecto3 parameter, expected (number, number, number), (Vector3), instead got (%s, %s, %s)"):format(tx,ty,tz),2)
	end
end


---Parses Vector4 variants into a single unified Vector4.
---@overload fun(xyzw: Vector4): Vector4
---@param x number
---@param y number
---@param z number
---@param w number
---@return Vector4
function params.vec4(x,y,z,w)
	local tx,ty,tz,tw=type(x), type(y), type(z), type(w)
	if (tx == "number" and ty == "number" and tz == "number" and tw == "number") then
		return vec(x,y,z,w)
	elseif (tx == "Vector4" and ty == "nil" and tz == "nil" and tw == "nil") then
		---@cast tx Vector4
		return x
	else
		error(("Invalid Vecto4 parameter, expected (number, number, number, number), (Vector4), instead got (%s, %s, %s, %s)"):format(tx,ty,tz,tw),2)
	end
end


return params