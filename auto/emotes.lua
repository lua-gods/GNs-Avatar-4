

local animations = animations:getAnimations()

local page = action_wheel:newPage("Emotes")

for i, animation in ipairs(animations) do
	page:newAction():setItem('minecraft:player_head{"SkullOwner":"GNUI"}')
end

action_wheel:setPage(page)