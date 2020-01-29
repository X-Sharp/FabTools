#region DEFINES
DEFINE _winPALVERSION  := 0x0300   // Windows 3.0
#endregion

FUNCTION	FabAdd2Ptr( ptrVal AS PTR, inc AS DWORD )	AS	PTR
//l Add an offset to a pointer
//d Move a pointer to a new position, using a Increment value. ( Data is always byte )
LOCAL	dwPtr	AS	DWORD
	// Convert PTR to DWORD
dwPtr := DWORD( _CAST, ptrVal )
	// Add step
dwPtr := dwPtr + inc
	// Back to ptr
RETURN PTR( _CAST, dwPtr )




FUNCTION FabBitmapToDIB( hBm AS PTR, hPal := NULL_PTR AS PTR ) AS PTR
//g DIB,Device Independant Bitmap Classes/Functions
//g Images,Images Classes/Functions
//p Convert a Bitmap Handle to a DIB memory
//l Convert a Bitmap Handle to a DIB memory
//x <hBm> is the Handle of the Bitmap object to convert\line
//x <hPal> is an optionnal Palette Handle.
//r A DIB Handle. ( You MUST free it using the GlobalFree() function when you no longer need to use the DIB )
//
	LOCAL   hOldPal		:= NULL_PTR AS      PTR		// VO2
	LOCAL   hDC			AS      PTR		// VO2
	LOCAL   ptrBits		AS      PTR
	LOCAL   ptrBIHeader	AS      _WinBitmapInfoHeader
	LOCAL   hdrSize		AS      DWORD
	LOCAL   hDib		AS		PTR		// VO2
	LOCAL   BIHeader	IS      _WinBitmapInfoHeader
	LOCAL   Bitmap		IS      _WinBitmap
	// Get some info about the Bitmap
	GetObject( hbm, _SizeOf( _WinBitmap ), @Bitmap)
	// "Standard" init of the BitmapInfoHeader
	FabInitBitmapInfoHeader( @BIHeader, DWORD( Bitmap.bmWidth) , DWORD( Bitmap.bmHeight ), DWORD( Bitmap.bmPlanes * Bitmap.bmBitsPixel) )
	// Allocate memory for the DIB
	hdrSize := _SizeOf( _WinBitmapInfoHeader ) + FabPaletteSize( @BIHeader ) + BIHeader.biSizeImage
	hDib := GlobalAlloc(GHND, hdrSize )
	IF ( hDib == 0 )
		//MessageAlert( "Unable to allocate DIB memory !", "BitmapToDib" )
		RETURN ( 0 )
	ENDIF
	ptrBIHeader := GlobalLock( hDib )
	IF ( ptrBIHeader == NULL_PTR )
		GlobalFree( hDib )
		//MessageAlert( "Unable to lock DIB memory !", "BitmapToDib" )
		RETURN ( 0 )
	ENDIF
	 //
	hDc := GetDC( 0 )
	//
	IF ( hDc != NULL_PTR )
		IF ( hPal != NULL_PTR )
			hOldPal := SelectPalette( hDC, hPal, FALSE )
			RealizePalette( hDC )
		ENDIF
		// Copy header : BitmapInfoHeader + Palette
		MemCopy( ptrBIHeader, @BIHeader, WORD( hdrSize - BIHeader.biSizeImage ) )
		// Get a pointer to Bits
		ptrBits := FabDIBitmapBits( ptrBIHeader )
		IF ( GetDIBits( hDC, hBm, 0, WORD( Bitmap.bmHeight ), ptrBits, ptrBIHeader, DIB_RGB_COLORS ) == 0 )
			GlobalUnlock( hDib )
			hDib := 0
		ELSE
			GlobalUnlock( hDib )
		ENDIF
		//
		IF ( hOldPal!= NULL_PTR )
			SelectPalette( hDC, hOldPal, FALSE )
		ENDIF
	ENDIF
	// Free...
	GlobalUnlock( hDib )
	ReleaseDC( 0, hDC )
	//
	RETURN ( hDib )




	FUNCTION FabBMPString2DIB( cBMP AS STRING ) AS PTR
