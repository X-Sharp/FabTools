
CLASS OutlookBarHeader INHERIT OutlookBarBase

	PROTECT _aItems 					AS ARRAY
	PROTECT _iFirstVisibleItem 	AS LONG		// -1, means nothing in
	PROTECT _iLastVisibleItem 		AS LONG	
	PROTECT _oOutlookBar 			AS OutlookBar

	PROTECT _lUpArrow 				AS LOGIC		
	PROTECT _lDownArrow 				AS LOGIC			

	PROTECT _oUpArrow 				AS OutlookBarArrow
	PROTECT _oDownArrow 				AS OutlookBarArrow
	PROTECT _oTextColor				AS Color
	PROTECT _oHiLiteColor			AS	Color
	PROTECT _oGradientColor			AS	Color

	PROTECT _iImage 		AS LONG

	METHOD __ItemsGradientColor( oColor AS Color ) AS VOID  
		LOCAL oItem 	AS OutlookBarItem
		LOCAL i 			AS DWORD
		LOCAL nCount 	AS DWORD
	//
		nCount := SELF:ItemCount
		FOR i := 1 UPTO nCount STEP 1
			oItem := SELF:_aItems[ i,2 ]
			oItem:GradientColor := oColor
		NEXT
	//
		RETURN		
		

	ASSIGN __OutlookBar( oOLBControl AS OutlookBar )   
		SELF:_oOutlookBar := oOLBControl
		RETURN 

	METHOD _DrawFabBack( hDC AS PTR ) AS VOID  
/*
	LOCAL hBrush AS PTR
	LOCAL dwOldColor AS DWORD
	LOCAL dwOldBkColor AS DWORD
	LOCAL Rect IS _WinRECT
	//
	hBrush := SELF:_GetHalftoneBrush()
	//
	rect.top := SELF:Area:Top
	rect.left := SELF:Area:Left
	rect.bottom := SELF:Area:Bottom
	rect.right := SELF:Area:Right
	//
	dwOldColor := SetTextColor( hDC, SELF:HiLiteColor:ColorRef )
	dwOldBkColor := SetBkColor( hDC, SELF:BackgroundColor:ColorRef )
	//	
	FillRect( hDC, @rect, hBrush )
	//
	DeleteObject(hBrush)
	//
	SetTextColor( hDC, dwOldColor )
	SetBkColor( hDC, dwOldBkColor )
	//
//	COLOR_HOTLIGHT
//	COLOR_BTNTEXT
*/
		RETURN		 

	METHOD _DrawFabText( hDC AS PTR ) AS VOID  
		LOCAL rect IS _WINRect
		LOCAL dwOldColor AS DWORD
		LOCAL iOldBKMode AS INT
		LOCAL hOldFont AS PTR
		LOCAL lSelected AS LOGIC
		LOCAL hNewFont AS PTR
		LOCAL hFont AS PTR
		LOCAL LogFont IS _winLOGFONT
	//
		lSelected := ( SELF:_symName == SELF:_oOutlookBar:ActiveHeader )
	//
		rect:top := SELF:Area:Top
		rect:left := SELF:Area:Left
		IF ( SELF:_iImage > 0 )
			IF ( SELF:_oOutlookBar:SmallImageList != NULL_OBJECT )
				rect:left := rect:left + SELF:_oOutlookBar:SmallImageWidth
			ELSEIF ( SELF:_oOutlookBar:ImageList != NULL_OBJECT )
				rect:left := rect:left + SELF:_oOutlookBar:ImageWidth
			ENDIF
		ENDIF	
		rect:bottom := SELF:Area:Bottom
		rect:right := SELF:Area:Right
	// Now, the Caption
		hFont := GetStockObject( ANSI_VAR_FONT )
	//
		IF lSelected
		//
			GetObject( hFont, _sizeof(_winLOGFONT), @LogFont )
			SELF:_DrawFabBack( hDC )
		//
			LogFont:lfWeight := FW_EXTRABOLD
			hNewFont := CreateFontIndirect( @LogFont )
			hOldFont := SelectObject( hDC, hNewFont )
		ELSE
			hOldFont := SelectObject( hDC, hFont )
		ENDIF
	//
	// Draw the Text INSIDE the rectangle
		InflateRect( @rect, -2, -2)
		IF SELF:_lPressed
		// Change the Pos if pressed
			OffsetRect( @rect, 1, 1)
		ENDIF
		iOldBKMode := SetBkMode( hDC, TRANSPARENT )
		IF SELF:IsEnabled
			dwOldColor := SetTextColor( hDC, SELF:TextColor:ColorRef )
		ELSE
			dwOldColor := SetTextColor( hDC, GetSysColor( COLOR_GRAYTEXT ) )	
		ENDIF
	//
		DrawText( hDC, String2Psz( SELF:Caption ), LONG(SLen(SELF:Caption)), @rect, DT_CENTER + DT_VCENTER + DT_SINGLELINE + DT_END_ELLIPSIS)
	//
		SelectObject( hDC, hOldFont )
		SetTextColor( hDC, dwOldColor )
		SetBkMode( hDC, iOldBKMode )
		IF lSelected .OR. !SELF:IsEnabled
			DeleteObject( hNewFont )
		ENDIF
	//
		RETURN		 

	METHOD AddItem( oOLItem AS OutlookBarItem ) AS OutlookBarItem  
