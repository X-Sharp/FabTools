CLASS FabSplitShellWindow INHERIT SHELLWINDOW


  //{{%UC%}} USER CODE STARTS HERE (do NOT remove this line)
	// Dialog in Left Part
	PROTECT oLeftDlg		AS	DialogWindow
	// Dialog in Bottom Part
	PROTECT oBottomDlg		AS	DialogWindow
	// The two Splitbar controls
	PROTECT oVertSplit		AS	FabVertSplitbar
	PROTECT oHorzSplit		AS	FabHorzSplitbar
	// Width of Left Dialog in Percent
	PROTECT liLeftPercent	AS	LONG
	// Height of Bottom in Percent
	PROTECT liBottomPercent	AS	LONG
	// Width of Left Dialog in Pixel
	PROTECT liLeftPixel		AS	LONG
	// Height of Bottom in Pixel
	PROTECT liBottomPixel	AS	LONG
	// Show what Pane ?
	PROTECT lShowLeft		AS	LOGIC
	PROTECT lShowBottom		AS	LOGIC
	// Use what Position ? #PERCENT or #PIXEL
	PROTECT symPosType		AS	SYMBOL
	//
	PROTECT lCanResizeLeftPane	AS	LOGIC
	PROTECT lCanResizeBottomPane	AS	LOGIC
	
	
//d Shell Window class with two special part : Left and bottom band may be dialog windows
//d  separated from the standard window background by SplitBar Controls.
	METHOD __AdjustClient() AS LOGIC  
	LOCAL strucClientRect	IS _winRect
	LOCAL oToolBar			AS ToolBar
	LOCAL oStatusBar		AS StatusBar
	LOCAL nVSplitWidth		AS	LONG
	LOCAL nVSplitHeight		AS	LONG
	LOCAL nHSplitWidth		AS	LONG
	LOCAL nHSplitHeight		AS	LONG
	LOCAL lToolBarValid   := TRUE AS LOGIC
	LOCAL lStatusBarValid := TRUE AS LOGIC
	LOCAL nLeftWidth			AS	LONG
	LOCAL nBottomHeight		AS	LONG
	//
	oToolBar   := SELF:ToolBar
	oStatusBar := SELF:StatusBar
	//
	IF SELF:lShowLeft
		nLeftWidth := SELF:__LeftSize
		IF SELF:lCanResizeLeftPane
			nVSplitWidth := GetSystemMetrics( SM_CYDLGFRAME ) + 2
		ENDIF
	ENDIF
	//
	IF SELF:lShowBottom
		nBottomHeight := SELF:__BottomSize
		IF SELF:lCanResizeBottomPane
			nHSplitHeight := GetSystemMetrics( SM_CXDLGFRAME ) + 2
		ENDIF
	ENDIF
	//
	IF (oToolBar == NULL_OBJECT)
		lToolBarValid := FALSE
	ELSEIF !oToolBar:IsVisible()
		lToolBarValid := FALSE
	ENDIF
	//
	IF (oStatusBar == NULL_OBJECT)
		lStatusBarValid := FALSE
	ELSEIF !oStatusBar:IsVisible()
		lStatusBarValid := FALSE
	ENDIF
	//
	GetClientRect(SELF:Handle(), @strucClientRect)
	//
	IF lStatusBarValid
		IF oStatusBar:__IsTopAligned
			strucClientRect:top += oStatusBar:Size:Height
		ELSE
			strucClientRect:bottom -= oStatusBar:Size:Height
		ENDIF
	ENDIF
	//
	IF lToolBarValid
		IF oToolBar:__IsTopAligned
			strucClientRect:top += oToolBar:Size:Height
    	ELSE
			strucClientRect:bottom -= oToolBar:Size:Height
		ENDIF
	ENDIF
	// Resize Left Pane
	IF ( SELF:oLeftDlg != NULL_OBJECT )
		SetWindowPos( SELF:oLeftDlg:Handle(), NULL_PTR,  strucClientRect:left, strucClientRect:top, ;
				nLeftWidth, ;
				strucClientRect:bottom - strucClientRect:top - nBottomHeight - nHSplitHeight, SWP_NOACTIVATE + SWP_NOZORDER )
		InvalidateRect( SELF:oLeftDlg:Handle(), NULL, FALSE )
	ENDIF
	// Resize Bottom Pane
	IF ( SELF:oBottomDlg != NULL_OBJECT )
		SetWindowPos( SELF:oBottomDlg:Handle(), NULL_PTR,  strucClientRect:left, strucClientRect:bottom - nBottomHeight, ;
				strucClientRect:right - strucClientRect:left, ;
				nBottomHeight, SWP_NOACTIVATE + SWP_NOZORDER )
		InvalidateRect( SELF:oBottomDlg:Handle(), NULL, FALSE )
	ENDIF
	// Resize Vertical SplitBar
	IF ( SELF:oVertSplit != NULL_OBJECT )
		nVSplitHeight := strucClientRect:bottom - strucClientRect:top - nBottomHeight - nHSplitHeight
		SetWindowPos( SELF:oVertSplit:Handle(), NULL_PTR, strucClientRect:left + nLeftWidth, strucClientRect:top, ;
				nVSplitWidth, nVSplitHeight, SWP_NOACTIVATE + SWP_NOZORDER )
	ENDIF
	// Resize Horizontal SplitBar
	IF ( SELF:oHorzSplit != NULL_OBJECT )
		nHSplitWidth := strucClientRect:right - strucClientRect:left
		SetWindowPos( SELF:oHorzSplit:Handle(), NULL_PTR,  strucClientRect:left, strucClientRect:bottom - nBottomHeight - nHSplitHeight, ;
				nHSplitWidth, ;
				nHSplitHeight, SWP_NOACTIVATE + SWP_NOZORDER )
	ENDIF
	// Resize Shell Part
