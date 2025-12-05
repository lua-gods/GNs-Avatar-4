

function paper(text)
	host:setSlot("hotbar." .. player:getNbt().SelectedItemSlot, 
	"minecraft:paper"..toJson{
		display = {
			Name = toJson({text = "Written Paper",italic = false}),
			Lore = {toJson({text = text,italic = false, color = "gray"})}
		}
	}
)
	pings.write()
end


function pings.write()
	if player:isLoaded() then
		sounds:playSound("minecraft:entity.villager.work_cartographer",player:getPos())
	end
end