events.CHAT_SEND_MESSAGE:register(function (message)
	if message:find("`") then
		if player:getPermissionLevel() >= 2 then
			host:sendChatCommand(('/tellraw @s {"translate":"chat.type.text","with":["%s","%s"]}'):format(player:getName(),toJson(message:sub(2,-1)):sub(2,-2)))
			host:appendChatHistory(message)
		end
		return 
	end
	return message
end)