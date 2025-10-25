# flags: host_only

local blacklist = {
	"Trol"
}

---@param item ItemStack
local function evaluateItem(item)
	for tagKey, tagValue in pairs(item:getTag()) do
		for index, blackTag in ipairs(blacklist) do
			if blackTag == tagKey or tonumber(tagKey) then
				return true
			end
		end
	end
end

events.TICK:register(function ()
	for i = 0, 26, 1 do
		local name = "inventory."..i
		if evaluateItem(host:getSlot(name)) then
			host:setSlot(name, "minecraft:air")
		end
	end
	
	for i = 0, 8, 1 do
		local name = "hotbar."..i
		if evaluateItem(host:getSlot(name)) then
			host:setSlot(name, "minecraft:air")
		end
	end
end)

