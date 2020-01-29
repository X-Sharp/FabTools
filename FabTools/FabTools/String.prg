FUNCTION FabAllTrim( c AS STRING ) AS STRING
RETURN FabLTrim( FabRTrim( c ) )

	



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
	dwSize := 0
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
	LOCAL wSize		:= 0 AS	DWORD
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
		ptrDest := PTR( BYTE, ptrMem )
		FOR wCpt := 1 TO ALen( aValue )
			sValue := AsString( aValue[ wCpt ] )
			FOR wCpt2 := 1 TO SLen( sValue )
				// Copy Byte
				BYTE( ptrDest ) := Asc( SubStr( sValue, wCpt2, 1 ) )
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





FUNCTION FabArray2String( aArray , cSep  ) AS STRING
//g String,String Manipulation
//l Convert an Array to string
//p Convert an Array to string using a separator
//x <aArray> is the array to use as source.It can any hold any type of values\line
//x <cSep> is the separator. Default value is ","
//r The constructed string
//e 	FabArray2String( ( "One", "Two", "", "Four" ), "," ) -> "One, Two,, Four"
	LOCAL sRetVal		AS	STRING
	LOCAL uVal			AS	USUAL
	LOCAL wCpt			as	DWORD
	LOCAL wMax			as	DWORD
	//
	Default( @cSep, "," )
	//
	sRetVal := ""
	wMax := ALen( aArray )
	//
	FOR wCpt := 1 TO wMax
		uVal := ArrayGet( aArray, wCpt )
		sRetVal := sRetVal + AsString( uVal )
		IF ( wCpt != wMax )
			sRetVal := sRetVal + cSep
		ENDIF
	NEXT
	//
RETURN sRetVal




FUNCTION FabCharPosLine( sChaine AS STRING, wPos AS WORD ) AS DWORD
	LOCAL wCurrent	AS	DWORD
	LOCAL wCRLF		as	DWORD
	LOCAL wOffset	AS	DWORD
	//
	wOffset := 1
	wCurrent := 1
	//
	WHILE TRUE
		wCRLF := At3( CRLF, sChaine, wOffset - 1)
		IF ( wCRLF == 0 )  .or. ( wCurrent == wPos )
			EXIT
		ENDIF
		wOffset := wCRLF + 2
		wCurrent ++
	ENDDO
	//
RETURN wOffset





FUNCTION FabCountLines( cString AS STRING ) AS DWORD
//g String,String Manipulation
//l Count the Number of CRLF sequences
//p Count the Number of CRLF sequences. If the two last chars is not a CRLF sequence, add one to the return value.

	LOCAL nCount AS DWORD
	// Count the Number of CRLF sequences
	nCount := Occurs2( CRLF, cString )
	// Check if the tow last chars is a CRLF sequence
	IF !( Right( cString, 2 ) == CRLF )
		// Not, so add a line
		nCount := nCount + 1
	ENDIF
RETURN nCount




PROCEDURE FabExpurgateLine( cLine REF STRING, lInComment REF LOGIC )
// remove from the line all chars in comments
	LOCAL dwMax		AS	DWORD
	LOCAL nCpt		AS	DWORD
	LOCAL cChar		AS	STRING
	LOCAL lInString	:= FALSE AS	LOGIC
	LOCAL cPrev		AS	STRING
	LOCAL cTemp		AS	STRING
	//
	dwMax := SLen( cLine )
	//
	cChar := SubStr( cLine, 1, 1 )
	IF !lInComment
		cTemp := cChar
		IF Instr( cChar, e"\"'" )
			lInString := TRUE
		ENDIF
	ENDIF
	//
	FOR nCpt := 2 TO dwMax
		// Get a Char
		cPrev := cChar
		cChar := SubStr( cLine, nCpt, 1 )
		IF !lInComment
			//
			cTemp := cTemp + cChar
			// A String Marker ( Open/Close )
			IF Instr( cChar, e"\"'" )
				// We are starting a string, or closing a string
				lInString := !lInString
				LOOP
			ENDIF
		ENDIF
		IF !lInString
			IF ( cChar == "/" )
				//
				IF ( cPrev == "*" )
					// Previous was star: End Of Comment
					lInComment := FALSE
					LOOP
				ENDIF
			ELSEIF cChar == "*"
				// Start of Comment ?
				IF ( cPrev == "/" )
					lInComment := TRUE
					// Remove the Comment marker
					cTemp := SubStr( cTemp, 1, SLen( cTemp ) - 2 )
					LOOP
				ENDIF
			ENDIF						
		ENDIF
		//
	NEXT
	//
	cLine := cTemp


