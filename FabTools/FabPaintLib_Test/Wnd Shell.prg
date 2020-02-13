#include "VOGUIClasses.vh"
#include "VOSystemLibrary.vh"
#include "VOWin32APILibrary.vh"
#using FabPaintLib

CLASS ImgViewShell INHERIT SHELLWINDOW 


  //{{%UC%}} USER CODE STARTS HERE (do NOT remove this line)
	PROTECT oPrinter      	AS PrintingDevice
	EXPORT  lStretch		AS LOGIC

METHOD AppExit() 	
	//	
	SELF:Close()	
	//
	SELF:EndWindow()
return self

METHOD ChildClosing() 		
	LOCAL aChild	AS ARRAY
	//
	aChild := SELF:GetAllChildren()
	//	
	IF ( ALen(aChild) == 1 )
		// Reset Menu
		SELF:Menu := EmptyShellMenu{}

	ENDIF
return self

METHOD ClipPaste() 
	LOCAL oNew	AS	FabPaintLib
	// Data available ?
	IF IsClipboardFormatAvailable( CF_BITMAP )
		// Create the VO Object
		oNew := FabPaintLib{ }
		// that we destroy and replace by the Clipboard
		oNew:FromClipboard()
		//
		SELF:CopyImg( oNew, "PasteFromClipboard.bmp" )
	ENDIF
	//
return self	

METHOD Close() 		
	LOCAL aChild	AS ARRAY
	LOCAL i			as dword
	//
	aChild := SELF:GetAllChildren()
	
	FOR i := 1 TO ALen(aChild)
		aChild[i]:Close()
	NEXT	

	SUPER:Close()	
return self	

METHOD CopyImg( pCopy, cOrgFileName ) 
	LOCAL oNewChild AS StdImageWindow
	LOCAL cFileName	AS	STRING
	LOCAL nValue	AS	LONG
	//
	nValue := Val( Right( cOrgFileName, 2 ) ) + 1
	cFileName := cOrgFileName + "-" + NTrim( nValue )
	//
	oNewChild := StdImageWindow{ SELF, cFileName, pCopy }
	oNewChild:Show()
return self

METHOD DoOpenFile(cFileName, lReadOnly) 
	LOCAL oNewChild AS StdImageWindow
	//
	oNewChild := StdImageWindow{SELF, cFileName }
	oNewChild:Show()
	//
//	SELF:Menu := ImgViewShellMenu{SELF}
return self

METHOD DoOpenImage( cFileName, oImg ) 
	LOCAL oNewChild AS StdImageWindow
	//
	oNewChild := StdImageWindow{SELF, cFileName, oImg }
	oNewChild:Show()
return self

METHOD DoOpenMultiImage( cFileName, oMultiImg ) 
	LOCAL oNewChild AS MultiImageWindow
	//
	oNewChild := MultiImageWindow{SELF, cFileName, oMultiImg }
	oNewChild:Show()
return self

METHOD Drop(oDragEvent) 
	LOCAL nNumFiles := oDragEvent:FileCount
	LOCAL nFile AS INT
	
	FOR nFile := 1 TO nNumFiles
		IF File(oDragEvent:FileName(nFile))
			SELF:DoOpenFile(oDragEvent:FileName(nFile))
		ENDIF
	NEXT
return self	

