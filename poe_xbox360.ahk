/*
Default Controls:
Move = Left Analog Stick
Mouse Control = Right Analog Stick
Left Mouse/Skill = LT
Right Mouse/Skill = RT
*/

; BEGIN CONFIG SECTION
; Increase the following value to make the mouse cursor move faster:
JoyMulti = .5
; Decrease the following value to require less joystick displacement-from-center
; to start moving the mouse.  However, you may need to calibrate your joystick
; -- ensuring it's properly centered -- to avoid cursor drift. A perfectly tight
; and centered joystick could use a value of 1:
JoyThreshold = 3
; Change the following to true to invert the Y-axis, which causes the mouse to
; move vertically in the direction opposite the stick:
InvertYAxis := false
; If your system has more than one joystick, increase this value to use a joystick
; other than the first:
JoystickNumber = 1
; Change these values to use joystick reassign the buttons on your controller to different actions
; Use the Joystick Test Script to find out your joystick's numbers more easily.
ButtonLeft = 5 ; Left click
ButtonCtrlLeft = 1 ; Ctrl Left click
ButtonRight = 6 ; Right click
ButtonI = 7 ; Open inventory I
ButtonTab = 8 ; Open minimap Tab
ButtonMovementSkill = 2 ; Movement skill E, adapted for flamedash
MovementSkillMulti = 12 ; 50 pixels x multiplier
ButtonMainSkill = 4 ; Send E
; <^> keys send q w e r

; END OF CONFIG SECTION -- Don't change anything below this point unless you want
; to alter the basic nature of the script.
#NoEnv							; Prevents bugs caused by environmental variables matching those in the script
#SingleInstance force           ; Makes it so only one copy can be ran at a time
SendMode Input		            ; Avoids the possible limitations of SendMode Play, increases reliability.
SetWorkingDir %A_ScriptDir%     ; Sets the script's working directory
SetDefaultMouseSpeed, 0         ; For character movement without moving the cursor
SetTitleMatchMode, 3            ; Window title must exactly match Winactive("Path of Exile")
SetFormat, float, 03  			; Omits decimal point from axis position percentages.
left_flag = 0
right_flag = 0

; Calculate the axis displacements that are needed to start moving the cursor:
JoyThresholdUpper := 50 + JoyThreshold
JoyThresholdLower := 50 - JoyThreshold
if InvertYAxis
    YAxisMultiplier = -1
else
    YAxisMultiplier = 1
	
; This section creates Hotkeys for Joystick Buttons that repeat the Key being used in subroutines below the auto-execute section
JoystickPrefix = %JoystickNumber%Joy
Hotkey, %JoystickPrefix%%ButtonLeft%, ButtonLeft
Hotkey, %JoystickPrefix%%ButtonRight%, ButtonRight
Hotkey, %JoystickPrefix%%ButtonI%, ButtonI
Hotkey, %JoystickPrefix%%ButtonTab%, ButtonTab
Hotkey, %JoystickPrefix%%ButtonMovementSkill%, ButtonMovementSkill
Hotkey, %JoystickPrefix%%ButtonCtrlLeft%, ButtonCtrlLeft
Hotkey, %JoystickPrefix%%ButtonMainSkill%, MainSkill
	
WinWaitActive, Path of Exile, , 60   	; this command waits 60 seconds for Path of Exile to be the active window before continuing
if ErrorLevel
{
    MsgBox, Path of Exile not started within the allotted time. Please run the script again then start Path of Exile
    ExitApp
}
else
{
		Sleep 500												; waits this long before initializing: this solves getting incorrect info
		x_anchor := 956					; sets the upper left x-plane coord in pixels
		y_anchor := 486					; sets the upper left y-plane coord in pixels
}	
SetTimer, DIII_Move, -1
SetTimer, DIII_Mouse, -1
SetTimer, WatchPOV, -1
return  ; End of auto-execute section.

; This section contains the subroutines for Hotkeys that need to send repeated keys while held down
ButtonCtrlLeft:
	SetMouseDelay, -1  ; Makes movement smoother.
	Send, {Ctrl Down}
	MouseClick, left,,, 1, 0, D  ; Hold down the left mouse button.
	SetTimer, WaitForCtrlLeftButtonUp, 10
