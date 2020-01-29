/*
TEXTBLOCK	!Read-Me
/-*
	You will find four classes in this module to provide easy-access to INI files or Registry.

FabConfigFile is the base class that provide two methods :
	GetValue() and WriteValue() that call GetString() and WriteString() ( Here deferred )

FabIniFile
	Provide access to standard INI File
	Ini with the fullpath of the Ini file ( \Windows\ per default )

FabWinIniFile
	Provide acces to WIN.INI
	Init with ()

FabRegistry
	Provide access to the Ws95/NT registry in the same way as the INI files
	Init with the desired key like "SOFTWARE\ComputerAssociates\CA-Visual Objects Applications\"
	

DeleteEntry( cEntry )
	Delete one entry
	
DeleteSection( cSection )
	Delete the full section
	
GetEntries( cSection )
	Get an array of Entries Name in the section
	
GetInt( cSection, cEntry <, nDefault > )
	Get an Int in the desired Section,Entry with nDefault per default ( 0 )
	
GetSection( cSection )
	Get an Array with 	{ Name, Value }			// For Ini Files
						{ Name, Value, Type }	// For Registry keys
GetSections( )
	Get an array with all Sections Name in the IniFile
						
GetString( cSection, cEntry <,sDefault> )
	Get a string in the desired Section,Entry with sDefault per default ( " " )
	
GetStringUpper( cSection, cEntry <,sDefault> )
	Get an Upper string in the desired Section,Entry with sDefault per default ( " " )

GetValue( cSection, cEntry, <uDefault>, <uType> )
	Get a usual value from the Section, Entry.
	If uType is not provided, the UsualType() of uDefault is used to determine the desired type
		GetValue( "Test", "Entry", , DATE ) --> return a Date Value

WriteInt( cSection, cEntry, nValue )
	Write the nValue in the Section,Entry
	
WriteString( cSection, cEntry, sValue )
	Write the sValue in the Section,Entry

WriteValue( cSection, cEntry, uValue )
	Write the uValue in the Section,Entry
	
*-/




*/
/*
textblock	!Read-Me - 2
/-*
Added a ReadOnly Access/Assign so you should be able to use the class with standard user rights
*-/

*/
#region DEFINES
STATIC DEFINE FAB_MAXSTRING := 2048
#endregion

CLASS FabRegistry	INHERIT	FabConfigFile
//l Registry access class
//g Configuration,Configuration Classes
//p A class designed to access/modify the System registry.
//d This class can be used to work on the system registry. It handles the registry in the same way as INI Files.\line
//d In a KEY, you can have multiples \b Section\b0, and in each one, you can have \b Entries\b0.\line
//d In an Entry, you can store any type of value. ( String, Numeric, ... )
	//
	PROTECT sSubKey     AS STRING
	//
	PROTECT sClass		AS STRING
	//
	PROTECT liLastError AS LONG
	//
	PROTECT hKey 		AS PTR
	//
	PROTECT m_ReadOnly AS LOGIC


	DECLARE	ACCESS KeyInfo					//AS FabRegKeyInfo

//Protected
	DECLARE	METHOD _CloseKey				//( hKey AS PTR ) AS LONG
	DECLARE	METHOD _CopyValues				//( SrcKey AS PTR, DestKey AS PTR )
	DECLARE	METHOD _CreateKey				//( cSection AS STRING ) AS PTR
	DECLARE	METHOD _ExportEntryToString		//( cSection AS STRING, cEntry AS STRING )
	DECLARE	METHOD _ExportSectionToFile		//( cSection AS STRING, oFile AS FabFileBin )
	DECLARE	METHOD _GetKeyInfo				//( hKey AS PTR ) AS FabRegKeyInfo
	DECLARE	METHOD _OpenKey					//( cSection AS STRING ) AS PTR 
	
	
	
	



	PROTECT METHOD _CloseKey( hkResult AS PTR ) AS LONG PASCAL 
	//
		RETURN	RegCloseKey( hkResult )




	PROTECT METHOD _CopyValues( SrcKey AS PTR, DestKey AS PTR ) PASCAL 
	// Copy values from Source to Dest open reg keys.
		


		RETURN SELF

	PROTECT METHOD _CreateKey( cSection AS STRING ) AS PTR PASCAL 
		LOCAL sKeySection		AS STRING
		LOCAL phkResult			AS PTR
		LOCAL lpdwDisposition	AS DWORD
	//
		sKeySection := SELF:BuildSubKey( cSection )
	//
		SELF:liLastError := RegCreateKeyEx( SELF:hKey,              ;
		String2Psz( sKeySection ),          ;
		0,                                  ;
		String2Psz( SELF:sClass ),          ;
		REG_OPTION_NON_VOLATILE,            ;
		SELF:Key_All_Access, 				   ;
		0,                                  ;
		@phkResult,                         ;
		@lpdwDisposition )

	//
		RETURN phkResult




	PROTECT METHOD _ExportEntryToString( cSection AS STRING, cEntry AS STRING ) 
		LOCAL cResult	AS	STRING
		LOCAL ptrData	AS	BYTE PTR
		LOCAL dwType	AS	DWORD
		LOCAL dwSize	AS	DWORD
		LOCAL wCpt		AS	DWORD
		LOCAL bByte		AS	BYTE
		LOCAL cTemp		AS	STRING
	// First, Get DataType
		dwType := SELF:GetDataType( cSection, cEntry )
	//
		IF ( SELF:LastError == ERROR_SUCCESS )
		// Get Size
			dwSize := SELF:GetDataSize( cSection, cEntry )
		// Get Data
			ptrData := MemAlloc( dwSize )
			SELF:GetData( cSection, cEntry, ptrData, dwSize )
		//
			IF Empty( cEntry )
				cEntry := "@"
			ELSE
				cEntry := StrTran( cEntry, '"', '\"' )
				cEntry := '"'+ cEntry + '"'
			ENDIF
 		//
			IF ( dwType != REG_SZ )  .AND.	;
			( dwType != REG_DWORD )
			// Complex Type
			// Build Entry String
				IF ( dwType != REG_BINARY )
					cResult := cEntry + "=hex(" + NTrim( dwType ) + "):"
				ELSE
					cResult := cEntry + "=hex:"
				ENDIF
			// Add Data Bytes
				FOR wCpt := 1 UPTO dwSize
				//
					bByte := ptrData[ wCpt ]
					cResult := cResult + FabIntToHex( bByte, 2 )
				//
					IF ( wCpt != dwSize )
						cResult := cResult + ","
					ENDIF
				NEXT
			ELSE
			// Basic Type
				IF ( dwType == REG_SZ )
				// Build Entry String
					cResult := cEntry + "="
				// Add Data Chars
					IF ( dwSize > 0 )
						dwSize := dwSize - 1
					ENDIF
				//
					cTemp := Mem2String( ptrData, dwSize )
					cTemp := StrTran( cTemp, "\", "\\" )
					cTemp := StrTran( cTemp, '"', '\"' )
					cTemp := '"' + cTemp + '"'
					cResult := cResult + cTemp
				ELSE
				// Build Entry String
					cResult := cEntry + "=dword:"
				// Add Data Bytes
					cResult := cResult + AsHexString( PTR( PTR( DWORD, ptrData ) ) )
				ENDIF
			ENDIF
		// Free Buffer
			MemFree( ptrData )
		ENDIF
	//
		RETURN cResult




	PROTECT METHOD _ExportSectionToFile( cSection AS STRING, oFile AS FabFileBin ) 
		LOCAL cKey		AS	STRING
		LOCAL cValue	AS	STRING
		LOCAL aEntries	AS	ARRAY
		LOCAL wCpt		AS	DWORD
	//
		cKey := "[" + SELF:UseKeyString + "\" + SELF:BuildSubKey( cSection ) + "]"
		aEntries := SELF:GetEntries( cSection )
	//
		IF oFile:IsOpen
		//
			oFile:WriteLine( cKey )
		//
			FOR wCpt := 1 TO ALen( aEntries )
				cValue := SELF:_ExportEntryToString( cSection, aEntries[ wCpt ] )
				oFile:WriteLine( cValue )
			NEXT
			oFile:WriteLine( "" )
		ENDIF



		RETURN SELF

	PROTECT METHOD _GetKeyInfo( hKey AS PTR ) AS FabRegKeyInfo PASCAL 
		LOCAL oKeyInfo		:= NULL_OBJECT AS	FabRegKeyInfo
		LOCAL NumSubKeys	AS	DWORD
		LOCAL MaxSubKeyLen	AS	DWORD
		LOCAL NumValues		AS	DWORD
		LOCAL MaxValueLen	AS	DWORD
		LOCAL MaxDataLen	AS	DWORD
		LOCAL lwFileTime	IS	_winFileTime
	//
		SELF:liLastError := RegQueryInfoKey( hKey, NULL_PTR, NULL_PTR, NULL_PTR,	;
		@NumSubKeys,	;
		@MaxSubKeyLen, 	;
		NULL_PTR, 		;
		@NumValues, 	;
		@MaxValueLen,	;
		@MaxDataLen,	;
		NULL_PTR, 		;
		@lwFileTime)
	//
		IF ( SELF:LastError == ERROR_SUCCESS )
		//
			oKeyInfo := FabRegKeyInfo{ NumSubKeys, MaxSubKeyLen, NumValues, MaxValueLen, MaxDataLen, @lwFileTime }
		ENDIF
	//
		RETURN oKeyInfo




	PROTECT METHOD _OpenKey( cSection AS STRING ) AS PTR PASCAL 
		LOCAL sKeySection	AS STRING
		LOCAL phkResult		AS PTR
	//
		sKeySection := SELF:BuildSubKey( cSection )
	//
		SELF:liLastError := RegOpenKeyEx( SELF:hKey,    ;
		String2Psz( sKeySection ), ;
		0,                      ;
		SELF:Key_Access,        ;
		@phkResult )
	//
		RETURN phkResult




	PROTECT METHOD BuildSubKey( cSection ) 
		LOCAL sRet	AS STRING
	//
		IF Empty( cSection )
			sRet := SELF:sSubKey
		ELSE
			sRet := SELF:sSubKey + "\" + cSection
		ENDIF
		RETURN sRet




	METHOD CloneSelf( ) 
