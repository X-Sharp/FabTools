#define ILD_ROP 0x0040
#define   BP_PUSHBUTTON 1
#define   BP_RADIOBUTTON 2
#define   BP_CHECKBOX 3
#define   BP_GROUPBOX 4
#define   BP_USERBUTTON 5
#define   PBS_NORMAL 1
#define   PBS_HOT 2
#define   PBS_PRESSED 3
#define   PBS_DISABLED 4
#define   PBS_DEFAULTED 5
#define	DTT_GRAYED 1

Using VO


CLASS FabBitmapButton	INHERIT	FabCustomTextCntrl
	//
	PROTECT	_oImgList	AS	ImageList
	//
	PROTECT _lPressed		AS	LOGIC
	PROTECT _symCaptionPos	AS	SYMBOL
	PROTECT _lAsFocus		AS	LOGIC
	PROTECT _lHiLite		AS	LOGIC
	//
	PROTECT _lUseXP			AS	LOGIC
	
	METHOD _CalcImageRect( hDC AS PTR, Canvas AS _WINRECT ) AS VOID  
		LOCAL Size		IS _winSize
		//
		ImageList_GetIconSize( SELF:_oImgList:Handle(), @Size:cx, @Size:cy )
		//
		SELF:_GetClientRect( Canvas )
		//
		DO CASE
			CASE SELF:_symCaptionPos == #BOTTOM
				//
				Canvas:Top := Canvas:Top + 8
				Canvas:Left := ( ( Canvas:Right - Canvas:Left ) - Size:cx ) / 2
				Canvas:Right := Canvas:Left + Size:cx
				Canvas:Bottom := Canvas:Top + Size:cy
				//		
			CASE SELF:_symCaptionPos == #TOP
				//
				Canvas:Bottom := Canvas:Bottom - 8
				Canvas:Left := ( ( Canvas:Right - Canvas:Left ) - Size:cx ) / 2
				Canvas:Right := Canvas:Left + Size:cx
				Canvas:Top := Canvas:Bottom - Size:cy
				//		
			CASE SELF:_symCaptionPos == #RIGHT
				//
				Canvas:Left := Canvas:Left + 8
				Canvas:Top := ( ( Canvas:Bottom - Canvas:Top ) - Size:cy ) / 2
				Canvas:Bottom := Canvas:Top + Size:cy
				Canvas:Right := Canvas:Left + Size:cx
				//		
			CASE SELF:_symCaptionPos == #LEFT
				//
				Canvas:Right := Canvas:Right - 8
				Canvas:Top := ( ( Canvas:Bottom - Canvas:Top ) - Size:cy ) / 2
				Canvas:Bottom := Canvas:Top + Size:cy
				Canvas:Left := Canvas:Right - Size:cx
				//		
			OTHERWISE
				//
				Canvas:Top := ( ( Canvas:Bottom - Canvas:Top ) - Size:cy ) / 2
				Canvas:Bottom := Canvas:Top + Size:cy
				Canvas:Left := ( ( Canvas:Right - Canvas:Left ) - Size:cx ) / 2
				Canvas:Right := Canvas:Left + Size:cx
				//
		ENDCASE
		//
		IF ( SELF:_lPressed ) .OR. !IsWindowEnabled( SELF:Handle() )
			OffsetRect( Canvas, 0, 2 )
		ENDIF
		//
		return
		
	METHOD _CalcTextRect( hDC AS PTR, Canvas AS _WINRECT ) AS VOID  
		LOCAL cText		AS	STRING
		LOCAL Size		IS _winSize
		//
		SELF:_GetClientRect( Canvas )
		//
		cText := SELF:Caption
		IF Empty( cText )
			//
			InflateRect( Canvas, -6, -6 )
			RETURN
		ENDIF
		//
		Size:cy := DrawText( hDC, Cast2Psz(cText), int(SLen(cText)), Canvas, DT_CALCRECT )
		Size:cx := Canvas:Right
		//
		SELF:_GetClientRect( Canvas )
		//
		DO CASE
			CASE SELF:_symCaptionPos == #TOP
				//
				Canvas:Top := Canvas:Top + 8
				Canvas:Left := ( ( Canvas:Right - Canvas:Left ) - Size:cx ) / 2
				Canvas:Right := Canvas:Left + Size:cx
				Canvas:Bottom := Canvas:Top + Size:cy
				//		
			CASE SELF:_symCaptionPos == #BOTTOM
				//
				Canvas:Bottom := Canvas:Bottom - 8
				Canvas:Left := ( ( Canvas:Right - Canvas:Left ) - Size:cx ) / 2
				Canvas:Right := Canvas:Left + Size:cx
				Canvas:Top := Canvas:Bottom - Size:cy
				//		
			CASE SELF:_symCaptionPos == #LEFT
				//
				Canvas:Left := Canvas:Left + 8
				Canvas:Top := ( ( Canvas:Bottom - Canvas:Top ) - Size:cy ) / 2
				Canvas:Bottom := Canvas:Top + Size:cy
				Canvas:Right := Canvas:Left + Size:cx
				//		
			CASE SELF:_symCaptionPos == #RIGHT
				//
				Canvas:Right := Canvas:Right - 8
				Canvas:Top := ( ( Canvas:Bottom - Canvas:Top ) - Size:cy ) / 2
				Canvas:Bottom := Canvas:Top + Size:cy
				Canvas:Left := Canvas:Right - Size:cx
				//		
			OTHERWISE
				//
				Canvas:Top := ( ( Canvas:Bottom - Canvas:Top ) - Size:cy ) / 2
				Canvas:Bottom := Canvas:Top + Size:cy
				Canvas:Left := ( ( Canvas:Right - Canvas:Left ) - Size:cx ) / 2
				Canvas:Right := Canvas:Left + Size:cx
				//
		ENDCASE
		//
		IF ( SELF:_lPressed ) .OR. !IsWindowEnabled( SELF:Handle() )
			OffsetRect( Canvas, 0, 2 )
		ENDIF
		//
		return	
		
	METHOD _DrawBackground( hDC AS PTR ) AS VOID  
		LOCAL dwBkClr	AS	DWORD
		LOCAL hBrush	AS	PTR
		LOCAL Canvas	IS	_winRect
		dwBkClr := GetBkColor( hDC )
		// Draw the background
		GetClientRect( SELF:Handle(), @Canvas )
		hBrush := CreateSolidBrush( dwBkClr )
		FillRect( hDC, @Canvas, hBrush )
		DeleteObject( hBrush )
		return	
		
	METHOD _DrawControl( hDC AS PTR ) AS VOID  
		LOCAL Canvas	IS	_winRect
		LOCAL iState	AS	LONG
		LOCAL hT		AS	PTR
		//
		GetClientRect( SELF:Handle(), @Canvas )
		//
		IF FabXPThemesLoaded() .AND. SELF:UseXPTheme
			hT := OpenThemeData( SELF:Handle(), String2Psz("BUTTON") )
			//
			IF ( SELF:_lPressed )
				iState := PBS_PRESSED
			ELSEIF ( SELF:_lHiLite )
				iState := PBS_HOT		
			ELSEIF ( SELF:_lAsFocus )
				iState := PBS_DEFAULTED
			ELSEIF !IsWindowEnabled( SELF:Handle() )
				iState := PBS_DISABLED
			ELSE
				iState := PBS_NORMAL
			ENDIF
			DrawThemeBackground( hT, hDC, BP_PUSHBUTTON, iState, @Canvas, NULL_PTR )
			//
			CloseThemeData( hT )
		ELSE
			IF ( SELF:_lAsFocus )
				InflateRect( @Canvas, -1, -1 )
			ENDIF
			//
			iState := DFCS_BUTTONPUSH
			IF ( SELF:_lPressed )
				iState := _or( iState, DFCS_PUSHED )
			ENDIF
			//
			DrawFrameControl( hDC, @Canvas, DFC_BUTTON, dword(iState) )
		ENDIF
		//
		return
		
	METHOD _DrawFocus( hDC AS PTR ) AS VOID  
		LOCAL Canvas	IS	_winRect
		LOCAL DIM aPts[5] IS _winPOINT
		LOCAL hOldFont	AS	PTR
		//
		SELF:_GetClientRect( @Canvas )
		//
		IF !FabXPThemesLoaded()
			aPts[1]:y := Canvas:Top
			aPts[1]:x := Canvas:Left
			//
			aPts[2]:y := Canvas:Top
			aPts[2]:x := Canvas:Right-1
			//
			aPts[3]:y := Canvas:Bottom-1
			aPts[3]:x := Canvas:Right-1
			//
			aPts[4]:y := Canvas:Bottom-1
			aPts[4]:x := Canvas:Left
			//
			aPts[5]:y := Canvas:Top
			aPts[5]:x := Canvas:Left
			//
			POlyline( hDC, @aPts[1], 5 )
		ENDIF
		//
		IF ( SELF:_oImgList != NULL_OBJECT )
			//
			hOldFont := SelectObject( hDC, SELF:oFont:Handle() )
			//
			SELF:_CalcTextRect( hDC, @Canvas )
			//
			SelectObject( hDC, hOldFont )
			//
			InflateRect( @Canvas, 2, 2 )
		ELSE
			InflateRect( @Canvas, -4, -4 )
		ENDIF
		//
		DrawFocusRect( hDc, @Canvas )
		//
		return	
		
	METHOD _DrawImage( hDC AS PTR ) AS VOID  
		LOCAL nNum 		AS LONG
		LOCAL nCount	AS	LONG
		LOCAL Canvas	IS	_winRect
		LOCAL hIcon		AS	PTR
		LOCAL Size		IS _winSize
		//
		IF ( SELF:_oImgList != NULL_OBJECT )
			nCount := ImageList_GetImageCount( SELF:_oImgList:Handle() )
		ENDIF
		//
		IF ( nCount > 0 )
			//
			IF ( SELF:_lPressed )		
				nNum := Min(1, nCount-1)
			ELSEIF ( SELF:_lHilite )
				nNum := Min(2, nCount-1)
			ELSE
				nNum := Min(0, nCount-1)
			ENDIF
			//
			SELF:_CalcImageRect( hDC, @Canvas )
			//
			IF !IsWindowEnabled( SELF:Handle() )
				//
				IF ( nCount >= 4 )
					nNum := 3
					ImageList_Draw(SELF:_oImgList:Handle() , nNum, hDC, Canvas:Left, Canvas:Top, ILD_NORMAL )
				ELSE
					//
					ImageList_GetIconSize( SELF:_oImgList:Handle(), @Size:cx, @Size:cy )
					hIcon := ImageList_ExtractIcon( 0, SELF:_oImgList:Handle(), 0 )
					DrawState( hDC, 0,NULL_PTR, LONG(_CAST,hIcon),0,Canvas:Left, Canvas:Top,Size:cx,Size:cy, _Or( DST_ICON,DSS_DISABLED ) )
					DestroyIcon( hIcon )
					//
				ENDIF
			ELSE
				ImageList_Draw(SELF:_oImgList:Handle() , nNum, hDC, Canvas:Left, Canvas:Top, ILD_NORMAL )
			ENDIF
			//
		ENDIF
		return
		
	METHOD _DrawText( hDC AS PTR ) AS VOID  
		LOCAL liOldMode	AS	LONG
		LOCAL liNewMode	AS	LONG
		LOCAL hOldFont	AS	PTR
		LOCAL Canvas	IS	_winRect
		LOCAL cText		AS	STRING
		LOCAL dwMode	as	long
		LOCAL hT		AS	PTR
		//
		hOldFont := SelectObject( hDC, SELF:oFont:Handle() )
		// We are always in TRANSPARENT mode for Text drawing
		liNewMode := TRANSPARENT
		liOldMode := SetBkMode( hDC, PTR(_CAST, liNewMode) )
		//
		SELF:_CalcTextRect( hDC, @Canvas )
		//
		cText := SELF:Caption
		//
		IF FabXPThemesLoaded() .AND. SELF:UseXPTheme
			hT := OpenThemeData( SELF:Handle(), String2Psz("BUTTON") )
			//
			IF ( SELF:_lPressed )
				dwMode := PBS_PRESSED
			ELSEIF ( SELF:_lHiLite )
				dwMode := PBS_HOT
			ELSEIF ( SELF:_lAsFocus )
				dwMode := PBS_DEFAULTED
			ELSEIF !IsWindowEnabled( SELF:Handle() )
				dwMode := PBS_DISABLED
			ELSE
				dwMode := PBS_NORMAL
			ENDIF
			//cText := Multi2Wide( cText )
			//
			DrawThemeText( hT, hDC, 0, dwMode, Cast2Psz(cText),-1, DT_LEFT,0, @Canvas )
			//
			CloseThemeData( hT )
		ELSE
			//
			dwMode := DST_PREFIXTEXT
			IF !IsWindowEnabled( SELF:Handle() )
				//
				dwMode := _or( dwMode, DSS_DISABLED )
				//
			ENDIF
			//
			DrawState( hDC, 0,NULL_PTR, LONG(_CAST,Cast2Psz(cText)),SLen(cText),Canvas:Left,Canvas:Top,;
			Canvas:Right-Canvas:Left,Canvas:Bottom-Canvas:Top, dword(dwMode) )
		ENDIF
		//
		SelectObject( hDC, hOldFont )
		SetBkMode( hDC, PTR(_CAST, liOldMode))
		//
		return
		
	METHOD _GetClientRect( Canvas AS _WINRECT ) AS VOID  
		//
		GetClientRect( SELF:Handle(), Canvas )
		return
		
	METHOD _GetHalftoneBrush( ) AS PTR  
		LOCAL DIM wPattern[ 8 ] AS WORD
		LOCAL nCpt		AS	LONG
		LOCAL nShift	AS	LONG
		LOCAL hBitmap	AS	PTR
		LOCAL hBrush	AS	PTR
		//
		FOR nCpt := 1 UPTO 8
			nShift := ( nCpt % 2)
			wPattern[ nCpt ] := word( 0x5555 << nShift )
		NEXT
		//
		hBitmap := CreateBitmap( 8, 8, 1, 1, @wPattern[1] )
		//
		IF ( hBitmap != NULL_PTR )
			hBrush := CreatePatternBrush( hBitmap )
			DeleteObject( hBitmap )
		ENDIF
		//
		RETURN hBrush
		
		
	ACCESS CaptionPos AS SYMBOL  
		RETURN SELF:_symCaptionPos
		
	ASSIGN CaptionPos( sNew AS SYMBOL )   
		IF ( sNew == #TOP ) .OR. ;
			( sNew == #LEFT ) .OR. ;
			( sNew == #BOTTOM ) .OR. ;
			( sNew == #RIGHT ) .OR. ;
			( sNew == #CENTER )
			//
			SELF:_symCaptionPos := sNew
		ENDIF
		RETURN //SELF:_symCaptionPos
		
		
	METHOD CaptureMouse() AS VOID  
		//p Capture Mouse
		SetCapture(SELF:Handle(0))
		return
		
	METHOD Dispatch( oEvt ) 
		LOCAL oEvent	AS	@@Event
		LOCAL lDown		AS	LOGIC
		//
		oEvent := oEvt
		DO CASE
			CASE  ( oEvent:Message == (DWORD)WM_ERASEBKGND )
				//
				SELF:EventReturnValue := 1
				RETURN 1
				// User Press/Release the button
			CASE oEvent:Message == (DWORD)BM_CLICK
				IF IsMethodUsual( SELF:Owner, SELF:NameSym )
					Send( SELF:Owner, SELF:NameSym)
				ENDIF
			CASE oEvent:Message == (DWORD)BM_SETSTATE
				SUPER:Dispatch( oEvent )
				lDown := (oEvent:wParam == 1)
				IF ( SELF:_lPressed != lDown )
					SELF:_lPressed := lDown
					SELF:_lHilite := FALSE
					SELF:Update()
				ENDIF
				RETURN 0L
				// Get Focus
			CASE oEvent:Message == (DWORD)WM_SETFOCUS
				SELF:_lAsFocus := TRUE
				SELF:Update()
				// Lost focus
			CASE oEvent:Message == (DWORD)WM_KILLFOCUS
				SELF:_lAsFocus := FALSE
				SELF:Update()
				// Enabling the button
			CASE  oEvent:Message == (DWORD)WM_ENABLE
				SELF:Update()
			CASE  oEvent:Message == (DWORD)WM_SETTEXT
				// We want default behaviour
				SUPER:Dispatch( oEvent )
				SELF:Update()
				RETURN 0
			CASE oEvent:Message == (DWORD)WM_ENABLE
				// We want default behaviour
				SUPER:Dispatch( oEvent )
				SELF:Update()
				RETURN 0	
				// Pressing Mouse Button
			CASE ( oEvent:Message == (DWORD)WM_LBUTTONUP )
				IF SELF:_lPressed
					IF IsMethodUsual( SELF:Owner, SELF:NameSym )
						Send( SELF:Owner, SELF:NameSym )
						SELF:SetFocus()
					ENDIF
				ENDIF
			CASE ( oEvent:Message == (DWORD)WM_GETDLGCODE )
				// Return key ? ( Or Space Key )
				IF ( oEvent:wParam == (DWORD)VK_RETURN ) .OR. ( oEvent:wParam == (DWORD)VK_SPACE )
					IF IsMethodUsual( SELF:Owner, SELF:NameSym )
						Send( SELF:Owner, SELF:NameSym )
					ENDIF
				ENDIF
				SELF:EventReturnValue := DLGC_BUTTON
				RETURN 1
		ENDCASE
		//
		RETURN SUPER:Dispatch( oEvent )
		
		
		
	METHOD Draw( hDC AS PTR ) AS VOID  
		//
		SELF:__SetColors( hDC )
		//
		SELF:_DrawBackground( hDC )
		//
		SELF:_DrawControl( hDC )
		//
		SELF:_DrawImage( hDC )
		//
		SELF:_DrawText( hDC )
		//
		IF ( SELF:_lAsFocus )
			SELF:_DrawFocus( hDC )
		ENDIF	
		//
		return
		
	METHOD DrawDisabled() 
		/*
	hBmpBrush := LoadBitmap( _GetInst(), PSZ( "FABBMP_GRAY"  ) )
	//
	hBrush := CreatePatternBrush( hBmpBrush )
	hOldRETURN:= SelectObject( hDC, hBrush )
	//
	DrawBitmap2( hDC , hBitmap, wXDest , wYDest , wWidth , wHeight , 0x00A803A9 )
	//
	SelectObject( hDC, hOldBrush )
	//
	DeleteObject( hBrush )	
	DeleteObject( hBmpBrush )
	//
	
	
	PROCEDURE	DrawBitmap2( hDC AS PTR, hBitmap AS PTR, wXDest AS SHORTINT, wYDest AS SHORTINT, wWidth AS SHORTINT, wHeight AS SHORTINT, liRaster AS LONGINT )
	LOCAL	hDCMem		AS	PTR		// VO2
	LOCAL	hOldBm		AS	PTR		// VO2
	LOCAL	Bitmap		IS	_WinBitmap
	//
	hDCMem := CreateCompatibleDC( hDC )
	IF ( hDCMem != 0 )
	hOldBm := SelectObject( hDCMem, hBitmap )
	GetObject( hBitmap, _SizeOf( _WinBitmap ), @Bitmap )
	//
	IF ( wWidth > 0 ) .and. ( wHeight > 0 )
	StretchBlt( hDC, wXDest, wYDest, wWidth, wHeight, hDCMem, 0, 0, Bitmap.bmWidth, Bitmap.bmHeight, liRaster )
	ELSE
	BitBlt( hDC, wXDest, wYDest, Bitmap.bmWidth, Bitmap.bmHeight, hDCMem, 0, 0, liRaster )
	ENDIF
	//
	SelectObject( hDCMem, hOldBm )
	DeleteDC( hDCMem )
	ENDIF
	RETURN
	*/
	return self
	
	METHOD Expose( oEvent ) 
		LOCAL clientRect IS _winRect
		LOCAL memDC AS PTR
		LOCAL hBmp AS PTR
		LOCAL hOldBmp AS PTR
		LOCAL iWidth AS LONG
		LOCAL iHeight AS LONG
		//LOCAL lRet AS LOGIC
		LOCAL myDC AS PTR
		// get a device context and create a compatible bitmap
		// actual drawin occurs on the bitmap to avoid flicker
		myDC := GetDC( SELF:Handle() )
		GetClientRect( SELF:Handle(), @clientRect )
		iWidth := clientRect:Right - clientRect:Left
		iHeight := clientRect:Bottom - clientRect:Top
		memDC := CreateCompatibleDC( myDC )
		hBmp := CreateCompatibleBitmap( myDC, iWidth, iHeight)
		hOldBmp := SelectObject( memDC, hBmp )
		//
		SELF:Draw( memDC )
		//
		BitBlt( myDC, clientRect:left, clientRect:top, iWidth, iHeight, memDC, 0, 0, SRCCOPY)
		SelectObject( memDC, hOldBmp )
		DeleteObject( hBmp )
		DeleteDC( memDC )
		ReleaseDC( SELF:Handle(), myDC )
		return self	
		
	ACCESS ImageList AS ImageList  
		RETURN SELF:_oImgList
		
	ASSIGN ImageList( oNew AS ImageList )   
		SELF:_oImgList := oNew
		SELF:Update()
		RETURN //SELF:_oImgList
		
		
	CONSTRUCTOR(oOwner, nID, oPoint, oDimension, cText, kStyle) 
		//LOCAL oFt	AS	Font
		//
		SUPER( oOwner, nID, oPoint, oDimension, cText, kStyle)
		SELF:SetStyle( WS_BORDER, FALSE )
		//
		IF __FabIsWindowsXP()
			FabInitXPThemes()
			SELF:_lUseXP := FabXPThemesLoaded()
			
		ENDIF
		//
		SELF:CaptionPos := #CENTER
		//
		SELF:Show()
		//
		SELF:SetFont( NULL_OBJECT )
		SELF:GetFont()	// Force Creation if needed
		//oFt:FromHandle( GetStockObject( ANSI_VAR_FONT ) )
		//
		SELF:Update()
		//
		RETURN 
		
	METHOD MouseButtonDown(oMouseEvent) 
		LOCAL oME AS MouseEvent
		//
		oME := oMouseEvent
		//
		SUPER:MouseButtonDown( oME )
		//
		SELF:CaptureMouse()
		//
		SELF:_lPressed := TRUE
		SELF:SetFocus()
		SELF:Update()
		return self
		
	METHOD MouseButtonUp(oMouseEvent) 
		LOCAL oME AS MouseEvent
		//
		oME := oMouseEvent
		//
		SUPER:MouseButtonUp( oME )
		//
		SELF:ReleaseMouse()
		//
		SELF:_lPressed := FALSE
		SELF:Update()
		//
		return self
		
	METHOD MouseDrag( oMouseEvent ) 
		LOCAL oME	AS	MouseEvent
		//
		SUPER:MouseDrag( oMouseEvent )
		oME := oMouseEvent
		//
		SELF:_lPressed := SELF:CanvasArea:PointInSide( oME:Position )
		//
		SELF:Update()
		//
		return self
		
	ACCESS CanvasArea 
		LOCAL rect       IS _WINRECT
		LOCAL oPoint     AS Point
		LOCAL oDimension AS Dimension
		//
		GetClientRect(SELF:Handle(), @rect)
		oPoint     := Point{0, 0}
		oDimension := Dimension{rect:right - rect:left, rect:bottom - rect:top}
		RETURN BoundingBox{oPoint, oDimension}
		
	METHOD MouseMove( oMouseEvent ) 
		LOCAL oME AS MouseEvent
		//
		oME := oMouseEvent
		//
		SUPER:MouseMove( oME )
		//
		SELF:_lHiLite := SELF:CanvasArea:PointInSide( oME:Position )
		//
		IF SELF:_lHiLite
			SELF:CaptureMouse()
		ELSE
			SELF:ReleaseMouse()
		ENDIF
		//
		SELF:Update()
		//
		return self
		
	METHOD ReleaseMouse() AS VOID  
		//p Release mouse
		ReleaseCapture()
		return
		
	ACCESS UseXPTheme AS LOGIC  
		RETURN SELF:_lUseXP
		
	ASSIGN UseXPTheme( lSet AS LOGIC )   
		SELF:_lUseXP := lSet
		SELF:Update()
		RETURN //SELF:_lUseXP
		
END CLASS

FUNCTION __FabIsWindowsXP() AS LOGIC STRICT
	LOCAL ptrVI		IS	_winOSVERSIONINFO
	LOCAL lIsXP		AS	LOGIC
	//
	ptrVI:dwOSVersionInfoSize := _Sizeof( _winOSVERSIONINFO )
	GetVersionEx( @ptrVI )
	//
	IF ( ptrVI:dwPlatformId == (DWORD)VER_PLATFORM_WIN32_NT )
		IF ( ptrVI:dwBuildNumber >= 2462 )
			lIsXP := TRUE
		ENDIF
	ENDIF
	//
	RETURN lIsXP
	