//p Add an OutlookBarItem to the Header
	//
		oOLItem:__ParentHeader := SELF
		AAdd(_aItems, {oOLItem:NameSym, oOLItem})
	// Falls noch kein Item vorhanden war, Anzeige beginnt beim ersten
		IF SELF:_iFirstVisibleItem < 0
			SELF:_iFirstVisibleItem := 1
		ENDIF
	//
		RETURN oOLItem

	ACCESS BackgroundColor AS Color  
		RETURN SELF:_oOutlookBar:BackgroundColor

	ACCESS Control AS OutlookBar
		RETURN SELF:_oOutlookBar

	ACCESS DownArrow AS OutlookBarArrow  
//r The OutlookBarArrow object associated for the Down Arrow
		RETURN SELF:_oDownArrow

	METHOD Draw( hDC AS PTR ) AS VOID  
//p Draw the Outlookbar Header
		IF ( SELF:BarStyle == #FABSTYLE )
			SELF:DrawFab( hDC )
		ELSEIF ( SELF:BarStyle == #NEWSTYLE )
			SELF:DrawNew( hDC )
		ELSE
			SELF:DrawStd( hDC )
		ENDIF
		RETURN		 

	METHOD DrawArrows( hDC AS PTR ) AS LOGIC  
	//
		IF SELF:_lUpArrow
			SELF:_oUpArrow:Draw( hDC )
		ENDIF
	//
		IF SELF:_lDownArrow
			SELF:_oDownArrow:Draw( hDC )
		ENDIF
	//
		RETURN TRUE

	METHOD DrawFab( hDC AS PTR ) AS VOID  
//p Draw the Outlookbar Header
		LOCAL rect IS _WINRect
		LOCAL hBrush AS PTR
		LOCAL hPen AS PTR
		LOCAL hOldPen AS PTR
		LOCAL dwFace AS DWORD
		LOCAL dwLight AS DWORD
		LOCAL dwShadow AS DWORD
		LOCAL lSelected AS LOGIC
		LOCAL nX, nY	AS	LONG
		LOCAL iImagePos	AS	LONG
		LOCAL hImgList	AS	PTR
		LOCAL hIcon		AS	PTR
	//
		lSelected := ( SELF:_symName == SELF:_oOutlookBar:ActiveHeader )
	//
		rect:top := SELF:Area:Top
		rect:left := SELF:Area:Left
		rect:bottom := SELF:Area:Bottom
		rect:right := SELF:Area:Right
	//
	//InflateRect( @rect, -1, -1)
	//
		dwFace := GetSysColor(COLOR_3DFACE)
		IF SELF:_lPressed
			dwShadow := GetSysColor(COLOR_3DHIGHLIGHT)
			dwLight := GetSysColor(COLOR_3DSHADOW)
		ELSE
			dwLight := GetSysColor(COLOR_3DHIGHLIGHT)
			dwShadow := GetSysColor(COLOR_3DSHADOW)
		ENDIF
	// Header's Rectangle
		hBrush := CreateSolidBrush( dwFace )
		FillRect( hDC, @rect, hBrush)
		DeleteObject(hBrush)
	//
		hPen := CreatePen( PS_SOLID,1, dwLight)
		hOldPen := SelectObject( hDC, hPen )
		MoveToEx( hDC, rect:right, rect:top, NULL_PTR )
		LineTo( hDC, rect:left, rect:top)
		LineTo( hDC, rect:left, rect:bottom)
	//
		SelectObject( hDC, hOldPen )
		DeleteObject( hPen )
	//
		hPen := CreatePen( PS_SOLID,1, dwShadow)
		hOldPen := SelectObject( hDC, hPen )
		MoveToEx( hDC, rect:left+1, rect:bottom, NULL_PTR )
		LineTo( hDC, rect:right, rect:bottom)
		LineTo( hDC, rect:right, rect:top )
	//
		SelectObject( hDC, hOldPen )
		DeleteObject( hPen )
	//
		nX := SELF:Area:Left + 2
		nY := SELF:Area:Top + 2
	//
		IF SELF:_lPressed
		//
			nX := nX + 1
			nY := nY + 1
		//
		ENDIF
	//
		IF ( SELF:_iImage > 0 )
			iImagePos := SELF:_iImage - 1
			IF ( SELF:_oOutlookBar:SmallImageList != NULL_OBJECT )
				hImgList := SELF:_oOutlookBar:SmallImageList:Handle()
			ELSEIF ( SELF:_oOutlookBar:ImageList != NULL_OBJECT )
				hImgList := SELF:_oOutlookBar:ImageList:Handle()
			ENDIF
			IF ( hImgList != NULL_PTR )	
			// Draw the Image
				IF SELF:IsEnabled
					ImageList_Draw( hImgList, iImagePos, hDC, nX, nY, ILD_NORMAL)
				ELSE
					hIcon := ImageList_ExtractIcon( 0, hImgList, iImagePos )
					DrawState( hDc, NULL_PTR, NULL_PTR, LONG(_CAST,hIcon),0,nX,nY,0,0,_OR(DST_ICON,DSS_DISABLED))
					DestroyIcon( hIcon )
				ENDIF
			ENDIF
		ENDIF
	// Now, the Caption
		SELF:_DrawFabText( hDC )
		RETURN		
		

	METHOD	 DrawGradientFillBackground( hDC AS PTR, rect AS _WINRect, lOnOff AS LOGIC ) AS LOGIC  
		LOCAL DIM vert[2] IS _WINTRIVERTEX
		LOCAL grect 		IS  _winGRADIENT_RECT
		LOCAL dwColor 		AS DWORD
		LOCAL oColor		AS	Color
		LOCAL dwWhite		AS	DWORD
		LOCAL dwStart		AS	DWORD
		LOCAL dwEnd			AS	DWORD
   //
		IF ( lOnOff ) .OR. SELF:_lPressed
			oColor := SELF:HiliteBackgroundColor
		ELSE
			oColor := SELF:ItemsBackgroundColor
		ENDIF
		dwColor := oColor:ColorRef
		dwWhite := SELF:_oGradientColor:ColorRef
	//  
		IF ( SELF:_lPressed )
			dwStart := dwColor
			dwEnd   := dwWhite
		ELSE
			dwStart := dwWhite
			dwEnd   := dwColor
		ENDIF
	//
		vert[1]:x      := rect:left
		vert[1]:y      := rect:top
		vert[1]:Red    := MakeWord(0,GetRValue(dwStart))
		vert[1]:Green  := MakeWord(0,GetGValue(dwStart))
		vert[1]:Blue   := MakeWord(0,GetBValue(dwStart))
		vert[1]:Alpha  := 0x0000

		vert[2]:x      := rect:right
		vert[2]:y      := rect:bottom 
		vert[2]:Red    := MakeWord(0,GetRValue(dwEnd))
		vert[2]:Green  := MakeWord(0,GetGValue(dwEnd))
		vert[2]:Blue   := MakeWord(0,GetBValue(dwEnd))
		vert[2]:Alpha  := 0x0000

		grect:UpperLeft  := 0
		grect:LowerRight := 1
	//
		GradientFill( hDC, @vert, 2, @grect, 1, GRADIENT_FILL_RECT_H )
	//
		RETURN		 TRUE  

	METHOD DrawItems( hDC AS PTR, rcInside AS _WINRect ) AS LOGIC  
// Internal method
// Draw each item (in the visible rect)
		LOCAL oItem 	AS OutlookBarItem
		LOCAL yStart 	AS INT
		LOCAL i 			AS DWORD
		LOCAL nCount 	AS DWORD
		LOCAL iFirstItem AS INT
	//
		iFirstItem := SELF:FirstVisibleItem
	//
		nCount := SELF:ItemCount
		yStart := rcInside:Top + SELF:_oOutlookBar:ItemTopSpace
	//
		FOR i := DWORD(iFirstItem) UPTO nCount STEP 1
			oItem := SELF:GetItem(i)
			oItem:Draw( hDC )
			yStart += oItem:TotalHeight + SELF:_oOutlookBar:ItemSpacing
			IF yStart > rcInside:Bottom
				EXIT
			ENDIF
		NEXT
	//
		RETURN TRUE
		
		

	METHOD DrawNew( hDC AS PTR ) AS VOID  
//p Draw the Outlookbar Header
		LOCAL rect IS _WINRect
		LOCAL hBrush AS PTR
		LOCAL hPen AS PTR
		LOCAL hOldPen AS PTR
		LOCAL dwFace AS DWORD
		LOCAL dwLight AS DWORD
		LOCAL dwShadow AS DWORD
		LOCAL lSelected AS LOGIC
		LOCAL nX, nY	AS	LONG
		LOCAL iImagePos	AS	LONG
		LOCAL hImgList	AS	PTR
		LOCAL hIcon		AS	PTR
	//
		lSelected := ( SELF:_symName == SELF:_oOutlookBar:ActiveHeader )
	//
		rect:top := SELF:Area:top
		rect:left := SELF:Area:left
		rect:bottom := SELF:Area:bottom
		rect:right := SELF:Area:right
	//
	//InflateRect( @rect, -1, -1)
	//
		dwFace := GetSysColor(COLOR_3DFACE)
	//
		IF SELF:_lPressed
			dwShadow := GetSysColor(COLOR_3DHIGHLIGHT)
			dwLight := GetSysColor(COLOR_3DSHADOW)
		ELSE
			dwLight := GetSysColor(COLOR_3DHIGHLIGHT)
			dwShadow := GetSysColor(COLOR_3DSHADOW)
		ENDIF
	// Header's Rectangle
		hBrush := CreateSolidBrush( dwFace )
		FillRect( hDC, @rect, hBrush)
		DeleteObject(hBrush)
	//
		SELF:DrawGradientFillBackground( hDC, @rect, lSelected )
	//
		hPen := CreatePen( PS_SOLID,1, dwLight)
		hOldPen := SelectObject( hDC, hPen )
		MoveToEx( hDC, rect:right, rect:top, NULL_PTR )
		LineTo( hDC, rect:left, rect:top)
		LineTo( hDC, rect:left, rect:bottom)
	//
		SelectObject( hDC, hOldPen )
		DeleteObject( hPen )
	//
		hPen := CreatePen( PS_SOLID,1, dwShadow)
		hOldPen := SelectObject( hDC, hPen )
		MoveToEx( hDC, rect:left+1, rect:bottom, NULL_PTR )
		LineTo( hDC, rect:right, rect:bottom)
		LineTo( hDC, rect:right, rect:top )
	//
		SelectObject( hDC, hOldPen )
		DeleteObject( hPen )
	//
		nX := SELF:Area:left + 2
		nY := SELF:Area:top + 2
	//
		IF SELF:_lPressed
		//
			nX := nX + 1
			nY := nY + 1
		//
		ENDIF
	//
		IF ( SELF:_iImage > 0 )
			iImagePos := SELF:_iImage - 1
			IF ( SELF:_oOutlookBar:SmallImageList != NULL_OBJECT )
				hImgList := SELF:_oOutlookBar:SmallImageList:Handle()
			ELSEIF ( SELF:_oOutlookBar:ImageList != NULL_OBJECT )
				hImgList := SELF:_oOutlookBar:ImageList:Handle()
			ENDIF
			IF ( hImgList != NULL_PTR )	
			// Draw the Image
				IF SELF:IsEnabled
					ImageList_Draw( hImgList, iImagePos, hDC, nX, nY, ILD_NORMAL)
				ELSE
					hIcon := ImageList_ExtractIcon( 0, hImgList, iImagePos )
					DrawState( hDC, NULL_PTR, NULL_PTR, LONG(_CAST,hIcon),0,nX,nY,0,0,_OR(DST_ICON,DSS_DISABLED))
					DestroyIcon( hIcon )
				ENDIF
			ENDIF
		ENDIF
	// Now, the Caption
		SELF:_DrawFabText( hDC )
		RETURN		
		

	METHOD DrawStd( hDC AS PTR ) AS VOID  
//p Draw the Outlookbar Header
		LOCAL rect IS _WINRect
		LOCAL hBrush AS PTR
		LOCAL hPen AS PTR
		LOCAL hOldPen AS PTR
		LOCAL dwFace AS DWORD
		LOCAL dwLight AS DWORD
		LOCAL dwShadow AS DWORD
		LOCAL dwOldColor AS DWORD
		LOCAL iOldBKMode AS INT
		LOCAL hOldFont AS PTR
	//
		rect:top := SELF:Area:top
		rect:left := SELF:Area:left
		rect:bottom := SELF:Area:bottom
		rect:right := SELF:Area:right
	//
		dwFace := GetSysColor(COLOR_3DFACE)
		IF SELF:_lPressed
			dwShadow := GetSysColor(COLOR_3DHIGHLIGHT)
			dwLight := GetSysColor(COLOR_3DSHADOW)
		ELSE
			dwLight := GetSysColor(COLOR_3DHIGHLIGHT)
			dwShadow := GetSysColor(COLOR_3DSHADOW)
		ENDIF
	// Header's Rectangle
		hBrush := CreateSolidBrush( dwFace )
		FillRect( hDC, @rect, hBrush)
		DeleteObject(hBrush)
	//
		hPen := CreatePen( PS_SOLID,1, dwLight)
		hOldPen := SelectObject( hDC, hPen )
		MoveToEx( hDC, rect:right, rect:top, NULL_PTR )
		LineTo( hDC, rect:left, rect:top)
		LineTo( hDC, rect:left, rect:bottom)
	//
		SelectObject( hDC, hOldPen )
		DeleteObject( hPen )
	//
		hPen := CreatePen( PS_SOLID,1, dwShadow)
		hOldPen := SelectObject( hDC, hPen )
		MoveToEx( hDC, rect:left+1, rect:bottom, NULL_PTR )
		LineTo( hDC, rect:right, rect:bottom)
		LineTo( hDC, rect:right, rect:top )
	//
		SelectObject( hDC, hOldPen )
		DeleteObject( hPen )
	// Now, the Caption
		hOldFont := SelectObject( hDC, GetStockObject( ANSI_VAR_FONT ) )
		dwOldColor := SetTextColor( hDC, DWORD(RGB(0,0,0)))
		iOldBKMode := SetBkMode( hDC, TRANSPARENT )
	// Draw the Text INSIDE the rectangle
		InflateRect( @rect, -2, -2)
		IF SELF:_lPressed
		// Change the Pos if pressed
			OffsetRect( @rect, 1, 1)
		ENDIF
		DrawText( hDC, String2Psz( SELF:Caption ), LONG(SLen(SELF:Caption)), @rect, DT_CENTER + DT_VCENTER + DT_SINGLELINE + DT_END_ELLIPSIS)
	//
		SetTextColor( hDC, dwOldColor )
		SetBkMode( hDC, iOldBKMode )
		SelectObject( hDC, hOldFont )
	//
		RETURN		 

	ACCESS FirstVisibleItem AS LONG  
//r The index of the First Item visible
		RETURN SELF:_iFirstVisibleItem


	ASSIGN FirstVisibleItem( nItem AS LONG )   
//p Set the First Item Visible (using it's index)
		SELF:_iFirstVisibleItem := nItem


	METHOD GetItem( nPos AS DWORD ) AS OutlookBarItem  
//p Retrieve an OutlookBarItem, based on it's pos
		LOCAL oRet AS OutlookBarItem
	//
	// 07/03/2003 _ Bug : ALen(SELF:_aItems) > 1
		IF ( ALen(SELF:_aItems) >= 1 )
			IF Between( nPos, 1, ALen(SELF:_aItems))
				oRet := SELF:_aItems[nPos,2]
			ENDIF
		ENDIF
		RETURN oRet

	METHOD GetItemFromSymbol( symItem AS SYMBOL ) AS OutlookbarItem  
		LOCAL nPos AS DWORD
		LOCAL oItem AS OutlookbarItem
	//
		nPos := AScan( SELF:_aItems, {|aX| aX[1] = symItem})
		IF nPos > 0
			oItem := SELF:_aItems[nPos, 2]
		ENDIF
		RETURN oItem

	ACCESS GradientColor AS Color  
		RETURN SELF:_oGradientColor

	ASSIGN GradientColor( oColor AS Color )   
		SELF:_oGradientColor := oColor

	ACCESS HiliteBackgroundColor AS Color  
		RETURN SELF:_oOutlookBar:HiliteBackgroundColor

	ACCESS HiLiteColor AS Color  
		RETURN SELF:_oHiLiteColor

	ASSIGN HiLiteColor( oColor AS Color )   
		SELF:_oHiLiteColor := oColor

	ACCESS ImageIndex AS LONG  
//r The Image Index in the ImageList of the OutlookBar
		RETURN SELF:_iImage

	CONSTRUCTOR(symName, cCaption, uValue, iImage) 
//p Create a OutlookBar Header
//a <symName> 	SymBol Name of the Header
//a <cCaption>	Caption of the Header
//a <uValue>	User-Defined Value attached to the Header
//a <iImage>	Image Index to use in either SmallImageList or ImageList
	//
		SUPER( symName, cCaption, uValue )    
	//
		SELF:_aItems := {}
		SELF:_lPressed := FALSE
		SELF:_iFirstVisibleItem := -1	// Currently, nothing
		SELF:_iLastVisibleItem := -1	// Currenlty, nothing
		SELF:_lUpArrow := FALSE
		SELF:_lDownArrow := FALSE
	//
		SELF:_oUpArrow := OutlookBarArrow{#_Up, SELF }
		SELF:_oDownArrow := OutlookBarArrow{#_Down, SELF }
	//
		SELF:TextColor := __RGB2Color( GetSysColor( COLOR_BTNTEXT ) )
	//
		SELF:HiLiteColor := __RGB2Color( GetSysColor( COLOR_HIGHLIGHT ) )
	//
		SELF:GradientColor := Color{247,194,95}
	//
		IF IsNumeric( iImage )
			SELF:_iImage := iImage
		ENDIF
	//
		RETURN		 

	ACCESS IsDownArrow AS LOGIC  
//r Has an Arrow ?
		RETURN SELF:_lDownArrow

	ASSIGN IsDownArrow( lOnOff AS LOGIC  )   
//p Set/Reset the use of an arrow
		SELF:_lDownArrow := lOnOff

	ACCESS IsItemsBoxed AS LOGIC  
		RETURN SELF:_oOutlookBar:IsItemsBoxed

	ACCESS IsUpArrow AS LOGIC  
//r Has an Arrow ?
		RETURN SELF:_lUpArrow

	ASSIGN IsUpArrow( lOnOff AS LOGIC )   
//p Set/Reset the use of an arrow
		SELF:_lUpArrow := lOnOff

	ACCESS ItemCount AS DWORD  
		RETURN ALen(SELF:_aItems)

	ACCESS ItemsBackgroundColor AS Color  
		RETURN SELF:_oOutlookBar:ItemsBackgroundColor

	ACCESS LastVisibleItem AS LONG  
//r The index of the Last Item visible
		RETURN SELF:_iLastVisibleItem


	ASSIGN LastVisibleItem( nItem AS LONG )   
//p Set the last Item Visible (using it's index)
		SELF:_iLastVisibleItem := nItem

	METHOD Press( lOnOff AS LOGIC ) AS VOID  
//p Change the state of the Header
		LOCAL hDC AS PTR

		IF lOnOff
			IF !SELF:_lPressed
				SELF:_lPressed := TRUE
				hDC := GetDC( SELF:_oOutlookBar:Handle() )
				SELF:Draw( hDC )
				ReleaseDC( SELF:_oOutlookBar:Handle(), hDC )
			ENDIF
		ELSE
			IF SELF:_lPressed
				SELF:_lPressed := FALSE
				hDC := GetDC( SELF:_oOutlookBar:Handle() )
				SELF:Draw( hDC )
				ReleaseDC( SELF:_oOutlookBar:Handle(), hDC )
			ENDIF
		ENDIF

		RETURN		 

	METHOD ScrollDown() 
		LOCAL oItem AS OutlookBarItem
		LOCAL rc IS _winRect
	//
		IF (SELF:_iLastVisibleItem < LONG(SELF:ItemCount))
			SELF:_iFirstVisibleItem += 1
			RETURN TRUE
	// check, if the last item is complete visible
		ELSEIF (SELF:_iLastVisibleItem = LONG(SELF:ItemCount))
			oItem := SELF:GetItem(SELF:ItemCount)
			SELF:Control:GetInsideRect(@rc)
			IF oItem:Area:Top + oItem:TotalHeight > rc:bottom
				SELF:_iFirstVisibleItem += 1
				RETURN TRUE
			ENDIF
		ENDIF
		RETURN FALSE


	METHOD ScrollUp() AS LOGIC  
//p Move the Items up
//r A logical value indicating the new first item index
		IF SELF:_iFirstVisibleItem > 0
			SELF:_iFirstVisibleItem -= 1
			RETURN TRUE
		ENDIF
	//
		RETURN FALSE

	METHOD SetDownArrowPos( rect AS _winRect ) AS LOGIC  
		SELF:_oDownArrow:Area:SetRectWin( rect )
		RETURN TRUE

	METHOD SetUpArrowPos( rect AS _winRect ) AS LOGIC  
		SELF:_oUpArrow:Area:SetRectWin( rect )
		RETURN TRUE

	ACCESS BarStyle AS SYMBOL  
		RETURN SELF:_oOutlookBar:BarStyle

	ACCESS TextColor AS Color  
		RETURN SELF:_oTextColor

	ASSIGN TextColor( oColor AS Color )   
		SELF:_oTextColor := oColor

	ACCESS UpArrow AS OutlookBarArrow  
//r The OutlookBarArrow object associated for the Up Arrow
		RETURN SELF:_oUpArrow

	METHOD Update() AS VOID  
	//
		IF ( SELF:_oOutlookBar != NULL_OBJECT )
			SELF:_oOutlookBar:Update()
		ENDIF
	//
		RETURN	
		
END CLASS

