#IfWinActive ahk_class FrontierDevelopmentsAppWinClass
;#Include Libraries/JSON.ahk
#include Libraries/Jxon.ahk

SetKeyDelay, 100, 50

global Merits := 50                          ; Number of Merits to collect
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
; =============================================
; 
; Be at a Station on the Contacts Screen with no Contact highlighted
; and press the key to start the Macr4o
; This will run until you hit the Macro start key again.
; By default it will buy 50 merits every 31 minutes  EVEN if your cargo is full it will try

LControl & q::
    ; Macro for Heelies
    #MaxThreadsPerHotkey, 1
    if Healies
    {
        TrayTip, Farming, Done Healies, 10
        Click, Up, Right
        Click, Up, Left
        Healies := False
        Return 
    }

    Healies := True
    TrayTip, Farming, Starting Healies Farming, 10
    Loop 
    {
        WinActivate, ahk_class FrontierDevelopmentsAppWinClass
        Click, Down Right   ; Activate Turrets
        Click, Down Left    ; Active Healing Beam
        Sleep, 5000
        if not Healies
            Break 
    }
    Healies := False 
return

;PageUp Macro to Relog Elite Dangerous 
LControl & a::
    Traytip, Relog, Session Flipping(Solo), 10
    ; Activate Elite Dangerous Window
    WinActivate ahk_class FrontierDevelopmentsAppWinClass
    Send {Esc}      ; Goto Menu
    Send {Up}       ; Up to loop down to Exit
    Send {Space}    ; Select Exit
    Send {Space}    ; Select Exit to Main Menu
    Sleep, 6000     ; Wait for the Mennu to load
    Send {Space}    ; Contine
    Sleep, 1000     ; Let the page load 
    Send {Right}    ; Move to Private Group
    Send {Right}    ; Move to Solo
    Send {Space}    ; Select Solo Mode
return

; Right Control key to start picking up Power Play Merits
RControl::
; Let's find the user home dir path so we can find our way to the Elite Dangerous Log Files
;    EnvGet, UserProfile, USERPROFILE
; Let's Prepend the users homedir to the Elite Dangerous Log files
;    JournalPath = %UserProfile%\Saved Games\Frontier Developments\Elite Dangerous\Journal*

    ;StartingCargo := GetCargo()
    ;Msgbox Cargo: %StartingCargo%
    ; return

    #MaxThreadsPerHotkey, 1
    if BuyMerits                        ; This means an underlying thread is already running the loop below
    {
        TrayTip, Merits, Done Buying Merits, 10     ;  Set tooltip to say we're stopping Merit buying
        BuyMerits := False              ; Signal the thread's loop to stop
        return                          ; End this thread so we can go back into hotkey mode
    }

    ; Otherwise Let's start buying Merits
    BuyMerits := True
    Loop
    {
        ; Activate Elite Dangerous Window
        WinActivate ahk_class FrontierDevelopmentsAppWinClass
        ; Let's Find out how much Cargo we have:
        StartingCargoCount := GetCargo()
        Traytip, Merits, Buying Merits Starting Cargo %StartingCargoCount%, 10
        Send {Left}
        Send {Left}
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
        Send {Left}                     ; Back to Contacts Screen
        Send {Space}                    ; Back to Contacts Page with Top Left contact Selected
        Send {Left}                     ; Back to Contacts with no contacts selected so we know where to start
        Send {Left}
        EndingCargoCount := GetCargo()
        Traytip, Merits, Buying Merits Ending Cargo %EndingCargoCount%, 10

        Sleep, %Sleeptime%              ; Wait for 31 minutes to pick up the next batch
        EndingCargoCount := GetCargo()
        if (EndingCargoCount = StartingCargoCount)
        {
            Traytip, Merits, Cargo Full - EXITING %EndingCargoCount% : %StartingCargoCount%, 10          
            BuyMerits := False
            Break 
        }
        Else
        if not BuyMerits                ; We pressed the activation sequence again to stop the buying process
            Break                       ; Break out of this loop
    }
    BuyMerits := False                  ; Reset in preparation for the next press of this hotkey
    return

; ==================================================================
; Funtions/Subroutines
;
    GetCargo()
    {
        EnvGet, UserProfile, USERPROFILE
        CargoFile = %UserProfile%\Saved Games\Frontier Developments\Elite Dangerous\Cargo.json
        FileReadLine, CargoLine, %CargoFile%, 1
        Cargo := Jxon_Load(CargoLine)
        Return Cargo.Count 
    }