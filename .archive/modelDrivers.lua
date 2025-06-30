---@diagnostic disable: param-type-mismatch

local variables = setmetatable({},{
	__index = function(t,k)
		return rawget(t,k) or 0
	end
})

local expressionEnv = setmetatable(
{math,table},
{
	__index = function(t,k)
		return rawget(t,k) or variables[k]
	end
}
)

local listeners = {}

---@type table<string,fun(model:ModelPart,...:any)>
local driverFunctions = {
	scale = function (model, x, y, z) model:scale(x,y,z) end,
	scaleX = function (model, x) model:scale(model:getScale()._yz + vec(x,0,0)) end,
	scaleY = function (model, y) model:scale(model:getScale().x_z + vec(0,y,0)) end,
	scaleZ = function (model, z) model:scale(model:getScale().xy_ + vec(0,0,z)) end,
	
	pos = function (model, x, y, z) model:pos(x,y,z) end,
	rot = function (model, x, y, z) model:rot(x,y,z) end,
	uvPos = function (model, x, y) 
		local mat = model:getUVMatrix() or matrices.mat3()
		mat.c3 = vec(x,y,1)
		model:setUVMatrix(mat)
		end,
	uvScale = function (model, x, y, px, py)
		px = px or 0
		py = py or 0
		local mat = matrices.mat3()
		local s = model:getTextureSize()
		px = px / s.x
		py = py / s.y
		mat:translate(-px,-py):scale(x,y):translate(px,py)
		model:setUVMatrix(mat)
		end
}

---@class modelDriverAPI
local API = {}

function API.setVar(name, value)
	variables[name] = value
	if listeners[name] then
		for _, driver in pairs(listeners[name]) do
			local data = driver.call()
			driver.driver(driver.model, table.unpack(data))
		end
	end
end

---@param model ModelPart
local function apply(model)
	local name = model:getName()
	
	local step = name:gmatch("[^:]+")
	local i = 0
	local modelName = step()
	for parameter in step do
		i = i + 1
		if parameter:find("[%a]+%([^)]*%)") then -- check if the 
			local driverName = parameter:match("[%a]+")
			if driverFunctions[driverName] then -- only register if the driver with the same name exists
				local expression = parameter:sub(#driverName+2,-2)
				local call = load("return {"..expression.."}",modelName,expressionEnv)
				
				local driver = {model = model, driver = driverFunctions[driverName], call = call}
				
				for varName in expression:gmatch("[%a]+") do
					listeners[varName] = listeners[varName] or {}
					listeners[varName][modelName..driverName] = driver
				end
			end
		end
	end
	
	for key, value in pairs(model:getChildren()) do
		apply(value)
	end
end

apply(models)

return API