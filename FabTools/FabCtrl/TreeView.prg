USING VO


CLASS FabTreeView INHERIT TreeView


CONSTRUCTOR(oOwner, xID, oPoint, oDimension, kStyle)  
   SUPER(oOwner, xID, oPoint, oDimension, kStyle)
   RETURN

METHOD AddItem(symParentName, oTreeViewItem, lHasChildren ) 
	// insert this item as the last item in the parent item's list
RETURN SELF:InsertItem(symParentName, #Last, oTreeViewItem, lHasChildren )

METHOD InsertItem(symParentName, symInsertAfter, oTreeViewItem, lHasChildren ) 
	LOCAL lResult AS LOGIC
	LOCAL strucItem IS _winTV_ITEM
	//
	Default( @lHasChildren, FALSE )
	//
	lResult := SUPER:InsertItem( symParentName, symInsertAfter, oTreeViewItem)
	//
	IF ( lResult ) .AND. ( lHasChildren )
		strucItem:mask := _Or(TVIF_HANDLE, TVIF_CHILDREN)
		strucItem:hItem := SELF:__GetHandleFromSymbol( oTreeViewItem:NameSym )
		strucItem:cChildren := 1
		TreeView_SetItem( SELF:Handle(), @strucItem )
	ENDIF
	//
RETURN lResult

END CLASS

