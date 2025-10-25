# flags: host_only

local startTime = client.getSystemTime()
local isInRace = false
local lastPos

function events.entity_init()
	lastPos = player:getPos()
end

local function padNumber(num, length)
	local string = tostring(num)
	while #string < length do
		string = "0" .. string
	end
	return string
end

function events.render()
	--{"color":"green","text":"GO!!!"}
	local title = client.getTitle()
	title = title and parseJson(client.getTitle())
	if title and title.text and title.text == "GO!!!" and not isInRace then
		isInRace = true
		startTime = client.getSystemTime()
	end
	if not isInRace then return end
	local raceTime = math.clamp(client.getSystemTime() - startTime,0,3599999)
	local time = padNumber(raceTime % 1000,3)
	local time = padNumber(math.floor(raceTime / 1000) % 60,2) .. ":" .. time
	local time = padNumber(math.floor(raceTime / 60000),2) .. ":" .. time
	host:setActionbar(time)
	local playerPos = player:getPos()

	if raceTime > 10000 then
		if playerPos.x > -471 and playerPos.x < -453 then
			if (68.5 >= playerPos.z and 68.5 <= lastPos.z) or (68.5 >= lastPos.z and 68.5 <= playerPos.z) then
				isInRace = false
				sounds:playSound("minecraft:block.note_block.bell",player:getPos())
				host:setTitle(time):setTitleTimes(0,200,0)
			end
		end
	end
	lastPos = playerPos
end