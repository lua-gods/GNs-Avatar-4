# flags: host_only

local target = animations.player.roblox


local animationLookupCache = {}

local rootModelNames = {}
for key, value in pairs(models:getChildren()) do
	rootModelNames[key] = value:getName()
end

local animName = target:getName()


for i, modelName in ipairs(rootModelNames) do
	if animations[modelName] and animations[modelName][animName] then
		animationLookupCache[modelName] = animations[modelName][animName]
	end
end