
---@param model ModelPart
---@param indent integer
local function _showModelTree(model,indent)
	if model:getType() == "GROUP" then
		print((" "):rep(indent) .. model:getName())
		for _, v in ipairs(model:getChildren()) do
			_showModelTree(v,indent + 1)
		end
	end
end

function showModelTree(model)
	model = model or models
	_showModelTree(model,0)
end