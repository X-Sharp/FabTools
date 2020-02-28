using FabZip
using VO


STATIC DEFINE ADDWND_FILES := 100
STATIC DEFINE ADDWND_SELECTPB := 101
STATIC DEFINE ADDWND_ACTIONCOMBO := 102
STATIC DEFINE ADDWND_LEVELSLIDER := 103
STATIC DEFINE ADDWND_DOSFORMATCHK := 104
STATIC DEFINE ADDWND_SYSTEMCHK := 105
STATIC DEFINE ADDWND_RECURSECHK := 106
STATIC DEFINE ADDWND_DIRINFOCHK := 107
STATIC DEFINE ADDWND_DISKSPANNINGGRP := 108
STATIC DEFINE ADDWND_SPANNINGCHK := 109
STATIC DEFINE ADDWND_FORMATCHK := 110
STATIC DEFINE ADDWND_MAXSIZE := 111
STATIC DEFINE ADDWND_MINDISK1 := 112
STATIC DEFINE ADDWND_MINFREESIZE := 113
STATIC DEFINE ADDWND_DOITPB := 114
STATIC DEFINE ADDWND_WILDCARDSPB := 115
STATIC DEFINE ADDWND_CANCELPB := 116
STATIC DEFINE ADDWND_FIXEDTEXT1 := 117
STATIC DEFINE ADDWND_FIXEDTEXT2 := 118
STATIC DEFINE ADDWND_FIXEDTEXT3 := 119
STATIC DEFINE ADDWND_FIXEDTEXT4 := 120
STATIC DEFINE ADDWND_FIXEDTEXT5 := 121
STATIC DEFINE ADDWND_FOLDERSGRP := 122
STATIC DEFINE ADDWND_FIXEDTEXT6 := 123
STATIC DEFINE ADDWND_DISKSIZEGRP := 124
STATIC DEFINE ADDWND_FIXEDTEXT7 := 125
STATIC DEFINE ADDWND_FIXEDTEXT8 := 126
PARTIAL CLASS AddWnd INHERIT DIALOGWINDOW
	PROTECT oDCFiles AS SINGLELINEEDIT
	PROTECT oCCSelectPB AS PUSHBUTTON
	PROTECT oDCActionCombo AS COMBOBOX
	PROTECT oDCLevelSlider AS HORIZONTALSLIDER
	PROTECT oDCDosFormatChk AS CHECKBOX
	PROTECT oDCSystemChk AS CHECKBOX
	PROTECT oDCRecurseChk AS CHECKBOX
	PROTECT oDCDirInfoChk AS CHECKBOX
	PROTECT oDCDiskSpanningGrp AS GROUPBOX
	PROTECT oDCSpanningChk AS CHECKBOX
	PROTECT oDCFormatChk AS CHECKBOX
	PROTECT oDCMaxSize AS COMBOBOX
	PROTECT oDCMinDisk1 AS SINGLELINEEDIT
	PROTECT oDCMinFreeSize AS SINGLELINEEDIT
	PROTECT oCCDoItPB AS PUSHBUTTON
	PROTECT oCCWildcardsPB AS PUSHBUTTON
	PROTECT oCCCancelPB AS PUSHBUTTON
	PROTECT oDCFixedText1 AS FIXEDTEXT
	PROTECT oDCFixedText2 AS FIXEDTEXT
	PROTECT oDCFixedText3 AS FIXEDTEXT
	PROTECT oDCFixedText4 AS FIXEDTEXT
	PROTECT oDCFixedText5 AS FIXEDTEXT
	PROTECT oDCFoldersGrp AS GROUPBOX
	PROTECT oDCFixedText6 AS FIXEDTEXT
	PROTECT oDCDiskSizeGrp AS GROUPBOX
	PROTECT oDCFixedText7 AS FIXEDTEXT
	PROTECT oDCFixedText8 AS FIXEDTEXT

	// {{%UC%}} User code starts here (DO NOT remove this line)  
  	EXPORT	aSelected	AS	ARRAY
  	EXPORT	symMode		AS	SYMBOL
  	EXPORT	Level		AS	LONG
	EXPORT	oAddOptions	AS	FabAddOptions
	//
	EXPORT	ZipMaxSize		AS	LONG
	EXPORT	ZipMinDisk1	AS	LONG
	EXPORT	ZipMinSize		AS	LONG
	

