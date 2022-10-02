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
ApplicationVersion := "0.1.0"
ApplicationACC := "AC2"

;===== Configuration variables =====
inifile = %ApplicationName%.ini
IniRead, ReplayLength, %inifile%, Default, ReplayLength, 60 ; auto replay length in minutes
IniRead, ReplayHotkey, %inifile%, Default, ReplayHotkey, m ; hotkey for saving replays
IniRead, TerminationHotkey, %inifile%, Default, TerminationHotkey, +x ; hotkey for terminating the script (shift + x)

;===== Script =====
; Add hotkey for terminating the script
Hotkey, %TerminationHotkey%, TerminateScript

; Show current configuration options
ConfigMessage = 
(
Welcome to %ApplicationName% v%ApplicationVersion%

Replay length: %ReplayLength% minutes
Replay hotkey: %ReplayHotkey%
Termination hotkey: %TerminationHotkey%

You can edit these settings in %A_WorkingDir%\%inifile%
)
MsgBox, 0, %ApplicationName% - Settings, %ConfigMessage%

; Ask for current race length, used for number of save replay iterations
InputBox, RaceLength, %ApplicationName% - Setup, Enter the race length (in minutes).
if ErrorLevel
  Exit

; Check if race length is valid
if RaceLength is not integer 
{
  MsgBox, 0, %ApplicationName%, %RaceLength% is not a valid input. Exiting programm!
  Exit
}

If (RaceLength <= ReplayLength)
{
  MsgBox, 0, %ApplicationName%, %RaceLength% minutes is shorter than the auto replay length. No additional replay saves required. Exiting programm!
  Exit
}

WinWaitActive, %ApplicationACC%

; Send hotkey in an interval based on race length and replay length
Iterations := Ceil(RaceLength / ReplayLength) + 1
While (A_Index <= Iterations) {
  if (A_Index = 1) {
    Continue
  }

  if WinActive(ApplicationACC) {
    OutputDebug, Saving replay (Index: %A_Index%)
    Send {%ReplayHotkey%}
  } else {
    MsgBox, 0, %ApplicationName% - Error, Replay could not be saved because ACC is not the active window, 3
  }
  Sleep, ReplayLength * 60000 ; 60000ms = 60s
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