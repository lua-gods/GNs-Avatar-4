# flags: host_only

local replace = {
	gnui = "gnuі",
	GNUI = "GΝUI",
}

events.CHAT_SEND_MESSAGE:register(function (message)
	local msg = message
	if message then
		if message:sub(1,1) ~= "/" then
			for what, with in pairs(replace) do
				msg = msg:gsub(what, with)
			end
		end
		return msg
	end
end)