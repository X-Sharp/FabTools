#region DEFINES
Define IDA_MainMenu := "MainMenu"
Define IDM_MainMenu := "MainMenu"
Define IDM_MainMenu_File_ID := 25747
Define IDM_MainMenu_File_Print_ID := 25752
Define IDM_MainMenu_File_Printer_Setup_ID := 25751
Define IDM_MainMenu_File_Quit_ID := 25754
Define IDM_MainMenu_File_Scan_New_ID := 25749
Define IDM_MainMenu_File_Select_Source_ID := 25748
Define IDM_MainMenu_Help_About_ID := 25756
Define IDM_MainMenu_Help_ID := 25755
#endregion

CLASS MainMenu INHERIT Menu
 
CONSTRUCTOR(oOwner) 
	local oTB as ToolBar

	SUPER(ResourceID{IDM_MainMenu, _GetInst( )})

	self:RegisterItem(IDM_MainMenu_File_ID,	;
		HyperLabel{#_File,	;
			"File",	;
			,	;
			,},self:Handle( ),0)
	self:RegisterItem(IDM_MainMenu_File_Select_Source_ID,	;
		HyperLabel{#SelectSource,	;
			"Select Source...",	;
			"Select a Twain Source",	;
			,})
	self:RegisterItem(IDM_MainMenu_File_Scan_New_ID,	;
		HyperLabel{#ScanPB,	;
			"Scan New",	;
			"Scan a new document",	;
			,})
	self:RegisterItem(IDM_MainMenu_File_Printer_Setup_ID,	;
		HyperLabel{#PrinterSetup,	;
			"Printer Setup...",	;
			"Setup Printer",	;
			,})
	self:RegisterItem(IDM_MainMenu_File_Print_ID,	;
		HyperLabel{#PrintPB,	;
			"Print",	;
			"Print the current image",	;
			,})
	self:RegisterItem(IDM_MainMenu_File_Quit_ID,	;
		HyperLabel{#ClosePB,	;
			"Quit",	;
			"Quit application",	;
			,})
	self:RegisterItem(IDM_MainMenu_Help_ID,	;
		HyperLabel{#_Help,	;
			"Help",	;
			,	;
			,},self:Handle( ),1)
	self:RegisterItem(IDM_MainMenu_Help_About_ID,	;
		HyperLabel{#HelpAbout,	;
			"About...",	;
			"About EZTwain Test",	;
			,})

	oTB := ToolBar{ }

	oTB:ButtonStyle := TB_ICONONLY

	oTB:AppendItem(IDT_CLOSE,IDM_MainMenu_File_Quit_ID)
	oTB:AddTipText(IDT_CLOSE,IDM_MainMenu_File_Quit_ID,"Quit")

	oTB:AppendItem(IDT_SEPARATOR)

	oTB:AppendItem(IDT_PICTURE,IDM_MainMenu_File_Select_Source_ID)
	oTB:AddTipText(IDT_PICTURE,IDM_MainMenu_File_Select_Source_ID,"Select Source")

	oTB:AppendItem(IDT_PREVIEW,IDM_MainMenu_File_Scan_New_ID)
	oTB:AddTipText(IDT_PREVIEW,IDM_MainMenu_File_Scan_New_ID,"Acquire")

	oTB:AppendItem(IDT_SEPARATOR)

	oTB:AppendItem(IDT_PRINT,IDM_MainMenu_File_Print_ID)
	oTB:AddTipText(IDT_PRINT,IDM_MainMenu_File_Print_ID,"Print")

	oTB:AppendItem(IDT_HELP,IDM_MainMenu_Help_About_ID)
	oTB:AddTipText(IDT_HELP,IDM_MainMenu_Help_About_ID,"About")

	oTB:Flat := true

	self:ToolBar := oTB

	return self

END CLASS