//g DIB,Device Independant Bitmap Classes/Functions
//g Images,Images Classes/Functions
//p Convert a BMP string to a DIB
//l Convert a BMP string to a DIB
//x <cString> is a valid string with all BMP data
//r A pointer to a DIB memory. ( Don't forget to free the DIB memory when you don't need it with the GlobalFree() function )
	LOCAL	lFSize		AS	DWORD
	LOCAL	hDib		:= NULL_PTR AS	PTR		// VO2
	LOCAL	BFHeader	IS	_WinBitmapFileHeader
	LOCAL	ptrData		AS	PTR
	LOCAL	FilePos		AS	LONGINT
	//
	lFSize := SLen( cBMP )
	//
	MemCopyString( @BFHeader, cBMP, _SizeOf( _WinBitmapFileHeader ) )
	//
	IF ( BFHeader.bfType == 19778 ) //  'BM'
    	//
		hDIB :=GlobalAlloc( GMEM_MOVEABLE + GMEM_DISCARDABLE, lFSize - _SizeOf( _WinBitmapFileHeader ) )
		IF ( hDIB != NULL_PTR )
			ptrData := GlobalLock( hDIB )
			IF ( ptrData != NULL_PTR )
				FilePos := _SizeOf( _WinBitmapFileHeader ) + 1
				MemCopyString( ptrData, SubStr( cBmp, FilePos ), DWORD( lFSize - _SizeOf( _WinBitmapFileHeader ) ) )
				//
			ENDIF
			GlobalUnlock( hDIB )
		ELSE
			//MessageAlert( "GlobalAlloc Error !", "ReadBitmap" )
		ENDIF
	ELSE
		//MessageAlert( "Wrong File Format", "ReadBitmap" )
	ENDIF
	RETURN ( hDIB )




	FUNCTION FabCreateDIBPalette( hDIB AS PTR ) AS PTR
//g DIB,Device Independant Bitmap Classes/Functions
//g Images,Images Classes/Functions
//p Create a Palette memory using a DIB memory
//l Create a Palette memory using a DIB memory
//d This function will create a separate palette memory info from a specified DIB memory.\line
//d When you no longer need the palette, call the DeleteObject() function to delete it.
//r A pointer to the newly allocated palette data.
	LOCAL	lpPal		AS	_winLOGPALETTE
	LOCAL	hLogPal		AS	PTR
	LOCAL	hPal		:=  NULL_PTR AS	PTR
	LOCAL	i			AS	DWORD
	LOCAL	wNumColors	AS	DWORD
	LOCAL	lpbmi		AS	_winBitmapInfo
	LOCAL	lpbi		AS	PTR
	//
	IF ( hDIB == NULL_PTR )
		RETURN ( NULL_PTR )
	ENDIF
	//
	lpbi := GlobalLock( hDIB )
	lpbmi := lpbi
	wNumColors := FabDIBitmapColors( lpbi )
	IF ( wNumColors > 0 )
		hLogPal := GlobalAlloc( GHND, _sizeof( _winLOGPALETTE ) + _SizeOf( _winPALETTEENTRY ) * wNumColors )
		IF ( hLogPal == NULL_PTR )
			GlobalUnlock( hDIB )
			RETURN ( NULL_PTR )
		ENDIF
		lpPal := GlobalLock( hLogPal )
		lpPal.palVersion := _winPALVERSION
		lpPal.palNumEntries := WORD( wNumColors )
		FOR i := 0 TO ( wNumColors - 1 )
			//
			lpPal.palPalEntry[ 1 ].peRed 	:= lpBmi.bmiColors[ i ].rgbRed
			lpPal.palPalEntry[ 1 ].peGreen 	:= lpBmi.bmiColors[ i ].rgbGreen
			lpPal.palPalEntry[ 1 ].peBlue	:= lpBmi.bmiColors[ i ].rgbBlue
			lpPal.palPalEntry[ 1 ].peFlags 	:= 0
			// As the DIM array as a size of 1, move the pointer
			FabAdd2Ptr( lpPal, _SizeOf( _winPALETTEENTRY ) )
			// Idem
			FabAdd2Ptr( lpBmi, _SizeOf( _winRGBQUAD ) )
		NEXT
		//
		hPal := CreatePalette( lpPal )
		//
		GlobalUnlock( hLogPal )
		GlobalFree( hLogPal )
		//
	ENDIF
	GlobalUnlock( hDib )
	//
	RETURN	hPal




	FUNCTION FabDIB2BMPString( hDIB AS PTR ) AS STRING
