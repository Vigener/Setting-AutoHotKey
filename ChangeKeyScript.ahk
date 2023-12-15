; メモ
; ; vkBB
; : vkBA
; , vkBC
; ^ Ctrl
; + Shift
; ! Alt
; # Win
; vk1D 無変換
; vk1C 変換

; a::msgbox % "Your AHK version is " A_AhkVersion

; >>>事前準備関連
;#InstallKeybdHook
#UseHook
;IMEのON/OFF に関する関数の定義
IME_SET(SetSts, WinTitle="A") {
    ControlGet,hwnd,HWND,,,%WinTitle%
    if	(WinActive(WinTitle))	{
        ptrSize := !A_PtrSize ? 4 : A_PtrSize
        VarSetCapacity(stGTI, cbSize:=4+4+(PtrSize*6)+16, 0)
        NumPut(cbSize, stGTI, 0, "UInt") ;	DWORD   cbSize;
        hwnd := DllCall("GetGUIThreadInfo", Uint,0, Uint,&stGTI)
        ? NumGet(stGTI,8+PtrSize,"UInt") : hwnd
    }

    return DllCall("SendMessage"
    , UInt, DllCall("imm32\ImmGetDefaultIMEWnd", Uint,hwnd)
    , UInt, 0x0283 ;Message : WM_IME_CONTROL
    , Int, 0x006 ;wParam  : IMC_SETOPENSTATUS
    , Int, SetSts) ;lParam  : 0 or 1
}
;-----------------------------------------------------------
; IMEの状態の取得
; WinTitle="A" 対象Window
; 戻り値 1:ON / 0:OFF
;-----------------------------------------------------------
IME_GET(WinTitle="A") {
    ControlGet,hwnd,HWND,,,%WinTitle%
    if (WinActive(WinTitle)) {
        ptrSize := !A_PtrSize ? 4 : A_PtrSize
        VarSetCapacity(stGTI, cbSize:=4+4+(PtrSize*6)+16, 0)
        NumPut(cbSize, stGTI, 0, "UInt") ; DWORD cbSize;
        hwnd := DllCall("GetGUIThreadInfo", Uint,0, Uint,&stGTI)
        ? NumGet(stGTI,8+PtrSize,"UInt") : hwnd
    }
    return DllCall("SendMessage"
      , UInt, DllCall("imm32\ImmGetDefaultIMEWnd", Uint,hwnd)
      , UInt, 0x0283  ;Message : WM_IME_CONTROL
      ,  Int, 0x0005  ;wParam  : IMC_GETOPENSTATUS
      ,  Int, 0)      ;lParam  : 0
}
; <<<

; >>>キー割当の記述

; テスト実装

; AHKの設定
;頻繁にスクリプトを変える場合に便利
vk1D & 0::Reload		;このスクリプトをリロードして適用
vk1D & 8::Edit		;このスクリプトを編集

; Hotstring関係
#Hotstring *
#Hotstring O
::m@@::vgnrieee@gmail.com
::m//::vgnrieee@gmail.com
::m@s::s2310970@u.tsukuba.ac.jp
::m/s::s2310970@u.tsukuba.ac.jp
::m@u::s2310970@u.tsukuba.ac.jp
::m/u::s2310970@u.tsukuba.ac.jp
::t@@::08021311283
::t//::08021311283
::i@@::202310970
::i//::202310970
::n//::五十嵐尊人
::d//::
    FormatTime, dateStr, , yyyy/MM/dd
    Send, %dateStr%
Return ;日付を入力 ex)2000/01/01
::d--::
    FormatTime, dateStr, , yyyy-MM-dd
    Send, %dateStr%
Return ;日付を入力 ex)2000-01-01


;色々便利な設定0
;IMEのON/OFF
vk1D::IME_SET(0) ;無変換キーで英語入力に
vk1C::IME_SET(1) ;変換キーで日本語入力に
;Ctrl+変換キーで日本語入力・英語入力どちらの場合でも打ち始めた文字を削除
Ctrl & BackSpace::
    ime := IME_GET()
    If (ime) {
        Send, ^z
    } Else {
        Send, ^{BackSpace}
    }
