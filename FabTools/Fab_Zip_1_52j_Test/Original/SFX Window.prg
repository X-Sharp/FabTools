#include "..\Fab_Zip_1_52j___V2\GlobalDefines.vh"
#include "VOSystemLibrary.vh"
#include "VOWin32APILibrary.vh"
#include "SFX Window.vh"
CLASS SFXWnd INHERIT DIALOGWINDOW

	PROTECT oCCOkPB AS PUSHBUTTON
	PROTECT oCCHelpPB AS PUSHBUTTON
	PROTECT oDCSFXCaption AS SINGLELINEEDIT
	PROTECT oDCFixedText1 AS FIXEDTEXT
	PROTECT oDCSFXDefaultDir AS SINGLELINEEDIT
	PROTECT oDCFixedText2 AS FIXEDTEXT
	PROTECT oDCSFXCommandLine AS SINGLELINEEDIT
	PROTECT oDCFixedText3 AS FIXEDTEXT
	PROTECT oDCCmdChk AS CHECKBOX
	PROTECT oDCFilesChk AS CHECKBOX
	PROTECT oDCFixedText4 AS FIXEDTEXT
	PROTECT oDCOverChk AS CHECKBOX
	PROTECT oDCOverCombo AS COMBOBOX
	PROTECT oCCCancelPB AS PUSHBUTTON

  //USER CODE STARTS HERE (do NOT remove this line)
  	EXPORT SFXOpt	AS	FabSFXOptions

