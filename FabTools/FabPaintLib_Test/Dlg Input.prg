#include "VOSystemLibrary.vh"
#include "VOWin32APILibrary.vh"
#include "Dlg Input.vh"
class InputBox inherit DIALOGWINDOW 

	export oDCValue1Txt as FIXEDTEXT
	export oDCValue1 as SINGLELINEEDIT
	export oDCValue2 as SINGLELINEEDIT
	export oDCValue2Txt as FIXEDTEXT
	export oDCValue3Txt as FIXEDTEXT
	export oDCValue3 as SINGLELINEEDIT
	export oDCValue4 as SINGLELINEEDIT
	export oDCValue4Txt as FIXEDTEXT
	export oCCOkPB as PUSHBUTTON
	export oCCCancelPB as PUSHBUTTON

  //{{%UC%}} USER CODE STARTS HERE (do NOT remove this line)

METHOD CancelPB( ) 
	self:EndDialog( 0 )
return self	

CONSTRUCTOR(oParent,uExtra)  

self:PreInit(oParent,uExtra)

super(oParent,ResourceID{"InputBox",_GetInst()},TRUE)

oDCValue1Txt := FixedText{self,ResourceID{INPUTBOX_VALUE1TXT,_GetInst()}}
oDCValue1Txt:HyperLabel := HyperLabel{#Value1Txt,"Value1",NULL_STRING,NULL_STRING}

oDCValue1 := SingleLineEdit{self,ResourceID{INPUTBOX_VALUE1,_GetInst()}}
oDCValue1:HyperLabel := HyperLabel{#Value1,NULL_STRING,NULL_STRING,NULL_STRING}

oDCValue2 := SingleLineEdit{self,ResourceID{INPUTBOX_VALUE2,_GetInst()}}
oDCValue2:HyperLabel := HyperLabel{#Value2,NULL_STRING,NULL_STRING,NULL_STRING}

oDCValue2Txt := FixedText{self,ResourceID{INPUTBOX_VALUE2TXT,_GetInst()}}
oDCValue2Txt:HyperLabel := HyperLabel{#Value2Txt,"Value2",NULL_STRING,NULL_STRING}

oDCValue3Txt := FixedText{self,ResourceID{INPUTBOX_VALUE3TXT,_GetInst()}}
oDCValue3Txt:HyperLabel := HyperLabel{#Value3Txt,"Value3",NULL_STRING,NULL_STRING}

oDCValue3 := SingleLineEdit{self,ResourceID{INPUTBOX_VALUE3,_GetInst()}}
oDCValue3:HyperLabel := HyperLabel{#Value3,NULL_STRING,NULL_STRING,NULL_STRING}

oDCValue4 := SingleLineEdit{self,ResourceID{INPUTBOX_VALUE4,_GetInst()}}
oDCValue4:HyperLabel := HyperLabel{#Value4,NULL_STRING,NULL_STRING,NULL_STRING}

oDCValue4Txt := FixedText{self,ResourceID{INPUTBOX_VALUE4TXT,_GetInst()}}
oDCValue4Txt:HyperLabel := HyperLabel{#Value4Txt,"Value4",NULL_STRING,NULL_STRING}

oCCOkPB := PushButton{self,ResourceID{INPUTBOX_OKPB,_GetInst()}}
oCCOkPB:HyperLabel := HyperLabel{#OkPB,_chr(38)+"Ok",NULL_STRING,NULL_STRING}

oCCCancelPB := PushButton{self,ResourceID{INPUTBOX_CANCELPB,_GetInst()}}
oCCCancelPB:HyperLabel := HyperLabel{#CancelPB,_chr(38)+"Cancel",NULL_STRING,NULL_STRING}

self:Caption := "Parameters"
self:HyperLabel := HyperLabel{#InputBox,"Parameters",NULL_STRING,NULL_STRING}

self:PostInit(oParent,uExtra)

return 

METHOD OkPB( ) 
	SELF:EndDialog( 1 )
return self
END CLASS

