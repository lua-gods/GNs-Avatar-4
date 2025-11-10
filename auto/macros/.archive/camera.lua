local keys = {
	right = keybinds:newKeybind("look right","key.keyboard.right"),
	left = keybinds:newKeybind("look left","key.keyboard.left"),
	up = keybinds:newKeybind("look up","key.keyboard.up"),
	down = keybinds:newKeybind("look down","key.keyboard.down"),
}

local SLEED = 10
local speed = 0

local lastTime = 0
function events.WORLD_RENDER()
	local time = client.getSystemTime()
	local delta = (time - lastTime) / 100
	lastTime = time
	
	local shift = vec(0,0)
	if keys.left:isPressed() then shift.x = shift.x - 1 end
	if keys.right:isPressed() then shift.x = shift.x + 1 end
	if keys.up:isPressed() then shift.y = shift.y - 1 end
	if keys.down:isPressed() then shift.y = shift.y + 1 end
	if (shift.x ~= 0) or (shift.y ~= 0) then
		speed = speed + delta * 0.1
	else
		speed = 1
	end
	host:setRot(player:getRot() + shift.yx * delta * SLEED * speed)
end