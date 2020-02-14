USING VO
#include "Open Dialog.vh"
using FabPaintLib


STATIC DEFINE TESTDLG_STC32 := 100
STATIC DEFINE TESTDLG_PREVIEW := 101
STATIC DEFINE TESTDLG_PICTURE := 102
CLASS	MyFabOpenDialog		INHERIT	FabOpenDialog
	//
	PROTECT pDib	AS	FabPaintLib
	//
	PROTECT ImgX, ImgY, ImgW, ImgH AS LONG


METHOD	Dispatch( oEvent, hDlg ) 
	LOCAL NMHDR		AS	_winNMHDR
	LOCAL cFile		AS	STRING
	LOCAL pBuffer	AS	PTR
	// If the message is a Click on Help ?
	IF ( oEvent:Message == WM_NOTIFY )
		NMHDR := PTR( _CAST, oEvent:lParam )
		IF ( NMHDR:_code == DWORD(CDN_SELCHANGE) )
			// Selected File Change !!
			pBuffer := MemAlloc( MAX_PATH )
			CommDlg_OpenSave_GetFilePath( GetParent( hDlg) , long(_cast,pBuffer), MAX_PATH )
			cFile := Psz2String( pBuffer )
			MemFree( pBuffer )
			// pmg
			// Stops a Crash when moving between directories.
			IF !File(cFile)
				RETURN 0l
			ENDIF
			//
			IF SELF:PreviewChecked( hDlg )
				SELF:SetPreviewImg( cFile )
			ENDIF
			SELF:ShowPreview( hDlg )
		ENDIF
	ELSEIF ( oEvent:Message == WM_PAINT )
		//
		SELF:ShowPreview( hDlg )
	ENDIF

return self

PROTECT METHOD EndInitDlg( oEvent, hDlg )	
	//
	SELF:InitImgViewer( hDlg )
	//
	SELF:PreviewCheck( hDlg, TRUE )
	//
 return self

CONSTRUCTOR( oOwner ) 
	//
	SUPER( oOwner )
	//
	SELF:SetFilter( { "*.bmp;*.dib;*.rle", "*.jpg;*.jpeg;*.jif", "*.png", "*.pct",;
					"*.tif;*.eps", "*.tga", "*.wmf", "*.emf", "*.pcx", "*.pgm", "*.gif", ;
					"*.bmp;*.dib;*.rle;*.jpg;*.jpeg;*.jif;*.png;*.pct;*.tif;*.eps;*.tga;*.wmf;*.emf;*.pcx;*.pgm", "*.*" }, ;
					{ "BMP file", "JPEG file","PNG file","PICT file",;
					"TIFF file","TARGA file","Windows Metafile","Windows Enhanced Metafile","PCX file","Portable Greymap File","GIF file",;
					"All supported graphic formats", "All Files" }, 11 )
	//
	SELF:OkText := "Open"
	//
	SELF:cDefFile := CHR(0)
	//
	SELF:ResourceDLG := ResourceID{"TestDlg",_GetInst()}
return 

METHOD InitImgViewer( hDlg ) 
	LOCAL hCtrl AS PTR
	LOCAL pRect IS _winRect
	LOCAL pPt	IS _winPoint
	// Retrieve the hControl
	hCtrl := GetDlgItem( hDlg, TESTDLG_PICTURE )
	//
	GetWindowRect( hCtrl, @pRect )
	//
	pPt:X := pRect:Left
	pPt:Y := pRect:Top
	//
	ScreenToClient( hDlg, @pPt )
	//
	SELF:ImgX := pPt:X
	SELF:ImgY := pPt:Y
	//
	GetClientRect( hCtrl, @pRect )
	SELF:ImgH := pRect:Bottom
	SELF:ImgW := pRect:Right
	// Hide Static Text
	ShowWindow( hCtrl, SW_HIDE )
	//
return self	
	

METHOD PreviewCheck( hDlg, lSet ) 
	LOCAL hCtrl AS PTR
	// Retrieve the hControl
	Default( @lSet, TRUE )
	hCtrl := GetDlgItem( hDlg, TESTDLG_PREVIEW )
	SendMessage( hCtrl, BM_SETCHECK, DWORD( _CAST, lSet) , 0 )
	//
return self

METHOD PreviewChecked( hDlg ) 
	LOCAL hCtrl AS PTR
	LOCAL lChecked AS LOGIC
	//
	hCtrl := GetDlgItem( hDlg, TESTDLG_PREVIEW )
	lChecked := ( SendMessage( hCtrl, BM_GETCHECK, 0, 0 ) == BST_CHECKED )
	//
