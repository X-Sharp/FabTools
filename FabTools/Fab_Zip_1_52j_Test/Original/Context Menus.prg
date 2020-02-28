#include "GlobalDefines.vh"
CLASS ListMenu INHERIT Menu
 

METHOD Init(oOwner) CLASS ListMenu
//	LOCAL oTB AS ToolBar

	SUPER:Init(ResourceID{"ListMenu", _GetInst( )})

	SELF:RegisterItem(IDM_ListMenu_Dummy_ID,	;
		HyperLabel{#_Dummy,	;
			"Dummy",	;
			,	;
			,},SELF:Handle( ),0)
	SELF:RegisterItem(IDM_ListMenu_Dummy_Select_All_ID,	;
		HyperLabel{#SelectAll,	;
			"Select All",	;
			,	;
			,})
	SELF:RegisterItem(IDM_ListMenu_Dummy_Deselect_All_ID,	;
		HyperLabel{#ClearAll,	;
			"Deselect All",	;
			,	;
			,})
	SELF:RegisterItem(IDM_ListMenu_Dummy_Add_ID,	;
		HyperLabel{#AddPB,	;
			"Add",	;
			,	;
			,})
	SELF:RegisterItem(IDM_ListMenu_Dummy_Extract_ID,	;
		HyperLabel{#ExtractPB,	;
			"Extract",	;
			,	;
			,})
	SELF:RegisterItem(IDM_ListMenu_Dummy_Delete_ID,	;
		HyperLabel{#DeletePB,	;
			"Delete",	;
			,	;
			,})

	RETURN SELF
END CLASS