//g DIB,Device Independant Bitmap Classes/Functions
//g Images,Images Classes/Functions
//p Convert a DIB memory to a Bitmap string
//l Convert a DIB memory to a Bitmap string
//x <hDIB> is a valid pointer to a DIB
//r A String with all BMP datas
	LOCAL cHeader	AS	STRING
	LOCAL cData		AS	STRING
	LOCAL lSize		AS	DWORD
	LOCAL BFHeader	AS	_WinBitmapFileHeader
	LOCAL BInfo		AS	_WinBitmapInfoHeader
	//
	IF ( hDIB != NULL_PTR )
		// Lock DIB Data
		BInfo := GlobalLock( hDIB )
		lSize := GlobalSize( hDIB )
		//
		IF ( BInfo != NULL_PTR )
			BFHeader := MemAlloc( _SizeOf( _WinBitmapFileHeader ) )
			//
			BFHeader.bfType := 19778 //  'BM'
			BFHeader.bfSize := _SizeOf( _WinBITMAPFILEHEADER ) + DWORD( lSize )
			BFHeader.bfReserved1 := 0
			BFHeader.bfReserved2 := 0
			BFHeader.bfOffBits := _SizeOf( _WinBITMAPFILEHEADER)  + BInfo.biSize + FabPaletteSize( BInfo )
			//
			cHeader := Mem2String( BFHeader, _SizeOf( _WinBitmapFileHeader ) )
			//
			cData := Mem2String( BInfo, lSize )
			//
			GlobalUnlock( hDIB )
			MemFree( BFHeader )
		ENDIF
	ENDIF
	RETURN ( cHeader + cData )




	FUNCTION	FabDIB2String( hDIB AS PTR ) AS STRING
//g DIB,Device Independant Bitmap Classes/Functions
//g Images,Images Classes/Functions
//p Convert a DIB memory to a string
//l Convert a DIB memory to a string
//x <hDIB> is a valid pointer to a DIB
//r A String with all DIB data.
	LOCAL sBuffer	AS	STRING
	LOCAL   lSize		AS      DWORD
	LOCAL   ptrData	AS      PTR
	//
	IF ( hDIB != NULL_PTR )
		// Lock DIB Data
		ptrData := GlobalLock( hDIB )
		lSize := GlobalSize( hDIB )
		//
		IF ( ptrData != NULL_PTR )
			//
			sBuffer := Mem2String( ptrData, lSize )
			//
			GlobalUnlock( hDIB )
		ENDIF
	ENDIF
	RETURN sBuffer




	FUNCTION FabDIBDraw( hDC AS PTR, hDib AS PTR, wCol AS INT, wRow AS INT, hPal AS PTR, wWidth AS DWORD, wHeight AS DWORD )
