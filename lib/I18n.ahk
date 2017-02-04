; https://autohotkey.com/board/topic/50131-simple-internationalization-function/
global _locale_

I18n(msg_key, p0 = "-0", p1 = "-0", p2 = "-0", p3 = "-0", p4 = "-0")
{
	IniRead, msg, % "i18n.ini", % _locale_, % msg_key, % msg_key

	If (msg = "ERROR" OR msg = "") 
		Return % msg_key
	StringReplace, msg, msg, `\n, `r`n, ALL
	StringReplace, msg, msg, `\t, % A_Tab, ALL
	Loop 3
	{
		idx := A_Index - 1
		IfNotEqual, p%idx%, -0
			msg := RegExReplace(msg, "\{" . idx . "\}", p%idx%)
	}

	Return % msg
}