STATIC GLOBAL _FabEnumChild	AS	ARRAY

STATIC GLOBAL _FabEnumThreadWindow	AS	ARRAY

STATIC GLOBAL _FabIconCount AS 	WORD

DELEGATE _FabEnumChildCallBack_delegate( hChild AS PTR, lParam AS LONGINT ) AS LOGIC
STATIC FUNCTION _FabEnumChildCallBack( hChild AS PTR, lParam AS LONGINT ) AS LOGIC
	//
	AAdd( _FabEnumChild, hChild )
	//
RETURN TRUE


DELEGATE _FabEnumThreadWindowCallBack_delegate( hChild AS PTR, lParam AS LONGINT ) AS LOGIC
STATIC FUNCTION _FabEnumThreadWindowCallBack( hChild AS PTR, lParam AS LONGINT ) AS LOGIC
	//
	AAdd( _FabEnumThreadWindow, hChild )
	//
RETURN TRUE


DELEGATE _FabIconEnumProcedure_delegate( hModule AS PTR, lpszType AS PTR, lpszName AS PTR, lParam AS LONG ) AS LOGIC 
STATIC FUNCTION _FabIconEnumProcedure( hModule AS PTR, lpszType AS PTR, lpszName AS PTR, lParam AS LONG ) AS LOGIC CALLBACK
	//
	_FabIconCount := _FabIconCount + 1
	//
/*
	// Name is from MAKEINTRESOURCE()
	IF( HiWord( DWORD( _CAST, lpszName) ) == 0 )
		AAdd( _FabIconName, NTrim( DWORD( _CAST, lpszName) ) )
	ELSE
		// Name is string
		AAdd( _FabIconName, Psz2String( lpszName ) )
	ENDIF
	//
*/
RETURN TRUE




FUNCTION	FabEnumChildObjects( oParent AS OBJECT ) AS ARRAY
//l Array of Childs Objects
//p Retrieve an Array of Childs Objects
//x <oParent> is a valid Window/Control object
//d FabEnumChildWindows() uses the FabEnumChildWindows() to retrieve an array of child Objects.
//d The <oParent> object must have a Method called Handle() to retrieve it's Windows Handle.
//r Only valid VO Objects are returned. This means that all underlying Windows child that are not recognised by GetObjectByHandle()
//r  are removed from the array returned by FabEnumChildWindows().
	LOCAL aObjects	AS	ARRAY
	LOCAL aTemp	AS	ARRAY
	LOCAL oObject	AS	OBJECT
	LOCAL hParent	AS	PTR
	LOCAL nCpt		AS	DWORD
	//
	aObjects := { }
	IF IsMethod( oParent, #Handle )
		// Retrieve Parent's Handle
		hParent := Send( oParent, #Handle )
		// Retrieve Windows Child Handles
		aTemp := FabEnumChildWindows( hParent )
		// Now, reomve non VO-Objects
		FOR nCpt := 1 TO ALen( aTemp )
			oObject := GetObjectByHandle( aTemp[ nCPt ] )
			IF ( oObject != NULL_OBJECT )
				AAdd( aObjects, oObject )
			ENDIF
		NEXT
	ENDIF
	//
RETURN aObjects



FUNCTION	FabEnumChildWindows( hParent AS PTR ) AS ARRAY
//l Array of Childs Handles
//p Retrieve an Array of Childs Handles
//x <hParent> is a valid Window/Control Handle
//d FabEnumChildWindows() uses the API EnumChildWindows() to retrieve an array of child handles.
	LOCAL aRet	AS	ARRAY
	// Init Global Var
	_FabEnumChild := { }
//#warning Callback function modified to use a DELEGATE by xPorter. Please review.
// 	EnumChildWindows( hParent, @_FabEnumChildCallBack(), 0 )
STATIC LOCAL o_FabEnumChildCallBackDelegate := _FabEnumChildCallBack AS _FabEnumChildCallBack_Delegate

	EnumChildWindows( hParent, System.Runtime.InteropServices.Marshal.GetFunctionPointerForDelegate(o_FabEnumChildCallBackDelegate), 0 )
	// Save Global to local
	aRet := _FabEnumChild
	// And free global var
	_FabEnumChild := {}
	//
RETURN aRet




FUNCTION	FabEnumThreadWindows( ) AS ARRAY
//l Array of Windows Handles in the current thread
//p Retrieve an Array of Windows Handles in the current thread
//d FabEnumChildWindows() uses the API EnumChildWindows() to retrieve an array of child handles.
	LOCAL aRet	AS	ARRAY
	// Init Global Var
	_FabEnumThreadWindow := { }
//#warning Callback function modified to use a DELEGATE by xPorter. Please review.
// 	EnumThreadWindows( GetCurrentThreadID(), @_FabEnumThreadWindowCallBack(), 0 )
STATIC LOCAL o_FabEnumThreadWindowCallBackDelegate := _FabEnumThreadWindowCallBack AS _FabEnumThreadWindowCallBack_Delegate
	EnumThreadWindows( GetCurrentThreadID(), System.Runtime.InteropServices.Marshal.GetFunctionPointerForDelegate(o_FabEnumThreadWindowCallBackDelegate), 0 )
	// Save Global to local
	aRet := _FabEnumThreadWindow
	// And free global var
	_FabEnumThreadWindow := {}
	//
RETURN aRet




FUNCTION FabGetIconCountFromEXEFile( cEXEDLLFile AS STRING ) AS LONGINT
//l Count of Icons in EXE/DLL Files
//p Retrieve the number of Icons resources in EXE/DLL Files
//x <cEXEDLLFile> is string with a valid EXE/DLL Filename
//d FabGetIconCountFromEXEFile() uses the API EnumResourceNames() function to retrieve the count of Icon resources in a file.
//r A Numeric Value, indicating the number of Icon resources in this file.
	LOCAL hLibrary	AS	PTR
	// Load the DLL/EXE - NOTE: must be a 32bit EXE/DLL for this to work
	hLibrary := LoadLibraryEx( String2Psz( cEXEDLLFile ), NULL_PTR, LOAD_LIBRARY_AS_DATAFILE )
	//
	IF( hLibrary == NULL_PTR )
		RETURN  -1
	ENDIF
	//
	_FabIconCount := 0
//#warning Callback function modified to use a DELEGATE by xPorter. Please review.
// 	EnumResourceNames( hLibrary, RT_GROUP_ICON, @_FabIconEnumProcedure(), 0 )
STATIC LOCAL o_FabIconEnumProcedureDelegate := _FabIconEnumProcedure AS _FabIconEnumProcedure_Delegate
	EnumResourceNames( hLibrary, RT_GROUP_ICON, System.Runtime.InteropServices.Marshal.GetFunctionPointerForDelegate(o_FabIconEnumProcedureDelegate), 0 )
	//
	FreeLibrary( hLibrary )
	//
RETURN	( _FabIconCount )





