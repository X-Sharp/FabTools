#include "GlobalDefines.vh"
#include "VOGUIClasses.vh"
#include "VOWin32APILibrary.vh"
CLASS EmptyShellMenu INHERIT Menu
 

CONSTRUCTOR(oOwner) 
	local oTB as Toolbar

	SELF:PreInit()
	super(ResourceID{"EmptyShellMenu", _GetInst( )})

	self:RegisterItem(IDM_EmptyShellMenu_File_ID,	;
		HyperLabel{#File,	;
			"&File",	;
			,	;
			"File"},self:Handle( ),0)
	self:RegisterItem(IDM_EmptyShellMenu_File_Open_ID,	;
		HyperLabel{#FileOpen,	;
			"&Open..	CTRL+O",	;
			"Open a file",	;
			"File_Open"})
	self:RegisterItem(IDM_EmptyShellMenu_File_Paste_from_Clipboard_ID,	;
		HyperLabel{#ClipPaste,	;
			"&Paste from Clipboard...",	;
			"Paste Image from Clipboard",	;
			,})
	self:RegisterItem(IDM_EmptyShellMenu_File_Print_Setup_ID,	;
		HyperLabel{#FilePrinterSetup,	;
			"P&rint Setup...",	;
			"Setup printer options",	;
			"File_Printer_Setup"})
	self:RegisterItem(IDM_EmptyShellMenu_File_Exit_ID,	;
		HyperLabel{#AppExit,	;
			"E&xit	ALT+F4",	;
			"End of application",	;
			"File_Exit"})
	self:RegisterItem(IDM_EmptyShellMenu_Help_ID,	;
		HyperLabel{#Help,	;
			"&Help",	;
			,	;
			,},self:Handle( ),1)
	self:RegisterItem(IDM_EmptyShellMenu_Help_Index_ID,	;
		HyperLabel{#HelpIndex,	;
			"&Index	F1",	;
			"Index of help",	;
			"Help_Index"})
	self:RegisterItem(IDM_EmptyShellMenu_Help_Using_help_ID,	;
		HyperLabel{#HelpUsingHelp,	;
			"&Using help",	;
			"How to use help",	;
			"Help_UsingHelp"})
	self:RegisterItem(IDM_EmptyShellMenu_Help_About_ID,	;
		HyperLabel{#HelpAboutDialog,	;
			"&About...",	;
			"About application",	;
			,})

	oTB := Toolbar{ }
	oTB:ButtonStyle := TB_ICONONLY
	oTB:EnableBands(FALSE)

	oTB:AppendItem(IDT_OPEN,IDM_EmptyShellMenu_File_Open_ID)
	oTB:AddTipText(IDT_OPEN,IDM_EmptyShellMenu_File_Open_ID,"Open File")

	oTB:AppendItem(IDT_SEPARATOR)

	oTB:AppendItem(IDT_PASTE,IDM_EmptyShellMenu_File_Paste_from_Clipboard_ID)
	oTB:AddTipText(IDT_PASTE,IDM_EmptyShellMenu_File_Paste_from_Clipboard_ID,"Paste")

	oTB:AppendItem(IDT_SEPARATOR)

	oTB:AppendItem(IDT_HELP,IDM_EmptyShellMenu_Help_About_ID)
	oTB:AddTipText(IDT_HELP,IDM_EmptyShellMenu_Help_About_ID,"Help")

	oTB:Flat := true

	self:ToolBar := oTB

	self:Accelerator := EmptyShellMenu_Accelerator{ }

	SELF:PostInit()
	return 
END CLASS

CLASS EmptyShellMenu_Accelerator INHERIT Accelerator
 

CONSTRUCTOR( ) 
	super(ResourceID{"EmptyShellMenu_Accelerator", _GetInst( )})

	return 
END CLASS

