#region DEFINES
STATIC DEFINE OUTLOOKBARDLG_OOBAR := 100 
STATIC DEFINE PRJTAB_PAGE1_PUSHBUTTON1 := 100 
STATIC DEFINE PRJTAB_PAGE2_PUSHBUTTON1 := 100 
#endregion

CLASS OutlookBarDlg INHERIT DIALOGWINDOW 

	EXPORT oDCOOBar AS OUTLOOKBAR

  //{{%UC%}} USER CODE STARTS HERE (do NOT remove this line)

METHOD CreateOutlookBar( ) 
	LOCAL oHeader AS OutlookbarHeader
	LOCAL oItem AS OutlookBarItem
	LOCAL oImageList AS ImageList
	//
	oImageList := ImageList{3, Dimension{32, 32}}
	oImageList:Add(ICON_COMPTES{})
	oImageList:Add(ICON_DEPENSE{})
	oImageList:Add(ICON_RECETTE{})
	SELF:oDCOOBar:ImageList := oImageList
	//
	oHeader := OutlookBarHeader{#Operations, "Operations",2032,2}
	//
	oItem := OutlookBarItem{#Choose, "Choose", 1}
	oHeader:AddItem( oItem )
	oItem := OutlookBarItem{#New, "New", 2}
	oHeader:AddItem( oItem )
	oItem := OutlookBarItem{#Open, "Open", 3}
	oHeader:AddItem( oItem )
	oItem := OutlookBarItem{#SplitTest, "Split Test", 4}
	oHeader:AddItem( oItem )
	//
	SELF:oDCOOBar:AddHeader(oHeader)
	oHeader := OutlookBarHeader{#Utilities, "Utilities"}
	oItem := OutlookBarItem{#Open, "Open", 3}
	oHeader:AddItem( oItem )
	//
	SELF:oDCOOBar:AddHeader(oHeader)
	//
	SELF:oDCOOBar:ActiveHeader := #Operations
	SELF:oDCOOBar:BarStyle := #NEWSTYLE         
	self:oDCOOBar:ItemSpacing := 0
	// Try to uncomment each following lines
	// one by one
	//self:oDCOOBar:HeaderHeight := 35
	//self:oDCOOBar:HiliteBackgroundColor := __RGB2Color( GetSysColor( COLOR_BTNFACE ) )
	//
	self:oDCOOBar:BackgroundColor := Color{ 127,127,127 }
	//self:oDCOOBar:HiliteBackgroundColor := Color{ 127,127,127 }
return self

CONSTRUCTOR(oParent,uExtra)  

self:PreInit(oParent,uExtra)

SUPER(oParent,ResourceID{"OutlookBarDlg",_GetInst()},FALSE)

oDCOOBar := OutlookBar{SELF,ResourceID{OUTLOOKBARDLG_OOBAR,_GetInst()}}
oDCOOBar:HyperLabel := HyperLabel{#OOBar,NULL_STRING,NULL_STRING,NULL_STRING}

SELF:Caption := ""
SELF:HyperLabel := HyperLabel{#OutlookBarDlg,NULL_STRING,NULL_STRING,NULL_STRING}

self:PostInit(oParent,uExtra)

return self


METHOD OLBItemClicked( oItem ) 
	IF IsMethod( SELF:Owner, oItem:NameSym )
		Send( SELF:Owner, oItem:NameSym )
	ENDIF	
RETURN NIL

METHOD PostInit(oParent,uExtra) 
	//Put your PostInit additions here
	SELF:CreateOutlookBar()
RETURN NIL


METHOD Resize(oResizeEvent) 
	//
	SUPER:Resize(oResizeEvent)
	//
	SELF:UpdateBar()
return self

METHOD UpdateBar() 
	LOCAL RC IS _winRECT
	// Move OOBar
	GetClientRect( SELF:Handle(), @rc )
	SetWindowPos( SELF:oDCOOBar:Handle(), NULL, 2 , 2, rc.right-rc.left-4, rc.bottom-rc.Top-4, SWP_NOACTIVATE + SWP_NOZORDER )
	//
RETURN NIL


END CLASS
