#include "VOSystemLibrary.vh"
#include "VOWin32APILibrary.vh"
#include "Add Window.vh"
CLASS AddWnd INHERIT DIALOGWINDOW

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

  //USER CODE STARTS HERE (do NOT remove this line)
  	EXPORT	aSelected	AS	ARRAY
  	EXPORT	symMode		AS	SYMBOL
  	EXPORT	Level		AS	LONG
	EXPORT	oAddOptions	AS	FabAddOptions
	//
	EXPORT	MaxSize		AS	LONG
	EXPORT	MinDisk1	AS	LONG
	EXPORT	MinSize		AS	LONG
	

METHOD ButtonClick(oControlEvent) CLASS AddWnd
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

METHOD CancelPB( ) CLASS AddWnd
	SELF:EndDialog( 0 )
return self

METHOD DisableSpanning() CLASS AddWnd
	SELF:oDCFormatChk:Disable()
	SELF:oDCMaxSize:Disable()
	SELF:oDCMinDisk1:Disable()
	SELF:oDCMinFreeSize:Disable()
return self

METHOD DoItPB( ) CLASS AddWnd
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
		SELF:MaxSize := Val( SELF:oDCMaxSize:TextValue ) * 1000
		//
		SELF:MinDisk1:= Val( SELF:oDCMinDisk1:TextValue )
		SELF:MinSize := Val( SELF:oDCMinFreeSize:TextValue )
	ENDIF
	//
	SELF:EndDialog( 1 )
	
 return self

METHOD EnableSpanning() CLASS AddWnd
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