//g DIB,Device Independant Bitmap Classes/Functions
//g Images,Images Classes/Functions
//p Draw a DIB bitmap into a specified Device Context
//l Draw a DIB bitmap into a specified Device Context
//x <hDC> is a valid Device Context. ( Created with GetDC() or CreateDC() ).\line
//x <hDIB> is a valid pointer to a DIB memory.\line
//x <wCol> indicate the desired X position of the Upper Left bitmap\line
//x <wRow> indicate the desired X position of the Upper Left bitmap\line
//x <hPal> is a pointer to memory with palette data. ( NULL_PTR if none ).\line
//x <wWidth> indicate the desired Width of image. ( 0 if no scaling )\line
//x <wHeight> indicate the desired Height of image. ( 0 if no scaling ) \line
//r Alogical value indicating the succes of the operation.
	LOCAL lpBmp		AS	_winBitmapinfoHeader
	LOCAL lpBits	AS	PTR
	LOCAL hOldPal	:= NULL_PTR AS	PTR
	//
	lpBmp := GlobalLock( hDib )
	//
	IF( lpBmp != NULL_PTR )
		lpBits := FabDIBitmapBits(lpBmp)
		//
		IF( hPal != NULL_PTR )
			holdPal := SelectPalette( hDC, hPal, FALSE )
			RealizePalette( hDC )
		ENDIF
		IF( ( wWidth == 0 )  .OR. ( wHeight == 0 ) )
			SetDIBitsToDevice( hDC, wCol, wRow, DWORD(lpBmp.biWidth), 	;
			DWORD(lpBmp.biHeight), 0, 0, 0,			;
			DWORD(lpBmp.biHeight), lpBits, lpBmp, DIB_RGB_COLORS )
		ELSE
			StretchDIBits( hDC, wCol, wRow, INT( wWidth ), INT( wHeight ),			;
			0, 0, lpBmp.biWidth, lpBmp.biHeight,	;
			lpBits, lpBmp, DIB_RGB_COLORS, SRCCOPY )
		ENDIF
		IF( holdPal != NULL_PTR )
			SelectPalette( hDC, holdPal, TRUE )
			RealizePalette( hDC )
		ENDIF

		GlobalUnlock( hDib )

		RETURN TRUE
	ENDIF

	RETURN FALSE




	FUNCTION FabDIBHeight( ptrBInfo AS PTR ) AS DWORD
//g DIB,Device Independant Bitmap Classes/Functions
//g Images,Images Classes/Functions
//p Retrieve the Height of a DIB
//l Retrieve the Height of a DIB
//d Be aware that the DIB MUST have been GlobalLock() before calling this function.
//s
	LOCAL Bmi	AS    _WinBitmapInfoHeader
	LOCAL Bmc	AS    _WinBitmapCoreHeader
	LOCAL dwSize	AS    DWORD
	//
	IF FabIsWin30DIB( ptrBInfo )
		Bmi := ptrBInfo
		dwSize := DWORD( Bmi.biHeight )
	ELSE
		Bmc := ptrBInfo
		dwSize := DWORD( Bmc.bcHeight )
	ENDIF
	//
	RETURN dwSize




	FUNCTION FabDIBitmapBits( BInfo AS _WinBitmapInfo ) AS PTR
//g DIB,Device Independant Bitmap Classes/Functions
//g Images,Images Classes/Functions
//p Return a Pointer to bits location in a DIB memory
//l Return a Pointer to bits location in a DIB memory
//d Bits = Start + HeaderSize + BytesColors ( Win or OS/2 are # )
//d Be aware that the DIB MUST have been GlobalLock() before calling this function.
//s
	LOCAL   Bits            AS      PTR
	//
	Bits := FabAdd2Ptr( BInfo,BInfo.bmiHeader.biSize )
	//
	Bits := FabAdd2Ptr( Bits, FabPaletteSize( BInfo ) )
	//
	RETURN  Bits




	FUNCTION FabDIBitmapColors( BInfo AS _WINBitmapInfoHeader ) AS DWORD
