
CLASS OutlookBarItem INHERIT OutlookBarBase
//d An OutlookBarItem is a button, belonging to a Header
//d It has a Image and a text
//d  
	PROTECT _iImage 		AS LONG
	PROTECT _oParentHeader 	AS OutlookBarHeader
	PROTECT _oLabelArea 	AS WRect
	PROTECT _oGradientColor			AS	Color
	
	ASSIGN __ParentHeader( oOLBHeader AS OutlookBarHeader )   
		SELF:_oParentHeader := oOLBHeader


	ACCESS Control AS OutlookBar
		RETURN SELF:_oParentHeader:Control

	METHOD Draw( hDC AS PTR) AS LOGIC  
	//
		IF SELF:_oParentHeader:BarStyle == #FABSTYLE		
			SELF:DrawFab( hDC, FALSE )
		ELSEIF SELF:_oParentHeader:BarStyle == #NEWSTYLE
			SELF:DrawNew( hDC, FALSE )
		ELSE 
			SELF:DrawStd( hDC, FALSE )
		ENDIF
		RETURN TRUE

	METHOD DrawBackground( hDC AS PTR, Rect AS _WINRect ) AS LOGIC  
		LOCAL hBrush AS PTR
		LOCAL dwColor AS DWORD
		LOCAL oColor	AS	Color
   //
		oColor := SELF:_oParentHeader:BackgroundColor
		dwColor := oColor:ColorRef
		hBrush := CreateSolidBrush( dwColor )
	//
		FillRect( hDC, rect, hBrush )
	//
		DeleteObject(hBrush)
	//
		RETURN TRUE

	METHOD DrawFab( hDC AS PTR, lOnOff AS LOGIC  ) AS LOGIC  
//p Draw the Item
		LOCAL iImagePos AS INT
		LOCAL hImgList 	AS PTR
		LOCAL nX 		AS INT
		LOCAL nY 		AS INT
		LOCAL Rect 		IS _winRect
		LOCAL hFont 	AS PTR
		LOCAL hOldFont 	AS PTR
		LOCAL dwOldColor AS DWORD
		LOCAL iOldBKMode AS INT
		LOCAL LogFont	IS	_winLOGFONT
		LOCAL hNewFont	AS	PTR
		LOCAL rcInside	IS _winRect
		LOCAL iSavedDC	AS	LONG
		LOCAL hRegion	AS	PTR
		LOCAL hIcon		AS	PTR
	//
		SELF:Control:GetInsideRect( @rcInside )
		iSavedDC := SaveDC( hDC )
		hRegion := CreateRectRgnIndirect( @rcInside)
	// Clipping allow the draw to be kept inside the Rect
		SelectClipRgn( hDC, hRegion )
		DeleteObject( hRegion )
	// Copy the actual Area Coords to the Rect Struct
		SELF:Area:GetRectWin( @Rect)
		Rect:Left := 0
		Rect:Right := rcInside:Right - rcInside:Left -1
//	SetRect( @Rect, 0, SELF:Area:Bottom, rcInside.Right - rcInside.Left -1, SELF:Area:Top )
		IF !Empty(SELF:Caption)
			Rect:Bottom := SELF:LabelArea:Bottom
		ENDIF
		InflateRect( @Rect, 1, 1 )
		IF lOnOff
			SELF:DrawHiliteBackground( hDC, @Rect )
		ELSE
			SELF:DrawBackground( hDC, @Rect )
		ENDIF
	//
		nX := SELF:Area:Left
		nY := SELF:Area:Top
	//
		IF SELF:_lPressed
		//
		//nX := nX + 1
			nY := nY + 1
		//
		ENDIF
	//
		iImagePos := SELF:_iImage - 1
		IF ( SELF:Control:ImageList != NULL_OBJECT )
			hImgList := SELF:Control:ImageList:Handle()
		// Draw the Image
			IF SELF:IsEnabled
				IF lOnOff
					ImageList_Draw(hImgList, iImagePos, hDC, nX, nY, ILD_SELECTED)
				ELSE
					ImageList_Draw(hImgList, iImagePos, hDC, nX, nY, ILD_NORMAL)
				ENDIF
			ELSE
				hIcon := ImageList_ExtractIcon( 0, hImgList, iImagePos )
				DrawState( hDc, NULL_PTR, NULL_PTR, LONG(_CAST,hIcon),0,nX,nY,0,0,_OR(DST_ICON,DSS_DISABLED))
				DestroyIcon( hIcon )
			ENDIF
		ENDIF
	// Has Text ?
		IF !Empty(SELF:Caption)
		//
			SELF:_oLabelArea:GetRectWin( @Rect )
		//SELF:DrawBackground( hDC, @Rect )
		//
			hFont := GetStockObject( ANSI_VAR_FONT )
			IF lOnOFF .OR. !SELF:IsEnabled
				GetObject( hFont, _sizeof(_winLOGFONT), @LogFont )
				IF SELF:IsEnabled
					LogFont:lfUnderline := 1
					dwOldColor := SetTextColor( hDC, SELF:_oParentHeader:HiLiteColor:ColorRef )
				ELSE
