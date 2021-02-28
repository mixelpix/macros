#IfWinActive ahk_class FrontierDevelopmentsAppWinClass
SetKeyDelay, 100, 50
;reset power
RControl::
    send {AltDown}
    send {Right}
    send {space}
return

