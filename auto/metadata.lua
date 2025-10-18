
renderer:setShadowRadius(0.4)
models:setPrimaryRenderType("CUTOUT") -- enables more shader compatibility

avatar:store("color","#5ac54f")
avatar:store("hair_color","#5ac54f")
avatar:store("horn_color","#2a2f4e")
avatar:store("eye_height",3)

avatar:store("shijiHats",{
	color1="#ff0000",
	color2="#00ff00",
	color3="#0000ff",
	color4="#ffffff",
})
--avatar:store("shijihats",{color1="#5ac54f"})
avatar:store("S255_HSV",math.random() < 0.5)

local zlib = require("lib.zlib")

avatar:store("decompress",function (data)
	return zlib.Deflate.Decompress(data)
end)
avatar:store("compress",function (data)
	return zlib.Deflate.Compress(data)
end)