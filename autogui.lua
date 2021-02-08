--region ffi
local ffi = require 'ffi'
ffi.cdef[[
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
  int wVk;
  int wScan;
  long dwFlags;
  long time;
  unsigned long *dwExtraInfo;
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
}
--endregion

local autogui = {dt = 1/30}

function autogui.sleep(t)
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
    if t + dt > time then return end
    autogui.sleep(dt)
  end
end

function autogui.moveBy(dx, dy, time)
  local x, y = autogui.position()
  autogui.moveto(x + dx, y + dy, time)
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
    autogui.mouseDown(x, y, button)
    autogui.mouseUp(x, y, button)
    if i < clicks then autogui.sleep(interval) end
  end
end

function autogui.doubleClick(x, y, button)
  autogui.click(x, y, button)
  autogui.click(x, y, button)
end

function autogui.dragTo(x, y, button, time)
  autogui.mouseDown(button)
  autogui.moveto(x, y, time)
  autogui.mouseUp(button)
end

function autogui.dragBy(dx, dy, button, time)
  autogui.mouseDown(button)
  autogui.moveto(dx, dy, time)
  autogui.mouseUp(button)
end

--endregion

return autogui
