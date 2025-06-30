# host only
if not host:isHost() then return end

local Pages = require("lib.pages")
local GNUI = require("lib.GNUI.main")
local book = Pages.newBook()

local keybind = keybinds:fromVanilla("figura.config.action_wheel_button")

GNUI.getScreenCanvas():addChild(book:setAnchorMax())
book:newPage("default",function (events, screen) end) -- creates a page that gets displayed by default

keybind.press = function (modifiers, self)
	if book.currentPage then
		book:setPage()
	else
		book:setPage("menu")
	end
	return true
end

return book