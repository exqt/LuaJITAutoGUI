# LuaJITAutoGUI
LuaJITAutoGUI lets your Lua scripts control the mouse and keyboard to automate interactions with other applications. Inspired by [PyAutoGUI](https://pyautogui.readthedocs.io/en/latest/)

- [LuaJIT](https://luajit.org/) is required to run
- Windows only (for now)
- screenshot functions are not implemented

# Function Reference
```lua
--Mouse
x, y = autogui.position()
autogui.moveTo(x, y, time)
autogui.moveBy(dx, dy, time)
autogui.mouseDown(button)
autogui.mouseUp(button)
autogui.scroll(amount)
autogui.click(x, y, button, clicks, interval)
autogui.doubleClick(x, y)
autogui.dragTo(x, y, button, time)
autogui.dragBy(dx, dy, button, time)
```

# Examples
```lua
--draw a star
local x, y = autogui.position()
local radius = 100
local angle = 4/5*math.pi

autogui.moveTo(x + radius, y)
for i=1, 5 do
  local px = x + radius*math.cos(angle*i)
  local py = y + radius*math.sin(angle*i)
  autogui.dragTo(px, py)
end
```
```lua
autogui.write("hello!, 안녕 こんにちは")
autogui.sleep(0.1)
autogui.hotkey('ctrl', 'a') -- select all
autogui.hotkey('ctrl', 'x') -- cut
```

# Credit
- [utf8.lua](https://github.com/luapower/utf8)
