// 
using FabZip
using VO

STATIC DEFINE HELPABOUT_FIXEDICON1 := 100
STATIC DEFINE HELPABOUT_FABZIPVERSION := 101
STATIC DEFINE HELPABOUT_DLLINFOPB := 102
STATIC DEFINE HELPABOUT_FIXEDTEXT2 := 103
STATIC DEFINE HELPABOUT_FIXEDTEXT3 := 104
STATIC DEFINE HELPABOUT_OKPB := 105
PARTIAL CLASS HelpAbout INHERIT DIALOGWINDOW
	PROTECT oDCFixedIcon1 AS FIXEDICON
	PROTECT oDCFabZipVersion AS FIXEDTEXT
	PROTECT oCCDLLInfoPB AS PUSHBUTTON
	PROTECT oDCFixedText2 AS FIXEDTEXT
	PROTECT oDCFixedText3 AS FIXEDTEXT
	PROTECT oCCOkPB AS PUSHBUTTON

	// {{%UC%}} User code starts here (DO NOT remove this line)  

METHOD DLLInfoPB( ) 
	// HACK 
	FabMessageInfo( "Unzip DLL Version : " + NTrim( GetUnzDllVersion( ) ) + CRLF + "Zip DLL Version : " + NTrim( GetZipDllVersion() ), "Info" )
return self

CONSTRUCTOR(oParent,uExtra)

	SELF:PreInit(oParent,uExtra)

	SUPER(oParent , ResourceID{"HelpAbout" , _GetInst()} , TRUE)

	SELF:oDCFixedIcon1 := FIXEDICON{SELF , ResourceID{ HELPABOUT_FIXEDICON1  , _GetInst() } }
	SELF:oDCFixedIcon1:HyperLabel := HyperLabel{#FixedIcon1 , "DELZIP" , NULL_STRING , NULL_STRING}

	SELF:oDCFabZipVersion := FIXEDTEXT{SELF , ResourceID{ HELPABOUT_FABZIPVERSION  , _GetInst() } }
	SELF:oDCFabZipVersion:HyperLabel := HyperLabel{#FabZipVersion , "FabZip Library V" , NULL_STRING , NULL_STRING}

	SELF:oCCDLLInfoPB := PUSHBUTTON{SELF , ResourceID{ HELPABOUT_DLLINFOPB  , _GetInst() } }
	SELF:oCCDLLInfoPB:HyperLabel := HyperLabel{#DLLInfoPB , "DLL Info" , NULL_STRING , NULL_STRING}

	SELF:oDCFixedText2 := FIXEDTEXT{SELF , ResourceID{ HELPABOUT_FIXEDTEXT2  , _GetInst() } }
	SELF:oDCFixedText2:HyperLabel := HyperLabel{#FixedText2 , "fabrice@xsharp.eu" , NULL_STRING , NULL_STRING}

	SELF:oDCFixedText3 := FIXEDTEXT{SELF , ResourceID{ HELPABOUT_FIXEDTEXT3  , _GetInst() } }
	SELF:oDCFixedText3:HyperLabel := HyperLabel{#FixedText3 , "© 1997-2020 Fabrice Foray" , NULL_STRING , NULL_STRING}

	SELF:oCCOkPB := PUSHBUTTON{SELF , ResourceID{ HELPABOUT_OKPB  , _GetInst() } }
	SELF:oCCOkPB:HyperLabel := HyperLabel{#OkPB , "OK" , NULL_STRING , NULL_STRING}

	SELF:Caption := "About FabZip Test"
	SELF:HyperLabel := HyperLabel{#HelpAbout , "About FabZip Test" , NULL_STRING , NULL_STRING}

	SELF:PostInit(oParent,uExtra)

RETURN


METHOD OkPB( ) 
	SELF:EndDialog()
return self

METHOD PostInit(oParent,uExtra) 
	//Put your PostInit additions here
	SELF:oDCFabZipVersion:TextValue := SELF:oDCFabZipVersion:TextValue + "1.0" //FABZIP_VERSION
	RETURN NIL

END CLASS

