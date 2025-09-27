local FileDialog = require("lib.GNUI-desktop.widget.fileDialog")

local zlib = require("lib.zlib")

local Skull = require("lib.skull")


local function give(item)
	if player:isLoaded() then
		local id = player:getNbt().SelectedItemSlot
		sounds:playSound("minecraft:entity.item.pickup",client:getCameraPos():add(client:getCameraDir()),1,1)
		host:setSlot("hotbar."..id,item)
	end
end

function head(nbt,name)
	name = name or "GN's Head"
	give(Skull.writeSkull(nbt,name))
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
			local item = Skull.writeSkull({nbs={data}},name)
			buffer:close()
			
			if #item < 65536*999 then
				give(item)
				print("Generated ("..#item..")")
			end
		end)
	end
}