RETURN lChecked

METHOD SetPreviewImg( cFile ) 
	//
	IF File(cfile)   // Pmg
		SELF:pDib := FabPaintLib{ (String)cFile }
	ENDIF
return self

METHOD ShowPreview( hDlg ) 
	LOCAL Factor	AS	REAL8
	LOCAL rx, ry	AS	REAL8
	LOCAL pBMI		AS	_winBITMAPINFO
	LOCAL Width, Height	AS	LONG
	LOCAL dwClr		AS	DWORD
	LOCAL hDC		AS	PTR
	LOCAL pRect		IS _winRect
	//
	hDC := GetDC( hDlg )
	SetRect( @pRect, SELF:ImgX -1, SELF:ImgY -1, SELF:ImgX + SELF:ImgW + 1, SELF:ImgY + SELF:ImgH + 1 )
	IF ( SELF:pDib != NULL_OBJECT ) .AND. SELF:PreviewChecked( hDlg )
		dwClr := (DWORD)COLOR_3DFACE
	ELSE
		dwClr := (DWORD)COLOR_3DSHADOW
	ENDIF
	FillRect( hDC, @pRect, PTR(_CAST, dwClr+1 ) )
	ReleaseDC( hDlg, hDC )
	//
	IF ( SELF:pDib != NULL_OBJECT ) .AND. SELF:PreviewChecked( hDlg )
		//
		Width := SELF:ImgW
		Height := SELF:ImgH
		//
		pBMI := SELF:pDIB:Info
		//
		Factor := 1
		//
		IF ( pBMI:bmiHeader:biWidth > Width ) .OR. ( pBMI:bmiHeader:biHeight > Height )
			// doesn't fit, need to scale
			rx := REAL8( pBMI:bmiHeader:biWidth ) / REAL8( Width )
			ry := REAL8(  pBMI:bmiHeader:biHeight ) / REAL8( Height )
			Factor := 1.0 / Max( rx, ry )
		ENDIF
		//
		Width := LONG( Factor * pBMI:bmiHeader:biWidth )
		Height := LONG( Factor * pBMI:bmiHeader:biHeight )
		//
		Self:pDib:StretchDraw( hDlg, SELF:ImgX, SELF:ImgY, Width, Height )
		//
	ENDIF	
return self
END CLASS

PARTIAL CLASS TestDlg INHERIT DIALOGWINDOW
	PROTECT oDCPreview AS CHECKBOX
	PROTECT oDCPicture AS FIXEDTEXT

	// {{%UC%}} User code starts here (DO NOT remove this line)  

CONSTRUCTOR(oParent,uExtra)

	SELF:PreInit(oParent,uExtra)

	SUPER(oParent , ResourceID{"TestDlg" , _GetInst()} , FALSE)

	SELF:oDCPreview := CHECKBOX{SELF , ResourceID{ TESTDLG_PREVIEW  , _GetInst() } }
	SELF:oDCPreview:HyperLabel := HyperLabel{#Preview , "Preview" , NULL_STRING , NULL_STRING}

	SELF:oDCPicture := FIXEDTEXT{SELF , ResourceID{ TESTDLG_PICTURE  , _GetInst() } }
	SELF:oDCPicture:HyperLabel := HyperLabel{#Picture , "Fixed Text" , NULL_STRING , NULL_STRING}

	SELF:Caption := "Dialog Caption"
	SELF:HyperLabel := HyperLabel{#TestDlg , "Dialog Caption" , NULL_STRING , NULL_STRING}

	SELF:PostInit(oParent,uExtra)

RETURN


END CLASS

/* TEXTBLOCK ! Read Me
/-*
The Resource was designed with WED, in TabPage mode ( No border, Control, Child )
A FixedText has been placed right-most, it has the ID 0x045f ( Manually changed ).

If you don't have MSDN :
In this case, the system uses the control as the point of reference for determining where to position the new controls.
All new controls above and to the left of the stc32 control are positioned the same amount above and to the left of the
controls in the default dialog box. New controls below and to the right of the stc32 control are positioned below and
to the right of the default controls. In general, each new control is positioned so that it has the same position
relative to the default controls as it had to the stc32 control. To make room for these new controls, the system adds
space to the left, right, bottom, and top of the default dialog box as needed.


*-/

*/
