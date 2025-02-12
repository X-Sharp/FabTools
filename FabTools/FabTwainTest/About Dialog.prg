#region DEFINES
STATIC DEFINE ABOUTDLG_CLOSEPB := 100 
STATIC DEFINE ABOUTDLG_EMAIL := 106 
STATIC DEFINE ABOUTDLG_EMAIL1 := 108 
STATIC DEFINE ABOUTDLG_FIXEDICON1 := 102 
STATIC DEFINE ABOUTDLG_FIXEDTEXT1 := 103 
STATIC DEFINE ABOUTDLG_FIXEDTEXT2 := 104 
STATIC DEFINE ABOUTDLG_FIXEDTEXT3 := 105 
STATIC DEFINE ABOUTDLG_FIXEDTEXT4 := 107 
STATIC DEFINE ABOUTDLG_HOMEPAGE := 101 
#endregion

CLASS AboutDlg INHERIT DIALOGWINDOW 

	PROTECT oCCClosePB AS PUSHBUTTON
	PROTECT oDCHomePage AS FabHyperLink
	PROTECT oDCEMail AS FabHyperLink
	PROTECT oDCEMail1 AS FabHyperLink

  //{{%UC%}} USER CODE STARTS HERE (do NOT remove this line)

METHOD ClosePB( ) 
	SELF:EndDialog()
return self	

CONSTRUCTOR(oParent,uExtra)  

self:PreInit(oParent,uExtra)

SUPER(oParent,ResourceID{"AboutDlg",_GetInst()},TRUE)

oCCClosePB := PushButton{SELF,ResourceID{ABOUTDLG_CLOSEPB,_GetInst()}}
oCCClosePB:HyperLabel := HyperLabel{#ClosePB,_chr(38)+"Close",NULL_STRING,NULL_STRING}

oDCHomePage := FabHyperLink{SELF,ResourceID{ABOUTDLG_HOMEPAGE,_GetInst()}}
oDCHomePage:HyperLabel := HyperLabel{#HomePage,"http://www.fabtoys.net",NULL_STRING,NULL_STRING}

oDCEMail := FabHyperLink{SELF,ResourceID{ABOUTDLG_EMAIL,_GetInst()}}
oDCEMail:HyperLabel := HyperLabel{#EMail,"EMail:fabrice@fabtoys.net",NULL_STRING,NULL_STRING}

oDCEMail1 := FabHyperLink{SELF,ResourceID{ABOUTDLG_EMAIL1,_GetInst()}}
oDCEMail1:HyperLabel := HyperLabel{#EMail1,"http://www.twain.org",NULL_STRING,NULL_STRING}

SELF:Caption := "About FabTwain"
SELF:HyperLabel := HyperLabel{#AboutDlg,"About FabTwain",NULL_STRING,NULL_STRING}

self:PostInit(oParent,uExtra)

return self


METHOD PostInit(oParent,uExtra) 
	//Put your PostInit additions here
	SELF:oDCEMail:Action := "mailto:fabrice.foray@free.fr"
	RETURN NIL


END CLASS
