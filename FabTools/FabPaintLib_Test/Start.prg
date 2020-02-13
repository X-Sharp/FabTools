#include "VOGUIClasses.vh"
#include "VOSystemLibrary.vh"
#include "VOWin32APILibrary.vh"
CLASS VulcanApp INHERIT App

METHOD Start() 
	LOCAL oMainWindow AS ImgViewShell
	//
	WCSetCoordinateSystem(WCWindowsCoordinates)
	CAPaintShowErrors( TRUE )
	//
	oMainWindow := ImgViewShell{SELF}
	oMainWindow:Show(SHOWCENTERED)
	//
	SELF:Exec()
	//
	
return self	
END CLASS

PROC	InitCAPaint()		_INIT3
// You don't need this function ( Starting with FabPaintLib 1.2 )
return 
FUNC	ExitCAPaint	()	AS VOID STRICT
// You don't need this function ( Starting with FabPaintLib 1.2 )
return 
FUNCTION FabExtractFileExt( FileName AS STRING) AS STRING  STRICT
//g Files,Files Related Classes/Functions
//p Extract File Extension info from FullPath String
//l Extract File Extension info from FullPath String
//r the File Extension ( always start with a . char )
//e "C:\TEST\TESTFILE.TST"			->	".TST"
//e "C:\TEST\TESTFILE."				->	"."
//e "C:\TEST\TESTFILE"				->	""
	LOCAL wPos		AS	DWORD
	LOCAL cResult	AS	STRING
	//
	wPos := SLen( FileName )
	// Starting at end of String, search for a Path, Drive or extension separator
	WHILE ( wPos > 0 ) .and. !Instr( SubStr3( FileName, wPos, 1 ), "\:." )
		wPos --
	ENDDO
	//
	IF ( wPos > 0 ) .AND. SubStr3( FileName, wPos, 1 ) == "."
		cResult := SubStr2( FileName, wPos )
	ENDIF
RETURN cResult	
FUNCTION FabMakeIntResource( i AS DWORD )	AS PTR
RETURN  PTR( _CAST, DWORD( WORD( i ) ) )

FUNCTION FabSetWindowStyle( hWnd AS PTR, liAdd AS LONG ) AS LONG
//g Window,Window/Dialog Related Classes/Functions
//l Set Window style
//p Set Window style
//a <hWnd> is the Handle of the window who's style must be changed\line
//a <liAdd> is the Style Value to set
//r The previous Style Value

	LOCAL liStyle	AS	LONGINT
	// Get Style
	liStyle := GetWindowLong( hWnd, GWL_STYLE )
	liStyle := _Or( liStyle, liAdd )
	SetWindowLong( hWnd, GWL_STYLE, liStyle )
	//
RETURN liStyle
FUNCTION FabGetStringArrayInPsz( pszMem AS PTR ) AS ARRAY
//g String,String Manipulation
//l Retrieve an array of strings stored in memory.
//p Retrieve an array of strings stored in memory.
//x <pszMem> is a pointer to a memory filled with psz strings.
//r An array of strings
//d FabGetStringArrayInPsz() will read each byte found starting at <pszMem>, copy each one to a string, stopping at the first zero byte encountered.\line
//d Each string is ended with a Null char.  A double null char mark the end of the array.\line
//d \b !!! Warning !!: You must have a double null char in the buffer to end the conversion \b0
/*
 Return the array string that the Psz Pointer is pointing

	Each string is ended with a Null char.
	A double null char mark the end of the array.
	
!!! Warning !!: You must have a null char in the buffer to end the conversion
*/
	LOCAL ptrSrc	AS	BYTE PTR
	LOCAL sString	AS	STRING
	LOCAL aString	AS	ARRAY
	//
 	ptrSrc := pszMem
 	aString := {}
 	//
	DO WHILE TRUE
		//
		sString := Psz2String( ptrSrc )
		IF ( SLen( sString ) == 0 )
			// Out
			EXIT
		ENDIF
		AAdd( aString,  sString )
		//
		ptrSrc := ptrSrc + SLen( sString ) + 1
		//
	ENDDO
RETURN aString
FUNCTION FabArray2Psz( aValue AS ARRAY ) AS PTR
//g String,String Manipulation
//l Convert an Array to a Psz memory
//p Convert an Array to a Psz memory
//d Convert an array of string to a buffer where each string is followed by a null character
//d and the final string is followed by a second null character.
//x <aValue> is the Array of value to store
//r A Ptr to the allocated memory. You must use the MemFree() function to free this block
	LOCAL ptrMemory	AS	PTR
	LOCAL dwSize	AS	DWORD
	//
	ptrMemory := FabArray2Psz2( aValue, @dwSize )
	//
RETURN ptrMemory



FUNCTION FabArray2Psz2( aValue AS ARRAY, dwSize REF DWORD ) AS PTR
//g String,String Manipulation
//l Convert an Array to a Psz memory, and return size of memory
//p Convert an Array to a Psz memory, and return size of memory
//d Convert an array of string to a buffer where each string is followed by a null character
//d and the final string is followed by a second null character.
//x <aValue> is the Array of value to store\line
//x <dwSize> is a DWORD passed by reference than will return the size of allocated memory.
//r A Ptr to the allocated memory. You must use the MemFree() function to free this block
/*
	Convert an array of string to a buffer where each string is followed by a null character
	and the final string is followed by a second null character.
*/
	LOCAL ptrMem	AS	PTR
	LOCAL ptrDest	AS	BYTE PTR
	LOCAL wSize		AS	DWORD
	LOCAL wCpt		AS	WORD
	LOCAL wCpt2		AS	WORD
	LOCAL sValue	AS	STRING
	// Empty Array ?
	IF ( ALen( aValue ) == 0 )
		RETURN NULL_PTR
	ENDIF
	// First, we need to know how many bytes to allocate
	FOR wCpt := 1 TO ALen( aValue )
		// Don't forget Null Char
		wSize := wSize + SLen( AsString( aValue[ wCpt ] ) ) + 1
	NEXT
	// Empty Array ?
	IF ( wSize == 0 )
		RETURN NULL_PTR
	ENDIF
	// Add double Null Char at the end
	wSize := wSize + 1
	//
	ptrMem := MemAlloc( wSize )
	IF ( ptrMem != NULL_PTR )
		ptrDest := PTR( ptrMem ) //PTR( BYTE, ptrMem )
		FOR wCpt := 1 TO ALen( aValue )
			sValue := AsString( aValue[ wCpt ] )
			FOR wCpt2 := 1 TO SLen( sValue )
				// Copy Byte
				BYTE( ptrDest ) := (byte)Asc( SubStr( sValue, wCpt2, 1 ) )
				// Move Pointer
				ptrDest ++
			NEXT
			// End-of-string
			BYTE( ptrDest ) := 0
			// Move Pointers
			ptrDest ++
		NEXT
		// End-of-string
		BYTE( ptrDest ) := 0
	ELSE
		wSize := 0
	ENDIF
	// Return REF size
	dwSize := wSize
RETURN ptrMem