METHOD FileOpen() 
	//LOCAL oOD 	AS MyFabOpenDialog
	local oOD   AS OpenDialog
	LOCAL aExt  AS ARRAY
	LOCAL aDesc	AS ARRAY
	LOCAL oMP	AS	FabMultiPage
	LOCAL nPages	AS LONGINT
	LOCAL oDlg	AS	InputBox
	LOCAL nPage AS LONGINT
	LOCAL oImg	AS	FabPaintLib
	LOCAL oYNBox AS Textbox
	//
	aExt  := {"*.bmp;*.jpg;*.pcx;*.tga;*.tif;*.png;*.pct;*.dib;*.gif",;
              "*.*",;
              "*.bmp",;
			  "*.jpg",;
			  "*.pcx",;
			  "*.tga",;
			  "*.tif",;
			  "*.png",;
			  "*.pct",;
              "*.dib",;
			  "*.gif"}
			
	aDesc := {"All Pictures",;
              "All files",;
			  "BMP - OS/2 or Windows Bitmap",;
			  "JPG - JPEG - JFIF Compliant",;
			  "PCX - Zsoft Paintbrush",;
			  "TGA - Truevision Targa",;
			  "TIF - Tagged Image File Format",;
			  "PNG - Portable Network Graphics",;
			  "PCT - Macintosh PICT",;
			  "DIB - OS/2 or Windows DIB",;
			  "GIF - GIF File"}
			
	//oOD := MyFabOpenDialog{SELF, aExt[1]}
	oOD := OpenDialog{ SELF, aExt[1] }
	oOD:SetFilter(aExt, aDesc, 1)

	oOD:Show()
	
	IF !Empty(oOD:FileName)
		// MultiPage File ?
		oMP := FabMultiPage{ (String) oOD:FileName }
		IF oMP:IsValid
			// Try as an animated image ?
			oYNBox := TextBox{ SELF, "Animation", "Play the Multipage image as an animation  ?" }
			oYNBox:Type := BOXICONQUESTIONMARK + BUTTONYESNO
			//
			IF ( oYNBox:Show() == BOXREPLYYES )
				//
				SELF:DoOpenMultiImage(oOD:FileName, oMP )
			ELSE
				// No, open a single frame			
				nPages := oMP:PageCount
				//
				oDlg := InputBox{ SELF }
				oDlg:oDCValue1Txt:Caption := "Page :"
				oDlg:oDCValue2Txt:Caption := "Max=" + NTrim(nPages)
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
					nPage := Val(oDlg:oDCValue1:TEXTValue)
					// WARNING : Page number is zero-based
					oImg := oMP:CloneImage( nPage - 1)
				ENDIF								
				oMP:Destroy()
				IF ( oImg:IsValid )
					SELF:DoOpenImage(oOD:FileName, oImg)
				ENDIF
			ENDIF
		ELSE
			// No, try as a standard file....
			SELF:DoOpenFile(oOD:FileName )
		ENDIF
		//
	ENDIF
return self	

METHOD FilePrinterSetup() 

	oPrinter:Setup()
return self	

METHOD HelpAboutDialog() 
	local oOD as HelpAbout
	
	(oOD := HelpAbout{self}):Show()
return self	

CONSTRUCTOR(oParent,uExtra)  

self:PreInit(oParent,uExtra)

super(oParent,uExtra)

SELF:Caption := "Fab Image Viewer"
SELF:HyperLabel := HyperLabel{#ImgViewShell,"Fab Image Viewer",NULL_STRING,NULL_STRING}
SELF:Menu := EmptyShellMenu{}
SELF:IconSm := ICO_MAIN{}
SELF:Origin := Point{17, 245}
SELF:Size := Dimension{640, 480}

self:PostInit(oParent,uExtra)

return 

METHOD PostInit( oParent, uExtra ) 
	LOCAL oSB AS StatusBar
	//	
	oSB := SELF:EnableStatusBar()
	//
	SELF:oPrinter := PrintingDevice{}
	//
	oSB:AddItem( StatusBarItem{ #Info, 150 } )
	oSB:DisplayTime()
	//
RETURN SELF


ACCESS Printer 
	
	RETURN oPrinter

METHOD WindowCascade() 

	SELF:Arrange(ARRANGECASCADE)
return self

METHOD WindowIcon() 

	SELF:Arrange(ARRANGEASICONS)
return self

METHOD WindowTile() 

	SELF:Arrange(ARRANGETILE)
return self
END CLASS

