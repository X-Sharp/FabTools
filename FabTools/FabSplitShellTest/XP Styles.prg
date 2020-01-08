#warning The following method did not include a CLASS declaration
CLASS AppWindow_external_class INHERIT AppWindow
METHOD ControlNotify(oControlNotifyEvent) 

    IF oControlNotifyEvent:NotifyCode == TTN_NEEDTEXT
        ProcessToolTip(SELF,oControlNotifyEvent)
    ELSE
        SUPER:ControlNotify(oControlNotifyEvent)
    ENDIF
return self


END CLASS
FUNCTION ProcessToolTip(oOwner,oControlNotifyEvent)

    LOCAL nCode     AS LONG
    LOCAL lParam    AS LONG

    LOCAL oControl    AS Control

    LOCAL strucToolInfo IS _winTOOLINFOXP
    LOCAL strucToolTip  AS _winTOOLTIPTEXT
    LOCAL strucNotify   AS _winNMHDR
    LOCAL cTipText      AS STRING
    LOCAL oWindow       AS OBJECT


    nCode      := oControlNotifyEvent:NotifyCode
    lParam     := oControlNotifyEvent:lParam
    oControl   := oControlNotifyEvent:Control

    strucNotify          := PTR(_CAST, lParam)
    strucToolInfo.cbSize := _SizeOf(_winTOOLINFOXP)
    strucToolInfo.hwnd   := strucNotify.hwndFrom

    SendMessage(strucNotify.hwndFrom, TTM_GETCURRENTTOOL, 0, ;
                LONG(_CAST, @strucToolInfo))
    oWindow := __WCGetControlByHandle(strucToolInfo.hwnd)
    IF (oWindow == NULL_OBJECT)
        oWindow := __WCGetControlByHandle(GetParent(strucToolInfo.hwnd))
    ENDIF
    strucToolTip := PTR(_CAST, lParam)

    IF IsInstanceOf(oWindow, #ToolBar)
        cTipText  := oWindow:GetTipText(strucToolTip.hdr.idFrom, ;
                                        #MenuItemID)
        IF IsMethod(oOwner, #StatusMessage)  .and. ;
               (oOwner:Menu != NULL_OBJECT)
            Send(oOwner, #StatusMessage, ;
                     oOwner:Menu:Hyperlabel(strucToolTip.hdr.idFrom))
        ENDIF
    ELSEIF IsInstanceOf(oWindow, #TabControl)
        cTipText := oWindow:GetTipText(;
                oWindow:__GetSymbolFromIndex(strucToolTip.hdr.idFrom))
    ENDIF

    IF Empty(cTipText)
        IF _And(strucToolTip.uFlags, TTF_IDISHWND) > 0
            oWindow := __WCGetControlByHandle(strucToolTip.hdr.idFrom)
            IF (oWindow == NULL_OBJECT)
                oWindow := __WCGetControlByHandle(;
                                    GetParent(strucToolTip.hdr.idFrom))
                IF (oWindow == NULL_OBJECT)
                    oWindow := __WCGetControlByHandle(;
                                 GetParent(GetParent(strucToolTip.hdr.idFrom)))
                ENDIF
                IF !IsInstanceOf(oWindow, #ComboBox)  .and. ;
                           !IsInstanceOf(oWindow, #IPAddress)
                    oWindow := NULL_OBJECT
                ENDIF
            ENDIF
        ELSE
            oWindow := __WCGetControlByHandle(GetDlgItem(oOwner:handle(), ;
                                INT(_CAST, strucToolTip.hdr.idFrom)))
        ENDIF

        IF (oWindow != NULL_OBJECT)
            cTipText := oWindow:ToolTipText
            IF Empty(cTipText)  .and. oWindow:UseHLForToolTip
                cTipText := oWindow:Hyperlabel:Description
            ENDIF
        ENDIF
    ENDIF

    IF Empty(cTipText)
        strucToolTip.lpszText := NULL_PSZ
    ELSE
        strucToolTip.lpszText := Cast2Psz(cTipText)
    ENDIF
    RETURN NIL




VOSTRUCT _winTOOLINFOXP ALIGN 1
        MEMBER cbSize AS DWORD
        MEMBER uFlags AS DWORD
        MEMBER hwnd AS PTR
        MEMBER uId AS DWORD
        MEMBER rect IS _winRECT
        MEMBER hinst AS PTR
        MEMBER lpszText AS PSZ
        MEMBER lParam AS LONG