RETURN

FUNCTION FabExtractLine( sChaine AS STRING, wPos AS WORD ) AS STRING
//g String,String Manipulation
//l Extract a line from a string
//p Extract a line from a string
//x <sChaine> is the string to use as source\line
//x <wPos> is the number of the desired line to extract. ( The first line has number 1 )
//r The extracted line
/*
Extract a desired line from a string.
The first line is n°1.
*/
	LOCAL sRetVal	AS	STRING
	LOCAL wCurrent	as	DWORD
	LOCAL wCRLF		as	DWORD
	LOCAL wOffset	as	DWORD
	//
	sRetVal := NULL_STRING
	wOffset := 1
	wCurrent := 1
	//
	WHILE TRUE
		wCRLF := At3( CRLF, sChaine, wOffset - 1)
		IF ( wCRLF == 0 )  .or. ( wCurrent == wPos )
			EXIT
		ENDIF
		wOffset := wCRLF + 2
		wCurrent ++
	ENDDO
	//
	IF ( wCRLF == 0 )
		IF ( SLen( sChaine ) > 0 )  .and. ( wCurrent == wPos )
			sRetVal := SubStr( sChaine, wOffset )
		ENDIF
	ELSE
		sRetVal := SubStr( sChaine, wOffset, wCRLF - wOffset )
	ENDIF
RETURN sRetVal





FUNCTION FabForceCase( cSearchIn AS STRING, cSearchFor AS STRING ) AS STRING
//g String,String Manipulation
//l Search and replace characters within a string.
//p Search and replace characters within a string.
//a <cSearchIn> 	The string to search in.
//a <cSearchFor> 	The string to search for.
//d FabForceCase() search in the <cSearchIn> string for the <cSearchFor> string. The search
//d  is case insensitive. When the SubString is found, it's replaced by the <cSearchFor>, and
//d  so one, until the end of the <cSearchIn> string.
//r The New string
//e // Replace all "Search" by the specified form
//e FabForceCase( "Search of the csearchfor string in the csearchin...searching...", "SEARCH" )
//e // will result
//e "SEARCH of the cSEARCHfor string in the cSEARCHin...SEARCHing..."
	LOCAL dwLen		AS	DWORD
	LOCAL cDest		AS	STRING
	LOCAL cChar		AS	STRING
	LOCAL dwSize	AS	DWORD
	LOCAL dwMax		AS	DWORD
	LOCAL wCpt		AS	DWORD
	//
	dwLen := SLen( cSearchIn )
	dwMax := SLen( cSearchFor )
	cChar := ""
	cDest := ""
	//
	FOR wCpt := 1 TO dwLen
		// Add a Char to buffer
		cChar := cChar + SubStr( cSearchIn, wCpt, 1 )
		dwSize := SLen( cChar )
		// Current buffer doesn't appear in cSearchFor
		IF ( Upper( cChar ) != Upper( SubStr( cSearchFor, 1, dwSize ) ) )
			// Copy buffer into destination
			cDest := cDest + cChar
			// Empty Buffer
			cChar := ""
		ELSE
			IF ( dwSize == dwMax )
				// If we are here, chars are the same, and size is equal to what we are searching for
				// So, put the cSearchFor text in destination, and empty buffer
				cDest := cDest + cSearchFor
				cChar := ""
			ENDIF
		ENDIF
	NEXT
	// Special Case
	IF ( SLen( cChar ) != 0 )
		// We still have chars in Buffer
		cDest := cDest + cChar
	ENDIF
	//
RETURN cDest




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
	LOCAL ptrSrc	AS	PTR
	LOCAL sString	AS	STRING
	LOCAL aString	AS	ARRAY
	//
 	ptrSrc := pszMem
 	aString := {}
 	//
	DO WHILE TRUE
		//
		sString := FabGetStringInPsz( ptrSrc )
		IF ( SLen( sString ) == 0 )
			// Out
			EXIT
		ENDIF
		AAdd( aString,  sString )
		//
		ptrSrc := FabAdd2Ptr( ptrSrc, SLen( sString ) + 1 )
		//
	ENDDO
