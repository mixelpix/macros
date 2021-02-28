#IfWinActive ahk_class FrontierDevelopmentsAppWinClass

SetKeyDelay, 100, 50

global Merits := 50                         ; Number of Merits to collect
; Sleep Durations
; 1 Second = 1000
; 1 Minutes = 60000
; 1 Hour = 3600000
global SleepMinutes := 31                    ; Minutes to sleep between buys
global Sleeptime := SleepMinutes * 60000 ; 31 = Minutes  60000 is Milliseconds
#MaxThreadsPerHotkey, 3
;
; Change this to whatever activation key you want
; Press the key once to start the Merit Buying, again to stop it.
; Right Control key to start picking up Power Play Merits
RControl::

#MaxThreadsPerHotkey, 1
if BuyMerits                        ; This means an underlying thread is already running the loop below
{
    Tooltip, Stop Buying Merits     ;  Set tooltip to say we're stopping Merit buying
    BuyMerits := False              ; Signal the thread's loop to stop
    return                          ; End this thread so we can go back into hotkey mode
}

; Otherwise Let's start buying Merits
BuyMerits := True
Loop
{
    ToolTip, Buying Merits
    Send {Right}                    ; right to Contacts
    Send {Down}                     ; down to Power Play
    Send {Space}                    ; Seelct the Power Play Contact
    Sleep, 1000                     ; Wait for screen update
    Send {Down}                     ; Down to first option
    loop, %Merits%                  ; select up to 50 Firitifcation Items
    {
        Send {Right} ; 
    }
    Send {Space}                    ; Pick up the items
    Send {space}                    ; Move to previous screen
    Sleep, 1000                     ; Wait for screen delay
    Send {left}                     ; Back to Contacts Screen
    Send {space}                    ; Back to Contacts Page with Top Left contact Selected
    Send {left}                     ; Back to Contacts with no contacts selected so we know where to start
    Send {Left}
    Sleep, %Sleeptime%              ; Wait for 31 minutes to pick up the next batch
    if not BuyMerits                ; We pressed the activation sequence again to stop the buying process
        Break                       ; Break out of this loop
}
BuyMerits := False                  ; Reset in preparation for the next press of this hotkey
return