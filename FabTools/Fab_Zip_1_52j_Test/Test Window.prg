using FabZip
using VO


STATIC DEFINE FABZIPTEST1_ZIPFILENAME := 100
STATIC DEFINE FABZIPTEST1_OPENPB := 101
STATIC DEFINE FABZIPTEST1_CREATEPB := 102
STATIC DEFINE FABZIPTEST1_PASSCHK := 103
STATIC DEFINE FABZIPTEST1_ADDPB := 104
STATIC DEFINE FABZIPTEST1_EXTRACTPB := 105
STATIC DEFINE FABZIPTEST1_DELETEPB := 106
STATIC DEFINE FABZIPTEST1_CONVERTPB := 107
STATIC DEFINE FABZIPTEST1_COMMENTPB := 108
STATIC DEFINE FABZIPTEST1_OKPB := 109
STATIC DEFINE FABZIPTEST1_ZIP_CONTROL := 110
STATIC DEFINE FABZIPTEST1_ZIPLIST := 111
STATIC DEFINE FABZIPTEST1_DLLMSG := 112
STATIC DEFINE FABZIPTEST1_FABZIPMSG := 113
STATIC DEFINE FABZIPTEST1_GROUPBOX1 := 114
STATIC DEFINE FABZIPTEST1_EXTRACTBAR := 115
STATIC DEFINE FABZIPTEST1_FPROCESS := 116
STATIC DEFINE FABZIPTEST1_CANCELPB := 117
STATIC DEFINE FABZIPTEST1_PROCESSGRP := 118
STATIC DEFINE FABZIPTEST1_TOTALSIZEBAR := 119
STATIC DEFINE FABZIPTEST1_TOTALFILESBAR := 120
STATIC DEFINE FABZIPTEST1_ZIPMESSAGES := 121
PARTIAL CLASS FabZipTest1 INHERIT DATAWINDOW
	PROTECT oDCZipFileName AS SINGLELINEEDIT
	PROTECT oCCOpenPB AS PUSHBUTTON
	PROTECT oCCCreatePB AS PUSHBUTTON
	PROTECT oDCPassChk AS CHECKBOX
	PROTECT oCCAddPB AS PUSHBUTTON
	PROTECT oCCExtractPB AS PUSHBUTTON
	PROTECT oCCDeletePB AS PUSHBUTTON
	PROTECT oCCConvertPB AS PUSHBUTTON
	PROTECT oCCCommentPB AS PUSHBUTTON
	PROTECT oCCOkPB AS PUSHBUTTON
	PROTECT oDCZip_Control AS FABZIPFILECTRL
	PROTECT oDCZipList AS LISTVIEW
	PROTECT oDCDllMsg AS CHECKBOX
	PROTECT oDCFabZipMsg AS CHECKBOX
	PROTECT oDCGroupBox1 AS GROUPBOX
	PROTECT oDCExtractBar AS PROGRESSBAR
	PROTECT oDCFProcess AS FIXEDTEXT
	PROTECT oCCCancelPB AS PUSHBUTTON
	PROTECT oDCProcessGrp AS GROUPBOX
	PROTECT oDCTotalSizeBar AS PROGRESSBAR
	PROTECT oDCTotalFilesBar AS PROGRESSBAR
	PROTECT oDCZipMessages AS FIXEDTEXT
	
	// {{%UC%}} User code starts here (DO NOT remove this line)  
	PROTECT	lNeedCancel		AS	LOGIC
	PROTECT nCurrentSize	AS	DWORD
	PROTECT nCurrentPos		AS	DWORD
	PROTECT nMaxFiles		AS	DWORD
	PROTECT nCurrentFile	AS	DWORD
	PROTECT nMaxSize		AS	DWORD
	PROTECT nCurrMaxSize	AS	DWORD
	
	METHOD AddPB( ) 
		LOCAL	oDlg	AS	AddWnd
		LOCAL	oAddOpt	AS	FabAddOptions
		LOCAL	wCpt	AS	WORD
		LOCAL lSuccess	AS	LOGIC
		// We first need a ZipFile Name
		IF Empty( SELF:ZipFileName )
			SELF:CreatePB()
			IF Empty( SELF:ZipFileName )
				return self
			ENDIF
		ELSE
			SELF:oDCZip_Control:ZipFile:FileName := SELF:ZipFileName
		ENDIF
		//
		oAddOpt := FabAddOptions{}
		oDlg := AddWnd{ SELF, oAddOpt }
		oDlg:Show()
		IF ( oDlg:Result == 0 )
			return self
		ENDIF
		// Retrieve selected files
		FOR wCpt := 1 TO ALen( oDlg:aSelected )
			//  aSelected is an Array of FileSpec
			SELF:oDCZip_Control:ZipFile:FilesArg:Add( oDlg:aSelected[ wCpt ]:FullPath )
		NEXT
		//
		SELF:lNeedCancel := FALSE
		//
		SELF:ProcessShow()
		// Set AddOptions
		SELF:oDCZip_Control:ZipFile:AddOptions := oAddOpt
		// Compression Level
		SELF:oDCZip_Control:ZipFile:CompressionLevel := (word)oDlg:Level	
		// Disk Spanning ?
		IF oAddOpt:DiskSpan .OR. oAddOpt:DiskSpanErase
			//
			SELF:oDCZip_Control:ZipFile:MaxVolumeSize := (dword)oDlg:ZipMaxSize
			SELF:oDCZip_Control:ZipFile:MinFreeVolumeSize := (dword)oDlg:ZipMinSize
			SELF:oDCZip_Control:ZipFile:KeepFreeOnDisk1 := (dword)oDlg:ZipMinDisk1
		ELSE
			SELF:oDCZip_Control:ZipFile:MaxVolumeSize := 0
			SELF:oDCZip_Control:ZipFile:MinFreeVolumeSize := 65536
			SELF:oDCZip_Control:ZipFile:KeepFreeOnDisk1 := 0
		ENDIF
		// For Debbugging only, VERY VERY LONG
		//	SELF:oDCZip_Control:ZipFile:Trace := TRUE
		// If you want more info on operation
		//	SELF:oDCZip_Control:ZipFile:Verbose := TRUE
		// This is a Modal Call
		lSuccess := SELF:oDCZip_Control:ZipFile:Add()
		//
		SELF:ProcessHide()
		SELF:lNeedCancel := FALSE
		//
		IF lSuccess
			IF oAddOpt:DiskSpan .OR. oAddOpt:DiskSpanErase
				// In a Spanning operation, get the name of the name of the last file
				// that's where the Directory is stored.
				SELF:oDCZip_Control:ZipFile:FileName := SELF:oDCZip_Control:ZipFile:LastWrittenFile
				SELF:ZipFileName := SELF:oDCZip_Control:ZipFile:FileName
				//
			ENDIF
		ENDIF
		return self
		
	METHOD ButtonClick(oControlEvent) 
		LOCAL oControl  AS Control
		LOCAL cPass		AS	STRING
		//
		oControl := IIf(oControlEvent == NULL_OBJECT, NULL_OBJECT, oControlEvent:Control)
		SUPER:ButtonClick(oControlEvent)
		//Put your changes here
		IF ( oControl != NULL_OBJECT )
			IF ( oControl:NameSym == #PassChk )
				IF ( SELF:PassChk )
					// Input Password
					cPass := FabInputBox( "Enter", "Password :", "" )
					IF !Empty( cPass )
						IF ( cPass != FabInputBox( "Confirm", "Password :", "" ) )
							FabMessageAlert( "Password don't match !", "Error" )
							SELF:PassChk := FALSE
						ELSE
							// Ok, set Password
							SELF:oDCZip_Control:ZipFile:Password := cPass
						ENDIF
					ELSE
						SELF:PassChk := FALSE
					ENDIF
				ELSE
					// Remove Password
					SELF:oDCZip_Control:ZipFile:Password := ""
				ENDIF
			ELSEIF ( oControl:NameSym == #FabZipMsg )
				SELF:oDCZip_Control:ZipFile:Unattended := !SELF:oDCFabZipMsg:Checked
			ENDIF
		ENDIF
		RETURN NIL
		
	METHOD CancelPB( ) 
		// Set Cancel to TRUE for the next message processing
		self:lNeedCancel := true
		return self
		
	METHOD ClearAll( ) 
		LOCAL	wCpt	AS	WORD
		LOCAL	oItem	AS	ListViewItem
		//
		FOR wCpt := 1 TO SELF:oDCZipList:ItemCount
			//
			oItem := SELF:oDCZipList:GetItemAttributes( wCpt )
			//
			oItem:Selected := FALSE
			//
			SELF:oDCZipList:SetItemAttributes( oItem )
			//
		NEXT
		//
		return self		
		
	METHOD CommentPB( ) 
		FabMessageInfo( SELF:oDCZip_Control:ZipFile:ZipComment )
		return self	
		
	METHOD ConvertPB( ) 
		LOCAL oFS	AS	FileSpec
		LOCAL oDlg	AS	SFXWnd
		LOCAL oOpt	AS	FabSFXOptions
		// Get Current File Extension
		IF ( ".ZIP" $ Upper( SELF:oDCZip_Control:ZipFile:FileName ) )
			//
			oOpt := FabSFXOptions{}
			oOpt:Caption := "FabZipTest Self-extracting Archive"
			// When converting to SFX, we now have some usefull options
			oDlg := SFXWnd{ SELF, oOpt }
			oDlg:Show()
			IF ( oDlg:Result == 1 )
				//
				SELF:oDCZip_Control:ZipFile:SFXOptions := oOpt
				//
				SELF:oDCZip_Control:ZipFile:Convert2SFX()
				SELF:ZipFileName := SELF:oDCZip_Control:ZipFile:FileName
			ENDIF
		ELSEIF ( ".EXE" $ Upper( SELF:oDCZip_Control:ZipFile:FileName ) )
			SELF:oDCZip_Control:ZipFile:Convert2ZIP()
			SELF:ZipFileName := SELF:oDCZip_Control:ZipFile:FileName
		ENDIF
		oFS := FileSpec{ SELF:ZipFileName }
		IF Upper( oFS:Extension ) == ".ZIP"
			SELF:oCCConvertPB:Caption := "Add SFX"
		ELSEIF Upper( oFS:Extension ) == ".EXE"
			SELF:oCCConvertPB:Caption := "Remove SFX"
		ENDIF
		
		return self	
		
	METHOD CreatePB( ) 
		LOCAL oOD		AS	SaveAsDialog
		LOCAL oFS		AS	FileSpec
		//
		oOD := SaveAsDialog{SELF, ""}
		oOD:SetFilter( { "*.Zip", "*.Zip;*.Exe", "*.*" }, { "Archives", "Archives and Exe Files", "All Files" }, 1 )
		oOD:Caption := "Choose a Zip-File name"
		// FabSaveAsDialogEx
		//oOD:OkText := "Create"
		oOD:Show()
		//	
		IF !Empty( oOD:FileName )
			// Set FileName in the SLE
			SELF:ZipFileName := oOD:FileName
			IF Empty( FabExtractFileExt( SELF:ZipFileName ) )
				SELF:ZipFileName := SELF:ZipFileName + ".zip"
			ENDIF
			//
			oFS := FileSpec{ SELF:ZipFileName }
			IF Upper( oFS:Extension ) == ".ZIP"
				SELF:oCCConvertPB:Caption := "Add SFX"
			ELSE
				SELF:oCCConvertPB:Caption := "Remove SFX"
			ENDIF
			//
			SELF:oDCZip_Control:ZipFile:FileName := SELF:ZipFileName
			// This is automatically done when setting the name
			//	SELF:oDCZip_Control:FileZip:UpdateContents()
		ENDIF	
		return self
		
	METHOD DeletePB( ) 
		LOCAL	oDlg	AS	DeleteWnd
		LOCAL	nFrom	AS	INT
		LOCAL	wCpt	AS	INT
		LOCAL	oItem	AS	ListViewItem
		// We first need a ZipFile Name
		IF Empty( SELF:ZipFileName ) .or. !File( SELF:ZipFileName )
			return self
		ENDIF
		//
		oDlg := DeleteWnd{ SELF }
		// All Files ?
		oDlg:SELECT( SELF:oDCZipList:SelectedCount != 0 )
		//
		oDlg:Show()
		IF ( oDlg:Result == 0 )
			return self
		ENDIF
		// Want all Files
		IF oDlg:lAll
			SELF:SelectAll()
		ENDIF
		// Retrieve selected files
		nFrom := 0
		FOR wCpt := 1 TO SELF:oDCZipList:SelectedCount
			oItem := SELF:oDCZipList:GetNextItem( , , , , TRUE, nFrom )
			// We need to get the value ( Name as it appears in the Zip File ) with the path
			SELF:oDCZip_Control:ZipFile:FilesArg:Add( oItem:GetValue( #Name ) )
			nFrom := oItem:ItemIndex
		NEXT
		//
		SELF:lNeedCancel := FALSE
		//
		SELF:ProcessShow()
		//
		// For Debbugging only, VERY VERY LONG
		//	SELF:oDCZip_Control:ZipFile:Trace := TRUE
		// If you want more info on operation
		//	SELF:oDCZip_Control:ZipFile:Verbose := TRUE
		// This is a Modal Call
		SELF:oDCZip_Control:ZipFile:@@Delete()
		//
		SELF:ProcessHide()
		SELF:lNeedCancel := FALSE
		
		return self
		
	ACCESS DllMsg
		RETURN SELF:FieldGet( #DllMsg )
		
	ASSIGN DllMsg( uValue )
		SELF:FieldPut( #DllMsg , uValue )
		
	METHOD ExtractPB( ) 
		LOCAL oItem		AS	ListViewItem
		LOCAL wCpt		AS	WORD
		LOCAL nFrom		AS	WORD
		LOCAL oDirDlg	AS	ExtractWnd
		LOCAL oXtract	AS	FabExtractOptions
		//
		IF Empty( SELF:ZipFileName ) .or. !File( SELF:ZipFileName )
			return self
		ENDIF
		// Get Extract dir and Options
		oXtract	:= FabExtractOptions{}
		oDirDlg := ExtractWnd{ SELF, oXtract }
		// All Files ?
		oDirDlg:SELECT( SELF:oDCZipList:SelectedCount != 0 )
		// Set Default extract dir to Zip Dir
		oDirDlg:DirName := FabExtractFilePath( SELF:ZipFileName )
		//
		oDirDlg:Show()
		IF ( oDirDlg:Result == 0 )
			return self
		ENDIF
		// Want all Files
		IF oDirDlg:lAll
			SELF:SelectAll()
		ENDIF
		// Retrieve selected files
		nFrom := 0
		FOR wCpt := 1 TO SELF:oDCZipList:SelectedCount
			oItem := SELF:oDCZipList:GetNextItem( , , , , TRUE, nFrom )
			// We need to get the value ( Name as it appears in the Zip File ) with the path
			SELF:oDCZip_Control:ZipFile:FilesArg:Add( oItem:GetValue( #Name ) )
			nFrom := oItem:ItemIndex
		NEXT
		//
		SELF:lNeedCancel := FALSE
		//
		SELF:ProcessShow()
		//
		SELF:oDCZip_Control:ZipFile:ExtractDir := oDirDlg:Dirname
		// For Debbugging only, VERY VERY LONG
		//	SELF:oDCZip_Control:ZipFile:Trace := TRUE
		// If you want more info on operation
		//	SELF:oDCZip_Control:ZipFile:Verbose := TRUE
		// If you want to extract any pre-existing files
		oXtract:OverWrite := TRUE
		// Set ExtractOptions
		SELF:oDCZip_Control:ZipFile:ExtractOptions := oXtract
		// This is a Modal Call
		SELF:oDCZip_Control:ZipFile:Extract()
		//
		SELF:ProcessHide()
		SELF:lNeedCancel := FALSE
		return self
		
	ACCESS FabZipMsg
		RETURN SELF:FieldGet( #FabZipMsg )
		
	ASSIGN FabZipMsg( uValue )
		SELF:FieldPut( #FabZipMsg , uValue )
		
	CONSTRUCTOR(oWindow,iCtlID,oServer,uExtra)
		
		SELF:PreInit(oWindow,iCtlID,oServer,uExtra)
		
		SUPER(oWindow , ResourceID{"FabZipTest1" , _GetInst()},iCtlID)
		
		SELF:oDCZipFileName := SINGLELINEEDIT{SELF , ResourceID{ FABZIPTEST1_ZIPFILENAME  , _GetInst() } }
		SELF:oDCZipFileName:HyperLabel := HyperLabel{#ZipFileName , NULL_STRING , NULL_STRING , NULL_STRING}
		
		SELF:oCCOpenPB := PUSHBUTTON{SELF , ResourceID{ FABZIPTEST1_OPENPB  , _GetInst() } }
		SELF:oCCOpenPB:HyperLabel := HyperLabel{#OpenPB , "Open Zip File" , NULL_STRING , NULL_STRING}
		
		SELF:oCCCreatePB := PUSHBUTTON{SELF , ResourceID{ FABZIPTEST1_CREATEPB  , _GetInst() } }
		SELF:oCCCreatePB:HyperLabel := HyperLabel{#CreatePB , "Create Zip File" , NULL_STRING , NULL_STRING}
		
		SELF:oDCPassChk := CHECKBOX{SELF , ResourceID{ FABZIPTEST1_PASSCHK  , _GetInst() } }
		SELF:oDCPassChk:HyperLabel := HyperLabel{#PassChk , "Use Password" , NULL_STRING , NULL_STRING}
		
		SELF:oCCAddPB := PUSHBUTTON{SELF , ResourceID{ FABZIPTEST1_ADDPB  , _GetInst() } }
		SELF:oCCAddPB:HyperLabel := HyperLabel{#AddPB , "&Add" , NULL_STRING , NULL_STRING}
		
		SELF:oCCExtractPB := PUSHBUTTON{SELF , ResourceID{ FABZIPTEST1_EXTRACTPB  , _GetInst() } }
		SELF:oCCExtractPB:HyperLabel := HyperLabel{#ExtractPB , "&Extract" , NULL_STRING , NULL_STRING}
		
		SELF:oCCDeletePB := PUSHBUTTON{SELF , ResourceID{ FABZIPTEST1_DELETEPB  , _GetInst() } }
		SELF:oCCDeletePB:HyperLabel := HyperLabel{#DeletePB , "&Delete" , NULL_STRING , NULL_STRING}
		
		SELF:oCCConvertPB := PUSHBUTTON{SELF , ResourceID{ FABZIPTEST1_CONVERTPB  , _GetInst() } }
		SELF:oCCConvertPB:HyperLabel := HyperLabel{#ConvertPB , "&Convert" , NULL_STRING , NULL_STRING}
		
		SELF:oCCCommentPB := PUSHBUTTON{SELF , ResourceID{ FABZIPTEST1_COMMENTPB  , _GetInst() } }
		SELF:oCCCommentPB:HyperLabel := HyperLabel{#CommentPB , "&Comment" , NULL_STRING , NULL_STRING}
		
		SELF:oCCOkPB := PUSHBUTTON{SELF , ResourceID{ FABZIPTEST1_OKPB  , _GetInst() } }
		SELF:oCCOkPB:HyperLabel := HyperLabel{#OkPB , "&Close" , NULL_STRING , NULL_STRING}
		
		SELF:oDCZip_Control := FABZIPFILECTRL{SELF , ResourceID{ FABZIPTEST1_ZIP_CONTROL  , _GetInst() } }
		SELF:oDCZip_Control:HyperLabel := HyperLabel{#Zip_Control , "Zip Control" , NULL_STRING , NULL_STRING}
		
		SELF:oDCZipList := LISTVIEW{SELF , ResourceID{ FABZIPTEST1_ZIPLIST  , _GetInst() } }
		SELF:oDCZipList:ContextMenu := LISTMENU{}
		SELF:oDCZipList:HyperLabel := HyperLabel{#ZipList , NULL_STRING , NULL_STRING , NULL_STRING}
		
		SELF:oDCDllMsg := CHECKBOX{SELF , ResourceID{ FABZIPTEST1_DLLMSG  , _GetInst() } }
		SELF:oDCDllMsg:TooltipText := "Show Dll Messages"
		SELF:oDCDllMsg:HyperLabel := HyperLabel{#DllMsg , "Show CallBack Messages" , NULL_STRING , NULL_STRING}
		
		SELF:oDCFabZipMsg := CHECKBOX{SELF , ResourceID{ FABZIPTEST1_FABZIPMSG  , _GetInst() } }
		SELF:oDCFabZipMsg:TooltipText := "Show Dll Messages"
		SELF:oDCFabZipMsg:HyperLabel := HyperLabel{#FabZipMsg , "Show FabZip Class Messages" , NULL_STRING , NULL_STRING}
		
		SELF:oDCGroupBox1 := GROUPBOX{SELF , ResourceID{ FABZIPTEST1_GROUPBOX1  , _GetInst() } }
		SELF:oDCGroupBox1:HyperLabel := HyperLabel{#GroupBox1 , "Zip File" , NULL_STRING , NULL_STRING}
		
		SELF:oDCExtractBar := PROGRESSBAR{SELF , ResourceID{ FABZIPTEST1_EXTRACTBAR  , _GetInst() } }
		SELF:oDCExtractBar:TooltipText := "Current File"
		SELF:oDCExtractBar:HyperLabel := HyperLabel{#ExtractBar , NULL_STRING , NULL_STRING , NULL_STRING}
		
		SELF:oDCFProcess := FIXEDTEXT{SELF , ResourceID{ FABZIPTEST1_FPROCESS  , _GetInst() } }
		SELF:oDCFProcess:HyperLabel := HyperLabel{#FProcess , "Name of the file in process" , NULL_STRING , NULL_STRING}
		
		SELF:oCCCancelPB := PUSHBUTTON{SELF , ResourceID{ FABZIPTEST1_CANCELPB  , _GetInst() } }
		SELF:oCCCancelPB:HyperLabel := HyperLabel{#CancelPB , "&Cancel" , NULL_STRING , NULL_STRING}
		
		SELF:oDCProcessGrp := GROUPBOX{SELF , ResourceID{ FABZIPTEST1_PROCESSGRP  , _GetInst() } }
		SELF:oDCProcessGrp:HyperLabel := HyperLabel{#ProcessGrp , "Processing" , NULL_STRING , NULL_STRING}
		
		SELF:oDCTotalSizeBar := PROGRESSBAR{SELF , ResourceID{ FABZIPTEST1_TOTALSIZEBAR  , _GetInst() } }
		SELF:oDCTotalSizeBar:TooltipText := "Total Size"
		SELF:oDCTotalSizeBar:HyperLabel := HyperLabel{#TotalSizeBar , NULL_STRING , NULL_STRING , NULL_STRING}
		
		SELF:oDCTotalFilesBar := PROGRESSBAR{SELF , ResourceID{ FABZIPTEST1_TOTALFILESBAR  , _GetInst() } }
		SELF:oDCTotalFilesBar:TooltipText := "Total # of Files"
		SELF:oDCTotalFilesBar:HyperLabel := HyperLabel{#TotalFilesBar , NULL_STRING , NULL_STRING , NULL_STRING}
		
		SELF:oDCZipMessages := FIXEDTEXT{SELF , ResourceID{ FABZIPTEST1_ZIPMESSAGES  , _GetInst() } }
		SELF:oDCZipMessages:HyperLabel := HyperLabel{#ZipMessages , "ZipMessages" , NULL_STRING , NULL_STRING}
		
		SELF:Caption := "Fab Zip Test #1"
		SELF:Icon := DelZip{}
		SELF:HyperLabel := HyperLabel{#FabZipTest1 , "Fab Zip Test #1" , NULL_STRING , NULL_STRING}
		IF !IsNil(oServer)
			SELF:Use(oServer)
		ENDIF
		
		
		SELF:PostInit(oWindow,iCtlID,oServer,uExtra)
		
		RETURN
		
		
	METHOD OkPB( ) 
		SELF:EndWindow()
		return self
		
	METHOD	OnFabZipDirUpdate( oCtrl as object ) 
		// In the following code the Commented lines ware using the FileSpec class
		// to process the FileName and Path, but it seems that FileSpec is converting
		// FileName to Upper case, so I now use the FabExtractFileXXX() function
		// to preserve FileNames case.
		LOCAL oItem			AS	ListViewItem
		LOCAL oZDir			AS	FabZipDirEntry
		LOCAL wCpt			AS	WORD
		LOCAL cTmp			AS	STRING
		//	LOCAL oFS			AS	FileSpec
		// We come here due to FabZipFile creation, we are in the Init() of the Window
		IF ( SELF:oDCZipList == NULL_OBJECT )
			return self
		ENDIF
		// Clear ListView
		SELF:oDCZipList:DeleteAll()
		// Update ListView
		FOR wCpt := 1 TO oCtrl:ZipFile:Contents:Len
			// Zip Dir Entry
			oZDir := oCtrl:ZipFile:Contents:Get( wCpt )
			// One Line
			oItem := ListViewItem{}
			// Convert FileName from Unix to DOS
			cTmp := StrTran( oZDir:FileName, "/", "\" )
			//		oFS := FileSpec{}
			//		oFs:FileName := cTmp
			// FileName
			//		oItem:SetText( oFS:FileName + oFS:Extension , #NAME )
			oItem:SetText( FabExtractFileName( cTmp ) + FabExtractFileExt( cTmp ) , #NAME )
			// We need to save the value ( Name as it appears in the Zip File ) for extracting
			//		oItem:SetValue( oFS:FullPath, #NAME )
			oItem:SetValue( cTmp, #NAME )
			// File¨Path
			//		oItem:SetValue( oFS:Path, #Path )
			oItem:SetValue( FabExtractFilePath( cTmp ), #Path )
			// File Date
			oItem:SetValue( oZDir:FileDate, #DATE )
			// File Time
			oItem:SetValue( oZDir:FileTime, #TIME )
			// File Size
			oItem:SetValue( oZDir:UnCompressedSize, #SIZE )
			// File Packed Size
			oItem:SetValue( oZDir:CompressedSize, #Packed )
			// Ratio
			oItem:SetValue( NTrim( oZDir:Ratio ) + "%", #Ratio )
			// Flag
			IF oZDir:Crypted
				oItem:SetValue( "*", #Crypt )
			ELSE
				oItem:SetValue( " ", #Crypt )
			ENDIF
			// Files Attributes
			oItem:SetValue( oZDir:Attributes, #Attrib )
			//		oItem:SetValue( oZDir:ExtFileAttrib, #Attrib )
			// Add the line
			SELF:oDCZipList:AddItem( oItem )
		NEXT
		return self	
		
	METHOD	OnFabZipMessage( oCtrl, nError, cMsg ) 
		// If nError == 0, No error, just a message after each file
		IF ( SELF:DllMsg )
			IF ( nError == 0 )
				// Just to let you knwo that...
				SELF:oDCZipMessages:TextValue := cMsg
			ELSE
				// Error Message
				FabMessageAlert( "Message #" + NTrim( nError ) + CRLF + cMsg , "Error Message From Zip/Unzip DLL" )
				// Abort
				RETURN TRUE
			ENDIF
		ENDIF
		// Special case, aborting for quitting....
		
		return self
		
	METHOD	OnFabZipProgress( oCtrl as object, symEvent as symbol, cFile as string, nSize as int64 ) as logic
		//
		TRY
			IF ( symEvent == #New )
				// Convert Unix-style to Dos separator
				cFile := StrTran( cFile, "/", "\" )
				//
				SELF:oDCFProcess:TextValue := cFile
				SELF:oDCExtractBar:Range := Range{ 1, 100 }
				SELF:oDCExtractBar:UnitSize := 1
				SELF:oDCExtractBar:Position := 1
				//
				SELF:nCurrentSize := (dword)nSize
				SELF:nCurrentPos := 0
				//
				SELF:nCurrentFile := SELF:nCurrentFile + 1
				SELF:oDCTotalFilesBar:Position := FabGetPercent( SELF:nCurrentFile, SELF:nMaxFiles )
				//
			ELSEIF ( symEvent == #Update )
				// nSize gives now the bytes processed since the last call.
				SELF:nCurrentPos := SELF:nCurrentPos + (int)nSize
				SELF:oDCExtractBar:Position := FabGetPercent( SELF:nCurrentPos, SELF:nCurrentSize )
				//
				SELF:nCurrMaxSize := SELF:nCurrMaxSize + (int)nSize
				SELF:oDCTotalSizeBar:Position := FabGetPercent( SELF:nCurrMaxSize, SELF:nMaxSize )
				//
			ELSEIF ( symEvent == #END )
				SELF:oDCFProcess:TextValue := ""
				SELF:oDCExtractBar:Range := Range{ 1, 100 }
				SELF:oDCExtractBar:UnitSize := 1
				SELF:oDCExtractBar:Position := 1
			ELSEIF ( symEvent == #TotalFiles )
				SELF:oDCTotalFilesBar:Range := Range{ 1, 100 }
				SELF:oDCTotalFilesBar:UnitSize := 1
				SELF:oDCTotalFilesBar:Position := 1
				SELF:nMaxFiles := (dword)nSize
				SELF:nCurrentFile := 0
			ELSEIF ( symEvent == #TotalSize )
				SELF:oDCTotalSizeBar:Range := Range{ 1, 100 }
				SELF:oDCTotalSizeBar:UnitSize := 1
				SELF:oDCTotalSizeBar:Position := 1
				SELF:nMaxSize := (dword)nSize
				SELF:nCurrMaxSize := 0
			ENDIF
		CATCH Err AS Exception
			System.Diagnostics.Debug.WriteLine( Err:Message )
		END TRY
		// System refresh or we can't do anything ( Cancel, moving windows, .... )
		GetAppObject():Exec( EXECWHILEEVENT )
		//
		RETURN	SELF:lNeedCancel
		
	METHOD OpenPB( ) 
		LOCAL oOD	AS	OpenDialog
		LOCAL cInit	AS	STRING
		LOCAL oFS	AS	FileSpec
		//
		IF Empty( SELF:ZipFileName )
			cInit := "" //"*.zip"
		ELSE
			cInit := SELF:ZipFileName
		ENDIF
		//
		oOD := OpenDialog{SELF, cInit }
		oOD:SetFilter( { "*.Zip", "*.Zip;*.Exe", "*.*" }, { "Archives", "Archives and Exe Files", "All Files" }, 1 )
		oOD:Caption := "Choose a Zip File"
		oOD:Show()
		//
		IF !Empty( oOD:FileName )
			SELF:ZipFileName := oOD:FileName
		ENDIF
		//
		IF File( SELF:ZipFileName )
			//
			oFS := FileSpec{ SELF:ZipFileName }
			IF Upper( oFS:Extension ) == ".ZIP"
				SELF:oCCConvertPB:Caption := "Add SFX"
			ELSE
				SELF:oCCConvertPB:Caption := "Remove SFX"
			ENDIF
			// Clear ListView
			SELF:oDCZipList:DeleteAll()
			//
			SELF:oDCZip_Control:ZipFile:FileName := SELF:ZipFileName
			// This is automatically done when setting the name
			//	SELF:oDCZip_Control:FileZip:UpdateContents()
		ENDIF	
		return self
		
	ACCESS PassChk
		RETURN SELF:FieldGet( #PassChk )
		
	ASSIGN PassChk( uValue )
		SELF:FieldPut( #PassChk , uValue )
		
	METHOD PostInit(oWindow,iCtlID,oServer,uExtra) 
		LOCAL oColumn	AS	ListViewColumn
		//Put your PostInit additions here
		// Crypted ?
		SELF:oDCZipList:AddColumn( ListViewColumn{ 01, HyperLabel{ #Crypt, "" } } )
		// FileName
		SELF:oDCZipList:AddColumn( ListViewColumn{ , HyperLabel{ #NAME, "File Name" } } )
		// Date
		SELF:oDCZipList:AddColumn( ListViewColumn{ 08, HyperLabel{ #DATE, "Date" } } )
		// Time
		SELF:oDCZipList:AddColumn( ListViewColumn{ 08, HyperLabel{ #TIME, "Time" } } )
		// Size
		oColumn := ListViewColumn{ 07, HyperLabel{ #SIZE, "Size" } }
		oColumn:Alignment := LVCFMT_RIGHT
		SELF:oDCZipList:AddColumn( oColumn )
		// Ratio
		SELF:oDCZipList:AddColumn( ListViewColumn{ 05, HyperLabel{ #Ratio, "Ratio" } } )
		// Packed
		oColumn := ListViewColumn{ 07, HyperLabel{ #Packed, "Packed" } }
		oColumn:Alignment := LVCFMT_RIGHT
		SELF:oDCZipList:AddColumn( oColumn )
		// Files Attributes
		SELF:oDCZipList:AddColumn( ListViewColumn{ 05, HyperLabel{ #Attrib, "Attributes" } } )
		// Path
		SELF:oDCZipList:AddColumn( ListViewColumn{ 35, HyperLabel{ #Path, "Path" } } )
		// Init Config
		SELF:DllMsg := TRUE
		SELF:FabZipMsg := TRUE
		// Select the Entire Row of hte ListView
		FabLWSelectEntireRow( SELF:oDCZipList )
		//
		SELF:ZipFileName := ""
		RETURN NIL
		
	METHOD ProcessHide() 
		SELF:oDCFProcess:Hide()
		SELF:oDCExtractBar:Hide()
		SELF:oDCTotalFilesBar:Hide()
		SELF:oDCTotalSizeBar:Hide()
		SELF:oCCCancelPB:Hide()
		SELF:oDCProcessGrp:Hide()
		return self
		
	METHOD ProcessShow() 
		SELF:oDCFProcess:Show()
		SELF:oDCExtractBar:Show()
		SELF:oDCTotalFilesBar:Show()
		SELF:oDCTotalSizeBar:Show()
		SELF:oCCCancelPB:Show()
		SELF:oDCProcessGrp:Show()
		//
		SELF:Update()
		return self
		
	METHOD QueryClose(oEvent) 
		LOCAL lAllowClose AS LOGIC
		lAllowClose := TRUE
		//Put your changes here
		IF ( SELF:oDCZip_Control:ZipFile:Processing )
			// Sorry, you must first cancel the operation...
			lAllowClose := FALSE		
		ENDIF
		RETURN lAllowClose
		
	METHOD SelectAll( ) 
		LOCAL	wCpt	AS	WORD
		LOCAL	oItem	AS	ListViewItem
		//
		FOR wCpt := 1 TO SELF:oDCZipList:ItemCount
			//
			oItem := SELF:oDCZipList:GetItemAttributes( wCpt )
			//
			oItem:Selected := TRUE
			//
			SELF:oDCZipList:SetItemAttributes( oItem )
			//
		NEXT
		//
		return self
		
	ACCESS ZipFileName
		RETURN SELF:FieldGet( #ZipFileName )
		
	ASSIGN ZipFileName( uValue )
		SELF:FieldPut( #ZipFileName , uValue )
		
END CLASS

