

if not host:isHost() then return end

local GNUI = require("lib.GNUI.main")

local screen = GNUI.getScreen()

local Box = require("lib.GNUI.widget.box")
local Button = require("lib.GNUI.widget.button")
local TextField = require("lib.GNUI.widget.textField")
local Slider = require("lib.GNUI.widget.slider")
local Stack = require("lib.GNUI.widget.panes.stack")



local Window = require("lib.GNUI-desktop.widget.window")
local FileDialog = require("lib.GNUI-desktop.widget.fileDialog")



local function levenshtein(s, t)
	local m, n = #s, #t
	if m == 0 then return n end
	if n == 0 then return m end

	local matrix = {}
	for i = 0, m do
		matrix[i] = {}
		matrix[i][0] = i
	end
	for j = 0, n do
		matrix[0][j] = j
	end

	for i = 1, m do
		local s_i = s:sub(i, i)
		for j = 1, n do
			local t_j = t:sub(j, j)
			local cost = (s_i == t_j) and 0 or 1
			matrix[i][j] = math.min(
				matrix[i - 1][j] + 1, -- deletion
				matrix[i][j - 1] + 1, -- insertion
				matrix[i - 1][j - 1] + cost -- substitution
			)
		end
	end

	return matrix[m][n]
end


local function fuzzySort(query, arr)
	query = query:lower()
	table.sort(arr, function(a, b)
		return levenshtein(query, a.name:lower()) < levenshtein(query, b.name:lower())
	end)
	return arr
end

local apps = {}
for index, value in ipairs(listFiles("auto.apps")) do
	local appData = require(value)
	apps[#apps+1] = appData
end


---@class GNUI.App
---@field name string
---@field icon Minecraft.itemID
---@field start fun()

local WIDTH = 150
local HEIGHT = 20



local appLauncher = Stack.new(screen)
:setAnchor(0.5,0.5)
:setSize(WIDTH)
:setPos(-WIDTH/2,-7)
:setVisible(false)

local searchBar = TextField.new(appLauncher)
:setSize(0,HEIGHT)
:setTextAlign(0,0.5)

local appList = Stack.new(appLauncher)
:setSize(0,0)

local appLauncherBtn = Button.new(screen,"none")
:setCustomMinimumSize(8,8)
:setGrowDirection(0.5,0.5)
:setText(":mag_right:")
:setAnchor(0.5,0.5)


local function listApps(ap)
	appList:purgeAllChildren()
	for _, appData in pairs(ap) do
		local entryBtn = Button.new(appList)
		:setSize(0,HEIGHT)
		:setText(appData.name)
		:setTextAlign(0,0.5)
		:setTextOffset(HEIGHT+4,0)
		
		entryBtn.PRESSED:register(function ()
			appData.start()
			appLauncher:setVisible(false)
			appLauncherBtn:setVisible(true)
		end)
		
		local icon = Box.new(entryBtn)
		:setPos(HEIGHT*0.5,HEIGHT*0.5)
		icon.ModelPart:newItem("icon")
		:item(appData.icon)
		:setPos(-2,0)
	end
end

listApps(apps)


appLauncherBtn.PRESSED:register(function ()
	appLauncher:setVisible(true)
	appLauncherBtn:setVisible(false)
	searchBar:click()
end)

searchBar.FIELD_CONFIRMED:register(function (text)
	
	if #text > 0 then
		appList:getChildByIndex(1):click()
		appLauncher:setVisible(false)
		appLauncherBtn:setVisible(true)
	end
	
	return ""
end)

searchBar.FIELD_CHANGED:register(function (field)
	local filteredApps = {}
	for key, value in pairs(apps) do
		filteredApps[key] = value
	end
	fuzzySort(field, filteredApps)
	listApps(filteredApps)
end)
 
local key = keybinds:fromVanilla("figura.config.action_wheel_button")

local onCursor = false

key.press = function ()
	onCursor = not onCursor
	appLauncherBtn:setVisible(onCursor)
	if not onCursor then
		appLauncher:setVisible(false)
		searchBar:setTextField("")
	end
	host.unlockCursor = onCursor
	renderer.renderCrosshair = not onCursor
	return true
end