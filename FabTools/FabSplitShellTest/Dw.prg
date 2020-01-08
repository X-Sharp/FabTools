#region DEFINES
STATIC DEFINE MYWINDOW_CLOSEPB := 100 
#endregion

class MyWindow inherit DATAWINDOW 

	protect oCCClosePB as PUSHBUTTON

  //{{%UC%}} USER CODE STARTS HERE (do NOT remove this line)

METHOD ClosePB( ) 
	SELF:EndWindow()
return self

CONSTRUCTOR(oWindow,iCtlID,oServer,uExtra)  

self:PreInit(oWindow,iCtlID,oServer,uExtra)

SUPER(oWindow,ResourceID{"MyWindow",_GetInst()},iCtlID)

oCCClosePB := PushButton{self,ResourceID{MYWINDOW_CLOSEPB,_GetInst()}}
oCCClosePB:HyperLabel := HyperLabel{#ClosePB,_chr(38)+"Close",NULL_STRING,NULL_STRING}

self:Caption := "DataWindow Caption"
self:HyperLabel := HyperLabel{#MyWindow,"DataWindow Caption",NULL_STRING,NULL_STRING}

if !IsNil(oServer)
	self:Use(oServer)
endif

self:PostInit(oWindow,iCtlID,oServer,uExtra)

return self


END CLASS
