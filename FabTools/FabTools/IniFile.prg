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


DeleteEntry( sEntry )
	Delete one entry

DeleteSection( sSection )
	Delete the full section

GetEntries( sSection )
	Get an array of Entries Name in the section

GetInt( sSection, sEntry <, nDefault > )
	Get an Int in the desired Section,Entry with nDefault per default ( 0 )

GetSection( sSection )
	Get an Array with 	{ Name, Value }			// For Ini Files
						{ Name, Value, Type }	// For Registry keys
GetSections( )
	Get an array with all Sections Name in the IniFile

GetString( sSection, sEntry <,sDefault> )
	Get a string in the desired Section,Entry with sDefault per default ( " " )

GetStringUpper( sSection, sEntry <,sDefault> )
	Get an Upper string in the desired Section,Entry with sDefault per default ( " " )

GetValue( sSection, sEntry, <uDefault>, <uType> )
	Get a usual value from the Section, Entry.
	If uType is not provided, the UsualType() of uDefault is used to determine the desired type
		GetValue( "Test", "Entry", , DATE ) --> return a Date Value

WriteInt( sSection, sEntry, nValue )
	Write the nValue in the Section,Entry

WriteString( sSection, sEntry, sValue )
	Write the sValue in the Section,Entry

WriteValue( sSection, sEntry, uValue )
	Write the uValue in the Section,Entry

*-/



*/
#region DEFINES
STATIC DEFINE FAB_MAXSTRING := 2048
#endregion

CLASS FabConfigFile
//d This is an Abstract Class for Ini Files and Registry Classes.\line
//d Don't use it directly.
//g Configuration,Configuration Classes





METHOD GetBinary( sSection, sEntry, ptrData, nLength ) 
	LOCAL nCpt	AS	DWORD
	LOCAL cData	AS	STRING
	LOCAL pData	AS	BYTE PTR
	LOCAL cHex	AS	STRING
	//
	pData := ptrData
	cData := SELF:GetString( sSection, sEntry, "" )
	//
	FOR nCpt := 1 TO nLength
		cHex := "0x"+SubStr( cData, (nCpt - 1)*2 +1, 2 )
		pData[ nCpt ] := Val( cHex )
	NEXT
	//
RETURN cData



METHOD GetString( sSection, sEntry, sDefault ) 
	// Deferred



RETURN self

METHOD GetStringUpper( sSection, sEntry, sDefault ) 
RETURN Upper( SELF:GetString( sSection, sEntry, sDefault ) )




METHOD GetValue(  sSection, sEntry, uDefault, uType ) 
//p Get a String Value, and convert it to a particular type
//a <sSection> is a string, indicating the section of the value to read\line
//a <sEntry> is a string, indicating the name if the value to read\line
//a <uDefault> is a usual, with the default value\line
//a <uType> is a constant ( LOGIC, STRING, DWORD, ... ) indicating the type if the value to return.
//r The string converted to the desired type, or the default value.
//s
	LOCAL sDefault	AS	STRING
	LOCAL sResult	AS	STRING
	LOCAL uResult	AS	USUAL
	//
	IF IsNil( uDefault )
		uDefault := " "
	ENDIF
	//
	IF IsNil( uType )
		uType := UsualType( uDefault )
	ENDIF
	//
	sDefault := AsString( uDefault )
	//
	sResult := SELF:GetString( sSection, sEntry, sDefault )
	//
	DO CASE
		CASE ( uType == STRING )
			uResult := sResult
		CASE ( uType == DATE )
			uResult := SToD( sResult )
		CASE ( uType == LOGIC )
			uResult := ( Upper( sResult ) == ".T." )
		CASE ( uType == FLOAT )	 .or.		;
			 ( uType == WORD )	 .or.		;
			 ( uType == SHORT )	 .or.		;
			 ( uType == DWORD )	 .or.		;
			 ( uType == LONG )	 .or.		;
			 ( uType == REAL4 )	 .or.		;
			 ( uType == REAL8 )	 .or.		;
			 ( uType == BYTE )	 .or.		;
			 ( uType == INT )

			uResult := Val( sResult )
		OTHERWISE
			uResult := NIL
	ENDCASE
	//
RETURN uResult




METHOD SetString( sSection, sEntry, sString ) 
	// Deferred



RETURN self

METHOD SetValue( sSection, sEntry, uValue )	
RETURN SELF:WriteValue( sSection, sEntry, uValue )




METHOD WriteBinary( sSection, sEntry, ptrData, nLength ) 
	LOCAL nCpt	AS	DWORD
	LOCAL cData	AS	STRING
	LOCAL pData	AS	BYTE PTR
	LOCAL cHex	AS	STRING
	LOCAL bByte	AS	BYTE
	//
	pData := ptrData
	cData := ""
	//
	FOR nCpt := 1 TO nLength
		bByte := pData[ nCpt ]
		cHex := "00" + AsHexString( bByte )
		cHex := Right( cHex, 2 )
		cData := cData + cHex
	NEXT
	//
