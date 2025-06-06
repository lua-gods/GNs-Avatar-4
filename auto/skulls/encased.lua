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
	name = "minecraft:gold_block",
	modelBlock = models.skull.block,
	modelHat = models.skull.hat,
	modelHud = SkullUtils.makeIcon(models.skull.icon:getTextures()[1]),
	modelItem = models.skull.entity,
	
	processBlock = MiniMacro.new(
		---@param skull SkullInstanceBlock
		---@param model ModelPart
		function (skull, model)
			skull.blockModel:newBlock("encasing"):block("minecraft:white_stained_glass")
			skull.blockModel:newBlock("encasing2"):block("minecraft:black_concrete"):scale(-0.99,0.99,0.99):pos(15.99,0.01,0.01)
		end,
	
	---@param skull SkullInstanceBlock
	---@param model ModelPart
	function (skull, model,delta)
	end,
	
	---@param skull SkullInstanceBlock
	---@param model ModelPart
	function (skull, model)
	end)
}

