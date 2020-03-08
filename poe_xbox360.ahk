/*
Default Controls:
Move = Left Analog Stick
Mouse Control = Right Analog Stick
Left DPAD Q W E R
X - Ctrl click
O - Dash (Space)
[] - Flasks 
/\ - Gem Swap (1j4)
Left Mouse/Skill Dash (Space + M3) = L1/L2
Right Mouse/Skill Main Skill A = R1/R2
*/

; BEGIN CONFIG SECTION
; Increase the following value to make the mouse cursor move faster:
JoyMulti = .5
; Decrease the following value to require less joystick displacement-from-center
; to start moving the mouse.  However, you may need to calibrate your joystick
; -- ensuring it's properly centered -- to avoid cursor drift. A perfectly tight
; and centered joystick could use a value of 1:
JoyThreshold = 5
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
MovementMulti = 1
ButtonMovementSkill = 2 ; Movement skill Space, adapted for flamedash
MovementSkillMulti = 3 ; 50 pixels x multiplier
MainSkillMulti = 6 ; Summon skeletons ahead
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
CanMoveCharacter := true

; Calculate the axis displacements that are needed to start moving the cursor:
JoyThresholdUpper := 50 + JoyThreshold
JoyThresholdLower := 50 - JoyThreshold
	
; This section creates Hotkeys for Joystick Buttons that repeat the Key being used in subroutines below the auto-execute section
JoystickPrefix = %JoystickNumber%Joy
Hotkey, %JoystickPrefix%%ButtonLeft%, ButtonLeft
Hotkey, %JoystickPrefix%%ButtonRight%, ButtonRight
Hotkey, %JoystickPrefix%%ButtonI%, ButtonI
Hotkey, %JoystickPrefix%%ButtonTab%, ButtonTab
Hotkey, %JoystickPrefix%%ButtonMovementSkill%, ButtonMovementSkill
Hotkey, %JoystickPrefix%%ButtonCtrlLeft%, ButtonCtrlLeft
	
WinWaitActive, Path of Exile, , 600000   	; this command waits 60 seconds for Path of Exile to be the active window before continuing
if ErrorLevel
{
    MsgBox, Path of Exile not started within the allotted time. Please run the script again then start Path of Exile
    ExitApp
}
else
{
	Sleep 500						; waits this long before initializing: this solves getting incorrect info
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
	FireMovementSkill()
return

; Move cursor in direction using analog stick data
ExtendCursor(multi)
{
	global JoyThresholdLower
	global JoyThresholdUpper
	global x_anchor
	global y_anchor
	GetKeyState, joyX, %JoystickNumber%JoyX
	GetKeyState, joyY, %JoystickNumber%JoyY
	;msgbox %joyX% . %joyY%
	if joyX between JoyThresholdLower and JoyThresholdUpper
	{
		if joyY between JoyThresholdLower and JoyThresholdUpper
		{
			return false
		}
	}
	if (joyX < JoyThresholdLower or joyX > JoyThresholdUpper) or (joyY < JoyThresholdLower or joyY > JoyThresholdUpper)
	{
		x_final := x_anchor + multi * (joyX - 50)
		y_final := y_anchor + multi * (joyY - 50)
		SetMouseDelay, -1
		MouseMove, %x_final%, %y_final%, 0
		return true
	}
	return false
}

; This timer allows the D-pad (POV hat) to sent keypresses to be used for hotkeys
WatchPOV:
	if !WinActive("Path of Exile") 
	{
		SetTimer, DIII_Mouse, -500				; runs the timer less frequently if Diablo isn't the active window
		return
	}

	GetKeyState, joyZ, %JoystickNumber%JoyZ 
	; Watch for Left Trigger
	if joyZ > 60
	{									
		FireMovementSkill()
	}
	; Watch for Right Trigger
	if joyZ < 40
	{
		FireMainSkill()
	}
	
	GetKeyState, POV, JoyPOV  ; Get position of the POV control.
	; Some joysticks might have a smooth/continous POV rather than one in fixed increments.
	; To support them all, use a range:
	if POV < 0   ; No angle to report
		KeyToHoldDown = 0
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

	if joyZ between 40 and 60
	{
		if KeyToHoldDown != 0
		{
			Send {%KeyToHoldDown% down}
			Sleep, 100
			Send {%KeyToHoldDown% up}
		}
	}

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
		MouseMove, DeltaU * JoyMulti, DeltaR * JoyMulti, 0, R
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

	if CanMoveCharacter
	{
		if ExtendCursor(MovementMulti)
		{
			Send {LButton}
		}
	}

	SetTimer, DIII_Move, -10
return	

FireMainSkill()
{
	global MainSkillMulti, CanMoveCharacter

	CanMoveCharacter := false
	ExtendCursor(MainSkillMulti)
	Send {a down}
	Sleep 100
	Send {a up}
	CanMoveCharacter := true
}

FireMovementSkill()
{
	global MovementSkillMulti, CanMoveCharacter
	
	CanMoveCharacter := false
	if ExtendCursor(MovementSkillMulti)
	{
		Send, {Space}
		Sleep, 100
		Send, {MButton}
	}
	CanMoveCharacter := true
}
