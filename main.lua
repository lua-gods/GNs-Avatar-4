

--[[ <- separate to enable
figuraMetatables.HostAPI.__index.isHost = function () return false end
--]]

IS_FIGURA = true


--[ [
local blist = {
	["4a7ff870-027e-43a0-a1a5-05f7c4d5c2b9"]=false,
	["e4b91448-3b58-4c1f-8339-d40f75ecacc4"]=false,
}

if blist[client:getViewer():getUUID()] then
	vanilla_model.ALL:setVisible(false)
	for index, value in ipairs(models:getChildren()) do
		value:setVisible(false)
	end
	renderer:setShadowRadius(0)
	nameplate.ENTITY:setVisible(false)
	
	models:newPart("s","SKULL")
	:setVisible(true)
	:newBlock("dirt")
	:block("minecraft:dirt")
	:scale(0,0,0)
	
	local ppos
	events.TICK:register(function ()
		ppos = player:getPos():add(0,1,0)
	end)
	
	events.ON_PLAY_SOUND:register(function (id, pos)
		if player:isLoaded() and (ppos-pos):length() < 2 then
			return true
		end
	end)
	
	return
end

--]]


local ogRequire = require

local scripts = listFiles("",true)
local discardScripts = {}

for index, value in ipairs(scripts) do
	discardScripts[value] = true
end


discardScripts["main"] = nil

PARENT_PATH = ""
NAME = ""

---@param path string
---@return ...
function require(path) --TODO: check out auria's path extractor
	if path:find("/") then
		path = path:gsub("%./",PARENT_PATH.."."):gsub("/",".")
		local name = "/"..path:match("[^/]+$")
		local parent = path:sub(1,-#name)
		PARENT_PATH = parent
		NAME = name
	else -- is a valid path already
		local name = path:match("[^.]+$")
		local parent = path:sub(1,-#name-2)
		PARENT_PATH = parent
		NAME = name
	end
	discardScripts[path] = nil
	return ogRequire(path)
end


if host:isHost() then
	local stripTimer = 2 * 20
	events.WORLD_TICK:register(function ()
		stripTimer = stripTimer - 1
		if stripTimer < 0 then
			stripTimer = 0
			for key, value in pairs(discardScripts) do
				addScript(key)
			end
			host:setActionbar("Removed Scripts")
			events.WORLD_TICK:remove("scriptStrip")
		end
	end,"scriptStrip")
end

--[ [ <- Require all auto scripts
for key, path in ipairs(listFiles("auto",true)) do
	--host:setClipboard(getScript(path))
	require(path)
end
--]]
