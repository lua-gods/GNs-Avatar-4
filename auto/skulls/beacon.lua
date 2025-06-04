local SkullAPI = require("lib.skull")
local SkullUtils = require("lib.skullUtils")
local MiniMacro = require("lib.MiniMacro")


function hash(str)
	local hash = 0
	for i = 1, #str do
		local c = str:byte(i)
		hash = (hash * math.pi + c) % 100000 -- keep it within 5 digits
	end
	return hash
end

local identity = SkullAPI.registerIdentity{
	name = "minecraft:observer",
	modelBlock = models.skull.block,
	modelHat = models.skull.hat,
	modelHud = SkullUtils.makeIcon(models.skull.icon:getTextures()[1]),
	modelItem = models.skull.entity,
	
	processBlock = MiniMacro.new(
		---@param skull SkullInstanceBlock
		---@param model ModelPart
		function (skull, model)
			model:setColor(1,0,0)
		end,
	
	---@param skull SkullInstanceBlock
	---@param model ModelPart
	function (skull, model,delta)
		--local t = world.getTime(delta)/20 + hash(skull.pos.x..skull.pos.z)
		--model:setRot(0,t*90,0)
		--:setScale(1,math.abs((t)%2-1)*0.25+0.75,1)
	end,
	
	---@param skull SkullInstanceBlock
	---@param model ModelPart
	function (skull, model)
	end)
}

