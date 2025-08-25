#Requires AutoHotkey v2.0

; Swap CapsLock and Escape
CapsLock::Escape
Escape::CapsLock

; Swap LWin and LAlt
LWin::LAlt
LAlt::LWin

; Trackball scrolling with XButton1 and XButton2
; When held down, trackball scrolls without cursor movement
; When clicked without movement, performs right-click

; Configuration
ScrollSpeed := 3  ; Adjust scrolling speed (higher = faster)
ClickTolerance := 5  ; Pixels of movement allowed to still count as click
HoldTime := 150  ; Milliseconds to distinguish click from hold
InvertVertical := true   ; Invert vertical scrolling direction
InvertHorizontal := true ; Invert horizontal scrolling direction

; Use screen-absolute coordinates
CoordMode "Mouse", "Screen"

; Variables to track mouse state
global IsScrolling := false
global StartX := 0
global StartY := 0
global originalX := 0
global originalY := 0

; Handle both XButton1 and XButton2 with the same function
XButton1::HandleXButton("XButton1")
XButton2::HandleXButton("XButton2")

XButton1 up::StopScrollingIfActive()
XButton2 up::StopScrollingIfActive()

; Main handler function for both buttons
HandleXButton(buttonName) {
    ; Get current mouse position
    MouseGetPos(&startX, &startY)
    global StartX := startX
    global StartY := startY
    
    ; Wait to see if this is a click or hold
    startTime := A_TickCount
    Loop {
        if (!GetKeyState(buttonName, "P")) {
            ; Button released - check if it was a click
            elapsedTime := A_TickCount - startTime
            ; Only check movement if it was a quick press
            if (elapsedTime < HoldTime) {
                ; Get final position to check movement
                MouseGetPos(&finalX, &finalY)
                distance := Sqrt((finalX - startX)**2 + (finalY - startY)**2)
                if (distance <= ClickTolerance) {
                    ; Quick click without significant movement - simulate right click
                    SendEvent "{Blind}{RButton down}{RButton up}"
                }
            }
            return
        }
        
        ; Check if we've held long enough to start scrolling
        if (A_TickCount - startTime > HoldTime) {
            ; Hold detected, start scrolling mode
            StartScrolling()
            return
        }
        
        Sleep 10
    }
}

; Stop scrolling if either button is released
StopScrollingIfActive() {
    if (IsScrolling) {
        StopScrolling()
    }
}

; Start scrolling mode
StartScrolling() {
    global IsScrolling := true
    global originalX, originalY, lastX, lastY
    
    ; Store original mouse position
    MouseGetPos(&originalX, &originalY)
    lastX := originalX
    lastY := originalY
    
    ; Capture mouse events for scrolling
    while (IsScrolling && (GetKeyState("XButton1", "P") || GetKeyState("XButton2", "P"))) {
        MouseGetPos(&currentX, &currentY)
        
        ; Calculate movement relative to last position
        deltaX := currentX - lastX
        deltaY := currentY - lastY
        
        ; Update last position
        lastX := currentX
        lastY := currentY
        
        ; Perform scrolling on ANY movement (no threshold checking during scroll)
        if (deltaX != 0 || deltaY != 0) {
            ; Horizontal scrolling with optional inversion
            if (deltaX != 0) {
                wheelDirection := (InvertHorizontal ? (deltaX < 0) : (deltaX > 0)) ? "WheelRight " : "WheelLeft "
                wheelAmount := Round(Abs(deltaX) * ScrollSpeed / 20)
                if (wheelAmount > 0) {
                    SendEvent "{Blind}{" . wheelDirection . wheelAmount . "}"
                }
            }
            ; Vertical scrolling with optional inversion
            if (deltaY != 0) {
                wheelDirection := (InvertVertical ? (deltaY < 0) : (deltaY > 0)) ? "WheelDown " : "WheelUp "
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
    
    global IsScrolling := false
}

; Stop scrolling mode
StopScrolling() {
    global IsScrolling := false
}

; Reset scrolling state when script exits
OnExit(ExitFunc)

ExitFunc(*) {
    global IsScrolling := false
}