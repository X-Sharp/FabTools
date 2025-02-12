USING VO


CLASS	FabOpenDialog	INHERIT	FabStandardFileDialog
	//g Window, Window/Dialog Related Classes/Functions
	//l Replacement the VO OpenDialog
	//p Class that allow to change the Caption of controls on the OpenDialog box, and to add a User-Defined Dialog resource

	EXPORT	ListboxText		AS	STRING
	//s
	// Text for the Open Button
	EXPORT	OkText			AS	STRING
	// Text for the Cancel Button
	EXPORT	CancelText		AS	STRING
	// Text for the Help Button
	EXPORT	HelpText			AS	STRING
	// Text for the Combobox with drives
	EXPORT ComboDriveText	AS	STRING
	// Text for the SingleLineEdit
	EXPORT EditText			AS	STRING
	// Text for the Combobox with Filters
	EXPORT ComboFiltersText	AS	STRING
	// Text for the Read-Only Checkbox
	EXPORT CheckText		AS	STRING





	CONSTRUCTOR( oOwner, cFileName )
		SUPER( oOwner, cFileName )
		RETURN

	PROTECT METHOD InitDlg( oEvent, hDlg )
		//
		SUPER:InitDlg( oEvent, hDlg )
		//
		DO CASE
		CASE ( oEvent:Message == WM_INITDIALOG )
			//
			IF !Empty( SELF:OkText )
				CommDlg_OpenSave_SetControlText( GetParent(hdlg), IDOK, LONG( _CAST, String2Psz( SELF:OkText ) )  )
			ENDIF
			//
			IF !Empty( SELF:CancelText )
				CommDlg_OpenSave_SetControlText( GetParent(hdlg), IDCANCEL, LONG( _CAST, String2Psz( SELF:CancelText ) )  )
			ENDIF
			//
			IF !Empty( SELF:ComboDriveText )
				CommDlg_OpenSave_SetControlText( GetParent(hdlg), STC4, LONG( _CAST, String2Psz( SELF:ComboDriveText ) )  )
			ENDIF
			//
			IF !Empty( SELF:ListboxText )
				CommDlg_OpenSave_SetControlText( GetParent(hdlg), STC1, LONG( _CAST, String2Psz( SELF:ListboxText ) )  )
			ENDIF
			//
			IF !Empty( SELF:EditText )
				CommDlg_OpenSave_SetControlText( GetParent(hdlg), STC3, LONG( _CAST, String2Psz( SELF:EditText ) )  )
			ENDIF
			//
			IF !Empty( SELF:ComboFiltersText )
				CommDlg_OpenSave_SetControlText( GetParent(hdlg), STC2, LONG( _CAST, String2Psz( SELF:ComboFiltersText ) )  )
			ENDIF
			//
			IF !Empty( SELF:HelpText )
				CommDlg_OpenSave_SetControlText( GetParent(hdlg), pshHelp, LONG( _CAST, String2Psz( SELF:HelpText ) )  )
			ENDIF
			//
			IF !Empty( SELF:CheckText )
				CommDlg_OpenSave_SetControlText( GetParent(hdlg), chx1, LONG( _CAST, String2Psz( SELF:CheckText ) )  )
			ENDIF
			//
		ENDCASE
		//
		RETURN	0



	METHOD Show()
		LOCAL lSuccess	AS	LOGIC
		// Fill structure
		IF SELF:FillStruct()
			// Call GetOpenFileName() or GetSaveFileName()
			lSuccess := GetOpenFileName( SELF:ptrOpen )
			IF !lSuccess
				MemSet( SELF:ptrFile, 0, MAX_PATH + 1 )
			ENDIF
			// Don't forget to free memory
			SELF:FreeStruct()
		ENDIF
		RETURN lSuccess



END CLASS