/*
	SetWindowPos( SELF:Handle(4),NULL_PTR, strucClientRect.left + nLeftWidth + nVSplitWidth, strucClientRect.top, ;
				strucClientRect.right - strucClientRect.left - nLeftWidth - nVSplitWidth, ;
				strucClientRect.bottom - strucClientRect.top - nBottomHeight - nHSplitHeight+1, SWP_NOACTIVATE + SWP_NOZORDER )
*/
	//
	MoveWindow(SELF:Handle(4), strucClientRect:left + nLeftWidth + nVSplitWidth, strucClientRect:top, ;
		strucClientRect:right - strucClientRect:left - nLeftWidth - nVSplitWidth, ;
		strucClientRect:bottom - strucClientRect:top - nBottomHeight - nHSplitHeight+1, TRUE)
RETURN TRUE

ACCESS __BottomSize 
	LOCAL liSize	AS	LONG
	LOCAL rc		IS	_winRect
	//
	GetClientRect( SELF:Handle(), @rc )
	//
	IF ( SELF:symPosType == #PERCENT )
		liSize := ( SELF:liBottomPercent * ( rc:bottom - rc:top ) ) / 100
	ELSE
		liSize := SELF:liBottomPixel
	ENDIF
//	IF ( SELF:liBottomPixel == 0 )
//		SELF:liBottomPixel := ( SELF:liBottomPercent * ( rc.bottom - rc.top ) ) / 100
//	ENDIF
RETURN liSize

ACCESS __LeftSize 
	LOCAL liSize	AS	LONG
	LOCAL rc		IS	_winRect
	//
	GetClientRect( SELF:Handle(), @rc )
	//
	IF ( SELF:symPosType == #PERCENT )
		liSize := ( SELF:liLeftPercent * ( rc:right - rc:Left ) ) / 100
	ELSE
		liSize := SELF:liLeftPixel
	ENDIF
//	IF ( SELF:liLeftPixel == 0 )
//		SELF:liLeftPixel := ( SELF:liLeftPercent * ( rc.right - rc.Left ) ) / 100
//	ENDIF
RETURN liSize

ACCESS BottomPane as dialogwindow   
RETURN SELF:oBottomDlg

ASSIGN BottomPane( oDlg as dialogwindow )   
	//
	SELF:oBottomDlg := oDlg
	//
	IF ( oDlg != NULL_OBJECT )
		SELF:oBottomDlg:Show()
		SELF:oHorzSplit:Show()
	ELSE
		SELF:oHorzSplit:Hide()
	ENDIF
	//
	SELF:__AdjustClient()
RETURN 

ACCESS BottomSizePercent	
//r The height of the bottom part in percent
RETURN SELF:liBottomPercent

ASSIGN BottomSizePercent( nNew )	
//d Set the height of the bottom part in percent
	//
	SELF:liBottomPercent := nNew
	//
	SELF:__AdjustClient()
	//
RETURN 

ACCESS BottomSizePixel	
//r The height of the bottom part in number of pixels
RETURN SELF:liBottomPixel

ASSIGN BottomSizePixel( liValue )	
//d Set the height of the bottom part in number of pixels
	//
	SELF:liBottomPixel := liValue
	//
	SELF:__AdjustClient()
	//
RETURN 

ACCESS CanResizeBottomPane 
RETURN SELF:lCanResizeBottomPane

ASSIGN CanResizeBottomPane( lSet ) 
	SELF:lCanResizeBottomPane := lSet
	SELF:__AdjustClient()
RETURN 

ACCESS CanResizeLeftPane 
RETURN SELF:lCanResizeLeftPane

ASSIGN CanResizeLeftPane( lSet ) 
	SELF:lCanResizeLeftPane := lSet
	SELF:__AdjustClient()
RETURN 


CONSTRUCTOR( oParent, uExtra, VertSplitBarPercent, HorzSplitBarPercent  ) 
	//
	SUPER(oParent,uExtra)
	//
	SELF:SetStyle( WS_CLIPCHILDREN, FALSE )
	//
	IF !IsNil( VertSplitBarPercent )
		SELF:LeftSizePercent := VertSplitBarPercent
	ENDIF
	//
	IF !IsNil( HorzSplitBarPercent )
		SELF:BottomSizePercent := HorzSplitBarPercent
	ENDIF
	//
	SELF:oHorzSplit := FabHorzSplitbar{ SELF, 1001, Point{}, Dimension{}, WS_CHILD }
	SELF:oHorzSplit:Show()
	SELF:oVertSplit := FabVertSplitbar{ SELF, 1000, Point{}, Dimension{}, WS_CHILD }
	SELF:oVertSplit:Show()
	//
	SELF:symPosType := #PERCENT
	SELF:BottomSizePercent := 20
	SELF:LeftSizePercent := 20
	//
	SELF:lCanResizeBottomPane := TRUE
	SELF:lCanResizeLeftPane := TRUE
	//
	SELF:__AdjustClient()
	//
RETURN 

ACCESS LeftPane as dialogwindow  
RETURN SELF:oLeftDlg

ASSIGN LeftPane( oDlg as DialogWindow )   
	//
	SELF:oLeftDlg := oDlg
	//
	IF ( oDlg != NULL_OBJECT )
		SELF:oLeftDlg:Show()
		SELF:oVertSplit:Show()
	ELSE
		SELF:oVertSplit:Hide()
	ENDIF
	//
	SELF:__AdjustClient()
RETURN 

ACCESS LeftSizePercent	
//r The width of the left part in percent
RETURN SELF:liLeftPercent

ASSIGN LeftSizePercent( nNew )	
//s The width of the left part in percent
	//
	SELF:liLeftPercent := nNew
	//
	SELF:__AdjustClient()
	//
RETURN 

ACCESS LeftSizePixel	
//r The width of the left part in number of pixels
	//
RETURN SELF:liLeftPixel

ASSIGN LeftSizePixel( liValue )	
//d Set the width of the left part in number of pixels
	//
	SELF:liLeftPixel := liValue
	//
	SELF:__AdjustClient()
	//
RETURN 

METHOD OnHorzSplitbarMove( nSplitMove ) 
	LOCAL nNewHeight	AS	LONG
	LOCAL rc			IS	_winRect
	//
	GetClientRect( SELF:Handle(), @rc )
	//
//	nNewHeight := SELF:liBottomPixel - nSplitMove
	nNewHeight := SELF:__BottomSize - nSplitMove
	IF ( nNewHeight <= 0 ) .OR. ( nNewHeight > ( rc:bottom - rc:top ) )
		RETURN self
	ENDIF
	//
	SELF:liBottomPixel := nNewHeight
	//
	SELF:liBottomPercent := ( SELF:liBottomPixel * 100 )  / ( rc:bottom - rc:top )
	//
	SELF:__AdjustClient()
		
return self

METHOD OnVertSplitBarMove( nSplitMove ) 
	LOCAL nNewWidth	AS	LONG
	LOCAL rc		IS	_winRect
	//
	GetClientRect( SELF:Handle(), @rc )
	//
//	nNewWidth := SELF:liLeftPixel + nSplitMove
	nNewWidth := SELF:__LeftSize + nSplitMove
	IF ( nNewWidth <= 0 ) .OR. ( nNewWidth > ( rc:right - rc:left ) )
		RETURN self
	ENDIF
	//
	SELF:liLeftPixel := nNewWidth
	//
	SELF:liLeftPercent := ( SELF:liLeftPixel * 100 )  / ( rc:right - rc:Left )
	//
	SELF:__AdjustClient()

return self

ACCESS PosType 
RETURN SELF:symPosType

ASSIGN PosType( sNew ) 
	//
	IF ( sNew == #PERCENT ) .OR. ( sNew == #PIXEL )
		SELF:symPosType := sNew
	ENDIF
	//


METHOD Refresh() 
	//
	SELF:__AdjustClient()
	//
return self

ACCESS ShowBottomPane	
RETURN SELF:lShowBottom

ASSIGN ShowBottomPane( lNew ) 
	//
	SELF:lShowBottom := lNew
	//
	IF ( SELF:oBottomDlg == NULL_OBJECT )
		SELF:lShowBottom := FALSE
	ENDIF
	//
	SELF:__AdjustClient()
	//


ACCESS ShowLeftPane	
RETURN SELF:lShowLeft

ASSIGN ShowLeftPane( lNew ) 
	//
	SELF:lShowLeft := lNew
	//
	IF ( SELF:oLeftDlg == NULL_OBJECT )
		SELF:lShowLeft := FALSE
	ENDIF
	//
	SELF:__AdjustClient()


END CLASS

