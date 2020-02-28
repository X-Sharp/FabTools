#include "VOSystemLibrary.vh"
#include "VOWin32APILibrary.vh"
#include "Delete Window.vh"
CLASS DeleteWnd INHERIT DIALOGWINDOW

	PROTECT oCCDeletePB AS PUSHBUTTON
	PROTECT oCCCancelPB AS PUSHBUTTON
	PROTECT oDCFilesGrp AS RADIOBUTTONGROUP
	PROTECT oCCSelectRadio AS RADIOBUTTON
	PROTECT oCCAllRadio AS RADIOBUTTON

  //USER CODE STARTS HERE (do NOT remove this line)
	EXPORT	lAll		AS	LOGIC

METHOD CancelPB( ) CLASS DeleteWnd
 	SELF:EndDialog( 0 )
           return self

METHOD DeletePB( ) CLASS DeleteWnd
	//
	SELF:lAll := ( SELF:oDCFilesGrp:Value == "A" )	
 	//
 	self:EndDialog( 1 )
return self

METHOD Init(oParent,uExtra) CLASS DeleteWnd

SELF:PreInit(oParent,uExtra)

SUPER:Init(oParent,ResourceID{"DeleteWnd",_GetInst()},TRUE)

oCCDeletePB := PushButton{SELF,ResourceID{DELETEWND_DELETEPB,_GetInst()}}
oCCDeletePB:HyperLabel := HyperLabel{#DeletePB,_chr(38)+"Delete",NULL_STRING,NULL_STRING}

oCCCancelPB := PushButton{SELF,ResourceID{DELETEWND_CANCELPB,_GetInst()}}
oCCCancelPB:HyperLabel := HyperLabel{#CancelPB,_chr(38)+"Cancel",NULL_STRING,NULL_STRING}

oCCSelectRadio := RadioButton{SELF,ResourceID{DELETEWND_SELECTRADIO,_GetInst()}}
oCCSelectRadio:HyperLabel := HyperLabel{#SelectRadio,_chr(38)+"Selected Files",NULL_STRING,NULL_STRING}

oCCAllRadio := RadioButton{SELF,ResourceID{DELETEWND_ALLRADIO,_GetInst()}}
oCCAllRadio:HyperLabel := HyperLabel{#AllRadio,_chr(38)+"All Files",NULL_STRING,NULL_STRING}

oDCFilesGrp := RadioButtonGroup{SELF,ResourceID{DELETEWND_FILESGRP,_GetInst()}}
oDCFilesGrp:FillUsing({ ;
						{oCCSelectRadio,"S"}, ;
						{oCCAllRadio,"A"} ;
						})
oDCFilesGrp:HyperLabel := HyperLabel{#FilesGrp,"Files",NULL_STRING,NULL_STRING}

SELF:Caption := "Delete"
SELF:HyperLabel := HyperLabel{#DeleteWnd,"Delete",NULL_STRING,NULL_STRING}

SELF:PostInit(oParent,uExtra)

RETURN SELF

METHOD	SELECT( lSelected )	CLASS	DeleteWnd
	//
	IF !lSelected
		SELF:oCCSelectRadio:Disable()
		SELF:oDCFilesGrp:Value := "A"
	ELSE
		SELF:oDCFilesGrp:Value := "S"
	ENDIF
	//
return self
END CLASS

