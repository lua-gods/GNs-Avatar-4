---@diagnostic disable: param-type-mismatch, inject-field
local cfg = require("./../config") ---@type GNUI.Config ---@type GNUI.Config
local event = cfg.event ---@type Event ---@type EventLibAPI
local utils = cfg.utils ---@type GNUI.UtilsAPI
local nineslice = require("./../nineslice") ---@type ModelPart.Nineslice

local debugTex = textures['gnui_debug_outline'] or 
textures:newTexture("gnui_debug_outline",6,6)
:fill(0,0,6,6,vec(0,0,0,1))
:fill(1,1,4,4,vec(1,1,1))
:fill(2,2,2,2,vec(0,0,0,1))



local nextID = 0

---@alias GNUI.TextBehavior string
---| "NONE" # Does not handle text
---| "WRAP"  # Wraps the text
---| "TRIM" # Truncates the text


---@alias GNUI.TextEffect string
---| "SHADOW"
---| "OUTLINE"
---| "NONE"


---@class GNUI.Box  # A box is a Rectangle that represents the building block of GNUI
--- ============================ CHILD MANAGEMENT ============================
---@field name string                      # An optional property used to get the element by a name.
---@field id integer                       # A unique integer for this element. (next-free based).
---@field visible boolean                  # `true` to see.
---@field parent GNUI.Box                  # the element's parents.
---@field children table<any,GNUI.Box>     # A list of the element's children.
---@field childIndex integer               # the element's place order on its parent.
---@field VISIBILITY_CHANGED Event         # on change of visibility.
---@field CHILDREN_ADDED Event             # when a child is added. first parameter is the child added.
---@field CHILDREN_REMOVED Event           # when a child is removed. first parameter is the child removed.
---@field CHILDREN_CHANGED Event           # when the children list is changed.
---@field PARENT_CHANGED table             # when the parent changes.
---@field isFreed boolean                  # true when the element is being freed.
---@field ON_FREE Event                    # when the element is wiped from history.
--- ============================ POSITIONING ============================
---@field dimensions Vector4               # Determins the offset of each side from the final output
---@field DIMENSIONS_CHANGED Event         # Triggered when the final box dimensions has changed.
---
---@field finalDimensions Vector4          # The final output dimensions with anchors applied. incredibly handy piece of data.
---@field z number                         # Offsets the box forward(+) or backward(-) if Z fighting is occuring, also affects its children.
---@field zSquish number                   # Multiplies how much the modelpart is positioned in the Z axis
---@field size Vector2                     # The size of the container.
---@field SIZE_CHANGED Event               # Triggered when the size of the final box dimensions is different from the last tick.
---
---@field anchor Vector4|Vector2           # Determins where to attach to its parent, (`0`-`1`, left-right, up-down)
---@field ANCHOR_CHANGED Event             # Triggered when the anchors applied to the box is changed.
---
---@field customMinimumSize Vector2        # Minimum size that the box will use.
---@field systemMinimumSize Vector2        # The minimum size that the box can use, set by the box itself.
---@field growDirection Vector2            # The direction in which the box grows into when is too small for the parent container.
---@field offsetChildren Vector2           # Shifts the children.
---
---@field scaleFactor number               # Scales the displayed sprites and its children based on the factor.
---@field accumScaleFactor number          # Scales the displayed sprites and its children based on the factor.
--- ============================ TEXT ============================
---@field text table                       # The text to be displayed.
---@field textOffset Vector2               # Specifies how much to offset the text from its final position.
---@field textEffect GNUI.TextEffect       # The effect to be applied to the text.
---@field fontScale number                 # The scale of the text.
---@field bakedText string[]               # The baked text to be displayed.
---@field bakedTextTable Minecraft.RawJSONText.Component[]  # The baked text to be displayed but in a table format.
---@field defaultTextColor string          # The color to be used when the text color is not specified.
---@field textAlign Vector2                # The alignment of the text within the box.
---@field textBehavior GNUI.TextBehavior   # Tells the text what to do when out of bounds.
---@field TEXT_CHANGED Event               # Triggered when the text is changed.
---@field textLengths integer[]            # The length of each separated text
---@field textPart ModelPart               # The `ModelPart` used to display text.
---@field textTasks TextTask[]             # A list of tasks to be executed when the text is changed.
---@field textLimitsHeight boolean         # If true, the text will clamp to the height of the box
--- ============================ RENDERING ============================
---@field modelPart ModelPart              # The `ModelPart` used to handle where to display debug features and the sprite.
---@field nineslice ModelPart.Nineslice              # the sprite that will be used for displaying textures.
---@field SPRITE_CHANGED Event             # Triggered when the sprite object set to this box has changed.
---@field color Vector3                    # The tint applied to the sprite.
--- ============================ INPUTS ============================
---@field cursorHovering boolean           # True when the cursor is hovering over the container, compared with the parent container.
---@field INPUT Event                      # Serves as the handler for all inputs within the boundaries of the container.
---@field canCaptureCursor boolean         # True when the box can capture the cursor. from its parent
---@field MOUSE_MOVED Event                # Triggered when the mouse position changes within this container.  `GNUI.InputEventMouseMotion` being the first agument, containing data about the event.
---@field MOUSE_PRESSENCE_CHANGED Event    # Triggered when the state of the mouse to box interaction changes, arguments include: (hovering: boolean, pressed: boolean)
---@field MOUSE_ENTERED Event              # Triggered once the cursor is hovering over the container
---@field MOUSE_EXITED Event               # Triggered once the cursor leaves the confinement of this container.
---@field isCursorHovering boolean         # `true` when the cursor is hovering over the container.
---
--- ============================ CLIPPING ============================
---@field clipOnParent boolean             # when `true`, the box will go invisible once touching outside the parent container.
---@field isClipping boolean               # `true` when the box is touching outside the parent's container.
---
--- ============================ MISC ============================
---@field cache table                      # Contains data to optimize the process.
---
--- ============================ CANVAS ============================
---@field Canvas GNUI.Canvas               # The canvas that the box is attached to.
---@field CANVAS_CHANGED Event             # Triggered when the canvas that the box is attached to has changed. first argument is the new, second is the old one.
local Box = {}
Box.__index = function (t,i)
	return rawget(t,i) or Box[i]
