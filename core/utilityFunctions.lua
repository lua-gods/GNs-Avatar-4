function status(...)
	host:setActionbar(table.concat({...},", "))
end

function ping()
	sounds:playSound("minecraft:entity.item.pickup",client:getCameraPos():add(client:getCameraDir()),1,1)
	sounds:playSound("minecraft:entity.experience_orb.pickup",client:getCameraPos():add(client:getCameraDir()),1,1)
end

local printWhitelist = {
	"e4b91448-3b58-4c1f-8339-d40f75ecacc4"
}
-- dc912a38-2f0f-40f8-9d6d-57c400185362


local isWhitelisted = false
for index, uuid in ipairs(printWhitelist) do
	if client:getViewer():getUUID() == uuid then
		isWhitelisted = true
		break
	end
end

if not isWhitelisted then
	function print() end
end