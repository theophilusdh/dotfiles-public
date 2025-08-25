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

StartScrolling() {
    global IsScrolling := true
    global originalX, originalY
    
    CoordMode "Mouse", "Screen"  ; Use screen-absolute coordinates.
    
    ; Temporarily enable per-monitor DPI awareness to prevent OS scaling mismatches.
    prevContext := DllCall("SetThreadDpiAwarenessContext", "ptr", -3, "ptr")  ; -3 is DPI_AWARENESS_CONTEXT_PER_MONITOR_AWARE
    
    ; Store original mouse position
    MouseGetPos(&originalX, &originalY)
    
    ; Capture mouse events for scrolling
    while (IsScrolling && (GetKeyState("XButton1", "P") || GetKeyState("XButton2", "P"))) {
        MouseGetPos(&currentX, &currentY)
        
        ; Calculate movement relative to original position
        deltaX := currentX - originalX
        deltaY := currentY - originalY
        
        ; Perform scrolling (only if there's movement)
        if (deltaX != 0 || deltaY != 0) {
            ; Horizontal scrolling
            if (deltaX != 0) {
                if (HorizontalInvert) {
                    wheelDirection := (deltaX > 0) ? "WheelLeft " : "WheelRight "
                } else {
                    wheelDirection := (deltaX > 0) ? "WheelRight " : "WheelLeft "
                }
                wheelAmount := Round(Abs(deltaX) * ScrollSpeed / 20)
                if (wheelAmount > 0) {
                    SendEvent "{Blind}{" . wheelDirection . wheelAmount . "}"
                }
            }
            ; Vertical scrolling
            if (deltaY != 0) {
                if (VerticalInvert) {
                    wheelDirection := (deltaY > 0) ? "WheelUp " : "WheelDown "
                } else {
                    wheelDirection := (deltaY > 0) ? "WheelDown " : "WheelUp "
                }
                wheelAmount := Round(Abs(deltaY) * ScrollSpeed / 20)
                if (wheelAmount > 0) {
                    SendEvent "{Blind}{" . wheelDirection . wheelAmount . "}"
                }
            }
        }
        
        ; Reset mouse position to prevent cursor drift
        DllCall("SetCursorPos", "int", originalX, "int", originalY)
        
        Sleep 10
    }
    
    ; Restore previous DPI awareness context
    DllCall("SetThreadDpiAwarenessContext", "ptr", prevContext, "ptr")
    
    global IsScrolling := false
}

; Hotkeys to trigger the scrolling function
$XButton1::StartScrolling()
$XButton2::StartScrolling()