Return
;Ctrl+DeleteでIMEの切り替え
Ctrl & Delete::
    ime := IME_GET()
    If (ime) {
        IME_SET(0)
    } Else {
        IME_SET(1)
    }

;変換キー関連
; 変換キーと＠でBackSpace×3
vk1C & @::Send, {Blind}{BackSpace}{BackSpace}{BackSpace}
;変換キーとi,k,j,lでカーソル移動　変換キーと;,:で左右クリック
; vk1C & vkBB::MouseClick,Left
vk1C & u::MouseClick,Left
; vk1C & vkBA::MouseClick,Right
vk1C & o::MouseClick,Right
vk1C & i::
vk1C & j::
vk1C & k::
vk1C & l::
    While (GetKeyState("vk1C", "P"))			;式を評価した結果が真である間、一連の処理を繰り返し実行する
    {
        MoveX := 0, MoveY := 0
        MoveY += GetKeyState("i", "P") ? -11 : 0	;GetKeyState() と ?:演算子(条件) (三項演算子) の組み合わせ
        MoveX += GetKeyState("j", "P") ? -11 : 0
        MoveY += GetKeyState("k", "P") ? 11 : 0
        MoveX += GetKeyState("l", "P") ? 11 : 0
        MouseMove, %MoveX%, %MoveY%, 0, R		;マウスカーソルを移動する
        Sleep, 0 				;負荷が高い場合は設定を変更 設定できる値は-1、0、10～m秒 詳細はSleep
    }
Return

;vivaldi用の設定
Ctrl & o::
    If (GetKeyState("Space", "P")) {
        Send, +^o
    } Else {
        Send, ^o
    }
Return ;サイドパネルでメモを開く用
Ctrl & i::
    If (GetKeyState("Space", "P")) {
        Send, !^q
    } Else {
        Send, ^i
    }
Return ;サイドパネルでstackeditを開く用
vk1D & w::Send, !w ;ウィンドウパネルを開く用のAlt+wに無変換+wを割り当て

;CapsLockキーにCtrlキーの仕事をさせる
; Capslock::Ctrl
; sc03a::Ctrl
; Q::Send, {Ctrl}{Tab}

;改行系

; Enterキーの入力簡略化案

; vkBB::
;     If (A_PriorHotkey == Space and A_TimeSincePriorHotkey < 500){
;         Send, {Enter}
;     } Else{
;         Send, {vkBB}
;     }
; Return

; vkBA::
;     If (A_PriorHotkey == Space and A_TimeSincePriorHotkey < 500){
;         Send, {Blind}{Enter}
;     } Else {
;         Send, {vkBA}
;     }
; Return

; Space::
;     Send,{Blind}{Space}
;     Return
; Space & vkBB::
;     If (GetKeyState("Shift", "P")){
;         If (GetKeyState("vk1D", "P")) {
;             Send, {Up}{End}{Enter}
;         } Else {
;             Send, {End}{Enter}
;         }
;     } Else {
;         Send, {Blind}{Enter}
;     }
;     Return
; Space & vkBA::
;     Send, {Blind}{Enter}
;     Return
; vk1C & vkBB::
;     Send, {Blind}{Enter}
;     Return
; vk1C & vkBA::
;     Send, {Blind}{Enter}
;     Return

;[無変換]

; 行挿入(Ctrlを押している場合は、現在の行の上に、押していない場合は行の下に挿入)
vk1D & Enter::
    If (GetKeyState("Ctrl", "P")) {
        Send, {Up}{End}{Enter}
    } Else {
        Send, {End}{Enter}
    }
Return

; うまくいってない
; ; 無変換+Aでalt+Tab
; IsCtrlTabMenu := false

; ; 無変換キーが押された時の処理
; ~vk1D::
;     IsCtrlTabMenu := true
;     SetTimer, CheckCtrlTabMenu, 10
;     Return

