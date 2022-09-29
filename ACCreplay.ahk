; Recommended for performance and compatibility with future AutoHotkey releases.
#NoEnv
; Enable warnings to assist with detecting common errors.
#Warn
; Skips the dialog box and replaces the old instance automatically
#SingleInstance Force

; Recommended for new scripts due to its superior speed and reliability.
SendMode Input
SetWorkingDir %A_ScriptDir%
OnExit("ExitFunc")

;====== Global variables =====
ApplicationName := "ACCreplay"

;===== Configuration variables =====
inifile = %ApplicationName%.ini
IniRead, ReplayLength, %inifile%, Default, ReplayLength, 60 ; replay length in minutes
IniRead, ReplayHotkey, %inifile%, Default, ReplayHotkey, m ; hotkey for saving replays
IniRead, TerminationHotkey, %inifile%, Default, TerminationHotkey, +t ; hotkey for terminating the script (shift + t)

;===== Script =====
; Add hotkey for terminating the script
Hotkey, %TerminationHotkey%, TerminateScript

; Show current configuration options
ConfigMessage = 
(
Replay length: %ReplayLength% minutes
Replay hotkey: %ReplayHotkey%
Termination hotkey: %TerminationHotkey%

You can edit these configurations in %A_WorkingDir%\%inifile%
)
MsgBox, 0, %ApplicationName% - Settings, %ConfigMessage%

; Ask for current race length, used for number of save replay iterations
InputBox, RaceLength, %ApplicationName% - Setup, Enter the race length (in hours).
if ErrorLevel
  Exit

; Check if race length is valid
if RaceLength is not integer 
{
  MsgBox, 0, %ApplicationName%, %RaceLength% is not a valid input. Exiting programm!
  Exit
}

If RaceLength not between 1 and 24 
{
  MsgBox, 0, %ApplicationName%, %RaceLength% is not a valid race length. Exiting programm!
  Exit
}

; Send hotkey in an interval based on race length and replay length
Iterations := RaceLength + 1
Loop %Iterations% {
  if (A_Index != 1) {
    OutputDebug, Saving replay (Index: %A_Index%)
    Send {%ReplayHotkey%}
  }
  Sleep, (ReplayLength - 1) * 60000 ; Save replay one minute early to prevent data loss
}
Exit

TerminateScript:
ExitApp

;===== Functions =====
ExitFunc(ExitReason, ExitCode)
{
  global ApplicationName
  if ExitReason not in Logoff,Shutdown,Single
  {
    MsgBox, 4, %ApplicationName%, Are you sure you want to exit?
    IfMsgBox, No
    return 1 ; OnExit functions must return non-zero to prevent exit.
  }
  ; Do not call ExitApp -- that would prevent other OnExit functions from being called.
}