end
Box.__type = "GNUI.Box"
local root_container_count = 0
---Creates a new container.
---@param data GNUI.Box|{}|{pos:Vector2}?
---@return self
function Box.new(data)
	local model = models:newPart("GNUIBox"..nextID)
	local textModel = model:newPart("Text")
	nextID = nextID + 1
	models:removeChild(model)
	---@type GNUI.Box
	local new = setmetatable({
		-->====================[ Child Management ]====================<--
		id = nextID,
		visible = true,
		cache = {final_visible = true},
		VISIBILITY_CHANGED = event.new(),
		children = {},
		childIndex = 0,
		CHILDREN_ADDED = event.new(),
		CHILDREN_REMOVED = event.new(),
		CHILDREN_CHANGED = event.new(),
		PARENT_CHANGED = event.new(),
		isFreed = false,
		ON_FREE = event.new(),
		-->====================[ Positioning ]====================<--
		dimensions = vec(0,0,0,0) ,
		DIMENSIONS_CHANGED = event.new(),
		
		finalDimensions = vec(0,0,0,0),
		z = 1,
		zSquish = 1,
		size = vec(0,0),
		SIZE_CHANGED = event.new(),
		
		anchor = vec(0,0,0,0),
		ANCHOR_CHANGED = event.new(),
		
		systemMinimumSize = vec(0,0),
		growDirection = vec(1,1),
		offsetChildren = vec(0,0),
		
		scaleFactor = 1,
		accumScaleFactor = 1,
		
		-->====================[ Text ]====================<--
		textAlign = vec(0,0),
		textOffset = vec(0,0),
		fontScale = 1,
		textEffect = "NONE",
		defaultColor = "#FFFFFF",
		textHandling = true,
		textBehavior = "WRAP",
		TEXT_CHANGED = event.new(),
		textLimitsHeight = true,
		textPart = textModel,
		textLengths = {},
		textTasks = {},
		bakedText = {},
		-->====================[ Rendering ]====================<--
		modelPart = model,
		SPRITE_CHANGED = event.new(),
		
		-->====================[ Inputs ]====================<--
		INPUT = event.new(),
		INPUT_CHILDREN = event.new(),
		canCaptureCursor = true,
		MOUSE_MOVED = event.new(),
		MOUSE_PRESSENCE_CHANGED = event.new(),
		MOUSE_ENTERED = event.new(),
		MOUSE_EXITED = event.new(),
		isCursorHovering = false,
		
		-->====================[ Clipping ]====================<--
		clipOnParent = false,
		isClipping = false,
		-->====================[ Canvas ]====================<--
		CANVAS_CHANGED = event.new(),
	},Box)
	
	-->==========[ Internals ]==========<--
	if cfg.DEBUG_MODE then
		new.debugBox = nineslice.new():setModelpart(new.modelPart):setTexture(debugTex):setRenderType("EMISSIVE_SOLID"):setBorderThickness(3,3,3,3):setScale(cfg.DEBUG_SCALE):setExcludeMiddle(true):setDepthOffset(-0.1)
		new.MOUSE_PRESSENCE_CHANGED:register(function (hovering,pressed)
			if pressed then
				new.debugBox:setColor(0.5,0.5,0.1)
			else
				new.debugBox:setColor(1,1,hovering and 0.25 or 1)
			end
		end)
	end
	
	new.VISIBILITY_CHANGED:register(function (v)
	 new:update()
	end)
	
	new.ON_FREE:register(function ()
	 new.modelPart:remove()
	 new.isFreed = true
	end)

	local function orphan()
	 root_container_count = root_container_count + 1
	end
	orphan()
	new.PARENT_CHANGED:register(function (prnt)
	 if prnt then
		if prnt.__type:find("Canvas$") then
			new:setCanvas(prnt)
		else
			new:setCanvas(prnt.Canvas)
		end
	 else
		new:setCanvas(nil)
	 end
	 root_container_count = root_container_count - 1
	 if new.parent then 
		new.modelPart:moveTo(new.parent.modelPart)
	 else
		new.modelPart:getParent():removeChild(new.modelPart)
		orphan()
	 end
	 new:update()
	end)
	new:applyData(data)
	return new
end

---Applies the entire data table to the element
---@param data GNUI.Box|{}|{pos:Vector2}?
function Box:applyData(data)
	if data then
		for key, value in pairs(data) do
			local setter = "set"..key:gsub("^.",string.upper)
			if self[setter] then
				self[setter](self,value)
			else
				self[key] = value
			end
		end
	end
end

---Sets the visibility of the element and its children
---@param visible boolean
---@generic self
---@param self self
---@return self
function Box:setVisible(visible)
	---@cast self GNUI.Box
	if self.visible ~= visible then
		self.visible = visible
		self.VISIBILITY_CHANGED:invoke(visible)
	end
	return self
end

---Sets the color of the element.
---@param r number|Vector3|string
---@param g number?
---@param b number?
---@generic self
---@param self self
---@return self
function Box:setColor(r,g,b)
	---@cast self GNUI.Box
	if type(r) == "string" then
		r,g,b = vectors.hexToRGB(r):unpack()
	end
	self.color = utils.vec3(r,g,b)
	self:setTexture(self.nineslice)
	return self
end

function Box:_updateVisibility()
	if self.parent then
		self.cache.final_visible = self.parent.visible and self.visible
	else
		self.cache.final_visible = self.visible
	end
	return self
end

---Sets the name of the element. this is used to make it easier to find elements with getChild
---@param name string
---@generic self
---@param self self
---@return self
function Box:setName(name)
	---@cast self GNUI.Box
	self.name = name
	return self
end

---@return string
function Box:getName()
	return self.name
end

---Gets a child by username
---@param name string
---@return GNUI.Box
function Box:getChild(name)
	for _, child in pairs(self.children) do
		if child.name and child.name == name then
			return child
		end
	end
	return self
end

function Box:getChildByIndex(index)
	return self.children[index]
end

---@generic self
---@param self self
---@return self
function Box:updateChildrenOrder()
	---@cast self GNUI.Box
	for i, c in pairs(self.children) do
		c.childIndex = i
	end
	return self
end

