#Requires AutoHotkey v2.0

; Swap CapsLock and Escape
CapsLock::Escape
Escape::CapsLock

; Swap LWin and LAlt
LWin::LAlt
LAlt::LWin

; Backup right click option
AppsKey::RButton

; Trackball scrolling

; Define global variables
global ScrollSpeed := 1.0  ; Adjust this value to change scrolling sensitivity (higher = faster)
global VerticalInvert := true  ; Set to true to invert vertical scroll direction
global HorizontalInvert := true  ; Set to true to invert horizontal scroll direction
global IsScrolling := false
global inScrollMode := false
global originalX, originalY
global accHoriz := 0.0
global accVert := 0.0

StartScrolling() {
    global IsScrolling := true
    global inScrollMode := false
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
        
        if (!inScrollMode) {
            if (Abs(deltaX) > 9 || Abs(deltaY) > 9) {
                inScrollMode := true
                ; Proceed to process scrolling
            } else {
                Sleep 10
                continue  ; Do not process scrolling or reset position yet
            }
        }
        
        ; Perform scrolling (only if there's movement)
        if (deltaX != 0 || deltaY != 0) {
            ; Horizontal scrolling
            if (deltaX != 0) {
                horizDelta := deltaX * (HorizontalInvert ? -1 : 1) * ScrollSpeed / 20.0
                accHoriz += horizDelta
                if (Abs(accHoriz) >= 0.5) {
                    wheelAmountH := Round(Abs(accHoriz))
                    if (wheelAmountH > 0) {
                        signH := accHoriz > 0 ? 1 : -1
                        wheelDirectionH := accHoriz > 0 ? "WheelRight " : "WheelLeft "
                        SendEvent "{Blind}{" . wheelDirectionH . wheelAmountH . "}"
                        accHoriz -= wheelAmountH * signH
                        if ((signH > 0 && accHoriz < 0) || (signH < 0 && accHoriz > 0)) {
                            accHoriz := 0.0
                        }
                    }
                }
            }
            ; Vertical scrolling
            if (deltaY != 0) {
                vertDelta := deltaY * (VerticalInvert ? -1 : 1) * ScrollSpeed / 20.0
                accVert += vertDelta
                if (Abs(accVert) >= 0.5) {
                    wheelAmountV := Round(Abs(accVert))
                    if (wheelAmountV > 0) {
                        signV := accVert > 0 ? 1 : -1
                        wheelDirectionV := accVert > 0 ? "WheelDown " : "WheelUp "
                        SendEvent "{Blind}{" . wheelDirectionV . wheelAmountV . "}"
                        accVert -= wheelAmountV * signV
                        if ((signV > 0 && accVert < 0) || (signV < 0 && accVert > 0)) {
                            accVert := 0.0
                        }
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
    
    ; If never entered scroll mode, simulate right click
    if (!inScrollMode) {
        SendEvent "{RButton}"
    }
    
    global IsScrolling := false
}

; Hotkeys to trigger the scrolling function
$XButton1::StartScrolling()
$XButton2::StartScrolling()