#include "GlobalDefines.vh"
#using FabPaintLib

CLASS MultiImageWindow INHERIT StdImageWindow
	//
	EXPORT oMulti		AS	FabMultiPage
	EXPORT nMaxPage 	AS	INT
	EXPORT nCurrentPage	AS	INT
	EXPORT oTimerCtrl	AS	FabTimerControl

METHOD Close() 		
	//
	SUPER:Close()
	//
	SELF:oMulti:Destroy()
	//
return self
	

CONSTRUCTOR(oParentWindow, cFileName, oMultiPage ) 
	//
	SUPER(oParentWindow, "" )
	//
	SELF:Caption := "MultiPage File : " + cFileName
	//	Le menu sans ToolBar
	SELF:Menu:DisableItem( IDM_ImgViewShellMenu_Edit_ID )
	SELF:Menu:DisableItem( IDM_ImgViewShellMenu_Image_ID )
	//
	SELF:oTimerCtrl := FabTimerControl{ SELF, 2032, Point{0,0}, Dimension{0,0} }
	SELF:oTimerCtrl:Timer:Interval := 100
	//	
	//
	SELF:oMulti := oMultiPage
	//
	SELF:nMaxPage := SELF:oMulti:PageCount
	SELF:nCurrentPage := 1
	//
	SELF:ShowCurrentImage()
	//
	SELF:oTimerCtrl:Start()
return 

METHOD OnFabTimer() 
	SELF:ShowCurrentImage()
	// DO it Again
RETURN TRUE
	

METHOD ShowCurrentImage() 
	//
	self:oImg := self:oMulti:CloneImage( self:nCurrentPage )
	SELF:oDCImg:Image := SELF:oImg	
	//
	SELF:nCurrentPage := SELF:nCurrentPage + 1
	IF ( SELF:nCurrentPage >= SELF:nMaxPage )
		SELF:nCurrentPage := 0
	ENDIF
	//
	
return self
END CLASS

