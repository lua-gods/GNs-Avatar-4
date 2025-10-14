
models = models.models

local ogIndex = figuraMetatables.AnimationAPI.__index
figuraMetatables.AnimationAPI.__index = function(self, key)
	return ogIndex(self,key) or ogIndex(self, "models."..tostring(key))
end