; ; 無変換キーが離された時の処理
; ~vk1D Up::
;     IsCtrlTabMenu := false
;     SetTimer, CheckCtrlTabMenu, Off
;     Return

; ; Aキーが押された時の処理
; ~a::
;     If (IsCtrlTabMenu = true) {
;         Send, ^{Tab}
;     } else {
;         Send, a
;     }
;     Return

; ; タイマーが経過した時の処理
; CheckCtrlTabMenu:
;     If (IsCtrlTabMenu = true) {
;         Send, ^{Tab}
;     }
;     Return

;無変換+d*2で一行選択+その行を削除+その行をコピー
; vk1D & d::Send, ^x
; Send {BackSpace}
; If (A_PriorHotkey == A_ThisHotkey and A_TimeSincePriorHotkey < 1000){
;     Send {Home}
;     Send +{End}
;     Send ^X
;     Send {BackSpace}
; }

;編集系（左手）
vk1D & s::
    GetKeyState, state, vk1C	;Ctrlではホイールがズームになることが多い
    if state = U
        Send,{Blind}{Home}		;Home
    else if state = D
        Send,{Blind}{WheelLeft}		;マウスホイール←
return
; vk1D & f::
;     GetKeyState, ConvState, vk1D
;     GetKeyState, shiftState, Shift
;     if ConvState = U
;     {
;         if shiftState = D
;             Send, ^{Right} ; 右Shiftが押されている場合、Ctrl+右矢印を送信
;         else
;             Send, {Blind}{End} ; それ以外の場合、Endを送信
;     }
;     else if ConvState = D
;         Send, {Blind}{WheelRight} ; 変換キーが押されている場合、マウスホイール→を送信
; return
vk1D & f::Send, {Blind}{End} ;End

vk1D & e::
    GetKeyState, state, vk1C
    if state = U
        Send,{Blind}{PgUp}		;PageUp
    else if state = D
        Send,{Blind}{WheelUp}		;マウスホイール↑
return
; vk1D & d::
; 	GetKeyState, state, vk1C
; 	if state = U
; 		Send,{Blind}{PgDn}		;でPageDown
; 	else if state = D
; 		Send,{Blind}{WheelDown}		;マウスホイール↓
; return

;編集系(その他)
; vk1D & g::
;     GetKeyState, state, vk1C
;     if state = U
;         Send,{Blind}{Up}{Home}		;上の行頭へ
;     else if state = D
;         Send,{Up}{End}{Enter}		;上に1行増やしその頭へ
; return
;下の行も同様にしたいが、とりあえずコピーとかぶるのでCapsのコピーとどっちが楽か比べて必要なければ移行する

;編集系(右手)
;十字キーの設定
; vk1D & J::Send,{Blind}{Left}
; vk1D & L::Send,{Blind}{Right}
; vk1D & I::Send,{Blind}{Up}
; vk1D & K::Send,{Blind}{Down}
vk1D & H::Send,{Blind}{Left}
vk1D & J::Send,{Blind}{Down}
vk1D & K::Send,{Blind}{Up}
vk1D & L::Send,{Blind}{Right}

vk1D & N::Send, ^z ;もとに戻す
vk1D & M::Send, ^y ;やり直す
vk1D & c::Send, ^c		;コピー
vk1D & d::Send, {Blind}{Home}+{End}		;1行選択
vk1D & V::Send, ^V
vk1D & X::Send, ^X
;文字入力系
vk1D & vkBB::Send,{Enter}
vk1D & vkBA::Send,{Enter}
vk1D & P::Send,{BackSpace}
vk1D & O::Send,{BackSpace}
vk1D & @::Send,{Del}
vk1D & Q::Send,{Esc}
;アプリケーション移動系等
IsWinTabMenu := false
; vk1D & R::Send {LWinDown}{Tab} ;いまいちうまく行かない
; vk1D & H::Send,!{Left}
; vk1D & Y::Send,!{Right}

; vk1D & w::WinActivate, ahk_exe cmd.exe
vk1D & g::Run,C:\Users\vgnri\AppData\Local\Fit Win\fitwin\fitwin.exe

