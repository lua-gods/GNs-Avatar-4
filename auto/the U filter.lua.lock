
local replace = {
	--a = "а",
	--c = "с",
	----d = "ԁ",
	--h = "һ",
	--i = "і",
	--j = "ј",
	----n = "ո",
	--o = "о",
	--p = "р",
	
	gnui = "gnսi",
	GNUI = "GN⋃I",
	--v = "ν",
	--x = "х",
	--y = "у",
	
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