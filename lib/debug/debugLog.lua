local utilsTable = require "lib.utils.utilsTable"
local hud = models:newPart("debugLog","HUD")
---@class debugLog
local debugLog = {}
local nextLine = 0

hud:newBlock("dirt"):block("dirt"):pos(-8,-8,-8)

function debugLog.clear()
	hud:removeTask()
	nextLine = 0
end

function debugLog.print(...)
	nextLine = nextLine + 1
	hud:newText("line"..nextLine)
	:setText(table.concat(utilsTable.forEach({...},tostring),"  "))
	:pos(0,-10 * nextLine)
	:outline(true)
end


return debugLog