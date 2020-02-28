using FabZip
using VO


STATIC DEFINE DELETEWND_DELETEPB := 100
STATIC DEFINE DELETEWND_CANCELPB := 101
STATIC DEFINE DELETEWND_FILESGRP := 102
STATIC DEFINE DELETEWND_SELECTRADIO := 103
STATIC DEFINE DELETEWND_ALLRADIO := 104
PARTIAL CLASS DeleteWnd INHERIT DIALOGWINDOW
	PROTECT oCCDeletePB AS PUSHBUTTON
	PROTECT oCCCancelPB AS PUSHBUTTON
	PROTECT oDCFilesGrp AS RADIOBUTTONGROUP
	PROTECT oCCSelectRadio AS RADIOBUTTON
	PROTECT oCCAllRadio AS RADIOBUTTON
	
	// {{%UC%}} User code starts here (DO NOT remove this line)  
	EXPORT	lAll		AS	LOGIC
	
	METHOD CancelPB( ) 
		SELF:EndDialog( 0 )
		return self
		
	METHOD DeletePB( ) 
		//
		SELF:lAll := ( SELF:oDCFilesGrp:Value == "A" )	
		//
		self:EndDialog( 1 )
		return self
		
	CONSTRUCTOR(oParent,uExtra)
	
		SELF:PreInit(oParent,uExtra)
		
		SUPER(oParent , ResourceID{"DeleteWnd" , _GetInst()} , TRUE)
		
		SELF:oCCDeletePB := PUSHBUTTON{SELF , ResourceID{ DELETEWND_DELETEPB  , _GetInst() } }
		SELF:oCCDeletePB:HyperLabel := HyperLabel{#DeletePB , "&Delete" , NULL_STRING , NULL_STRING}
		
		SELF:oCCCancelPB := PUSHBUTTON{SELF , ResourceID{ DELETEWND_CANCELPB  , _GetInst() } }
		SELF:oCCCancelPB:HyperLabel := HyperLabel{#CancelPB , "&Cancel" , NULL_STRING , NULL_STRING}
		
		SELF:oDCFilesGrp := RADIOBUTTONGROUP{SELF , ResourceID{ DELETEWND_FILESGRP  , _GetInst() } }
		SELF:oDCFilesGrp:HyperLabel := HyperLabel{#FilesGrp , "Files" , NULL_STRING , NULL_STRING}
		
		SELF:oCCSelectRadio := RADIOBUTTON{SELF , ResourceID{ DELETEWND_SELECTRADIO  , _GetInst() } }
		SELF:oCCSelectRadio:HyperLabel := HyperLabel{#SelectRadio , "&Selected Files" , NULL_STRING , NULL_STRING}
		
		SELF:oCCAllRadio := RADIOBUTTON{SELF , ResourceID{ DELETEWND_ALLRADIO  , _GetInst() } }
		SELF:oCCAllRadio:HyperLabel := HyperLabel{#AllRadio , "&All Files" , NULL_STRING , NULL_STRING}
		
		SELF:oDCFilesGrp:FillUsing({ ;
		{SELF:oCCSelectRadio, "S"}, ;
		{SELF:oCCAllRadio, "A"} ;
		})
		
		SELF:Caption := "Delete"
		SELF:HyperLabel := HyperLabel{#DeleteWnd , "Delete" , NULL_STRING , NULL_STRING}
		
		SELF:PostInit(oParent,uExtra)
		
		RETURN
		
		
	METHOD	SELECT( lSelected )	
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

