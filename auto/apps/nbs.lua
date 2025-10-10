local FileDialog = require("lib.GNUI-desktop.widget.fileDialog")

local zlib = require("lib.zlib")

local Skull = require("lib.skull")


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
	local item = Skull.makeSkull({nbs={data}},name)
	buffer:close()
	
	Skull.makeSkull({ogg=item},name)
	print("Generated ("..#item..")")
end)
	end
}