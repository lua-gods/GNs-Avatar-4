# host only
if not host:isHost() then return end

local Pages = require("lib.pages")
local GNUI = require("lib.GNUI.main")
local book = Pages.newBook()

GNUI.getScreenCanvas():addChild(book:setAnchorMax())

local keybind = keybinds:fromVanilla("figura.config.action_wheel_button")

book:newPage("default",function (events, screen)
end)

keybind.press = function (modifiers, self)
	if book.currentPage then
		book:setPage()
	else
		book:setPage("Guitar")
	end
	return true
end

return book