return

WaitForCtrlLeftButtonUp:
	if GetKeyState(JoystickPrefix . ButtonLeft)
		return  ; The button is still, down, so keep waiting.
	; Otherwise, the button has been released.
	SetTimer, WaitForCtrlLeftButtonUp, Off
	SetMouseDelay, -1  ; Makes movement smoother.
	MouseClick, left,,, 1, 0, U  ; Release the mouse button.
	Send, {Ctrl Up}
return

ButtonLeft:
	SetMouseDelay, -1  ; Makes movement smoother.
	MouseClick, left,,, 1, 0, D  ; Hold down the left mouse button.
	SetTimer, WaitForLeftButtonUp, 10
return

WaitForLeftButtonUp:
	if GetKeyState(JoystickPrefix . ButtonLeft)
		return  ; The button is still, down, so keep waiting.
	; Otherwise, the button has been released.
	SetTimer, WaitForLeftButtonUp, Off
	SetMouseDelay, -1  ; Makes movement smoother.
	MouseClick, left,,, 1, 0, U  ; Release the mouse button.
return

ButtonRight:
	SetMouseDelay, -1  ; Makes movement smoother.
	MouseClick, right,,, 1, 0, D  ; Hold down the right mouse button.
	SetTimer, WaitForRightButtonUp, 10
return

WaitForRightButtonUp:
	if GetKeyState(JoystickPrefix . ButtonRight)
		return  ; The button is still, down, so keep waiting.
	; Otherwise, the button has been released.
	SetTimer, WaitForRightButtonUp, Off
	MouseClick, right,,, 1, 0, U  ; Release the mouse button.
return

; This section contains the Hotkeys that binds the joystick buttons to other actions in the game that don't need held down.
ButtonI:
	Send, {I}
return

ButtonTab:
	Send, {Tab}
return

ButtonMovementSkill:
	GetKeyState, joyX, %JoystickNumber%JoyX
	GetKeyState, joyY, %JoystickNumber%JoyY
	if (joyX < JoyThresholdLower) OR (joyX > JoyThresholdUpper) OR (joyY < JoyThresholdLower) OR (joyY > JoyThresholdUpper)
	{
		x_final := x_anchor + MovementSkillMulti * (joyX - 50)
		y_final := y_anchor + MovementSkillMulti * (joyY - 50)
		MouseMove, %x_final%, %y_final%, 0
		Send, {Space}
	}
return

MainSkill:
	Send {e down}
	Sleep, 100
	Send {e up}
return

; This timer watches for the triggers to be pressed and converts them into mouse clicks
WaitForLeftTriggerUp:
	GetKeyState, joyZ, %JoystickNumber%JoyZ 
	if joyZ > 60
	    return
	SetTimer, WaitForLeftTriggerUp, off
	Click left up
return

WaitForRightTriggerUp:
	GetKeyState, joyZ, %JoystickNumber%JoyZ 
	if joyZ < 40
	    return		
	SetTimer, WaitForRightTriggerUp, off
	Click right up
return

