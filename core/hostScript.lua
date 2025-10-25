if not host:isHost() then return end

local fileIdentifier = avatar:getName()..".lcl"


local hostScripts = {}

local function fnv1a(str,seed)
	local hash = seed or 2166136261
	for i = 1, #str do
		hash = bit32.bxor(hash, str:byte(i))
		hash = (hash * 16777619) % 2^32
	end
	return hash
end

---@type table<string,fun(path:string,content:string)>
local FLAGS = {
	host_only = function (path, content)
		addScript(path)
		addScript(path,content,"RUNTIME")
		hostScripts[#hostScripts+1] = {
			hash = fnv1a(content),
			path = path,
			content = content
		}
	end
}

for _, path in ipairs(listFiles("",true)) do
	local content = getScript(path)
	if content:find("^#") then
		local header = content:sub(1,(content:find("\n") or (#content+1)) -1)
		
		-- parse flags
		for flag in header:match("flags:([^\n]*)$"):gmatch("[^, ]+") do
			if FLAGS[flag] then
				FLAGS[flag](path, content)
			end
		end
	end
end


config:setName(fileIdentifier)
if host:isAvatarUploaded() then
	for index, value in ipairs(config:load("scripts")) do
		if value.hash == fnv1a(value.content) then
			addScript(value.path,value.content,"RUNTIME")
		end
	end
else
	config:save("hash",finalHash)
	config:save("scripts",hostScripts)
end





