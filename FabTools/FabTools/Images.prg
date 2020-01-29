CLASS	FabBitmap	INHERIT	FabImage
//g Images,Images Classes/Functions
//
	



METHOD	Axit( )			
	IF ( SELF:hBitmap != NULL_PTR )
		// Free Bitmap
		DeleteObject( SELF:hBitmap )
	ENDIF



RETURN self

METHOD	Destroy( )			
//p Destroy the Bitmap
	IF ( SELF:hBitmap != NULL_PTR )
		// Free Bitmap
		DeleteObject( SELF:hBitmap )
		SELF:hBitmap := NULL_PTR
	ENDIF




RETURN self

ACCESS	Size			
//r The Size of the Bitmpa Object ( as a Dimension )
	LOCAL oDim		AS	Dimension
	LOCAL hDCMem	AS	PTR
	LOCAL hDC		AS	PTR
	LOCAL hOldBm	AS	PTR
	LOCAL Bitmap	IS	_WinBitmap
	LOCAL liHeight	AS	LONG
	LOCAL liWidth	AS	LONG
	//
	IF ( SELF:hBitmap != NULL_PTR )
		//
		hDC := GetDC( 0 )
		hDCMem := CreateCompatibleDC( hDC )
		GetObject( hBitmap, _SizeOf( _WinBitmap ), @Bitmap )
		hOldBm := SelectObject( hDCMem, hBitmap )
		//
		liHeight := Bitmap.bmHeight
		liWidth := Bitmap.bmWidth
		//
		SelectObject( hDCMem, hOldBm )
		DeleteDC( hDCMem )
		ReleaseDC( 0, hDC )
		//
		oDim := Dimension{ liWidth, liHeight }
		//
	ELSE
		oDim := Dimension{ 0, 0 }
	ENDIF
RETURN ( oDim )





END CLASS
CLASS	FabDIB	INHERIT	FabImage
//g Images,Images Classes/Functions
	



METHOD	Axit( )			
	IF ( SELF:hBitmap != NULL_PTR )
		// Free Bitmap
		GlobalFree( SELF:hBitmap )
	ENDIF



RETURN self

METHOD	Destroy( )			
	IF ( SELF:hBitmap != NULL_PTR )
		// Free Bitmap
		GlobalFree( SELF:hBitmap )
		SELF:hBitmap := NULL_PTR
	ENDIF




RETURN self

METHOD	Init( hDIB )	
//p Create a FabDIB object
//a <hDIB> is a pointer to a DIB memory
//d You can use the FabReadBMPFile2DIB() to create a DIB pointer, then build a FabDIB object.
//d  Then you can pass this FabDIB object to a FabDIBObject() to use the standard Window:Draw() method.
	//
	SELF:hBitmap := hDIB
	//
RETURN SELF



ACCESS	Size			
//r The Size of the FabDIB object ( as a Dimension )
	LOCAL oDim		AS	Dimension
	LOCAL Bmi		AS    _WinBitmapInfoHeader
	LOCAL Bmc		AS    _FabBitmapCoreHeader
	LOCAL liHeight	AS	LONG
	LOCAL liWidth	AS	LONG
	//
	IF ( SELF:hBitmap != NULL_PTR )
		//
		IF FabIsWin30DIB( SELF:hBitmap )
			Bmi := SELF:hBitmap
			liHeight :=  Bmi.biHeight
			liWidth := Bmi.biWidth
		ELSE
			Bmc := SELF:hBitmap
			liHeight := Bmc.bcHeight
			liWidth := Bmc.bcWidth
		ENDIF
		//
		oDim := Dimension{ liWidth, liHeight }
	ELSE
		oDim := Dimension{ 0, 0 }
	ENDIF
RETURN ( oDim )




END CLASS
CLASS	FabIcon	INHERIT	FabImage
//g Images,Images Classes/Functions
	



METHOD	Axit( )			
	IF ( SELF:hBitmap != NULL_PTR )
		// Free icon
		DestroyIcon( SELF:hBitmap )
	ENDIF


RETURN self


METHOD	Destroy( )			
	IF ( SELF:hBitmap != NULL_PTR )
		// Free icon
		DestroyIcon( SELF:hBitmap )
		SELF:hBitmap := NULL_PTR
	ENDIF




RETURN self