//p Create a clone of the current object, initialized with the same property values
//r A new FabRegistry object
		LOCAL oReg	AS	FabRegistry
	// Create an empty FabRegistry Object
		oReg := FabRegistry{ }
	// Point to the same hKey
		oReg:UseKey := SELF:UseKey
	// Point to the same SubKey
		oReg:SubKey := SELF:SubKey
	// Set the same Class if Any
		oReg:Type := SELF:Type
	//
		RETURN oReg




	METHOD CopyEntries( SrcSection, DestSection ) 
//p Copy all entries from one section to another.
//d CopyEntries() will copy all entries from one section to another whatever types they are.
//a <SrcSection> is a string indicating the root of registry tree to copy.\line
//a \tab If Empty, the root starts at the SubKey property.\line
//a <DestSection> indicate the destination.\line
//a \tab If String, this indicate the destination SubKey, using the same HKEY ( UseKey Property ),
//a  starting at the SubKey property.\line
//a \tab If you want a destination in another HKEY, or with another Root, you can pass a FabRegistry object.\line
//r A logical value indicating the success of the operation.
		LOCAL lSuccess 	AS 	LOGIC
		LOCAL aEntries	AS	ARRAY
		LOCAL wCpt		AS	DWORD
		LOCAL oDest		AS	FabRegistry
		LOCAL cTemp		AS	STRING
	//
		DEFAULT( @SrcSection, "" )
		DEFAULT( @DestSection, "" )
		lSuccess := FALSE
	//
		IF IsString( DestSection )
		// Make a copy of the current FabRegistry object
		// And set the DestSection as SubKey
			oDest := SELF:CreateSubKeyObject( DestSection )
		ELSE
			oDest := DestSection
		ENDIF
	// The full path to the Source SubKey
		cTemp := SELF:BuildSubKey( SrcSection )
	//
		IF ( cTemp != oDest:SubKey )
 		// Does the Source key exist ?
			IF SELF:KeyExist( SrcSection )
			// Read all Entries Name in the source section
				aEntries := SELF:GetEntries( SrcSection )
				lSuccess := TRUE
			// For each entry
				FOR wCpt := 1 TO ALen( aEntries )
				// Copy this one
					lSuccess := SELF:CopyEntry( SrcSection, oDest, aEntries[ wCpt ] )
					IF !lSuccess
					// Error !
						EXIT
					ENDIF
				NEXT
			ENDIF
		ENDIF
	//
		RETURN lSuccess





	METHOD CopyEntry( SrcSection, DestSection, cEntry ) 
//p Copy one Entry value from one section to another.
//d CopyEntry() will copy one entry entries from one section to another whatever types it is.
//a <SrcSection> is a string indicating the root of registry tree to copy.\line
//a \tab If Empty, the root starts at the SubKey property.\line
//a <DestSection> indicate the destination.\line
//a \tab If String, this indicate the destination SubKey, using the same HKEY ( UseKey Property ),
//a  starting at the SubKey property.\line
//a \tab If you want a destination in another HKEY, or with another Root, you can pass a FabRegistry object.\line
//a <cEntry> is a string, indicating the Entry to copy. If Empty, this will copy the default value for the Source Key.
//r A logical value indicating the success of the operation.
		LOCAL lSuccess 	AS 	LOGIC
		LOCAL dwLen		AS	DWORD
		LOCAL dwType	AS	DWORD
		LOCAL ptrData	AS	PTR
		LOCAL oDest		AS	FabRegistry
		LOCAL cTemp		AS	STRING
	//
		DEFAULT( @SrcSection, "" )
		DEFAULT( @DestSection, "" )
		DEFAULT( @cEntry, "" )
		lSuccess := FALSE
	//
		IF IsString( DestSection )
		// Make a copy of the current FabRegistry object
		// And set the DestSection as SubKey
			oDest := SELF:CreateSubKeyObject( DestSection )
		ELSE
			oDest := DestSection
		ENDIF
	// The full path to the Source SubKey
		cTemp := SELF:BuildSubKey( SrcSection )
	//
		IF ( cTemp != oDest:SubKey )
		// Save the Registry type of the data
			dwType := SELF:GetDataType( SrcSection, cEntry )
		// May be the Entry doesn't exist ?
			IF ( SELF:LastError == ERROR_SUCCESS )
			// Read the needed size
				dwLen := SELF:GetDataSize( SrcSection, cEntry )
			// Alocate enough room to store the data
				ptrData := MemAlloc( dwLen )
			// Read the data
				SELF:GetData( SrcSection, cEntry, ptrData, dwLen )
			// Now, try to put the data to the destination
				oDest:PutData( "", cEntry, ptrData, dwLen, dwType )
			// Free memory
				MemFree( ptrData )
			//
				lSuccess := TRUE
			ENDIF
		ENDIF
	//
		RETURN lSuccess




	METHOD CopySection( SrcSection, DestSection ) 
