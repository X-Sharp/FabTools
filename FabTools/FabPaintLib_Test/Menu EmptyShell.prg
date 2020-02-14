USING VO

DEFINE IDM_EmptyShellMenu_File_ID := 12500
DEFINE IDM_EmptyShellMenu_File_Open_ID := 12501
DEFINE IDM_EmptyShellMenu_File_Paste_from_Clipboard_ID := 12502
DEFINE IDM_EmptyShellMenu_File_Print_Setup_ID := 12504
DEFINE IDM_EmptyShellMenu_File_Exit_ID := 12506
DEFINE IDM_EmptyShellMenu_Help_ID := 12507
DEFINE IDM_EmptyShellMenu_Help_Index_ID := 12508
DEFINE IDM_EmptyShellMenu_Help_Using_help_ID := 12509
DEFINE IDM_EmptyShellMenu_Help_About_ID := 12511



PARTIAL CLASS EmptyShellMenu INHERIT Menu

CONSTRUCTOR( oOwner )

	LOCAL oTB AS Toolbar

	SELF:PreInit()

	SUPER( ResourceID { "EmptyShellMenu" , _GetInst( ) } )

	SELF:RegisterItem(IDM_EmptyShellMenu_File_ID, ;
		HyperLabel{ #File , "&File" ,  , "File" } , SELF:Handle() , 0)

	SELF:RegisterItem(IDM_EmptyShellMenu_File_Open_ID, ;
		HyperLabel{ #FileOpen , "&Open..	Ctrl+O" , "Open a file" , "File_Open" })

	SELF:RegisterItem(IDM_EmptyShellMenu_File_Paste_from_Clipboard_ID, ;
		HyperLabel{ #ClipPaste , "&Paste from Clipboard..." , "Paste Image from Clipboard" ,  })

	SELF:RegisterItem(IDM_EmptyShellMenu_File_Print_Setup_ID, ;
		HyperLabel{ #FilePrinterSetup , "P&rint Setup..." , "Setup printer options" , "File_Printer_Setup" })

	SELF:RegisterItem(IDM_EmptyShellMenu_File_Exit_ID, ;
		HyperLabel{ #AppExit , "E&xit	Alt+F4" , "End of application" , "File_Exit" })

	SELF:RegisterItem(IDM_EmptyShellMenu_Help_ID, ;
		HyperLabel{ #Help , "&Help" ,  ,  } , SELF:Handle() , 1)

	SELF:RegisterItem(IDM_EmptyShellMenu_Help_Index_ID, ;
		HyperLabel{ #HelpIndex , "&Index	F1" , "Index of help" , "Help_Index" })

	SELF:RegisterItem(IDM_EmptyShellMenu_Help_Using_help_ID, ;
		HyperLabel{ #HelpUsingHelp , "&Using help" , "How to use help" , "Help_UsingHelp" })

	SELF:RegisterItem(IDM_EmptyShellMenu_Help_About_ID, ;
		HyperLabel{ #HelpAboutDialog , "&About..." , "About application" ,  })

	oTB := Toolbar{}

	oTB:ButtonStyle := TB_ICONONLY
	oTB:Flat := TRUE
	oTB:EnableBands(FALSE)

	oTB:AppendItem(IDT_OPEN , IDM_EmptyShellMenu_File_Open_ID)
	oTB:AddTipText(IDT_OPEN , IDM_EmptyShellMenu_File_Open_ID , "Open File")

	oTB:AppendItem(IDT_SEPARATOR)

	oTB:AppendItem(IDT_PASTE , IDM_EmptyShellMenu_File_Paste_from_Clipboard_ID)
	oTB:AddTipText(IDT_PASTE , IDM_EmptyShellMenu_File_Paste_from_Clipboard_ID , "Paste")

	oTB:AppendItem(IDT_SEPARATOR)

	oTB:AppendItem(IDT_HELP , IDM_EmptyShellMenu_Help_About_ID)
	oTB:AddTipText(IDT_HELP , IDM_EmptyShellMenu_Help_About_ID , "Help")


	SELF:ToolBar := oTB
	SELF:Accelerator := EmptyShellMenu_Accelerator{ }

	SELF:PostInit()

	RETURN

END CLASS

PARTIAL CLASS EmptyShellMenu_Accelerator INHERIT Accelerator

CONSTRUCTOR()
	SUPER( ResourceID { "EmptyShellMenu_Accelerator" , _GetInst( ) } )
RETURN


END CLASS

