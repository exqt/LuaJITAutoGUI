--region ffi
local ffi = require 'ffi'
ffi.cdef[[
typedef unsigned short WORD;
typedef unsigned long DWORD;
typedef struct tagPOINT {
  long x;
  long y;
} POINT;
typedef struct tagMOUSEINPUT {
  long dx;
  long dy;
  unsigned int mouseData;
  unsigned int dwFlags;
  unsigned int time;
  unsigned long *dwExtraInfo;
} MOUSEINPUT, *PMOUSEINPUT, *LPMOUSEINPUT;
typedef struct tagKEYBDINPUT {
  WORD      wVk;
  WORD      wScan;
  DWORD     dwFlags;
  DWORD     time;
  DWORD *dwExtraInfo;
} KEYBDINPUT, *PKEYBDINPUT, *LPKEYBDINPUT;
typedef struct tagHARDWAREINPUT {
  long uMsg;
  int wParamL;
  int wParamH;
} HARDWAREINPUT, *PHARDWAREINPUT, *LPHARDWAREINPUT;
typedef struct INPUT {
  unsigned int type;
  union {
    MOUSEINPUT    mi;
    KEYBDINPUT    ki;
    HARDWAREINPUT hi;
  } U;
} INPUT;
bool SetCursorPos(int x, int y);
bool GetCursorPos(POINT *lpPoint);
void Sleep(int dwMilliseconds);
unsigned int SendInput(
  unsigned int cInputs,
  INPUT pInputs,
  int     cbSize
);
int MessageBoxA(void *w, const char *txt, const char *cap, int type);
]]
local CONST = {
  INPUT_MOUSE = 0,
  INPUT_KEYBOARD = 1,
  MOUSEEVENTF_LEFTDOWN = 0x0002,
  MOUSEEVENTF_LEFTUP = 0x0004,
  MOUSEEVENTF_RIGHTDOWN = 0x0008,
  MOUSEEVENTF_RIGHTUP = 0x0010,
  MOUSEEVENTF_MIDDLEDOWN = 0x0020,
  MOUSEEVENTF_MIDDLEUP = 0x0040,
  MOUSEEVENTF_WHEEL = 0x0800,
  KEYEVENTF_KEYUP = 0x0002,
  KEYEVENTF_UNICODE = 0x0004,
}
--endregion

local autogui = {dt = 1/10}

function autogui.sleep(t)
  if t < autogui.dt then return end
  ffi.C.Sleep(t*1000)
end

--region Mouse
function autogui._mouseInput(x, y, flags, mouseData)
  local input = ffi.new("INPUT")
  input.type = CONST.INPUT_MOUSE
  input.U.mi.dx = x
  input.U.mi.dy = y
  input.U.mi.mouseData = mouseData or 0
  input.U.mi.dwFlags = flags
  input.U.mi.time = 0
  input.U.mi.dwExtraInfo = nil
  ffi.C.SendInput(1, input, ffi.sizeof("INPUT"))
end

function autogui._setCursorPos(x, y)
  ffi.C.SetCursorPos(x, y)
end

function autogui.position()
  local p = ffi.new("POINT[1]")
  ffi.C.GetCursorPos(p)
  return p[0].x, p[0].y
end

local lerp = function(s, e, t) return s*(1-t)+e*t end
function autogui.moveTo(x, y, time)
  local sx, sy = autogui.position()
  x = x or sx
  y = y or sy
  if time == nil or time <= 0 then
    autogui._setCursorPos(x, y)
    return
  end

  local dt = autogui.dt
  for t=0, time, dt do
    autogui._setCursorPos(lerp(sx, x, t/time), lerp(sy, y, t/time))
    if t + dt > time then break end
    autogui.sleep(dt)
  end
  autogui._setCursorPos(x, y)
end

function autogui.moveBy(dx, dy, time)
  local x, y = autogui.position()
  autogui.moveTo(x + dx, y + dy, time)
end