//				LogFont.lfItalic := 1
//				dwOldColor := SetTextColor( hDC, SELF:_oParentHeader:TextColor:ColorRef )
					dwOldColor := SetTextColor( hDC, GetSysColor( COLOR_GRAYTEXT ) )
				ENDIF
				hNewFont := CreateFontIndirect( @LogFont )
				hOldFont := SelectObject( hDC, hNewFont )
			ELSE
				hOldFont := SelectObject( hDC, hFont )
				dwOldColor := SetTextColor( hDC, SELF:_oParentHeader:TextColor:ColorRef )
			ENDIF
		//
			iOldBKMode := SetBkMode( hDC, TRANSPARENT )
			DrawText( hDC, String2Psz(SELF:_cCaption), -1, @Rect, DT_CENTER + DT_WORDBREAK )
			SelectObject( hDC, hOldFont )
			SetTextColor( hDC, dwOldColor )
			SetBkMode( hDC, iOldBKMode )
			IF lOnOff
				DeleteObject( hNewFont )
			ENDIF
		ENDIF
	//
		SELF:_oParentHeader:DrawArrows( hDC )
	//
		RestoreDC( hDC, iSavedDC )
	//
		RETURN TRUE

METHOD	 DrawGradientFillBackground( hDC AS PTR, Rect AS _winRect, lOnOff AS LOGIC ) AS LOGIC  
		LOCAL DIM vert[2] IS _WINTRIVERTEX
		LOCAL grect 		IS  _winGRADIENT_RECT
		LOCAL dwColor 		AS DWORD
		LOCAL oColor		AS	Color
		LOCAL dwWhite		AS	DWORD
		LOCAL dwStart		AS	DWORD
		LOCAL dwEnd			AS	DWORD
		LOCAL hPen			AS	PTR
		LOCAL hOldPen		AS	PTR
   //
		IF ( lOnOff ) .OR. SELF:_lPressed
			oColor := SELF:_oParentHeader:HiliteBackgroundColor
		ELSE
			oColor := SELF:_oParentHeader:ItemsBackgroundColor
		ENDIF
		dwColor := oColor:ColorRef
		dwWhite := SELF:GradientColor:ColorRef
	//  
		IF ( SELF:_lPressed )
			dwStart := dwColor
			dwEnd   := dwWhite
		ELSE
			dwStart := dwWhite
			dwEnd   := dwColor
		ENDIF
	//
		vert[1]:x      := Rect:left
		vert[1]:y      := Rect:top
		vert[1]:Red    := MakeWord(0,GetRValue(dwStart))
		vert[1]:Green  := MakeWord(0,GetGValue(dwStart))
		vert[1]:Blue   := MakeWord(0,GetBValue(dwStart))
		vert[1]:Alpha  := 0x0000

		vert[2]:x      := Rect:right
		vert[2]:y      := Rect:bottom 
		vert[2]:Red    := MakeWord(0,GetRValue(dwEnd))
		vert[2]:Green  := MakeWord(0,GetGValue(dwEnd))
		vert[2]:Blue   := MakeWord(0,GetBValue(dwEnd))
		vert[2]:Alpha  := 0x0000

		grect:UpperLeft  := 0
		grect:LowerRight := 1
	//
		GradientFill( hDC, @vert, 2, @grect, 1, GRADIENT_FILL_RECT_V )
	//
		IF SELF:_oParentHeader:IsItemsBoxed
		// Now draw a black rectangle
		// Create a black pen
			hPen := CreatePen( PS_SOLID,1, 0)
			hOldPen := SelectObject( hDC, hPen )
		// and then draw
			MoveToEx( hDC, Rect:Right-1, Rect:Top-1, NULL_PTR )
			LineTo( hDC, Rect:Left+1, Rect:Top-1)
			LineTo( hDC, Rect:Left+1, Rect:bottom)
			LineTo( hDC, Rect:Right-1, Rect:bottom)
			LineTo( hDC, Rect:Right-1, Rect:Top-1)
		// restore dc
			SelectObject( hDC, hOldPen )
			DeleteObject( hPen )
		ENDIF
	//	
