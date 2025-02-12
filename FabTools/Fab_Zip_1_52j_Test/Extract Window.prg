using FabZip
using VO


STATIC DEFINE EXTRACTWND_SLEDIR := 100
STATIC DEFINE EXTRACTWND_FOLDERSTV := 101
STATIC DEFINE EXTRACTWND_FILESGROUP := 102
STATIC DEFINE EXTRACTWND_SELECTRADIO := 103
STATIC DEFINE EXTRACTWND_ALLRADIO := 104
STATIC DEFINE EXTRACTWND_EXTRACTGROUP := 105
STATIC DEFINE EXTRACTWND_NORMALBTN := 106
STATIC DEFINE EXTRACTWND_FRESHENBTN := 107
STATIC DEFINE EXTRACTWND_UPDATEBTN := 108
STATIC DEFINE EXTRACTWND_OVERWRITE := 109
STATIC DEFINE EXTRACTWND_DIRNAME := 110
STATIC DEFINE EXTRACTWND_PBOK := 111
STATIC DEFINE EXTRACTWND_PBCANCEL := 112
STATIC DEFINE EXTRACTWND_FIXEDTEXT1 := 113
STATIC DEFINE EXTRACTWND_FIXEDTEXT2 := 114
PARTIAL CLASS ExtractWnd INHERIT DIALOGWINDOW
	PROTECT oDCSLEDir AS SINGLELINEEDIT
	PROTECT oDCFoldersTV AS TREEVIEW
	PROTECT oDCFilesGroup AS RADIOBUTTONGROUP
	PROTECT oCCSelectRadio AS RADIOBUTTON
	PROTECT oCCAllRadio AS RADIOBUTTON
	PROTECT oDCExtractGroup AS RADIOBUTTONGROUP
	PROTECT oCCNormalBtn AS RADIOBUTTON
	PROTECT oCCFreshenBtn AS RADIOBUTTON
	PROTECT oCCUpdateBtn AS RADIOBUTTON
	PROTECT oDCOverwrite AS CHECKBOX
	PROTECT oDCDirName AS CHECKBOX
	PROTECT oCCPBOk AS PUSHBUTTON
	PROTECT oCCPBCancel AS PUSHBUTTON
	PROTECT oDCFixedText1 AS FIXEDTEXT
	PROTECT oDCFixedText2 AS FIXEDTEXT

	// {{%UC%}} User code starts here (DO NOT remove this line)
	EXPORT	oXTract		AS	FabExtractOptions
	EXPORT	lAll		AS	LOGIC

	ACCESS DirName
		// Get Dir
		RETURN SELF:oDCSLEDir:CurrentText

	ASSIGN DirName ( cDir )
		SELF:oDCSLEDir:CurrentText := cDir



	METHOD Drop( oDragEvent)
		// Set the CurrentText to provide an EditChange for TreeView
		SELF:oDCSLEDir:CurrentText  := oDragEvent:FileName( 1)+"\"
		return self

	METHOD EditChange(oControlEvent)
		LOCAL uValue AS USUAL
		LOCAL nPos as dword
		//
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



	CONSTRUCTOR(oParent,uExtra)

		SELF:PreInit(oParent,uExtra)

		SUPER(oParent , ResourceID{"ExtractWnd" , _GetInst()} , TRUE)

		SELF:oDCSLEDir := SINGLELINEEDIT{SELF , ResourceID{ EXTRACTWND_SLEDIR  , _GetInst() } }
		SELF:oDCSLEDir:HyperLabel := HyperLabel{#SLEDir , NULL_STRING , NULL_STRING , NULL_STRING}

		SELF:oDCFoldersTV := TREEVIEW{SELF , ResourceID{ EXTRACTWND_FOLDERSTV  , _GetInst() } }
		SELF:oDCFoldersTV:HyperLabel := HyperLabel{#FoldersTV , "FoldersTreeView" , NULL_STRING , NULL_STRING}

		SELF:oDCFilesGroup := RADIOBUTTONGROUP{SELF , ResourceID{ EXTRACTWND_FILESGROUP  , _GetInst() } }
		SELF:oDCFilesGroup:HyperLabel := HyperLabel{#FilesGroup , "Files" , NULL_STRING , NULL_STRING}

		SELF:oCCSelectRadio := RADIOBUTTON{SELF , ResourceID{ EXTRACTWND_SELECTRADIO  , _GetInst() } }
		SELF:oCCSelectRadio:HyperLabel := HyperLabel{#SelectRadio , "&Selected Files" , NULL_STRING , NULL_STRING}

		SELF:oCCAllRadio := RADIOBUTTON{SELF , ResourceID{ EXTRACTWND_ALLRADIO  , _GetInst() } }
		SELF:oCCAllRadio:HyperLabel := HyperLabel{#AllRadio , "&All Files" , NULL_STRING , NULL_STRING}

		SELF:oDCExtractGroup := RADIOBUTTONGROUP{SELF , ResourceID{ EXTRACTWND_EXTRACTGROUP  , _GetInst() } }
		SELF:oDCExtractGroup:HyperLabel := HyperLabel{#ExtractGroup , "Extract Mode" , NULL_STRING , NULL_STRING}

		SELF:oCCNormalBtn := RADIOBUTTON{SELF , ResourceID{ EXTRACTWND_NORMALBTN  , _GetInst() } }
		SELF:oCCNormalBtn:TooltipText := "All files"
		SELF:oCCNormalBtn:HyperLabel := HyperLabel{#NormalBtn , "&Normal" , NULL_STRING , NULL_STRING}

		SELF:oCCFreshenBtn := RADIOBUTTON{SELF , ResourceID{ EXTRACTWND_FRESHENBTN  , _GetInst() } }
		SELF:oCCFreshenBtn:TooltipText := "Only newer files"
		SELF:oCCFreshenBtn:HyperLabel := HyperLabel{#FreshenBtn , "&Freshen" , NULL_STRING , NULL_STRING}

		SELF:oCCUpdateBtn := RADIOBUTTON{SELF , ResourceID{ EXTRACTWND_UPDATEBTN  , _GetInst() } }
		SELF:oCCUpdateBtn:TooltipText := "Newer files and brand new files"
		SELF:oCCUpdateBtn:HyperLabel := HyperLabel{#UpdateBtn , "&Update" , NULL_STRING , NULL_STRING}

		SELF:oDCOverwrite := CHECKBOX{SELF , ResourceID{ EXTRACTWND_OVERWRITE  , _GetInst() } }
		SELF:oDCOverwrite:HyperLabel := HyperLabel{#Overwrite , "&Overwrite Existing Files" , NULL_STRING , NULL_STRING}

		SELF:oDCDirName := CHECKBOX{SELF , ResourceID{ EXTRACTWND_DIRNAME  , _GetInst() } }
		SELF:oDCDirName:HyperLabel := HyperLabel{#DirName , "Use &Dir Names" , NULL_STRING , NULL_STRING}

		SELF:oCCPBOk := PUSHBUTTON{SELF , ResourceID{ EXTRACTWND_PBOK  , _GetInst() } }
		SELF:oCCPBOk:HyperLabel := HyperLabel{#PBOk , "&Ok" , NULL_STRING , NULL_STRING}

		SELF:oCCPBCancel := PUSHBUTTON{SELF , ResourceID{ EXTRACTWND_PBCANCEL  , _GetInst() } }
		SELF:oCCPBCancel:HyperLabel := HyperLabel{#PBCancel , "&Cancel" , NULL_STRING , NULL_STRING}

		SELF:oDCFixedText1 := FIXEDTEXT{SELF , ResourceID{ EXTRACTWND_FIXEDTEXT1  , _GetInst() } }
		SELF:oDCFixedText1:HyperLabel := HyperLabel{#FixedText1 , "Folders" , NULL_STRING , NULL_STRING}

		SELF:oDCFixedText2 := FIXEDTEXT{SELF , ResourceID{ EXTRACTWND_FIXEDTEXT2  , _GetInst() } }
		SELF:oDCFixedText2:HyperLabel := HyperLabel{#FixedText2 , "Destination" , NULL_STRING , NULL_STRING}

		SELF:oDCFilesGroup:FillUsing({ ;
		{SELF:oCCSelectRadio, "S"}, ;
		{SELF:oCCAllRadio, "A"} ;
		})

		SELF:oDCExtractGroup:FillUsing({ ;
		{SELF:oCCNormalBtn, "N"}, ;
		{SELF:oCCFreshenBtn, "F"}, ;
		{SELF:oCCUpdateBtn, "U"} ;
		})

		SELF:Caption := "Extract"
		SELF:HyperLabel := HyperLabel{#ExtractWnd , "Extract" , NULL_STRING , NULL_STRING}

		SELF:PostInit(oParent,uExtra)

		RETURN


	METHOD PBCancel( )
		SELF:EndDialog( 0)
		return self

	METHOD PBOk( )
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
		RETURN SELF

	METHOD PostInit(oParent,uExtra)
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
		RETURN SELF

	METHOD Recurse( oTVI)
		LOCAL aTab 			AS ARRAY
		LOCAL oTreeItem1 	AS TreeViewItem
		LOCAL oTreeItem2 	AS TreeViewItem
		LOCAL nI 			AS DWORD
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
					//
					//
					TRY
						IF FFirst( (string)(sDir+aTab[nI][F_NAME]+"\*.*"), FA_DIRECTORY)
							IF CharPos( FName(), 1) != "."  .Or. (FNext() .And. FNext())
								// si le r�pertoire contient d'autres sous-r�pertoires, on ajoute un item dummy
								// qui permet d'avoir le + et de recevoir l'�v�nement TreeViewItemExpanding
								oTreeItem2 := TreeViewItem{}
								oTreeItem2:NameSym := String2Symbol( LTrim(sDir+aTab[nI][F_NAME])+"\DUMMY")
								oTreeItem2:TextValue := aTab[nI][F_NAME]
								oTreeItem2:Value := {FALSE,"DUMMY"}
								SELF:oDCFoldersTV:AddItem( oTreeItem1:NameSym, oTreeItem2)
							ENDIF
						ENDIF
					CATCH
						// Probably due to unreadable folder/file (no right)
                        NOP
					END TRY
					// catch
				ENDIF
			NEXT // nI
		ENDIF
		SELF:Pointer := oPtr

		return self

	METHOD	SELECT( lSelected )
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

	METHOD TreeViewItemExpanding(oTreeViewExpandingEvent)
		SUPER:TreeViewItemExpanding(oTreeViewExpandingEvent)
		//Put your changes here
		IF oTreeViewExpandingEvent:TreeViewItem:Value[1] == FALSE
			SELF:Recurse( oTreeViewExpandingEvent:TreeViewItem )
		ENDIF
		RETURN NIL

	METHOD TreeViewSelectionChanged(oTreeViewSelectionEvent)
		SUPER:TreeViewSelectionChanged( oTreeViewSelectionEvent)
		//Put your changes here
		IF !IsNil( oTreeViewSelectionEvent:NewTreeViewItem)
			SELF:oDCSLEDir:TextValue := Symbol2String( oTreeViewSelectionEvent:NewTreeViewItem:NameSym)
		ENDIF
		RETURN NIL

END CLASS