function autogui.mouseDown(button)
  button = button or 'left'
  if button == 'left' then
    autogui._mouseInput(0, 0, CONST.MOUSEEVENTF_LEFTDOWN)
  elseif button == 'right' then
    autogui._mouseInput(0, 0, CONST.MOUSEEVENTF_RIGHTDOWN)
  elseif button == 'middle' then
    autogui._mouseInput(0, 0, CONST.MOUSEEVENTF_MIDDLEDOWN)
  end
end

function autogui.mouseUp(button)
  button = button or 'left'
  if button == 'left' then
    autogui._mouseInput(0, 0, CONST.MOUSEEVENTF_LEFTUP)
  elseif button == 'right' then
    autogui._mouseInput(0, 0, CONST.MOUSEEVENTF_RIGHTUP)
  elseif button == 'middle' then
    autogui._mouseInput(0, 0, CONST.MOUSEEVENTF_MIDDLEUP)
  end
end

function autogui.scroll(amount)
  amount = amount or -128
  autogui._mouseInput(0, 0, CONST.MOUSEEVENTF_WHEEL, amount)
end

function autogui.click(x, y, button, clicks, interval)
  autogui.moveTo(x, y)
  clicks = clicks or 1
  interval = interval or autogui.dt
  for i=1, clicks do
    autogui.mouseDown(button)
    autogui.mouseUp(button)
    if i < clicks then autogui.sleep(interval) end
  end
end

function autogui.doubleClick(x, y, button)
  autogui.click(x, y, button)
  autogui.click(x, y, button)
end

function autogui.dragTo(x, y, button, time)
  autogui.mouseDown(button)
  autogui.moveTo(x, y, time)
  autogui.sleep(autogui.dt)
  autogui.mouseUp(button)
end

function autogui.dragBy(dx, dy, button, time)
  autogui.mouseDown(button)
  autogui.moveTo(dx, dy, time)
  autogui.sleep(autogui.dt)
  autogui.mouseUp(button)
end

--endregion

