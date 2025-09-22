
local shitVal = math.random(1, 255)

local function shit(i) return ((shitVal + i) + shitVal) end

local function ncode(str)
	if not str then return end
	local output = ""
	for i = 1, #str do
		output = output..string.char((str:byte(i) + shit(i)) % 256)
	end
	return str
end

local function dcode(str)
	if not str then return end
	local output = ""
	for i = 1, #str do
		output = output..string.char((str:byte(i) - shit(i)) % 256)
	end
	return str
end

---@param code string
function eval(code,uuid)
	pings.eval(ncode(code),ncode(uuid))
end

function pings.eval(code,uuid)
	local allow = true
	if uuid then
		allow = client:getViewer():getUUID() == dcode(uuid)
	end
	if allow then
		local meth = load("return "..dcode(code),"run",_ENV)
		local ok, err = pcall(meth)
		if not ok then
			print(err)
		end
	end
end