#include "VOGUIClasses.vh"
#include "VOSystemLibrary.vh"
#include "VOWin32APILibrary.vh"
#include "Extract Window.vh"
class ExtractWnd inherit DIALOGWINDOW 

	protect oDCSLEDir as SINGLELINEEDIT
	protect oDCFoldersTV as TREEVIEW
	protect oDCFilesGroup as RADIOBUTTONGROUP
	protect oCCSelectRadio as RADIOBUTTON
	protect oCCAllRadio as RADIOBUTTON
	protect oDCExtractGroup as RADIOBUTTONGROUP
	protect oCCNormalBtn as RADIOBUTTON
	protect oCCFreshenBtn as RADIOBUTTON
	protect oCCUpdateBtn as RADIOBUTTON
	protect oDCOverwrite as CHECKBOX
	protect oDCDirName as CHECKBOX
	protect oCCPBOk as PUSHBUTTON
	protect oCCPBCancel as PUSHBUTTON
	protect oDCFixedText1 as FIXEDTEXT
	protect oDCFixedText2 as FIXEDTEXT

  //USER CODE STARTS HERE (do NOT remove this line)
	EXPORT	oXTract		AS	FabExtractOptions
	EXPORT	lAll		AS	LOGIC

ACCESS DirName CLASS ExtractWnd
	// Get Dir
RETURN SELF:oDCSLEDir:CurrentText

ASSIGN DirName ( cDir ) CLASS ExtractWnd
	SELF:oDCSLEDir:CurrentText := cDir
RETURN SELF:oDCSLEDir:CurrentText
	

METHOD Drop( oDragEvent) CLASS ExtractWnd
	// Set the CurrentText to provide an EditChange for TreeView
	SELF:oDCSLEDir:CurrentText  := oDragEvent:FileName( 1)+"\"
return self

