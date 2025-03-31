
local GNUI = require"library.GNUI.main"
local Theme = require"library.GNUI.theme"
local Button = require"library.GNUI.element.button"

local quickTween = require"library.quickTween"

Screen.new({
	name = "menu.statistics"
},function (events, screen)
	local time = client:getDate()
	local dateStatus = Button.new(screen,"Tertiary")
	dateStatus
	:setAnchor(0,0,0.5,0)
	:setPos(1,1)
	:setSize(-1,20)
	:setText({text=time.month_name.." / "..time.day.." / "..time.year,color="white"})
	
	local timeStatus = Button.new(screen,"Tertiary")
	timeStatus
	:setAnchor(0.5,0,1,0)
	:setPos(0,1)
	:setSize(-1,20)
	:setText({text=((time.hour-1)%12+1) ..":"..time.minute .. (time.hour > 12 and " PM" or " AM"),color="white"})

	
	local localModeStatus = Button.new(screen,"Tertiary")
	localModeStatus
	:setAnchor(0,0,1,0)
	:setPos(1,21)
	:setSize(-2,20)
	:setText({text=":typing:  Figura "..client.getFiguraVersion(),color="white"})
	
	local statuses = ""
	
	local function addStatus(msg)
		if #msg > 1 then
			statuses = statuses .. " ● " .. msg .. "\n"
		else
			statuses = statuses .. "\n"
		end
	end
	
	
	
	if goofy then addStatus("Goofy Plugin Detected") end
	if addScript or true then addStatus("Exturaddon detected") end
	local c = 0
	for key, value in pairs( client.getActiveResourcePacks()) do
		if value:find('Fabric Mod') then
			c = c + 1
		end
		if value == 'Fabric Mod "VulkanMod"' then
			addStatus("Vulkan Mod Detected")
		end
	end
	addStatus("")
	addStatus("Instance has "..c.." fabric mods")
	
	local miniStatus = GNUI.newBox(screen)
	:setAnchorMax()
	:setDimensions(1,46,0,-15)
	:setText(statuses)
	
	local statusBar = Button.new(screen,"Tertiary")
	statusBar
	:setAnchor(0,1,1,1)
	:setDimensions(0,-15,0,0)
	:setTextOffset(4,0)
	:setText("Just GN  |  v7  |  by GNamimates"):setTextAlign(0,0.5)
end)