#include "..\Fab_Zip_1_52j___V2\GlobalDefines.vh"
#include "VOSystemLibrary.vh"
#include "VOWin32APILibrary.vh"
#include "About.vh"
class HelpAbout inherit DIALOGWINDOW 

	protect oCCDLLInfoPB as PUSHBUTTON
	protect oDCFixedText2 as FIXEDTEXT
	protect oDCFixedIcon1 as FIXEDICON
	protect oDCFabZipVersion as FIXEDTEXT
	protect oDCFixedText3 as FIXEDTEXT
	protect oCCOkPB as PUSHBUTTON

  //{{%UC%}} USER CODE STARTS HERE (do NOT remove this line)

METHOD DLLInfoPB( ) CLASS HelpAbout
	//
	FabMessageInfo( "Unzip DLL Version : " + NTrim( GetUnzDllVersion( ) ) + CRLF + ;
	"Zip DLL Version : " + NTrim( GetZipDllVersion() ), "Info" )
return self

method Init(oParent,uExtra) class HelpAbout 

self:PreInit(oParent,uExtra)

super:Init(oParent,ResourceID{"HelpAbout",_GetInst()},TRUE)

oCCDLLInfoPB := PushButton{self,ResourceID{HELPABOUT_DLLINFOPB,_GetInst()}}
oCCDLLInfoPB:HyperLabel := HyperLabel{#DLLInfoPB,"DLL Info",NULL_STRING,NULL_STRING}

oDCFixedText2 := FixedText{self,ResourceID{HELPABOUT_FIXEDTEXT2,_GetInst()}}
oDCFixedText2:HyperLabel := HyperLabel{#FixedText2,"fabrice@fabtoys.net",NULL_STRING,NULL_STRING}

oDCFixedIcon1 := FIXEDICON{self,ResourceID{HELPABOUT_FIXEDICON1,_GetInst()}}
oDCFixedIcon1:HyperLabel := HyperLabel{#FixedIcon1,"DELZIP",NULL_STRING,NULL_STRING}

oDCFabZipVersion := FixedText{self,ResourceID{HELPABOUT_FABZIPVERSION,_GetInst()}}
oDCFabZipVersion:HyperLabel := HyperLabel{#FabZipVersion,"FabZip Library V",NULL_STRING,NULL_STRING}

oDCFixedText3 := FixedText{self,ResourceID{HELPABOUT_FIXEDTEXT3,_GetInst()}}
oDCFixedText3:HyperLabel := HyperLabel{#FixedText3,"© 1997-2007 Fabrice Foray",NULL_STRING,NULL_STRING}

oCCOkPB := PushButton{self,ResourceID{HELPABOUT_OKPB,_GetInst()}}
oCCOkPB:HyperLabel := HyperLabel{#OkPB,"OK",NULL_STRING,NULL_STRING}

self:Caption := "About FabZip Test"
self:HyperLabel := HyperLabel{#HelpAbout,"About FabZip Test",NULL_STRING,NULL_STRING}

self:PostInit(oParent,uExtra)

return self

METHOD OkPB( ) CLASS HelpAbout
	SELF:EndDialog()
return self

METHOD PostInit(oParent,uExtra) CLASS HelpAbout
	//Put your PostInit additions here
	SELF:oDCFabZipVersion:TextValue := SELF:oDCFabZipVersion:TextValue + FABZIP_VERSION
	RETURN NIL

END CLASS

