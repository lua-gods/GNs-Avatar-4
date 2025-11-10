# flags: host_only
local Box = require("lib.GNUI.widget.box")
local Button = require("lib.GNUI.widget.button")
local TextField = require("lib.GNUI.widget.textField")
local Slider = require("lib.GNUI.widget.slider")
local Stack = require("lib.GNUI.widget.panes.stack")
local GNUI  = require("lib.GNUI.main")

local Window = require("lib.GNUI-desktop.widget.window")
local FileDialog = require("lib.GNUI-desktop.widget.fileDialog")

local PROXY = {
	["minecraft:egg"]		     = "minecraft:egg",
	["minecraft:snowball"]    = "minecraft:snowball",
	["minecraft:bow"]		     = "minecraft:arrow",
	["minecraft:trident"]	  = "minecraft:trident",
	["minecraft:tnt"]		     = "minecraft:tnt",
	["minecraft:fire_charge"] = "minecraft:fireball",
	["minecraft:armor_stand"] = "minecraft:armor_stand",
	["minecraft:oak_boat"]    = "minecraft:boat",
}

local BLOCKS = {}
for key, block in pairs(client.getRegistry("minecraft:block")) do
	BLOCKS[block] = true
end

---@type GNUI.App
return {
	name = "Arrow Rain",
	icon = "minecraft:dispenser",
	start = function ()
		local window = Window.new()
		
		local shoot = keybinds:fromVanilla("key.use")
		
		shoot.press = function ()return true end
		
		
		
		
		window:setTitle("S.H.I.T.T.E.R.")
		:setSize(100,76)
		local stack = Stack.new(window.Content)
		:setStackDirection("DOWN")
		:maxAnchor()
		
		Box.new(stack):setText("Amount")
		:setSize(0,10)
		local amountSlider = Slider.new(stack,{
			min=1,
			max=50,
			value=10,
			step=1,
			showNumber=true
		})
		:setSize(0,10)
		
		Box.new(stack):setText("Spread")
		:setSize(0,10)
		local spreadSlider = Slider.new(stack,{
			min=0,
			max=100,
			value=25,
			step=1,
			showNumber=true
		})
		:setSize(0,10)
		
		Box.new(stack):setText("Power")
		:setSize(0,10)
		local powerSlider = Slider.new(stack,{
			min=1,
			max=100,
			value=30,
			step=1,
			showNumber=true
		})
		:setSize(0,10)
		
		events.WORLD_TICK:register(function ()
			if shoot:isPressed() then
				host:swingArm()
				if player:isLoaded() then
					local item = player:getHeldItem()
					local id = item.id
					if id == "minecraft:air" then return end
					local proxy = PROXY[id] or id:match("([^.]+)_spawn_egg$")
					local power = powerSlider.value/10
					local spread = spreadSlider.value/50
					local amount = amountSlider.value
					if proxy then
						for i = 1, amount do
							local vel = player:getLookDir() * power + vec(math.random() - 0.5, math.random() - 0.5, math.random() - 0.5) * spread * power
							host:sendChatCommand(string.format("/summon %s ~ ~%s ~ {Fuse:100,life:1180,pickup:2,Motion:[%.02f,%.02f,%.02f],Owner:\"%s\",player:1b}", proxy, player:getEyeHeight(), vel.x, vel.y, vel.z, player:getUUID()))
						end
					elseif id == "minecraft:splash_potion" then
						local nbt = item:getTag()
						for i = 1, amount do
							local vel = player:getLookDir() * power + vec(math.random() - 0.5, math.random() - 0.5, math.random() - 0.5) * spread * power
							host:sendChatCommand(string.format("/summon minecraft:potion ~ ~%s ~ {Motion:[%.02f,%.02f,%.02f],Owner:\"%s\",CustomPotionEffects:[%s]}", player:getEyeHeight(), vel.x, vel.y, vel.z, player:getUUID(),toJson(nbt.CustomPotionEffects)))
						end
					elseif BLOCKS[id] then
						for i = 1, amount do
							local vel = player:getLookDir() * power + vec(math.random() - 0.5, math.random() - 0.5, math.random() - 0.5) * spread * power
							host:sendChatCommand(string.format("/summon falling_block ~ ~%s ~ {DropItem:0,Motion:[%.02f,%.02f,%.02f],BlockState:{Name:\"%s\"}}", player:getEyeHeight(), vel.x, vel.y, vel.z, id))
						end
					end
				end
			end
		end,window.id.."shitter")
		
		
		window.ON_CLOSE:register(function ()
			events.WORLD_TICK:remove(window.id.."shitter")
			shoot.press = nil
		end)
	end
}