METHOD ButtonClick(oControlEvent) 
	LOCAL oControl AS Control
	oControl := IIf(oControlEvent == NULL_OBJECT, NULL_OBJECT, oControlEvent:Control)
	SUPER:ButtonClick(oControlEvent)
	//Put your changes here
	IF ( oControl != NULL_OBJECT )
		IF ( oControl:NameSym == #SpanningChk )
			IF SELF:oDCSpanningChk:Checked
				SELF:oDCActionCombo:Value := #Add
				SELF:oCCDoItPB:Caption := "&" + Proper( AsString( SELF:oDCActionCombo:Value ) )
				SELF:symMode := SELF:oDCActionCombo:Value
				SELF:oDCActionCombo:Disable()
				//
				SELF:EnableSpanning()
				//
			ELSE
				SELF:oDCActionCombo:Enable()
				SELF:DisableSpanning()
			ENDIF
		ENDIF
	ENDIF
	//
	RETURN NIL

METHOD CancelPB( ) 
	SELF:EndDialog( 0 )
return self

METHOD DisableSpanning() 
	SELF:oDCFormatChk:Disable()
	SELF:oDCMaxSize:Disable()
	SELF:oDCMinDisk1:Disable()
	SELF:oDCMinFreeSize:Disable()
return self

METHOD DoItPB( ) 
	//
	IF Empty( SELF:aSelected )
		SELF:EndDialog( 0 )
		return self
	ENDIF
	//
	DO CASE
		CASE ( symMode == #Move )
			SELF:oAddOptions:Move := TRUE
		CASE (symMode == #Freshen )
			SELF:oAddOptions:Freshen := TRUE
		CASE ( symMode == #Update )
			SELF:oAddOptions:Update := TRUE
		OTHERWISE
			// Nothing to do, we are in Add mode by default
	ENDCASE
	//
	SELF:oAddOptions:DirNames := SELF:oDCDirInfoChk:Checked
	SELF:oAddOptions:RecurseDirs := SELF:oDCRecurseChk:Checked
	SELF:oAddOptions:ForceDos  :=  SELF:oDCDosFormatChk:Checked
	SELF:oAddOptions:System :=  SELF:oDCSystemChk:Checked
	//
	SELF:Level := SELF:oDCLevelSlider:Value
	// Disk Spanning ?
	IF SELF:oDCSpanningChk:Checked
		IF SELF:oDCFormatChk:Checked
			SELF:oAddOptions:DiskSpanErase := TRUE
		ELSE
			SELF:oAddOptions:DiskSpan := TRUE
		ENDIF
		// 1kb == 1000b ( or 1024 ? )
		SELF:ZipMaxSize := Val( SELF:oDCMaxSize:TextValue ) * 1000
		//
		SELF:ZipMinDisk1:= Val( SELF:oDCMinDisk1:TextValue )
		SELF:ZipMinSize := Val( SELF:oDCMinFreeSize:TextValue )
	ENDIF
	//
	SELF:EndDialog( 1 )
	
 return self

METHOD EnableSpanning() 
	//
	SELF:oDCFormatChk:Enable()
	SELF:oDCMaxSize:Enable()
	SELF:oDCMinDisk1:Enable()
	SELF:oDCMinFreeSize:Enable()
	//
	SELF:oDCMaxSize:Value := 0
	SELF:oDCMinDisk1:Value := 0
	SELF:oDCMinFreeSize:Value := 65536
return self

METHOD	FillAction( )	
RETURN	( { {"Add & Replace Files", #Add}, ;
			{"Move Files", #Move}, ;
			{"Update & Add Files",#Update}, ;
			{"Freshen Existing Files",#Freshen} } )

METHOD	FillFloppy( )	
RETURN	( { { "Automatic", 0 } ,	;
			{ "720", 720 },			;
			{ "1440", 1440 },		;
			{ "2880", 2880 },		;
			{ "100000", 100000}	}	)


CONSTRUCTOR(oParent,uExtra)

	SELF:PreInit(oParent,uExtra)

	SUPER(oParent , ResourceID{"AddWnd" , _GetInst()} , TRUE)

	SELF:oDCFiles := SINGLELINEEDIT{SELF , ResourceID{ ADDWND_FILES  , _GetInst() } }
	SELF:oDCFiles:HyperLabel := HyperLabel{#Files , NULL_STRING , NULL_STRING , NULL_STRING}

	SELF:oCCSelectPB := PUSHBUTTON{SELF , ResourceID{ ADDWND_SELECTPB  , _GetInst() } }
	SELF:oCCSelectPB:TooltipText := "Select"
	SELF:oCCSelectPB:HyperLabel := HyperLabel{#SelectPB , "->" , NULL_STRING , NULL_STRING}

	SELF:oDCActionCombo := COMBOBOX{SELF , ResourceID{ ADDWND_ACTIONCOMBO  , _GetInst() } }
	SELF:oDCActionCombo:FillUsing( SELF:FillAction() )
	SELF:oDCActionCombo:HyperLabel := HyperLabel{#ActionCombo , NULL_STRING , NULL_STRING , NULL_STRING}

	SELF:oDCLevelSlider := HORIZONTALSLIDER{SELF , ResourceID{ ADDWND_LEVELSLIDER  , _GetInst() } }
	SELF:oDCLevelSlider:HyperLabel := HyperLabel{#LevelSlider , NULL_STRING , NULL_STRING , NULL_STRING}
	SELF:oDCLevelSlider:Range := Range{ , 9}

	SELF:oDCDosFormatChk := CHECKBOX{SELF , ResourceID{ ADDWND_DOSFORMATCHK  , _GetInst() } }
	SELF:oDCDosFormatChk:HyperLabel := HyperLabel{#DosFormatChk , "FileNames in 8.3 format" , NULL_STRING , NULL_STRING}

	SELF:oDCSystemChk := CHECKBOX{SELF , ResourceID{ ADDWND_SYSTEMCHK  , _GetInst() } }
	SELF:oDCSystemChk:HyperLabel := HyperLabel{#SystemChk , "Include System and Hidden Files" , NULL_STRING , NULL_STRING}

	SELF:oDCRecurseChk := CHECKBOX{SELF , ResourceID{ ADDWND_RECURSECHK  , _GetInst() } }
	SELF:oDCRecurseChk:HyperLabel := HyperLabel{#RecurseChk , "Recurse into Subdirectories" , NULL_STRING , NULL_STRING}

	SELF:oDCDirInfoChk := CHECKBOX{SELF , ResourceID{ ADDWND_DIRINFOCHK  , _GetInst() } }
	SELF:oDCDirInfoChk:HyperLabel := HyperLabel{#DirInfoChk , "Store Dirnames with files" , NULL_STRING , NULL_STRING}

	SELF:oDCDiskSpanningGrp := GROUPBOX{SELF , ResourceID{ ADDWND_DISKSPANNINGGRP  , _GetInst() } }
	SELF:oDCDiskSpanningGrp:HyperLabel := HyperLabel{#DiskSpanningGrp , NULL_STRING , NULL_STRING , NULL_STRING}

	SELF:oDCSpanningChk := CHECKBOX{SELF , ResourceID{ ADDWND_SPANNINGCHK  , _GetInst() } }
	SELF:oDCSpanningChk:HyperLabel := HyperLabel{#SpanningChk , "Disk Spanning" , NULL_STRING , NULL_STRING}

	SELF:oDCFormatChk := CHECKBOX{SELF , ResourceID{ ADDWND_FORMATCHK  , _GetInst() } }
	SELF:oDCFormatChk:HyperLabel := HyperLabel{#FormatChk , "Format each Disk" , NULL_STRING , NULL_STRING}

	SELF:oDCMaxSize := COMBOBOX{SELF , ResourceID{ ADDWND_MAXSIZE  , _GetInst() } }
	SELF:oDCMaxSize:FillUsing( SELF:FillFloppy() )
	SELF:oDCMaxSize:HyperLabel := HyperLabel{#MaxSize , NULL_STRING , NULL_STRING , NULL_STRING}

	SELF:oDCMinDisk1 := SINGLELINEEDIT{SELF , ResourceID{ ADDWND_MINDISK1  , _GetInst() } }
	SELF:oDCMinDisk1:HyperLabel := HyperLabel{#MinDisk1 , NULL_STRING , NULL_STRING , NULL_STRING}

	SELF:oDCMinFreeSize := SINGLELINEEDIT{SELF , ResourceID{ ADDWND_MINFREESIZE  , _GetInst() } }
	SELF:oDCMinFreeSize:HyperLabel := HyperLabel{#MinFreeSize , NULL_STRING , NULL_STRING , NULL_STRING}

	SELF:oCCDoItPB := PUSHBUTTON{SELF , ResourceID{ ADDWND_DOITPB  , _GetInst() } }
	SELF:oCCDoItPB:HyperLabel := HyperLabel{#DoItPB , "Do It" , NULL_STRING , NULL_STRING}

	SELF:oCCWildcardsPB := PUSHBUTTON{SELF , ResourceID{ ADDWND_WILDCARDSPB  , _GetInst() } }
	SELF:oCCWildcardsPB:HyperLabel := HyperLabel{#WildcardsPB , "&With Wildcards" , NULL_STRING , NULL_STRING}

	SELF:oCCCancelPB := PUSHBUTTON{SELF , ResourceID{ ADDWND_CANCELPB  , _GetInst() } }
	SELF:oCCCancelPB:HyperLabel := HyperLabel{#CancelPB , "&Cancel" , NULL_STRING , NULL_STRING}

	SELF:oDCFixedText1 := FIXEDTEXT{SELF , ResourceID{ ADDWND_FIXEDTEXT1  , _GetInst() } }
	SELF:oDCFixedText1:HyperLabel := HyperLabel{#FixedText1 , "Files :" , NULL_STRING , NULL_STRING}

	SELF:oDCFixedText2 := FIXEDTEXT{SELF , ResourceID{ ADDWND_FIXEDTEXT2  , _GetInst() } }
	SELF:oDCFixedText2:HyperLabel := HyperLabel{#FixedText2 , "Action" , NULL_STRING , NULL_STRING}

	SELF:oDCFixedText3 := FIXEDTEXT{SELF , ResourceID{ ADDWND_FIXEDTEXT3  , _GetInst() } }
	SELF:oDCFixedText3:HyperLabel := HyperLabel{#FixedText3 , "Compression Level" , NULL_STRING , NULL_STRING}

	SELF:oDCFixedText4 := FIXEDTEXT{SELF , ResourceID{ ADDWND_FIXEDTEXT4  , _GetInst() } }
	SELF:oDCFixedText4:HyperLabel := HyperLabel{#FixedText4 , "Min" , NULL_STRING , NULL_STRING}

	SELF:oDCFixedText5 := FIXEDTEXT{SELF , ResourceID{ ADDWND_FIXEDTEXT5  , _GetInst() } }
	SELF:oDCFixedText5:HyperLabel := HyperLabel{#FixedText5 , "Max" , NULL_STRING , NULL_STRING}

	SELF:oDCFoldersGrp := GROUPBOX{SELF , ResourceID{ ADDWND_FOLDERSGRP  , _GetInst() } }
	SELF:oDCFoldersGrp:HyperLabel := HyperLabel{#FoldersGrp , "Folders" , NULL_STRING , NULL_STRING}

	SELF:oDCFixedText6 := FIXEDTEXT{SELF , ResourceID{ ADDWND_FIXEDTEXT6  , _GetInst() } }
	SELF:oDCFixedText6:HyperLabel := HyperLabel{#FixedText6 , "Archive Size kb" , NULL_STRING , NULL_STRING}

	SELF:oDCDiskSizeGrp := GROUPBOX{SELF , ResourceID{ ADDWND_DISKSIZEGRP  , _GetInst() } }
	SELF:oDCDiskSizeGrp:HyperLabel := HyperLabel{#DiskSizeGrp , "Disk Size" , NULL_STRING , NULL_STRING}

	SELF:oDCFixedText7 := FIXEDTEXT{SELF , ResourceID{ ADDWND_FIXEDTEXT7  , _GetInst() } }
	SELF:oDCFixedText7:HyperLabel := HyperLabel{#FixedText7 , "Min Free Size" , NULL_STRING , NULL_STRING}

	SELF:oDCFixedText8 := FIXEDTEXT{SELF , ResourceID{ ADDWND_FIXEDTEXT8  , _GetInst() } }
	SELF:oDCFixedText8:HyperLabel := HyperLabel{#FixedText8 , "Min Free Size on Disk1" , NULL_STRING , NULL_STRING}

	SELF:Caption := "Add"
	SELF:HyperLabel := HyperLabel{#AddWnd , "Add" , NULL_STRING , NULL_STRING}

	SELF:PostInit(oParent,uExtra)

RETURN


METHOD ListBoxSelect(oControlEvent) 
	LOCAL oControl AS Control
	//
	oControl := IIf(oControlEvent == NULL_OBJECT, NULL_OBJECT, oControlEvent:Control)
	SUPER:ListBoxSelect(oControlEvent)
	//Put your changes here
	IF ( oControl != NULL_OBJECT )
		IF ( oControl:NameSym == #ActionCombo )
			IF !IsNil( SELF:oCCDoItPB )
				SELF:oCCDoItPB:Caption := "&" + Proper( AsString( SELF:oDCActionCombo:Value ) )
				SELF:symMode := SELF:oDCActionCombo:Value
			ENDIF
		ENDIF
	ENDIF
	RETURN NIL

METHOD PostInit(oParent,uExtra) 
	//Put your PostInit additions here
	SELF:oDCActionCombo:CurrentItemNo := 1
	SELF:oDCLevelSlider:Value := 9
	//
	SELF:aSelected := {}
	SELF:oCCDoItPb:Caption := "&Add"
	SELF:symMode := #Add
	//
	SELF:oAddOptions := uExtra
	//
	SELF:Caption := "Add From " + FabGetCurrentDir()
	//
	SELF:DisableSpanning()
	//
	RETURN NIL

METHOD SelectPB( ) 
	LOCAL oDlg	AS	OpenDialog
	LOCAL uFiles	AS	USUAL
	LOCAL cTotal	AS	STRING
	LOCAL aFiles	AS	ARRAY
	LOCAL nCpt		AS	WORD
	//
	oDlg := OpenDialog{ SELF }
	oDlg:Caption := "Select Files"
	oDlg:SetStyle( OFN_ALLOWMULTISELECT )
	oDlg:SetStyle( OFN_HIDEREADONLY )
	// TODO Port of FabOpenDialogEx
	//oDlg:OkText := "Select"
	oDlg:Show()
	//
	uFiles := oDlg:FileName
	IF IsArray( uFiles )
		cTotal := ""
		aFiles := {}
		FOR nCpt := 1 TO ALen( uFiles )
			AAdd( aFiles, FileSpec{ uFiles[ nCpt ] } )
			//			
			cTotal := cTotal + "," + aFiles[ nCpt ]:FileName + aFiles[ nCpt ]:Extension
			//
		NEXT
		cTotal := SubStr( cTotal, 2 )
		SELF:oDCFiles:TextValue := cTotal
	ELSE
		aFiles := {}
		AAdd( aFiles, FileSpec{ uFiles } )
		//		
		SELF:oDCFiles:TextValue := aFiles[ 1 ]:FileName + aFiles[ 1 ]:Extension
	ENDIF
	//
	SELF:aSelected := aFiles
	SELF:Caption := "Add From " + FabGetCurrentDir()

return self

METHOD WildcardsPB( ) 
	LOCAL oWildFile	AS	FileSpec
	//
	oWildFile := FileSpec{ }
	oWildFile:Path := FabGetCurrentDir()
	oWildFile:FileName := "*"
	oWildFile:Extension := ".*"
	//
	SELF:aSelected := { oWildFile }
	//
	SELF:DoItPB()
return self	
END CLASS