METHOD	FillAction( )	CLASS	AddWnd
RETURN	( { {"Add & Replace Files", #Add}, ;
			{"Move Files", #Move}, ;
			{"Update & Add Files",#Update}, ;
			{"Freshen Existing Files",#Freshen} } )

METHOD	FillFloppy( )	CLASS	AddWnd
RETURN	( { { "Automatic", 0 } ,	;
			{ "720", 720 },			;
			{ "1440", 1440 },		;
			{ "2880", 2880 },		;
			{ "100000", 100000}	}	)


method Init(oParent,uExtra) class AddWnd 

self:PreInit(oParent,uExtra)

super:Init(oParent,ResourceID{"AddWnd",_GetInst()},TRUE)

oDCFiles := SingleLineEdit{self,ResourceID{ADDWND_FILES,_GetInst()}}
oDCFiles:HyperLabel := HyperLabel{#Files,NULL_STRING,NULL_STRING,NULL_STRING}

oCCSelectPB := PushButton{self,ResourceID{ADDWND_SELECTPB,_GetInst()}}
oCCSelectPB:HyperLabel := HyperLabel{#SelectPB,"->",NULL_STRING,NULL_STRING}
oCCSelectPB:TooltipText := "Select"

oDCActionCombo := combobox{self,ResourceID{ADDWND_ACTIONCOMBO,_GetInst()}}
oDCActionCombo:FillUsing(Self:FillAction( ))
oDCActionCombo:HyperLabel := HyperLabel{#ActionCombo,NULL_STRING,NULL_STRING,NULL_STRING}

oDCLevelSlider := HorizontalSlider{self,ResourceID{ADDWND_LEVELSLIDER,_GetInst()}}
oDCLevelSlider:Range := Range{0,9}
oDCLevelSlider:HyperLabel := HyperLabel{#LevelSlider,NULL_STRING,NULL_STRING,NULL_STRING}

oDCDosFormatChk := CheckBox{self,ResourceID{ADDWND_DOSFORMATCHK,_GetInst()}}
oDCDosFormatChk:HyperLabel := HyperLabel{#DosFormatChk,"FileNames in 8.3 format",NULL_STRING,NULL_STRING}

oDCSystemChk := CheckBox{self,ResourceID{ADDWND_SYSTEMCHK,_GetInst()}}
oDCSystemChk:HyperLabel := HyperLabel{#SystemChk,"Include System and Hidden Files",NULL_STRING,NULL_STRING}

oDCRecurseChk := CheckBox{self,ResourceID{ADDWND_RECURSECHK,_GetInst()}}
oDCRecurseChk:HyperLabel := HyperLabel{#RecurseChk,"Recurse into Subdirectories",NULL_STRING,NULL_STRING}

oDCDirInfoChk := CheckBox{self,ResourceID{ADDWND_DIRINFOCHK,_GetInst()}}
oDCDirInfoChk:HyperLabel := HyperLabel{#DirInfoChk,"Store Dirnames with files",NULL_STRING,NULL_STRING}

oDCDiskSpanningGrp := GroupBox{self,ResourceID{ADDWND_DISKSPANNINGGRP,_GetInst()}}
oDCDiskSpanningGrp:HyperLabel := HyperLabel{#DiskSpanningGrp,NULL_STRING,NULL_STRING,NULL_STRING}

oDCSpanningChk := CheckBox{self,ResourceID{ADDWND_SPANNINGCHK,_GetInst()}}
oDCSpanningChk:HyperLabel := HyperLabel{#SpanningChk,"Disk Spanning",NULL_STRING,NULL_STRING}

oDCFormatChk := CheckBox{self,ResourceID{ADDWND_FORMATCHK,_GetInst()}}
oDCFormatChk:HyperLabel := HyperLabel{#FormatChk,"Format each Disk",NULL_STRING,NULL_STRING}

oDCMaxSize := combobox{self,ResourceID{ADDWND_MAXSIZE,_GetInst()}}
oDCMaxSize:HyperLabel := HyperLabel{#MaxSize,NULL_STRING,NULL_STRING,NULL_STRING}
oDCMaxSize:FillUsing(Self:FillFloppy( ))

oDCMinDisk1 := SingleLineEdit{self,ResourceID{ADDWND_MINDISK1,_GetInst()}}
oDCMinDisk1:HyperLabel := HyperLabel{#MinDisk1,NULL_STRING,NULL_STRING,NULL_STRING}

oDCMinFreeSize := SingleLineEdit{self,ResourceID{ADDWND_MINFREESIZE,_GetInst()}}
oDCMinFreeSize:HyperLabel := HyperLabel{#MinFreeSize,NULL_STRING,NULL_STRING,NULL_STRING}

oCCDoItPB := PushButton{self,ResourceID{ADDWND_DOITPB,_GetInst()}}
oCCDoItPB:HyperLabel := HyperLabel{#DoItPB,"Do It",NULL_STRING,NULL_STRING}

oCCWildcardsPB := PushButton{self,ResourceID{ADDWND_WILDCARDSPB,_GetInst()}}
oCCWildcardsPB:HyperLabel := HyperLabel{#WildcardsPB,_chr(38)+"With Wildcards",NULL_STRING,NULL_STRING}

oCCCancelPB := PushButton{self,ResourceID{ADDWND_CANCELPB,_GetInst()}}
oCCCancelPB:HyperLabel := HyperLabel{#CancelPB,_chr(38)+"Cancel",NULL_STRING,NULL_STRING}

oDCFixedText1 := FixedText{self,ResourceID{ADDWND_FIXEDTEXT1,_GetInst()}}
oDCFixedText1:HyperLabel := HyperLabel{#FixedText1,"Files :",NULL_STRING,NULL_STRING}

oDCFixedText2 := FixedText{self,ResourceID{ADDWND_FIXEDTEXT2,_GetInst()}}
oDCFixedText2:HyperLabel := HyperLabel{#FixedText2,"Action",NULL_STRING,NULL_STRING}

oDCFixedText3 := FixedText{self,ResourceID{ADDWND_FIXEDTEXT3,_GetInst()}}
oDCFixedText3:HyperLabel := HyperLabel{#FixedText3,"Compression Level",NULL_STRING,NULL_STRING}

oDCFixedText4 := FixedText{self,ResourceID{ADDWND_FIXEDTEXT4,_GetInst()}}
oDCFixedText4:HyperLabel := HyperLabel{#FixedText4,"Min",NULL_STRING,NULL_STRING}

oDCFixedText5 := FixedText{self,ResourceID{ADDWND_FIXEDTEXT5,_GetInst()}}
oDCFixedText5:HyperLabel := HyperLabel{#FixedText5,"Max",NULL_STRING,NULL_STRING}

oDCFoldersGrp := GroupBox{self,ResourceID{ADDWND_FOLDERSGRP,_GetInst()}}
oDCFoldersGrp:HyperLabel := HyperLabel{#FoldersGrp,"Folders",NULL_STRING,NULL_STRING}

oDCFixedText6 := FixedText{self,ResourceID{ADDWND_FIXEDTEXT6,_GetInst()}}
oDCFixedText6:HyperLabel := HyperLabel{#FixedText6,"Archive Size (kb)",NULL_STRING,NULL_STRING}

oDCDiskSizeGrp := GroupBox{self,ResourceID{ADDWND_DISKSIZEGRP,_GetInst()}}
oDCDiskSizeGrp:HyperLabel := HyperLabel{#DiskSizeGrp,"Disk Size",NULL_STRING,NULL_STRING}

oDCFixedText7 := FixedText{self,ResourceID{ADDWND_FIXEDTEXT7,_GetInst()}}
oDCFixedText7:HyperLabel := HyperLabel{#FixedText7,"Min Free Size",NULL_STRING,NULL_STRING}

oDCFixedText8 := FixedText{self,ResourceID{ADDWND_FIXEDTEXT8,_GetInst()}}
oDCFixedText8:HyperLabel := HyperLabel{#FixedText8,"Min Free Size on Disk1",NULL_STRING,NULL_STRING}

self:Caption := "Add"
self:HyperLabel := HyperLabel{#AddWnd,"Add",NULL_STRING,NULL_STRING}

self:PostInit(oParent,uExtra)

return self

METHOD ListBoxSelect(oControlEvent) CLASS AddWnd
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

METHOD PostInit(oParent,uExtra) CLASS AddWnd
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

METHOD SelectPB( ) CLASS AddWnd
	LOCAL oDlg	AS	FabOpenDialogEx
	LOCAL uFiles	AS	USUAL
	LOCAL cTotal	AS	STRING
	LOCAL aFiles	AS	ARRAY
	LOCAL nCpt		AS	WORD
	//
	oDlg := FabOpenDialogEx{ SELF }
	oDlg:Caption := "Select Files"
	oDlg:SetStyle( OFN_ALLOWMULTISELECT )
	oDlg:SetStyle( OFN_HIDEREADONLY )
	oDlg:OkText := "Select"
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

METHOD WildcardsPB( ) CLASS AddWnd
	LOCAL oWildFile	AS	FileSpec
	//
	oWildFile := FileSpec{ FabGetCurrentDir() }
	oWildFile:FileName := "*"
	oWildFile:Extension := ".*"
	//
	SELF:aSelected := { oWildFile }
	//
	SELF:DoItPB()
return self	
END CLASS

