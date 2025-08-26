### Class Name: `Macros`
lets you contain Figura events and toggle them
```lua
local Macros = require("lib.macros")

local macro = Macros.new(function (events, ...)
	-- triggers when the player is loaded and the macro is enabled
	events.ENTITY_INIT:register(function ()
		print("INIT")
	end)
	
	events.RENDER:register(function ()
		print("tick")
	end)
	
	-- triggers when the macro is disabled
	events.ON_EXIT:register(function ()
		print("end")
	end)
end)


events.TICK:register(function ()
	-- enable the macro when the player sneaks
	macro:setActive(player:isSneaking())
end)
```
# Properties
|Type|Field|Description| |
|-|-|-|-|
|`MacroEventsAPI`|events|the collection of registered events| |
|`string`|id| used to identify the macro| |
|`fun(events: MacroEventsAPI,...)`|init|the registered initialization function|
|`boolean`|isActive|...| |
# Methods
|Returns|Methods|
|-|-|
|`Macros`|MacrosAPI.[new](#MacrosAPInewinit)(init : fun(events:)|
||Macros:[setActive](#Macrossetactiveactive-)(active : boolean, . : any)|

## `MacrosAPI.new(init)`
### Arguments
- `fun(events:` `init`

### Returns `Macros`


## `Macros:setActive(active, ...)`
Enables / Disables the macro  
### Arguments
- `boolean` `active`

- `any` `...` the data that will be passed to the `init` function


