
CLASS OutlookBarArrow INHERIT OutlookBarElement
	//
	PROTECT _oParent AS OutlookBarHeader
	//
	
	ACCESS Control as OutlookBar
	RETURN SELF:_oParent:Control


METHOD Draw( hDC AS PTR ) AS LOGIC  
	LOCAL rect IS _winRect
	LOCAL dwState AS DWORD
	//	
	dwState := 0
	//
	SELF:Area:GetRectWin( @rect )
	//
	IF SELF:_symName = #_Up
		dwState := (DWORD)DFCS_SCROLLUP
	ELSEIF SELF:_symName = #_Down
		dwState := (DWORD)DFCS_SCROLLDOWN
	ENDIF
	//
	IF SELF:_lPressed
		dwState := _OR(dwState, (DWORD)DFCS_PUSHED)
	ENDIF
	//
	IF SELF:Control:BarStyle == #FABSTYLE
		dwState := _Or( dwState, (DWORD)DFCS_FLAT )
	ENDIF
	//
	DrawFrameControl( hDC, @rect, (DWORD)DFC_SCROLL, dwState )
	//
RETURN TRUE


CONSTRUCTOR( symName, oHeader ) 
	SUPER( symName )
	SELF:_oParent := oHeader
	SELF:_lPressed := FALSE

return 

METHOD Press( lOnOff AS LOGIC ) AS VOID  
	LOCAL hDC AS PTR
	//
	IF lOnOff
		IF !SELF:_lPressed
			SELF:_lPressed := TRUE
			hDC := GetDC( SELF:Control:Handle() )
			SELF:Draw( hDC )
			ReleaseDC( SELF:Control:Handle(), hDC )
		ENDIF
	ELSE
		IF SELF:_lPressed
			SELF:_lPressed := FALSE
			hDC := GetDC( SELF:Control:Handle() )
			SELF:Draw( hDC )
			ReleaseDC( SELF:Control:Handle(), hDC )
		ENDIF
	ENDIF

return 

METHOD Update() AS VOID  
	//
	SELF:_oParent:Update()
	//

return 
END CLASS

