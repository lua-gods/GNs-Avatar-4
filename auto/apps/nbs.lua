# flags: host_only
local FileDialog = require("lib.GNUI-desktop.widget.fileDialog")


local Skull = require("lib.skull")

local function give(item)
	if player:isLoaded() then
		local id = player:getNbt().SelectedItemSlot
		sounds:playSound("minecraft:entity.item.pickup",client:getCameraPos():add(client:getCameraDir()),1,1)
		host:setSlot("hotbar."..id,item)
	end
end

---@type GNUI.App
return {
	name = "NBS Head",
	icon = "minecraft:note_block",
	start = function ()
		FileDialog.new().ITEM_CONFIRMED:register(function (path,name)
			local buffer = data:createBuffer()
			buffer:readFromStream(file:openReadStream(path))
			buffer:setPosition(0)
			
			local data = buffer:readBase64(buffer:available())
			Skull.giveSkull({nbs={data}},name)
			buffer:close()
		end)
	end
}