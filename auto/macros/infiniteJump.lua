---@diagnostic disable: undefined-field

local jumpKey = keybinds:fromVanilla("key.jump")

---@type GNsAvatar.Macro
return {
	name = ":bloon_white: Infinite Jumps",
	config = {
		{
			type="LABEL",
			text="Unlimited Jumps"
		}
	},
	init=function (events, props)
		if host:isHost() then
			jumpKey:onPress(function ()
				local vel = vec(table.unpack(player:getNbt().Motion))
				vel = vel * 1.2
				vel.y = 0.42
				host:setVelocity(vel)
			end)
			
			events.ON_EXIT:register(function ()
				jumpKey.press = nil
			end)
		end
	end
}