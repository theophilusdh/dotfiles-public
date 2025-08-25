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
global accHoriz := 0.0
global accVert := 0.0

StartScrolling() {
    global IsScrolling := true
    global originalX, originalY
    global accHoriz := 0.0
    global accVert := 0.0
    
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
                horizDelta := deltaX * (HorizontalInvert ? -1 : 1) * ScrollSpeed / 20.0
                accHoriz += horizDelta
                if (Abs(accHoriz) >= 0.5) {  ; Use 0.5 to align with rounding behavior
                    wheelAmountH := Round(Abs(accHoriz))
                    if (wheelAmountH > 0) {
                        wheelDirectionH := (accHoriz > 0) ? "WheelRight " : "WheelLeft "
                        SendEvent "{Blind}{" . wheelDirectionH . wheelAmountH . "}"
                        accHoriz -= (accHoriz > 0 ? wheelAmountH : -wheelAmountH)
                    }
                }
            }
            ; Vertical scrolling
            if (deltaY != 0) {
                vertDelta := deltaY * (VerticalInvert ? -1 : 1) * ScrollSpeed / 20.0
                accVert += vertDelta
                if (Abs(accVert) >= 0.5) {  ; Use 0.5 to align with rounding behavior
                    wheelAmountV := Round(Abs(accVert))
                    if (wheelAmountV > 0) {
                        wheelDirectionV := (accVert > 0) ? "WheelDown " : "WheelUp "
                        SendEvent "{Blind}{" . wheelDirectionV . wheelAmountV . "}"
                        accVert -= (accVert > 0 ? wheelAmountV : -wheelAmountV)
                    }
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