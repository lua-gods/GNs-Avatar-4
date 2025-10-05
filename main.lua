
--[ [ <- separate to enable

for _, path in ipairs(listFiles("core")) do
	require(path)
end

for _, path in ipairs(listFiles("auto")) do
	require(path)
end

--]]