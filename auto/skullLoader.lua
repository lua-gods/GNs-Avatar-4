for index, path in ipairs(listFiles("auto.skulls")) do
	require(path)
end