; vk1D::
;     Input,MyCommands,I T1 L2, {Esc},b,w,re,e,f
;     If MyCommands = b
;     {
;         IsOpenChrome()
;     } Else If MyCommands = w
;     {
;         WinActivate, ahk_exe mintty.exe
;     } Else If MyCommands = re
;     {
;         Reload
;     } Else If MyCommands = e
;     {
;         ; tablacusexplorer を開く
;         Run, D:\tablacusexplorer\TE64.exe
;     } Else If MyCommands = f
;     {
;         Run,D:\fitwin\fitwin.exe
;     }
; return

; ｢Alt｣+｢Tab｣のタスク切り替えを便利に
IsAltTabMenu := false
!Tab::
    Send !^{Tab}
    IsAltTabMenu := true
return

TenKey := false

; カタカナひらがなローマ字キー2連打でAltTabMenuキーとして割当
vkF2::
    If (A_PriorHotKey == A_ThisHotKey and A_TimeSincePriorHotkey < 500){
        Send !^{Tab}
        IsAltTabMenu := true
        ; } else {
        ;     ; vkF2が単独でクリックされた場合の動作
        ;     Send, {Blind}{Ctrl}
    }
return

; If (TenKey) {
;     n::Send, 0
;     m::Send, 1
;     ,::Send, 2
;     .::Send, 3
;     j::Send, 4
;     k::Send, 5
;     l::Send, 6
;     u::Send, 7
;     i::Send, 8
;     o::Send, 9
;     p::Send, -
;     vkBB::Send, {+}
;     vkBA::Send, *
;     h::Send, .
; }

; vkF2::
; key := "vkF2"
; KeyWait, %key%, T0.3
; If(ErrorLevel){          ;長押しした場合
;     TenKey := true
;     KeyWait, %key%
;     TenKey := false
;     return
; }
; KeyWait, %key%, D, T0.2
; If(!ErrorLevel){         ;2度押しした場合
;     Send !^{Tab}
;     IsAltTabMenu := true
; }else{                   ;短押しした場合
;     Send, {Esc}
;     return
; }

#If (IsAltTabMenu)
    j::Send {Left}
k::Send {Down}
i::Send {Up}
l::Send {Right}
Enter::
    Send {Enter}
    IsAltTabMenu := false
Return
Space::
    Send {Space}
    IsAltTabMenu := false
Return
#If

; うまく動作せず
; ;音量調整入れても面白いかもだけど現状はいらなそう
; ;タスクバーでスクロールすると音量調整
; #IfWinActive,ahk_class Shell_TrayWnd
; WheelUp::Send,{Volume_Up}
; WheelDown::Send,{Volume_Down}
; MButton::Send,{Volume_Mute}
; ; vk1Dsc07B & i::Send,{Volume_Up}			;↑
; ; vk1Dsc07B & k::Send,{Volume_Down}		;↓
; ; vk1Dsc07B & b::Send,{Volume_Mute}		;MButton
; #IfWinActive

;Ctrlキーが押されている間、QキーにTabキーの役割をさせる
; Qキーが押された時の処理
; ~q::
;     If (GetKeyState("Ctrl", "D")) {
;         ; Ctrlキーが押されている場合
;         ; Send, {BackSpace}
;         Send, {Tab}
;     }
;     Return

; CtrlTabMenu := false

; 変換キーが押された時の処理
; ~vk1C::
;     If (A_PriorHotKey == A_ThisHotKey and A_TimeSincePriorHotkey < 1000) {
;         CtrlTabMenu := true
;         Send, {CtrlDown}
;         Send, {Blind}{Tab}
;     } else {
;         IME_SET(1)
;     }
;     Return

; #If (CtrlTabMenu)
;     ; CtrlTabMenu状態での処理
;     ~vk1C::
;         Send, {Blind}{Tab}
;         Return

;     ; Enterキーが押された時の処理
;     Enter::
;         CtrlTabMenu := false
;         Send, {CtrlUp}
;         Return
; #If

#UseHook off

