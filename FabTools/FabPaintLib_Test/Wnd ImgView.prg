
using FabPaintLib
using FabPaintLib.Control
using FreeImageAPI
USING VO

define EXIF_MODEL_MAIN := FREE_IMAGE_MDMODEL.FIMD_EXIF_MAIN
define EXIF_MODEL_EXIF := FREE_IMAGE_MDMODEL.FIMD_EXIF_EXIF
define EXIF_MODEL_GPS  := FREE_IMAGE_MDMODEL.FIMD_EXIF_GPS
define EXIF_MODEL_MAKERNOTE := FREE_IMAGE_MDMODEL.FIMD_EXIF_MAKERNOTE
define	    COMPRESSION_PACKBITS := (0x0100 )
define	    COMPRESSION_NONE :=  (0x0800 )
define	    COMPRESSION_CCITTFAX3 :=  (0x1000 )
define	    COMPRESSION_CCITTFAX4 :=  (0x2000 )
define	    COMPRESSION_LZW :=  (0x4000 )
define	    COMPRESSION_JPEG :=  (0x8000 )
define	    COMPRESSION_DEFLATE :=  (0x0200 )
define     COMPRESSION_ADOBE_DEFLATE :=  (0x0400 )



CLASS StdImageWindow INHERIT ChildAppWindow
	//	
	EXPORT cFile	AS STRING
	//	
	EXPORT oImg		AS	FabPaintLib
	//
	EXPORT cx     	AS INT
	EXPORT cy     	AS INT
	//	
	EXPORT oDCImg	AS	FabPaintLibCtrl

METHOD ClipCopy() 
	//
	IF ( SELF:oImg:IsValid )
		SELF:oImg:ToClipboard()
	ENDIF
return self

METHOD ClipPaste() 
	LOCAL oNew	AS	FabPaintLib
	// Data available ?
	IF IsClipboardFormatAvailable( CF_DIB )
		// Create the VO Object
		oNew := FabPaintLib{ "" }
		// that we destroy and replace by the Clipboard
		oNew:FromClipboard()
		//
		SELF:Owner:CopyImg( oNew, "PasteFromClipboard.bmp" )
	ENDIF
	//
return self	

METHOD Close() 		
	//
	SUPER:Close()
	//
	IF !IsNil( SELF:oImg )
		SELF:oImg:Destroy()
		// HACK : Manual DESTRUCTION or Crash on exit.... ???
		Self:oDCImg:Destroy()
	ENDIF
	//
return self	
		
	

