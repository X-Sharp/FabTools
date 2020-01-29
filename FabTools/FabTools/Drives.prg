FUNCTION FabAFiles( aFiles AS ARRAY ) AS LOGIC
//l Same as File() function with an array of Files
//p Same as File() function with an array of Files
//d This function will use all array items as FilePath, and check them with the File() function. If you need to test if at least ONE file exist, you must use the FabAFiles2() function.
//r A logical value indicating if ALL files are existing
	//
	LOCAL lExist	AS	LOGIC
	//
	lExist := TRUE
	AEval( aFiles,{ |c| lExist := ( lExist  .and. File( c ) ) } )
	//
RETURN lExist




FUNCTION FabAFiles2( aFiles AS ARRAY ) AS LOGIC
//l Same as File() function with an array of Files
//p Same as File() function with an array of Files
//d This function will use all array items as FilePath, and check them with the File() function. If you need to test if ALL files exist, you must use the FabAFiles() function.
//r A logical value indicating if at least one file exist
	//
	LOCAL lExist	AS	LOGIC
	//
	lExist := FALSE
	AEval( aFiles,{ |c| lExist := ( lExist  .or. File( c ) ) } )
	//
RETURN lExist



FUNCTION FabFSize( hFile AS PTR ) AS DWORD
//p Get the size of an opened file
//l Get the size of an opened file
	LOCAL lPos		AS	LONG
	LOCAL dwSize	as	long
	//
	lPos := FSeek3( hFile, 0, FS_RELATIVE )
	dwSize := FSeek3( hFile, 0, FS_END )
	FSeek3( hFile, lPos, FS_SET )
RETURN dword(dwSize)