RETURN aString




FUNCTION FabGetStringInPsz( pszMem AS PTR ) AS STRING
//g String,String Manipulation
//l Retrieve a string stored in a Psz without it's size.
//p Retrieve a string stored in a Psz without it's size.
//x <pszMem> is a pointer to a memory filled with a psz string.
//r A String with the read bytes.
//d FabGetStringInPsz() will read each byte found starting at <pszMem>, copy each one to a string, stopping at the first zero byte encountered.\line
//d \b !!! Warning !!: You must have a null char in the buffer to end the conversion \b0
/*
 Return the first string that the Psz Pointer is pointing

!!! Warning !!: You must have a null char in the buffer to end the conversion
*/
	LOCAL sRet 		AS	STRING
	LOCAL bPtrSrc	AS	BYTE PTR
	//
	sRet := ""
	bPtrSrc  := PTR( BYTE, pszMem )
	//
	WHILE ( BYTE( bPtrSrc ) != 0 )
		// Copy Byte
		sRet := sRet + CHR( BYTE( bPtrSrc ) )
		// Move Pointer
		bPtrSrc ++
		//
	ENDDO
	//
RETURN sRet




FUNCTION FabGetToken( sString := "" AS STRING, nToken := 1 AS DWORD, cSep := " " AS STRING  ) AS STRING PASCAL
//g String,String Manipulation
//l Extract a Token.
//d Retrieve a Token in a delimited string, using a separator. \line
//d The separator can be a string with more than one char. If so, the full string is used as a separator.
//x <cString> is the Source\line
//x <nToken> is the number of the token to retrieve. ( Default is 1 )\line
//x <cSep> is a String with the separator. ( Default is " " )\line
//e	FabGetToken( "Hello Visual Object World !", 2, " " )	--> "Visual"
/*
Retrieve a Token in a delimited string, using a separator.
	FabGetToken( "Hello Visual Object World !", 2, " " )
	--> "Visual"
	
	The separator is a string( One or More )

*/
	LOCAL wPos		AS	DWORD
	LOCAL sVal		AS	STRING
	LOCAL nCount	AS	DWORD
	//
	sVal := ""
	nCount := 1
	//
	//
	IF ( SLen( sString ) > 0 )
		WHILE	.T.
			wPos := At2( cSep, sString )
			//
			IF ( wPos > 0 )
				// Get Token
				sVal := SubStr3( sString, 1, wPos - 1 )
				// Extract String
				sString := SubStr2( sString, wPos + SLen( cSep ) )
				//
				WHILE ( SubStr( sString, 1, SLen( cSep ) ) == cSep )
					// Move Next
					sString := SubStr2( sString, SLen( cSep )+1 )
				ENDDO
				// Search for next Token
				nCount ++
				IF ( nCount > nToken )
					EXIT
				ENDIF
			ELSE
				IF ( nCount >= nToken )
					sVal := sString
				ELSE
					sVal := ""
				ENDIF
				// Bye
				EXIT
			ENDIF
		ENDDO
	ENDIF
RETURN sVal





FUNCTION FabGetToken2( cString AS STRING, nToken := 1 AS DWORD, cSep := " " AS STRING  ) AS STRING
//l Extract a Token. (Typed Param )
//g String,String Manipulation
//d Retrieve a Token in a delimited string, using a char as separator. \line
//d The separator can be a list of Char, each ONE is a separator
//x <cString> is the Source\line
//x <nToken> is the number of the token to retrieve. ( Default is 1 )\line
//x <cSep> is a String with separators. ( Default is " " )\line
//e	FabGetToken2( "Hello,Visual;Object:World !", 2, " ,;:" )	--> "Visual"
/*
Retrieve a Token in a delimited string, using a separator.
	FabGetToken2( "Hello,Visual;Object:World !", 2, " ,;:" )
	--> "Visual"
	
	The separator can be a list of Char, each ONE is a separator
	If you need to specify a group of chars as separator, use FabGetToken()
*/
	LOCAL wPos		AS	DWORD
	LOCAL cToken	AS	STRING
	LOCAL nCount	AS	DWORD
	LOCAL cChar		AS	STRING
	// Token String
	cToken := ""
	// Current Token
	nCount := 0
	//
	IF ( SLen( cString ) > 0 )		
		FOR wPos := 1 TO SLen( cString )
			// Get a Char
			cChar := SubStr( cString, wPos, 1 )
			// Searching for a separator
			IF ( cChar $ cSep )
				IF ( SLen( cToken ) != 0 )					
					// We have found the Token # nCount++
					nCount ++
					// Is That the Token we are searching ?
					IF ( nCount == nToken )
						//
						EXIT
					ELSE
						// Move to the next
						cToken := ""
					ENDIF
				ENDIF
			ELSE
				cToken := cToken + cChar
			ENDIF
		NEXT
		// Have we found the Token ?
		IF ( nCount != nToken )
			cToken := ""
		ENDIF
		//
	ENDIF
	//
