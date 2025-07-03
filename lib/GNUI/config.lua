---@class GNUI.Config
local config = {
--[────────-< Dependencies >-────────]--
utils = require("./utils"),
event = require("../event"),


--[────────-< Debug >-────────]--
DEBUG_MODE = false, -- enable to view debug information about the boxes
DEBUG_SCALE = 2/client:getGuiScale(), -- the thickness of the lines for debug lines, in BBunits


--[────────-< Rendering >-────────]--
CLIPPING_MARGIN = 16, -- The gap between the parent element to its children.


--[────────-< Labeling >-────────]--
EVENT_NAME_DEBUG = "_c",
EVENT_NAME_INTERNAL = "__a",
}

return config