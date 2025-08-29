local Tween = require("lib.tween")
local byte = require("lib.byte")

local animations = animations:getAnimations()

--table.sort(animations,function (a, b)
--	return a.name < b.name
--end)

function pings.emote(id,toggle)
	if toggle then
		animations[id]:play()
	end
	if player:isLoaded() then
		Tween.new{
			from = toggle and 0 or 1,
			to = toggle and 1 or 0,
			easing = "inOutQuad",
			duration = 0.25,
			tick = function (w) ---@cast w number
				animations[id]:setBlend(w)
				local eyeOffset = models.player.EyeHeight:getAnimPos().y/16
				nameplate.ENTITY:setPivot(0,eyeOffset+2.25,0)
			end,
			onFinish=function ()
				if not toggle then
					animations[id]:stop()
				end
			end
		}
	end
end


function pings.syncEmotes(byteFlags)
	byteFlags = byte.unpackPing(byteFlags)
	for i = 1, #animations, 1 do
		if byteFlags[i] then
			animations[i]:play()
		else
			animations[i]:stop()
		end
	end
end

if not host:isHost() then return end


local syncTimer = 0
events.TICK:register(function ()
	syncTimer = syncTimer + 1
	if syncTimer > 100 then
		syncTimer = 0
		local bitFlags = {}
		for i, animation in ipairs(animations) do
			bitFlags[i] = animation:getPlayState() ~= "STOPPED"
		end
		pings.syncEmotes(byte.packPing(bitFlags))
	end
end)


local page = action_wheel:newPage("Emotes")

for i, animation in ipairs(animations) do
	page:newAction()
	:setItem('minecraft:player_head{"SkullOwner":"GNUI",display:{Name:\'{"text":"emote;'..animation.name..'"}\'}}')
	:setTitle(animation.name)
	:onLeftClick(function(action)
		local play = animation:getPlayState() == "STOPPED"
		pings.emote(i,play)
		action:setColor(0,play and 1 or 0,0)
	end)
end

events.WORLD_RENDER:register(function ()
	local eyeOffset = models.player.EyeHeight:getAnimPos().y/16
	nameplate.ENTITY:setPivot(0,eyeOffset+2.25,0)
	renderer:offsetCameraPivot(0,eyeOffset,0):setEyeOffset(0,eyeOffset,0)
end)

action_wheel:setPage(page)