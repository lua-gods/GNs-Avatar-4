local asyncPairs = require("lib.asyncPairs")



--[[ <- separate to enable
figuraMetatables.HostAPI.__index.isHost = function () return false end
--]]

--[[ TRIM OPERATORS, idk if this does anything
local operators = {
    [" = "] = "=",
   [" == "] = "==",
    [" + "] = "+",
   [" %- "] = "-",
    [" %* "] = "*",
    [" / "] = "/",
   [" %% "] = "%%",
   [" %^ "] = "^",
   [" ~= "] = "~=",
    [" < "] = "<",
    [" > "] = ">",
   [" <= "] = "<=",
   [" >= "] = ">=",
 [" %.%. "] = "..",
}

for path, content in pairs(getScripts()) do
	for match, to in pairs(operators) do
		content = content:gsub(match,to)
	end
	addScript(path,content)
end
--]]

IS_FIGURA = true


--[ [
local blist = {
	["4a7ff870-027e-43a0-a1a5-05f7c4d5c2b9"]=true,
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



avatar:store("kash",function ()
	return avatar:getRenderCount()
end)


local tableColors = {}

function printTblColor(table)
	local clr = tableColors[table] or ("#"..vectors.rgbToHex(math.random(),math.random(),math.random()))
	tableColors[table] = clr
	printJson(toJson{
		{text=""},
		{
			text = "[lua]",
			color = "blue",
		},
		{
			text=" GNUI",
		},
		{
			text = " : ",
			color = "blue",
		},
		{
			text = tostring(table),
			color = clr
		},
		{text = "\n"}
	})
end


--[ [ <- separate to enable
for key, path in ipairs(listFiles("auto",true)) do
	--host:setClipboard(getScript(path))
	require(path)
end
--]]
