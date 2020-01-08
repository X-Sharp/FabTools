CLASS MainWindow INHERIT FabSplitShellWindow 


  //{{%UC%}} USER CODE STARTS HERE (do NOT remove this line)
	PROTECT 	cFolder	AS	STRING

METHOD Choose() 
	LOCAL oDW	AS	MyWindow
	//
	oDW := MyWindow{SELF }
	oDW:Caption := "Choose"
	oDW:Show()
RETURN SELF

METHOD Folder_Open() 
	LOCAL oBF	AS	StandardFolderDialog
	//
	oBF := StandardFolderDialog{SELF }
	IF oBF:Show()
		//
		SELF:cFolder := oBF:FolderName
		//
	ENDIF
RETURN SELF

METHOD Folder_Quit() 
	SELF:EndWindow()
RETURN SELF	

CONSTRUCTOR(oParent,uExtra)  

SELF:PreInit(oParent,uExtra)

SUPER(oParent,uExtra)

SELF:Caption := "Fab Bank"
SELF:HyperLabel := HyperLabel{#MainWindow,"Fab Bank",NULL_STRING,NULL_STRING}
SELF:Menu := MainMenu{}
SELF:Icon := ICON_AA{}
SELF:Origin := Point{17, 125}
SELF:Size := Dimension{800, 600}

SELF:PostInit(oParent,uExtra)

RETURN SELF


METHOD New() 
	LOCAL oDW	AS	MyWindow
LOCAL o AS ChildAppWindow
	//
	oDW := MyWindow{SELF }
	oDW:Caption := "New"
	oDW:Show()
//
o := ChildAppWindow{ SELF, TRUE}
o:Show()
RETURN SELF




METHOD OpenWindow() 
	LOCAL oDW	AS	MyWindow
	//
	oDW := MyWindow{SELF }
	oDW:Caption := "Open"
	oDW:Show()
RETURN SELF

METHOD PostInit(oParent,uExtra) 
	//Put your PostInit additions here
	SELF:LeftPane := OutlookBarDlg{ SELF }
	SELF:LeftSizePixel := 128
	SELF:PosType := #PIXEL
	SELF:CanResizeLeftPane := TRUE	//FALSE
	SELF:ShowLeftPane := TRUE
	//
	//SELF:BottomPane := BottomDialog{ SELF }
	//
	RETURN NIL


METHOD SplitTest 
	LOCAL oSW AS MySplitWindow
	
	oSW := MySplitWindow{SELF}
	oSW:Caption := "Split Test"
	oSW:Show(SHOWZOOMED)
RETURN SELF


END CLASS
