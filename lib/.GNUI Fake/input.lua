
---@class GNUI.InputEvent
---@field char string
---@field key GNUI.keyCode
---@field state Event.Press.state
---@field ctrl boolean
---@field shift boolean
---@field alt boolean
---@field isHandled boolean
---@field strength number # for scrollwheel

---@class GNUI.InputEventMouseMotion
---@field pos Vector2 # local position 
---@field relative Vector2 # the change of position since last set

---A valid key code for use in keybinds.
---
---Also accepts other formats such as
---* `key.keyboard.###`
---* `key.mouse.###`
---* `scancode.###`
---@alias GNUI.keyCode string
---| "key.keyboard.unknown"    # 🚫 *Unset*
---| "key.keyboard.escape"     # `⎋ Esc`
---| "key.keyboard.f1"       # `F1`
---| "key.keyboard.f2"       # `F2`
---| "key.keyboard.f3"       # `F3`
---| "key.keyboard.f4"       # `F4`
---| "key.keyboard.f5"       # `F5`
---| "key.keyboard.f6"       # `F6`
---| "key.keyboard.f7"       # `F7`
---| "key.keyboard.f8"       # `F8`
---| "key.keyboard.f9"       # `F9`
---| "key.keyboard.f10"      # `F10`
---| "key.keyboard.f11"      # `F11`
---| "key.keyboard.f12"      # `F12`
---| "key.keyboard.print.screen"  # `PrtSc|SysRq`
---| "key.keyboard.scroll.lock"   # `Scroll Lock`
---| "key.keyboard.pause"      # `Pause|Break`
---| "key.keyboard.f13"      # `F13`
---| "key.keyboard.f14"      # `F14`
---| "key.keyboard.f15"      # `F15`
---| "key.keyboard.f16"      # `F16`
---| "key.keyboard.f17"      # `F17`
---| "key.keyboard.f18"      # `F18`
---| "key.keyboard.f19"      # `F19`
---| "key.keyboard.f20"      # `F20`
---| "key.keyboard.f21"      # `F21`
---| "key.keyboard.f22"      # `F22`
---| "key.keyboard.f23"      # `F23`
---| "key.keyboard.f24"      # `F24`
---| "key.keyboard.f25"      # `F25`
---| "key.keyboard.0"       # `0`
---| "key.keyboard.1"       # `1`
---| "key.keyboard.2"       # `2`
---| "key.keyboard.3"       # `3`
---| "key.keyboard.4"       # `4`
---| "key.keyboard.5"       # `5`
---| "key.keyboard.6"       # `6`
---| "key.keyboard.7"       # `7`
---| "key.keyboard.8"       # `8`
---| "key.keyboard.9"       # `9`
---| "key.keyboard.a"       # `A`
---| "key.keyboard.b"       # `B`
---| "key.keyboard.c"       # `C`
---| "key.keyboard.d"       # `D`
---| "key.keyboard.e"       # `E`
---| "key.keyboard.f"       # `F`
---| "key.keyboard.g"       # `G`
---| "key.keyboard.h"       # `H`
---| "key.keyboard.i"       # `I`
---| "key.keyboard.j"       # `J`
---| "key.keyboard.k"       # `K`
---| "key.keyboard.l"       # `L`
---| "key.keyboard.m"       # `M`
---| "key.keyboard.n"       # `N`
---| "key.keyboard.o"       # `O`
---| "key.keyboard.p"       # `P`
---| "key.keyboard.q"       # `Q`
---| "key.keyboard.r"       # `R`
---| "key.keyboard.s"       # `S`
---| "key.keyboard.t"       # `T`
---| "key.keyboard.u"       # `U`
---| "key.keyboard.v"       # `V`
---| "key.keyboard.w"       # `W`
---| "key.keyboard.x"       # `X`
---| "key.keyboard.y"       # `Y`
---| "key.keyboard.z"       # `Z`
---| "key.keyboard.grave.accent"  # ``‌`‌``
---| "key.keyboard.comma"      # `,`
---| "key.keyboard.period"     # `.`
---| "key.keyboard.semicolon"    # `;`
---| "key.keyboard.apostrophe"   # `'`
---| "key.keyboard.minus"      # `-`
---| "key.keyboard.equal"      # `=`
---| "key.keyboard.slash"      # `/`
---| "key.keyboard.backslash"    # `\`
---| "key.keyboard.left.bracket"  # `[`
---| "key.keyboard.right.bracket"  # `]`
---| "key.keyboard.space"      # `␣`
---| "key.keyboard.tab"      # `↹ Tab` **/** `⇥`
---| "key.keyboard.backspace"    # `⟵ Backspace` **/** `⌫`
---| "key.keyboard.caps.lock"    # `🅰 Caps Lock` **/** `⇪`
---| "key.keyboard.enter"      # `↵ Enter` **/** `↵ Return`
---| "key.keyboard.left.control"  # `✲ Ctrl` **/** `⎈` **/** `⌃`
---| "key.keyboard.right.control"  # `✲ RCtrl` **/** `⎈` **/** `⌃`
---| "key.keyboard.left.shift"   # `⇧ Shift`
---| "key.keyboard.right.shift"   # `⇧ RShift`
---| "key.keyboard.left.win"    # `⊞ Win` **/** `⌘ Command` **/** `❖ Super`
---| "key.keyboard.right.win"    # `⊞ RWin` **/** `⌘ RCommand` **/** `❖ RSuper`
---| "key.keyboard.left.alt"    # `⎇ Alt` **/** `⌥ Option`
---| "key.keyboard.right.alt"    # `⎇ RAlt` **/** `Alt Gr` **/** `⌥ ROption`
---| "key.keyboard.menu"      # `☰ Menu`
---| "key.keyboard.insert"     # `Ins`
---| "key.keyboard.delete"     # `⌦ Del`
---| "key.keyboard.home"      # `⤒ Home`
---| "key.keyboard.end"      # `⤓ End`
---| "key.keyboard.page.up"    # `⇞ PgUp`
---| "key.keyboard.page.down"    # `⇟ PgDn`
---| "key.keyboard.up"       # `↑ Up`
---| "key.keyboard.down"      # `↓ Down`
---| "key.keyboard.left"      # `← Left`
---| "key.keyboard.right"      # `→ Right`
---| "key.keyboard.num.lock"    # `Num Lock` **/** `⌧ Clear`
---| "key.keyboard.keypad.equal"  # `KP =`
---| "key.keyboard.keypad.divide"  # `KP /`
---| "key.keyboard.keypad.multiply" # `KP *`
---| "key.keyboard.keypad.subtract" # `KP -`
---| "key.keyboard.keypad.add"   # `KP +`
---| "key.keyboard.keypad.0"    # `KP 0`
---| "key.keyboard.keypad.1"    # `KP 1`
---| "key.keyboard.keypad.2"    # `KP 2`
---| "key.keyboard.keypad.3"    # `KP 3`
---| "key.keyboard.keypad.4"    # `KP 4`
---| "key.keyboard.keypad.5"    # `KP 5`
---| "key.keyboard.keypad.6"    # `KP 6`
---| "key.keyboard.keypad.7"    # `KP 7`
---| "key.keyboard.keypad.8"    # `KP 8`
---| "key.keyboard.keypad.9"    # `KP 9`
---| "key.keyboard.keypad.decimal"  # `KP .`
---| "key.keyboard.keypad.enter"  # `↵ KP Enter` **/** `⌤`
---| "key.keyboard.world.1"    # `🌐¹`
---| "key.keyboard.world.2"    # `🌐²`
---| "key.mouse.left"          # `Mouse Left`
---| "key.mouse.right"         # `Mouse Right`
---| "key.mouse.middle"        # `Mouse Middle`
---| "key.mouse.4"             # `Mouse Back`
---| "key.mouse.5"             # `Mouse Forward`
---| "key.mouse.6"             # `Mouse 6`
---| "key.mouse.7"             # `Mouse 7`
---| "key.mouse.8"             # `Mouse 8`
---| "key.mouse.scroll"        # `Mouse 8`

local keymap = client.getEnum("keybinds")

for key, value in pairs(keymap) do keymap[key] = "key.keyboard." .. value end

local mousemap = {
	[0] = "left",
	[1] = "right",
	[2] = "middle",
	[3] = "4",
	[4] = "5",
	[5] = "6",
	[6] = "7",
	[7] = "8",
	-- anyhting after this is made up for GNUI
	[8] = "scroll"
}

for key, value in pairs(mousemap) do mousemap[key] = "key.mouse." .. value end