METHOD EXIFData() 
	LOCAL nCpt	as	dword
	LOCAL nMax	as	dword
	LOCAL cName	as	STRING
	LOCAL cDesc	as	STRING
	LOCAL cValue	as	STRING
	LOCAL oDlg	as	EXIFDlg
	local oItem	as	ListViewItem
	//
	oDlg := EXIFDlg{ self }
	//	
	// First, MAIN EXIF Data
	self:oImg:EXIFModel := (FREE_IMAGE_MDMODEL) EXIF_MODEL_MAIN
	nMax := dword(self:oImg:EXIFTagCount)
	//
	oItem := ListViewItem{}
	oItem:SetText( "Main", #Item )
	oItem:ImageIndex := 1
	oDlg:oDCEXIFListView:AddItem( oItem )
	//
	IF ( nMax > 0 )
		//
		FOR nCpt := 1 to nMax
			//
			cName := self:oImg:EXIFGetTagShortName( nCpt - 1 )
			cDesc := self:oImg:EXIFGetTagDescription( nCpt - 1 )
			cValue := self:oImg:EXIFGetTagValue( nCpt - 1 )
			//
			IF !Empty( cValue )
				//
				oItem := ListViewItem{}
				oItem:SetText( cName, #Item )
				oItem:SetText( cValue, #Value )
				oItem:SetText( cDesc, #Desc )
				oItem:ImageIndex := 2
				oDlg:oDCEXIFListView:AddItem( oItem )
			ENDIF
		NEXT
		//
	ENDIF
	// Then, EXIF EXIF Data
	self:oImg:EXIFModel :=  (FREE_IMAGE_MDMODEL) EXIF_MODEL_EXIF
	//	
	nMax := dword(self:oImg:EXIFTagCount)
	//
	oItem := ListViewItem{}
	oItem:SetText( "EXIF", #Item )
	oItem:ImageIndex := 1
	oDlg:oDCEXIFListView:AddItem( oItem )
	//
	IF ( nMax > 0 )
		//
		FOR nCpt := 1 to nMax *2
			//
			cName := self:oImg:EXIFGetTagShortName( nCpt - 1 )
			cDesc := self:oImg:EXIFGetTagDescription( nCpt - 1 )
			cValue := self:oImg:EXIFGetTagValue( nCpt - 1 )
			//
			IF !Empty( cValue )
				//
				oItem := ListViewItem{}
				oItem:SetText( cName, #Item )
				oItem:SetText( cValue, #Value )
				oItem:SetText( cDesc, #Desc )
				oItem:ImageIndex := 2
				oDlg:oDCEXIFListView:AddItem( oItem )
			ENDIF
		NEXT
		//
	ENDIF
	// Then, MakerNote EXIF Data
	self:oImg:EXIFModel :=  (FREE_IMAGE_MDMODEL) EXIF_MODEL_MAKERNOTE
	//	
	nMax := dword(self:oImg:EXIFTagCount)
	//
	oItem := ListViewItem{}
	oItem:SetText( "MakerNote", #Item )  
	oItem:ImageIndex := 1
	oDlg:oDCEXIFListView:AddItem( oItem )
	//
	IF ( nMax > 0 )
		//
		FOR nCpt := 1 to nMax
			//
			cName := self:oImg:EXIFGetTagShortName( nCpt - 1 )
			cDesc := self:oImg:EXIFGetTagDescription( nCpt - 1 )
			cValue := self:oImg:EXIFGetTagValue( nCpt - 1 )
			//
			IF !Empty( cValue )
				//
				oItem := ListViewItem{}
				oItem:SetText( cName, #Item )
				oItem:SetText( cValue, #Value )
				oItem:SetText( cDesc, #Desc )
				oItem:ImageIndex := 2
				oDlg:oDCEXIFListView:AddItem( oItem )
			ENDIF
		NEXT
		//
	ENDIF
	//
	if ( oDlg:oDCEXIFListView:ItemCount >0 )
		oDlg:Show()
	else
		oDlg := null_object
	ENDIF
	//
return self

METHOD Expose	(oExposeEvent)	
	//	
	SUPER:Expose(oExposeEvent)
/*	
	LOCAL nHeight 	AS INT
	LOCAL nWidth  	AS INT
	LOCAL oPOint	AS POINT
	//
	SELF:Refresh()
	//	
	IF ( oExposeEvent:Message == WM_PAINT .AND. oExposeEvent:Window  == SELF )
		IF SELF:oImg:IsValid
			//
			oPoint := SELF:Origin
			nHeight := SELF:oImg:Height
			nWidth  := SELF:oImg:Width
			//
			IF SELF:Owner:lStretch
				SELF:oImg:ShowFitToWindow( SELF:Handle() )
			ELSE	
				//SELF:Size := Dimension{nWidth + SELF:cx, nHeight+SELF:cy}
				//SELF:Origin := oPoint
				//SELF:oImg:Show( SELF:Handle() )
			ENDIF
			//
			SELF:RefreshInfo()
		ENDIF	
	ENDIF*/
return self

METHOD FileClose() 
	SELF:EndWindow()
return self

METHOD FileExit() 
	SELF:EndWindow()
return self

METHOD FilePrint() 
	LOCAL oPrn		AS	FabPrinter
	LOCAL oYNBox	AS	TEXTBox	
	//
	IF ( SELF:oImg:IsValid )
		//
		oYNBox := TextBox{ SELF, "Printing", "Fit Image to Printer ?" }
		oYNBox:Type := BOXICONQUESTIONMARK + BUTTONYESNO
		// Get the Printer
		oPrn := FabPrinter{ "Fab ImgView Print Job", SELF:Owner:Printer }
		//
		oPrn:oImg := SELF:oImg
		oPrn:FitToWindow := ( oYNBox:Show() == BOXREPLYYES )
		oPrn:UseGDI := FALSE
		oPrn:Qty := 1
		oPrn:Start()
		oPrn:Destroy()
	ENDIF
	//
return self
	

METHOD FocusChange( oFCE ) 
	//
	SUPER:FocusChange( oFCE )
	//
	IF ( oFCE:GotFocus )
		//SELF:RefreshInfo()
	ENDIF
	//
return self

METHOD ImgContrast() 
	LOCAL oDlg	AS	InputBox
	LOCAL rContrast	AS	REAL8
	LOCAL bOffset	AS	BYTE
	//
	IF ( SELF:oImg:IsValid )
		//
		oDlg := InputBox{ SELF }
		oDlg:oDCValue1Txt:Caption := "Contrast"
		oDlg:oDCValue2Txt:Caption := "Offset"
		oDlg:oDCValue3Txt:Hide()
		oDlg:oDCValue3:Hide()
		oDlg:oDCValue4Txt:Hide()
		oDlg:oDCValue4:Hide()
		oDlg:oDCValue1:TextValue := NTrim( 1 )
		oDlg:oDCValue2:TextValue := NTrim( 128 )
		//
		oDlg:Show()
		IF ( oDlg:Result == 1 )
			//
			rContrast := Val( oDlg:oDCValue1:TEXTValue )
			bOffset := Val( oDlg:oDCValue2:TEXTValue )
			//
			SELF:oImg:ChangeContrast( rContrast, bOffset )
			// Force Refresh
			InvalidateRect( SELF:Handle(), NULL, TRUE )
		ENDIF		
		//
	ENDIF	
return self

METHOD ImgCopy0() 
	LOCAL oCpyImg	AS	FabPaintLib
	//
	IF ( SELF:oImg:IsValid )
		oCpyImg := SELF:oImg:Copy( 0 )
		SELF:Owner:CopyImg( oCpyImg, SELF:cFile )
	ENDIF
return self

METHOD ImgCopy1() 
	LOCAL oCpyImg	AS	FabPaintLib
	//
	IF ( SELF:oImg:IsValid )
		oCpyImg := SELF:oImg:Copy( 1 )
		SELF:Owner:CopyImg( oCpyImg, SELF:cFile )
	ENDIF
return self

METHOD ImgCopy32() 
	LOCAL oCpyImg	AS	FabPaintLib
	//
	IF ( SELF:oImg:IsValid )
		oCpyImg := SELF:oImg:Copy( 32 )
		SELF:Owner:CopyImg( oCpyImg, SELF:cFile )
	ENDIF
return self	

METHOD ImgCopy8() 
	LOCAL oCpyImg	AS	FabPaintLib
	//
	IF ( SELF:oImg:IsValid )
		oCpyImg := SELF:oImg:Copy( 8 )
		SELF:Owner:CopyImg( oCpyImg, SELF:cFile )
	ENDIF
return self

METHOD ImgCrop() 
	LOCAL oDlg	AS	InputBox
	//
	IF ( SELF:oImg:IsValid )
		//
		oDlg := InputBox{ SELF }
		oDlg:oDCValue1Txt:Caption := "XMin"
		oDlg:oDCValue2Txt:Caption := "XMax"
		oDlg:oDCValue3Txt:Caption := "YMin"
		oDlg:oDCValue4Txt:Caption := "YMax"
		oDlg:oDCValue1:TextValue := NTrim( 0 )
		oDlg:oDCValue2:TextValue := NTrim( SELF:oImg:Width )
		oDlg:oDCValue3:TextValue := NTrim( 0 )
		oDlg:oDCValue4:TextValue := NTrim( SELF:oImg:Height )
		//
		oDlg:Show()
		IF ( oDlg:Result == 1 )
			SELF:oImg:Crop( Val(oDlg:oDCValue1:TEXTValue),Val(oDlg:oDCValue2:TEXTValue),Val(oDlg:oDCValue3:TEXTValue),Val(oDlg:oDCValue4:TEXTValue))
			// Force Refresh
			InvalidateRect( SELF:Handle(), NULL, TRUE )
		ENDIF		
		//
	ENDIF	
return self

METHOD ImgGray() 
	//
	IF ( SELF:oImg:IsValid )
		//
		SELF:oImg:GrayScale()
		// Force Refresh
		InvalidateRect( SELF:Handle(), NULL, TRUE )
		//
	ENDIF	
return self

METHOD ImgIntensity() 
	LOCAL oDlg	AS	InputBox
	LOCAL rIntensity	AS	REAL8
	LOCAL bOffset		AS	BYTE
	LOCAL rExponent 	AS REAL8
	//
	IF ( SELF:oImg:IsValid )
		//
		oDlg := InputBox{ SELF }
		oDlg:oDCValue1Txt:Caption := "Intensity"
		oDlg:oDCValue2Txt:Caption := "Offset"
		oDlg:oDCValue3Txt:Caption := "Exponent"
		oDlg:oDCValue4Txt:Hide()
		oDlg:oDCValue4:Hide()
		oDlg:oDCValue1:TextValue := NTrim( 20 )
		oDlg:oDCValue2:TextValue := NTrim( 128 )
		oDlg:oDCValue3:TextValue := NTrim( 1 )
		//
		oDlg:Show()
		IF ( oDlg:Result == 1 )
			//
			rIntensity := Val( oDlg:oDCValue1:TEXTValue )
			bOffset := Val( oDlg:oDCValue2:TEXTValue )
			rExponent := Val( oDlg:oDCValue3:TEXTValue )
			//
			SELF:oImg:ChangeIntensity( rIntensity, bOffset, rExponent )
			// Force Refresh
			InvalidateRect( SELF:Handle(), NULL, TRUE )
		ENDIF		
		//
	ENDIF	
return self

METHOD ImgInvert() 
	//
	IF ( SELF:oImg:IsValid )
		//
		SELF:oImg:Invert()
		// Force Refresh
		InvalidateRect( SELF:Handle(), NULL, TRUE )
		//
	ENDIF	
return self


METHOD ImgLightness() 
	LOCAL oDlg	AS	InputBox
	LOCAL iLightness	AS	LONG
	//
	IF ( SELF:oImg:IsValid )
		//
		oDlg := InputBox{ SELF }
		oDlg:oDCValue1Txt:Caption := "Lightness"
		oDlg:oDCValue2Txt:Hide()
		oDlg:oDCValue2:Hide()
		oDlg:oDCValue3Txt:Hide()
		oDlg:oDCValue3:Hide()
		oDlg:oDCValue4Txt:Hide()
		oDlg:oDCValue4:Hide()
		oDlg:oDCValue1:TextValue := NTrim( 1 )
		//
		oDlg:Show()
		IF ( oDlg:Result == 1 )
			//
			iLightness := Val( oDlg:oDCValue1:TEXTValue )
			//
			SELF:oImg:ChangeLightness( iLightness )
			// Force Refresh
			InvalidateRect( SELF:Handle(), NULL, TRUE )
		ENDIF		
		//
	ENDIF	
return self

METHOD ImgRBili() 
	LOCAL oDlg	AS	InputBox
	//
	IF ( SELF:oImg:IsValid )
		//
		oDlg := InputBox{ SELF }
		oDlg:oDCValue1Txt:Caption := "XSize"
		oDlg:oDCValue2Txt:Caption := "YSize"
		oDlg:oDCValue3Txt:Hide()
		oDlg:oDCValue3:Hide()
		oDlg:oDCValue4Txt:Hide()
		oDlg:oDCValue4:Hide()
		oDlg:oDCValue1:TextValue := NTrim( SELF:oImg:Width )
		oDlg:oDCValue2:TextValue := NTrim( SELF:oImg:Height )
		//
		oDlg:Show()
		IF ( oDlg:Result == 1 )
			oWin := SELF
			// Not Supported any more
			//DIBSetResizeCallBack( SELF:oImg:pDibObject, @FabResizeCallBack() )
			SELF:oImg:ResizeBilinear( Val(oDlg:oDCValue1:TEXTValue),Val(oDlg:oDCValue2:TEXTValue))
			// Force Refresh
			InvalidateRect( SELF:Handle(), NULL, TRUE )
		ENDIF		
		//
	ENDIF	
return self

METHOD ImgRBox() 
	LOCAL oDlg	AS	InputBox
	//
	IF ( SELF:oImg:IsValid )
		//
		oDlg := InputBox{ SELF }
		oDlg:oDCValue1Txt:Caption := "XSize"
		oDlg:oDCValue2Txt:Caption := "YSize"
		oDlg:oDCValue3Txt:Caption := "Radius"
		oDlg:oDCValue4Txt:Hide()
		oDlg:oDCValue4:Hide()
		oDlg:oDCValue1:TextValue := NTrim( SELF:oImg:Width )
		oDlg:oDCValue2:TextValue := NTrim( SELF:oImg:Height )
		oDlg:oDCValue3:TextValue := NTrim( 1 )
		//
		oDlg:Show()
		IF ( oDlg:Result == 1 )
			SELF:oImg:ResizeBox( Val(oDlg:oDCValue1:TEXTValue),Val(oDlg:oDCValue2:TEXTValue),Val(oDlg:oDCValue3:TEXTValue))
			// Force Refresh
			InvalidateRect( SELF:Handle(), NULL, TRUE )
		ENDIF		
		//
	ENDIF	
return self

METHOD ImgRGauss() 
	LOCAL oDlg	AS	InputBox
	//
	IF ( SELF:oImg:IsValid )
		//
		oDlg := InputBox{ SELF }
		oDlg:oDCValue1Txt:Caption := "XSize"
		oDlg:oDCValue2Txt:Caption := "YSize"
		oDlg:oDCValue3Txt:Caption := "Radius"
		oDlg:oDCValue4Txt:Hide()
		oDlg:oDCValue4:Hide()
		oDlg:oDCValue1:TextValue := NTrim( SELF:oImg:Width )
		oDlg:oDCValue2:TextValue := NTrim( SELF:oImg:Height )
		oDlg:oDCValue3:TextValue := NTrim( 1 )
		//
		oDlg:Show()
		IF ( oDlg:Result == 1 )
			SELF:oImg:ResizeGaussian( Val(oDlg:oDCValue1:TEXTValue),Val(oDlg:oDCValue2:TEXTValue),Val(oDlg:oDCValue3:TEXTValue))
			// Force Refresh
			InvalidateRect( SELF:Handle(), NULL, TRUE )
		ENDIF		
		//
	ENDIF	
return self

METHOD ImgRHamming() 
	LOCAL oDlg	AS	InputBox
	//
	IF ( SELF:oImg:IsValid )
		//
		oDlg := InputBox{ SELF }
		oDlg:oDCValue1Txt:Caption := "XSize"
		oDlg:oDCValue2Txt:Caption := "YSize"
		oDlg:oDCValue3Txt:Caption := "Radius"
		oDlg:oDCValue4Txt:Hide()
		oDlg:oDCValue4:Hide()
		oDlg:oDCValue1:TextValue := NTrim( SELF:oImg:Width )
		oDlg:oDCValue2:TextValue := NTrim( SELF:oImg:Height )
		oDlg:oDCValue3:TextValue := NTrim( 1 )
		//
		oDlg:Show()
		IF ( oDlg:Result == 1 )
			SELF:oImg:ResizeHamming( Val(oDlg:oDCValue1:TEXTValue),Val(oDlg:oDCValue2:TEXTValue),Val(oDlg:oDCValue3:TEXTValue))
			// Force Refresh
			InvalidateRect( SELF:Handle(), NULL, TRUE )
		ENDIF		
		//
	ENDIF	
return self				

METHOD ImgRotate() 
	LOCAL oDlg	AS	InputBox
	LOCAL Deg	AS	REAL8
	//
	IF ( SELF:oImg:IsValid )
		//
		oDlg := InputBox{ SELF }
		oDlg:oDCValue1Txt:Caption := "Angle °"
		oDlg:oDCValue2Txt:Hide()
		oDlg:oDCValue2:Hide()
		oDlg:oDCValue3Txt:Hide()
		oDlg:oDCValue3:Hide()
		oDlg:oDCValue4Txt:Hide()
		oDlg:oDCValue4:Hide()
		oDlg:oDCValue1:TextValue := NTrim( 0 )
		//
		oDlg:Show()
		IF ( oDlg:Result == 1 )
			//
			Deg := Val(oDlg:oDCValue1:TEXTValue)
			// Fill background with Black == RGB(0,0,0)
			self:oImg:RotateDeg( Deg , System.Drawing.Color.FromArgb(255,255,255) )
			// Force Refresh
			InvalidateRect( SELF:Handle(), NULL, TRUE )
		ENDIF		
		//
	ENDIF	
return self

CONSTRUCTOR(oParentWindow, cFileName, oCpyImg ) 
	LOCAL cCaption 	AS STRING
	LOCAL oDlg		AS	Progress
	//
	SUPER(oParentWindow, TRUE)
	//
	SELF:oDCImg := FabPaintLibCtrl{ SELF, 2032, Point{0,0}, Dimension{0,0} }
	SELF:oDCImg:WantScrollBar := TRUE
	SELF:oDCImg:Zoom := 1
	SELF:oDCImg:Show()
	//	Le menu sans ToolBar
	SELF:Menu := ImgViewMenu{SELF}
	SELF:Icon := ICO_IMAGE{}
	//	
	cCaption  := "Image File: "
	//	
	IF IsNil( oCpyImg )
		IF File(cFileName)
			SELF:cFile := cFileName
			oDlg := Progress{ SELF }
			oDlg:Show()
			ApplicationExec( EXECWHILEEVENT )
			// Not Supported anymore
			// DIBSetProgressControl( oDlg:oDCProgressBar1:Handle() )
			//
			SELF:oImg := FabPaintLib{ (string) cFileName }
			// Not Supported anymore
			// DIBSetProgressControl( NULL_PTR )
			oDlg:Destroy()
		ENDIF
	ELSEIF IsInstanceOf( oCpyImg, #FabPaintLib )
		SELF:oImg := oCpyImg
		SELF:cFile := cFileName
	ENDIF
	//		
	SELF:Caption := cCaption + cFileName
	SELF:oDCImg:Image := SELF:oImg
	//
return 

METHOD QueryClose() 
	//
	SELF:Owner:ChildClosing()
	//
RETURN TRUE

METHOD Refresh() 
	LOCAL cr		IS _WINRECT
	LOCAL wr		IS _WINRECT
	LOCAL hWnd		AS	PTR
	LOCAL w,h AS LONG
	//
	hWnd := SELF:Handle()
	//
	GetWindowRect(hWnd, @wr)
	GetClientRect(hWnd, @cr)
	SELF:cx := wr:right  - wr:left - cr:right
	SELF:cy := wr:bottom - wr:top  - cr:bottom
	//
	w := Min( cr:right - cr:left, SELF:oDCImg:ImageWidth )
	h := Min( cr:bottom-cr:top, SELF:oDCImg:ImageHeight )
	//
	SetWindowPos( SELF:oDCImg:Handle(), NULL_PTR, 0,0,w,h, _or(SWP_SHOWWINDOW, SWP_NOZORDER	) )
	SELF:oDCImg:Zoom := SELF:oDCImg:Zoom
	//
return self	

METHOD RefreshInfo() 
	LOCAL nHeight 	AS INT
	LOCAL nWidth  	AS INT
	LOCAL nBPP		AS INT
	//
	nHeight := (LONG)SELF:oImg:Height
	nWidth  := (LONG)SELF:oImg:Width
	nBpp := SELF:oImg:BitPerPixel
	//
	SELF:Owner:StatusBar:SetText( NTrim(nWidth)+"x"+NTrim(nHeight)+","+NTrim(nBpp)+"bpp", #Info )
	//
return self	

METHOD Resize(oResizeEvent) 
	SUPER:Resize(oResizeEvent)
	//Put your changes here
	IF ( SELF:oDCImg != NULL_OBJECT )
		//SendMessage( SELF:oDCImg:Handle(), WM_SIZE, oResizeEvent:wParam, oResizeEvent:lParam)
		SendMessage( self:oDCImg:Handle(), WM_SIZE, oResizeEvent:Width, oResizeEvent:height)
	ENDIF
	//
RETURN NIL
		

METHOD SaveAs	()	
	LOCAL oDlg 	AS 	SaveAsDialog
	LOCAL aExt  AS 	ARRAY
	LOCAL aDesc	AS 	ARRAY
	LOCAL cExt	AS	STRING
	//
	aExt  := {"*.bmp;*.jpg;*.pcx;*.tga;*.tif;*.png;*.pct;*.dib",;
              "*.*",;
              "*.bmp",;
			  "*.jpg",;
			  "*.tif",;
			  "*.png",;
              "*.dib"}
			
	aDesc := {"All Pictures",;
              "All files",;
			  "BMP - OS/2 or Windows Bitmap",;
			  "JPG - JPEG - JFIF Compliant",;
			  "TIF - Tagged Image File Format",;
			  "PNG - Portable Network Graphics",;
			  "DIB - OS/2 or Windows DIB"}
	//			
	oDlg := SaveAsDialog{SELF, aExt[3]}
	oDlg:SetFilter(aExt, aDesc, 3)
	oDlg:Show()
	//
	IF !Empty( oDlg:FileName)
		cExt := Upper(FabExtractFileExt( oDlg:FileName ))
		IF ( cExt == ".JPG" )
			SELF:oImg:SaveAsJPEG( oDlg:FileName )
		ELSEIF ( cExt == ".JPEG" )
			SELF:oImg:SaveAsJPEG( oDlg:FileName )
		ELSEIF ( cExt == ".TIF" )
			SELF:oImg:SaveAsTIFFEx( oDlg:FileName, COMPRESSION_JPEG )
		ELSEIF ( cExt == ".PNG" )
			SELF:oImg:SaveAsPNG( oDlg:FileName )
		ELSE
			SELF:oImg:SaveAs( oDlg:FileName )
		ENDIF
	ENDIF
return self

METHOD Show( kShowState ) 
	//
	SUPER:Show( kShowState )
	//
	SELF:Refresh()
return self

METHOD ZoomIn( ) 
	SELF:oDCImg:Zoom := SELF:oDCImg:Zoom + 1
	IF ( SELF:oDCImg:Zoom == 0 ) .OR. ( SELF:oDCImg:Zoom == -1 )
		SELF:oDCImg:Zoom := 1
	ENDIF	    
return self	

METHOD ZoomOut( ) 
	SELF:oDCImg:Zoom := SELF:oDCImg:Zoom - 1
	IF ( SELF:oDCImg:Zoom == 1 ) .OR. ( SELF:oDCImg:Zoom == 0 )
		SELF:oDCImg:Zoom := -1
	ENDIF
return self
END CLASS

FUNCTION FabResizeCallBack( bPercentComplete AS BYTE ) AS LOGIC STRICT
	// Continue, please....
	oWin:Caption := Str( bPercentComplete )
	// Return FALSE to cancel resize
RETURN TRUE

GLOBAL oWin AS window