; This timer allows the D-pad (POV hat) to sent keypresses to be used for hotkeys
WatchPOV:
	if !WinActive("Path of Exile") 
	{
		SetTimer, DIII_Mouse, -500				; runs the timer less frequently if Diablo isn't the active window
		return
	}
	GetKeyState, POV, JoyPOV  ; Get position of the POV control.
	KeyToHoldDownPrev = %KeyToHoldDown%  ; Prev now holds the key that was down before (if any).
	; Some joysticks might have a smooth/continous POV rather than one in fixed increments.
	; To support them all, use a range:
	if POV < 0   ; No angle to report
		KeyToHoldDown =
	else if POV > 31500                 ; 315 to 360 degrees: Forward
		KeyToHoldDown = Q
	else if POV between 0 and 4500      ; 0 to 45 degrees: Forward
		KeyToHoldDown = Q
	else if POV between 4501 and 13500  ; 45 to 135 degrees: Right
		KeyToHoldDown = W
	else if POV between 13501 and 22500 ; 135 to 225 degrees: Down
		KeyToHoldDown = E
	else                                ; 225 to 315 degrees: Left
		KeyToHoldDown = R
	
	GetKeyState, joyZ, %JoystickNumber%JoyZ 
	
	; Watch for Left Trigger
	if joyZ > 60
	{	
		SetMouseDelay, -1  									
		Click left down  						
		SetTimer, WaitForLeftTriggerUp, 10
	}
	
	; Watch for Right Trigger
	if joyZ < 40
	{
		SetMouseDelay, -1  									
		Click right down 						
		SetTimer, WaitForRightTriggerUp, 10
	}	
	
	if KeyToHoldDown = %KeyToHoldDownPrev%  ; The correct key is already down (or no key is needed).
	{	
		SetTimer, WatchPOV, -10
		return  ; Do nothing.
	}	
	; Otherwise, release the previous key and press down the new key:
	SetKeyDelay -1  ; Avoid delays between keystrokes.
	if KeyToHoldDownPrev   ; There is a previous key to release.
		Send, {%KeyToHoldDownPrev% up}  ; Release it.
	if KeyToHoldDown   ; There is a key to press down.
		Send, {%KeyToHoldDown% down}  ; Press it down.
	
	SetTimer, WatchPOV, -10
return	

; This timer of the timer controls right stick mouse movements	
DIII_Mouse:
	if !WinExist("Path of Exile") 
	{
		SetTimer, DIII_Mouse, -500				; runs the timer less frequently if Diablo isn't the active window
		return
	}
	MouseNeedsToBeMoved := false  ; Set default.	
	GetKeyState, joyR, %JoystickNumber%JoyR
    GetKeyState, joyU, %JoystickNumber%JoyU
	
	if joyU > %JoyThresholdUpper%
	{
		MouseNeedsToBeMoved := true
		DeltaU := joyU - JoyThresholdUpper
	}
	else if joyU < %JoyThresholdLower%
	{
		MouseNeedsToBeMoved := true
		DeltaU:= joyU - JoyThresholdLower
	}
	else
		DeltaU = 0
	
	if joyR > %JoyThresholdUpper%
	{
		MouseNeedsToBeMoved := true
		DeltaR := joyR - JoyThresholdUpper
	}
	else if joyR < %JoyThresholdLower%
	{
		MouseNeedsToBeMoved := true
		DeltaR := joyR - JoyThresholdLower
	}
	else
		DeltaR = 0
	if MouseNeedsToBeMoved
	{
		SetMouseDelay, -1  ; Makes movement smoother.
		MouseMove, DeltaU * JoyMulti, DeltaR * JoyMulti * YAxisMultiplier, 0, R
	}
	SetTimer, DIII_Mouse, -10
return	

; This timer watches for left stick input then moves the character 
DIII_Move:
	if !WinActive("Path of Exile") 
	{
		SetTimer, DIII_Move, -500				; runs the timer less frequently if Diablo isn't the active window
		return
	}
	
	GetKeyState, joyX, %JoystickNumber%JoyX
	GetKeyState, joyY, %JoystickNumber%JoyY
	
	if GetKeyState("Shift", "P") ; this if/loop lets Shift still function as stand a stand still key
	{
		Loop
		{
			GetKeyState, state, Shift, P
			if state = U  
			break				
		}
	}
	else if (joyX < JoyThresholdLower) OR (joyX > JoyThresholdUpper) OR (joyY < JoyThresholdLower) OR (joyY > JoyThresholdUpper)
	{
	
		x_final := x_anchor + 2 * (joyX - 50)
		y_final := y_anchor + 2 * (joyY - 50)
		;MouseGetPos, x_initial, y_initial
		MouseMove, %x_final%, %y_final%, 0			; Move cursor to direction to be moved towards without clicking
		GetKeyState, joyZ, %JoystickNumber%JoyZ 
		if joyZ between 40 and 60 ;only send left key if right is up
			Send {LButton}								; sends Move command, you must set your Move keybind to match in game
		;MouseMove, %x_initial%, %y_initial%, 0  	; returns cursor to where it was before you issued joystick movement
	}
											
	SetTimer, DIII_Move, -10	
return	