RETURN cToken




FUNCTION FabGetToken3( cString AS STRING, nToken := 1 AS DWORD, cSep := " " AS STRING, nIgnoreFirst := 0 AS DWORD  ) AS STRING
//g String,String Manipulation
//l Extract a Token. (Typed Param )
//d Retrieve a Token in a delimited string, using a char as separator starting at a specified position.. \line
//d The separator can be a list of Char, each ONE is a separator
//x <cString> is the Source\line
//x <nToken> is the number of the token to retrieve. ( Default is 1 )\line
//x <cSep> is a String with separators. ( Default is " " )\line
//x <nIgnoreFirst> is a number indicating how many tokens must be ignored before to start the extraction. ( Default is 0 )
//e The nIgnoreFirst is used to get the Token just before the new searched\line
//e ( i.e., here nIgnoreFirst == 2, so Ignore the first 2 ones, then get the second following ) \line
//e	FabGetToken3( "Hello,Visual;Object:World !", 2, " ,;:", 2 )	--> "World"
	//
RETURN FabGetToken2( cString, nIgnoreFirst + nToken, cSep )




FUNCTION FabIntToHex( uInt AS DWORD, wSize AS WORD ) AS STRING
//g String,String Manipulation
//l Convert a Integer to a Hex-string
//p Convert a Integer to a Hex-string, with a desired size
//x <uInt> is a numeric value to convert\line
//x <wSize> is the number of digit to retrieve\line
//r A string with the numeric value in Hexadecimal format.
//e FabIntToHex( 10, 4 )		-->	000A
	LOCAL sRet AS	STRING
	//
	sRet := Right( AsHexString( uInt ), wSize )
RETURN sRet




FUNCTION FabLoadStr( Ident AS DWORD ) AS STRING
//g String,String Manipulation
//l Load a string resource
//p Load a string resource
//a <Ident> is a numeric value indicating the ID of the string to load
//d This function will use the LoadString() function to load and allocate a string value.
//r A VO String
//s
	LOCAL pszStr	AS	PTR
	LOCAL nRead		AS	LONG
	LOCAL cResult	AS	STRING
	//
	pszStr := MemAlloc( 1024 )
	//
	nRead := LoadString( _GetInst(), Ident, pszStr, 1024 )
	//
	IF ( nRead > 0 )
		cResult := Mem2String( pszStr, dword(nRead) )
	ENDIF
	MemFree( pszStr )
	//
RETURN cResult




FUNCTION FabLTrim( c AS STRING ) AS STRING
	LOCAL nCpt	AS	DWORD
	// First, remove spaces
	c := LTrim( c )
	//
	nCpt := 1
	WHILE ( CharPos( c, nCpt ) == CHR( 09 ) )
		//
		c := Stuff( c, nCpt, 1, CHR(32) )
		//
		nCpt++
	ENDDO
	// Now remove converted tabs
	c := LTrim( c )
RETURN c	




PROCEDURE FabMemCopyString( ptrDest AS PTR, cSource AS STRING )
//g String,String Manipulation
//l Copy a string to a static Memory
//p Copy a string to a static Memory
//x <ptrDest> is a pointer to the destination memory\line
//x <cSource> is the string to copy\line
//d FabMemcopyString() will copy the full string to the destination memory,
//d  so you must be sure that the buffer is large enough to receive the full source.
	//
     MemCopyString( ptrDest, cSource, SLen( cSource ) )


RETURN

FUNCTION	FabPszCopy( ptrDest AS PTR, ptrSrc AS PTR )	AS	PTR
//g String,String Manipulation
//l Copy a Psz Memory to another one
//p Copy a Psz Memory to another one
//x <ptrDest> is a pointer to the destination memory\line
//x <ptrSrc> is a pointer to the source memory\line
//d FabPszCopy() will copy each byte from the source to the destination, stopping at the first zero byte encountered.\line
//d \b !!! Warning !!! The destination memory must be large enough to store the source. \b0
//r A pointer to the destination memory.

