local hides = {
	models.disco,
	models.skull,
	models.playerHead,
	models.sunflower,
	models.sunglasses,
	models.lazer,
	models.info,
	models.fez
}

for key, value in pairs(hides) do
	value:setVisible(false)
end