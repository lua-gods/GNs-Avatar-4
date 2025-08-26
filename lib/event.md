### Class Name: `Event`
acts the same way as Figura events, but as instantiatable objects

```lua
-- create an event object
local EXPLODE = Event.new()
-- register a listener
EXPLODE:register(function ()
	print("BOOM!")
end)
-- call the event
EXPLODE:invoke()
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