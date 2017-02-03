#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
;#Persistent
#SingleInstance
;#Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

ie := ComObjCreate("InternetExplorer.Application")  ;// Create an IE object
ie.Visible := true                                  ;// Make the IE object visible

ComObjConnect(ie)   ;// Connects the webbrowser object
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

;TrayTip, Timed TrayTip, Pointage réussi!
;SetTimer, RemoveTrayTip, 3000
;return

;RemoveTrayTip:
;SetTimer, RemoveTrayTip, Off
;TrayTip
ExitApp

OnError()
{
	MsgBox, Impossible de pointer. Mise à jour du script probablement nécessaire.`rContinuez votre pointage manuellement.
	ExitApp
}