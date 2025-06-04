---@diagnostic disable: discard-returns
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
			skull.billBoard = model:newPart("billBoard"):scale(0.25,0.25,0.25):pos(0,16,0)

		end,
	
	---@param skull SkullInstanceBlock
	---@param model ModelPart
	function (skull, model,delta)
		model.ht:setRot(math.random(-5,5),math.random(-5,5),math.random(-5,5))
		local skulls = SkullAPI.getSkullBlockInstances()
		skull.billBoard:removeTask():setRot(0,90-client:getCameraRot().y)
		
		local i = 0
		
		---@param id string
		---@param targetSkull SkullInstanceBlock
		for id, targetSkull in pairs(skulls) do
			i = i + 1
			skull.billBoard:newText(id):pos(-25,i*10-50,0):text(id)
		end
		
	end,
	
	---@param skull SkullInstanceBlock
	---@param model ModelPart
	function (skull, model)
	end)
}

