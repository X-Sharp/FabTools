using VO

CLASS FabCustomTextCntrl INHERIT CustomControl
	//
	PROTECT oFont AS Font
	PROTECT oTextColor AS Color
	//

	METHOD __GetText() 
	    LOCAL iLength, iReturn AS INT
	    LOCAL cBuffer AS STRING
	    LOCAL pBuffer as void ptr
	    //
	    iLength := GetWindowTextLength( SELF:hWnd )
	    IF (iLength > 0)
		    pBuffer := Memalloc( iLength + 1 )
		    iReturn := GetWindowText( SELF:hwnd, pBuffer, iLength+1)
		    cBuffer := Psz2String( pBuffer )
		    IF ( iReturn != iLength )
			    cBuffer := Left(cBuffer, dword(iReturn))
		    ENDIF
		    MemFree( pBuffer )
	    ENDIF
	    //
    RETURN cBuffer



METHOD __SetColors(_hDC AS PTR) AS PTR  
	LOCAL hBr AS PTR
	LOCAL strucLogBrush IS _WinLogBrush
	LOCAL p IS _winPOint
	LOCAL oFormDlg AS OBJECT
	//
//	IF ( SELF:oTextColor == NULL_OBJECT) .and. ( SELF:oControlBackGround == NULL_OBJECT)
//		RETURN NULL_PTR
//	ENDIF
	//
	IF ( SELF:oTextColor != NULL_OBJECT)
		SetTextColor(_hDC, SELF:oTextColor:ColorRef)
	ELSE
		SetTextColor(_hDC, GetSysColor(COLOR_WINDOWTEXT))
	ENDIF
	//
	oFormDlg := SELF:__FormSurface
	//
	IF ( SELF:oControlBackground != NULL_OBJECT )
		hBr := SELF:oControlBackground:Handle()
		GetObject(hBr, _SizeOf(_WinLogBrush), @strucLogBrush)
		SetBkColor(_hDC, strucLogBrush:lbColor)
		UnrealizeObject(hBr)
		ClientToScreen(oFormDlg:Handle(), @p)
		SetBrushOrgEx(_hDc, p:X, p:Y, NULL_PTR)
	ELSE
		IF IsInstanceOf(SELF, #Edit) .or. IsInstanceOf(SELF, #ListBox)
			hBr := GetSysColorBrush(COLOR_WINDOW)
		ELSE
			hBr := GetSysColorBrush(COLOR_3DFACE)
		ENDIF
		GetObject(hBr, _SizeOf(_WinLogBrush), @strucLogBrush)
		SetBkColor(_hDC, strucLogBrush:lbColor)
	ENDIF
RETURN hBr


METHOD __SetText(cNewText) 
	IF !IsString(cNewText)
		WCError{#__SetText,#FabCustomTextCntrl,"Invalid argument type.",cNewText,1}:@@Throw()
	ENDIF
	//
	IF SELF:ValidateControl()
		SendMessage(hWnd, WM_SETTEXT, 0, LONG(_CAST, cNewText))
	ENDIF
RETURN cNewText


ACCESS Caption 
	IF !IsString( SELF:cCaption)
		SELF:cCaption := SELF:__GetText()
	ENDIF
RETURN SELF:cCaption


ASSIGN Caption(cNewCaption) 
	IF !IsString(cNewCaption)
		WCError{#Caption,#FabCustomTextCntrl,"Invalid argument type.",cNewCaption,1}:@@Throw()
	ENDIF
	SELF:cCaption := cNewCaption
    SELF:__SetText(cNewCaption)


METHOD Destroy() 
	//
	//IF !InCollect()
    	SELF:oFont := NULL_OBJECT
	//ENDIF
	//
	SUPER:Destroy()

return self

METHOD Draw( hDC AS PTR ) AS VOID  

return

METHOD Expose( oEvent ) 
	LOCAL hDC		AS	PTR
 	//
    hDC := GetDC( SELF:Handle() )
    //
    SELF:Draw( hDC )
	//
    ReleaseDC( SELF:Handle(), hDC )
    //
RETURN SELF

METHOD SetFont(oNewFont) 
	LOCAL oOldFont    AS Font
	LOCAL hFont       AS PTR
	//
	IF !IsNil(oNewFont)
		IF !IsInstanceOfUsual(oNewFont, #Font)
			WCError{#Font, #FabCustomTextCntrl, "Invalid argument type.", oNewFont,1}:@@Throw()
		ENDIF
	ENDIF
	//
	oOldFont := oFont
	SELF:oFont    := oNewFont
	IF ( SELF:oFont != NULL_OBJECT)
		SELF:oFont:Create()
		hFont := SELF:oFont:Handle()
	ELSE
//		hFont := GetStockObject( DEFAULT_GUI_FONT)
		hFont := GetStockObject( ANSI_VAR_FONT)
		IF ( hFont == NULL_PTR )
			hFont := GetStockObject(SYSTEM_FONT)
		ENDIF
	ENDIF
	//
	SendMessage(SELF:Handle(), WM_SETFONT, DWORD(_CAST, hFont), 1)
	//
RETURN oOldFont

ACCESS Font 
	LOCAL hFont		AS	PTR
	//
	IF ( SELF:oFont == NULL_OBJECT)
		IF ( SELF:oParent:Font != NULL_OBJECT )
			RETURN SELF:oParent:Font
		ELSE
			//
			hFont := PTR( _CAST, SendMessage( SELF:Handle(0), WM_GETFONT, 0, 0 ) )
			IF ( hFont == NULL_PTR )
				hFont := GetStockObject( ANSI_VAR_FONT )
			ENDIF	
			//
			SELF:oFont := Font{FONTSYSTEM8}
			//SELF:oFont:FromHandle( hFont )
			SELF:oFont:Create()
			//
		ENDIF
	ENDIF
RETURN SELF:oFont


ASSIGN Font(oNewFont) 
	LOCAL hFont AS PTR
	//
	oFont:= oNewFont
	IF oFont != NULL_OBJECT
		oFont:Create()
		hFont := oFont:Handle()
	ELSE
		hFont := GetStockObject(DEFAULT_GUI_FONT)
		IF (hFont == NULL_PTR)
			hFont := GetStockObject(SYSTEM_FONT)
		ENDIF
	ENDIF
	//
	SendMessage(SELF:Handle(), WM_SETFONT, DWORD(_CAST, hFont), LONG(_CAST, TRUE))
	//
RETURN 


CONSTRUCTOR(oOwner, xId, oPoint, oDimension, cRegclass, kStyle, lDataAware) 
	//
	SUPER(oOwner, xID, oPoint, oDimension, cRegclass, kStyle, lDataAware)
	//
RETURN 


ACCESS TextColor 
RETURN SELF:oTextColor


ASSIGN TextColor(oColor) 
	LOCAL hHandle AS PTR
	//
	IF !IsInstanceOfUsual(oColor,#Color)
		WCError{#TextColor,#FabCustomTextCntrl,"Invalid argument type.",oColor,1}:@@Throw()
	ENDIF
	//
	SELF:oTextColor := oColor
	hHandle:=SELF:Handle()
	IF ( hHandle != NUll_PTR )
		InvalidateRect(hHandle, NULL_PTR, TRUE)
		UpdateWindow(hHandle)
	ENDIF
	//
RETURN //SELF:oTextColor


ACCESS TextValue 
RETURN SELF:Caption


ASSIGN TextValue(cNewCaption) 
 SELF:Caption := cNewCaption

METHOD Update() AS VOID  
	InvalidateRect( SELF:HANDLE(0),NULL,TRUE)
return
END CLASS