RETURN SELF:WriteString( sSection, sEntry, cData )



METHOD WriteString( sSection, sEntry, sString ) 
	// Deferred


RETURN self

METHOD WriteValue( sSection, sEntry, uValue )	
	LOCAL sValue	AS	STRING
	//
	IF ( UsualType( uValue ) == DATE )
		sValue := DToS( uValue )
	ELSE
		sValue := AsString( uValue )
	ENDIF
	//
	SELF:WriteString( sSection, sEntry, sValue )
	//



RETURN self

END CLASS
CLASS FabIniFile	INHERIT	FabConfigFile
//l Ini Files Handling
//g Configuration,Configuration Classes
	//
	PROTECT oFSpec	AS	FileSpec



METHOD DeleteEntry( sSection, sEntry ) 
	LOCAL cFile := SELF:oFSpec:FullPath AS STRING
	//
	WritePrivateProfileString( String2Psz( sSection ), String2Psz( sEntry ), NULL_PTR, String2Psz( cFile ) )
	//



RETURN self

METHOD DeleteSection( sSection ) 
	LOCAL cFile := SELF:oFSpec:FullPath AS STRING
	//
	WritePrivateProfileString( String2Psz( sSection ), NULL_PTR, NULL_PTR, String2Psz( cFile ) )



RETURN self

ACCESS	FileName	
RETURN SELF:oFSpec:FileName + SELF:oFSpec:EXTEnsion




ACCESS	FullPath	
RETURN SELF:oFSpec:FullPath





METHOD	GetEntries( sSection ) 
// Retrieve all entries name in a section
	LOCAL ptrBuffer AS PTR
	LOCAL aEntries	AS ARRAY
	LOCAL cFile := SELF:oFSpec:FullPath AS STRING
	//
	ptrBuffer := MemAlloc( FAB_MAXSTRING )
	//
	GetPrivateProfileString( String2Psz( sSection ), NULL_PSZ, String2Psz( "" ), ptrBuffer, FAB_MAXSTRING, String2Psz( cFile ) )
	//
	aEntries := FabGetStringArrayInPsz( ptrBuffer )
	//
	MemFree( ptrBuffer )
	//
RETURN aEntries




METHOD GetInt( sSection, sEntry, nDefault ) 
	LOCAL cFile := SELF:oFSpec:FullPath AS STRING
	LOCAL dwRet	AS	DWORD
	LOCAL nRet AS INT
	//
	Default( @nDefault, 0 )
	dwRet := GetPrivateProfileInt( String2Psz( sSection ), String2Psz( sEntry), nDefault, String2Psz( cFile ) )
	nRet := LONG( _CAST, dwRet )
	// force to write/update the entry
	SELF:WriteInt( sSection, sEntry, nRet )
	//
RETURN nRet




METHOD GetSection( sSection ) 
// For each entry in the Section retrieve the value
	LOCAL aEntries	AS ARRAY
	LOCAL aSection	AS ARRAY
	LOCAL wCpt		AS WORD
	LOCAL sEntry	AS STRING
	//
	aEntries := SELF:GetEntries( sSection )
	aSection := {}
	//
	FOR wCpt := 1 UPTO ALen( aEntries )
		//
		sEntry := aEntries[ wCpt ]
		//
		AAdd( aSection,  { sEntry, SELF:GetString( sSection, sEntry ) } )
		//
	NEXT
	//
RETURN aSection




METHOD	GetSections( ) 
// Retrive all sections name in the IniFile
	LOCAL ptrBuffer AS PTR
	LOCAL aSections	AS ARRAY
	LOCAL cFile := SELF:oFSpec:FullPath AS STRING
	//
	ptrBuffer := MemAlloc( FAB_MAXSTRING )
	//
	GetPrivateProfileString( NULL_PSZ, NULL_PSZ, String2Psz( "" ), ptrBuffer, FAB_MAXSTRING, String2Psz( cFile ) )
	//
	aSections := FabGetStringArrayInPsz( ptrBuffer )
	//
	MemFree( ptrBuffer )
	//
RETURN aSections




METHOD GetString( sSection, sEntry, sDefault ) 
	LOCAL sValue 	AS STRING
	LOCAL ptrBuffer AS BYTE PTR
	LOCAL cFile := SELF:oFSpec:FullPath AS STRING
	//
	Default( @sDefault, " " )
	ptrBuffer := MemAlloc( FAB_MAXSTRING )
	//
	GetPrivateProfileString( String2Psz( sSection ), String2Psz( sEntry ), String2Psz( sDefault ), ptrBuffer, FAB_MAXSTRING, String2Psz( cFile  ) )
	//
	sValue := Psz2String( ptrBuffer )
	//
	MemFree( ptrBuffer )
	// force to write/update the entry
	SELF:WriteString( sSection, sEntry, sValue )
	//
RETURN Trim( sValue )




