#region DEFINES
Define IDA_TwainContext := "TwainContext"
Define IDM_TwainContext := "TwainContext"
Define IDM_TwainContext_Dummy_ID := 25112
Define IDM_TwainContext_Dummy_Zoom_In__1_f2_1_ID := 25114
Define IDM_TwainContext_Dummy_Zoom_In__2_f2_1_ID := 25115
Define IDM_TwainContext_Dummy_Zoom_In__3_f2_1_ID := 25116
Define IDM_TwainContext_Dummy_Zoom_In__4_f2_1_ID := 25117
Define IDM_TwainContext_Dummy_Zoom_In__5_f2_1_ID := 25118
Define IDM_TwainContext_Dummy_Zoom_In_ID := 25113
Define IDM_TwainContext_Dummy_Zoom_Out__1_f2_1_ID := 25120
Define IDM_TwainContext_Dummy_Zoom_Out__1_f2_2_ID := 25121
Define IDM_TwainContext_Dummy_Zoom_Out__1_f2_3_ID := 25122
Define IDM_TwainContext_Dummy_Zoom_Out__1_f2_4_ID := 25123
Define IDM_TwainContext_Dummy_Zoom_Out__1_f2_5_ID := 25124
Define IDM_TwainContext_Dummy_Zoom_Out_ID := 25119
#endregion

CLASS TwainContext INHERIT Menu
 
CONSTRUCTOR(oOwner) 

	SUPER(ResourceID{IDM_TwainContext, _GetInst( )})

	self:RegisterItem(IDM_TwainContext_Dummy_ID,	;
		HyperLabel{#_Dummy,	;
			"Dummy",	;
			,	;
			,},self:Handle( ),0)
	self:RegisterItem(IDM_TwainContext_Dummy_Zoom_In_ID,	;
		HyperLabel{#Dummy_Zoom_In,	;
			"Zoom In",	;
			,	;
			,},VOWin32APILibrary.Functions.GetSubMenu(SELF:Handle( ),0),0)
	self:RegisterItem(IDM_TwainContext_Dummy_Zoom_In__1_f2_1_ID,	;
		HyperLabel{#Dummy_Zoom_In__1_f2_1,	;
			"1 / 1",	;
			,	;
			,})
	self:RegisterItem(IDM_TwainContext_Dummy_Zoom_In__2_f2_1_ID,	;
		HyperLabel{#Dummy_Zoom_In__2_f2_1,	;
			"2 / 1",	;
			,	;
			,})
	self:RegisterItem(IDM_TwainContext_Dummy_Zoom_In__3_f2_1_ID,	;
		HyperLabel{#Dummy_Zoom_In__3_f2_1,	;
			"3 / 1",	;
			,	;
			,})
	self:RegisterItem(IDM_TwainContext_Dummy_Zoom_In__4_f2_1_ID,	;
		HyperLabel{#Dummy_Zoom_In__4_f2_1,	;
			"4 / 1",	;
			,	;
			,})
	self:RegisterItem(IDM_TwainContext_Dummy_Zoom_In__5_f2_1_ID,	;
		HyperLabel{#Dummy_Zoom_In__5_f2_1,	;
			"5 / 1",	;
			,	;
			,})
	self:RegisterItem(IDM_TwainContext_Dummy_Zoom_Out_ID,	;
		HyperLabel{#Dummy_Zoom_Out,	;
			"Zoom Out",	;
			,	;
			,},VOWin32APILibrary.Functions.GetSubMenu(self:Handle( ),0),1)
	self:RegisterItem(IDM_TwainContext_Dummy_Zoom_Out__1_f2_1_ID,	;
		HyperLabel{#Dummy_Zoom_Out__1_f2_1,	;
			"1 / 1",	;
			,	;
			,})
	self:RegisterItem(IDM_TwainContext_Dummy_Zoom_Out__1_f2_2_ID,	;
		HyperLabel{#Dummy_Zoom_Out__1_f2_2,	;
			"1 / 2",	;
			,	;
			,})
	self:RegisterItem(IDM_TwainContext_Dummy_Zoom_Out__1_f2_3_ID,	;
		HyperLabel{#Dummy_Zoom_Out__1_f2_3,	;
			"1 / 3",	;
			,	;
			,})
	self:RegisterItem(IDM_TwainContext_Dummy_Zoom_Out__1_f2_4_ID,	;
		HyperLabel{#Dummy_Zoom_Out__1_f2_4,	;
			"1 / 4",	;
			,	;
			,})
	self:RegisterItem(IDM_TwainContext_Dummy_Zoom_Out__1_f2_5_ID,	;
		HyperLabel{#Dummy_Zoom_Out__1_f2_5,	;
			"1 / 5",	;
			,	;
			,})

	return self

END CLASS