RETURN		 TRUE  

	METHOD DrawHiLiteBackground( hDC AS PTR, Rect AS _WINRect ) AS LOGIC  
		LOCAL hBrush AS PTR
		LOCAL dwColor AS DWORD
		LOCAL oColor	AS	Color
    //
		oColor := SELF:_oParentHeader:HiLiteBackgroundColor
		dwColor := oColor:ColorRef
		hBrush := CreateSolidBrush( dwColor )
	//
		FillRect( hDC, rect, hBrush )
	//
		DeleteObject(hBrush)
	//
		RETURN TRUE

	METHOD DrawNew( hDC AS PTR, lOnOff AS LOGIC  ) AS LOGIC  
//p Draw the Item
		LOCAL iImagePos AS INT
		LOCAL hImgList 	AS PTR
		LOCAL nX 		AS INT
		LOCAL nY 		AS INT
		LOCAL Rect 		IS _winRect
		LOCAL hFont 	AS PTR
		LOCAL hOldFont 	AS PTR
		LOCAL dwOldColor AS DWORD
		LOCAL iOldBKMode AS INT
		LOCAL LogFont	IS	_winLOGFONT
		LOCAL hNewFont	AS	PTR
		LOCAL rcInside	IS _winRect
		LOCAL iSavedDC	AS	LONG
		LOCAL hRegion	AS	PTR
		LOCAL hIcon		AS	PTR
	//
		SELF:Control:GetInsideRect( @rcInside )
		iSavedDC := SaveDC( hDC )
		hRegion := CreateRectRgnIndirect( @rcInside)
	// Clipping allow the draw to be kept inside the Rect
		SelectClipRgn( hDC, hRegion )
		DeleteObject( hRegion )
	// Copy the actual Area Coords to the Rect Struct
		SELF:Area:GetRectWin( @Rect)
		Rect:Left := 0
		Rect:Right := rcInside:Right - rcInside:Left -1

		InflateRect( @Rect, 1, 1 )
	//
		SELF:DrawGradientFillBackground( hDC, @Rect, lOnOff )
	//
		nX := SELF:Area:Left
		nY := SELF:Area:Top
	//
		iImagePos := SELF:_iImage - 1
		IF ( SELF:Control:ImageList != NULL_OBJECT )
			hImgList := SELF:Control:ImageList:Handle()
		// Draw the Image
			IF SELF:IsEnabled
				ImageList_Draw(hImgList, iImagePos, hDC, nX, nY, ILD_NORMAL)
			ELSE
				hIcon := ImageList_ExtractIcon( 0, hImgList, iImagePos )
				DrawState( hDC, NULL_PTR, NULL_PTR, LONG(_CAST,hIcon),0,nX,nY,0,0,_OR(DST_ICON,DSS_DISABLED))
				DestroyIcon( hIcon )
			ENDIF
		ENDIF
	// Has Text ?
		IF !Empty(SELF:Caption)
		//
			SELF:_oLabelArea:GetRectWin( @Rect )
		//SELF:DrawBackground( hDC, @Rect )
		//
			hFont := GetStockObject( ANSI_VAR_FONT )
			IF lOnOff .OR. !SELF:IsEnabled
				GetObject( hFont, _sizeof(_winLOGFONT), @LogFont )
				LogFont:lfWeight := FW_BOLD
				IF SELF:IsEnabled
					dwOldColor := SetTextColor( hDC, SELF:_oParentHeader:HiLiteColor:ColorRef )
				ELSE
