; Records via OBS if any game is opened, and stops recording when all games are closed.

#SingleInstance Ignore
Persistent

; ------------------------- CONFIG ------------------------- ;

; Games
GameClientTitles := [
  "VALORANT",
  "League of Legends",
  "League of Legends (TM) Client",
]
GameClientEXEs := []

; Toast notification duration in seconds
ShortToastDuration := 5
LongToastDuration := 10

; Show toast notification on startup when storage limit is exceeded
ShowStorageExceededAlert := true
MaxStorageGB := 200 ;Gigabytes
RecordingsDir := "C:\Users\jason\Videos\OBS" ;No trailing backslash

; Hotkeys
StartRecordingHotKeyCombination := ["Alt", ","]
StopRecordingHotKeyCombination := ["Alt", "."]

; OBS Studio executable name
OBSStudioEXE := "obs64.exe"

; Script icon
IconPath := "JuiceExcel.ico"

; -------------------- HELPER FUNCTIONS -------------------- ;

; KeysDown() takes an array of keys and presses all of them down.
KeysDown(keys) {
  for _, key in keys {
    Send "{" key " down}"
  }
}

; KeysUp() takes an array of keys and releases all of them.
KeysUp(keys) {
  for _, key in keys {
    Send "{" key " up}"
  }
}

; Toast() renders a toast notification with the given message and duration in seconds.
Toast(Message, Seconds) {
  Toast := Gui("+AlwaysOnTop +Disabled -Caption +Border")
  Toast.BackColor := "222222"
  Toast.SetFont("Cde9a47 S18 W700", "Verdana")
  Toast.AddText(, "Juice Clips")
  Toast.SetFont("Cde9a47 S14 W400", "Verdana")
  Toast.AddText(, Message)
  Toast.Show("X20 Y20 NoActivate Hide")

  ; Windows API AnimateWindow Values: https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-animatewindow
  AW_BLEND := 0x80000
  AW_HIDE := 0x10000
  OpenToast() {
    DllCall("AnimateWindow", "ptr", WinExist(Toast), "uint", 400, "uint", AW_BLEND)
  }
  CloseToast() {
    DllCall("AnimateWindow", "ptr", WinExist(Toast), "uint", 400, "uint", AW_BLEND|AW_HIDE)
  }

  OpenToast()
  SetTimer(CloseToast, -1000 * Seconds)
}

; ----------------------- DRIVER CODE ----------------------- ;

if FileExist(IconPath) {
  TraySetIcon(IconPath)
}
A_IconTip := "Juice Clips"

if ShowStorageExceededAlert {
  DirSize := 0
  Loop Files, RecordingsDir "\*.*", "R" {
    DirSize += A_LoopFileSizeMB
  }
  DirSizeGB := DirSize / 1000
  if DirSizeGB > MaxStorageGB {
    Toast("Your capacity of " Round(MaxStorageGB, 1) "GB has been exceeded by " Round(DirSizeGB - MaxStorageGB, 1) "GB. Delete some files from`n" RecordingsDir "`nto make space for more recordings.", LongToastDuration)
  }
}

for _, GameClientTitle in GameClientTitles {
  GroupAdd "GameClients", GameClientTitle
}

for _, GameClientEXE in GameClientEXEs {
  GroupAdd "GameClients", "ahk_exe " GameClientEXE
}

SetTitleMatchMode(3)

Loop {
  WinWait("ahk_group GameClients")
    DetectHiddenWindows(1)
    if WinExist("ahk_exe " OBSStudioEXE) {
      KeysDown(StartRecordingHotKeyCombination)
      Sleep 300
      KeysUp(StartRecordingHotKeyCombination)
      Toast("Started recording.", ShortToastDuration)
    } else {
      Toast("Attempted to start recording, but OBS Studio is not open. Please open`nthe application and start recording manually.", LongToastDuration)
    }
    DetectHiddenWindows(0)
  WinWaitClose("ahk_group GameClients")
    DetectHiddenWindows(1)
    if WinExist("ahk_exe " OBSStudioEXE) {
      KeysDown(StopRecordingHotKeyCombination)
      Sleep 300
      KeysUp(StopRecordingHotKeyCombination)
      Toast("Stopped recording.", ShortToastDuration)
    } else {
      Toast("Attempted to stop recording, but OBS Studio is not open. Results may`nnot have been saved.", LongToastDuration)
    }
    DetectHiddenWindows(0)
}