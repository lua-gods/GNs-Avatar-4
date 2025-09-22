--[ [

local blist = {
	["aa92bf40-5065-4a4c-a955-c201eacfb4ef"] = true,
}

if blist[client:getViewer():getUUID()] then
	vanilla_model.ALL:setVisible(false)
	for index, value in ipairs(models:getChildren()) do
		value:setVisible(false)
	end
	renderer:setShadowRadius(0)
	nameplate.ENTITY:setVisible(false)
	
	models:newPart("s","SKULL")
	:setVisible(true)
	:newBlock("dirt")
	:block("minecraft:dirt")
	:scale(0,0,0)
	
	local ppos
	events.TICK:register(function ()
		ppos = player:getPos():add(0,1,0)
	end)
	
	events.ON_PLAY_SOUND:register(function (id, pos)
		if player:isLoaded() and (ppos-pos):length() < 2 then
			return true
		end
	end)
	
	function require()
		
	end
	
	return
end

--]]