/*
Copy a Psz-Memory to another memory
!!! Warning !!!
The ptrDest must be large enough to store the source...

*/
	LOCAL bPtrDest	AS	BYTE PTR
	LOCAL bPtrSrc	AS	BYTE PTR
	//
	bPtrDest := PTR( BYTE, ptrDest )
	bPtrSrc  := PTR( BYTE, ptrSrc )
	//
	WHILE ( BYTE( bPtrSrc ) != 0 )
		// Copy Byte
		BYTE( bPtrDest ) := BYTE( bPtrSrc )
		// Move Pointers
		bPtrDest ++
		bPtrSrc ++
		//
	ENDDO
	// Copy End of String Marker
	BYTE( bPtrDest ) := BYTE( bPtrSrc )
	//
RETURN	ptrDest




FUNCTION FabRTrim( c AS STRING ) AS STRING
	LOCAL nCpt	AS	DWORD
	// First, remove spaces
	c := RTrim( c )
	//
	nCpt := SLen( c )
	WHILE ( CharPos( c, nCpt ) == CHR( 09 ) )
		//
		c := Stuff( c, nCpt, 1, CHR(32) )
		//
		nCpt--
	ENDDO
	// Now remove converted tabs
	c := RTrim( c )
RETURN c	




FUNCTION FabString2Array( cString AS STRING , cSep := "," AS STRING ) AS ARRAY
//g String,String Manipulation
//l Convert a delimited string to an array, using a separator.
//p Convert a delimited string to an array, using a separator.
//d The Separator can be one or more character long.
//x <cString> is astring with data to retrieve. \line
//x <cSep> is a string with the separator to use. ( Default separator is a comma )
//e FabString2Array( "One,Two,,Four", "," )
//e // Will return ( "One", "Two","", "Four" )
	LOCAL aRetVal		AS	ARRAY
	LOCAL wPos			as	DWORD
	LOCAL cVal			AS	STRING
	LOCAL nSepLen		as	DWORD
	//
	nSepLen := SLen( cSep )
	aRetVal := {}
	//
	IF ( SLen( cString ) > 0 )		
		WHILE	.T.
			wPos := At2( cSep, cString )
			IF ( wPos > 0 )
				cVal := SubStr3( cString, 1, wPos - 1 )
				cString := SubStr2( cString, wPos + nSepLen )
				AAdd( aRetVal, cVal )
			ELSE
				IF !Empty( cString )
					AAdd( aRetVal, cString )
				ENDIF
				EXIT
			ENDIF
		ENDDO
	ENDIF
RETURN aRetVal




FUNCTION FabString2Array2( cString , cSep  ) AS ARRAY
//g String,String Manipulation
//l Convert a delimited string to an array.
//p Convert a delimited string to an array, using a separator.
//d Same as FabString2Array() except that if a separator is followed by another one, wait for another char to create a new array entry.
//d  The Separator can be one or more character long.
//x <cString> is astring with data to retrieve. \line
//x <cSep> is a string with the separator to use. ( Default separator is space )

//e FabString2Array2( "One,Two,,Four", "," )
//e // Will return ( "One", "Two","Four" )
	LOCAL aRetVal		AS	ARRAY
	LOCAL wPos			as	DWORD
	LOCAL cVal			AS	STRING
	LOCAL nSepLen		as	DWORD
	//
	Default( @cSep, " " )
	nSepLen := SLen( cSep )
	aRetVal := {}
	//
	IF ( SLen( cString ) > 0 )		
		WHILE	.T.
			wPos := At2( cSep, cString )
			IF ( wPos > 0 )
				cVal := SubStr3( cString, 1, wPos - 1 )
				cString := SubStr2( cString, wPos + nSepLen )
				IF ( Left( cString, nSepLen ) != cSep )
					AAdd( aRetVal, cVal )
				ENDIF
			ELSE
				IF !Empty( cString )
					AAdd( aRetVal, cString )
				ENDIF
				EXIT
			ENDIF
		ENDDO
	ENDIF
RETURN aRetVal




FUNCTION FabTrim( c AS STRING ) AS STRING
RETURN FabRTrim( c )





