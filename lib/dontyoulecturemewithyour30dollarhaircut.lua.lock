local soundNames = {}
local nameSounds = {}
local i = 0
for index, value in ipairs(sounds:getCustomSounds()) do
	if value:find("30%.") then
		i = i + 1
		table.insert(soundNames, value)
		nameSounds[value] = true
	end
end

local api = {}
local e = 0
function api.playRandom(pos)
	--e = (e + 1) % (i - 1)
	--e = math.floor(world.getTime()/50)
	e = 0
	e = (e + pos.x * 12.135 )% 1024
	e = (e + pos.y * 321.25 )% 1024
	e = (e + pos.z * 42.41  )% 1024
	e = (e - 1) % (i - 1) + 1
	e = math.floor(e)
	sounds[soundNames[e]]:pos(pos):play(pos):volume(0.6)
end

return api