//				LogFont.lfItalic := 1
//				dwOldColor := SetTextColor( hDC, SELF:_oParentHeader:TextColor:ColorRef )
					dwOldColor := SetTextColor( hDC, GetSysColor( COLOR_GRAYTEXT ) )
				ENDIF
				hNewFont := CreateFontIndirect( @LogFont )
				hOldFont := SelectObject( hDC, hNewFont )
			ELSE
				hOldFont := SelectObject( hDC, hFont )
				GetObject( hFont, _sizeof(_winLOGFONT), @LogFont )
				LogFont:lfWeight := FW_BOLD
				dwOldColor := SetTextColor( hDC, SELF:_oParentHeader:TextColor:ColorRef )
				hNewFont := CreateFontIndirect( @LogFont )
				hOldFont := SelectObject( hDC, hNewFont )
			ENDIF
		//
			iOldBKMode := SetBkMode( hDC, TRANSPARENT )
		// Multine support, thanks PDB
			DrawText( hDC, String2Psz(SELF:_cCaption), -1, @Rect, DT_VCENTER + DT_WORDBREAK )
			SelectObject( hDC, hOldFont )
			SetTextColor( hDC, dwOldColor )
			SetBkMode( hDC, iOldBKMode )
		//
			DeleteObject( hNewFont )
		ENDIF
	//
		SELF:_oParentHeader:DrawArrows( hDC )
	//
		RestoreDC( hDC, iSavedDC )
	//
		RETURN TRUE

	METHOD DrawStd( hDC AS PTR, lOnOff AS LOGIC ) AS VOID  
		LOCAL rect IS _WINRect
		LOCAL hPen AS PTR
		LOCAL hOldPen AS PTR
		LOCAL dwLight AS DWORD
		LOCAL dwShadow AS DWORD
		LOCAL oOLBar AS OutlookBar
		LOCAL oColor AS Color
		LOCAL rcInside IS _winRect
		LOCAL hRegion AS PTR
		LOCAL hSavedDC AS PTR
		LOCAL iImagePos AS INT
		LOCAL hImgList AS PTR
		LOCAL nX AS INT
		LOCAL nY AS INT
		LOCAL rcLabel IS _winRect
		LOCAL hFont AS PTR
		LOCAL hOldFont AS PTR
		LOCAL dwOldColor AS DWORD
		LOCAL iOldBKMode AS INT
	//
		SELF:Area:GetRectWin( @rect )
	// Add one extra Pixel to each side, to draw outside the Bitmap
		InflateRect( @rect, 1, 1 )

		SELF:Control:GetInsideRect(@rcInside)
		hSavedDC := SaveDC( hDC )
		hRegion := CreateRectRgnIndirect(@rcInside)
		SelectClipRgn( hDC, hRegion )
		DeleteObject( hRegion )
	//
		IF SELF:_lPressed
			dwLight := DWORD(RGB( 0, 0, 0))	// GetSysColor(COLOR_3DSHADOW)
			dwShadow := GetSysColor(COLOR_3DHIGHLIGHT)
		ELSEIF lOnOff
			dwLight := GetSysColor(COLOR_3DHIGHLIGHT)
			dwShadow := DWORD(RGB( 0, 0, 0))	// GetSysColor(COLOR_3DSHADOW)
		ELSE
			oOLBar := SELF:Control
			oColor := oOLBar:BackgroundColor
			dwShadow := oColor:ColorRef
			dwLight := dwShadow
		ENDIF
	// light
		hPen := CreatePen( PS_SOLID,1, dwLight)
		hOldPen := SelectObject( hDC, hPen )
		MoveToEx( hDC, rect:right, rect:top, NULL_PTR )
		LineTo( hDC, rect:left, rect:top)
		LineTo( hDC, rect:left, rect:bottom)
		SelectObject( hDC, hOldPen)
		DeleteObject( hPen )
		
	// shadow
		hPen := CreatePen( PS_SOLID,1, dwShadow)
		SelectObject( hDC, hPen )
		MoveToEx( hDC, rect:left, rect:bottom, NULL_PTR )
		LineTo( hDC, rect:right, rect:bottom)
		LineTo( hDC, rect:right, rect:top)

	// restore dc
		SelectObject( hDC, hOldPen )
		DeleteObject( hPen )
	//
		nX := SELF:Area:Left
		nY := SELF:Area:Top //Bottom	// umgedreht, weil VO den NULL-Punkt nach unten verlegt
		iImagePos := SELF:_iImage - 1
		hImgList := SELF:Control:ImageList:Handle()
	//	
		ImageList_Draw(hImgList, iImagePos, hDC, nX, nY, ILD_NORMAL)
	//
		IF !Empty(SELF:Caption)
			SELF:_oLabelArea:GetRectWin( @rcLabel )
			hFont := GetStockObject( ANSI_VAR_FONT )
			hOldFont := SelectObject( hDC, hFont )
			dwOldColor := SetTextColor( hDC, DWORD(RGB(255, 255, 255)))
			iOldBKMode := SetBkMode( hDC, TRANSPARENT )
			DrawText( hDC, String2Psz(SELF:_cCaption), -1, @rcLabel, DT_CENTER + DT_WORDBREAK )
			SelectObject( hDC, hOldFont )
			SetTextColor( hDC, dwOldColor )
			SetBkMode( hDC, iOldBKMode )
		ENDIF	
	//
		RestoreDC( hSavedDC, -1 )

