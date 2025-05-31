local Pages = require("lib.pages")
local book = Pages.newBook()

local keybind = keybinds:fromVanilla("figura.config.action_wheel_button")

book:newPage("default",function (events, ...)
	
end)

keybind.press = function (modifiers, self)
	if book.currentPage then
		book:setPage()
	else
		book:setPage("default")
	end
	return true
end