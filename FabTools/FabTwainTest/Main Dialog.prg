USING FabPaintLib.Control
Using FabPaintLib

#region DEFINES
STATIC DEFINE MAINDIALOG_CLOSEPB := 104
STATIC DEFINE MAINDIALOG_CURRENTTXT := 114
STATIC DEFINE MAINDIALOG_DELPB := 107
STATIC DEFINE MAINDIALOG_FITCHK := 108
STATIC DEFINE MAINDIALOG_FIXEDTEXT1 := 115
STATIC DEFINE MAINDIALOG_FIXEDTEXT2 := 122
STATIC DEFINE MAINDIALOG_FORMATPAGE := 128
STATIC DEFINE MAINDIALOG_GROUPBOX1 := 113
STATIC DEFINE MAINDIALOG_HIDEERROR := 110
STATIC DEFINE MAINDIALOG_HIDEUI := 109
STATIC DEFINE MAINDIALOG_IMGBOX := 116
STATIC DEFINE MAINDIALOG_NEXTPB := 105
STATIC DEFINE MAINDIALOG_PIXTYPE := 111
STATIC DEFINE MAINDIALOG_PREVPB := 106
STATIC DEFINE MAINDIALOG_PRINTBOX := 123
STATIC DEFINE MAINDIALOG_PRINTFIT := 103
STATIC DEFINE MAINDIALOG_PRINTGDI := 127
STATIC DEFINE MAINDIALOG_PRINTPB := 102
STATIC DEFINE MAINDIALOG_PRINTQTY := 120
STATIC DEFINE MAINDIALOG_PRINTQTYSPINNER := 121
STATIC DEFINE MAINDIALOG_RESOLUTION := 119
STATIC DEFINE MAINDIALOG_RESOLUTIONSPINNER := 118
STATIC DEFINE MAINDIALOG_SAVEPB := 101
STATIC DEFINE MAINDIALOG_SCANPB := 100
STATIC DEFINE MAINDIALOG_TWAINIMG := 112
STATIC DEFINE MAINDIALOG_VIEWBOX := 117
STATIC DEFINE MAINDIALOG_ZOOMLESS := 124
STATIC DEFINE MAINDIALOG_ZOOMMORE := 126
STATIC DEFINE MAINDIALOG_ZOOMNORMAL := 125
#endregion

CLASS MainDialog INHERIT DIALOGWINDOW

	protect oCCScanPB as PUSHBUTTON
	protect oCCSavePB as PUSHBUTTON
	protect oCCPrintPB as PUSHBUTTON
	protect oDCPrintFit as CHECKBOX
	protect oCCClosePB as PUSHBUTTON
	protect oCCNextPB as PUSHBUTTON
	protect oCCPrevPB as PUSHBUTTON
	protect oCCDelPB as PUSHBUTTON
	protect oDCFitChk as CHECKBOX
	protect oDCHideUI as CHECKBOX
	protect oDCHideError as CHECKBOX
	protect oDCPixType as COMBOBOX
	protect oDCTwainImg as FABPAINTLIBCTRL
	protect oDCCurrentTxt as FIXEDTEXT
	protect oDCViewBox as GROUPBOX
	protect oDCResolutionSpinner as VERTICALSPINNER
	protect oDCResolution as SINGLELINEEDIT
	protect oDCPrintQty as SINGLELINEEDIT
	protect oDCPrintQtySpinner as VERTICALSPINNER
	protect oCCZoomLess as PUSHBUTTON
	protect oCCZoomNormal as PUSHBUTTON
	protect oCCZoomMore as PUSHBUTTON
	protect oDCPrintGDI as CHECKBOX
	protect oDCFormatPage as COMBOBOX

  //{{%UC%}} USER CODE STARTS HERE (do NOT remove this line)
  	PROTECT oTwain			AS	FabTwain
  	PROTECT lHideError		AS	LOGIC
  	PROTECT aImg			AS	ARRAY
  	PROTECT nImg			AS	DWORD
  	PROTECT oStatusBar		AS	StatusBar
	PROTECT oPrinter		AS	PrintingDevice


METHOD _ResizeControl()
	LOCAL oBB	AS	BoundingBox
	LOCAL oSize	AS	Dimension
	//
	oBB := SELF:CanvasArea
	IF ( SELF:oStatusBar != NULL_OBJECT )  .AND. ( SELF:oStatusBar:Handle() != NULL_PTR )
		//
		SELF:oStatusBar:Origin := Point{0,0}
		oSize := SELF:oStatusBar:Size
		oSize:Width := oBB:Width
		SELF:oStatusBar:Size := oSize
		//
	ENDIF
	//
