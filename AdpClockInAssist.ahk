#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#Persistent
#SingleInstance
#Warn  ; Enable warnings to assist with detecting common errors.

SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.


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
	Menu, Tray, Add, % I18n("quit"), OnQuit
	Menu, Tray, Tip, Test`Test2
}

OnQuit() {
	ExitApp
}


;TrayTip, Timed TrayTip, Pointage réussi!
;SetTimer, RemoveTrayTip, 3000
;return

;RemoveTrayTip:
;SetTimer, RemoveTrayTip, Off
;TrayTip

OnClockIn() {
	ie := ComObjCreate("InternetExplorer.Application")  ;// Create an IE object
	ie.Visible := true                                  ;// Make the IE object visible

	ComObjConnect(ie)
	ie.Navigate("https://pointage.adp.com/")
	while ie.ReadyState <> 4
		continue
		
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
}

OnError() {
	MsgBox, Impossible de pointer. Mise à jour du script probablement nécessaire.`rContinuez votre pointage manuellement.
	ExitApp
}