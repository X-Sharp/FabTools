#include "VOSystemLibrary.vh"
#include "VOWin32APILibrary.vh"
#include "Dlg About.vh"
STATIC DEFINE HELPABOUT_FIXEDICON1 := 100
STATIC DEFINE HELPABOUT_FIXEDTEXT1 := 101
STATIC DEFINE HELPABOUT_FIXEDTEXT2 := 102
STATIC DEFINE HELPABOUT_PUSHBUTTON1 := 103
PARTIAL CLASS HelpAbout INHERIT DIALOGWINDOW
	PROTECT oDCFixedIcon1 AS FIXEDICON
	PROTECT oDCFixedText1 AS FIXEDTEXT
	PROTECT oDCFixedText2 AS FIXEDTEXT
	PROTECT oCCPushButton1 AS PUSHBUTTON

	// {{%UC%}} User code starts here (DO NOT remove this line)  

CONSTRUCTOR(oParent,uExtra)

	SELF:PreInit(oParent,uExtra)

	SUPER(oParent , ResourceID{"HelpAbout" , _GetInst()} , TRUE)

	SELF:oDCFixedIcon1 := FIXEDICON{SELF , ResourceID{ HELPABOUT_FIXEDICON1  , _GetInst() } }
	SELF:oDCFixedIcon1:HyperLabel := HyperLabel{#FixedIcon1 , "ImgViewIcon" , NULL_STRING , NULL_STRING}

	SELF:oDCFixedText1 := FIXEDTEXT{SELF , ResourceID{ HELPABOUT_FIXEDTEXT1  , _GetInst() } }
	SELF:oDCFixedText1:HyperLabel := HyperLabel{#FixedText1 , "Image Viewer Application" , NULL_STRING , NULL_STRING}

	SELF:oDCFixedText2 := FIXEDTEXT{SELF , ResourceID{ HELPABOUT_FIXEDTEXT2  , _GetInst() } }
	SELF:oDCFixedText2:HyperLabel := HyperLabel{#FixedText2 , "Build with VO Version 2.7" , NULL_STRING , NULL_STRING}

	SELF:oCCPushButton1 := PUSHBUTTON{SELF , ResourceID{ HELPABOUT_PUSHBUTTON1  , _GetInst() } }
	SELF:oCCPushButton1:HyperLabel := HyperLabel{#PushButton1 , "OK" , NULL_STRING , NULL_STRING}

	SELF:Caption := "About FabImgView"
	SELF:HyperLabel := HyperLabel{#HelpAbout , "About FabImgView" , NULL_STRING , NULL_STRING}

	SELF:PostInit(oParent,uExtra)

RETURN


method PushButton1() 

	self:EndDialog()
return self
	
END CLASS

