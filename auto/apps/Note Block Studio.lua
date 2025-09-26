local FileDialog = require("lib.GNUI-desktop.widget.fileDialog")

local function give(item)
  if player:isLoaded() then
    local id = player:getNbt().SelectedItemSlot
    sounds:playSound("minecraft:entity.item.pickup",client:getCameraPos():add(client:getCameraDir()),1,1)
    host:setSlot("hotbar."..id,item)
  end
end

local zlib = require("lib.zlib")

---@type GNUI.App
return {
	name = "NBS Head",
	icon = "minecraft:note_block",
	start = function ()
		FileDialog.new().ITEM_CONFIRMED:register(function (path,name)
			local u1,u2,u3,u4 = client.uuidToIntArray("e4b91448-3b58-4c1f-8339-d40f75ecacc4")
			
			local buffer = data:createBuffer()
			buffer:readFromStream(file:openReadStream(path))
			buffer:setPosition(0)
			local str = buffer:readByteArray(buffer:available())
			str = zlib.Deflate.Compress(str)
			buffer:clear()
			buffer:setPosition(0)
			buffer:writeByteArray(str)
			buffer:setPosition(0)
			
			local data = buffer:readBase64(buffer:available())
			local textures = {}
			-- split the string to 32kb chunks
			for i=1, #data, 32768 do
				table.insert(textures, {Value = string.sub(data, i, i+32767)})
			end
			
			local item = ([=[minecraft:player_head{display:{Name:%s},SkullOwner:{Id:[I;%s,%s,%s,%s],Properties:{textures:%s}}}]=]):format(toJson(toJson({text=name})),u1,u2,u3,u4,toJson(textures))--
			
			host:setClipboard(item)
			if #item < 65536*999 then
				give(item)
				print("Generated ("..#item..")")
			end
		end)
	end
}