--region Keyboard
local keymap = {
  ['\b'] = 0x08, -- VK_BACK
  ['super'] = 0x5B, --VK_LWIN
  ['tab'] = 0x09, -- VK_TAB
  ['\t'] = 0x09, -- VK_TAB
  ['clear'] = 0x0c, -- VK_CLEAR
  ['enter'] = 0x0d, -- VK_RETURN
  ['\n'] = 0x0d, -- VK_RETURN
  ['return'] = 0x0d, -- VK_RETURN
  ['shift'] = 0x10, -- VK_SHIFT
  ['ctrl'] = 0x11, -- VK_CONTROL
  ['alt'] = 0x12, -- VK_MENU
  ['pause'] = 0x13, -- VK_PAUSE
  ['capslock'] = 0x14, -- VK_CAPITAL
  ['kana'] = 0x15, -- VK_KANA
  ['hanguel'] = 0x15, -- VK_HANGUEL
  ['hangul'] = 0x15, -- VK_HANGUL
  ['junja'] = 0x17, -- VK_JUNJA
  ['final'] = 0x18, -- VK_FINAL
  ['hanja'] = 0x19, -- VK_HANJA
  ['kanji'] = 0x19, -- VK_KANJI
  ['esc'] = 0x1b, -- VK_ESCAPE
  ['escape'] = 0x1b, -- VK_ESCAPE
  ['convert'] = 0x1c, -- VK_CONVERT
  ['nonconvert'] = 0x1d, -- VK_NONCONVERT
  ['accept'] = 0x1e, -- VK_ACCEPT
  ['modechange'] = 0x1f, -- VK_MODECHANGE
  [' '] = 0x20, -- VK_SPACE
  ['space'] = 0x20, -- VK_SPACE
  ['pgup'] = 0x21, -- VK_PRIOR
  ['pgdn'] = 0x22, -- VK_NEXT
  ['pageup'] = 0x21, -- VK_PRIOR
  ['pagedown'] = 0x22, -- VK_NEXT
  ['end'] = 0x23, -- VK_END
  ['home'] = 0x24, -- VK_HOME
  ['left'] = 0x25, -- VK_LEFT
  ['up'] = 0x26, -- VK_UP
  ['right'] = 0x27, -- VK_RIGHT
  ['down'] = 0x28, -- VK_DOWN
  ['select'] = 0x29, -- VK_SELECT
  ['print'] = 0x2a, -- VK_PRINT
  ['execute'] = 0x2b, -- VK_EXECUTE
  ['prtsc'] = 0x2c, -- VK_SNAPSHOT
  ['prtscr'] = 0x2c, -- VK_SNAPSHOT
  ['prntscrn'] = 0x2c, -- VK_SNAPSHOT
  ['printscreen'] = 0x2c, -- VK_SNAPSHOT
  ['insert'] = 0x2d, -- VK_INSERT
  ['del'] = 0x2e, -- VK_DELETE
  ['delete'] = 0x2e, -- VK_DELETE
  ['help'] = 0x2f, -- VK_HELP
  ['win'] = 0x5b, -- VK_LWIN
  ['winleft'] = 0x5b, -- VK_LWIN
  ['winright'] = 0x5c, -- VK_RWIN
  ['apps'] = 0x5d, -- VK_APPS
  ['sleep'] = 0x5f, -- VK_SLEEP
  ['num0'] = 0x60, -- VK_NUMPAD0
  ['num1'] = 0x61, -- VK_NUMPAD1
  ['num2'] = 0x62, -- VK_NUMPAD2
  ['num3'] = 0x63, -- VK_NUMPAD3
  ['num4'] = 0x64, -- VK_NUMPAD4
  ['num5'] = 0x65, -- VK_NUMPAD5
  ['num6'] = 0x66, -- VK_NUMPAD6
  ['num7'] = 0x67, -- VK_NUMPAD7
  ['num8'] = 0x68, -- VK_NUMPAD8
  ['num9'] = 0x69, -- VK_NUMPAD9
  ['multiply'] = 0x6a, -- VK_MULTIPLY  ??? Is this the numpad *?
  ['add'] = 0x6b, -- VK_ADD  ??? Is this the numpad +?
  ['separator'] = 0x6c, -- VK_SEPARATOR  ??? Is this the numpad enter?
  ['subtract'] = 0x6d, -- VK_SUBTRACT  ??? Is this the numpad -?
  ['decimal'] = 0x6e, -- VK_DECIMAL
  ['divide'] = 0x6f, -- VK_DIVIDE
  ['f1'] = 0x70, -- VK_F1
  ['f2'] = 0x71, -- VK_F2
  ['f3'] = 0x72, -- VK_F3
  ['f4'] = 0x73, -- VK_F4
  ['f5'] = 0x74, -- VK_F5
  ['f6'] = 0x75, -- VK_F6
  ['f7'] = 0x76, -- VK_F7
  ['f8'] = 0x77, -- VK_F8
  ['f9'] = 0x78, -- VK_F9
  ['f10'] = 0x79, -- VK_F10
  ['f11'] = 0x7a, -- VK_F11
  ['f12'] = 0x7b, -- VK_F12
  ['f13'] = 0x7c, -- VK_F13
  ['f14'] = 0x7d, -- VK_F14
  ['f15'] = 0x7e, -- VK_F15
  ['f16'] = 0x7f, -- VK_F16
  ['f17'] = 0x80, -- VK_F17
  ['f18'] = 0x81, -- VK_F18
  ['f19'] = 0x82, -- VK_F19
  ['f20'] = 0x83, -- VK_F20
  ['f21'] = 0x84, -- VK_F21
  ['f22'] = 0x85, -- VK_F22
  ['f23'] = 0x86, -- VK_F23
  ['f24'] = 0x87, -- VK_F24
  ['numlock'] = 0x90, -- VK_NUMLOCK
  ['scrolllock'] = 0x91, -- VK_SCROLL
  ['shiftleft'] = 0xa0, -- VK_LSHIFT
  ['shiftright'] = 0xa1, -- VK_RSHIFT
  ['ctrlleft'] = 0xa2, -- VK_LCONTROL
  ['ctrlright'] = 0xa3, -- VK_RCONTROL
  ['altleft'] = 0xa4, -- VK_LMENU
  ['altright'] = 0xa5, -- VK_RMENU
  ['browserback'] = 0xa6, -- VK_BROWSER_BACK
  ['browserforward'] = 0xa7, -- VK_BROWSER_FORWARD
  ['browserrefresh'] = 0xa8, -- VK_BROWSER_REFRESH
  ['browserstop'] = 0xa9, -- VK_BROWSER_STOP
  ['browsersearch'] = 0xaa, -- VK_BROWSER_SEARCH
  ['browserfavorites'] = 0xab, -- VK_BROWSER_FAVORITES
  ['browserhome'] = 0xac, -- VK_BROWSER_HOME
  ['volumemute'] = 0xad, -- VK_VOLUME_MUTE
  ['volumedown'] = 0xae, -- VK_VOLUME_DOWN
  ['volumeup'] = 0xaf, -- VK_VOLUME_UP
  ['nexttrack'] = 0xb0, -- VK_MEDIA_NEXT_TRACK
  ['prevtrack'] = 0xb1, -- VK_MEDIA_PREV_TRACK
  ['stop'] = 0xb2, -- VK_MEDIA_STOP
  ['playpause'] = 0xb3, -- VK_MEDIA_PLAY_PAUSE
  ['launchmail'] = 0xb4, -- VK_LAUNCH_MAIL
  ['launchmediaselect'] = 0xb5, -- VK_LAUNCH_MEDIA_SELECT
  ['launchapp1'] = 0xb6, -- VK_LAUNCH_APP1
  ['launchapp2'] = 0xb7, -- VK_LAUNCH_APP2
}
for i=0x41, 0x41+25 do
  keymap[string.char(i)] = i
  keymap[string.char(i + 0x20)] = i
