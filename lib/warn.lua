
---@param message string
function warn(message)
	printJson(toJson{text="[Warning] "..message.."\n",color="yellow"})
end