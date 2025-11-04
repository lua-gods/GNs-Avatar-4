function status(...)
	host:setActionbar(table.concat({...},", "))
end

function ping()
	sounds:playSound("minecraft:entity.item.pickup",client:getCameraPos():add(client:getCameraDir()),1,1)
	sounds:playSound("minecraft:entity.experience_orb.pickup",client:getCameraPos():add(client:getCameraDir()),1,1)
end