end -- 'A' to 'Z'
for i=0x30, 0x30+9 do keymap[string.char(i)] = i end -- '0' to '9'

function autogui._keyboardInput(key, flags, wScan)
  local input = ffi.new("INPUT")
  input.type = CONST.INPUT_KEYBOARD
  input.U.ki.wVk = key
  input.U.ki.wScan = wScan or 0
  input.U.ki.dwFlags = flags
  input.U.ki.time = 0
  input.U.ki.dwExtraInfo = nil
  ffi.C.SendInput(1, input, ffi.sizeof("INPUT"))
end

function autogui.keyDown(key)
  local vk = keymap[key]
  if not vk then error("Unknown key: " .. key) end
  autogui._keyboardInput(vk, 0)
end

function autogui.keyUp(key)
  local vk = keymap[key]
  if not vk then error("Unknown key: " .. key) end
  autogui._keyboardInput(vk, CONST.KEYEVENTF_KEYUP)
end

function autogui.press(key)
  autogui.keyDown(key)
  autogui.keyUp(key)
end

function autogui.write(str, interval)
  local utf8 = require 'utf8'
  interval = interval or 0
  for i, c in utf8.chars(str) do
    autogui._keyboardInput(0, CONST.KEYEVENTF_UNICODE, c)
    autogui._keyboardInput(0, CONST.KEYEVENTF_KEYUP, c)
    autogui.sleep(interval)
  end
end

function autogui.hotkey(...)
  local keys = {...}
  for i=1, #keys do
    autogui.keyDown(keys[i])
  end
  for i=#keys, 1, -1 do
    autogui.keyUp(keys[i])
  end
end
--endregion

--region Message
function autogui.alert(text, title)
  ffi.C.MessageBoxA(nil, text, title or "", 0)
end

function autogui.confirm(text, title)
  local r = ffi.C.MessageBoxA(nil, text, title, 0x00000001)
  if r == 1 then
    return "OK"
  else
    return "Cancel"
  end
end

--endregion

return autogui
