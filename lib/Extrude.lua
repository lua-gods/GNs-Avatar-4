---@param tex Texture
---@return {x: number, y: number, wid: number, hei: number}[]
local function getTextureAreas(tex)
	local stripes = {}

	local pos
	local wid = 0

	-- Create stripes

	local d = tex:getDimensions()
	tex:applyFunc(nil, nil, d.x, d.y, function(col, x, y)
		-- Check if pixel is transparent

		if col[4] == 0 or (x == 0 and wid > 0) then
			if not pos then return end

			-- Push to stack

			if not stripes[y] then stripes[y] = {} end
			stripes[y][x] = {
				x = pos.x,
				y = pos.y,
				wid = wid,
				hei = 1,
			}

			-- Reset

			pos = nil
			wid = 0
		end

		-- Increment current group

		if col[4] == 0 then return end
		if not pos then pos = vec(x, y) end
		wid = wid + 1
	end)

	-- Merge stripes into areas

	for i = 1, d.y do
		local a, b = stripes[i - 1], stripes[i]
		if a and b then
			for k, v in pairs(a) do
				if b[k] and b[k].wid == v.wid then
					v.hei = v.hei + 1
					a[k] = nil
					b[k] = v
				end
			end
		end
	end

	-- Flatten areas

	local areas = {}
	for _, tbl in pairs(stripes) do
		for _, v in pairs(tbl) do
			table.insert(areas, v)
		end
	end

	return areas
end


---@param tex Texture
---@return ModelPart
local function extrudeTexture(tex)
	local model = models:newPart("")

	local areas = getTextureAreas(tex)
	local w, h = tex:getDimensions():unpack()

	for i, tbl in pairs(areas) do
		local x, y, wid, hei = tbl.x, tbl.y, tbl.wid, tbl.hei

		model:newSprite("north-" .. i)
			:pos(-x, -y, 0)
			:texture(tex, w, h)
			:uvPixels(x, y)
			:size(wid, hei)
			:region(wid, hei)

		model:newSprite("south-" .. i)
			:pos(-x, -y, 1)
			:rot(0, 180, 0)
			:texture(tex, w, h)
			:uvPixels(x, y)
			:size(-wid, hei)
			:region(wid, hei)

		model:newSprite("up-" .. i)
			:pos(-x, -y, 1)
			:rot(-90, -180, -180)
			:texture(tex, w, h)
			:uvPixels(x, y)
			:size(wid, 1)
			:region(wid, 1)

		model:newSprite("down-" .. i)
			:pos(-x, -y - hei, 0)
			:rot(-90, 0, 0)
			:texture(tex, w, h)
			:uvPixels(x, y + hei - 1)
			:size(wid, 1)
			:region(wid, 1)

		model:newSprite("east-" .. i)
			:pos(-x, -y, 1)
			:rot(0, -90, 0)
			:texture(tex, w, h)
			:uvPixels(x, y)
			:size(1, hei)
			:region(1, hei)

		model:newSprite("west-" .. i)
			:pos(-x - wid, -y, 0)
			:rot(0, 90, 0)
			:texture(tex, w, h)
			:uvPixels(x + wid - 1, y)
			:size(1, hei)
			:region(1, hei)
	end

	return model
end

local tex = textures:fromVanilla("sign", "textures/item/oak_sign.png")
local model = extrudeTexture(tex)

local skulls = require("Scripts.SkullAPI.SkullAPI")
function skulls.item_init(skull)
	local res = 16
	res = 1 / (res / 16)

	-- Left hand third person

	local mat = matrices.mat4()
		:translate(tex:getDimensions():mul(0.5, 1).xy_)
		:translate(0, -3, -7.5)
		:scale(1.1)
		:scale(res, res, 1)
		:rotate(45, 45, 0)

	-- Right hand third person

	-- local mat = matrices.mat4()
	-- 	:translate(textures["Textures.Miku"]:getDimensions():mul(0.5, 1).xy_)
	-- 	:translate(0, 0, -8)
	-- 	:scale(res, res, 1)
	-- 	:rotate(45, -45, 0)

	skull:setModel(model)
	skull:getModel():matrix(mat)
end

model:visible(false)
