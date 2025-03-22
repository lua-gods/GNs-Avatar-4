for _, path in pairs(listFiles("class")) do require(path) end
for _, path in pairs(listFiles("primitive")) do require(path) end
for _, path in pairs(listFiles("generic")) do require(path) end

if host:isHost() then
	for _, path in pairs(listFiles("host")) do require(path) end
end