return self

METHOD ButtonClick(oControlEvent)
	LOCAL oControl AS Control
	oControl := IIf(oControlEvent == NULL_OBJECT, NULL_OBJECT, oControlEvent:Control)
	SUPER:ButtonClick(oControlEvent)
	//Put your changes here
	IF ( oControl != NULL_OBJECT )
		IF ( oControl:NameSym == #FitChk )
			//
			SELF:Zoom( !SELF:oDCFitChk:Checked )
			SELF:oDCTwainImg:ImageFit := SELF:oDCFitChk:Checked
			//
		ELSEIF ( oControl:NameSym == #HideUI )
			SELF:oTwain:ShowUI := !SELF:oDCHideUI:Checked
		ELSEIF ( oControl:NameSym == #HideError )
			// Hide Twain Error
			SELF:lHideError := SELF:oDCHideError:Checked
			// Hide FabPaint Errors
			CAPaintShowErrors( !SELF:oDCHideError:Checked )
		ENDIF
	ENDIF
	//
	RETURN NIL


METHOD ClosePB( )
	SELF:EndDialog()
return self

METHOD DelPB( )
	//
	SELF:ImageDel()
	//
return self

METHOD	FillFormatPage( )
RETURN { {"None", 0 }, { "A4", 1 }, { "A5", 2 }, { "A5 Landscape", 3 }, { "B5", 4 }, {"Legal", 5}, {"Letter",6}, { "Executive",7} }


METHOD	FillPixelType( )
RETURN { {"None", -1 }, { "B/W", TWPT_BW }, { "Gray", TWPT_GRAY }, { "RGB", TWPT_RGB }, {"Palette", TWPT_PALETTE} }


METHOD HelpAbout( )
	LOCAL oDlg	AS	AboutDlg
	//
	oDlg := AboutDlg{ SELF }
	oDlg:Show()
	//
RETURN SELF

METHOD ImageAdd( oImg )
	//
	AAdd( SELF:aImg, oImg )
	//
	SELF:nImg := ALen( SELF:aImg )
	//
	SELF:ImageUpdate()
	//
RETURN SELF

METHOD ImageDel()
	LOCAL oImg	AS	FabPaintLib
	//
	IF ( SELF:nImg > 0 )
		//
		oImg := SELF:aImg[ SELF:nImg ]
		oImg:Destroy()
		//
		ADel( SELF:aImg, SELF:nImg )
		ASize( SELF:aImg, ALen( SELF:aImg ) - 1 )
		//
		IF ( SELF:nImg > ALen( SELF:aImg ) )
			SELF:nImg := ALen( SELF:aImg )
		ENDIF
		//
		SELF:ImageUpdate()
	ENDIF
	//
return self

METHOD ImageNext()
	//
	IF ( SELF:nImg < ALen( SELF:aImg ) )
		SELF:nImg := SELF:nImg + 1
	ENDIF
	//
	SELF:ImageUpdate()
	//
return self

METHOD ImagePrev()
	//
	IF ( SELF:nImg > 1 )
		SELF:nImg := SELF:nImg - 1
	ENDIF
	//
	SELF:ImageUpdate()
	//
RETURN SELF

METHOD ImageUpdate()
	LOCAL oImg	AS	FabPaintLib
	//
	SELF:oDCCurrentTxt:TextValue := NTrim( SELF:nImg ) + " / " + NTrim( ALen(SELF:aImg) )
	//
	IF ( SELF:nImg > 0 )
		oImg := SELF:aImg[ SELF:nImg ]
	ENDIF
	//
	SELF:oDCTwainImg:Image := oImg
	//
return self

CONSTRUCTOR(oParent,uExtra)

self:PreInit(oParent,uExtra)

SUPER(oParent,ResourceID{"MainDialog",_GetInst()},TRUE)

oCCScanPB := PushButton{self,ResourceID{MAINDIALOG_SCANPB,_GetInst()}}
oCCScanPB:HyperLabel := HyperLabel{#ScanPB,_chr(38)+"Scan",NULL_STRING,NULL_STRING}

oCCSavePB := PushButton{self,ResourceID{MAINDIALOG_SAVEPB,_GetInst()}}
oCCSavePB:HyperLabel := HyperLabel{#SavePB,_chr(38)+"Save",NULL_STRING,NULL_STRING}

oCCPrintPB := PushButton{self,ResourceID{MAINDIALOG_PRINTPB,_GetInst()}}
oCCPrintPB:HyperLabel := HyperLabel{#PrintPB,"Print",NULL_STRING,NULL_STRING}

oDCPrintFit := CheckBox{self,ResourceID{MAINDIALOG_PRINTFIT,_GetInst()}}
oDCPrintFit:HyperLabel := HyperLabel{#PrintFit,"Fit to Page",NULL_STRING,NULL_STRING}

oCCClosePB := PushButton{self,ResourceID{MAINDIALOG_CLOSEPB,_GetInst()}}
oCCClosePB:HyperLabel := HyperLabel{#ClosePB,_chr(38)+"Close",NULL_STRING,NULL_STRING}

oCCNextPB := PushButton{self,ResourceID{MAINDIALOG_NEXTPB,_GetInst()}}
oCCNextPB:HyperLabel := HyperLabel{#NextPB,"Next",NULL_STRING,NULL_STRING}

oCCPrevPB := PushButton{self,ResourceID{MAINDIALOG_PREVPB,_GetInst()}}
oCCPrevPB:HyperLabel := HyperLabel{#PrevPB,"Previous",NULL_STRING,NULL_STRING}

oCCDelPB := PushButton{self,ResourceID{MAINDIALOG_DELPB,_GetInst()}}
oCCDelPB:HyperLabel := HyperLabel{#DelPB,"Del",NULL_STRING,NULL_STRING}

oDCFitChk := CheckBox{self,ResourceID{MAINDIALOG_FITCHK,_GetInst()}}
oDCFitChk:HyperLabel := HyperLabel{#FitChk,"Fit to Window",NULL_STRING,NULL_STRING}

oDCHideUI := CheckBox{self,ResourceID{MAINDIALOG_HIDEUI,_GetInst()}}
oDCHideUI:HyperLabel := HyperLabel{#HideUI,"Hide UI",NULL_STRING,NULL_STRING}

oDCHideError := CheckBox{self,ResourceID{MAINDIALOG_HIDEERROR,_GetInst()}}
oDCHideError:HyperLabel := HyperLabel{#HideError,"Hide Errors",NULL_STRING,NULL_STRING}

oDCPixType := combobox{self,ResourceID{MAINDIALOG_PIXTYPE,_GetInst()}}
oDCPixType:HyperLabel := HyperLabel{#PixType,NULL_STRING,NULL_STRING,NULL_STRING}
oDCPixType:FillUsing(Self:FillPixelType( ))

oDCTwainImg := FabPaintLibCtrl{self,ResourceID{MAINDIALOG_TWAINIMG,_GetInst()}}
oDCTwainImg:HyperLabel := HyperLabel{#TwainImg,"Scan Image",NULL_STRING,NULL_STRING}
oDCTwainImg:ContextMenu := TwainContext{}

oDCCurrentTxt := FixedText{self,ResourceID{MAINDIALOG_CURRENTTXT,_GetInst()}}
oDCCurrentTxt:HyperLabel := HyperLabel{#CurrentTxt,"Current",NULL_STRING,NULL_STRING}

oDCViewBox := GroupBox{self,ResourceID{MAINDIALOG_VIEWBOX,_GetInst()}}
oDCViewBox:HyperLabel := HyperLabel{#ViewBox,"View",NULL_STRING,NULL_STRING}

oDCResolutionSpinner := VerticalSpinner{self,ResourceID{MAINDIALOG_RESOLUTIONSPINNER,_GetInst()}}
oDCResolutionSpinner:Range := Range{0,300}
oDCResolutionSpinner:HyperLabel := HyperLabel{#ResolutionSpinner,NULL_STRING,NULL_STRING,NULL_STRING}

oDCResolution := SingleLineEdit{self,ResourceID{MAINDIALOG_RESOLUTION,_GetInst()}}
oDCResolution:HyperLabel := HyperLabel{#Resolution,NULL_STRING,NULL_STRING,NULL_STRING}
oDCResolution:TooltipText := "DPI"

oDCPrintQty := SingleLineEdit{self,ResourceID{MAINDIALOG_PRINTQTY,_GetInst()}}
oDCPrintQty:HyperLabel := HyperLabel{#PrintQty,NULL_STRING,NULL_STRING,NULL_STRING}

oDCPrintQtySpinner := VerticalSpinner{self,ResourceID{MAINDIALOG_PRINTQTYSPINNER,_GetInst()}}
oDCPrintQtySpinner:Range := Range{1,10}
oDCPrintQtySpinner:HyperLabel := HyperLabel{#PrintQtySpinner,NULL_STRING,NULL_STRING,NULL_STRING}

oCCZoomLess := PushButton{self,ResourceID{MAINDIALOG_ZOOMLESS,_GetInst()}}
oCCZoomLess:HyperLabel := HyperLabel{#ZoomLess,"-",NULL_STRING,NULL_STRING}

oCCZoomNormal := PushButton{self,ResourceID{MAINDIALOG_ZOOMNORMAL,_GetInst()}}
oCCZoomNormal:HyperLabel := HyperLabel{#ZoomNormal,"Normal",NULL_STRING,NULL_STRING}

oCCZoomMore := PushButton{self,ResourceID{MAINDIALOG_ZOOMMORE,_GetInst()}}
oCCZoomMore:HyperLabel := HyperLabel{#ZoomMore,"+",NULL_STRING,NULL_STRING}

oDCPrintGDI := CheckBox{self,ResourceID{MAINDIALOG_PRINTGDI,_GetInst()}}
oDCPrintGDI:HyperLabel := HyperLabel{#PrintGDI,"Use GDI Mode",NULL_STRING,NULL_STRING}

oDCFormatPage := combobox{self,ResourceID{MAINDIALOG_FORMATPAGE,_GetInst()}}
oDCFormatPage:HyperLabel := HyperLabel{#FormatPage,NULL_STRING,NULL_STRING,NULL_STRING}
oDCFormatPage:FillUsing(Self:FillFormatPage( ))

self:Caption := "Fab Twain Test"
self:HyperLabel := HyperLabel{#MainDialog,"Fab Twain Test",NULL_STRING,NULL_STRING}

self:PostInit(oParent,uExtra)

return self


METHOD InitTwain()
	//
	SELF:oTwain := FabTwain{ SELF }
	// Identify our Application for the Source Manager
	SELF:oTwain:RegisterApp( 1,0,TWLG_FRN,TWCY_FRANCE, "1.0", "Fabrice Foray", "FabTwain", "Fab Twain Test" )
return self

METHOD MenuCommand(oMenuCommandEvent)
	LOCAL	nZoomIn		AS	SHORT
	LOCAL	nZoomOut	AS	SHORT
	//
	SUPER:MenuCommand(oMenuCommandEvent)
	//Put your changes here
	// Zoom Menu ?
	IF ( "/" $ oMenuCommandEvent:AsString() )
		//
		nZoomIn := Val( SubStr( oMenuCommandEvent:AsString(), 1, 1 ) )
		nZoomOut := Val( SubStr( oMenuCommandEvent:AsString(), 5, 1 ) )
		//
		IF ( nZoomOut == 1 )
			SELF:oDCTwainImg:Zoom := nZoomIn
		ELSE
			SELF:oDCTwainImg:Zoom := nZoomOut * -1
		ENDIF
		//
	ENDIF
RETURN NIL


METHOD NextPB( )
	//
	SELF:ImageNext()
	//
return self

METHOD OnTwainDibAcquire( hDIB )
	LOCAL oImg	AS	FabPaintLib
	//
	oImg := FabPaintLib{}
	oImg:CreateFromHDib( hDIB )
	//
	SELF:ImageAdd( oImg )
	//
	GlobalFree( hDIB )
	//
return self

METHOD OnTwainError( dwError )
	LOCAL oDlg		AS	ErrorBox
	LOCAL cError	AS	STRING
	//
	IF !SELF:lHideError
		DO CASE
			CASE ( dwError == TWERR_OPEN_DSM )
				cError := "Unable to load or open Source Manager"
			CASE ( dwError == TWERR_OPEN_SOURCE	)
				cError := "Unable to open Datasource"
			CASE ( dwError == TWERR_ENABLE_SOURCE )
				cError := "Unable to enable Datasource"
			CASE ( dwError == TWERR_NOT_4 )
				cError := "Capability set outside state 4 (SOURCE_OPEN)"
			CASE ( dwError == TWERR_CAP_SET )
				cError := "Capability set failed"
			CASE ( dwError == TWERR_GLOBALALLOC	)
				cError := "Cannot allocate memory in SetCapOneValue"
			CASE ( dwError == TWERR_LOCKMEMORY )
				cError := "Error Locking bitmap into memory"
			CASE ( dwError == TWERR_CREATEFILE )
				cError := "Error creating file"
			OTHERWISE
				cError := "!! Unknown Error !!"
		ENDCASE
		//
		oDlg := ErrorBox{ SELF, cError }
		oDlg:Show()
		//
	ENDIF
	//
RETURN SELF

METHOD OnTwainSourceOpen()
	LOCAL l,t,w,h	AS	REAL8
	LOCAL u 		AS WORD
	LOCAL PType		AS WORD
	// We came here as the Source in now in Open State.
	// So now, we can set any capabilities
	// PixelType, PixelDepth, ...
	// Try to Set units as CENTIMETERS....
	SELF:oTwain:CurrentUnits := TWUN_CENTIMETERS
	// Verify
	u := SELF:oTwain:CurrentUnits
	// Sorry I can only accept Inch or Centimeter
	IF ( u != TWUN_CENTIMETERS )  .OR. ( u!= TWUN_INCHES )
		SELF:oTwain:CurrentUnits := TWUN_INCHES
	ENDIF
	// Verify
	u := SELF:oTwain:CurrentUnits
	//
	PType := SELF:oDCFormatPage:Value
	l := 0
	t := 0
	DO CASE
		CASE ( PType == 1 )
			// A4
			w := 21
			h := 29.7
		CASE ( PType == 2 )
			// A5
			w := 14.8
			h := 21
		CASE ( PType == 3 )
			// A5 Landscape
			w := 21
			h := 14.8
		CASE ( PType == 4 )
			w := 18.2
			h := 25.7
		CASE ( PType == 5 )
			w := 21.59
			h := 35.56
		CASE ( PType == 6 )
			w := 21.59
			h := 27.94
		CASE ( PType == 7 )
			w := 18.415
			h := 26.67
		OTHERWISE
			h := SELF:oTwain:PhysicalHeight
			w := SELF:oTwain:PhysicalWidth
	ENDCASE
	IF ( u == TWUN_INCHES )
		w := w / 2.54
		h := h / 2.54
	ELSEIF ( u == TWUN_CENTIMETERS )
		// Nothing to do
        NOP
	ELSE
		// Back to default
		h := SELF:oTwain:PhysicalHeight
		w := SELF:oTwain:PhysicalWidth
	ENDIF
	//
	SELF:oTwain:SetImageLayout( l, t, w, h )
	//
	SELF:oTwain:PixelType := WORD( _CAST, SELF:oDCPixType:Value )
	SELF:oTwain:XResolution := Val( SELF:oDCResolution:TextValue )
	SELF:oTwain:XferCount := 1
	//
return self

METHOD OnTwainStateChange( dwNew )
	//
	SELF:oStatusBar:SetText( "Twain State Change : " + NTrim( dwNew ), #TwainArea )
	//
return self

METHOD PostInit(oWindow,iCtlID,oServer,uExtra)
	//Put your PostInit additions here
	SELF:oPrinter := PrintingDevice{}
	SELF:InitTwain()
	SELF:aImg := {}
	SELF:nImg := 0
	//
	SELF:oStatusBar := StatusBar{ SELF }
	SELF:oStatusBar:Create()
	SELF:oStatusBar:AddItem(StatusBarItem{#MessageArea, , SBITEMSUNKEN })
	SELF:oStatusBar:SetText(NULL_STRING, #MessageArea)
	SELF:oStatusBar:AddItem(StatusBarItem{#TwainArea,250 , SBITEMSUNKEN })
	SELF:oStatusBar:SetText(NULL_STRING, #TwainArea)
	//
	SELF:_ResizeControl()
	//
	SELF:Menu := MainMenu{}
	//
	SELF:oDCHideUI:Checked := FALSE
	SELF:Zoom( FALSE )
	SELF:oDCFitChk:Checked := TRUE
	SELF:oDCTwainImg:ImageFit := TRUE
	CAPaintShowErrors( TRUE )
	//
	SELF:oDCPixType:Value := TWPT_GRAY
	SELF:oDCFormatPage:TextValue := "A4"
	SELF:oDCResolutionSpinner:Client := SELF:oDCResolution
	SELF:oDCResolution:TextValue := "150"
	//
	SELF:oDCPrintQtySpinner:Client := SELF:oDCPrintQty
	SELF:oDCPrintQty:TextValue := "1"
	//
	SELF:ImageUpdate()
	//
	RETURN NIL


METHOD PrevPB( )
	//
	SELF:ImagePrev()
	//
return self

METHOD PrinterSetup()
	//
	SELF:oPrinter:SetUp()
	//
return self

METHOD	PrintPB
	LOCAL oPrn		AS	FabPrinter
	LOCAL oImg		AS	FabPaintLib
	LOCAL oCpyImg	AS	FabPaintLib
	//
	IF ( SELF:nImg == 0 )
		return self
	ENDIF
	// Get the Printer
	oPrn := FabPrinter{ "FabTwain and FabPaintLib Test", SELF:oPrinter }
	//
	oImg := SELF:aImg[ SELF:nImg ]
	oCpyImg := oImg:Copy()
	//
	oPrn:oImg := oCpyImg
	oPrn:FitToWindow := SELF:oDCPrintFit:Checked
	oPrn:UseGDI := SELF:oDCPrintGDI:Checked
	oPrn:Qty := Val( SELF:oDCPrintQty:TextValue )
	oPrn:Start()
	oPrn:Destroy()
	//

  return self

METHOD Resize(oResizeEvent)
	SUPER:Resize(oResizeEvent)
	//Put your changes here
	SELF:_ResizeControl()
RETURN NIL


METHOD SavePB( )
	LOCAL oDlg 	AS 	SaveAsDialog
	LOCAL aExt  AS 	ARRAY
	LOCAL aDesc	AS 	ARRAY
	LOCAL oImg	AS	FabPaintLib
	LOCAL cExt	AS	STRING
	//
	IF ( SELF:nImg == 0 )
		return self
	ENDIF
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
		oImg := SELF:aImg[ SELF:nImg ]
		cExt := Upper(FabExtractFileExt( oDlg:FileName ))
		IF ( cExt == ".JPG" )
			oImg:SaveAsJPEG( oDlg:FileName )
		ELSEIF ( cExt == ".JPEG" )
			oImg:SaveAsJPEG( oDlg:FileName )
		ELSEIF ( cExt == ".TIF" )
			oImg:SaveAsTIFF( oDlg:FileName )
		ELSEIF ( cExt == ".PNG" )
			oImg:SaveAsPNG( oDlg:FileName )
		ELSE
			oImg:SaveAs( oDlg:FileName )
		ENDIF
	ENDIF

return self

METHOD ScanPB( )
	//
	SELF:oTwain:ModalAcquire()
	//
 return self

METHOD SelectSource()
	//
	SELF:oTwain:SelectSource()
	//
return self

METHOD StatusMessage(oHL, ntype)
	LOCAL message AS STRING
	//
	IF ( SELF:oStatusBar == NULL_OBJECT )
		return self
	ENDIF
	//
	DO CASE
		CASE IsInstanceOfUsual(oHL, #HyperLabel)  .and. IsString(oHL:Description)
			message := oHL:Description
		CASE IsString(oHL)
			message := oHL
		OTHERWISE
			message := ""
	ENDCASE
	//
	SELF:oStatusBar:setmessage(message, nType)
	//
return self

METHOD	Zoom( lAllowZoom )
	//
	IF ( lAllowZoom )
		SELF:oCCZoomLess:Enable()
		SELF:oCCZoomNormal:Enable()
		SELF:oCCZoomMore:Enable()
	ELSE
		SELF:oDCTwainImg:Zoom := 1
		SELF:oCCZoomLess:Disable()
		SELF:oCCZoomNormal:Disable()
		SELF:oCCZoomMore:Disable()
	ENDIF
	//
return self

METHOD ZoomLess( )
	//
	IF ( SELF:oDCTwainImg:Zoom == 1 )
		SELF:oDCTwainImg:Zoom := -2
	ELSE
		SELF:oDCTwainImg:Zoom := SELF:oDCTwainImg:Zoom - 1
	ENDIF
	//
return self

METHOD ZoomMore( )
	//
	IF ( SELF:oDCTwainImg:Zoom == -2 )
		SELF:oDCTwainImg:Zoom := 1
	ELSE
		SELF:oDCTwainImg:Zoom := SELF:oDCTwainImg:Zoom + 1
	ENDIF
	//
return self

METHOD ZoomNormal( )
	//
	SELF:oDCTwainImg:Zoom := 1
	//
return self

END CLASS
