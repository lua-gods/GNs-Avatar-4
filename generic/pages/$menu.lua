
local GNUI = require"library.GNUI.main"
local Theme = require"library.GNUI.theme"
local Button = require"library.GNUI.element.button"

local quickTween = require"library.quickTween"



local menus = {
	{
		name="Status",
		path="generic.pages.menus.$macros",
	},
	{
		name="Macros",
		path="generic.pages.menus.$settings",
	},
	{
		name=":open_folder_paper:Settings",
		path="generic.pages.menus.$statistics",
	},
}



Screen.new({
	name = "menu",
	background=true
},function (events,screen)
	screen:setDimensions(20,20,-20,-20)
	
	--#region wardrobe
	do
		local wardrobe = GNUI.newBox(screen)
		wardrobe:setAnchor(0.7,0,1,1)
		Theme.style(wardrobe,"Background")
		
		Button.new(wardrobe,"Secondary")
		:setAnchor(0,1,1,1)
		:setDimensions(0,-20,0,0)
		:setText("Wardrobe")
		
		local usernameButton = Button.new(wardrobe,"Secondary")
		:setAnchor(0,0,1,0)
		:setDimensions(0,0,-20,20)
		:setText("GNamimates")
		local editUsernameButton = Button.new(wardrobe,"Secondary")
		:setAnchor(1,0,1,0)
		:setDimensions(-20,0,0,20)
		:setText(":pencil:")
		:setTextBehavior("NONE")
		:setTextAlign(0,0)
		:setTextOffset(5,5)
		
		local statueAnchor = GNUI.newBox(wardrobe):setAnchor(0.5,0.5)
		local statue = models.player:deepCopy():applyFunc(function (model)
			model:setParentType("NONE")
		end)
		
		statue
		:scale(4.5)
		:setPos(0,-15*5,-20)
		:rot(0,15,0)
		statueAnchor.ModelPart:addChild(statue)
		
		
		local function updateUsername()
			usernameButton:setText(player:getName())
		end
		if player:isLoaded() then updateUsername() end
		events.ENTITY_INIT:register(updateUsername)
		quickTween.right(wardrobe,100)
		
		local isPressing = false
		---@param event GNUI.InputEvent
		wardrobe.INPUT:register(function (event)
			if event.key == "key.mouse.left" then
				isPressing = event.state == 1
			end
		end)
		
		---@param event GNUI.InputEventMouseMotion
		wardrobe.MOUSE_MOVED:register(function (event)
			if isPressing then
				statue:setRot(0,statue:getRot().y+event.relative.x*2,0)
			end
	end)
	end
	--#endregion
	
	do
		local c = #menus
		
		local menuTabs = GNUI.newBox(screen)
		:setAnchor(0,0,0.7,0)
		:setDimensions(0,0,-20,20)
		Theme.style(menuTabs,"Background")
		quickTween.up(menuTabs,100)
		
		
		local menuPage = GNUI.newBox(screen)
		:setAnchor(0,0,0.7,1)
		:setDimensions(0,30,-20,0)
		Theme.style(menuPage,"Background")
		quickTween.down(menuPage,100)
		
		
		local menuButtons = {} ---@type GNUI.Button[]
		local currentMenu = 0
		
		for i, menuInfo in ipairs(menus) do
			local name = menuInfo.name
			local button = Button.new(menuTabs,"Secondary")
			:setAnchor((i-1)/c,0,i/c,1)
			:setText(name)
			:setToggle(true)
			menuButtons[i] = button
		end
		
		local function setMenu(id)
			if currentMenu ~= id then
				currentMenu = id
				for i, button in ipairs(menuButtons) do
					button:setToggle(i ~= id)
					button:setPressed(i ~= id)
				end
			end
		end
		for i, button in ipairs(menuButtons) do
			button.PRESSED:register(function ()
				setMenu(i)
			end)
		end
		setMenu(1)
	end
end)

Screen.setScreen("menu")