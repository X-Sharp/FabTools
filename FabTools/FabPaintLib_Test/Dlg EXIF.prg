#include "VOSystemLibrary.vh"
#include "VOWin32APILibrary.vh"
#include "Dlg EXIF.vh"
CLASS EXIFDlg INHERIT DIALOGWINDOW 

	EXPORT oCCClosePB AS PUSHBUTTON
	EXPORT oDCEXIFListView AS LISTVIEW

  //{{%UC%}} USER CODE STARTS HERE (do NOT remove this line)

METHOD ClosePB( ) 
	self:EndDialog()
return self

CONSTRUCTOR(oParent,uExtra)  

self:PreInit(oParent,uExtra)

SUPER(oParent,ResourceID{"EXIFDlg",_GetInst()},TRUE)

oCCClosePB := PushButton{SELF,ResourceID{EXIFDLG_CLOSEPB,_GetInst()}}
oCCClosePB:HyperLabel := HyperLabel{#ClosePB,"Close",NULL_STRING,NULL_STRING}

oDCEXIFListView := ListView{SELF,ResourceID{EXIFDLG_EXIFLISTVIEW,_GetInst()}}
oDCEXIFListView:FullRowSelect := True
oDCEXIFListView:GridLines := True
oDCEXIFListView:HyperLabel := HyperLabel{#EXIFListView,NULL_STRING,NULL_STRING,NULL_STRING}

SELF:Caption := "EXIF Data"
SELF:HyperLabel := HyperLabel{#EXIFDlg,"EXIF Data",NULL_STRING,NULL_STRING}

self:PostInit(oParent,uExtra)

return 

method PostInit(oParent,uExtra) 
	//Put your PostInit additions here
	local oLVColumn 	as ListViewColumn
	local oImgList		as	ImageList
	//
	oLVColumn := ListViewColumn{ 10 }
	oLVColumn:HyperLabel := HyperLabel{ #Item,"Item" }
	//
	self:oDCEXIFListView:AddColumn( oLVColumn )
	//
	oLVColumn := ListViewColumn{10 }
	oLVColumn:HyperLabel := HyperLabel{ #Value,"Value" }
	//
	self:oDCEXIFListView:AddColumn( oLVColumn )
	//
	oLVColumn := ListViewColumn{ }
	oLVColumn:HyperLabel := HyperLabel{ #Desc,"Description" }
	//
	self:oDCEXIFListView:AddColumn( oLVColumn )
	//
	oImgList := ImageList{ 1, Dimension{16,16} }
	oImgList:Add( ICON_GREEN{} )
	//
	self:oDCEXIFListView:SmallImageList := oImgList
	//	
	return nil

END CLASS