METHOD EditChange(oControlEvent) CLASS ExtractWnd
	LOCAL oControl AS Control
	LOCAL uValue AS USUAL
	LOCAL nPos as dword
	//
	oControl := IIf(oControlEvent == NULL_OBJECT, NULL_OBJECT, oControlEvent:Control)
	SUPER:EditChange(oControlEvent)
	//Put your changes here
	uValue := SELF:oDCSLEDir:CurrentText
	nPos := 0
	//
	DO WHILE (nPos := At3( "\", uValue, nPos+1)) != 0
		SELF:oDCFoldersTV:Expand( String2Symbol( Left( uValue, nPos)))
	ENDDO
	//
	IF oDCFoldersTV:GetItemAttributes( String2Symbol( uValue)) != NULL_OBJECT
		SELF:oDCFoldersTV:SelectItem( String2Symbol( uValue))
		SendMessage( self:oDCSLEDir:Handle(), EM_SETSEL, SLen( uValue), long(SLen( uValue)))
	ENDIF
RETURN nil

	

method Init(oParent,uExtra) class ExtractWnd 

self:PreInit(oParent,uExtra)

super:Init(oParent,ResourceID{"ExtractWnd",_GetInst()},TRUE)

oDCSLEDir := SingleLineEdit{self,ResourceID{EXTRACTWND_SLEDIR,_GetInst()}}
oDCSLEDir:HyperLabel := HyperLabel{#SLEDir,NULL_STRING,NULL_STRING,NULL_STRING}

oDCFoldersTV := TreeView{self,ResourceID{EXTRACTWND_FOLDERSTV,_GetInst()}}
oDCFoldersTV:HyperLabel := HyperLabel{#FoldersTV,"FoldersTreeView",NULL_STRING,NULL_STRING}

oCCSelectRadio := RadioButton{self,ResourceID{EXTRACTWND_SELECTRADIO,_GetInst()}}
oCCSelectRadio:HyperLabel := HyperLabel{#SelectRadio,_chr(38)+"Selected Files",NULL_STRING,NULL_STRING}

oCCAllRadio := RadioButton{self,ResourceID{EXTRACTWND_ALLRADIO,_GetInst()}}
oCCAllRadio:HyperLabel := HyperLabel{#AllRadio,_chr(38)+"All Files",NULL_STRING,NULL_STRING}

oCCNormalBtn := RadioButton{self,ResourceID{EXTRACTWND_NORMALBTN,_GetInst()}}
oCCNormalBtn:HyperLabel := HyperLabel{#NormalBtn,_chr(38)+"Normal",NULL_STRING,NULL_STRING}
oCCNormalBtn:TooltipText := "All files"

oCCFreshenBtn := RadioButton{self,ResourceID{EXTRACTWND_FRESHENBTN,_GetInst()}}
oCCFreshenBtn:HyperLabel := HyperLabel{#FreshenBtn,_chr(38)+"Freshen",NULL_STRING,NULL_STRING}
oCCFreshenBtn:TooltipText := "Only newer files"

oCCUpdateBtn := RadioButton{self,ResourceID{EXTRACTWND_UPDATEBTN,_GetInst()}}
oCCUpdateBtn:HyperLabel := HyperLabel{#UpdateBtn,_chr(38)+"Update",NULL_STRING,NULL_STRING}
oCCUpdateBtn:TooltipText := "Newer files and brand new files"

oDCOverwrite := CheckBox{self,ResourceID{EXTRACTWND_OVERWRITE,_GetInst()}}
oDCOverwrite:HyperLabel := HyperLabel{#Overwrite,_chr(38)+"Overwrite Existing Files",NULL_STRING,NULL_STRING}

oDCDirName := CheckBox{self,ResourceID{EXTRACTWND_DIRNAME,_GetInst()}}
oDCDirName:HyperLabel := HyperLabel{#DirName,"Use "+_chr(38)+"Dir Names",NULL_STRING,NULL_STRING}

oCCPBOk := PushButton{self,ResourceID{EXTRACTWND_PBOK,_GetInst()}}
oCCPBOk:HyperLabel := HyperLabel{#PBOk,_chr(38)+"Ok",NULL_STRING,NULL_STRING}

oCCPBCancel := PushButton{self,ResourceID{EXTRACTWND_PBCANCEL,_GetInst()}}
oCCPBCancel:HyperLabel := HyperLabel{#PBCancel,_chr(38)+"Cancel",NULL_STRING,NULL_STRING}

oDCFixedText1 := FixedText{self,ResourceID{EXTRACTWND_FIXEDTEXT1,_GetInst()}}
oDCFixedText1:HyperLabel := HyperLabel{#FixedText1,"Folders",NULL_STRING,NULL_STRING}

oDCFixedText2 := FixedText{self,ResourceID{EXTRACTWND_FIXEDTEXT2,_GetInst()}}
oDCFixedText2:HyperLabel := HyperLabel{#FixedText2,"Destination",NULL_STRING,NULL_STRING}

oDCFilesGroup := RadioButtonGroup{self,ResourceID{EXTRACTWND_FILESGROUP,_GetInst()}}
oDCFilesGroup:FillUsing({ ;
							{oCCSelectRadio,"S"}, ;
							{oCCAllRadio,"A"} ;
							})
oDCFilesGroup:HyperLabel := HyperLabel{#FilesGroup,"Files",NULL_STRING,NULL_STRING}

oDCExtractGroup := RadioButtonGroup{self,ResourceID{EXTRACTWND_EXTRACTGROUP,_GetInst()}}
oDCExtractGroup:FillUsing({ ;
							{oCCNormalBtn,"N"}, ;
							{oCCFreshenBtn,"F"}, ;
							{oCCUpdateBtn,"U"} ;
							})
oDCExtractGroup:HyperLabel := HyperLabel{#ExtractGroup,"Extract Mode",NULL_STRING,NULL_STRING}

self:Caption := "Extract"
self:HyperLabel := HyperLabel{#ExtractWnd,"Extract",NULL_STRING,NULL_STRING}

self:PostInit(oParent,uExtra)

return self

METHOD PBCancel( ) CLASS ExtractWnd
	SELF:EndDialog( 0)
return self

METHOD PBOk( ) CLASS ExtractWnd
	//
	SELF:oXtract:DirNames := SELF:oDCDirName:Checked
	SELF:oXtract:Overwrite := SELF:oDCOverwrite:Checked
	//
	IF ( SELF:oDCExtractGroup:Value != "N" )
		SELF:oXtract:Freshen := ( SELF:oDCExtractGroup:Value == "F" )
		SELF:oXtract:Update := ( SELF:oDCExtractGroup:Value == "U" )
	ENDIF
	SELF:lAll := ( SELF:oDCFilesGroup:Value == "A" )	
	//
	SELF:EndDialog( 1)
return self	

METHOD PostInit(oParent,uExtra) CLASS ExtractWnd
	LOCAL oTreeItem1 	AS TreeViewItem
	LOCAL oTreeItem2 	AS TreeViewItem
	LOCAL nCpt 			as dword
	LOCAL nType 		as dword
    LOCAL oImg 			AS ImageList
	//
	SELF:oXTract := uExtra
	// ImageList
	oImg := ImageList{ 6, Dimension{ 16,16}}
	oImg:Add( Floppy{})
	oImg:Add( HardDisk{})
	oImg:Add( NetWork{})
	oImg:Add( CdRom{})
	oImg:Add( Close{})
	oImg:Add( Open{})
	//
	SELF:oDCFoldersTV:ImageList := oImg
	// Search for Drives
	FOR nCpt := Asc("A") to Asc("Z")
		nType := GetDriveType( String2Psz( CHR( nCpt)+":\" ) )
		IF nType != 0 .And. nType != 1
			// if exist
			oTreeItem1 := TreeViewItem{}
			oTreeItem1:NameSym := String2Symbol( CHR( nCpt)+":\")
			oTreeItem1:Value := { FALSE, CHR( nCpt)+":\"}
			oTreeItem1:TextValue := CHR( nCpt)+":\"
			oTreeItem1:ImageIndex := nType - 1
			oTreeItem1:SelectedImageIndex := nType - 1
			SELF:oDCFoldersTV:AddItem( #ROOT, oTreeItem1)
			// Automatically add a sub-Item
			oTreeItem2 := TreeViewItem{}
			oTreeItem2:NameSym := String2Symbol( LTrim(oTreeItem1:Value[2]+"DUMMY"))
			oTreeItem2:TextValue := "DUMMY"
			oTreeItem2:Value := {FALSE, "Dummy"}
			SELF:oDCFoldersTV:AddItem( oTreeItem1:NameSym, oTreeItem2)
		ENDIF
	NEXT
	//
	SELF:oDCExtractGroup:Value := "N"
	//
	SELF:oDCSLEDir:SetFocus()
return self	

METHOD Recurse( oTVI) CLASS ExtractWnd
	LOCAL aTab 			AS ARRAY
	LOCAL oTreeItem1 	AS TreeViewItem
	LOCAL oTreeItem2 	AS TreeViewItem
	LOCAL nI 			as dword	
	LOCAL sDir 			AS STRING
	LOCAL oPtr 			AS Pointer
	// Wait...
	oPtr := SELF:Pointer
	SELF:Pointer := Pointer{ POINTERHOURGLASS}
	// Mark as already done
	oTVI:Value[1] := TRUE
	//
	sDir := oTVI:Value[2]
	aTab := Directory( sDir+"*.*", FA_DIRECTORY )
	//
	SELF:oDCFoldersTV:DeleteItem( String2Symbol(LTrim(sDir+"DUMMY")))
	//
	IF ALen( aTab) > 2
		FOR nI := 1 TO ALen( aTab)
			IF (aTab[nI][F_NAME] != ".") .and. (aTab[nI][F_NAME] != "..") .and. ( "D"$aTab[nI][F_ATTR] )
				oTreeItem1 := TreeViewItem{}
				oTreeItem1:NameSym := String2Symbol( LTrim(sDir+aTab[nI][F_NAME]+"\"))
				oTreeItem1:TextValue := aTab[nI][F_NAME]
				oTreeItem1:Value := {FALSE, sDir+aTab[nI][F_NAME]+"\"}
				oTreeItem1:ImageIndex := 5
				oTreeItem1:SelectedImageIndex := 6
				//
				SELF:oDCFoldersTV:InsertItem( oTVI:NameSym, #SORT, oTreeItem1)
				IF FFirst( sDir+aTab[nI][F_NAME]+"\*.*", FA_DIRECTORY)
					IF CharPos( FName(), 1) != "."  .Or. (FNext() .And. FNext())
						// si le répertoire contient d'autres sous-répertoires, on ajoute un item dummy
						// qui permet d'avoir le + et de recevoir l'évènement TreeViewItemExpanding
						oTreeItem2 := TreeViewItem{}
						oTreeItem2:NameSym := String2Symbol( LTrim(sDir+aTab[nI][F_NAME])+"\DUMMY")
						oTreeItem2:TextValue := aTab[nI][F_NAME]
						oTreeItem2:Value := {FALSE,"DUMMY"}	
						SELF:oDCFoldersTV:AddItem( oTreeItem1:NameSym, oTreeItem2)
					ENDIF
				ENDIF
			ENDIF
		NEXT nI
	ENDIF
	SELF:Pointer := oPtr

return self

METHOD	SELECT( lSelected )	CLASS	ExtractWnd
	//
	IF !lSelected
		SELF:oCCSelectRadio:Disable()
		SELF:oDCFilesGroup:Value := "A"
	ELSE
		SELF:oDCFilesGroup:Value := "S"
	ENDIF
	// To be sure that the SLE has the Edit Focus
	SELF:oDCSLEDir:SetFocus()
return self

METHOD TreeViewItemExpanding(oTreeViewExpandingEvent) CLASS ExtractWnd
	SUPER:TreeViewItemExpanding(oTreeViewExpandingEvent)
	//Put your changes here
	IF oTreeViewExpandingEvent:TreeViewItem:Value[1] == FALSE
		SELF:Recurse( oTreeViewExpandingEvent:TreeViewItem )
	ENDIF
	RETURN NIL

METHOD TreeViewSelectionChanged(oTreeViewSelectionEvent) CLASS ExtractWnd
	SUPER:TreeViewSelectionChanged( oTreeViewSelectionEvent)
	//Put your changes here
	IF !IsNil( oTreeViewSelectionEvent:NewTreeViewItem)
 		SELF:oDCSLEDir:TextValue := Symbol2String( oTreeViewSelectionEvent:NewTreeViewItem:NameSym)
	ENDIF
	RETURN NIL

END CLASS

