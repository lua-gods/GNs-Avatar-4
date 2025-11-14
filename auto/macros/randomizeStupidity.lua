---@type GNsAvatar.Macro

local blocks = client.getRegistry("minecraft:block")


return {
	name = ":catstare: Random Punch Sound",
	config = {
		{
			text = "Every punch sound will be replaced with a random sound effect",
			type = "LABEL",
		},
	},
	init=function (events, props)
		
		events.ON_PLAY_SOUND:register(function (id, pos, volume, pitch, loop, category, path)
			if id == "minecraft:entity.player.attack.nodamage" and path then
				sounds:playSound(world.newBlock(blocks[math.random(#id)]):getSounds()["break"], pos)
				return true
			end
		end)
	end
}
