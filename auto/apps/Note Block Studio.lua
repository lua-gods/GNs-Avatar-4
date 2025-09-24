local FileDialog = require("lib.GNUI-desktop.widget.fileDialog")

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
			
			local u1,u2,u3,u4 = client.uuidToIntArray("e4b91448-3b58-4c1f-8339-d40f75ecacc4")
			
			local data = buffer:readBase64(buffer:available())
			local item = ([=[minecraft:player_head{display:{Name:'{"text":"%s","italic":false}'},SkullOwner:{Id:[I;%s,%s,%s,%s],Properties:{textures:[{Value:"%s"}]}}}]=]):format("lao",u1,u2,u3,u4,data)
			if #item < 65536 then
				give(item)
				print("Generated ("..#item.." < 65536)")
			else
				print("Exceeded byte limit ("..#item.." > 65536)")
			end
		end)
	end
}