//g DIB,Device Independant Bitmap Classes/Functions
//g Images,Images Classes/Functions
//p Count the number of used colors in a DIB memory.
//l Count the number of used colors in a DIB memory.
//d Be aware that the DIB MUST have been GlobalLock() before calling this function.
//s
	LOCAL   Bmi             AS      _WinBitmapInfo
	LOCAL   BCi             AS      _WinBitmapCoreInfo
	//
	IF !FabIsWin30DIB( BInfo )
		// OS/2 PM Bitmap, use bcBitCount field to determine colors
		BCi := BInfo
		DO CASE
			CASE BCi.bmciHeader.bcBitCount == 1
				RETURN 2                // Monochrome bitmap -> 2 colors
			CASE BCi.bmciHeader.bcBitCount == 4
				RETURN 16       // 4-bit image -> 16 colors
			CASE BCi.bmciHeader.bcBitCount == 8
				RETURN 256      // 8-bit image -> 256 colors
			OTHERWISE
				RETURN 0                // 24-bt image -> 0 colors in color table
		ENDCASE
	ELSE
		// Windows bitamp
		Bmi := BInfo
		//
		IF ( Bmi.bmiHeader.biClrUsed == 0 )
			DO CASE
				CASE Bmi.bmiHeader.biBitCount == 1
					RETURN 2                // Monochrome bitmap -> 2 colors
				CASE Bmi.bmiHeader.biBitCount == 4
					RETURN 16       // 4-bit image -> 16 colors
				CASE Bmi.bmiHeader.biBitCount == 8
					RETURN 256      // 8-bit image -> 256 colors
				CASE Bmi.bmiHeader.biBitCount == 24
					RETURN 0                // 24-bt image -> 0 colors in color table
			ENDCASE
		ELSE
			RETURN  bmi.bmiHeader.biClrUsed
		ENDIF
	ENDIF
	RETURN 0





	FUNCTION	FabDIBToBitmap( hDIB AS PTR, hPalette AS PTR ) AS PTR
//g DIB,Device Independant Bitmap Classes/Functions
//g Images,Images Classes/Functions
//p Convert a DIB memory to a Bitmap Handle
//l Convert a DIB memory to a Bitmap Handle
//x <hDib> is a pointer to a DIB memory.\line
//x <hPalette> is a pointer to a memory with palette information. ( NULL_PTR if none )
//r A Bitmap Handle ( pointer type )
	LOCAL   hBitmap   := NULL_PTR AS      PTR		// VO2
	LOCAL   hDC       AS      PTR		// VO2
	LOCAL   BInfo     AS      _WinBitmapInfo
	LOCAL   Bits      AS      PTR
	LOCAL   hOldPal   := NULL_PTR  AS		 PTR		// VO2
   //
	BInfo := GlobalLock( hDIB )
   //
	IF ( BInfo != NULL_PTR )
		hDC := GetDC( 0 )
      //
		IF ( hPalette != NULL_PTR )
			hOldPal := SelectPalette( hDC, hPalette, FALSE )
		ENDIF
		RealizePalette( hDC )
      //
		Bits := FabDIBitmapBits( BInfo )
      //
		hBitmap := CreateDIBitmap( hDC, BInfo, CBM_INIT, Bits, BInfo, DIB_RGB_COLORS )
      //
		IF ( hOldPal != NULL_PTR )
			SelectPalette( hDC, hOldPal, FALSE )
		ENDIF
      //
		ReleaseDC( 0, hDC )
	ENDIF
	GlobalUnlock( hDIB )
   //
	RETURN hBitmap




	FUNCTION FabDIBWidth( ptrBInfo AS PTR ) AS DWORD
//g DIB,Device Independant Bitmap Classes/Functions
//g Images,Images Classes/Functions
//p Retrieve the Width of a DIB
//l Retrieve the Width of a DIB
//d Be aware that the DIB MUST have been GlobalLock() before calling this function.
//s
	LOCAL Bmi	AS    _WinBitmapInfoHeader
	LOCAL Bmc	AS    _WinBitmapCoreHeader
	LOCAL dwSize	AS    DWORD
	//
	IF FabIsWin30DIB( ptrBInfo )
		Bmi := ptrBInfo
		dwSize := DWORD( Bmi.biWidth )
	ELSE
		Bmc := ptrBInfo
		dwSize := DWORD( Bmc.bcWidth )
	ENDIF
	//
	RETURN dwSize




	STATIC PROCEDURE FabInitBitmapInfoHeader( BIHeader AS _WinBitmapInfoHeader, dwWidth AS DWORD, dwHeight AS DWORD, nBPP AS DWORD )
	// Zero init
	MemClear( BIHeader, _SizeOf( _WinBitmapInfoHeader ) )
	// Init header
	BIHeader.biSize   := _SizeOf( _WinBitmapInfoHeader )
	BIHeader.biWidth  := LONG( dwWidth )
	BIHeader.biHeight := LONG( dwHeight )
	BIHeader.biPlanes := 1
	IF ( nBPP <= 1 )
		nBPP := 1
	ELSEIF ( nBPP <= 4 )
		nBPP := 4
	ELSEIF ( nBPP <= 8 )
		nBPP := 8
	ELSE
		nBPP := 24
	ENDIF
	// Compute BitCount / Size
	BIHeader.biBitCount  := LoWord( nBPP )
	BIHeader.biSizeImage := FabWidthByte( dwWidth * nBPP ) * dwHeight
	//
	RETURN




	FUNCTION FabIsWin30DIB( ptrBInfo AS PTR ) AS LOGIC
