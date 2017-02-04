#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#Persistent
#SingleInstance
#Warn  ; Enable warnings to assist with detecting common errors.

SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

FileCreateDir, %A_AppData%\ADPClockInAssist

InitI18n()
CreateSysTrayMenu()

return




InitI18n() {
	hostLocale = %A_Language%
	IniRead, foundTranslation, % "i18n.ini", hostLocale; TODO centralize i18n filename somewhere
	
	if (!foundTranslation)
		_locale_ = 0409
	else
		_locale_ = hostLocale
}

CreateSysTrayMenu() {
	Menu, Tray, NoStandard
	Menu, Tray, Add, % I18n("clockin"), OnClockIn
	Menu, Tray, Add
	Menu, Tray, Add, % I18n("quit"), OnQuit

	UpdateTrayIconTooltip()
}

OnQuit() {
	ExitApp
}

OnClockIn() {
	TrayTip, % "ADP Clock In Assist" , % I18n("clockin.success") 
	return

	ie := ComObjCreate("InternetExplorer.Application")
	ie.Visible := false

	ComObjConnect(ie)
	ie.Navigate("https://pointage.adp.com/")
	while ie.ReadyState <> 4
		continue
    
	; Example of running JS on current page
	; ie.document.parentWindow.execScript("document.getElementById('login').value = 'lol'") 
		
	Send {Enter} ;// Assumes login/pass are saved in IE

	While ie.readyState != 4 || ie.document.readyState != "complete" || ie.busy
		Sleep, 10

	try 
	{
		ie.document.getElementsByClassName("bouton_bg")[0].children[0].click()
	} 
	catch e 
	{
		Sleep, 500
		try {
			ie.document.getElementsByClassName("bouton_bg")[0].children[0].click()
		}
		catch e
		{
			OnError()
		}
	}

	While ie.readyState != 4 || ie.document.readyState != "complete" || ie.busy
		Sleep, 10

	try 
	{
		ie.document.getElementsByClassName("bouton")[0].click()
	} 
	catch e 
	{
		Sleep, 500
		try 
		{
			ie.document.getElementsByClassName("bouton")[0].click()
		} 
		catch e 
		{
			OnError()
		}
	}

	While ie.readyState != 4 || ie.document.readyState != "complete" || ie.busy
		Sleep, 10

	ie.Quit()

	UpdateHistoryOnDisk()
}

UpdateHistoryOnDisk() {
	; Deleting content of history.txt if the date changed
	historyDate = ""
	FormatTime, currentDate,, yyyy.MM.dd
	FileReadLine, historyDate, %A_AppData%\ADPClockInAssist\history.txt, 1

	if (historyDate != currentDate) {
		FileDelete, %A_AppData%\ADPClockInAssist\history.txt
		FileAppend, % currentDate . "`n", %A_AppData%\ADPClockInAssist\history.txt
	}
	
	FormatTime, currentTime,, HH:mm
	FileAppend, % currentTime . "`n", %A_AppData%\ADPClockInAssist\history.txt

	UpdateTrayIconTooltip()
}

UpdateTrayIconTooltip() {
	history = 
	timeSepatator = :
	Loop, read, %A_AppData%\ADPClockInAssist\history.txt 
	{
    	if (InStr(A_LoopReadLine, timeSepatator))
		{
			history .= A_LoopReadLine "`n"
		}
	}

	Menu, Tray, Tip, % history
}

OnError() {
	MsgBox, Impossible de pointer. Mise à jour du script probablement nécessaire.`rContinuez votre pointage manuellement.
	ExitApp
}