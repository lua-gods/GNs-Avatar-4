local utils = {}

local function deepCopy(part)
	local copy = part:copy(part:getName())
	for key, value in pairs(part:getTask()) do
		copy:addTask(value)
	end
	for _, child in ipairs(part:getChildren()) do
		copy:removeChild(child)
		deepCopy(child):moveTo(copy)
	end
	return copy
end


function utils.shallowCopy(part)
	local copy = part:copy(part:getName())
	for key, value in pairs(part:getTask()) do
		copy:addTask(value)
	end
	return copy
end



---comment
---@param model ModelPart
function utils.deepCopy(model)
	assert(type(model) == "ModelPart", "expected ModelPart, got "..type(model))
	return deepCopy(model)
end


return utils