//g DIB,Device Independant Bitmap Classes/Functions
//g Images,Images Classes/Functions
//p Check if ptrBInfo indicate a valid Windows or OS/2 Bitmap
//l Check for a valid Windows or OS/2 Bitmap
//d Be aware that the DIB MUST have been GlobalLock() before calling this function.
//
	LOCAL   Bmi       AS _WinBitmapInfo
	LOCAL   lRetVal   AS LOGIC
	//
	Bmi := ptrBInfo
	//
	IF !( Bmi.bmiHeader.biSize == _SizeOf( _WinBitmapInfoHeader ) )
		// OS/2
		lRetVal := FALSE
	ELSE
		// Windows
		lRetVal := TRUE
	ENDIF
	//
	RETURN lRetVal




	FUNCTION FabPaletteSize( ptrBInfo AS PTR ) AS DWORD
//g DIB,Device Independant Bitmap Classes/Functions
//g Images,Images Classes/Functions
//p Return the number of bytes in the DIB's color Table.
//l Return the size of a Palette in bytes
//d Be aware that the DIB MUST have been GlobalLock() before calling this function.
//
	LOCAL dwSize AS DWORD
	//
	IF FabIsWin30DIB( ptrBInfo )
		// Windows
		dwSize := FabDIBitmapColors( ptrBInfo ) * DWORD( _SizeOf( _WinRGBQuad ) )
	ELSE
		// OS/2
		dwSize := FabDIBitmapColors( ptrBInfo ) * DWORD( _SizeOf( _WinRGBTriple ) )
	ENDIF
	RETURN ( dwSize )




	FUNCTION	FabReadBMPFile( cFileName AS STRING ) AS PTR
