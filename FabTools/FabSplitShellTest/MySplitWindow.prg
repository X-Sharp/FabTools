CLASS MySplitWindow INHERIT SplitWindow
	

CONSTRUCTOR(oWin) 
	LOCAL oListViewColumn	AS ListViewColumn
	LOCAL oTV				AS TreeView
	LOCAL oLV				AS ListView

	SUPER(oWin, FALSE, TRUE, SPLIT_VERTALIGN)
	SELF:layout := DIMension{2,1}
	
	oTV := TreeView{SELF,0,Point{0,0},DIMension{200,200}}
	oTV:AddItem(#ROOT,TreeViewItem{#ITEM1,"Item 1"})
	oTV:AddItem(#ROOT,TreeViewItem{#ITEM2,"Item 2"})
	oTV:AddItem(#ROOT,TreeViewItem{#ITEM3,"Item 3"})
	SELF:SetPaneClient(oTV,1)
	oTV:Show()
	oLV := ListView{SELF,0,Point{0,0},DIMension{200,200},;
		LVS_REPORT + LVS_SINGLESEL + LVS_SHOWSELALWAYS + LVS_OWNERDATA + WS_CHILD + WS_BORDER}

	oListViewColumn			:= ListViewColumn{}
	oListViewColumn:NameSym	:= #COL1
	oListViewColumn:Caption	:= "ONE"
	oListViewColumn:Width	:= 10
	oLV:AddColumn(oListViewColumn)

	oListViewColumn			:= ListViewColumn{}
	oListViewColumn:NameSym	:= #COL2
	oListViewColumn:Caption	:= "TWO"
	oListViewColumn:Width	:= 20
	oLV:AddColumn(oListViewColumn)

	oListViewColumn			:= ListViewColumn{}
	oListViewColumn:NameSym	:= #COL3
	oListViewColumn:Caption	:= "THREE"
	oListViewColumn:Width	:= 30
	oLV:AddColumn(oListViewColumn)

	oListViewColumn			:= ListViewColumn{}
	oListViewColumn:NameSym	:= #COL4
	oListViewColumn:Caption	:= "FOUR"
	oListViewColumn:Width	:= 40
	oLV:AddColumn(oListViewColumn)

	SELF:SetPaneClient(oLV,2)
	oLV:Show()
	
RETURN SELF
	
	


END CLASS