CLASS	FabSaveDialog	INHERIT	FabStandardFileDialog
	//g Window, Window/Dialog Related Classes/Functions
	//l Replacement the VO SaveDialog
	//p Class that allow to change the Caption of controls on the SaveDialog box, and to add a User-Defined Dialog resource

	// Text for the File Listview
	EXPORT ListboxText		AS	STRING
	//s
	// Text for the Save Button
	EXPORT OkText			AS	STRING
	// Text for the Cancel Button
	EXPORT CancelText		AS	STRING
	// Text for the Help Button
	EXPORT HelpText		AS	STRING
	// Text for the Combobox with drives
	EXPORT	 ComboDriveText	AS	STRING
	// Text for the SingleLineEdit
	EXPORT	 EditText			AS	STRING
	// Text for the Combobox with Filters
	EXPORT	 ComboFiltersText	AS	STRING



	CONSTRUCTOR( oOwner, cFileName )
		//
		SUPER( oOwner, cFileName )
		//
		SELF:SetStyle( OFN_HIDEREADONLY, TRUE  )




		RETURN

	PROTECT METHOD InitDlg( oEvent, hDlg )
		//
		SUPER:InitDlg( oEvent, hDlg )
		//
		DO CASE
		CASE ( oEvent:Message == WM_INITDIALOG )
			//
			IF !Empty( SELF:OkText )
				CommDlg_OpenSave_SetControlText( GetParent(hdlg), IDOK, LONG( _CAST, String2Psz( SELF:OkText ) )  )
			ENDIF
			//
			IF !Empty( SELF:CancelText )
				CommDlg_OpenSave_SetControlText( GetParent(hdlg), IDCANCEL, LONG( _CAST, String2Psz( SELF:CancelText ) )  )
			ENDIF
			//
			IF !Empty( SELF:ComboDriveText )
				CommDlg_OpenSave_SetControlText( GetParent(hdlg), STC4, LONG( _CAST, String2Psz( SELF:ComboDriveText ) )  )
			ENDIF
			//
			IF !Empty( SELF:ListboxText )
				CommDlg_OpenSave_SetControlText( GetParent(hdlg), STC1, LONG( _CAST, String2Psz( SELF:ListboxText ) )  )
			ENDIF
			//
			IF !Empty( SELF:EditText )
				CommDlg_OpenSave_SetControlText( GetParent(hdlg), STC3, LONG( _CAST, String2Psz( SELF:EditText ) )  )
			ENDIF
			//
			IF !Empty( SELF:ComboFiltersText )
				CommDlg_OpenSave_SetControlText( GetParent(hdlg), STC2, LONG( _CAST, String2Psz( SELF:ComboFiltersText ) )  )
			ENDIF
			//
			IF !Empty( SELF:HelpText )
				CommDlg_OpenSave_SetControlText( GetParent(hdlg), pshHelp, LONG( _CAST, String2Psz( SELF:HelpText ) )  )
			ENDIF
			//
		ENDCASE
		//
		RETURN	0



	METHOD Show()
		LOCAL lSuccess	AS	LOGIC
		// Fill structure
		IF SELF:FillStruct()
			// Call GetOpenFileName() or GetSaveFileName()
			lSuccess := GetSaveFileName( SELF:ptrOpen )
			IF !lSuccess
				MemSet( SELF:ptrFile, 0, MAX_PATH + 1 )
			ENDIF
			// Don't forget to free memory
			SELF:FreeStruct()
		ENDIF
		RETURN lSuccess



END CLASS