//g DIB,Device Independant Bitmap Classes/Functions
//g Images,Images Classes/Functions
//p Read a .BMP file and return a Bitmap Handle
//l Read a .BMP file and return a Bitmap Handle
//x <cFileName> is a string with the FullPath information to a valid BMP file
//r A Pointer to a Windows Bitmap ( You must free it using the DeleteObject() function )
	LOCAL	hBitmap 	:= NULL_PTR AS	PTR		// VO2
	LOCAL	hFile		AS	PTR		// VO2
	LOCAL	lFSize		AS	DWORD
	LOCAL	hDib		AS	PTR		// VO2
	LOCAL	hRGB		AS	PTR		// VO2
	LOCAL	BFHeader	IS	_WinBitmapFileHeader
	LOCAL	BIHeader	IS	_WinBitmapInfoHeader
	LOCAL	lRGBSize	AS	DWORD
	LOCAL	ptrData		AS	PTR
	LOCAL	ptrRGB		AS	PTR
	LOCAL	hDC			AS	PTR		// VO2
	LOCAL	FilePos		AS	LONGINT
	//
	cFileName := AllTrim( cFileName )
	IF ( At( ".", cFileName ) == 0 )
		cFileName := cFileName + ".BMP"
	ENDIF
	//
	hFile := FOpen2( cFileName, FO_READ + FO_DENYWRITE )
	IF !( hFile == F_ERROR )
		//
		lFSize := DWORD( FSeek3( hFile, 0, FS_END ) )
		FRewind( hFile )
		FRead3( hFile, @BFHeader, _SizeOf( _WinBitmapFileHeader ) )
		FilePos := FTell( hFile )
		//
		FRead3( hFile, @BIHeader, _SizeOf( _WinBitmapInfoHeader ) )
		IF ( BFHeader.bfType == 19778 ) //  'BM'
			//
			lRGBSize := DWORD( _SizeOf(   _WinBitmapInfoHeader ) + FabPaletteSize( @BIHeader ) )
			hRGB := GlobalAlloc( GMEM_MOVEABLE + GMEM_DISCARDABLE, lRGBSize )
			IF ( hRGB != NULL_PTR )
				ptrRGB := GlobalLock( hRGB )
				IF ( ptrRGB != NULL_PTR )
					FSeek3( hFile, FilePos, FS_SET )
					FRead3( hFile, ptrRGB, DWORD( lRGBSize ) )
					//
					hDIB :=GlobalAlloc( GMEM_MOVEABLE + GMEM_DISCARDABLE, lFSize - BFHeader.bfOffBits )
					IF ( hDib != NULL_PTR )
						ptrData := GlobalLock( hDib )
						IF ( ptrData != NULL_PTR )
							FilePos := LONG( BFHeader.bfOffBits )
							FSeek3( hFile, FilePos, FS_SET )
							FRead3( hFile, ptrData, lFSize - BFHeader.bfOffBits )
							//
							hDC := GetDC( 0 )
							hBitmap	:= CreateDIBitmap( hDC, @BIHeader, CBM_INIT, ptrData, ptrRGB, DIB_RGB_COLORS )
							ReleaseDC( 0, hDC )
							GlobalUnlock( hDib )
						ENDIF
						//
						GlobalFree( hDib )
					ENDIF
					GlobalUnlock( hRGB )
					GlobalFree( hRGB )
				ELSE
					//MessageAlert( "GlobalAlloc Error !", "ReadBitmap" )
				ENDIF
			ELSE
				//MessageAlert( "GlobalAlloc Error !", "ReadBitmap" )
			ENDIF
		ELSE
			//MessageAlert( "Wrong File Format", "ReadBitmap" )
		ENDIF
		//
		FClose( hFile )
	ENDIF
	RETURN ( hBitmap )




	FUNCTION	FabReadBMPFile2DIB( cFileName AS STRING ) AS PTR
//g DIB,Device Independant Bitmap Classes/Functions
//g Images,Images Classes/Functions
//p Read a .BMP file to a DIB memory
//l Read a .BMP file to a DIB memory
//x <cFileName> is a string with the FullPath information to a valid BMP file
//r A Pointer to a DIB memory ( You must free it using the GlobalFree() function )
	LOCAL	hFile		AS	PTR		// VO2
	LOCAL	lFSize		AS	DWORD
	LOCAL	hDib		:= NULL_PTR  AS	PTR		// VO2
	LOCAL	BFHeader	IS	_WinBitmapFileHeader
	LOCAL	ptrData		AS	PTR
	//
	cFileName := AllTrim( cFileName )
	IF ( At( ".", cFileName ) == 0 )
		cFileName := cFileName + ".BMP"
	ENDIF
	//
	hFile := FOpen2( cFileName, FO_READ + FO_DENYWRITE )
	IF !( hFile == F_ERROR )
		//
		lFSize := DWORD( FSeek3( hFile, 0, FS_END ) )
		FRewind( hFile )
		FRead3( hFile, @BFHeader, _SizeOf( _WinBitmapFileHeader ) )
		//
		IF ( BFHeader.bfType == 19778 ) //  'BM'
			//
			hDIB :=GlobalAlloc( GMEM_MOVEABLE + GMEM_DISCARDABLE, lFSize - _SizeOf( _WinBitmapFileHeader ) )
			IF ( hDIB != NULL_PTR )
				ptrData := GlobalLock( hDIB )
				IF ( ptrData != NULL_PTR )
					FRead3( hFile, ptrData, DWORD( lFSize - _SizeOf( _WinBitmapFileHeader ) ) )
					//
				ENDIF
				GlobalUnlock( hDIB )
			ELSE
				//MessageAlert( "GlobalAlloc Error !", "ReadBitmap" )
			ENDIF
		ELSE
			//MessageAlert( "Wrong File Format", "ReadBitmap" )
		ENDIF
		//
		FClose( hFile )
	ENDIF
	RETURN ( hDIB )




	FUNCTION	FabString2DIB( cString AS STRING ) AS PTR
