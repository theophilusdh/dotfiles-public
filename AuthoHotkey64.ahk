#Requires AutoHotkey v2.0

; Swap CapsLock and Escape
CapsLock::Escape
Escape::CapsLock

; Swap LWin and LAlt
LWin::LAlt
LAlt::LWin

; Trackball scrolling

; Define global variables
global ScrollSpeed := 1.0  ; Adjust this value to change scrolling sensitivity (higher = faster)
global VerticalInvert := false  ; Set to true to invert vertical scroll direction
global HorizontalInvert := false  ; Set to true to invert horizontal scroll direction
global IsScrolling := false
global originalX, originalY

; Start scrolling mode
StartScrolling() {
    global IsScrolling := true
    global originalX, originalY, lastX, lastY
    
    ; Store original mouse position
    MouseGetPos(&originalX, &originalY)
    lastX := originalX
    lastY := originalY

    ; Accumulators for fractional wheel amounts
    accum_wheel_h := 0.0
    accum_wheel_v := 0.0
    
    ; Capture mouse events for scrolling
    while (IsScrolling && (GetKeyState("XButton1", "P") || GetKeyState("XButton2", "P"))) {
        MouseGetPos(&currentX, &currentY)
        
        ; Calculate movement relative to last position
        deltaX := currentX - lastX
        deltaY := currentY - lastY
        
        ; Update last position
        lastX := currentX
        lastY := currentY
        
        ; Horizontal scrolling with optional inversion and accumulation
        effective_deltaX := InvertHorizontal ? -deltaX : deltaX
        accum_wheel_h += effective_deltaX * (ScrollSpeed / 20.0)
        if (accum_wheel_h != 0) {
            h_sign := accum_wheel_h > 0 ? 1 : -1
            h_direction := h_sign > 0 ? "WheelRight " : "WheelLeft "
            h_amount := Round(Abs(accum_wheel_h))
            if (h_amount > 0) {
                SendEvent "{Blind}{" . h_direction . h_amount . "}"
                accum_wheel_h -= h_amount * h_sign
            }
        }
        
        ; Vertical scrolling with optional inversion and accumulation
        effective_deltaY := InvertVertical ? -deltaY : deltaY
        accum_wheel_v += effective_deltaY * (ScrollSpeed / 20.0)
        if (accum_wheel_v != 0) {
            v_sign := accum_wheel_v > 0 ? 1 : -1
            v_direction := v_sign > 0 ? "WheelDown " : "WheelUp "
            v_amount := Round(Abs(accum_wheel_v))
            if (v_amount > 0) {
                SendEvent "{Blind}{" . v_direction . v_amount . "}"
                accum_wheel_v -= v_amount * v_sign
            }
        }
        
        ; Reset mouse position to prevent cursor drift
        DllCall("SetCursorPos", "int", originalX, "int", originalY)
        
        Sleep 10
    }
    
    global IsScrolling := false
}

; Hotkeys to trigger the scrolling function
$XButton1::StartScrolling()
$XButton2::StartScrolling()