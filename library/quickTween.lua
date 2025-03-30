local tween = require"library.tween"
local api = {}

local DEFAULT = 50
local DURATION = 0.25

local function process(box,offset)
	tween.tweenFunction(box.Dimensions+offset.xyxy,box.Dimensions,DURATION,"outCirc",function (dim)
		box:setDimensions(dim)
	end)
end

---@param box GNUI.Box
---@param dist number?
function api.left(box, dist) dist=dist or DEFAULT process(box,vec(-dist,0)) end

---@param box GNUI.Box
---@param dist number?
function api.right(box, dist) dist=dist or DEFAULT process(box,vec(dist,0)) end

---@param box GNUI.Box
---@param dist number?
function api.up(box, dist) dist=dist or DEFAULT process(box,vec(0,-dist)) end

---@param box GNUI.Box
---@param dist number?
function api.down(box, dist) dist=dist or DEFAULT process(box,vec(0,dist)) end

---@param box GNUI.Box
---@param dist number?
function api.zoom(box, dist) dist=dist or DEFAULT
	tween.tweenFunction(box.Dimensions + vec(dist,dist,-dist,-dist),box.Dimensions,DURATION,"outCirc",function (dim)
		box:setDimensions(dim)
	end)
end

api.tween = tween.tweenFunction

return api