---@class ModelPart
local ModelsAPI = {}

local ogIndex = figuraMetatables.ModelPart.__index
figuraMetatables.ModelPart.__index = function (table, key)
	return ModelsAPI[key] or ogIndex(table, key) or ModelsAPI[key]
end

---@param model ModelPart
---@param process fun(model:ModelPart)?
---@return ModelPart
local function deepCopyModel(model,process)
	local copy = model:copy(model:getName())
	if process then process(copy) end
	for key, child in pairs(copy:getChildren()) do
		copy:removeChild(child):addChild(deepCopyModel(child,process))
	end
	return copy
end

---Copies the model and its hierarchy.
---@return ModelPart
function ModelsAPI:deepCopy()
	return deepCopyModel(self)
end

local function applyFunc(model,func)
	func(model)
	for _, child in pairs(model:getChildren()) do
		applyFunc(child,func)
	end
	return model
end

---Calls a function with the first argument being the model getting applied with.
---@param func fun(model:ModelPart)
function ModelsAPI:applyFunc(func)
	applyFunc(self,func)
	return self
end