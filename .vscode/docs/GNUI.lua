---@diagnostic disable: missing-fields, missing-return
--[────────────────────────────────────────-< GNUI >-────────────────────────────────────────]--

---@class GNUIAPI
local API = {
	box = {}, ---@type GNUI.BoxAPI
	sprite = {}, ---@type GNUI.QuadAPI
	screen = {}, ---@type GNUI.ScreenAPI
}

--[────────────────────────────────────────-< Box >-────────────────────────────────────────]--

---Represents a box on the screen.
---@class GNUI.BoxAPI
local BoxAPI = {}

---@return GNUI.Box
function BoxAPI.new() end


---@class GNUI.Box
---@
local Box = {}