
CLASS OutlookBar INHERIT CustomControl
//p Control to build a bar that "look & feel" like the Outlook Bar

	PROTECT _oImageList AS ImageList
	PROTECT _oBackground AS Color
	PROTECT _oBackgroundHilite AS Color
	PROTECT _oItemsBackground AS Color

	PROTECT _hDC AS PTR

	PROTECT _symCurrentHeader AS SYMBOL
	PROTECT _symActiveItem AS SYMBOL
	PROTECT _symTrappingHeader AS SYMBOL	// wird bei MouseButtonDown gesetzt
	PROTECT _symTrappingItem AS SYMBOL
	PROTECT _symTrappingArrow AS SYMBOL

	PROTECT _symHiLitedItem AS SYMBOL
	
	
	// Two dimension Array : Each element is { symbol, header object } 
	PROTECT _aHeaders AS ARRAY
	// Height of each headers
	PROTECT _nHeaderHeight AS INT
	PROTECT _nYBottomHeaderStart AS INT	// hier beginnt der erste der unten liegenden Headers

// distance between the first visible bitmap and the above header
	PROTECT _nItemTopSpace AS INT	
	// distance between the items bitmap and its caption
	PROTECT _nLabelSpacing AS INT	
	// distance between the items
	PROTECT _nItemSpacing AS INT	
	// the rect, where all visible items are drawn
	PROTECT _rcInside IS _winRECT
	// In #NEWSTYLE, Draw a box around Items ?
	PROTECT _lDrawBox AS LOGIC	
	
	PROTECT _symStyle	AS	SYMBOL
	PROTECT _oSmlImgList	AS	ImageList

	METHOD _RectHeight( cRect AS _winRect ) AS LONG  
		LOCAL iHeight AS LONG
		iHeight := cRect:bottom - cRect:top
		RETURN iHeight

	METHOD _RectWidth( cRect AS _winRect ) AS LONG  
		LOCAL iWidth AS LONG
		iWidth := cRect:right - cRect:left
		RETURN iWidth


	ACCESS ActiveHeader AS SYMBOL  
		RETURN SELF:_symCurrentHeader


	ASSIGN ActiveHeader( symNewHeader AS SYMBOL )   
		IF symNewHeader != _symCurrentHeader
			_symCurrentHeader := symNewHeader
			SELF:Recalc()
		ENDIF
		RETURN 


	METHOD AddHeader( oOLHeader AS OutlookBarHeader ) AS LOGIC  
		LOCAL lRet AS LOGIC
	//
		lRet := SELF:InsertHeader( oOLHeader, #Last )
		RETURN lRet


	ACCESS BackgroundColor AS Color  
		RETURN SELF:_oBackground


	ASSIGN BackgroundColor( oColor AS Color )   
		SELF:_oBackground := oColor
	// need to repaint to update the screen
		SELF:Update()
		RETURN 

	METHOD Dispatch( oEvent ) 

	// Der Controlhintergrund nuss nicht gelöscht werden,
	// weil wir den Hintergrund selbst füllen
		IF oEvent:uMsg = WM_ERASEBKGND	
			RETURN 1L
		ELSEIF oEvent:uMsg = WM_THEMECHANGED
		// Change in Theme ?       
		// Force redraw for #NEWSTYLE
			SELF:RegisterTimer(1,TRUE)
		ENDIF
		RETURN SUPER:Dispatch( oEvent )


	METHOD DrawArrows( hDC AS PTR) AS LOGIC  

		LOCAL oHeader AS OutlookBarHeader

		oHeader := SELF:GetActiveHeader()
		IF oHeader = NULL_OBJECT
			RETURN FALSE
		ENDIF

		oHeader:DrawArrows( hDC )

		RETURN TRUE


	METHOD DrawBackground( hDC AS PTR) AS LOGIC  
		LOCAL hBrush AS PTR
		LOCAL rect IS _winRECT
		LOCAL dwColor AS DWORD
	//
		dwColor := SELF:_oBackground:ColorRef
		GetClientRect( SELF:Handle(), @rect )
    //
		hBrush := CreateSolidBrush( dwColor )
	//
		FillRect( hDC, @rect, hBrush )
	//
		DeleteObject(hBrush)
	//	
		RETURN TRUE


	METHOD DrawHeaders( hDC AS PTR ) AS LOGIC  
		LOCAL i AS DWORD
		LOCAL nCount AS DWORD
		LOCAL oHeader AS OutlookBarHeader
		LOCAL iSavedDC AS INT
		LOCAL rcInside IS _winRect
		LOCAL hRegion AS PTR
	//
		IF ( SELF:_nHeaderHeight != 0 )
		//	
			nCount := ALen(_aHeaders)
			FOR i := 1 UPTO nCount
				oHeader := _aHeaders[i,2]
				oHeader:Draw( hDC )
			NEXT
		ENDIF
	//
		oHeader := SELF:GetActiveHeader()
		IF oHeader != NULL_OBJECT .AND. oHeader:FirstVisibleItem > 0
		//
			rcInside := SELF:_rcInside
			iSavedDC := SaveDC( hDC )
			hRegion := CreateRectRgnIndirect(@rcInside)
			SelectClipRgn( hDC, hRegion )
			DeleteObject( hRegion )
		//
			oHeader:DrawItems( hDC, @rcInside )
		//
			RestoreDC( hDC, iSavedDC )
		//
			oHeader:DrawArrows( hDC )
		//
		ENDIF	
		RETURN TRUE


	METHOD DrawItems( hDC AS PTR ) AS LOGIC  
		LOCAL oHeader 	AS OutlookBarHeader
		LOCAL oItem 	AS OutlookBarItem
		LOCAL yStart 	AS INT
		LOCAL i 			AS DWORD
		LOCAL nCount 	AS DWORD
		LOCAL iSavedDC AS INT
		LOCAL rcInside IS _winRect
		LOCAL hRegion 	AS PTR
		LOCAL iFirstItem AS INT
	//
		oHeader := SELF:GetActiveHeader()
	//
		IF (oHeader != NULL_OBJECT) .AND. (oHeader:FirstVisibleItem > 0)  
		//
			iFirstItem := oHeader:FirstVisibleItem
			rcInside := SELF:_rcInside
			iSavedDC := SaveDC( hDC )
			hRegion := CreateRectRgnIndirect(@rcInside)
			SelectClipRgn( hDC, hRegion )
			DeleteObject( hRegion )
			nCount := oHeader:ItemCount
			yStart := rcInside:Top + SELF:_nItemTopSpace
		//
			FOR i := DWORD(iFirstItem) UPTO nCount STEP 1
				oItem := oHeader:GetItem(i)
				oItem:Draw( hDC )
				yStart += oItem:TotalHeight + SELF:_nItemSpacing
				IF yStart > rcInside:Bottom
					EXIT
				ENDIF
			NEXT
			RestoreDC( hDC, iSavedDC )
		ENDIF

		RETURN TRUE


	METHOD Expose(oEE) 
		LOCAL clientRect IS _winRECT
		LOCAL memDC AS PTR
		LOCAL hBmp AS PTR
		LOCAL hOldBmp AS PTR
		LOCAL iWidth AS LONG
		LOCAL iHeight AS LONG
		//LOCAL lRet AS LOGIC
		LOCAL myDC AS PTR
	//
		SELF:Recalc()
	// get a device context and create a compatible bitmap
	// actual drawin occurs on the bitmap to avoid flicker
		myDC := GetDC( SELF:Handle() )
		GetClientRect( SELF:Handle(), @clientRect )
		iWidth := SELF:_RectWidth( @clientRect )
		iHeight := SELF:_RectHeight( @clientRect )
		memDC := CreateCompatibleDC( myDC )
		hBmp := CreateCompatibleBitmap( myDC, iWidth, iHeight)
		hOldBmp := SelectObject( memDC, hBmp )
	//
		SELF:DrawBackground( memDC )
		SELF:DrawHeaders( memDC )
/*
	SELF:DrawItems( memDC )
	SELF:DrawArrows( memDC )
*/
	//
		BitBlt( myDC, clientRect:left, clientRect:top, iWidth, iHeight, memDC, 0, 0, SRCCOPY)
		SelectObject( memDC, hOldBmp )
		DeleteObject( hBmp )
		DeleteDC( memDC )
		ReleaseDC( SELF:Handle(), myDC )

		RETURN		 SELF

	METHOD GetActiveHeader( ) AS OutlookBarHeader  
		LOCAL oHeader AS OutlookbarHeader
	//
		oHeader := SELF:GetHeaderFromSymbol( SELF:_symCurrentHeader )
		RETURN oHeader


	METHOD GetHeaderFromPoint( oPoint AS Point ) AS OutlookBarHeader  
		LOCAL i AS DWORD
		LOCAL nCount AS DWORD
		LOCAL oHeader AS OutlookbarHeader
	//
		nCount := ALen(SELF:_aHeaders)
		IF nCount != 0
			FOR i := 1 UPTO nCount
				oHeader := SELF:_aHeaders[i,2]
				IF oHeader:HitTest( oPoint )
					RETURN oHeader
				ENDIF
			NEXT
		ENDIF
	//
		RETURN NULL_OBJECT


	METHOD GetHeaderFromSymbol( symHeader AS SYMBOL ) AS OutlookBarHeader 
		LOCAL nPos AS DWORD
		LOCAL oHeader AS OutlookBarHeader
    //
		nPos := AScan( _aHeaders, {|aX| aX[1] = symHeader})
		IF nPos > 0
			oHeader := _aHeaders[nPos, 2]
		ENDIF
	//
		RETURN oHeader

	METHOD GetInsideRect(rc AS _winRect) AS LOGIC  
	//
		rc:top := SELF:_rcInside:top
		rc:left := SELF:_rcInside:left
		rc:bottom := SELF:_rcInside:bottom
		rc:right := SELF:_rcInside:right
	//
		RETURN TRUE


	METHOD GetItemFromPoint( oPoint AS Point ) AS  OutlookbarItem  
		LOCAL i 				AS INT
		LOCAL iFirstItem 	AS INT
		LOCAL iLastItem 	AS INT
		LOCAL oHeader 		AS OutlookBarHeader
		LOCAL oItem 		AS OutlookBarItem
	//
		IF (SELF:_symCurrentHeader != NULL_SYMBOL)
			oHeader := SELF:GetActiveHeader()
		//
			IF (oHeader != NULL_OBJECT) .AND. (oHeader:ItemCount > 0)
			//
				iFirstItem := oHeader:FirstVisibleItem
				iLastItem := oHeader:LastVisibleItem
			//
				IF (iLastItem >= iFirstItem )  
				//
					FOR i := iFirstItem UPTO iLastItem STEP 1   
					//
						oItem := oHeader:GetItem( DWORD(i) )
						IF oItem:HitTest( oPoint )
							RETURN oItem
						ENDIF
					NEXT // i
				ENDIF
			ENDIF
		ENDIF
	//
		RETURN NULL_OBJECT


	METHOD GetItemFromSymbol( symItem AS SYMBOL ) AS OutlookbarItem  
//p Retrieve an Outlookbar Item using it's Symbol Name, in the Active Header
//d If you search for an Item in another Header, you MUST first GetHeaderFromSymbol(),
//d then use the GetItemFromSymbol() method of the OutlookbarHeader class
		LOCAL i AS DWORD
		LOCAL nCount AS DWORD
		LOCAL oHeader AS OutlookbarHeader
		LOCAL oItem AS OutlookbarItem
	//
		oHeader := SELF:GetActiveHeader()
		IF oHeader != NULL_OBJECT
			nCount := oHeader:ItemCount
			IF nCount != 0
				FOR i := 1 UPTO nCount
					oItem := oHeader:GetItem( i )
					IF oItem:NameSym = symItem
						RETURN oItem
					ENDIF
				NEXT
			ENDIF
		ENDIF
	//
		RETURN NULL_OBJECT


	ACCESS HeaderHeight AS LONG  
//r Return the height of a header (in pixel)
		RETURN SELF:_nHeaderHeight


	ASSIGN HeaderHeight( nNewHeight AS LONG )   
//d Set the height of an header (in pixel)
	//
		IF nNewHeight >= 0
			SELF:_nHeaderHeight := nNewHeight
			SELF:Update()
		ENDIF
	//


	ACCESS HiliteBackgroundColor AS Color  
//r The Background Color
		RETURN SELF:_oBackgroundHilite


	ASSIGN HiliteBackgroundColor( oColor AS Color )   
//p Set the Background color
		SELF:_oBackgroundHilite := oColor


	ACCESS HorizontalItemSpace AS LONG   
		RETURN SELF:ImageWidth

	ACCESS ImageHeight AS LONG  
//r According to the ImageList, retrieve the height of each image
		LOCAL iX AS INT
		LOCAL iY AS INT
	//
		IF ( SELF:_oImageList != NULL_OBJECT )
		//
			ImageList_GetIconSize(SELF:_oImageList:Handle(), @iX, @iY)
		ENDIF
		RETURN iY

	ACCESS ImageList AS ImageList  
		RETURN SELF:_oImageList

	ASSIGN ImageList( oNewImageList AS ImageList )  
//l Zuweisen einer Bildliste, die von den Items verwendet wird
//p Bildliste festlegen, aus der die Items gezeichnet werden
//d Die Bilder für die Items werden in dieser Imagelist gehalten. Ein Bild für
//d ein einzelnes Item wird über dessen ImageIndex festglegt.
//d Die Grösse der Bilder kann relativ beliebig sein. Gedacht war eine Grösse von
//d 32x32 Pixel (was anderes habe ich auch nicht ausprobiert).
	//
		SELF:_oImageList := oNewImageList
		SELF:Update()
	//
		RETURN 


	ACCESS ImageWidth AS LONG  
//r According to the ImageList, retrieve the width of each image
		LOCAL iX AS INT
		LOCAL iY AS INT
	//
		IF ( SELF:_oImageList != NULL_OBJECT )
		//
			ImageList_GetIconSize(SELF:_oImageList:Handle(), @iX, @iY)
		ENDIF
		RETURN iX

	CONSTRUCTOR(oOwner, nID, oPoint, oDimension) 

		SUPER(oOwner, nID, oPoint, oDimension, 0, FALSE)

		SELF:_aHeaders := {}

	// default background ( For #FABSTYLE )
		SELF:_oBackGroundHilite := __RGB2Color( GetSysColor( COLOR_3DFACE ) )
	// Default values
		SELF:_nHeaderHeight := 22	// height of a header
		SELF:_nItemTopSpace := 5	// space between header and the first visible item
		SELF:_nLabelSpacing := 3	// space between item an its text
		SELF:_nItemSpacing := 6		// space between items (bottom of text to next item top)
	//
		SELF:BarStyle := #STDSTYLE
	//
		RETURN		 

	METHOD InsertHeader( oOLHeader AS OutlookBarHeader, symBeforeHeader AS SYMBOL ) AS LOGIC  
		LOCAL nPos AS DWORD
		LOCAL nCount AS DWORD
	//
		oOLHeader:__OutlookBar := SELF
	//
		nCount := ALen(_aHeaders)
		IF ( nCount == 0 )
			nPos := 0
		ELSE
			nPos := AScan( SELF:_aHeaders, {|aX| aX[1] = symBeforeHeader})
		ENDIF
	//
		IF ( nPos > 0 )
			ASize( _aHeaders, nCount+1)
			AIns( _aHeaders, nPos)
			SELF:_aHeaders[nPos] := {oOLHeader:NameSym, oOLHeader }
		ELSE
			AAdd( SELF:_aHeaders, { oOLHeader:NameSym, oOLHeader })
		ENDIF
	//
		IF ( oOLHeader:ImageIndex > 0 )
			IF ( SELF:_oSmlImgList != NULL_OBJECT )
				IF ( SELF:HeaderHeight < (SELF:SmallImageHeight+4) )
					SELF:HeaderHeight := SELF:SmallImageHeight + 4
				ENDIF
			ELSE
				IF ( SELF:HeaderHeight < (SELF:ImageHeight+4) )
					SELF:HeaderHeight := SELF:ImageHeight + 4
				ENDIF
			ENDIF
		ENDIF
	//
		RETURN TRUE


	ACCESS IsItemsBoxed AS LOGIC  
//d Only for #NEWSTYLE, indicate if a box is drawn around Items
		RETURN SELF:_lDrawBox

	ASSIGN IsItemsBoxed( lNew AS LOGIC )   
//d Only for #NEWSTYLE, indicate if a box is drawn around Items
		SELF:_lDrawBox := lNew
	// Force Redraw
		SELF:Update()
		RETURN		 

	ACCESS ItemsBackgroundColor AS Color  
//d Only for #NEWSTYLE, Items can have a different background than the bar
		RETURN SELF:_oItemsBackground


	ASSIGN ItemsBackgroundColor( oColor AS Color )   
//d Only for #NEWSTYLE, Items can have a different background than the bar
		SELF:_oItemsBackground := oColor
	// need to repaint to update the screen
		SELF:Update()

	ACCESS ItemSpacing AS LONG  
//r Get the number of pixel between each Item in the bar
		RETURN SELF:_nItemSpacing

	ASSIGN ItemSpacing( nNewSpacing AS LONG )   
//d Set the number of pixel between each Item in the bar 
		SELF:_nItemSpacing := nNewSpacing
		SELF:Update()

	ACCESS ItemTopSpace AS LONG  
		RETURN SELF:_nItemTopSpace

	ASSIGN ItemTopSpace( nNewSpacing AS LONG )   
		SELF:_nItemTopSpace := nNewSpacing
		SELF:Update()

	ACCESS LabelSpacing AS LONG  
	//
		RETURN SELF:_nLabelSpacing


	METHOD MouseButtonDown( oME ) 
// Internal method : Called when a Mouse Button is down
		LOCAL oHeader AS OutlookBarHeader
		LOCAL oItem AS OutlookBarItem
		LOCAL oPoint AS point
	//
		SUPER:MouseButtonDown( oME )
	//
		IF oME:IsLeftButton .AND. !(oME:IsShiftButton .OR. oME:IsControlButton)
		//
			oPoint := __WCConvertPoint(SELF, oME:Position)
			oHeader := SELF:GetHeaderFromPoint( oPoint )
		//
			IF oHeader != NULL_OBJECT .AND. oHeader:IsEnabled
			//
				SELF:MouseTrapOn()
				SELF:_symTrappingHeader := oHeader:NameSym
				oHeader:Press(TRUE)
			//
			ELSE
			//
				oHeader := SELF:GetActiveHeader()
			//
				IF oHeader != NULL_OBJECT .AND. oHeader:IsEnabled
				//
					IF oHeader:IsUpArrow .AND. oHeader:UpArrow:HitTest( oPoint )
					//
						SELF:MouseTrapOn()
						SELF:_symTrappingArrow := #_UP
						oHeader:UpArrow:Press( TRUE )
					//
					ELSEIF oHeader:IsDownArrow .AND. oHeader:DownArrow:HitTest( oPoint )
					//
						SELF:MouseTrapOn()
						SELF:_symTrappingArrow := #_DOWN
						oHeader:DownArrow:Press( TRUE )
					//
					ELSE
					//
						oItem := SELF:GetItemFromPoint( oPoint )
						IF oItem != NULL_OBJECT .AND. oItem:IsEnabled
						//
							SELF:MouseTrapOn()
							SELF:_symTrappingItem := oItem:NameSym
							oItem:Press(TRUE)
						//
						ENDIF
					ENDIF
				ENDIF
			ENDIF
		ENDIF
		RETURN		 SELF

	METHOD MouseButtonUp( oME ) 
		LOCAL oHeader AS OutlookBarHeader
		LOCAL oItem AS OutlookBarItem
		LOCAL oArrow AS OutlookBarArrow
		LOCAL oPoint AS point
		LOCAL lHeaderChanged AS LOGIC
		LOCAL lItemClicked AS LOGIC
		LOCAL lItemChanged AS LOGIC
		LOCAL lScroll AS LOGIC
		LOCAL symDirection AS SYMBOL
	//
		lHeaderChanged := FALSE
		lItemClicked := FALSE
		lItemChanged := FALSE
		lScroll := FALSE
	//
		SUPER:MouseButtonUp( oME )
	//
		IF !oME:IsLeftButton
			RETURN SELF
		ENDIF
	//
		SELF:MouseTrapOff()
	// "unpress" the current pressed element
		IF SELF:_symTrappingHeader != NULL_SYMBOL
		//
			oHeader := SELF:GetHeaderFromSymbol(SELF:_symTrappingHeader)
			IF oHeader != NULL_OBJECT
				IF ( SELF:_nHeaderHeight != 0 )
					oHeader:Press(FALSE)
				ENDIF
			ENDIF
		ELSEIF SELF:_symTrappingItem != NULL_SYMBOL
		//
			oItem := SELF:GetActiveHeader():GetItemFromSymbol(SELF:_symTrappingItem)
			IF oItem != NULL_OBJECT
				oItem:Press(FALSE)
			ENDIF
		ELSEIF SELF:_symTrappingArrow != NULL_SYMBOL
		//
			oHeader := SELF:GetActiveHeader()
			IF SELF:_symTrappingArrow = #_UP
				oArrow := oHeader:UpArrow
				oArrow:Press(FALSE)
			ELSEIF SELF:_symTrappingArrow = #_DOWN
				oArrow := oHeader:DownArrow
				oArrow:Press(FALSE)
			ENDIF
		ENDIF
	//
		oPoint := __WCConvertPoint(SELF, oME:Position)
	//
		oHeader := SELF:GetHeaderFromPoint( oPoint )
	//
		IF oHeader != NULL_OBJECT .AND. oHeader:IsEnabled
		//
			IF oHeader:NameSym = SELF:_symTrappingHeader
			//
				IF SELF:_symCurrentHeader != oHeader:NameSym
					SELF:_symCurrentHeader := oHeader:NameSym
					SELF:Update()
					lHeaderChanged := TRUE
				ENDIF
			ENDIF
		ELSEIF oArrow != NULL_OBJECT
		//
			IF oArrow:HitTest( oPoint )
				lScroll := TRUE
				symDirection := oArrow:NameSym
			ENDIF
		ELSE
		//
			oItem := SELF:GetItemFromPoint( oPoint )
		//
			IF oItem != NULL_OBJECT .AND. oItem:IsEnabled
				IF oItem:NameSym = SELF:_symTrappingItem
				//
					lItemClicked := TRUE
					IF oItem:NameSym != SELF:_symActiveItem
					//
						lItemChanged := TRUE
						SELF:_symActiveItem := oItem:NameSym
					ENDIF
				ENDIF
			ENDIF
		ENDIF
	//
		SELF:_symTrappingHeader := NULL_SYMBOL
		SELF:_symTrappingItem := NULL_SYMBOL
		SELF:_symTrappingArrow := NULL_SYMBOL
	//
		IF lHeaderChanged
			IF IsMethod( SELF:oParent, #OLBHeaderChanged)
				oParent:OLBHeaderChanged(oHeader)
			ENDIF
		ENDIF
	//
		IF lItemClicked
			IF IsMethod( SELF:oParent, #OLBItemClicked)
				oParent:OLBItemClicked(oItem)
			ENDIF
		ENDIF
	//
		IF lItemChanged
			IF IsMethod( SELF:oParent, #OLBItemChanged)
				oParent:OLBItemChanged(oItem)
			ENDIF
		ENDIF
	//
		IF lScroll
			IF symDirection = #_UP
				SELF:ScrollUp()
			ELSEIF symDirection = #_DOWN
				SELF:ScrollDown()
			ENDIF
		ENDIF
	//
		RETURN		 SELF

	METHOD MouseDrag( oME ) 
		LOCAL oPoint AS Point
		LOCAL oHeader AS OutlookBarHeader
		LOCAL oItem AS OutlookBarItem
		LOCAL oTrappingHeader AS OutlookBarHeader
		LOCAL oTrappingItem AS OutlookBarItem
		LOCAL oTrappingArrow AS OutlookBarArrow
	//
		SUPER:MouseDrag( oME )
	//
		IF SELF:_symTrappingHeader != NULL_SYMBOL
		//
			oTrappingHeader := SELF:GetHeaderFromSymbol( SELF:_symTrappingHeader )
			oPoint := __WCConvertPoint(SELF, oME:Position)
			oHeader := SELF:GetHeaderFromPoint( oPoint )
			IF oHeader != NULL_OBJECT .AND. oHeader:IsEnabled
				IF oHeader:NameSym = SELF:_symTrappingHeader
					oTrappingHeader:Press(TRUE)
				ELSE
					oTrappingHeader:Press(FALSE)
				ENDIF
			ELSE
				oTrappingHeader:Press(FALSE)
			ENDIF
		ELSEIF SELF:_symTrappingItem != NULL_SYMBOL
		//
			oTrappingItem := SELF:GetActiveHeader():GetItemFromSymbol( SELF:_symTrappingItem )
			oPoint := __WCConvertPoint(SELF, oME:Position)
			oItem := SELF:GetItemFromPoint( oPoint )
			IF oItem != NULL_OBJECT .AND. oItem:IsEnabled
				IF oItem:NameSym = SELF:_symTrappingItem
					oTrappingItem:Press(TRUE)
				ELSE
					oTrappingItem:Press(FALSE)
				ENDIF
			ELSE
				oTrappingItem:Press(FALSE)
			ENDIF
		ELSEIF SELF:_symTrappingArrow != NULL_SYMBOL
		//
			oHeader := SELF:GetActiveHeader()
			IF oHeader != NULL_OBJECT
				IF SELF:_symTrappingArrow = #_UP
					oTrappingArrow := oHeader:UpArrow
				ELSEIF SELF:_symTrappingArrow = #_DOWN
					oTrappingArrow := oHeader:DownArrow
				ENDIF
				IF oTrappingArrow != NULL_OBJECT
					oPoint := __WCConvertPoint(SELF, oME:Position)
					IF oTrappingArrow:HitTest( oPoint )
						oTrappingArrow:Press( TRUE )
					ELSE
						oTrappingArrow:Press( FALSE )
					ENDIF
				ENDIF
			ELSE
			//
				SELF:_symTrappingArrow := NULL_SYMBOL
			ENDIF
		ENDIF
		RETURN		 SELF

	METHOD MouseMove( oME ) 
		LOCAL oPoint AS Point
		LOCAL oItem AS OutlookBarItem
		LOCAL oOldItem AS OutlookBarItem
		LOCAL oHeader AS OutlookBarHeader
		LOCAL hDC AS PTR
	//
		SUPER:MouseMove( oME )
	//
		oPoint := __WCConvertPoint(SELF, oME:Position)
	// check if a header was hit
		oHeader := SELF:GetHeaderFromPoint( oPoint )
	// only check for items if no header was hit
		IF ( oHeader == NULL_OBJECT )
			oItem := SELF:GetItemFromPoint( oPoint )
		ENDIF
	// if no item was hit, unhilite the last hilited (if so)
		IF ( oItem == NULL_OBJECT )
			IF SELF:_symHiLitedItem != NULL_SYMBOL
				oOldItem := SELF:GetItemFromSymbol( SELF:_symHiLitedItem )
				hDC := GetDC( SELF:Handle() )
				oOldItem:HiLite( hDC, FALSE)
				ReleaseDC( SELF:Handle(), hDC )
				SELF:_symHiLitedItem := NULL_SYMBOL
			ENDIF
		ELSE	// a item was hit
			IF SELF:_symHiLitedItem != NULL_SYMBOL
				IF SELF:_symHiLitedItem != oItem:NameSym
					oOldItem := SELF:GetItemFromSymbol( SELF:_symHiLitedItem )
					hDC := GetDC( SELF:Handle() )
					oOldItem:HiLite( hDC, FALSE)
					oItem:HiLite( hDC, TRUE)
					ReleaseDC( SELF:Handle(), hDC )
					SELF:_symHiLitedItem := oItem:NameSym
				ENDIF
			ELSE
				hDC := GetDC( SELF:Handle() )
				oItem:HiLite( hDC, TRUE)
				ReleaseDC( SELF:Handle(), hDC )
				SELF:_symHiLitedItem := oItem:NameSym
			ENDIF
		ENDIF

		RETURN		 SELF		

	METHOD MouseTrapOff() AS VOID  
	//
		ReleaseCapture()
		RETURN		 

	METHOD MouseTrapOn() AS VOID  
	//
		SetCapture(SELF:Handle(0))

		RETURN		 

	METHOD Recalc() AS VOID  
		LOCAL nCount AS DWORD
		LOCAL i AS DWORD
		LOCAL oCurHeader AS OutlookBarHeader
		LOCAL lActiveFound AS LOGIC
		LOCAL iStartOffset AS INT
		LOCAL rcClient IS _winRect
	//
		nCount := ALen(_aHeaders)
		IF ( nCount == 0 )
			RETURN
		ENDIF
	//
		GetClientRect( SELF:Handle(), @rcClient )
	//
		lActiveFound := FALSE
		iStartOffset := 0
		FOR i := 1 UPTO nCount
		//
			oCurHeader := SELF:_aHeaders[i,2]
			IF lActiveFound
				iStartOffset := rcClient:Bottom - (LONG(nCount+1 - i)* SELF:_nHeaderHeight)
			ELSE
				iStartOffset := LONG(i-1) * SELF:_nHeaderHeight
			ENDIF
		//
			oCurHeader:Area:SetRect( 0, iStartOffset, rcClient:right-1, iStartOffset+SELF:_nHeaderHeight-1 )
		//
			IF (oCurHeader:NameSym == SELF:_symCurrentHeader)
				lActiveFound := TRUE
				SELF:_nYBottomHeaderStart := rcClient:Bottom - (LONG(nCount - i)*SELF:_nHeaderHeight)
				SELF:_rcInside:left := rcClient:left
				SELF:_rcInside:top := iStartOffset + SELF:_nHeaderHeight
				SELF:_rcInside:bottom := SELF:_nYBottomHeaderStart - 1
				SELF:_rcInside:right := rcClient:right-1
				SELF:RecalcItems()
				SELF:RecalcArrows()
			ENDIF
		NEXT
	//

		RETURN		 

	METHOD RecalcArrows() AS VOID  
//p calculate the size and position of the scrollbuttons
		LOCAL oHeader AS OutlookBarHeader
		LOCAL rect IS _winRect
		LOCAL iWidth AS INT
		LOCAL iHeight AS INT
		LOCAL dX AS INT
		LOCAL dY AS INT
	//
		oHeader := SELF:GetActiveHeader()
		IF oHeader != NULL_OBJECT
			iWidth := GetSystemMetrics( SM_CXVSCROLL )
			iHeight := GetSystemMetrics( SM_CYVSCROLL )
		// check if there is a scroll button needed
			IF oHeader:IsUpArrow
				SELF:GetInsideRect( @rect )
				rect:bottom := rect:top + iHeight
				rect:right := rect:left + iWidth

				dX := SELF:_rcInside:right - SELF:_rcInside:left - iWidth - 5
				dY := 5
				OffsetRect( @rect, dX, dY )
			ELSE
				SetRectEmpty( @rect )
			ENDIF
			oHeader:SetUpArrowPos( @rect )
		// check if there is a scroll button needed
			IF oHeader:IsDownArrow
				SELF:GetInsideRect( @rect )
				rect:bottom := rect:top + iHeight
				rect:right := rect:left + iWidth

				dX := SELF:_rcInside:right - SELF:_rcInside:left - iWidth - 5
				dY := SELF:_rcInside:bottom - SELF:_rcInside:top - iHeight - 5
				OffsetRect( @rect, dX, dY )
			ELSE
				SetRectEmpty( @rect )
			ENDIF
			oHeader:SetDownArrowPos( @rect )
		ENDIF
		RETURN		 

	METHOD RecalcItems() AS VOID  
//p Calculate the Position for all visible Items of the Active Header
		LOCAL rc IS _winRect
		LOCAL rcLabel IS _winRect
		LOCAL nCount AS DWORD
		LOCAL i AS DWORD
		//LOCAL oPoint AS Point
		LOCAL oArea AS WRect
		LOCAL nX AS LONGINT
		LOCAL yStart AS LONGINT
		LOCAL nYItemOffset AS INT
		LOCAL oHeader AS OutlookbarHeader
		LOCAL oItem AS OutlookBarItem
		LOCAL iFirstItem AS INT
		LOCAL hDC AS PTR
		LOCAL hFont AS PTR
		LOCAL hOldFont AS PTR
	//	
		oHeader := SELF:GetActiveHeader()
		IF oHeader != NULL_OBJECT .AND. oHeader:FirstVisibleItem > 0
			iFirstItem := oHeader:FirstVisibleItem
			rc := SELF:_rcInside
		//
			nCount := oHeader:ItemCount
		// vertical size of the bitmap and the space between items
			nYItemOffset := SELF:ImageHeight + SELF:_nItemSpacing
		// horizontal position of the left side of the bitmap
			IF ( SELF:_symStyle == #NEWSTYLE ) 
			//    Items are on the left 
				nX := 5	
			// vertical positon of the first visible item (top side)
				yStart := rc:top + SELF:_nItemTopSpace
			ELSE
			//( self:_symStyle == #FABSTYLE ) .or. ( self:_symStyle == #STDSTYLE ) )			
			//    Items are always centered in the bar
				nX := Integer((rc:right - rc:left - SELF:HorizontalItemSpace) / 2)	
			// vertical positon of the first visible item (top side)
				yStart := rc:top + SELF:_nItemTopSpace
			ENDIF
		//
			hDC := GetDC( SELF:Handle() )
			hFont := GetStockObject( ANSI_VAR_FONT )
			hOldFont := SelectObject( hDC, hFont )
		//
			FOR i := DWORD(iFirstItem) UPTO nCount STEP 1
			//
				oItem := oHeader:GetItem( i )
				//oPoint := Point{nX, yStart}
				oArea := WRect{} // BoundingBox{oPoint, oDim}
				IF ( SELF:_symStyle == #NEWSTYLE ) 
				//    Items are on the left, for the full Width 
					oArea:SetRect( nX, yStart, rc:right - 5, yStart + SELF:ImageHeight )
				ELSE
				//( self:_symStyle == #FABSTYLE ) .or. ( self:_symStyle == #STDSTYLE ) )			
					oArea:SetRect( nX, yStart, nX+SELF:ImageWidth, yStart + SELF:ImageHeight )
				ENDIF
				oItem:Area := oArea
			// if the item has a describing text, calculate the size and add the height to yStart
				IF !Empty(oItem:Caption)
					IF ( SELF:_symStyle == #NEWSTYLE ) 
/*					CopyRect( @rcLabel, @rc)
					// move the label rect to the desired position
					OffsetRect( @rcLabel, 0, yStart - rc.top + self:ImageHeight + self:_nLabelSpacing )
					// clear the height of the rect to let DrawText calculate
					rcLabel.bottom := rcLabel.top
					DrawText( hDC, String2Psz(oItem:Caption), -1, @rcLabel, DT_CENTER + DT_WORDBREAK + DT_CALCRECT )
					// if there ist only one line of text, DrawText changes the width of the rect
					OffsetRect( @rcLabel, Integer((rc.right - rcLabel.Right)/2), 0)
					oArea := WRect{} // BoundingBox{ oPoint, oSize } */
						oArea := oItem:Area:Clone()
						oArea:left := SELF:ImageWidth + 15 
						oItem:LabelArea := oArea:BoundingBox
						yStart += SELF:_nLabelSpacing // + oArea:Height	
					ELSE 
						CopyRect( @rcLabel, @rc)
					// move the label rect to the desired position
						OffsetRect( @rcLabel, 0, yStart - rc:top + SELF:ImageHeight + SELF:_nLabelSpacing )
					// clear the height of the rect to let DrawText calculate
						rcLabel:bottom := rcLabel:top
						DrawText( hDC, String2Psz(oItem:Caption), -1, @rcLabel, DT_CENTER + DT_WORDBREAK + DT_CALCRECT )
					// if there ist only one line of text, DrawText changes the width of the rect
						OffsetRect( @rcLabel, Integer((rc:right - rcLabel:Right)/2), 0)
						oArea := WRect{} // BoundingBox{ oPoint, oSize }
						oArea:SetRectWin( @rcLabel )
						oItem:LabelArea := oArea:BoundingBox
					// add the space and the height of the text to the next startposition
						yStart += SELF:_nLabelSpacing + (rcLabel:bottom - rcLabel:top)					
					ENDIF					
				ENDIF
			//
				yStart += nYItemOffset
				oHeader:LastVisibleItem := LONG(i)
			// if the start position of the next item is outside the visible area, don´t continue
				IF (yStart > rc:Bottom)
					EXIT
				ENDIF
			NEXT
		//
			SelectObject( hDC, hOldFont )
			ReleaseDC( SELF:Handle(), hDC )
		// use yStart to get the lower edge of the last item
			yStart -= SELF:_nItemSpacing
		// check if we need a button to scroll down
			IF (oHeader:LastVisibleItem < LONG(nCount) )
				oHeader:IsDownArrow := TRUE
			ELSEIF ( (oHeader:LastVisibleItem == LONG(nCount)) .AND. (yStart > rc:Bottom) )
				oHeader:IsDownArrow := TRUE
			ELSE
				oHeader:IsDownArrow := FALSE
			ENDIF
		// check if we need a button to scroll up
			IF (oHeader:FirstVisibleItem > 1)
				oHeader:IsUpArrow := TRUE
			ELSE
				oHeader:IsUpArrow := FALSE
			ENDIF
		ENDIF

		RETURN		 

	METHOD ScrollDown() AS LOGIC  
		LOCAL oHeader AS OutlookBarHeader
		LOCAL rcInside IS _winRect
	//
		oHeader := SELF:GetActiveHeader()
		IF !oHeader = NULL_OBJECT
			IF oHeader:ScrollDown()
				SELF:GetInsideRect(@rcInside)
				SELF:RecalcItems()
				SELF:RecalcArrows()
				SELF:Update()
			//InvalidateRect( SELF:Handle(), @rcInside, FALSE )
				RETURN TRUE
			ENDIF
		ENDIF
		RETURN FALSE


	METHOD ScrollUp() AS LOGIC  
		LOCAL oHeader AS OutlookBarHeader
		LOCAL rcInside IS _winRect
	//
		oHeader := SELF:GetActiveHeader()
		IF !oHeader = NULL_OBJECT
			IF oHeader:ScrollUp()
				SELF:GetInsideRect(@rcInside)
				SELF:RecalcItems()
				SELF:RecalcArrows()
				SELF:Update()
			//InvalidateRect( SELF:Handle(), @rcInside, FALSE )
				RETURN TRUE
			ENDIF
		ENDIF
		RETURN FALSE


	METHOD SetItemCaption( symItem AS SYMBOL, cNewCaption AS STRING ) AS VOID  
		LOCAL i AS DWORD
		LOCAL dwHeaderCount AS DWORD
		LOCAL oHeader AS OutlookBarHeader
		LOCAL oItem AS OutlookBarItem
	//
		dwHeaderCount := ALen(SELF:_aHeaders)
		FOR i := 1 UPTO dwHeaderCount
			oHeader := SELF:_aHeaders[i,2]
			oItem := oHeader:GetItemFromSymbol( symItem )
			IF !(oItem = NULL_OBJECT)
				EXIT
			ENDIF
		NEXT
	//
		IF !(oItem = NULL_OBJECT)
			oItem:Caption := cNewCaption
			SELF:Update()
		ENDIF

		RETURN		 

	ACCESS SmallImageHeight AS LONG  
		LOCAL iX AS INT
		LOCAL iY AS INT
	//
		IF ( SELF:_oSmlImgList != NULL_OBJECT )
		//
			ImageList_GetIconSize(SELF:_oSmlImgList:Handle(), @iX, @iY)
		ENDIF
		RETURN iY

	ACCESS SmallImageList AS ImageList  
//p The ImageList used for Headers. If NULL, then the standard ImageList is used
		RETURN SELF:_oSmlImgList

	ASSIGN SmallImageList( oNewImageList AS ImageList )  
//p The SmallImageList used for Headers. If NULL, then the standard ImageList is used
	//
		SELF:_oSmlImgList := oNewImageList
		SELF:Update()
	//


	ACCESS SmallImageWidth AS LONG  
		LOCAL iX AS INT
		LOCAL iY AS INT
	//
		IF ( SELF:_oSmlImgList != NULL_OBJECT )
		//
			ImageList_GetIconSize(SELF:_oSmlImgList:Handle(), @iX, @iY)
		ENDIF
		RETURN iX

	ACCESS BarStyle AS SYMBOL  
		RETURN SELF:_symStyle

	ASSIGN BarStyle( sNew AS SYMBOL )   
		LOCAL nCount AS DWORD
		LOCAL i AS DWORD
		LOCAL oHeader AS OutlookBarHeader
		LOCAL r,g,b AS DWORD
	//
		IF ( sNew == #STDSTYLE ) .OR. ( sNew == #FABSTYLE ) .OR. ( sNew == #NEWSTYLE )
			SELF:_symStyle := sNew
			DO CASE
				CASE SELF:_symStyle == #STDSTYLE
					SELF:_oBackGround := Color{127, 127, 127}
				CASE SELF:_symStyle == #FABSTYLE
					SELF:_oBackGround := __RGB2Color( GetSysColor( COLOR_3DFACE ) )
					SELF:_oBackGroundHilite := __RGB2Color( GetSysColor( COLOR_3DFACE ) )
				CASE SELF:_symStyle == #NEWSTYLE
			// Check for Theme
					IF IsThemeEnabled()
						SELF:_oItemsBackground := Color{}
						SELF:_oItemsBackground:ColorRef := GetSysColor( COLOR_MENUHILIGHT ) //COLOR_ACTIVECAPTION,COLOR_HIGHLIGHT 
				// Now, try to lighten color : Increase by 10%
						r := IIF( SELF:_oItemsBackground:Red==0, 20, SELF:_oItemsBackground:Red + SELF:_oItemsBackground:Red*2/10 )
						g := IIF( SELF:_oItemsBackground:Green==0, 20, SELF:_oItemsBackground:Green + SELF:_oItemsBackground:Green*2/10 )
						b := IIF( SELF:_oItemsBackground:Blue==0, 20, SELF:_oItemsBackground:Blue + SELF:_oItemsBackground:Blue*2/10 )
						SELF:_oItemsBackground:Red   := IIF( r > 255,255,r )  
						SELF:_oItemsBackground:Green := IIF( g > 255,255,g ) 
						SELF:_oItemsBackground:Blue  := IIF( b > 255,255,b ) 
					ELSE
				// Default
				// Blue
						SELF:_oItemsBackground := Color{125, 165, 224}
					ENDIF
			// Per default, Background of the bar is the same as the Item's
					SELF:_oBackGround := SELF:_oItemsBackground
			// Light Orange
					SELF:_oBackGroundHilite := Color{238, 149, 21}   
			// 247,194,95
			// Set the GradientColor for each Headers
			// Set the GradientColor for each Items in each Header
					nCount := ALen(_aHeaders)
					FOR i := 1 UPTO nCount
						oHeader := _aHeaders[i,2]
				// Orange
						oHeader:GradientColor := Color{247,194,95}
				// WHite
						oHeader:__ItemsGradientColor( Color{ 255,255,255 } )
					NEXT
			// Like Outlook, no space between buttons
					SELF:ItemSpacing := 0
			// And Draw Boxes
					SELF:IsItemsBoxed := TRUE
			ENDCASE
		//
			SELF:Update()
		//
		ENDIF

	METHOD Timer( ) CLIPPER
		// Change in Theme ?       
		// Force redraw for #NEWSTYLE
		SELF:BarStyle := SELF:BarStyle
		RETURN		 NIL 

	METHOD Update() AS VOID  
	//
		InvalidateRect( SELF:Handle(), NULL, FALSE )
	//UpdateWindow( SELF:Handle() )
		RETURN		 

	ACCESS VerticalItemSpace AS LONG  
	//
		RETURN SELF:ImageHeight + SELF:_nItemSpacing


		END CLASS

FUNCTION __RGB2Color( nRGB AS DWORD ) AS Color STRICT
	LOCAL hiWord	AS	WORD
	LOCAL loWord	AS	WORD
	LOCAL oColor	AS	Color
	//
	hiWord := HiWord( nRGB )
	loWord := LoWord( nRGB )
	//
	oColor := Color{ LoByte( loWord ), HiByte( loWord ), LoByte( HiWord ) }
	//
	RETURN oColor