CLASS	FabStandardFileDialog
	//g Window, Window/Dialog Related Classes/Functions
	//l Replacement the VO StandardFileDialog
	//d This class replace the VO StandardFileDialog to allow the extension of the dialog using a User-Defined dialog resource.\line
	//d This is an abstract class, you must not use it directly, but instead use the FabSaveDialog or  FabOpenDialog classes.
	// Ptr to OpenFileName Struct
	PROTECT	ptrOpen		AS	_winOpenFileName
	// Ptr to memory to store the selected filename
	PROTECT 	ptrFile		AS	PTR
	// Array of String to hold the FileName
	PROTECT 	aFile		AS	ARRAY
	// Array of Filters
	PROTECT	aFilters		AS	ARRAY
	// FilterIndex
	PROTECT 	nFilterIndex 	AS WORD
	// Flags
	PROTECT	liFlags		as	dword
	// Initial directory
	PROTECT 	cInitDir		AS	STRING
	// Owner Handle
	PROTECT	hWndOwner	AS	PTR
	// Default selected File
	PROTECT 	cDefFile		AS	STRING


	//s
	// Resource to Add
	EXPORT		ResourceDlg	AS	ResourceID
	// Caption of the Dialog
	EXPORT		Caption		AS	STRING
	// Default Extension
	EXPORT		DefExt		AS	STRING



	METHOD Dispatch( oEvent, hDlg )




		RETURN self

	PROTECT METHOD EndInitDlg( oEvent, hDlg )



		RETURN self

	METHOD FabDispatch( oEvent, hDlg )
		LOCAL NMHDR		AS	_winNMHDR
		LOCAL lRet		AS	LOGIC
		LOCAL uRet		AS	USUAL
		// First call
		IF ( oEvent:Message == WM_INITDIALOG )
			SELF:InitDlg( oEvent, hDlg )
		ENDIF
		// If the Init of the StandardDialog is over
		IF ( oEvent:Message == WM_NOTIFY )
			NMHDR := PTR( _CAST, oEvent:lParam )
			IF ( NMHDR:_code == DWORD( _CAST, CDN_INITDONE ) )
				SELF:EndInitDlg( oEvent, hDlg )
			ENDIF
		ENDIF
		// Is there a Dispatch method ?
		IF IsMethod( SELF, #Dispatch )
			// Send event
			uRet := Send( SELF, #Dispatch, oEvent, hDlg )
			IF IsNumeric( uRet )
				lRet := IIF( uRet == 0, FALSE, TRUE )
			ENDIF
			//
		ENDIF
		// If the message is a Click on Help ?
		IF ( oEvent:Message == WM_NOTIFY )
			NMHDR := PTR( _CAST, oEvent:lParam )
			IF ( NMHDR:_code == DWORD( _CAST, CDN_HELP ) )
				// Check if there is a Help method.
				IF IsMethod( SELF, #Help )
					uRet := Send( SELF, #Help )
					IF IsNumeric( uRet )
						lRet := IIF( uRet == 0, FALSE, TRUE )
					ENDIF
				ENDIF
			ENDIF
		ENDIF
		// End...
		IF ( oEvent:Message == WM_DESTROY )
			// Force to fill the FileName property
			SELF:aFile := FabGetStringArrayInPsz( SELF:ptrFile )
			//
			IF IsMethod( SELF, #Destroy )
				// Send event
				Send( SELF, #Destroy, oEvent, hDlg )
			ELSEIF IsMethod( SELF, #OnClose )
				// Send event
				Send( SELF, #OnClose, oEvent, hDlg )
			ENDIF
		ENDIF
		RETURN lRet


	ACCESS FileName
		LOCAL uFile	AS	USUAL
		//
		IF !Empty( SELF:aFile )
			// Multiple Files
			IF ( ALen( SELF:aFile ) > 1 )
				uFile := AClone( SELF:aFile )
			ELSE
				uFile := SELF:aFile[ 1 ]
			ENDIF
		ENDIF
		//
		RETURN uFile



	ASSIGN FileName( cNew )
		SELF:cDefFile := cNEw
		RETURN

	PROTECT METHOD FillStruct()
		LOCAL HookDelegate AS _Delegate_FabComDlg32HookProc
		//
		SELF:ptrOpen := MemAlloc( _sizeof( _winOpenFileName ) )
		IF ( SELF:ptrOpen != NULL_PTR )
			// Fill struct
			ptrOpen:lStructSize       := _sizeof( _winOPENFILENAME )
			ptrOpen:hwndOwner         := SELF:hWndOWner
			IF ( SELF:RESOURCEDlg != NULL_OBJECT )
				ptrOpen:hInstance     := SELF:ResourceDlg:Handle()
				IF IsString( SELF:ResourceDlg:ID )
					ptrOpen.lpTemplateName    := PTR(_cast, SELF:ResourceDlg:Address() )
				ELSE
					ptrOpen.lpTemplateName    := FabMakeIntResource( SELF:ResourceDlg:ID )
				ENDIF
				SELF:SetStyle( OFN_ENABLETEMPLATE )
			ENDIF
			//
			ptrOpen.lpstrFilter       := FabArray2Psz( SELF:aFilters )
			ptrOpen.nFilterIndex      := SELF:nFilterIndex
			ptrOpen.lpstrCustomFilter := NULL
			ptrOpen.nMaxCustFilter    := 0
			//
			SELF:ptrFile := MemAlloc( MAX_PATH + 1 )
			IF !Empty( cDefFile )
				MemCopyString( SELF:ptrFile, SELF:cDefFile, SLen( SELF:cDefFile ) )
			ENDIF
			ptrOpen.lpstrFile         := SELF:ptrFile
			ptrOpen.nMaxFile          := (DWORD)MAX_PATH
			ptrOpen.lpstrFileTitle    := NULL
			ptrOpen.nMaxFileTitle     := 0
			IF !Empty( SELF:cInitDir )
				ptrOpen.lpstrInitialDir   := StringAlloc( SELF:cInitDir )
			ENDIF
			IF !Empty( SELF:Caption )
				ptrOpen.lpstrTitle	  := StringAlloc( SELF:Caption )
			ENDIF
			ptrOpen.nFileOffset       := 0
			ptrOpen.nFileExtension    := 0
			IF !Empty( SELF:DefExt )
				ptrOpen.lpstrDefExt       := StringAlloc( SELF:DefExt )
			ELSE
				ptrOpen.lpstrDefExt       := NULL
			ENDIF
			ptrOpen.lCustData         := 0
			HookDelegate := _Delegate_FabComDlg32HookProc{ NULL, @_FabComDlg32HookProc() }
			ptrOpen.lpfnHook          := System.Runtime.InteropServices.Marshal.GetFunctionPointerForDelegate( (System.Delegate) HookDelegate )
			ptrOpen.Flags             := SELF:liFlags
			//
			_FabSelfDlgObject := SELF
			//
		ENDIF
		RETURN ( SELF:ptrOpen != NUll_PTR )



	PROTECT METHOD	FreeStruct()
		// Remove reference to the dialog
		_FabSelfDlgObject := NIL
		// Convert ptr to Array of File(s)
		SELF:aFile := FabGetStringArrayInPsz( SELF:ptrFile )
		// Free buffer for FileName
		MemFree( SELF:ptrFile )
		// Free Memory of Filters
		MemFree( SELF:ptrOpen:lpstrFilter )
		// Free memory for the caption
		MemFree( SELF:ptrOpen:lpstrTitle )
		// Free memory for the initial directory
		MemFree( SELF:ptrOpen:lpstrInitialDir )
		IF ( ptrOpen:lpstrDefExt != NULL_PSZ )
			MemFree( ptrOpen:lpstrDefExt )
		ENDIF
		// Free the structure
		MemFree( SELF:ptrOpen )
		SELF:ptrOpen := NULL_PTR
		//


		RETURN self

	METHOD help()



		RETURN self

	CONSTRUCTOR( oOwner, cFileName )
		//
		Default( @cFileName, "*.*" )
		SELF:cDefFile := cFileName
		//
		IF IsObject( oOwner )
			IF IsMethodUsual( oOwner, #Handle )
				SELF:hWndOwner := oOwner:Handle()
			ENDIF
		ENDIF
		//
		SELF:liFlags := _Or( OFN_SHOWHELP, OFN_EXPLORER, OFN_ENABLEHOOK )
		//



		RETURN

	PROTECT METHOD InitDlg( oEvent, hDlg )
		FabSetWindowStyle( hDlg, WS_CHILD )
		FabSetWindowStyle( hDlg, WS_VISIBLE )
		FabSetWindowStyle( hDlg, WS_CLIPSIBLINGS )
		FabSetWindowStyle( hDlg, DS_3DLOOK )
		FabSetWindowStyle( hDlg, DS_CONTROL )



		RETURN self

	ACCESS InitialDirectory
		RETURN	SELF:cInitDir



	ASSIGN InitialDirectory( cNewDir )
		IF IsString( cNewDir )
			SELF:cInitDir := cNewDir
		ENDIF
		RETURN



	METHOD SetFilter( acFilter, acDesc, nIndex )
		LOCAL aFilters	AS	ARRAY
		LOCAL aDesc		AS	ARRAY
		LOCAL wCpt		AS	WORD
		//
		Default( @nIndex, 1 )
		//
		IF IsString( acFilter ) .and. IsString( acDesc )
			aFilters := { acFilter }
			aDesc := { acDesc }
		ELSEIF IsArray( acFilter ) .and. IsArray( acDesc )
			aFilters := AClone( acFilter )
			aDesc := AClone( acDesc )
		ENDIF
		//
		IF !Empty( aFilters ) .and. !Empty( aDesc ) .and. ( ALen( aFilters ) == ALen( aDesc ) )
			//
			SELF:aFilters := {}
			FOR wCpt := 1 TO Min( ALen( aFilters ), ALen( aDesc ) )
				AAdd( SELF:aFilters, aDesc[ wCpt ] )
				AAdd( SELF:aFilters, aFilters[ wCpt ] )
			NEXT
		ENDIF
		//
		SELF:nFilterIndex := nIndex
		//





		RETURN self

	METHOD	SetStyle( kStyle, lOnOff )
		//
		Default( @lOnOff, TRUE )
		//
		IF lOnOff
			SELF:liFlags := (DWORD)_Or( SELF:liFlags, LONG( kStyle ) )
		ELSE
			SELF:liFlags := (DWORD)_Or( SELF:liFlags, LONG( kStyle ) )
			SELF:liFlags := (DWORD)_Xor( SELF:liFlags, LONG( kStyle ) )
		ENDIF


		RETURN self

	METHOD	Show( )
		// Deferred


		RETURN self


	DELEGATE _Delegate_FabComDlg32HookProc( hDlg AS PTR, uMsg AS DWORD, wParam AS DWORD , lParam AS LONG ) AS LOGIC

END CLASS

/* TEXTBLOCK !Read-Me
/-*
Full access to all customization feature of the StandardFileDialog

Use some undocumented features of the ResourceID class
ID Access	:	ID of the ressource in numerical format
Handle()	:	hInstance of the module that own the resource
Address()	:	ptr ( ? )

You can set the text of each Button / FixedText using the Exported properties in
FabOpenDialog
FabSaveDialog

If you need a deeper access, you can even change the look of the Dialog by setting the
ResourceDlg property with a valid ResourceId object
*-/



*/
STATIC FUNCTION _FabComDlg32HookProc( hDlg AS PTR, uMsg AS DWORD, wParam AS DWORD , lParam AS LONG ) AS LOGIC /* CALLBACK */
	LOCAL oDlg 		AS 	FabStandardFileDialog
	LOCAL lRet		AS	LOGIC
	LOCAL oEvent	AS 	@@Event
	// Get the Dialog
	oDlg := _FabSelfDlgObject
	// Ignore default processing of message
	lRet := TRUE
	// Call our "private" Dispatch
	// Build event
	oEvent := @@Event{ hDlg, uMsg, wParam, lParam }
	// Sending Event
	lRet := Send( oDlg, #FabDispatch, oEvent, hDlg )
	//
	RETURN lRet



STATIC GLOBAL _FabSelfDlgObject