ACCESS	Size			
//r The size of the Icon  ( as a Dimension )
	LOCAL oDim		AS	Dimension
	LOCAL hDCMem	AS	PTR
	LOCAL hDC		AS	PTR
	LOCAL hOldBm	AS	PTR
	LOCAL Bitmap	IS	_WinBitmap
	LOCAL Icon		IS 	_winIconInfo
	LOCAL liHeight	AS	LONG
	LOCAL liWidth	AS	LONG
	LOCAL hBitmap	AS	PTR
	//
	IF ( SELF:hBitmap != NULL_PTR )
		//
		GetIconInfo( SELF:hBitmap, @Icon )
		hBitmap := Icon.hbmMask
		//
		hDC := GetDC( 0 )
		hDCMem := CreateCompatibleDC( hDC )
		GetObject( hBitmap, _SizeOf( _WinBitmap ), @Bitmap )
		hOldBm := SelectObject( hDCMem, hBitmap )
		//
		liHeight := Bitmap.bmHeight
		liWidth := Bitmap.bmWidth
		//
		SelectObject( hDCMem, hOldBm )
		DeleteDC( hDCMem )
		ReleaseDC( 0, hDC )
		//
		DeleteObject( Icon.hbmMask )
		DeleteObject( Icon.hbmColor )
		//
		oDim := Dimension{ liWidth, liHeight }
		//
	ELSE
		oDim := Dimension{ 0, 0 }
	ENDIF
RETURN ( oDim )





END CLASS
CLASS FabImage
//g Images,Images Classes/Functions
//l Base-Class for Images
//p Base-Class for Images
//d This Base-Class ofers services for basic Image Handling.
	PROTECT hBitmap	AS	PTR

*	DECLARE	METHOD	Init		//( hBmp AS PTR )




METHOD	Axit( )			
	// Deferred



RETURN self

METHOD	Destroy( )			
//p This method doesn't exist in FabImage Class ( It's more true to say that It does nothing ! ).
//p All SubClasses must provide a Destroy() method according to the type if Handle used in the
//p  Init() or SetHandle() methods.
	// Deferred



RETURN self

METHOD	Handle( )		
//p Return the Handle of the Image attached to this FabImage Object
RETURN	( SELF:hBitmap )




METHOD	Init( hBmp )	
//d Create a FabImage Object
//a <hBmp> is the HANDLE of the Image ( It can be a Bitmap, an Icon, ... )
	//
	SELF:hBitmap := hBmp
	//
	RegisterAxit( SELF )

RETURN SELF


METHOD	SetHandle( ptrBitmap AS PTR )	
//p Attach a new handle to this Image.
	//
	IF !IsPtr( ptrBitmap )
		RETURN self
	ENDIF
	IF ( ptrBitmap != NULL_PTR )
		IF ( SELF:hBitmap != NULL_PTR )
			// Free Bitmap
			SELF:Destroy( )
		ENDIF
		SELF:hBitmap := ptrBitmap
	ENDIF
	//



RETURN self

ACCESS	Size			
//r Return the Size of the Image. ( as a Dimension ) \line
//r This is an Abstract method, all SubClasses must provide a Size Access according to the type if Handle used in the
//r  Init() or SetHandle() methods.
	LOCAL oDim		AS	Dimension
	//
	oDim := Dimension{ 0, 0 }
RETURN ( oDim )

	



END CLASS
CLASS	FabVOBitmap	INHERIT	Bitmap
//g Images,Images Classes/Functions
//d Sub-Class of the VO Bitmap Class, that provide an easy way to change the Icon Handle
//d  of the underground Windows-Bitmap





METHOD	SetHandle( ptrBitmap )	
//d Set a New Handle for the Bitmap Object. It first destroy any previous Bitmap.
	//
	IF !IsPtr( ptrBitmap )
		RETURN self
	ENDIF
	IF ( ptrBitmap != NULL_PTR )
		IF ( SELF:hBitmap != NULL_PTR )
			// Free Bitmap
			DeleteObject( SELF:hBitmap )
		ENDIF
		SELF:hBitmap := ptrBitmap
	ENDIF
	//
return self



END CLASS
CLASS	FabVOIcon	INHERIT	Icon
//g Images,Images Classes/Functions
//d Sub-Class of the VO Icon Class, that provide an easy way to change the Icon Handle
//d  of the underground Windows-Icon




METHOD	SetHandle( ptrBitmap )	
//d Set a New Handle for the Icon Object. It first destroy any previous Icon.
	//
	IF !IsPtr( ptrBitmap )
		RETURN self
	ENDIF
	IF ( ptrBitmap != NULL_PTR )
		IF ( SELF:hIcon != NULL_PTR )
			// Free Icon
			DestroyIcon( SELF:hIcon )
		ENDIF
		SELF:hIcon := ptrBitmap
	ENDIF
	//



RETURN self


END CLASS
VOSTRUCT _FabBITMAPCOREHEADER
              MEMBER bcSize AS DWORD
              MEMBER bcWidth AS WORD		// Bug in VO2 definition !!
              MEMBER bcHeight AS WORD
              MEMBER bcPlanes AS WORD
              MEMBER bcBitCount AS WORD