RETURN		

	ACCESS GradientColor AS Color  
		RETURN SELF:_oGradientColor

	ASSIGN GradientColor( oColor AS Color )   
		SELF:_oGradientColor := oColor

	ACCESS Header 
		RETURN SELF:_oParentHeader


	METHOD HiLite( hDC AS PTR, lOnOff AS LOGIC ) AS VOID  
		IF SELF:_oParentHeader:BarStyle == #FABSTYLE		
			SELF:DrawFab( hDC, lOnOff )
		ELSEIF SELF:_oParentHeader:BarStyle == #NEWSTYLE
			SELF:DrawNew( hDC, lOnOff )
		ELSE 
			SELF:DrawStd( hDC, lOnOff )
		ENDIF
RETURN		

	METHOD HitTest( oPoint AS Point ) AS LOGIC  
		LOCAL oTmpItemArea AS WRect
		LOCAL rcInside IS _winRect
		LOCAL lRet AS LOGIC
	// If the point is not inside the controls item area, don´t check
		SELF:Control:GetInsideRect( @rcInside )
		oTmpItemArea := WRect{}
		oTmpItemArea:SetRectWin( @rcInside )
	//
		IF oTmpItemArea:PointInSide( oPoint )
		// KP 27.04.2001
		// to avoid flicker when the mouse is between the item and its caption, extend the
		// item area to the caption area
			oTmpItemArea := SELF:Area:Clone()
			IF !Empty(SELF:Caption)
				oTmpItemArea:Bottom := SELF:LabelArea:Top
			ENDIF
		//
//		lRet := SELF:Area:PointInside( oPoint )
			lRet := oTmpItemArea:PointInSide( oPoint )
			IF !lRet .AND. !Empty(SELF:Caption)
				lRet := SELF:LabelArea:PointInSide( oPoint )
			ENDIF
		ELSE
			lRet := FALSE
		ENDIF
		RETURN lRet

	ACCESS ImageIndex AS LONG  
//r The Image Index in the ImageList of the OutlookBar
		RETURN SELF:_iImage


	CONSTRUCTOR(symName, cCaption, iImage, uValue) 
//p Create a OutlookBar Item
//a <symName> 	SymBol Name of the Item
//a <cCaption>	Caption of the Item
//a <iImage>	Image Index to use in ImageList
//a <uValue>	User-Defined Value attached to the Item
	//
		SUPER(symName, cCaption, uValue)
	//
		SELF:_oLabelArea := WRect{}
		SELF:_iImage := iImage
		SELF:_lPressed := FALSE
   //
		SELF:GradientColor := Color{ 255,255,255 }
RETURN		 

	ACCESS LabelArea AS BoundingBox  
		RETURN SELF:_oLabelArea:BoundingBox


	ASSIGN LabelArea( oDim AS BoundingBox )   
		SELF:_oLabelArea:BoundingBox := oDim


	METHOD Press( lOnOff AS LOGIC ) AS VOID  
// Internal Method
// Draw the Item
		LOCAL hDC AS PTR
	//
		IF lOnOff
			IF !SELF:_lPressed
				SELF:_lPressed := TRUE
				hDC := GetDC( SELF:Control:Handle() )
				IF SELF:_oParentHeader:BarStyle == #FABSTYLE		
					SELF:DrawFab( hDC, FALSE )
				ELSEIF SELF:_oParentHeader:BarStyle == #NEWSTYLE
					SELF:DrawNew( hDC, FALSE )
				ELSE 
					SELF:DrawStd( hDC, FALSE )
				ENDIF
				ReleaseDC( SELF:Control:Handle(), hDC )
			ENDIF
		ELSE
			IF SELF:_lPressed
				SELF:_lPressed := FALSE
				hDC := GetDC( SELF:Control:Handle() )
				IF SELF:_oParentHeader:BarStyle == #FABSTYLE		
					SELF:DrawFab( hDC, FALSE )
				ELSEIF SELF:_oParentHeader:BarStyle == #NEWSTYLE
					SELF:DrawNew( hDC, FALSE )
				ELSE 
					SELF:DrawStd( hDC, FALSE )
				ENDIF	
				ReleaseDC( SELF:Control:Handle(), hDC )
			ENDIF
		ENDIF

RETURN		

	ACCESS TotalHeight AS LONG  
		LOCAL iHeight AS INT
	//
		iHeight := SELF:Area:Height
		IF !Empty(SELF:Caption)
			iHeight += SELF:Control:LabelSpacing
			iHeight += SELF:LabelArea:Height
		ENDIF
	//
		RETURN iHeight


	METHOD Update() AS VOID  
	//
		IF ( SELF:_oParentHeader != NULL_OBJECT )
			SELF:_oParentHeader:Update()
		ENDIF
	//
RETURN		
END CLASS

