using FabZip
using VO


STATIC DEFINE SFXWND_OKPB := 100
STATIC DEFINE SFXWND_HELPPB := 101
STATIC DEFINE SFXWND_SFXCAPTION := 102
STATIC DEFINE SFXWND_FIXEDTEXT1 := 103
STATIC DEFINE SFXWND_SFXDEFAULTDIR := 104
STATIC DEFINE SFXWND_FIXEDTEXT2 := 105
STATIC DEFINE SFXWND_SFXCOMMANDLINE := 106
STATIC DEFINE SFXWND_FIXEDTEXT3 := 107
STATIC DEFINE SFXWND_CMDCHK := 108
STATIC DEFINE SFXWND_FILESCHK := 109
STATIC DEFINE SFXWND_FIXEDTEXT4 := 110
STATIC DEFINE SFXWND_OVERCHK := 111
STATIC DEFINE SFXWND_OVERCOMBO := 112
STATIC DEFINE SFXWND_CANCELPB := 113
PARTIAL CLASS SFXWnd INHERIT DIALOGWINDOW
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

	// {{%UC%}} User code starts here (DO NOT remove this line)  
  	EXPORT SFXOpt	AS	FabSFXOptions

METHOD ButtonClick(oControlEvent) 
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

METHOD CancelPB( ) 
	//
	SELF:EndDialog(0)
 return self

METHOD HelpPB( ) 
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

CONSTRUCTOR(oParent,uExtra)

	SELF:PreInit(oParent,uExtra)

	SUPER(oParent , ResourceID{"SFXWnd" , _GetInst()} , TRUE)

	SELF:oCCOkPB := PUSHBUTTON{SELF , ResourceID{ SFXWND_OKPB  , _GetInst() } }
	SELF:oCCOkPB:HyperLabel := HyperLabel{#OkPB , "&Ok" , NULL_STRING , NULL_STRING}

	SELF:oCCHelpPB := PUSHBUTTON{SELF , ResourceID{ SFXWND_HELPPB  , _GetInst() } }
	SELF:oCCHelpPB:HyperLabel := HyperLabel{#HelpPB , "<< Help on this" , NULL_STRING , NULL_STRING}

	SELF:oDCSFXCaption := SINGLELINEEDIT{SELF , ResourceID{ SFXWND_SFXCAPTION  , _GetInst() } }
	SELF:oDCSFXCaption:HyperLabel := HyperLabel{#SFXCaption , NULL_STRING , NULL_STRING , NULL_STRING}

	SELF:oDCFixedText1 := FIXEDTEXT{SELF , ResourceID{ SFXWND_FIXEDTEXT1  , _GetInst() } }
	SELF:oDCFixedText1:HyperLabel := HyperLabel{#FixedText1 , "SFX Dialog Title :" , NULL_STRING , NULL_STRING}

	SELF:oDCSFXDefaultDir := SINGLELINEEDIT{SELF , ResourceID{ SFXWND_SFXDEFAULTDIR  , _GetInst() } }
	SELF:oDCSFXDefaultDir:HyperLabel := HyperLabel{#SFXDefaultDir , NULL_STRING , NULL_STRING , NULL_STRING}

	SELF:oDCFixedText2 := FIXEDTEXT{SELF , ResourceID{ SFXWND_FIXEDTEXT2  , _GetInst() } }
	SELF:oDCFixedText2:HyperLabel := HyperLabel{#FixedText2 , "Default Extract Dir :" , NULL_STRING , NULL_STRING}

	SELF:oDCSFXCommandLine := SINGLELINEEDIT{SELF , ResourceID{ SFXWND_SFXCOMMANDLINE  , _GetInst() } }
	SELF:oDCSFXCommandLine:HyperLabel := HyperLabel{#SFXCommandLine , NULL_STRING , NULL_STRING , NULL_STRING}

	SELF:oDCFixedText3 := FIXEDTEXT{SELF , ResourceID{ SFXWND_FIXEDTEXT3  , _GetInst() } }
	SELF:oDCFixedText3:HyperLabel := HyperLabel{#FixedText3 , "Command Line" , NULL_STRING , NULL_STRING}

	SELF:oDCCmdChk := CHECKBOX{SELF , ResourceID{ SFXWND_CMDCHK  , _GetInst() } }
	SELF:oDCCmdChk:HyperLabel := HyperLabel{#CmdChk , "User Can Deselect CommandLine" , NULL_STRING , NULL_STRING}

	SELF:oDCFilesChk := CHECKBOX{SELF , ResourceID{ SFXWND_FILESCHK  , _GetInst() } }
	SELF:oDCFilesChk:HyperLabel := HyperLabel{#FilesChk , "Can Select Files" , NULL_STRING , NULL_STRING}

	SELF:oDCFixedText4 := FIXEDTEXT{SELF , ResourceID{ SFXWND_FIXEDTEXT4  , _GetInst() } }
	SELF:oDCFixedText4:HyperLabel := HyperLabel{#FixedText4 , "Overwrite Mode" , NULL_STRING , NULL_STRING}

	SELF:oDCOverChk := CHECKBOX{SELF , ResourceID{ SFXWND_OVERCHK  , _GetInst() } }
	SELF:oDCOverChk:HyperLabel := HyperLabel{#OverChk , "Hide Overwrite Box" , NULL_STRING , NULL_STRING}

	SELF:oDCOverCombo := COMBOBOX{SELF , ResourceID{ SFXWND_OVERCOMBO  , _GetInst() } }
	SELF:oDCOverCombo:HyperLabel := HyperLabel{#OverCombo , NULL_STRING , NULL_STRING , NULL_STRING}

	SELF:oCCCancelPB := PUSHBUTTON{SELF , ResourceID{ SFXWND_CANCELPB  , _GetInst() } }
	SELF:oCCCancelPB:HyperLabel := HyperLabel{#CancelPB , "Cancel" , NULL_STRING , NULL_STRING}

	SELF:Caption := "SFX Options"
	SELF:HyperLabel := HyperLabel{#SFXWnd , "SFX Options" , NULL_STRING , NULL_STRING}

	SELF:PostInit(oParent,uExtra)

RETURN


METHOD OkPB( ) 
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

METHOD PostInit(oParent,uExtra) 
	//Put your PostInit additions here
	SELF:oDCOverCombo:FillUsing( { 	{ "Confirm", 0 }, ;
									{ "Always", 1 }, ;
									{ "Never", 2 } } )
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