METHOD ButtonClick(oControlEvent) CLASS SFXWnd
	LOCAL oControl AS Control
	oControl := IIf(oControlEvent == NULL_OBJECT, NULL_OBJECT, oControlEvent:Control)
	SUPER:ButtonClick(oControlEvent)
	//Put your changes here
	IF (  oControl != NULL_OBJECT )
		IF ( oControl:NameSym == #OverChk )
			IF ( SELF:oDCOverChk:Checked )
				SELF:oDCOverCombo:Enable()
			ELSE
				SELF:oDCOverCombo:Disable()
			ENDIF
		ENDIF
	ENDIF
	RETURN NIL

METHOD CancelPB( ) CLASS SFXWnd
	//
	SELF:EndDialog(0)
 return self

METHOD HelpPB( ) CLASS SFXWnd
	LOCAL cText	AS	STRING
	//
	cText := "This command line will be executed immediately after extracting the files." + CRLF
	cText := cText + "Typically used to show the readme file, but can do anything. There is a predefined symbol that can be used" + CRLF
	cText := cText + " in the command line to tell you which target directory was actually used (since the user can always change your default)." + CRLF
	cText := cText + "Special symbols:" + CRLF
	cText := cText + " 	'|' is the command/arg separator" + CRLF
	cText := cText + "	'><' is the actual extraction dir selected by user" + CRLF
	cText := cText + "Example:" + CRLF
	cText := cText + "	notepad.exe|><readme.txt" + CRLF
	cText := cText + "Run notepad to show 'readme.txt' in the actual extraction directory." + CRLF
	cText := cText + "( This is an optional property. )"
	//
	FabMessageInfo( cText )
	//
return self

method Init(oParent,uExtra) class SFXWnd 

self:PreInit(oParent,uExtra)

super:Init(oParent,ResourceID{"SFXWnd",_GetInst()},TRUE)

oCCOkPB := PushButton{self,ResourceID{SFXWND_OKPB,_GetInst()}}
oCCOkPB:HyperLabel := HyperLabel{#OkPB,_chr(38)+"Ok",NULL_STRING,NULL_STRING}

oCCHelpPB := PushButton{self,ResourceID{SFXWND_HELPPB,_GetInst()}}
oCCHelpPB:HyperLabel := HyperLabel{#HelpPB,"<< Help on this",NULL_STRING,NULL_STRING}

oDCSFXCaption := SingleLineEdit{self,ResourceID{SFXWND_SFXCAPTION,_GetInst()}}
oDCSFXCaption:HyperLabel := HyperLabel{#SFXCaption,NULL_STRING,NULL_STRING,NULL_STRING}

oDCFixedText1 := FixedText{self,ResourceID{SFXWND_FIXEDTEXT1,_GetInst()}}
oDCFixedText1:HyperLabel := HyperLabel{#FixedText1,"SFX Dialog Title :",NULL_STRING,NULL_STRING}

oDCSFXDefaultDir := SingleLineEdit{self,ResourceID{SFXWND_SFXDEFAULTDIR,_GetInst()}}
oDCSFXDefaultDir:HyperLabel := HyperLabel{#SFXDefaultDir,NULL_STRING,NULL_STRING,NULL_STRING}

oDCFixedText2 := FixedText{self,ResourceID{SFXWND_FIXEDTEXT2,_GetInst()}}
oDCFixedText2:HyperLabel := HyperLabel{#FixedText2,"Default Extract Dir :",NULL_STRING,NULL_STRING}

oDCSFXCommandLine := SingleLineEdit{self,ResourceID{SFXWND_SFXCOMMANDLINE,_GetInst()}}
oDCSFXCommandLine:HyperLabel := HyperLabel{#SFXCommandLine,NULL_STRING,NULL_STRING,NULL_STRING}

oDCFixedText3 := FixedText{self,ResourceID{SFXWND_FIXEDTEXT3,_GetInst()}}
oDCFixedText3:HyperLabel := HyperLabel{#FixedText3,"Command Line",NULL_STRING,NULL_STRING}

oDCCmdChk := CheckBox{self,ResourceID{SFXWND_CMDCHK,_GetInst()}}
oDCCmdChk:HyperLabel := HyperLabel{#CmdChk,"User Can Deselect CommandLine",NULL_STRING,NULL_STRING}

oDCFilesChk := CheckBox{self,ResourceID{SFXWND_FILESCHK,_GetInst()}}
oDCFilesChk:HyperLabel := HyperLabel{#FilesChk,"Can Select Files",NULL_STRING,NULL_STRING}

oDCFixedText4 := FixedText{self,ResourceID{SFXWND_FIXEDTEXT4,_GetInst()}}
oDCFixedText4:HyperLabel := HyperLabel{#FixedText4,"Overwrite Mode",NULL_STRING,NULL_STRING}

oDCOverChk := CheckBox{self,ResourceID{SFXWND_OVERCHK,_GetInst()}}
oDCOverChk:HyperLabel := HyperLabel{#OverChk,"Hide Overwrite Box",NULL_STRING,NULL_STRING}

oDCOverCombo := combobox{self,ResourceID{SFXWND_OVERCOMBO,_GetInst()}}
oDCOverCombo:HyperLabel := HyperLabel{#OverCombo,NULL_STRING,NULL_STRING,NULL_STRING}

oCCCancelPB := PushButton{self,ResourceID{SFXWND_CANCELPB,_GetInst()}}
oCCCancelPB:HyperLabel := HyperLabel{#CancelPB,"Cancel",NULL_STRING,NULL_STRING}

self:Caption := "SFX Options"
self:HyperLabel := HyperLabel{#SFXWnd,"SFX Options",NULL_STRING,NULL_STRING}

self:PostInit(oParent,uExtra)

return self

METHOD OkPB( ) CLASS SFXWnd
	//
	SELF:SFXOpt:Caption := SELF:oDCSFXCaption:TEXTValue
	SELF:SFXOpt:DefaultDir := SELF:oDCSFXDefaultDir:TEXTValue
	SELF:SFXOpt:CommandLine := SELF:oDCSFXCommandLine:TEXTValue
	//
	SELF:SFXOpt:AskCmdLine :=  SELF:oDCCmdChk:Checked
	SELF:SFXOpt:AskFiles := SELF: oDCFilesChk:Checked
	SELF:SFXOpt:HideOverwriteBox := SELF: oDCOverChk:Checked
	SELF:SFXOpt:OverwriteMode := SELF:oDCOverCombo:Value
	//
	SELF:EndDialog(1)
return self	

METHOD PostInit(oParent,uExtra) CLASS SFXWnd
	//Put your PostInit additions here
	SELF:oDCOverCombo:FillUsing( { 	{ "Confirm", FABZIP_ovrConfirm }, ;
									{ "Always", FABZIP_ovrAlways }, ;
									{ "Never", FABZIP_ovrNever } } )
	//
	SELF:oDCSFXCaption:TEXTValue := uExtra:Caption
	SELF:oDCSFXDefaultDir:TEXTValue := uExtra:DefaultDir
	SELF:oDCSFXCommandLine:TEXTValue := uExtra:CommandLine
	//
	SELF:oDCCmdChk:Checked := uExtra:AskCmdLine
	SELF: oDCFilesChk:Checked := uExtra:AskFiles
	SELF: oDCOverChk:Checked := uExtra:HideOverwriteBox
	SELF:oDCOverCombo:Value := uExtra:OverwriteMode
	//
	IF ( SELF:oDCOverChk:Checked )
		SELF:oDCOverCombo:Enable()
	ELSE
		SELF:oDCOverCombo:Disable()
	ENDIF
	//
	SELF:SFXOpt := uExtra
	RETURN NIL

END CLASS

