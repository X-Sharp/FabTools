#include "GlobalDefines.vh"
#include "VOGUIClasses.vh"
#include "VOWin32APILibrary.vh"
CLASS MenuStd INHERIT Menu
 

METHOD Init(oOwner) CLASS MenuStd
	local oTB as ToolBar

	super:Init(ResourceID{"MenuStd", _GetInst( )})

	self:RegisterItem(IDM_MenuStd_FabZip_ID,	;
		HyperLabel{#File,	;
			"&FabZip",	;
			,	;
			"File"},self:Handle( ),0)
	self:RegisterItem(IDM_MenuStd_FabZip_Test_ID,	;
		HyperLabel{#ZipOpen,	;
			"Test	Ctrl+O",	;
			"Open the FabZip test Window",	;
			"File_Open"})
	self:RegisterItem(IDM_MenuStd_FabZip_Exit_ID,	;
		HyperLabel{#FileExit,	;
			"E&xit	Alt+F4",	;
			"End of application",	;
			"File_Exit"})
	self:RegisterItem(IDM_MenuStd_Help_ID,	;
		HyperLabel{#Help,	;
			"&Help",	;
			,	;
			,},self:Handle( ),1)
	self:RegisterItem(IDM_MenuStd_Help_About_ID,	;
		HyperLabel{#HelpAbout,	;
			"&About...",	;
			"About application",	;
			,})

	oTB := ToolBar{ }

	oTB:ButtonStyle := TB_ICONONLY

	oTB:AppendItem(IDT_CLOSE,IDM_MenuStd_FabZip_Exit_ID)
	oTB:AddTipText(IDT_CLOSE,IDM_MenuStd_FabZip_Exit_ID,"Quit")

	oTB:AppendItem(IDT_NEWSHEET,IDM_MenuStd_FabZip_Test_ID)
	oTB:AddTipText(IDT_NEWSHEET,IDM_MenuStd_FabZip_Test_ID,"Open File")

	oTB:AppendItem(IDT_SEPARATOR)

	oTB:AppendItem(IDT_LEFT,IDM_MenuStd_Help_About_ID)
	oTB:AddTipText(IDT_LEFT,IDM_MenuStd_Help_About_ID,"Help")

	oTB:Bitmap := FabToolsBar1{}
	oTB:ButtonSize := Dimension{16, 16}

	self:ToolBar := oTB

	self:Accelerator := MenuStd_Accelerator{ }

	return self
END CLASS

CLASS MenuStd_Accelerator INHERIT Accelerator
 

METHOD Init( ) CLASS MenuStd_Accelerator
	super:Init(ResourceID{"MenuStd_Accelerator", _GetInst( )})

	return self
END CLASS

