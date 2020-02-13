#include "VOSystemLibrary.vh"
#include "VOWin32APILibrary.vh"
#include "Dlg About.vh"
class HelpAbout inherit DIALOGWINDOW 

	protect oDCFixedIcon1 as FIXEDICON
	protect oDCFixedText1 as FIXEDTEXT
	protect oDCFixedText2 as FIXEDTEXT
	protect oCCPushButton1 as PUSHBUTTON

  //{{%UC%}} USER CODE STARTS HERE (do NOT remove this line)

CONSTRUCTOR(oParent,uExtra)  

self:PreInit(oParent,uExtra)

super(oParent,ResourceID{"HelpAbout",_GetInst()},TRUE)

oDCFixedIcon1 := FIXEDICON{self,ResourceID{HELPABOUT_FIXEDICON1,_GetInst()}}
oDCFixedIcon1:HyperLabel := HyperLabel{#FixedIcon1,"ImgViewIcon",NULL_STRING,NULL_STRING}

oDCFixedText1 := FixedText{self,ResourceID{HELPABOUT_FIXEDTEXT1,_GetInst()}}
oDCFixedText1:HyperLabel := HyperLabel{#FixedText1,"Image Viewer Application",NULL_STRING,NULL_STRING}

oDCFixedText2 := FixedText{self,ResourceID{HELPABOUT_FIXEDTEXT2,_GetInst()}}
oDCFixedText2:HyperLabel := HyperLabel{#FixedText2,"Build with VO Version 2.7",NULL_STRING,NULL_STRING}

oCCPushButton1 := PushButton{self,ResourceID{HELPABOUT_PUSHBUTTON1,_GetInst()}}
oCCPushButton1:HyperLabel := HyperLabel{#PushButton1,"OK",NULL_STRING,NULL_STRING}

self:Caption := "About FabImgView"
self:HyperLabel := HyperLabel{#HelpAbout,"About FabImgView",NULL_STRING,NULL_STRING}

self:PostInit(oParent,uExtra)

return 

method PushButton1() 

	self:EndDialog()
return self
	
END CLASS