//p Copy all value/sections from one section to another
//d CopySection() will copy all entries & sections from one section to another whatever types they are, including entries stored
//d  under the source section.
//a <SrcSection> is a string indicating the root of registry tree to copy.\line
//a \tab If Empty, the root starts at the SubKey property.\line
//a <DestSection> indicate the destination.\line
//a \tab If String, this indicate the destination SubKey, using the same HKEY ( UseKey Property ),
//a  starting at the SubKey property.\line
//a \tab If you want a destination in another HKEY, or with another Root, you can pass a FabRegistry object.\line
//r A logical value indicating the success of the operation.

		LOCAL lSuccess 	AS 	LOGIC
		LOCAL aSections	AS	ARRAY
		LOCAL wCpt		AS	DWORD
		LOCAL oDest		AS	FabRegistry
		LOCAL oDest2	AS	FabRegistry
		LOCAL cTemp		AS	STRING
	//
		DEFAULT( @SrcSection, "" )
		DEFAULT( @DestSection, "" )
		lSuccess := FALSE	
	//
		IF IsString( DestSection )
		// Make a copy of the current FabRegistry object
		// And set the DestSection as SubKey
			oDest := SELF:CreateSubKeyObject( DestSection )
		ELSE
			oDest := DestSection
		ENDIF
	// The full path to the Source SubKey
		cTemp := SELF:BuildSubKey( SrcSection )
	//
		IF ( cTemp != oDest:SubKey )
 		// Does the Source key exist ?
			IF SELF:KeyExist( SrcSection )
 			// First copy all values in the source section
				SELF:CopyEntries( SrcSection, oDest )
			// Read all Sections Name in the source section
				aSections := SELF:GetSections( SrcSection )
				lSuccess := TRUE
			// For each Section
				FOR wCpt := 1 TO ALen( aSections )
				//
					oDest2 := oDest:CloneSelf()
					oDest2:MoveDownTo( aSections[ wCpt ] )
				// Copy all Values in this one
					lSuccess := SELF:CopyEntries( FabConcatDir( SrcSection, aSections[ wCpt ] ), oDest2 )
					IF !lSuccess
					// Error !
						EXIT
					ENDIF
				// Now try to copy any existing SubKeys				
					lSuccess := SELF:CopySections( FabConcatDir( SrcSection, aSections[ wCpt ] ), oDest2 )
					IF !lSuccess
					// Error !
						EXIT
					ENDIF
				NEXT
			ENDIF
		ENDIF
	//
		RETURN lSuccess




	METHOD CopySections( SrcSection, DestSection ) 
//p Copy Sub-sections and their Values from one section to another
//d CopySections() will copy all entries & sections from one section to another whatever types they are, without including entries stored
//d  under the source section. This will only copy Sub Sections and their values.
//a <SrcSection> is a string indicating the root of registry tree to copy.\line
//a \tab If Empty, the root starts at the SubKey property.\line
//a <DestSection> indicate the destination.\line
//a \tab If String, this indicate the destination SubKey, using the same HKEY ( UseKey Property ),
//a  starting at the SubKey property.\line
//a \tab If you want a destination in another HKEY, or with another Root, you can pass a FabRegistry object.\line
//r A logical value indicating the success of the operation.
		LOCAL lSuccess 	AS 	LOGIC
		LOCAL aSections	AS	ARRAY
		LOCAL wCpt		AS	DWORD
		LOCAL oDest		AS	FabRegistry
		LOCAL oDest2	AS	FabRegistry
		LOCAL cTemp		AS	STRING
	//
		DEFAULT( @SrcSection, "" )
		DEFAULT( @DestSection, "" )
		lSuccess := FALSE
	//
		IF IsString( DestSection )
		// Make a copy of the current FabRegistry object
		// And set the DestSection as SubKey
			oDest := SELF:CreateSubKeyObject( DestSection )
		ELSE
			oDest := DestSection
		ENDIF
	// The full path to the Source SubKey
		cTemp := SELF:BuildSubKey( SrcSection )
	//
		IF ( cTemp != oDest:SubKey )
 		// Does the Source key exist ?
			IF SELF:KeyExist( SrcSection )
			// Read all Sections Name in the source section
				aSections := SELF:GetSections( SrcSection )
				lSuccess := TRUE
			// For each Section
				FOR wCpt := 1 TO ALen( aSections )
				//
					oDest2 := oDest:CloneSelf()
					oDest2:MoveDownTo( aSections[ wCpt ] )
				// Copy all Values in this one
					lSuccess := SELF:CopyEntries( FabConcatDir( SrcSection, aSections[ wCpt ] ), oDest2 )
					IF !lSuccess
					// Error !
						EXIT
					ENDIF
				// Now try to copy any existing SubKeys				
					lSuccess := SELF:CopySections( FabConcatDir( SrcSection, aSections[ wCpt ] ), oDest2 )
					IF !lSuccess
					// Error !
						EXIT
					ENDIF
				NEXT
			ENDIF
		ENDIF
	//
		RETURN lSuccess






	METHOD CreateSubKeyObject( cSubKey ) 
		LOCAL oReg	AS	FabRegistry
	// Create an empty FabRegistry Object
		oReg := SELF:CloneSelf()
	// Point to the same SubKey added with the desired SubKey
		oReg:SubKey := SELF:BuildSubKey( cSubKey )
	//
		RETURN oReg




	METHOD DeleteEntries( cSection ) 
//p Delete all Entries in a specified section
//r A logical value indicating the success of the operation.
		LOCAL aName	AS ARRAY
		LOCAL wCount 	AS DWORD
		LOCAL wAlen  	AS DWORD
	//
		aName := { }
	// Retreive the name of all Entries in the section
		aName := SELF:GetEntries( cSection )
	//
		wAlen := ALen( aName )
		FOR wCount := 1 UPTO wAlen
		//
			SELF:DeleteEntry( cSection, aName[ wCount ] )
		NEXT wCount
	//
		RETURN ( SELF:LastError == ERROR_SUCCESS )




	METHOD DeleteEntry( cSection, cEntry ) 
//p Remove an Entry in Section
//r A logical value indicating the success of the operation.
		LOCAL phkResult 	AS PTR
	//
		DEFAULT( @cSection, "" )
		DEFAULT( @cEntry, "" )
	//
		phkResult := SELF:_OpenKey( cSection )
	//
		IF ( SELF:LastError == ERROR_SUCCESS )
		//
			SELF:liLastError := RegDeleteValue( phkResult, String2Psz( cEntry ) )
		//
			SELF:_CloseKey( phkResult )
		ENDIF
	//
		RETURN ( SELF:LastError == ERROR_SUCCESS )




	PROTECT METHOD DeleteOneSection( cSection ) 
	//
		cSection := SELF:BuildSubKey( cSection )
	//
		SELF:liLastError := RegDeleteKey( SELF:hKey, String2Psz( cSection ) )



		RETURN SELF

	METHOD DeleteSection( cSection ) 
//d Remove a Section and all it's associated entries and all its descendents.
//r Return a logical value indicating the succes of the operation
		LOCAL aSections	AS ARRAY
		LOCAL wCount 	AS WORD
	//
		DEFAULT( @cSection, "" )
	// Get SubSections
		aSections := SELF:GetSections( cSection )
	// Delete SubKeys
		FOR wCount := 1 TO ALen( aSections )
			SELF:DeleteSection( FabConcatDir( cSection, aSections[ wCount ] ) )
		NEXT
	// Delete the specified key
		SELF:DeleteOneSection( cSection )
	//
/*
	aName := { }
	// Retrieve the name of all Entries in the section
	aName := SELF:GetEntries( cSection )
	//
	wAlen := ALen( aName )
	FOR wCount := 1 UPTO wAlen
		//
		SELF:DeleteOneSection( IIf( Empty( cSection ), aName[ wCount ], cSection + "\" + aName[ wCount ] ) )
		//
		IF ( SELF:LastError == ERROR_ACCESS_DENIED )
			SELF:DeleteSection( IIf( Empty( cSection ), aName[ wCount ], cSection + "\" + aName[ wCount ] ) )
		ENDIF
	NEXT wCount
	//
	SELF:DeleteOneSection( cSection )
*/
	//
		RETURN ( SELF:LastError == ERROR_SUCCESS )




	METHOD EntryExist( cSection, cEntry ) 
//p Check if a particular Entry exist, in a particular Section
//r TRUE if the entry exist, FALSE unless.
		LOCAL phkResult		AS PTR
		LOCAL lExist		AS	LOGIC
	//
		DEFAULT( @cSection, "" )
		DEFAULT( @cEntry, "" )
	//
		lExist := FALSE
		phkResult := SELF:_OpenKey( cSection )
	//
		IF ( SELF:LastError == ERROR_SUCCESS )
		// Try to get the DataType
			SELF:GetDataType( cSection, cEntry )
		//
			IF ( SELF:LastError == ERROR_SUCCESS )
				lExist := TRUE
			ENDIF
			SELF:_CloseKey( phkResult )
		//
		ENDIF
		RETURN lExist




	METHOD ExportToFile( SrcSection, cFile ) 