CONSTRUCTOR( cFileName ) 
	//
	SELF:oFSpec := FileSpec{}
	//
	IF IsString( cFileName )
		SELF:oFSpec:FullPath := cFileName
	ENDIF


METHOD SetInt( sSection, sEntry, nInt ) 
RETURN SELF:WriteInt( sSection, sEntry, nInt )





METHOD SetString( sSection, sEntry, sString ) 
RETURN SELF:WriteString( sSection, sEntry, sString )





METHOD SetValue( sSection, sEntry, uValue )	
RETURN SELF:WriteValue( sSection, sEntry, uValue )





METHOD WriteInt( sSection, sEntry, nInt ) 
	LOCAL cFile := SELF:oFSpec:FullPath AS STRING
	LOCAL cInt	:= AllTrim( Str( nInt ) ) AS STRING
	//
	WritePrivateProfileString( String2Psz( sSection ), String2Psz( sEntry ), String2Psz( cInt ), String2Psz( cFile ) )
	//

RETURN self


METHOD WriteString( sSection, sEntry, sString ) 
	LOCAL cFile := SELF:oFSpec:FullPath AS STRING
	//
	WritePrivateProfileString( String2Psz( sSection ), String2Psz( sEntry ), String2Psz( sString ), String2Psz( cFile ) )
	//



RETURN self

METHOD WriteValue( sSection, sEntry, uValue )	
	LOCAL sValue	AS	STRING
	//
	IF ( UsualType( uValue ) == DATE )
		sValue := DToS( uValue )
	ELSE
		sValue := AsString( uValue )
	ENDIF
	//
	SELF:WriteString( sSection, sEntry, sValue )
	//



RETURN self

END CLASS
CLASS FabWinIniFile INHERIT FabIniFile
//l Win.INI File Handling
//g Configuration,Configuration Classes



METHOD DeleteEntry( sSection, sEntry ) 
	//
	WriteProfileString( String2Psz( sSection ), String2Psz( sEntry ), NULL_PTR )
	//



RETURN self

METHOD DeleteSection( sSection ) 
	//
	WriteProfileString( String2Psz( sSection ), NULL_PTR, NULL_PTR )



RETURN self

METHOD	GetEntries( sSection ) 
// Retrieve all entries name in a section
	LOCAL ptrBuffer AS PTR
	LOCAL aEntries	AS ARRAY
	//
	ptrBuffer := MemAlloc( FAB_MAXSTRING )
	//
	GetProfileString( String2Psz( sSection ), NULL_PSZ, String2Psz( "" ), ptrBuffer, FAB_MAXSTRING )
	//
	aEntries := FabGetStringArrayInPsz( ptrBuffer )
	//
	MemFree( ptrBuffer )
	//
RETURN aEntries




METHOD GetInt( sSection, sEntry, nDefault ) 
	//
	Default( @nDefault, 0 )
	//
RETURN GetProfileInt( String2Psz( sSection ), String2Psz( sEntry ), nDefault )




METHOD	GetSections( ) 
// Retrieve all sections name in the IniFile
	LOCAL ptrBuffer AS PTR
	LOCAL aSections	AS ARRAY
	//
	ptrBuffer := MemAlloc( FAB_MAXSTRING )
	//
	GetProfileString( NULL_PSZ, NULL_PSZ, String2Psz( "" ), ptrBuffer, FAB_MAXSTRING )
	//
	aSections := FabGetStringArrayInPsz( ptrBuffer )
	//
	MemFree( ptrBuffer )
	//
RETURN aSections




METHOD GetString( sSection, sEntry, sDefault ) 
	LOCAL sValue 	AS STRING
	LOCAL ptrBuffer AS PTR
	//
	Default( @sDefault, " " )
	//
	ptrBuffer := MemAlloc( FAB_MAXSTRING )
	//
	GetProfileString( String2Psz( sSection ), String2Psz( sEntry ), String2Psz( sDefault ), ptrBuffer, FAB_MAXSTRING )
	//
	sValue := Psz2String( PTRBuffer )
	//
	MemFree( ptrBuffer )
	//
RETURN Trim( sValue )




CONSTRUCTOR() 
	//
	SUPER( System.IO.Path.Combine( Environment.GetEnvironmentVariable("windir"), "\WIN.INI" ) )
	//


METHOD SetInt( sSection, sEntry, nInt ) 
RETURN SELF:WriteInt( sSection, sEntry, nInt )





METHOD SetString( sSection, sEntry, sString ) 
RETURN SELF:WriteString( sSection, sEntry, sString )




METHOD WriteInt( sSection, sEntry, nInt ) 
	LOCAL cInt := AllTrim( Str( nInt ) ) AS STRING
	//
	WriteProfileString( String2Psz( sSection ), String2Psz( sEntry ), String2Psz( cInt ) )



RETURN self


METHOD WriteString( sSection, sEntry, sString ) 
	//
	WriteProfileString( String2Psz( sSection ), String2Psz( sEntry ), String2Psz( sString ) )
	//



RETURN self


END CLASS