//g DIB,Device Independant Bitmap Classes/Functions
//g Images,Images Classes/Functions
//p Convert a string to a DIB
//l Convert a string to a DIB
//x <cString> is a valid string with all DIB data
//r A pointer to a DIB memory. ( Don't forget to free the DIB memory when you don't need it with the GlobalFree() function )
	LOCAL	hDIB		:= NULL_PTR  AS	PTR
	LOCAL   lSize			AS	DWORD
	LOCAL   ptrData		AS	PTR
	//
	IF !Empty( cString )
		//
		lSize := SLen( cString )
		//
		hDib :=GlobalAlloc( GMEM_MOVEABLE + GMEM_DISCARDABLE, lSize )
		IF ( hDib != NULL_PTR )
			// Lock DIB Data
			ptrData := GlobalLock( hDIB )
			IF ( ptrData != NULL_PTR )
				//
				MemCopyString( ptrData, cString, lSize )
				//
				GlobalUnlock( hDIB )
			ENDIF
		ENDIF
	ENDIF
	RETURN hDib




STATIC FUNCTION   FabWidthByte( bits AS DWORD ) AS DWORD
RETURN ( ( ( Bits + 31 ) / 32 ) * 4 )




FUNCTION        FabWriteDIB2BMPFile( hDIB AS PTR, cFileName AS STRING ) AS    LOGIC
//g DIB,Device Independant Bitmap Classes/Functions
//g Images,Images Classes/Functions
//p Write the specified DIB using the BMP format
//l Write the specified DIB using the BMP format
//x <hDib> is a pointer to a DIB memory.\line
//x <cFileName> is a string with the fullpath info of the desired BMP file
//r A logical value indicating the success of the operation
	LOCAL   hFile		AS      PTR		// VO2
	LOCAL   lSize		AS      DWORD
	LOCAL   BFHeader	AS      _WinBitmapFileHeader
	LOCAL   BInfo		AS      _WinBitmapInfoHeader
	LOCAL   lRetVal		:= FALSE AS      LOGIC
	LOCAL   pszFileName	AS      PSZ
	//
	// Use Windows Low-Level Functions
	pszFileName := String2Psz( cFileName )
	hFile :=  _lcreat( pszFileName, 0 )
	IF ( hFile != NULL_PTR )
		//
		BInfo := GlobalLock( hDIB )
		lSize := GlobalSize( hDIB )
		//
		IF ( BInfo != NULL_PTR )
			BFHeader := MemAlloc( _SizeOf( _WinBitmapFileHeader ) )
			//
			BFHeader.bfType := 19778 //  'BM'
			BFHeader.bfSize := _SizeOf( _WinBITMAPFILEHEADER ) + DWORD( lSize )
			BFHeader.bfReserved1 := 0
			BFHeader.bfReserved2 := 0
			BFHeader.bfOffBits := _SizeOf( _WinBITMAPFILEHEADER)  + BInfo.biSize + FabPaletteSize( BInfo )
			// Use of Windows Huge-Write due to VO trouble with Huge Pointers
			_hwrite( hFile, BFHeader, LONG(_SizeOf( _WinBitmapFileHeader ) ) )
			// 4. Write out DIB header and packed bits to file
			_hwrite( hFile, BInfo, LONG( lSize ) )
			GlobalUnlock( hDIB )
			MemFree( BFHeader )
			lRetVal := TRUE
		ELSE
			//MessageAlert( "Error locking bitmap into memory", "WriteDIB2BMPFile" )
		ENDIF
		_lclose( hFile )
	ELSE
		//MessageAlert( "Error creating file", "WriteDIB2BMPFile" )
	ENDIF
	RETURN  lRetVal






