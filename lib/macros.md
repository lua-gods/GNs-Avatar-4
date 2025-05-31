### Class Name: `Macros`
lets you contain Figura events and toggle them
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


