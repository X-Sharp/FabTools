#region DEFINES
Define IDM_MainMenu_Folder_ID := 3373
Define IDM_MainMenu_Folder_New_ID := 3378
Define IDM_MainMenu_Folder_Open_ID := 3374
Define IDM_MainMenu_Folder_Quit_ID := 3376
Define IDM_MainMenu_Folder_Split_Test_ID := 3379
#endregion

CLASS MainMenu INHERIT Menu 

CONSTRUCTOR(oOwner) 
	LOCAL oTB as Toolbar 

	SELF:PreInit()
	SUPER(ResourceID{"MainMenu", _GetInst( )})

	SELF:RegisterItem(IDM_MainMenu_Folder_ID,	;
		HyperLabel{#_Folder,	;
			"Folder",	;
			,	;
			}, SELF:Handle(), 0)
	SELF:RegisterItem(IDM_MainMenu_Folder_Open_ID,	;
		HyperLabel{#Folder_Open,	;
			"&Open",	;
			,	;
			})
	SELF:RegisterItem(IDM_MainMenu_Folder_Quit_ID,	;
		HyperLabel{#Folder_Quit,	;
			"Quit",	;
			,	;
			})
	SELF:RegisterItem(IDM_MainMenu_Folder_New_ID,	;
		HyperLabel{#New,	;
			"New",	;
			,	;
			})
	SELF:RegisterItem(IDM_MainMenu_Folder_Split_Test_ID,	;
		HyperLabel{#Splittest,	;
			"Split Test",	;
			,	;
			})

	oTB := Toolbar{ }
	oTB:ButtonStyle := TB_ICONONLY
	oTB:Flat := TRUE
	oTB:EnableBands(FALSE)

	oTB:AppendItem(IDT_CLOSE,IDM_MainMenu_Folder_Quit_ID)
	oTB:AddTipText(IDT_CLOSE,IDM_MainMenu_Folder_Quit_ID,"Quit App")

	oTB:AppendItem(IDT_NEWSHEET,IDM_MainMenu_Folder_New_ID)
	oTB:AddTipText(IDT_NEWSHEET,IDM_MainMenu_Folder_New_ID,"New Sheet")

	SELF:ToolBar := oTB

	SELF:PostInit()
	return self

END CLASS
