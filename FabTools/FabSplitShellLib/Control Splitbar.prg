CLASS FabHorzSplitbar INHERIT FabSplitBar
	EXPORT Position AS SYMBOL
	
	
	
	METHOD __InvertRect( nMove ) 
		LOCAL rc	IS	_winRect
		LOCAL hDC	AS	PTR
		LOCAL hBrush	AS	PTR
		//
		IF IsNil( nMove )
			nMove := 0
		ENDIF
		//
		GetClientRect( SELF:Handle(), @rc )
		//
		rc:Top := rc:Top + nMove
		rc:Bottom := rc:Bottom + nMove
		//
		MapWindowPoints( SELF:Handle(), GetParent( SELF:Handle() ), (_winPOINT PTR)@rc, 2 )
		hDC := GetDC( GetParent(SELF:Handle()) )
		hBrush := GetStockObject( DKGRAY_BRUSH )
		SelectObject( hDC, hBrush )
		PatBlt( hDC, rc:left, rc:top, rc:right - rc:left, rc:bottom - rc:top, PATINVERT)
		ReleaseDC( GetParent(SELF:Handle()), hDC )
		//
		return self
		
		
	METHOD Expose( oEvent ) 
		LOCAL rc	IS _WINrect
		//
		SUPER:Expose( oEvent )
		GetClientRect( SELF:Handle(), @rc )
		//
		SELF:__Draw3DBoxRaised( rc:left, rc:top, rc:right, rc:bottom )
		//
		RETURN self
		
	CONSTRUCTOR( oOwner, xID, oPoint, oDimension, kStyle ) 
		//
		SUPER(oOwner, xID, oPoint, oDimension, kStyle )
		//
		oDimension := SELF:Size
		SELF:Size := Dimension{ oDimension:Width, GetSystemMetrics( SM_CXDLGFRAME ) + 2 }
		//
		SELF:Pointer := FABHSPLITBARCURSOR{}
		SELF:Position := #UNKNOWN
		//
		RETURN 
		
	METHOD MouseButtonDown( oEvent ) 
		//	
		IF oEvent:IsLeftButton
			// Capture all Mouse message
			SELF:CaptureMouse()
			//
			SELF:lInDrag := TRUE
			// As this can be a negative value.... ( But this SHOULD NOT happen here )
			SELF:nStart := SHORT(_CAST,HiWord( oEvent:lParam ))
			SELF:nPrevMove := 0
			SELF:__InvertRect()		
			//
		ENDIF
		RETURN SUPER:MouseButtonDown( oEvent )
		
	METHOD MouseButtonUp( oEvent ) 
		LOCAL nMove	AS	LONG
		//	
		IF ( oEvent:IsLeftButton ) .AND. SELF:lInDrag
			//
			SELF:ReleaseMouse()
			SELF:lInDrag := FALSE
			SELF:__InvertRect( SELF:nPrevMove )
			nMove := SHORT(_CAST,HiWord( oEvent:lParam )) + SELF:nStart
			SELF:nPrevMove := 0
			IF IsMethod( SELF:Owner, #OnHorzSplitbarMove )
				Send( SELF:Owner, #OnHorzSplitbarMove, nMove )
			ENDIF
			//
		ENDIF
		RETURN SUPER:MouseButtonUp( oEvent )
		
	METHOD MouseDrag( oEvent )
		LOCAL nMove	AS	LONG
		//	
		IF ( oEvent:IsLeftButton ) .AND. SELF:lInDrag
			SELF:__InvertRect( SELF:nPrevMove )
			nMove := SHORT(_CAST,HiWord( oEvent:lParam )) + SELF:nStart
			SELF:__InvertRect( nMove )
			SELF:nPrevMove := nMove
		ENDIF
		//	
		RETURN SUPER:MouseDrag( oEvent )
		
	METHOD UpdatePosition() 
		LOCAL rc	IS	_winrect
		LOCAL Height	AS	LONG
		//
		GetClientRect( GetParent(SELF:Handle()), @rc )
		Height := SELF:Size:Height
		//
		IF ( SELF:Position == #TOP )
			SetWindowPos( SELF:Handle(), NULL, 0, 0, rc:right-rc:left, Height, SWP_NOACTIVATE + SWP_NOZORDER )
		ELSEIF ( SELF:Position == #BOTTOM )
			SetWindowPos( SELF:Handle(), NULL, rc:left, rc:bottom-height, rc:right - rc:left, Height, SWP_NOACTIVATE + SWP_NOZORDER )
		ENDIF
		//
		
		return self
		
END CLASS

CLASS FABHSPLITBARCURSOR INHERIT Pointer
	
	CONSTRUCTOR() 
		super(ResourceID{"FABHSPLITBARCURSOR", _GetInst()})
		return 
END CLASS

CLASS FabSplitBar INHERIT CustomControl
	//
	PROTECT	oPointer	AS	Pointer
	//
	PROTECT	lInDrag		AS	LOGIC
	PROTECT nStart		AS	LONG
	PROTECT nPrevMove	AS	LONG
	
	
	PROTECT METHOD __Draw3DBoxRaised( nLeft, nTop, nRight, nBottom ) 	
		LOCAL hGray		AS	PTR
		LOCAL hOldPen	AS	PTR
		LOCAL hLtGrayBrush 	AS 	PTR
		LOCAL Rect 		IS _WinRect
		LOCAL hDC		AS	PTR
		//
		Rect:Top := nTop
		Rect:Left := nLeft
		Rect:Bottom := nBottom + 1
		Rect:Right := nRight + 1
		//
		hDC := GetDC( SELF:Handle() )
		//
		hLtGrayBrush := CreateSolidBrush( GetSysColor( COLOR_3DFACE ) )
		//
		FillRect( hDC,@Rect,hLtGrayBrush )
		//
		hGray := CreatePen(PS_SOLID,1,dword(RGB(128,128,128)))
		//
		hOldPen := SelectObject(hDC, GetStockObject(WHITE_PEN))
		MoveToEx( hDC, nLeft, nBottom, NULL_PTR )
		LineTo( hDC, nLeft, nTop)
		LineTo( hDC, nRight, nTop)
		//
		SelectObject(hDC, GetStockObject(BLACK_PEN))
		MoveToEx( hDC, nLeft, nBottom, NULL_PTR )
		LineTo( hDC, nRight, nBottom)
		LineTo( hDC, nRight, nTop-1)
		//
		SelectObject( hDC, hGray )
		MoveToEx( hDC, nLeft+1, nBottom-1, NULL_PTR )
		LineTo( hDC, nRight-1, nBottom-1)
		LineTo( hDC, nRight-1, nTop )
		//
		SelectObject( hDC, hOldPen )
		//
		DeleteObject( hLtGrayBrush )
		DeleteObject( hGray )	
		//
		ReleaseDC( SELF:Handle(), hDC )
		return self
		
	METHOD CaptureMouse( ) 
		//
		SetCapture( SELF:Handle() )
		//
		return self
		
	METHOD Dispatch( oEvent ) 
		//
		IF ( oEvent:Message == WM_SETCURSOR )
			IF ( SELF:oPointer != NULL_OBJECT ) .and. ;
					( LoWord( oEvent:lParam) == HTClient ) .and. ;
					( SELF:Handle() == PTR(_CAST,oEvent:wParam) )
				//
				SetCursor( SELF:oPointer:Handle() )
				//
				SELF:EventReturnValue := 1
				RETURN 1
			ENDIF	
		ENDIF
		//
		RETURN SUPER:Dispatch( oEvent )
		
	METHOD Expose( oEvent ) 
		LOCAL rc	IS _WINrect
		//
		GetClientRect( SELF:Handle(), @rc )
		//
		SELF:__Draw3DBoxRaised( rc:left, rc:top, rc:right, rc:bottom )
		//
		ValidateRect( SELF:Handle(), NULL_PTR )
		RETURN self
		
	CONSTRUCTOR( oOwner, xID, oPoint, oDimension, kStyle ) 
		//	
		SUPER(oOwner, xID, oPoint, oDimension, kStyle )
		//
		//SELF:Background := Brush{ BRUSHLIGHT }
		//
		RETURN 
		
		
	ACCESS Pointer 
		RETURN SELF:oPointer
		
	ASSIGN Pointer(oNewPointer) 
		//
		SELF:oPointer := oNewPointer
		//
		IF ( SELF:oPointer != NULL_OBJECT )
			SetCursor( SELF:oPointer:Handle() )
		ELSE
			SetCursor( LoadCursor(0, IDC_ARROW) )
		ENDIF
		//
		
		
	METHOD ReleaseMouse( ) 
		//
		ReleaseCapture( )
		//
		return self
		
END CLASS

CLASS FabVertSplitbar INHERIT FabSplitBar
	EXPORT Position AS SYMBOL
	
	METHOD __InvertRect( nMove ) 
		LOCAL rc	IS	_winRect
		LOCAL hDC	AS	PTR
		LOCAL hBrush	AS	PTR
		//
		IF IsNil( nMove )
			nMove := 0
		ENDIF
		//
		GetClientRect( SELF:Handle(), @rc )
		//
		rc:Left := rc:Left + nMove
		rc:Right := rc:right + nMove
		//
		MapWindowPoints( SELF:Handle(), GetParent( SELF:Handle() ), (_winPOINT PTR)@rc, 2 )
		hDC := GetDC( GetParent(SELF:Handle()) )
		hBrush := GetStockObject( DKGRAY_BRUSH )
		SelectObject( hDC, hBrush )
		PatBlt( hDC, rc:left, rc:top, rc:right - rc:left, rc:bottom - rc:top, PATINVERT)
		ReleaseDC( GetParent(SELF:Handle()), hDC )
		//
		return self	
		
	CONSTRUCTOR( oOwner, xID, oPoint, oDimension, kStyle ) 
		//
		SUPER(oOwner, xID, oPoint, oDimension, kStyle )
		//
		oDimension := SELF:Size
		SELF:Size := Dimension{ GetSystemMetrics( SM_CYDLGFRAME ) + 2, oDimension:Height }
		//
		SELF:Pointer := FABVSPLITBARCURSOR{}
		SELF:Position := #UNKNOWN
		//
		RETURN 
		
	METHOD MouseButtonDown( oEvent ) 
		//	
		IF oEvent:IsLeftButton
			// Capture all Mouse message
			SELF:CaptureMouse()
			SELF:lInDrag := TRUE
			// As this can be a negative value.... ( But this SHOULD NOT happen here )
			SELF:nStart := SHORT(_CAST,LoWord( oEvent:lParam ))
			SELF:nPrevMove := 0
			SELF:__InvertRect()
			//
		ENDIF
		RETURN SUPER:MouseButtonDown( oEvent )
		
		
	METHOD MouseButtonUp( oEvent ) 
		LOCAL nMove	AS	LONG
		//	
		IF ( oEvent:IsLeftButton ) .AND. SELF:lInDrag
			//
			SELF:ReleaseMouse()
			SELF:lInDrag := FALSE
			SELF:__InvertRect( SELF:nPrevMove )
			nMove := SHORT(_CAST,LoWord( oEvent:lParam )) + SELF:nStart
			SELF:nPrevMove := 0
			IF IsMethod( SELF:Owner, #OnVertSplitbarMove )
				Send( SELF:Owner, #OnVertSplitbarMove, nMove )
			ENDIF
			//
		ENDIF
		RETURN SUPER:MouseButtonUp( oEvent )
		
	METHOD MouseDrag( oEvent )
		LOCAL nMove	AS	LONG
		//	
		IF ( oEvent:IsLeftButton ) .AND. SELF:lInDrag
			SELF:__InvertRect( SELF:nPrevMove )
			//
			nMove := SHORT(_CAST,LoWord( oEvent:lParam )) + SELF:nStart
			SELF:__InvertRect( nMove )
			SELF:nPrevMove := nMove
		ENDIF
		//	
		RETURN SUPER:MouseDrag( oEvent )
		
	METHOD UpdatePosition() 
		LOCAL rc	IS	_winrect
		LOCAL Width	AS	LONG
		//
		GetClientRect( GetParent(SELF:Handle()), @rc )
		Width := SELF:Size:Width
		//
		IF ( SELF:Position == #RIGHT )
			SetWindowPos( SELF:Handle(), NULL, rc:right-Width, rc:top, Width, rc:bottom-rc:Top, SWP_NOACTIVATE + SWP_NOZORDER )
		ELSEIF ( SELF:Position == #LEFT )
			SetWindowPos( SELF:Handle(), NULL, rc:left, rc:top, Width, rc:bottom-rc:Top, SWP_NOACTIVATE + SWP_NOZORDER )
		ENDIF
		//
		
		return self
		
END CLASS

CLASS FABVSPLITBARCURSOR INHERIT Pointer
	
	CONSTRUCTOR() 
		super(ResourceID{"FABVSPLITBARCURSOR", _GetInst()})
		return 
END CLASS

