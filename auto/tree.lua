-- fill ~-8 ~ ~-8 ~8 ~64 ~8 air
function send(...)
	host:sendChatCommand(table.concat({...},""):gsub("(%s[%s]+)","%s"))
end

---@param x 0
---@param y 0
---@param z 0
---@param block Minecraft.blockID
function set(x,y,z,block)
	send("setblock ~" .. x .. " ~" .. y .. " ~" .. z .. " " .. block)
end

send("fill ~-8 ~ ~-8 ~8 ~64 ~8 air")

local HEIGHT = math.random(10,20)

for i = 1, 10, 1 do
	
end