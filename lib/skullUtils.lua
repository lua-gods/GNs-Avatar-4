local SkullUtils = {}

---@param texture Texture
function SkullUtils.makeIcon(texture)
	local model = models:newPart(texture:getName().."Icon","SKULL")
	models:addChild(model)
	return model
end

return SkullUtils