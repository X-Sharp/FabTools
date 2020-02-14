 USING VO



CLASS FabDropDownBitmapButton INHERIT FabBitmapButton
	
	CONSTRUCTOR(oOwner, nID, oPoint, oDimension, cText, kStyle)  
   SUPER(oOwner, nID, oPoint, oDimension, cText, kStyle)
   RETURN

METHOD _DrawControl( hDC AS PTR ) AS VOID  
	LOCAL Canvas	IS	_winRect
	LOCAL hPen		AS	PTR
	//
	SUPER:_DrawControl( hDC )
	//	
	GetClientRect( SELF:Handle(), @Canvas )
	//
	Canvas:Left := Canvas:Right - 11
	IF SELF:_lAsFocus
		Canvas:left := Canvas:left - 1
		Canvas:right := Canvas:Right - 1
	ENDIF
	//
	Canvas:Top := ( Canvas:Bottom - Canvas:Top ) / 2 - 2
	IF SELF:_lPressed
		Canvas:top := Canvas:Top + 1
	ENDIF
	//
	hPen := GetStockObject( BLACK_PEN )
	SelectObject( hDC, hPen )
	MoveToEx( hDC, Canvas:Left, Canvas:top, NULL )
	LineTo( hDC, Canvas:Right - 6, Canvas:top )
	//
	MoveToEx( hDC, Canvas:Left+1, Canvas:top+1, NULL )
	LineTo( hDC, Canvas:Right - 7, Canvas:top+1 )
	//
	MoveToEx( hDC, Canvas:Left+2, Canvas:top+2, NULL )
	LineTo( hDC, Canvas:Right - 8, Canvas:top+2 )
	//
	GetClientRect( SELF:Handle(), @Canvas )
	IF SELF:_lAsFocus
		Canvas:right := Canvas:Right - 1
	ENDIF
	//
	hPen := GetStockObject( WHITE_PEN )
	SelectObject( hDC, hPen )
	MoveToEx( hDC, Canvas:Right - 14, Canvas:Top + 4, NULL )
	LineTo( hDc, Canvas:Right - 14, Canvas:Bottom - 4 )
	//
	hPen := CreatePen( PS_SOLID, 1, GetSysColor( COLOR_3DSHADOW ) )
	SelectObject( hDC, hPen )
	MoveToEx( hDC, Canvas:Right - 15, Canvas:Top + 4, NULL )
	LineTo( hDc, Canvas:Right - 15, Canvas:Bottom - 4 )
	SelectObject( hDC, hPen )
	DeleteObject( hPen )
	//
return	

METHOD _GetClientRect( Canvas AS _WINRECT ) AS VOID  
	//
	GetClientRect( SELF:Handle(), Canvas )
 	//
 	Canvas:Right := Canvas:Right - 14
 	//
return
END CLASS

