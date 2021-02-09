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
--Keyboard
autogui.keyDown(key)
autogui.keyUp(key)
autogui.press(key)
autogui.write(str, interval)
autogui.hotkey(...)
--MessageBox
autogui.alert(text, title)
autogui.confirm(text, title) -- returns 'OK' or 'Cancel'
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

# Keyboard Keys
The following are the valid strings to pass to the press(), keyDown(), keyUp(), and hotkey() functions:

```
'\t', '\n', '\r', ' ', '!', '"', '#', '$', '%', '&', "'", '(',
')', '*', '+', ',', '-', '.', '/', '0', '1', '2', '3', '4', '5', '6', '7',
'8', '9', ':', ';', '<', '=', '>', '?', '@', '[', '\\', ']', '^', '_', '`',
'a', 'b', 'c', 'd', 'e','f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o',
'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z', '{', '|', '}', '~',
'accept', 'add', 'alt', 'altleft', 'altright', 'apps', 'backspace',
'browserback', 'browserfavorites', 'browserforward', 'browserhome',
'browserrefresh', 'browsersearch', 'browserstop', 'capslock', 'clear',
'convert', 'ctrl', 'ctrlleft', 'ctrlright', 'decimal', 'del', 'delete',
'divide', 'down', 'end', 'enter', 'esc', 'escape', 'execute', 'f1', 'f10',
'f11', 'f12', 'f13', 'f14', 'f15', 'f16', 'f17', 'f18', 'f19', 'f2', 'f20',
'f21', 'f22', 'f23', 'f24', 'f3', 'f4', 'f5', 'f6', 'f7', 'f8', 'f9',
'final', 'fn', 'hanguel', 'hangul', 'hanja', 'help', 'home', 'insert', 'junja',
'kana', 'kanji', 'launchapp1', 'launchapp2', 'launchmail',
'launchmediaselect', 'left', 'modechange', 'multiply', 'nexttrack',
'nonconvert', 'num0', 'num1', 'num2', 'num3', 'num4', 'num5', 'num6',
'num7', 'num8', 'num9', 'numlock', 'pagedown', 'pageup', 'pause', 'pgdn',
'pgup', 'playpause', 'prevtrack', 'print', 'printscreen', 'prntscrn',
'prtsc', 'prtscr', 'return', 'right', 'scrolllock', 'select', 'separator',
'shift', 'shiftleft', 'shiftright', 'sleep', 'space', 'stop', 'subtract', 'tab',
'up', 'volumedown', 'volumemute', 'volumeup', 'win', 'winleft', 'winright', 'yen',
'command', 'option', 'optionleft', 'optionright'
```

# Credit
- [utf8.lua](https://github.com/luapower/utf8)
