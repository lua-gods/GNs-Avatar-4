### Class Name: `Line`
 Displays a Line from point A to B in world space.

```lua
local Line = require("lib.line")

-- creates a line
local test = Line.new()

test
:setA(vec(0,2,1)) -- sets the first end of the line
:setB(vec(0,5,2)) -- sets the second end of the line
:setColor(1,0,0) -- sets the color to red
:setWidth(0.25) -- sets the width to a quarter of a block
```

# Properties
|Type|Field|Description| |
|-|-|-|-|
|`Vector3?`|a| First end of the line| |
|`Vector3?`|b| Second end of the line| |
|`Vector4`|color| The color of the line in RGBA| |
|`number`|depth| The offset depth of the line. 0 is normal, 0.5 is farther and -0.5 is closer| |
|`Vector3?`|dir| The difference between the first and second ends position| |
|`Vector3?`|dir_override| Overrides the dir of the line, useful for non world parent parts| |
|`integer`|id|...| |
|`number`|length| The distance between the first and second ends| |
|`SpriteTask`|model|...| |
|`boolean`|visible|...| |
|`number`|width| The width of the line in meters| |
|`boolean`|_queue_update| Whether or not the line should be updated in the next frame|package|
# Methods
|Returns|Methods|
|-|-|
|`Line`|Line.[new](#Linenewpreset)(preset : Line?)|
|`Line`|Line:[setAB](#LinesetABx1-y1-z1-x2-y2-z2)(x1 : number｜Vector3, y1 : number｜Vector3, z1 : number, x2 : number, y2 : number, z2 : number)|
||Line:[setAB](#LinesetABfrom-to)(from : Vector3, to : Vector3)|
|`Line`|Line:[setA](#LinesetAx-y-z)(x : number, y : number, z : number)|
||Line:[setA](#LinesetApos)(pos : Vector3)|
|`Line`|Line:[setB](#LinesetBx-y-z)(x : number, y : number, z : number)|
||Line:[setB](#LinesetBpos)(pos : Vector3)|
|`Line`|Line:[setWidth](#LinesetWidthw)(w : number)|
|`Line`|Line:[setRenderType](#LinesetRenderTyperender_type)(render_type : ModelPart.renderType)|
|`Line`|Line:[setColor](#LinesetColorr-g-b-a)(r : number, g : number, b : number, a : number)|
||Line:[setColor](#LinesetColorstring)(string : string)|
||Line:[setColor](#LinesetColorrgb)(rgb : Vector4)|
||Line:[setColor](#LinesetColorrgb)(rgb : Vector3)|
|`Line`|Line:[setDepth](#LinesetDepthz)(z : number)|
||Line:[free](#Linefree)()|
|`Line`|Line:[setVisible](#LinesetVisiblevisible)(visible : boolean)|
|`Line`|Line:[update](#Lineupdate)()|
|`Line`|Line:[immediateUpdate](#LineimmediateUpdate)()|
## `Line.new(preset)`
Creates a new line.  
### Arguments
- `Line?` `preset`

### Returns `Line`

## `Line:setAB(x1, y1, z1, x2, y2, z2)`
Sets both points of the line.  
### Arguments
- `number|Vector3` `x1`

- `number|Vector3` `y1`

- `number` `z1`

- `number` `x2`

- `number` `y2`

- `number` `z2`

### Returns `Line`

## `Line:setAB(from, to)`
Sets both points of the line.  
### Arguments
- `Vector3` `from`

- `Vector3` `to`


## `Line:setA(x, y, z)`
Sets the first point of the line.  
### Arguments
- `number` `x`

- `number` `y`

- `number` `z`

### Returns `Line`

## `Line:setA(pos)`
Sets the first point of the line.  
### Arguments
- `Vector3` `pos`


## `Line:setB(x, y, z)`
Sets the second point of the line.  
### Arguments
- `number` `x`

- `number` `y`

- `number` `z`

### Returns `Line`

## `Line:setB(pos)`
Sets the second point of the line.  
### Arguments
- `Vector3` `pos`


## `Line:setWidth(w)`
Sets the width of the line.    
Note: This is in minecraft blocks/meters.  
### Arguments
- `number` `w`

### Returns `Line`

## `Line:setRenderType(render_type)`
Sets the render type of the line.    
by default this is "CUTOUT_EMISSIVE_SOLID".  
### Arguments
- `ModelPart.renderType` `render_type`

### Returns `Line`

## `Line:setColor(r, g, b, a)`
Sets the color of the line.  
### Arguments
- `number` `r`

- `number` `g`

- `number` `b`

- `number` `a`

### Returns `Line`

## `Line:setColor(string)`
Sets the color of the line.  
### Arguments
- `string` `string`


## `Line:setColor(rgb)`
Sets the color of the line.  
### Arguments
- `Vector4` `rgb`


## `Line:setColor(rgb)`
Sets the color of the line.  
### Arguments
- `Vector3` `rgb`


## `Line:setDepth(z)`
Sets the depth of the line.    
Note: this is an offset to the depth of the object. meaning 0 is normal, `0.5` is farther and `-0.5` is closer  
### Arguments
- `number` `z`

### Returns `Line`

## `Line:free()`
Frees the line from memory.  

## `Line:setVisible(visible)`
### Arguments
- `boolean` `visible`

### Returns `Line`

## `Line:update()`
Queues itself to be updated in the next frame.  
### Returns `Line`

## `Line:immediateUpdate()`
Immediately updates the line without queuing it.  
### Returns `Line`