//p Export a Key, it's SubKeys and values to a REG File
//d Export a Key, it's SubKeys and values to a REG File that can be imported using the RegEdit application.
//a <SrcSection> is a string indicating where the export starts.
//a <cFile> is a string/FileSpec indicating the FullPath of the file to create.
//l A Logical value indicating the success of the operation
//e // First, points to a key
//e oReg := FabRegistry{ "Software\FabriceForay" }
//e // We can save a particular SubKey
//e oReg:ExportToFile( "FabAutoDoc", "TestFile.Reg" )
//e // Or export all SubKeys under the root
//e oReg:ExportToFile( "", "TestFile2.Reg" )
//
		LOCAL oFile			AS	FabFileBin
		LOCAL lSuccess		AS	LOGIC
		LOCAL aSections		AS	ARRAY
		LOCAL wCpt			AS	DWORD
		LOCAL lNeedClose	:= FALSE AS	LOGIC
	//
		DEFAULT( @SrcSection, "" )
		lSuccess := FALSE
	//
		IF IsString( cFile )
			oFile := FabFileBin{ cFile }
		ELSEIF IsInstanceOf( cFile, #FileSpec )
			oFile := FabFileBin{ cFile }
		ELSE
			oFile := cFile
		ENDIF
	// Does the Source key exist ?
		IF SELF:KeyExist( SrcSection )
			IF !oFile:IsOpen
			// Create File
				oFile:Create()
			// Add Header
				oFile:WriteLine( "REGEDIT4" + CRLF )
 			//
				lNeedClose := TRUE
			ENDIF
			IF oFile:IsOpen
			// Export Entries in the current SubKey
				SELF:_ExportSectionToFile( SrcSection, oFile )
			// Read all Sections Name in the source section
				aSections := SELF:GetSections( SrcSection )
				lSuccess := TRUE
			// For each Section
				FOR wCpt := 1 TO ALen( aSections )
				//
					lSuccess := SELF:ExportToFile( FabConcatDir( SrcSection, aSections[ wCpt ] ), oFile )
				//
					IF !lSuccess
					// Error !
						EXIT
					ENDIF
				NEXT
			ELSE
				lSuccess := FALSE
			ENDIF
			IF lNeedClose
				oFile:Close()
			ENDIF
		ENDIF
	//
		RETURN lSuccess




	ACCESS	FileName	
//r Return the Full SubKey.
//d This Access return a value that you can handle as a FileName
	// For compatibility with IniFile
		RETURN	SELF:SubKey




	METHOD GetData( cSection, cEntry, ptrBuffer, dwBufferLen ) 
//p Retrieve Data in a particular SubKey, without regarding it's type.
//a <cSection> is the Section Name\line
//a <cEntry> is the Entry Name\line
//a <ptrBuffer> is a pointer to an already allocated memory.\line
//a \tab The buffer MUST be large enough to receive data.
//a <dwBufferLen> is a DWORD indicating the size of the buffer
//r The amount of data read.
		LOCAL phkResult			AS PTR
		LOCAL lpdwType			AS DWORD
		LOCAL lpdwDataLen		AS DWORD
	//
		DEFAULT( @cSection, "" )
		DEFAULT( @cEntry, "" )
		DEFAULT( @dwBufferLen, 0 )
	//
		phkResult := SELF:_OpenKey( cSection )
		lpdwDataLen := dwBufferLen
	//
		IF ( SELF:LastError == ERROR_SUCCESS )
		//
			lpdwType := REG_NONE
		//
			SELF:liLastError := RegQueryValueEx( phkResult, ;
			String2Psz( cEntry ),   ;
			0,                      ;
			@lpdwType,              ;
			PTR( _CAST,ptrBuffer ),		;
			@lpdwDataLen )
		//
			SELF:_CloseKey( phkResult )
		//
		ENDIF
	//
		RETURN lpdwDataLen





	METHOD GetDataSize( cSection, cEntry ) 
//p Get the size of the data stored in a particular SubKey
//a <cSection> is the Section Name\line
//a <cEntry> is the Entry Name\line
//r The size of the data in bytes.
		LOCAL phkResult			AS PTR
		LOCAL lpdwType			AS DWORD
		LOCAL lpdwDataLen		:= 0 AS DWORD
	//
		DEFAULT( @cSection, "" )
		DEFAULT( @cEntry, "" )
	//
		phkResult := SELF:_OpenKey( cSection )
	//
		IF ( SELF:LastError == ERROR_SUCCESS )
		//
			SELF:liLastError := RegQueryValueEx( phkResult, ;
			String2Psz( cEntry ),   ;
			0,                      ;
			@lpdwType,              ;
			NULL_PTR,                ;
			@lpdwDataLen )
		//
			SELF:_CloseKey( phkResult )
		//
		ENDIF
	//
		RETURN lpdwDataLen




	METHOD GetDataType( cSection, cEntry ) 
//p Get the type of the data stored in a particular key
//a <cSection> is the Section Name\line
//a <cEntry> is the Entry Name\line
//r A DWORD value, indicating the type of the data.\line
//r \tab it can be REG_BINARY, REG_DWORD, ...\line
//r \tab You can check the RegQueryValueEx() function in the Win32SDK.HLP File for more info.
		LOCAL phkResult			AS PTR
		LOCAL lpdwType			:= 0 AS DWORD
		LOCAL lpdwDataLen		AS DWORD
	//
		DEFAULT( @cSection, "" )
		DEFAULT( @cEntry, "" )
	//
		phkResult := SELF:_OpenKey( cSection )
	//
		IF ( SELF:LastError == ERROR_SUCCESS )
		//
			SELF:liLastError := RegQueryValueEx( phkResult, ;
			String2Psz( cEntry ),   ;
			0,                      ;
			@lpdwType,              ;
			NULL_PTR,                ;
			@lpdwDataLen )
		//
			SELF:_CloseKey( phkResult )
		//
		//
		ENDIF
	//
		RETURN lpdwType




	METHOD GetEntries( cSection ) 
//d Retrieve all Entries in the specified Section.
//r An Array filled with the names of all entries in the section.
		LOCAL liError		AS LONG
		LOCAL dwIndex 		AS DWORD
		LOCAL dwNameLen		AS DWORD
		LOCAL phkResult		AS PTR
		LOCAL pszName		AS PSZ
		LOCAL aName			AS ARRAY
		LOCAL oKeyInfo		AS FabRegKeyInfo
	//
		DEFAULT( @cSection, "" )
	//
		aName := { }
		dwIndex := 0
		liError := 0
	//
		phkResult := SELF:_OpenKey( cSection )
	//
		IF ( SELF:LastError == ERROR_SUCCESS  )
		// Get Informations about the desired Key
			oKeyInfo := SELF:_GetKeyInfo( phkResult )
		//
			pszName   := MemAlloc( oKeyInfo:MaxValueNameLen + 1 )
		//
			IF ( oKeyInfo:Values > 0 )
				FOR dwIndex := 0 UPTO ( oKeyInfo:Values - 1 )
				//
					dwNameLen := oKeyInfo:MaxValueNameLen + 1
				//
					liError := RegEnumValue( phkResult, ;
					dwIndex, 			;	
					pszName,        	;
					@dwNameLen,			;
					NULL_PTR,       	;
					NULL_PTR,			;
					NULL_PTR,			;
					NULL_PTR )
				//
					IF ( liError == ERROR_SUCCESS )
					//
						AAdd( aName, Psz2String( pszName ) )
					ELSE
						EXIT
					ENDIF
				NEXT
			ENDIF
		//
			SELF:_CloseKey( phkResult )
			MemFree( pszName )
		ENDIF
	//
		SELF:liLastError := liError
	//
		RETURN aName




	METHOD GetInt( cSection, cEntry, nDefault ) 
//d Read a LongInt value, in the Entry of a specified Section
//a <cSection> is the Section Name\line
//a <cEntry> is the Entry Name\line
//a <nDefault> is the default value. ( Default is 0 ) If the Entry doesn't exist, it's created with the default value, and this one is returned.
//r The LongInt Value read in the specified entry, or the default value.
		LOCAL dwType		AS DWORD
		LOCAL dwData		:= 0 AS DWORD
	//
		DEFAULT( @nDefault, 0 )
		DEFAULT( @cSection, "" )
	//
		dwType := SELF:GetDataType( cSection, cEntry )
	//
		IF ( SELF:LastError == ERROR_SUCCESS )
		//
			IF ( dwType == REG_DWORD_BIG_ENDIAN )  .OR. ( dwType == REG_DWORD )
			// Ok read data
				SELF:GetData( cSection, cEntry, @dwData, _SizeOf( DWORD ) )
			//
				IF ( SELF:LastError == ERROR_SUCCESS )
					IF ( dwType == REG_DWORD_BIG_ENDIAN )
						dwData := LoWord( DWORD( dwData ) ) + HiWord( DWORD( dwData ) )
					ENDIF
				ELSE 
					IF !SELF:ReadOnly
					// May be the Key doesn't exist
						SELF:WriteInt( cSection, cEntry, nDefault )
					ENDIF
					dwData := nDefault
				ENDIF
			ELSE
				dwData := 0
			ENDIF
		ELSE
			IF !SELF:ReadOnly
			// May be the Key doesn't exist
				SELF:WriteInt( cSection, cEntry, nDefault )
			ENDIF
			dwData := nDefault
		ENDIF
	//
		RETURN LONG( _CAST, dwData )




	METHOD GetSection( cSection ) 
//p Retrieve all Entries and there values in a specified Section
//r An Multi-dimensionnal Array with Entries Name and values.
//d This method return an array with all entries. For Each entry, we have an array with :\line
//d \tab 1 - The Entry Name ( String )
//d \tab 2 - The Entry Value ( ? )
//d \tab 3 - The Value type ( As a RegXXX constant : REG_SZ;  REG_DWORD )
//e LOCAL aEntries	AS ARRAY
//e //
//e aEntries := oReg:GetSection( "Test" )
//e
		LOCAL dwIndex 		AS DWORD
		LOCAL dwType		AS DWORD
		LOCAL aEntries		AS ARRAY
		LOCAL aData			AS ARRAY
		LOCAL sData			AS STRING
		LOCAL iData			AS LONGINT
	//
		DEFAULT( @cSection, "" )
		aData := { }
		aEntries := {}
		dwIndex := 0
	// Read Entries Name
		aEntries := SELF:GetEntries( cSection )
	//
		IF ( SELF:LastError == ERROR_SUCCESS  )
		//
			FOR dwIndex := 1 TO ALen( aEntries )
			//
				dwType := SELF:GetDataType( cSection, aEntries[ dwIndex ] )
			//
				IF 	( dwType == REG_EXPAND_SZ )      .OR. ;
				( dwType == REG_BINARY )	     .OR. ;
				( dwType == REG_LINK )           .OR. ;
				( dwType == REG_NONE )           .OR. ;
				( dwType == REG_RESOURCE_LIST )  .OR. ;
				( dwType == REG_SZ )             .OR. ;
				( dwType == REG_MULTI_SZ )
				// Get Data as string
					sData := SELF:GetString( cSection, aEntries[ dwIndex ] )
 				//
					AAdd( aData, { aEntries[ dwIndex ], sData, dwType } )
				ELSEIF 	( dwType == REG_DWORD )          .OR. ;
				( dwType == REG_DWORD_BIG_ENDIAN )
				// Get Data as LONGINT
					iData := SELF:GetInt( cSection, aEntries[ dwIndex ] )
				//
					AAdd( aData, { aEntries[ dwIndex ], iData, dwType } )
				ENDIF
			NEXT
		ENDIF
	//
		RETURN aData




	METHOD GetSections( cSection ) 
//p Read all Sections Name
//r An Array with all Sections Name in the specified SubKey
		LOCAL liError		AS LONG
		LOCAL dwIndex		AS DWORD
		LOCAL dwNameLen		AS DWORD
		LOCAL phkResult		AS PTR
		LOCAL pszName		AS PSZ
		LOCAL aName			AS ARRAY
		LOCAL oKeyInfo		AS FabRegKeyInfo
	//
		DEFAULT( @cSection, "" )
		aName := {}
		dwIndex := 0
		liError := 0
	//
		phkResult := SELF:_OpenKey( cSection )
	//
		IF ( SELF:LastError == ERROR_SUCCESS  )
		//
			oKeyInfo := SELF:_GetKeyInfo( phkResult )
		//
			pszName   := MemAlloc( oKeyInfo:MaxSubKeyLen + 1 )
		//
			IF ( oKeyInfo:SubKeys > 0 )
				FOR dwIndex := 0 UPTO ( oKeyInfo:SubKeys -1 )
				//
					dwNameLen := oKeyInfo:MaxSubKeyLen + 1
				//
					liError := RegEnumKeyEx( phkResult, ;
					dwIndex,			;
					pszName,            ;
					@dwNameLen,			;
					NULL_PTR,			;
					NULL_PTR,			;
					NULL_PTR,			;
					NULL_PTR )
				//
					IF ( liError == ERROR_SUCCESS )
					//				
						AAdd( aName, Psz2String( pszName ) )
					ENDIF
				NEXT
			ENDIF
		//
			SELF:_CloseKey( phkResult )
			MemFree( pszName )
		ENDIF
		SELF:liLastError := liError
		RETURN aName




	METHOD GetString( cSection, cEntry, sDefault ) 
//d Read a String value, in the Entry of a specified Section
//a <cSection> is the Section Name\line
//a <cEntry> is the Entry Name\line
//a <sDefault> is the default value. ( Default is " " ) If the Entry doesn't exist, it's created with the default value, and this one is returned.
//r The String Value read in the specified entry, or the default value.
		LOCAL sRet			AS STRING
		LOCAL ptrData		AS PTR
		LOCAL dwType		AS DWORD
		LOCAL dwDataLen		AS DWORD
	//
		DEFAULT( @sDefault, " " )
		DEFAULT( @cSection, "" )
	//
		dwType := SELF:GetDataType( cSection, cEntry )
	//
		IF ( SELF:LastError == ERROR_SUCCESS )
		//
			dwDataLen := SELF:GetDataSize( cSection, cEntry )
			ptrData := MemAlloc( dwDataLen )
		//
			IF 	( dwType == REG_EXPAND_SZ )      .OR. ;
			( dwType == REG_BINARY )	     .OR. ;
			( dwType == REG_LINK )           .OR. ;
			( dwType == REG_NONE )           .OR. ;
			( dwType == REG_RESOURCE_LIST )  .OR. ;
			( dwType == REG_SZ )             .OR. ;
			( dwType == REG_MULTI_SZ )
			// Get Data
				SELF:GetData( cSection, cEntry, ptrData, dwDataLen )
			//
				sRet := Mem2String( ptrData, Max( 0,  --dwDataLen ) )
			ELSEIF 	( dwType == REG_DWORD )          .OR. 		;
			( dwType == REG_DWORD_BIG_ENDIAN )
			//
				sRet := NTrim( SELF:GetInt( cSection, cEntry ) )
			ENDIF
		//
			MemFree( ptrData )
		//
		ELSE
			IF !SELF:ReadOnly
			// May be the Key doesn't exist, put the default value
				SELF:WriteString( cSection, cEntry, sDefault )
			ENDIF
		//
			sRet := sDefault
		ENDIF
	//
		RETURN Trim( sRet )





	METHOD GetStringArray( cSection, cEntry, aDefault ) 
//d Read an array of Strings, in the Entry of a specified Section
//a <cSection> is the Section Name\line
//a <cEntry> is the Entry Name\line
//a <aDefault> is the default value. ( Default is { "" } ) If the Entry doesn't exist, it's created with the default value, and this one is returned.
//r The array of String Value read in the specified entry, or the default value.
		LOCAL aRet			AS ARRAY
		LOCAL ptrData		AS PTR
		LOCAL dwType		AS DWORD
		LOCAL dwDataLen		AS DWORD
	//
		DEFAULT( @aDefault, { "" } )
		DEFAULT( @cSection, "" )
		aRet := {}
	//
		dwType := SELF:GetDataType( cSection, cEntry )
	//
		IF ( SELF:LastError == ERROR_SUCCESS )
		//
			dwDataLen := SELF:GetDataSize( cSection, cEntry )
			ptrData := MemAlloc( dwDataLen )
		//
			IF 	( dwType == REG_MULTI_SZ )
			// Get Data
				SELF:GetData( cSection, cEntry, ptrData, dwDataLen )
			//
				aRet := FabGetStringArrayInPsz( ptrData )
			ELSE
			// May be the Key doesn't exist or wrong type, put the default value
				SELF:WriteStringArray( cSection, cEntry, aDefault )
			ENDIF
		//
			MemFree( ptrData )
		//
		ELSE
			IF !SELF:ReadOnly
			// May be the Key doesn't exist, put the default value
				SELF:WriteStringArray( cSection, cEntry, aDefault )
			ENDIF
		//
			aRet := aDefault
		ENDIF
	//
		RETURN aRet




	CONSTRUCTOR( sFullPath, HKey ) 
//p Intialize the FabRegistry Object
//a <sFullPath> is the FileName to use as SubKey or the real Registry Key to use
//e Local oReg	as	FabRegistry
//e oReg := FabRegistry( "SOFTWARE\ComputerAssociates\CA-Visual Objects Applications" )
		SELF:SubKey   		:= sFullPath
	//
		SELF:Type    		:= NULL_STRING
	// Init has no-error
		SELF:liLastError 	:= ERROR_SUCCESS
	// Per default, values are stored IN the HKEY_LOCAL_MACHINE key
		DEFAULT( @HKey, HKEY_LOCAL_MACHINE )
		SELF:UseKey			:= HKey
	//

ACCESS	 KEY_ACCESS AS DWORD PASCAL 
		LOCAL dwRet AS DWORD
	//
		IF SELF:ReadOnly
			dwRet := SELF:KEY_READ_ACCESS
		ELSE
			dwRet := SELF:KEY_ALL_ACCESS
		ENDIF
RETURN		 dwRet


ACCESS	 KEY_ALL_ACCESS AS DWORD PASCAL 
		RETURN 	_AND( _OR( 	STANDARD_RIGHTS_ALL,;
		KEY_QUERY_VALUE,	;
		KEY_SET_VALUE,		;
		KEY_CREATE_SUB_KEY,	;
		KEY_ENUMERATE_SUB_KEYS,;
		KEY_NOTIFY,			;
		KEY_CREATE_LINK ), _NOT( SYNCHRONIZE ) )



ACCESS	 KEY_READ_ACCESS AS DWORD PASCAL 
		RETURN 	_AND( _OR( 	STANDARD_RIGHTS_ALL,;
		KEY_QUERY_VALUE,	;
		KEY_ENUMERATE_SUB_KEYS,;
		KEY_NOTIFY ), _NOT( SYNCHRONIZE ) )



	METHOD KeyExist( cSection ) 
//p Check if a particular SubKey exist
//r TRUE if the key exist, FALSE unless.
		LOCAL phkResult		AS PTR
		LOCAL lExist		AS	LOGIC
	//
		DEFAULT( @cSection, "" )
	//
		lExist := FALSE
		phkResult := SELF:_OpenKey( cSection )
	//
		IF ( SELF:LastError == ERROR_SUCCESS )
		//
			SELF:_CloseKey( phkResult )
			lExist := TRUE
		//
		ENDIF
		RETURN lExist




	ACCESS KeyInfo AS FabRegKeyInfo PASCAL 
		LOCAL phkResult		AS PTR
		LOCAL oKeyInfo		:= NULL_OBJECT AS	FabRegKeyInfo
	//
		phkResult := SELF:_OpenKey( "" )
	//
		IF ( SELF:LastError == ERROR_SUCCESS )
		//
			oKeyInfo := SELF:_GetKeyInfo( phkResult )
		//
			SELF:_CloseKey( phkResult )
		//
		ENDIF
	//
		RETURN oKeyInfo


	ACCESS KeyLevel 
//r The level of the current SubKey. This indicates how many levels the SubKey is under the Root ( the current HKEY )
//e // If the current SubKey if "SOFTWARE\My Test"
//e ? Self:KeyLevel
//e // Will return 2
//e // If the current SubKey if "SOFTWARE"
//e ? Self:KeyLevel
//e // Will return 1
//e // If the current SubKey if ""
//e ? Self:KeyLevel
//e // Will return 0
		LOCAL nCount	AS	DWORD
	//
		nCount := Occurs2( "\", SELF:SubKey )
		nCount := nCount + 1
	//
		RETURN nCount




	ACCESS LastError( ) 
//r The last error code
		RETURN SELF:liLastError




	ASSIGN LastError( liError ) 
		SELF:liLastError := liError




	METHOD MoveDownTo( cSubKey ) 
//p Move to a new relative SubKey
//a <cSubKey> is a string indicating the new relative subkey to point to.
//d MoveDownTo() change the currently selected SubKey.
//e // If the current SubKey if "SOFTWARE\My Test"
//e Self:MoveDownTo( "And then" )
//e // Will return "SOFTWARE\My Test\And then"
//e // and any further operation will be relative to this SubKey
//r The SubKey after movement.
	//
		IF !Empty( cSubKey )
		//
			cSubKey := AllTrim( cSubKey )
			IF ( Left( cSubKey, 1 ) == "\" )
				cSubKey := SubStr( cSubKey, 2 )
			ENDIF
		// Move to...
			SELF:SubKey := SELF:SubKey + "\" + cSubKey
		ENDIF
	// Return the Current SubKey
		RETURN SELF:SubKey




	METHOD MoveEntries( SrcSection, DestSection ) 
//p Move all entries from one section to another.
//d MoveEntries() will move all entries from one section to another whatever types they are. After the operation,
//d  all entries are deleted.
//a <SrcSection> is a string indicating the root of registry tree to move.\line
//a \tab If Empty, the root starts at the SubKey property.\line
//a <DestSection> indicate the destination.\line
//a \tab If String, this indicate the destination SubKey, using the same HKEY ( UseKey Property ),
//a  starting at the SubKey property.\line
//a \tab If you want a destination in another HKEY, or with another Root, you can pass a FabRegistry object.\line
//r A logical value indicating the success of the operation.
		LOCAL lSuccess	AS	LOGIC
 	//
		lSuccess := SELF:CopyEntries( SrcSection, DestSection )
		IF lSuccess
			lSuccess := SELF:DeleteEntries( SrcSection, DestSection )
		ENDIF
 	//
		RETURN lSuccess




	METHOD MoveEntry( SrcSection, DestSection, cEntry ) 
//p Move one Entry value from one section to another.
//d MoveEntry() will move one entry entries from one section to another whatever types it is. After the operation,
//d  the source entry is deleted.
//a <SrcSection> is a string indicating the root of registry tree to move.\line
//a \tab If Empty, the root starts at the SubKey property.\line
//a <DestSection> indicate the destination.\line
//a \tab If String, this indicate the destination SubKey, using the same HKEY ( UseKey Property ),
//a  starting at the SubKey property.\line
//a \tab If you want a destination in another HKEY, or with another Root, you can pass a FabRegistry object.\line
//a <cEntry> is a string, indicating the Entry to move. If Empty, this will move the default value for the Source Key.
//r A logical value indicating the success of the operation.
		LOCAL lSuccess	AS	LOGIC
	//
		lSuccess := SELF:CopyEntry( SrcSection, DestSection, cEntry )
		IF lSuccess
			lSuccess := SELF:DeleteEntry( SrcSection, cEntry )
		ENDIF
		RETURN lSuccess





	METHOD MoveSection( SrcSection, DestSection ) 
//p Move all value/sections from one section to another
//d MoveSection() will move all entries & sections from one section to another whatever types they are, including entries stored
//d  under the source section. After the operation, the source section is deleted.
//a <SrcSection> is a string indicating the root of registry tree to move.\line
//a \tab If Empty, the root starts at the SubKey property.\line
//a <DestSection> indicate the destination.\line
//a \tab If String, this indicate the destination SubKey, using the same HKEY ( UseKey Property ),
//a  starting at the SubKey property.\line
//a \tab If you want a destination in another HKEY, or with another Root, you can pass a FabRegistry object.\line
//r A logical value indicating the success of the operation.
		LOCAL lSuccess	AS	LOGIC
 	//
		lSuccess := SELF:CopySection( SrcSection, DestSection )
		IF lSuccess
			lSuccess := SELF:DeleteSection( SrcSection )
		ENDIF
 	//
		RETURN lSuccess






	METHOD MoveSections( SrcSection, DestSection ) 
//p Move Sub-sections and their Values from one section to another
//d MoveSections() will move all entries & sections from one section to another whatever types they are, without including entries stored
//d  under the source section. This will only move Sub Sections and their values. After the operation, all Sub Sections are deleted.
//a <SrcSection> is a string indicating the root of registry tree to move.\line
//a \tab If Empty, the root starts at the SubKey property.\line
//a <DestSection> indicate the destination.\line
//a \tab If String, this indicate the destination SubKey, using the same HKEY ( UseKey Property ),
//a  starting at the SubKey property.\line
//a \tab If you want a destination in another HKEY, or with another Root, you can pass a FabRegistry object.\line
//r A logical value indicating the success of the operation.
		LOCAL aSections	AS	ARRAY
		LOCAL wCpt		AS	DWORD
	//
		aSections := SELF:GetSections( SrcSection )
	//
		SELF:CopySections( SrcSection, DestSection )
	//
		FOR wCpt := 1 TO ALen( aSections )
			SELF:DeleteSection( FabConcatDir( SrcSection, aSections[ wCpt ] ) )
		NEXT
		


		RETURN SELF

	METHOD MoveUpTo( nLevelUp ) 
//p Move Up the current SubKey specification
//d Move Up the current SubKey specification
//a <nLevelUp> is a DWORD value , indicating how many level must be removed.\line
//a \tab Default value is 1.
//r The new SubKey specification.
//e // If current if "SOFTWARE\FabriceForay\Test\TestKey"
//e Self:MoveUpTo( 1 )
//e // Result will be "SOFTWARE\FabriceForay\Test"
//e Self:MoveUpTo( 2 )
//e // And Then "SOFTWARE"
		LOCAL wCpt	AS	DWORD
	//
		DEFAULT( @nLevelUp, 1 )
	//
		IF ( nLevelUp <= SELF:KeyLevel )
			FOR wCpt := 1 UPTO nLevelUp
				SELF:SubKey := FabPathUp( SELF:SubKey )
			NEXT
		ENDIF
	// Return the Current SubKey
		RETURN SELF:SubKey




	METHOD PutData( cSection, cEntry, ptrBuffer, dwBufferLen, dwDataType ) 
//p Write Data in a particular SubKey, without regarding it's type.
//a <cSection> is the Section Name\line
//a <cEntry> is the Entry Name\line
//a <ptrBuffer> is a pointer to the memory where data bytes are stored.
//a <dwBufferLen> is a DWORD indicating the size of the buffer
//a <dwDataType> is a DWORD indicating the type of data ( Like REG_SZ, REG_DWORD, ... )
		LOCAL phkResult			AS PTR
	//
		DEFAULT( @cSection, "" )
		DEFAULT( @cEntry, "" )
	//
		phkResult := SELF:_CreateKey( cSection )
	//
		IF ( SELF:LastError == ERROR_SUCCESS )
		//
			SELF:liLastError := RegSetValueEx( phkResult,  ;
			String2Psz( cEntry ),  ;
			0,                     ;
			DWORD( _CAST, dwDataType ),                ;
			PTR( _CAST, ptrBuffer ), ;
			DWORD( _CAST, dwBufferLen ) )
		//
			SELF:_CloseKey( phkResult )
		ENDIF
	//
		RETURN SELF

	ACCESS ReadOnly AS LOGIC PASCAL 
RETURN		 SELF:m_ReadOnly


ASSIGN	 ReadOnly( lSet AS LOGIC ) AS LOGIC PASCAL 
		SELF:m_ReadOnly := lSet



	METHOD ReplaceKey( cFromFile, cBackupFile ) 
		LOCAL lSuccess			AS LOGIC
		LOCAL lNoBackup			:= FALSE AS LOGIC
		LOCAL cTmpFile			AS STRING
		LOCAL phkResult			AS PTR
	//
		IF Empty( cBackupFile )
		// Empty string or NIL
			cTmpFile := ""
			lNoBackup := TRUE
			IF !FabGetTempFile( @cTmpFile )
				RETURN FALSE
			ENDIF
			cBackupFile := cTmpFile
		ENDIF
	//
		phkResult := SELF:_OpenKey( "" )
	//
		IF ( SELF:LastError == ERROR_SUCCESS )
		//
			SELF:liLastError := RegReplaceKey( phkResult, 				;
			NULL_PTR, 					;
			String2Psz( cFromFile ),	;
			String2Psz( cBackupFile )	)
		//
			SELF:_CloseKey( phkResult )
		//
		ENDIF
	//
		IF lNoBackup
			FErase( cBackupFile )
		ENDIF
	//
		lSuccess := ( SELF:liLastError == ERROR_SUCCESS )
	//
		RETURN lSuccess
		




	METHOD RestoreKey( cFile ) 
		LOCAL liError			AS LONG
		LOCAL phkResult			AS DWORD
		LOCAL lSuccess			AS LOGIC
		LOCAL sKeySection		AS STRING
	//
		sKeySection := SELF:BuildSubKey()
	//
		liError := RegOpenKeyEx( SELF:hKey,    ;
		String2Psz( sKeySection ), ;
		0,                      ;
		SELF:Key_All_Access,        ;
		@phkResult )
	//
		IF ( liError == ERROR_SUCCESS )
		//
			liError := RegRestoreKey( phkResult, String2Psz( cFile ), 0 )
		//
			RegCloseKey( phkResult )
		//
		ENDIF
	//
		SELF:liLastError := liError
		lSuccess := ( SELF:liLastError == ERROR_SUCCESS )
	//
		RETURN lSuccess




	METHOD SaveKey( cFile ) 
		LOCAL liError			AS LONG
		LOCAL phkResult			AS DWORD
		LOCAL lSuccess			AS LOGIC
		LOCAL sKeySection		AS STRING
	//
		sKeySection := SELF:BuildSubKey()
	// Try to delete file if it exist.
		IF File( cFile )
			FErase( cFile )
		ENDIF
	//
		liError := RegOpenKeyEx( SELF:hKey,    ;
		String2Psz( sKeySection ), ;
		0,                      ;
		SELF:Key_All_Access,        ;
		@phkResult )
	//
		IF ( liError == ERROR_SUCCESS )
		//
			liError := RegSaveKey( phkResult, String2Psz( cFile ), NULL )
		//
			RegCloseKey( phkResult )
		//
		ENDIF
	//
		SELF:liLastError := liError
		lSuccess := ( SELF:liLastError == ERROR_SUCCESS )
	//
		RETURN lSuccess




	METHOD SetInt( cSection, cEntry, nInt ) 
//d Same as WriteInt() Method
		RETURN SELF:WriteInt( cSection, cEntry, nInt )




	METHOD SetString( cSection, cEntry, cString ) 
//d Same as WriteString() Method
		RETURN SELF:WriteString( cSection, cEntry, cString )


	ACCESS	SubKey	
//r The Current SubKey used.
//e ? oReg:SubKey	--> "SOFTWARE\ComputerAssociates\CA-Visual Objects Applications"
		RETURN	SELF:sSubKey


	ASSIGN	SubKey( cNew )	
//p Change the SubKey used by the FabRegistry Object
		IF IsString( cNew )
			cNew := AllTrim( cNew )
			IF Left( cNew, 1 ) == "\"
				cNew := SubStr( cNew, 1, SLen( cNew ) - 1 )
			ENDIF
			SELF:sSubKey := cNew
		ENDIF


	ACCESS	Type	
//r The Current Class value for this FabRegistry Object
		RETURN	SELF:sClass

	ASSIGN	TYPE( cNew )	
//p Set the Current Class value for this FabRegistry Object
		IF IsString( cNew )
			SELF:sClass := cNew
		ENDIF


	ACCESS UseKey( ) 
//r The Current Registry Key used
//e ? oReg:UseKey 	--> HKEY_LOCAL_MACHINE
		RETURN SELF:hKey


	ASSIGN UseKey( hKey ) 
//p Change the current Registry Key used
//a <hKey> is the Registry Key value to use.\line
//a \tab Valid Values are :\line
//a \tab HKEY_CLASSES_ROOT \line
//a \tab HKEY_CURRENT_USER \line
//a \tab HKEY_LOCAL_MACHINE \line
//a \tab HKEY_USERS \line
	// Correct Key ?
		IF 	( hKey == HKEY_CLASSES_ROOT  )  .OR. ;
		( hKey == HKEY_CURRENT_USER  )  .OR. ;
		( hKey == HKEY_LOCAL_MACHINE )  .OR. ;
		( hKey == HKEY_USERS )
		//
			SELF:hKey := hKey
		ENDIF
	//


	ACCESS UseKeyString 
//d Valid Values are :\line
//d \tab HKEY_CLASSES_ROOT \line
//d \tab HKEY_CURRENT_USER \line
//d \tab HKEY_LOCAL_MACHINE \line
//d \tab HKEY_USERS \line
//r The Current Registry Key used as a string
//e ? oReg:UseKeyString 	--> "HKEY_LOCAL_MACHINE"
		LOCAL cResult	AS	STRING
	//
		IF 		( hKey == HKEY_CLASSES_ROOT  )
			cResult := "HKEY_CLASSES_ROOT"
		ELSEIF	( hKey == HKEY_CURRENT_USER  )
			cResult := "HKEY_CURRENT_USER"
		ELSEIF	( hKey == HKEY_LOCAL_MACHINE )
			cResult := "HKEY_LOCAL_MACHINE"
		ELSEIF 	( hKey == HKEY_USERS )
			cResult := "HKEY_USERS"
		ENDIF
 	//
		RETURN cResult


	METHOD WriteInt( cSection, cEntry, nInt ) 
//d Write a LongInt value, in the Entry of a specified Section
//a <cSection> is the Section Name\line
//a <cEntry> is the Entry Name\line
//a <nInt> is the value to write. ( Default is 0 )
		LOCAL dwValue			AS DWORD
	//
		DEFAULT( @nInt, 0 )
	//
		dwValue  := DWORD( _CAST, nInt )
	//
		SELF:PutData( cSection, cEntry, @dwValue, _SizeOf( DWORD ), REG_DWORD )
	//
		RETURN SELF




	METHOD WriteString( cSection, cEntry, cString ) 
//d Write a String value, in the Entry of a specified Section
//a <cSection> is the Section Name\line
//a <cEntry> is the Entry Name\line
//a <cString> is the value to write. ( Default is " " )
		LOCAL pszString			AS PTR
	//
		DEFAULT( @cString, " " )
	//
		IF ( SLen( cString ) > FAB_MAXSTRING )
			cString := Left( cString, FAB_MAXSTRING )		
		ENDIF
	//
		pszString := StringAlloc( cString )
	//
		SELF:PutData( cSection, cEntry, pszString, PszLen( pszString ) + 1, REG_SZ )
	//
		MemFree( pszString )
	//
		RETURN SELF




	METHOD WriteStringArray( cSection, cEntry, aStrings ) 
//d Write an array of Strings value, in the Entry of a specified Section
//a <cSection> is the Section Name\line
//a <cEntry> is the Entry Name\line
//a <aStrings> is an array of String to write. ( Default is { "" } )
		LOCAL pszMemory		AS	PTR
		LOCAL dwSize		AS	DWORD
	//
		dwSize := 0
//	IF IsNil( aString
		DEFAULT( @aStrings, { "" } )
	// Convert Array to PSZ memory
		pszMemory := FabArray2Psz2( aStrings, @dwSize )
	// Write Data as MULTI_SZ
		SELF:PutData( cSection, cEntry, pszMemory, dwSize, REG_MULTI_SZ )
	//
		MemFree( pszMemory )
	//
		RETURN SELF




		END CLASS



CLASS FabRegKeyInfo
//l Registry Key Informations
//p Report Registry Key Informations
//d Returned by the KeyInfo access

// Internal Time/Date storage
	PROTECT wLastTime	AS	WORD
	PROTECT wLastDate	AS	WORD
	

	//number of subkeys
	PROTECT	dwSubKeys			AS	DWORD
	//longest subkey name length
	PROTECT	dwMaxSubKeyLen		AS	DWORD
	//number of value entries
	PROTECT	dwValues			AS	DWORD
	//longest value name length
	PROTECT	dwMaxValueNameLen	AS	DWORD
	//longest value data length
	PROTECT	dwMaxValueLen		AS	DWORD

//s

	//number of subkeys
	DECLARE	ACCESS SubKeys			//AS	DWORD
	//longest subkey name length
	DECLARE	ACCESS MaxSubKeyLen		//AS	DWORD
	//number of value entries
	DECLARE	ACCESS Values			//AS	DWORD
	//longest value name length
	DECLARE	ACCESS MaxValueNameLen	//AS	DWORD
	//longest value data length
	DECLARE	ACCESS MaxValueLen		//AS	DWORD




	PROTECT METHOD _SetDateTime( pftLastWriteTime AS _winFileTime ) PASCAL 
		LOCAL lpLocalTime 	IS _WinFileTime
		LOCAL wDate			:= 0 AS	WORD
		LOCAL wTime			:= 0 AS	WORD
	//
	// Convert UTC FileTime to Local Time
		IF FileTimeToLocalFileTime( pftLastWriteTime, @lpLocalTime )
	 	// Extract info
			IF !FileTimeToDosDateTime( @lpLocalTime , @wDate, @wTime )
			// Error !
				wDate := 0
				wTime := 0
			ENDIF
		ENDIF
	// Save data
		SELF:wLastTime := wTime
		SELF:wLastDate := wDate



		RETURN SELF

	CONSTRUCTOR( NumSubKeys, MaxSubKeyLen, NumValues, MaxValueLen, MaxDataLen, pftLastWriteTime  ) 
	//
		SELF:dwSubKeys := NumSubKeys
		SELF:dwMaxSubKeyLen := MaxSubKeyLen
		SELF:dwValues := NumValues
		SELF:dwMaxValueNameLen := MaxValueLen
		SELF:dwMaxValueLen := MaxDataLen
		SELF:_SetDateTime( pftLastWriteTime )

	ACCESS LastWriteDate AS DATE PASCAL 
//r Last Write Date
		RETURN FabPackedWord2Date( SELF:wLastDate )

	ACCESS LastWriteTime AS STRING PASCAL 
//r Last Write Time String in 24h format
		RETURN FabPackedWord2Time( SELF:wLastTime )

	ACCESS MaxSubKeyLen AS DWORD PASCAL 
//r longest subkey name length
		RETURN SELF:dwMaxSubKeyLen

	ACCESS MaxValueLen AS DWORD PASCAL 
//r longest value data length
		RETURN SELF:dwMaxValueLen

	ACCESS MaxValueNameLen AS DWORD PASCAL 
//r longest value name length
		RETURN SELF:dwMaxValueNameLen

	ACCESS SubKeys AS DWORD PASCAL 
//r number of subkeys
		RETURN SELF:dwSubKeys

	ACCESS Values AS DWORD PASCAL 
//r number of value entries
		RETURN SELF:dwValues

END CLASS