---Adopts an element as its child.
---@param child GNUI.Box
---@param index integer?
---@generic self
---@param self self
---@return self
function Box:addChild(child,index)
	---@cast self GNUI.Box
	if not child then return self end
	if not type(child):find("^GNUI.") then
		error("invalid element given, recived: "..type(child),2)
	end
	if child.parent then return self end
	table.insert(self.children, index or #self.children+1, child)
	if child.parent ~= self then
		local old_parent = child.parent
		child.parent = self
		child.PARENT_CHANGED:invoke(self,old_parent)
		self.CHILDREN_ADDED:invoke(child)
	end
	self:updateChildrenIndex()
	return self
end

---Abandons the child into the street.
---@param child GNUI.Box
---@generic self
---@param self self
---@return self
function Box:removeChild(child)
	---@cast self GNUI.Box
	if child.parent == self then -- birth certificate check
		table.remove(self.children, child.childIndex)
		child.childIndex = 0
		if child.parent then
			local old_parent = child.parent
			child.parent = nil
			child.PARENT_CHANGED:invoke(nil,old_parent)
			self.CHILDREN_REMOVED:invoke(child)
		end
		self:updateChildrenIndex()
	else
		error("This container, is, not, the father", 2)
	end
	return self
end

function Box:setParent(parent)
	if self.parent then
		self.parent:removeChild(self)
	end
	if parent then
		parent:addChild(self)
	end
	return self
end

function Box:setChildren(children)
	for _, child in pairs(self.children) do
		self:removeChild(child)
	end
	for _, child in pairs(children) do
		self:addChild(child)
	end
end

---@return table<integer, GNUI.Box|GNUI.Box>
function Box:getChildren()
	return self.children
end

---@generic self
---@param self self
---@return self
function Box:updateChildrenIndex()
	---@cast self GNUI.Box
	for i = 1, #self.children, 1 do
		local child = self.children[i]
		child.childIndex = i
		if child.update then
			child:update()
		end
	end
	self.CHILDREN_CHANGED:invoke()
	return self
end

---Sets the Child Index of the element.
---@param i any
---@generic self
---@param self self
---@return self
function Box:setChildIndex(i)
	---@cast self GNUI.Box
	if self.parent then
		i = math.clamp(i, 1, #self.parent.children)
		table.remove(self.parent.children, self.childIndex)
		table.insert(self.parent.children, i, self)
		self.parent:updateChildrenIndex()
		self.parent:update()
	end
	return self
end

---Frees all the data of the element. all thats left to do is to forget it ever existed.
function Box:free()
	if self.parent then
		self.parent:removeChild(self)
	end
	self.ON_FREE:invoke()
end

---Kills all the children, go startwars mode.
function Box:purgeAllChildren()
	local children = {}
	for key, value in pairs(self:getChildren()) do
		children[key] = value
	end
	for key, value in pairs(children) do
		value:free()
	end
	self.children = {}
end

---Kills all the children in the given number range.
---@param ifrom any
---@param ito any
function Box:purgeChildrenRange(ifrom,ito)
	local children = {}
	for i = math.max(ifrom,1), math.min(ito, #self.children), 1 do
		children[i] = self.children[i]
	end
	for key, value in pairs(children) do
		value:free()
	end
end

---Sets the canvas of this box and its hierarchy.
---@package
---@param canvas GNUI.Canvas
---@generic self
---@param self self
---@return self
function Box:setCanvas(canvas)
	---@cast self self
	if self.Canvas ~= canvas then
	 local old = self.Canvas
	 self.Canvas = canvas
	 self.CANVAS_CHANGED:invoke(canvas,old)
	 for i = 1, #self.children, 1 do
		local child = self.children[i]
		child:setCanvas(canvas)
	 end
	end
	return self
end

---Sets the backdrop of the container.  
---Note: if the sprite given is already in use, it will overtake it.
---@generic self
---@param self self
---@param texture Texture|ModelPart.Nineslice|{}?
---@return self
function Box:setTexture(texture)
	---@cast self self
	
	local t = type(texture)
	if t == "Texture" then
		texture = nineslice.new({texture = texture})
	elseif t == "table" then
		texture = nineslice.new(texture)
	end
	
	if self.nineslice then
		self.nineslice:setModelpart()
	end
	if texture then
		self.nineslice = texture
		texture:setModelpart(self.modelPart)
		if self.color then
			texture:setColor(self.color)
		end
		self:updateSpriteTasks(true)
		self.SPRITE_CHANGED:invoke()
	end
	return self
end



---Sets the flag if this box should go invisible once touching outside of its parent.
---@generic self
---@param self self
---@param clip any
---@return self
function Box:setClipOnParent(clip)
	---@cast self GNUI.Box
	self.clipOnParent = clip
	self:update()
	return self
end
-->====================[ Dimensions ]====================<--

---Sets the dimensions of this container.  
---x,y is top left  
---z,w is bottom right  
--- if Z or W is missing, they will use X and Y instead
---@generic self
---@param self self
---@param x number|Vector4
---@param y number?
---@param w number?
---@param t number?
---@return self
function Box:setDimensions(x,y,w,t)
	---@cast self GNUI.Box
	local new = utils.vec4(x,y,w or x,t or y)
	self.dimensions = new
	self:update()
	return self
end

---Sets the position of this container.  
---check out `Box:setEnd()` for setting the position from the other end.
---@generic self
---@param self self
---@param x number|Vector2
---@param y number?
---@return self
function Box:setPos(x,y)
	---@cast self GNUI.Box
	local new = utils.vec2(x or 0,y or 0)
	local size = self.dimensions.zw - self.dimensions.xy
	self.dimensions = vec(new.x,new.y,new.x + size.x,new.y + size.y)
	self:update()
	return self
end


---Sets the position of this container.  
---check out `Box:setPos()` for setting the position from the other end.
---@generic self
---@param self self
---@param x number|Vector2
---@param y number?
---@return self
function Box:setEnd(x,y)
	---@cast self GNUI.Box
	local new = utils.vec2(x or 0,y or 0)
	local size = self.dimensions.zw - self.dimensions.xy
	self.dimensions = vec(new.z - size.x,new.w - size.y,new.z,new.w)
	self:update()
	return self
end



---Sets the Size of this container.
---@generic self
---@param x number|Vector2
---@param y number?
---@param self self
---@return self
function Box:setSize(x,y)
	---@cast self GNUI.Box
	local size = utils.vec2(x or 0,y or 0)
	self.dimensions.zw = self.dimensions.xy + size
	self:update()
	return self
end

---Gets the Size of this container.
---@return Vector2
function Box:getSize()
---@diagnostic disable-next-line: return-type-mismatch
	return self.finalDimensions.zw - self.finalDimensions.xy
end


---Checks if the given position is inside the container, in local BBunits of this box with dimension offset considered.
---@param x number|Vector2
---@param y number?
---@return boolean
function Box:isPosInside(x,y)
	---@cast self GNUI.Box
	local pos = utils.vec2(x,y)
	return (
		 pos.x > self.finalDimensions.x / self.scaleFactor
	 and pos.y > self.finalDimensions.y / self.scaleFactor
	 and pos.x < self.finalDimensions.z / self.scaleFactor 
	 and pos.y < self.finalDimensions.w / self.scaleFactor)
end

---Multiplies the offset from its parent container, useful for making the future elements go behind the parent by setting this value to lower than 0.
---@param mul number
---@generic self
---@param self self
---@return self
function Box:setZMul(mul)
	---@cast self GNUI.Box
	self.z = mul
	self:update()
	return self
end

---If this box should be able to capture the cursor from its parent if obstructed.
---@param capture boolean
---@generic self
---@param self self
---@return self
function Box:setCanCaptureCursor(capture)
	---@cast self GNUI.Box
	self.canCaptureCursor = capture
	return self
end

---Sets the UI scale of its children, while still mentaining their original anchors and positions.
---@param factor number?
---@generic self
---@param self self
---@return self
function Box:setScaleFactor(factor)
	---@cast self GNUI.Box
	self.scaleFactor = factor or 1
	self:update()
	return self
end


---Sets the top anchor.  
--- 0 = top part of the box is fully anchored to the top of its parent  
--- 1 = top part of the box is fully anchored to the bottom of its parent
---@param units number?
---@generic self
---@param self self
---@return self
function Box:setAnchorTop(units)
	---@cast self GNUI.Box
	self.anchor.y = units or 0
	self:update()
	return self
end

---Sets the left anchor.  
--- 0 = left part of the box is fully anchored to the left of its parent  
--- 1 = left part of the box is fully anchored to the right of its parent
---@param units number?
---@generic self
---@param self self
---@return self
function Box:setAnchorLeft(units)
	---@cast self GNUI.Box
	self.anchor.x = units or 0
	self:update()
	return self
end

---Sets the down anchor.  
--- 0 = bottom part of the box is fully anchored to the top of its parent  
--- 1 = bottom part of the box is fully anchored to the bottom of its parent
---@param units number?
---@generic self
---@param self self
---@return self
function Box:setAnchorDown(units)
	---@cast self GNUI.Box
	self.anchor.z = units or 0
	self:update()
	return self
end

---Sets the right anchor.  
--- 0 = right part of the box is fully anchored to the left of its parent  
--- 1 = right part of the box is fully anchored to the right of its parent  
---@param units number?
---@generic self
---@param self self
---@return self
function Box:setAnchorRight(units)
	---@cast self GNUI.Box
	self.anchor.w = units or 0
	self:update()
	return self
end

---Sets the anchor for all sides.  
--- x 0 <-> 1 = left <-> right  
--- y 0 <-> 1 = top <-> bottom  
---if right and bottom are not given, they will use left and top instead.
---@param left number|Vector4|Vector2
---@param top number|Vector2?
---@param right number?
---@param bottom number?
---@generic self
---@param self self
---@return self
function Box:setAnchor(left,top,right,bottom)
	---@cast self GNUI.Box
	local l = type(left) == "Vector2"
	self.anchor = utils.vec4(l and left.x or left,top or l and left.y,right or l and left.x or left,bottom or l and left.y or left)
	self:update()
	return self
end

---Sets the anchor for all sides. to cover the whole parent box.
---@generic self
---@param self self
---@return self
function Box:setAnchorMax()
	---@cast self GNUI.Box
	self.anchor = vec(0,0,1,1)
	self:update()
	return self
end

--The proper way to set if the cursor is hovering, this will tell the box that it has changed after setting its value
---@param toggle boolean
---@generic self
---@param self self
---@return self
function Box:setIsCursorHovering(toggle)
	---@cast self GNUI.Box
	if self.isCursorHovering ~= toggle then
	 self.isCursorHovering = toggle
	 self.MOUSE_PRESSENCE_CHANGED:invoke(toggle)
	 if toggle then
		self.MOUSE_ENTERED:invoke()
	 else
		self.MOUSE_EXITED:invoke()
	 end
	end
	return self
end

--Sets the minimum size of the container. resets to none if no arguments is given
---@param x number|Vector2
---@param y number?
---@generic self
---@param self self
---@return self
function Box:setCustomMinimumSize(x,y)
	---@cast self GNUI.Box
	if (x and y) then
	 local value = utils.vec2(x,y)
	 if value.x == 0 and value.y == 0 then
		self.customMinimumSize = nil
	 else
		self.customMinimumSize = value
	 end
	else
	 self.customMinimumSize = nil
	end
	self.cache.final_minimum_size_changed = true
	self:update()
	return self
end

-- This API is only made for libraries, use `Container:setCustomMinimumSize()` instead
--Sets the minimum size of the container.  
--* this does not make the box update. `Container:update()` still needs to be called.
---@param x number|Vector2
---@param y number?
---@generic self
---@param self self
---@return self
function Box:setSystemMinimumSize(x,y)
	---@cast self GNUI.Box
	if (x and y) then
	 local value = utils.vec2(x,y)
	 self.systemMinimumSize = value
	else
	 self.systemMinimumSize = vec(0,0)
	end
	self.cache.final_minimum_size_changed = true
	self:update()
	return self
end

--- x -1 <-> 1 = left <-> right  
--- y -1 <-> 1 = top <-> bottom  
--Sets the grow direction of the container
---@param x number|Vector2
---@param y number?
---@generic self
---@param self self
---@return self
function Box:setGrowDirection(x,y)
	---@cast self GNUI.Box
	self.cache.final_minimum_size_changed = true
	self.growDirection = utils.vec2(x or 0,y or 0)
	self:update()
	return self
end

---Sets the shift of the children, useful for scrollbars.
---@param x number|Vector2
---@param y number?
---@generic self
---@param self self
---@return self
function Box:setChildrenOffset(x,y)
	---@cast self GNUI.Box
	self.offsetChildren = utils.vec2(x or 0,y or 0)
	self.cache.final_minimum_size_changed = true
	self:update()

	return self
end

---Gets the minimum size of the container.
function Box:getMinimumSize()
	local smallest = vec(0,0)
	if self.customMinimumSize then
	 smallest = self.customMinimumSize
	end
	if self.systemMinimumSize then
	 smallest.x = math.max(smallest.x,self.systemMinimumSize.x)
	 smallest.y = math.max(smallest.y,self.systemMinimumSize.y)
	end
	
	self.cache.final_minimum_size = smallest
	return smallest
end

--- Converts a point from BBunits to UV units.
---@param x number|Vector2
---@param y number?
---@return Vector2
function Box:XYtoUV(x,y)
	local pos = utils.vec2(x,y)
	return vec(
	 math.map(pos.x,self.dimensions.x,self.dimensions.z,0,1),
	 math.map(pos.y,self.dimensions.y,self.dimensions.w,0,1)
	)
end

--- Converts a point from UV units to BB units.
---@param x number|Vector2
---@param y number?
---@return Vector2
function Box:UVtoXY(x,y)
	local pos = utils.vec2(x,y)
	return vec(
	 math.map(pos.x,0,1,self.dimensions.x,self.dimensions.z),
	 math.map(pos.y,0,1,self.dimensions.y,self.dimensions.w)
	)
end

---returns the global position of the given local position.
---@param x number|Vector2
---@param y number?
---@return Vector2
function Box:toGlobal(x,y)
	local pos = utils.vec2(x,y)
	local parent = self
	local i = 0
	while parent do
	 i = i + 1
	 if i > 100 then break end
	 pos = pos + parent.finalDimensions.xy/parent.scaleFactor
	 parent = parent.parent
	end
	return pos
end 


---returns the local position of the given global position.
---@param x number|Vector2
---@param y number?
---@return Vector2
function Box:toLocal(x,y)
	local pos = utils.vec2(x,y)
	local parent = self
	local i = 0
	while parent do
	 i = i + 1
	 if i > 100 then break end
	 pos = pos - parent.finalDimensions.xy
	 parent = parent.parent
	end
	return pos
end

---Flags this Container to be updated.
---@generic self
---@param self self
---@return self
function Box:update()
	---@cast self GNUI.Box
	self.UpdateQueue = true
	return self
end


--- Calls the events that are most likely used by themes. ex. `MOUSE_PRESSENCE_CHANGED`
---@generic self
---@param self self
---@return self
function Box:updateTheming()
	---@cast self GNUI.Box
	self.MOUSE_PRESSENCE_CHANGED:invoke(self.isCursorHovering)
	return self
end


function Box:_update()
	local scale = (self.parent and self.parent.accumScaleFactor or 1) * self.scaleFactor
	local shift = vec(0,0)
	if self.accumScaleFactor ~= scale then
		self.accumScaleFactor = scale
		self:rebuildTextTasks()
	end
	self.dimensions:scale(scale)
	-- generate the containment rect
	local cr = self.dimensions:copy():add(self.parent and self.parent.offsetChildren.xyxy * self.accumScaleFactor or vec(0,0,0,0))
	-- adjust based on parent if this has one
	local clipping = false
	local size
	if self.parent and self.parent.finalDimensions then 
	 local parent_scale = 1 / self.parent.scaleFactor
	 local pc = self.parent.finalDimensions - self.parent.finalDimensions.xyxy
	 local as = vec(
		math.lerp(pc.x,pc.z,self.anchor.x),
		math.lerp(pc.y,pc.w,self.anchor.y),
		math.lerp(pc.x,pc.z,self.anchor.z),
		math.lerp(pc.y,pc.w,self.anchor.w)
	 ) * parent_scale * self.scaleFactor
	 cr.x = cr.x + as.x
	 cr.y = cr.y + as.y
	 cr.z = cr.z + as.z
	 cr.w = cr.w + as.w
	 size = vec(
		math.floor((cr.z - cr.x) * 100 + 0.5) / 100,
		math.floor((cr.w - cr.y) * 100 + 0.5) / 100
	 )
	 if self.customMinimumSize or (self.systemMinimumSize.x ~= 0 or self.systemMinimumSize.y ~= 0) then
		local fms = vec(0,0)
		
		if self.cache.final_minimum_size_changed or not self.cache.final_minimum_size then
			self.cache.final_minimum_size_changed = false
			if self.customMinimumSize then
			 fms.x = math.max(fms.x,self.customMinimumSize.x)
			 fms.y = math.max(fms.y,self.customMinimumSize.y)
			end
			if self.systemMinimumSize then
			 fms.x = math.max(fms.x,self.systemMinimumSize.x)
			 fms.y = math.max(fms.y,self.systemMinimumSize.y)
			end
			shift = (fms - size) * -(self.growDirection  * -0.5 + 0.5)
			self.cache.final_minimum_size = fms
			self.cache.final_minimum_size_shift = shift
		else
			fms = self.cache.final_minimum_size
			shift = self.cache.final_minimum_size_shift
		end
		cr.z = math.max(cr.z,cr.x + fms.x)
		cr.w = math.max(cr.w,cr.y + fms.y)
		
		cr:add(shift.x,shift.y,shift.x,shift.y)
		
		size = vec(
		math.floor((cr.z - cr.x) * 100 + 0.5) / 100,
		math.floor((cr.w - cr.y) * 100 + 0.5) / 100
		)
	 end
	 
	 -- calculate clipping
	 if self.clipOnParent then
		clipping = 
			pc.x > cr.x
		or pc.y > cr.y
		or pc.z < cr.z
		or pc.w < cr.w
	 end
	else
	 size = vec(
		math.floor((cr.z - cr.x) * 100 + 0.5) / 100,
		math.floor((cr.w - cr.y) * 100 + 0.5) / 100
	 )
	end

	self.cache.size = size
	self.finalDimensions = cr
	self.dimensions:scale(1 / scale)
	self.size = size
	if not self.cache.last_size or self.cache.last_size ~= size then
	 self.SIZE_CHANGED:invoke(size,self.cache.last_size)
	 self.cache.last_size = size
	 self.cache.size_changed = true
	else
	 self.cache.size_changed = false
	end
	self.DIMENSIONS_CHANGED:invoke()

	local visible = self.visible
	if self.clipOnParent and visible then
	 if clipping then
		visible = false
	 end
	end
	self.cache.final_visible = visible
	if self.cache.final_visible ~= self.cache.was_visible then 
	 self.cache.was_visible = self.cache.final_visible
	 self.modelPart:setVisible(visible)
	 if visible then
		self:updateSpriteTasks(true)
	 end
	end
	if visible then
	 self:updateSpriteTasks()
	end
	if self.text then
		self:repositionText()
	 end
end


function Box:updateSpriteTasks(forced_resize_sprites)
	local containment_rect = self.finalDimensions
	local unscaleSelf = 1 / self.scaleFactor
	local childCount = self.parent and (#self.parent.children) or 1
	self.zSquish = (self.parent and self.parent.zSquish or 1) * (1 / childCount)
	local child_weight = self.childIndex / childCount
	if self.cache.final_visible then
	 self.modelPart
		:setPos(
			-containment_rect.x * unscaleSelf,
			-containment_rect.y * unscaleSelf,
			-(child_weight) * cfg.CLIPPING_MARGIN * self.z * self.zSquish
		):setVisible(true)
		if self.nineslice and (self.cache.size_changed or forced_resize_sprites) then
			self.nineslice
			 :setSize(
				(containment_rect.z - containment_rect.x) * unscaleSelf,
				(containment_rect.w - containment_rect.y) * unscaleSelf
			 ):setScale(self.accumScaleFactor)
		end
	end
---@diagnostic disable-next-line: undefined-field
	 if cfg.DEBUG_MODE and self.debugBox then
	 ---@diagnostic disable-next-line: undefined-field
	 self.debugBox
	 :setPos(
		0,
		0,
		-(((self.childIndex * self.z) / (self.parent and (#self.parent.children) or 1) * 0.8) * cfg.CLIPPING_MARGIN))
		if self.cache.size_changed then
			---@diagnostic disable-next-line: undefined-field
				self.debugBox:setSize(
					(containment_rect.z - containment_rect.x) * unscaleSelf,
					(containment_rect.w - containment_rect.y) * unscaleSelf)
		end
	end
end

--- Forces an update of the box.
---@generic self
---@param self self
---@return self
function Box:forceUpdate()
	---@cast self GNUI.Box
	self:_update()
	self:_propagateUpdateToChildren()
	return self
end

function Box:_propagateUpdateToChildren(force_all)
	if self.UpdateQueue or force_all then
	 force_all = true -- when a box updates, make sure the children updates.
	 self.UpdateQueue = false
	 self:forceUpdate()
	end
	for key, value in pairs(self.children) do
	 if value.isFreed then
		self:removeChild(value)
	 else
		if value then
			value:_propagateUpdateToChildren(force_all)
		end
	 end
	end
end

-->========================================[ Text ]=========================================<--

---@alias Minecraft.RawJSONText.Type string
---| "text"
---| "translatable"
---| "score"
---| "selector"
---| "keybind"
---| "nbt"


---@alias Minecraft.RawJSONText.Color string
---| "black"        # changes the color to #000000
---| "dark_blue"    # changes the color to #0000AA
---| "dark_green"   # changes the color to #00AA00
---| "dark_aqua"    # changes the color to #00AAAA
---| "dark_red"     # changes the color to #AA0000
---| "dark_purple"  # changes the color to #AA00AA
---| "gold"         # changes the color to #FFAA00
---| "gray"         # changes the color to #AAAAAA
---| "dark_gray"    # changes the color to #555555
---| "blue"         # changes the color to #5555FF
---| "green"        # changes the color to #55FF55
---| "aqua"         # changes the color to #55FFFF
---| "red"          # changes the color to #FF5555
---| "light_purple" # changes the color to #FF55FF
---| "yellow"       # changes the color to #FFFF55
---| "white"        # changes the color to #FFFFFF


---@class Minecraft.RawJSONText.Component
---@field type Minecraft.RawJSONText.Type? # Optional. Specifies the content type.
---
---@field translate string? # A translation identifier, corresponding to the identifiers found in loaded language files. Displayed as the corresponding text in the player's selected language. If no corresponding translation can be found, the identifier itself is used as the translated text.
---@field fallback string? # Optional. If no corresponding translation can be found, this is used as the translated text. Ignored if  translate is not present.
---@field with Minecraft.RawJSONText.Component[]? #Optional. A list of raw JSON text components to be inserted into slots in the translation text. Ignored if  translate is not present.
---
---@field score Minecraft.RawJSONText.Component.Score? #Displays a score holder's current score in an objective. Displays nothing if the given score holder or the given objective do not exist, or if the score holder is not tracked in the objective. 
---
---@field selector string?
---@field separator Minecraft.RawJSONText.Component?
---
---@field keybind Minecraft.keybind? #  A keybind identifier, to be displayed as the name of the button that is currently bound to that action. For example, `{"keybind": "key.inventory"}` displays "e" if the player is using the default control scheme.
---
---@field text string? # A string containing plain text to display directly.
---@field extra Minecraft.RawJSONText.Component|Minecraft.RawJSONText.Component[]? # A list of additional raw JSON text components to be displayed after this one. 
---@field color Minecraft.RawJSONText.Color|string? # Optional. Changes the color to render the content in the text component object and its child objects. If not present, the parent color will be used instead. The color is specified as a color code or as a color name.
---@field font string? # Optional. The resource location of the font for this component in the resource pack within assets/<namespace>/font. Defaults to "minecraft:default".
---@field bold boolean? # Optional. Whether to render the content in bold.
---@field italic boolean? # Optional. Whether to render the content in italics. Note that text that is italicized by default, such as custom item names, can be unitalicized by setting this to false.
---@field underlined boolean? # Optional. Whether to underline the content.
---@field strikethrough boolean? # Optional. Whether to strikethrough the content.
---@field obfuscated boolean? # Optional. Whether to render the content obfuscated.
---@field insertion string? # Optional. When the text is shift-clicked by a player, this string is inserted in their chat input. It does not overwrite any existing text the player was writing. This only works in chat messages.
---@field clickEvent Minecraft.RawJSONText.ClickEvent?  # Optional. Allows for events to occur when the player clicks on text. Only work in chat messages and written books, unless specified otherwise.
---@field hoverEvent Minecraft.RawJSONText.HoverEvent? # Optional. Allows for a tooltip to be displayed when the player hovers their mouse over text.
---
---@field source Minecraft.RawJSONText.Component.Source? # Optional. Allowed values are "block", "entity", and "storage", corresponding to the source of the NBT data.
---@field nbt string? # The NBT path used for looking up NBT values from an entity, block entity, or storage. Requires one of  block,  entity, or  storage. Having more than one is allowed, but only one is used.[note 3]
---@field interpret boolean? # Optional, defaults to false. If true, the game attempts to parse the text of each NBT value as a raw JSON text component. Ignored if  nbt is not present.
---@field block string? # A string specifying the coordinates of the block entity from which the NBT value is obtained. The coordinates can be absolute, relative, or local. Ignored if  nbt is not present.
---@field entity string? # A string specifying the target selector for the entity or entities from which the NBT value is obtained. Ignored if  nbt is not present.
---@field storage string? # A string specifying the resource location of the command storage from which the NBT value is obtained. Ignored if  nbt is not present.

---@class Minecraft.RawJSONText.Component.Score
---@field name string # The name of the score holder whose score should be displayed. This can be a selector like @p or an explicit name. If the text is a selector, the selector must be guaranteed to never select more than one entity, possibly by adding limit=1. If the text is "*", it shows the reader's own score (for example, `/tellraw @a {"score":{"name":"*","objective":"obj"}}` shows every online player their own score in the "obj" objective).[
---@field objective string # The internal name of the objective to display the player's score in.

---@class Minecraft.RawJSONText.ClickEvent
---@field action Minecraft.RawJSONText.ClickEvent.Action # The action to perform when clicked.
---@field value string

---@alias Minecraft.RawJSONText.Component.Source string
---| "block"
---| "entity"
---| "storage"

---@alias Minecraft.RawJSONText.ClickEvent.Action string
---| "open_url" # Opens value as a URL in the user's default web browser.
---| "open_file" # Opens the file at value on the user's computer. This is used in messages automatically generated by the game (e.g., on taking a screenshot) and cannot be used by players for security reasons.
---| "run_command" # Works in signs, but only on the root text component, not on any children. Activated by using the sign. In chat and written books, this has  value entered in chat as though the player typed it themselves and pressed enter. However, this can only be used to run commands that do not send chat messages directly (like /say, /tell, and/teammsg). Since they are being run from chat, commands must be prefixed with the usual "/" slash, and player must have the required permissions. In signs, the command is run by the server at the sign's location, with the player who used the sign as the command executor (that is, the entity selected by @s). Since they are run by the server, sign commands have the same permission level as a command block instead of using the player's permission level, are not restricted by chat length limits, and do not need to be prefixed with a "/" slash.
---| "suggest_command" # Opens chat and fills in  value. If a chat message was already being composed, it is overwritten. This does not work in books.
---| "change_page" # Can only be used in written books. Changes to page  value if that page exists.
---| "copy_to_clipboard" # Copies  value to the clipboard.

---@class Minecraft.RawJSONText.HoverEvent
---@field action Minecraft.RawJSONText.HoverEvent.Action # The type of tooltip to show
---@field contents Minecraft.RawJSONText.HoverEvent.Content.ShowEntity|Minecraft.RawJSONText.HoverEvent.Content.ShowItem|Minecraft.RawJSONText.Component # The formatting of this tag varies depending on the action

---@class Minecraft.RawJSONText.HoverEvent.Content.ShowEntity
---@field id {[1]:integer,[2]:integer,[3]:integer,[4]:integer}|string # The item's resource location. Defaults to minecraft:air if invalid.
---@field name string? # Optional. Hidden if not present. A raw JSON text that is displayed as the name of the entity.
---@field type Minecraft.entityID # A string containing the type of the entity, as a resource location. Defaults to minecraft:pig if invalid.

---@class Minecraft.RawJSONText.HoverEvent.Content.ShowItem
---@field id Minecraft.itemID # The item's resource location. Defaults to minecraft:air if invalid.
---@field count integer? # Optional. Size of the item stack. This typically does not change the content tooltip.
---@field components? table # Optional. Additional information about the item. 

---@alias Minecraft.RawJSONText.HoverEvent.Action string
---| "show_text" # Another raw JSON text component. Can be any valid text component type: string, array, or object. Note that  clickEvent and  hoverEvent do not function within the tooltip.
---| "show_item" # The item stack whose tooltip that should be displayed. 
---| "show_entity": The entity whose tooltip should be displayed. 

local function clone(tbl)
	local output = {}
	for k,v in pairs(tbl) do
		output[k] = v
	end
	return output
end

local function isTableTheSame(a,b)
	if #a ~= #b then
		return false
	end
	for key, value in pairs(a) do
		if value ~= b[key] then
			return false
		end
	end
	for key, value in pairs(b) do
		if value ~= a[key] then
			return false
		end
	end
	return true
end

--- flattens all nested components into one big array.
---@param input Minecraft.RawJSONText.Component|Minecraft.RawJSONText.Component[]
local function flattenJsonText(input)
	input = clone(input) ---@type Minecraft.RawJSONText.Component|Minecraft.RawJSONText.Component[]
	if input[1] then -- is an array
		for i = 1, #input, 1 do
			input[i] = flattenJsonText(input[i])
		end
	else -- is a component
		if input.extra then
			local extra ---@type Minecraft.RawJSONText.Component[]
			if input.extra[1] then -- is an array
				extra = input.extra
			else extra = {input.extra}
			end
			local output = {input}
			input.extra = nil
			for i = 1, #extra, 1 do
				local ref = extra[i] -- as a reference data
				local out = clone(ref) -- as a modified data
				for key, value in pairs(input) do -- merge extra tags into children components
					out[key] = ref[key] or value
				end
				
				out = flattenJsonText(out) -- flattens nested extra tags
				
				-- merges the tables into one array
				if out[1] then -- is an array
					for j = 1, #out, 1 do
						output[#output+1] = out[j]
					end
				else output[#output+1] = out end
			end
			input = output
		end
	end
	if input[1] then -- is an array
		--- optimize raw json text components by removing empty ones
		local i = 0
		while i < #input do
			i = i + 1
			local c = input[i]
			local r = false
			if c.text and (c.text == "") then r = true end -- empty component
			-- merge the two components if the same
			if not r and input[i-1] and input[i-1].text and c.text then -- merge same components
				local c2 = input[i-1]
				local at = c.text
				local bt = c2.text
				c.text = nil
				c2.text = nil
				if isTableTheSame(c,c2) then
					r = true
					c2.text = bt .. at
				else
					c.text = at
					c2.text = bt
				end
			end
			
			if r then -- remove
				table.remove(input,i)
				i = i - 1
			end
		end
	end
	return input
end

---Splits all components by each word
---@param input Minecraft.RawJSONText.Component[]
local function fractureComponents(input,pattern)
	local output = {}
	if not input[1] then input = {input} end
	for i = 1, #input, 1 do
		local c = input[i]
		for word in string.gmatch(c.text or "",pattern) do
			local cc = clone(c)
			cc.text = word
			output[#output+1] = cc
		end
	end
	return output
end

---@package
---@generic self
---@param self self
---@return self
function Box:rebuildTextTasks()
	---@cast self GNUI.Box
	local part = self.textPart
	local fs = self.fontScale*self.accumScaleFactor
	self.textPart:removeTask()
	local tasks = {}
	for i = 1, #self.bakedText, 1 do
		tasks[i] = part:newText(i):setText(self.bakedText[i]):setScale(fs,fs,fs)
	end
	if self.textEffect == "SHADOW" then
		for i = 1, #self.bakedText, 1 do
			tasks[i]:setShadow(true)
		end
	end
	if self.textEffect == "OUTLINE" then
		for i = 1, #self.bakedText, 1 do
			tasks[i]:setOutline(true)
		end
	end
	self.textTasks = tasks
	self:repositionText()
	return self
end

function Box:repositionText()
	local tasks = self.textTasks
	local textLenghts = self.textLengths
	local pos = vec(0,0)
	local size = self.size
	local o = self.textOffset*self.accumScaleFactor
	local scale = self.fontScale*self.accumScaleFactor
	local lineWidth = {}
	local poses = {}
	
	local forceNextLine = false
	for i = 1, #self.bakedText, 1 do
		local len = textLenghts[i]
		if (self.textBehavior == "WRAP") or forceNextLine  then
			if (pos.x > size.x-len*scale) or forceNextLine then
				lineWidth[#lineWidth+1] = {width=pos.x,poses=poses}
				forceNextLine = false
				poses = {}
				pos.x = 0
				pos.y = pos.y - 10 * scale
			end
		end
		if self.bakedText[i]:find("\\n") then
			forceNextLine = true
		end
		poses[#poses+1] = pos:copy()
		pos.x = pos.x + len*scale
	end
	lineWidth[#lineWidth+1] = {width=pos.x,poses=poses}
	
	local align = self.textAlign
	local j = 0
	for l = 1, #lineWidth, 1 do
		local line = lineWidth[l]
		for i = 1, #line.poses, 1 do
			j = j + 1
			local p = line.poses[i]
			tasks[j]:setPos(
			-(size.x*align.x+p.x-line.width*align.x)-o.x,
			-((size.y-#lineWidth*10*scale)*align.y-p.y)-o.y,-0.1)
		end
	end
end

local lengthTrim = client.getTextWidth("|")*2

---Sets the text to be displayed in the box. This supports raw json text
---@generic self
---@param self self
---@return self
---@param text any
function Box:setText(text)
	---@cast self GNUI.Box
	self.text = text
	if type(text) ~= "table" then
		text = {{text=tostring(text):gsub("\t","    ")}}
	end
	local t = flattenJsonText(text)
	if not t[1] then t = {t} end -- convert to array
	for _, c in pairs(t) do
		if (c.color and c.color == "default") or c.color == nil then
			c.color = self.defaultTextColor
		end
	end
	self.bakedText = {}
	self.bakedTextTable = {}
	self.textLengths = {}
	--local ft = fractureComponents(t,"[\x00-\x7F\xC2-\xF4][\x80-\xBF]*")
	local ft = fractureComponents(t,"[^%S\n]*%S*[^%S\n]*\n?")
	--printTable(t,2)
	for i = 1, #ft, 1 do
		local bt = ft[i]
		self.textLengths[i] = client.getTextWidth("|"..bt.text:gsub("\n",""):gsub(":[a-zA-Z_]+:","H").."|")-lengthTrim
		self.bakedTextTable[i] = bt
		self.bakedText[i] = toJson(bt)
	end
	self.TEXT_CHANGED:invoke(self.text)
	self:rebuildTextTasks()
	return self
end

---Sets the scale of the text being displayed.
---@param scale number
---@generic self
---@param self self
---@return self
function Box:setFontScale(scale)
	---@cast self GNUI.Box
	self.fontScale = scale
	self:rebuildTextTasks()
	return self
end

---Sets the default text color
---@param color Vector3|string
---@generic self
---@param self self
---@return self
function Box:setDefaultTextColor(color)
	---@cast self GNUI.Box
	if type(color):find("Vector") then
		self.defaultTextColor = "#"..vectors.rgbToHex(color)
	else
---@diagnostic disable-next-line: assign-type-mismatch
		self.defaultTextColor = color
	end
	if self.text then
		self:setText(self.text)
	end
	return self
end

---Tells where to anchor the text at.  
---`0` <-> `1`, left <-> right  
---`0` <-> `1`, top <-> bottom  
---@param h number?
---@param v number?
---@generic self
---@param self self
---@return self
function Box:setTextAlign(h,v)
	---@cast self GNUI.Box
	self.textAlign = utils.vec2(h or 0,v or 0)
	self:repositionText()
	return self
end

---Sets the flag if the text should wrap around when out of bounds.
---@param behavior GNUI.TextBehavior
---@generic self
---@param self self
---@return self
function Box:setTextBehavior(behavior)
	---@cast self GNUI.Box
	self.textBehavior = behavior or "NONE"
	self:update()
	return self
end


---@generic self
---@param self self
---@return self
---@param effect GNUI.TextEffect
function Box:setTextEffect(effect)
	---@cast self GNUI.Box
	self.textEffect = effect
	self:rebuildTextTasks()
	return self
end

---Sets the offset of the text.
---@param x number|Vector2
---@param y number?
---@generic self
---@param self self
---@return self
function Box:setTextOffset(x,y)
	---@cast self GNUI.Box
	self.textOffset = utils.vec2(x,y)
	self:repositionText()
	return self
end

return Box
