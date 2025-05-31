### Class Name: `Event`
acts the same way as Figura events, but as instantiatable objects

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

# Methods
|Returns|Methods|
|-|-|
|`Event`|Events.[new](#Eventsnew)()|
||Events:[register](#Eventsregisterfunc-name)(func : function, name : any)|
||Events:[clear](#Eventsclear)()|
||Events:[remove](#Eventsremovename)(name : string｜function)|
|`integer`|Events:[getRegisteredCount](#EventsgetRegisteredCountname)(name : string)|
## `Events.new()`
### Returns `Event`

## `Events:register(func, name)`
Registers a function as a listener to the event when it triggers.  
### Arguments
- `function` `func`

- `any` `name`


## `Events:clear()`
Clears all the registered listeners.  

## `Events:remove(name)`
Removes the listener with the given name.  
### Arguments
- `string|function` `name`


## `Events:getRegisteredCount(name)`
Returns the amount of events with the given name.  
### Arguments
- `string` `name`

### Returns `integer`