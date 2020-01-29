// DrivesFiles.prg
USING System.IO

FUNCTION FabGetCurrentDir( ) AS STRING
/// <summary>
/// Files,Files Related Classes/Functions
/// Return the current directory as a string
/// </summary>
/// <return>the current directory as a string including Drive and Path</return>
LOCAL cRet AS STRING
    //
cRet := Directory.GetCurrentDirectory()
	//
RETURN cRet

FUNCTION FabExtractFileDir( FileName AS STRING) AS STRING 
//g Files,Files Related Classes/Functions
//p Extract FileDir info from FullPath String
//l Extract FileDir info from FullPath String
//r the FileDir ( never ended by a \ char except for root )
//e "C:\TEST\TESTFILE.TST"			->	"C:\TEST"
//e "C:\TESTFILE.TST"				->	"C:\"
//e "\TEST\TESTFILE.TST"			->	"\TEST"
//e "TEST\TESTFILE.TST"				->	"TEST"
//e "\\SERVER\TEST\TESTFILE.TST"	->	"\\SERVER\TEST"
LOCAL wPos		AS	DWORD
LOCAL cResult	AS	STRING
	//
wPos := SLen( FileName )
	// Starting at end of String, search for a Path or Drive separator
WHILE ( wPos > 0 ) .AND. !Instr( SubStr3( FileName, wPos, 1 ), "\:" )
	wPos --
ENDDO
	// Don't forget to suppress separator
IF ( wPos > 1 ) .AND. SubStr3( FileName, wPos, 1 ) == "\" .AND. !Instr( SubStr3( FileName, wPos-1, 1 ), "\:" )
	wPos--
ENDIF
	//
cResult := SubStr3( FileName, 1, wPos )
RETURN cResult

FUNCTION FabExtractFileDrive( FileName AS STRING ) AS STRING
//g Files,Files Related Classes/Functions
//p Extract FileDrive info from FullPath String
//l Extract FileDrive info from FullPath String
//d This functions also support FullPath information in UNC format. If so, the string
//d  returned will hold the full UNC path.
//r the FileDrive
//e "C:\TEST\TESTFILE.TST"			->	"C:"
//e "C:\TESTFILE.TST"				->	"C:"
//e "\TEST\TESTFILE.TST"			->	""
//e "TEST\TESTFILE.TST"				->	""
//e "\\SERVER\TEST\TESTFILE.TST"	->	"\\SERVER\TEST"
LOCAL wPos		AS	DWORD
LOCAL wPos2		AS	DWORD
LOCAL cResult	AS	STRING
	// Standard filepath string
IF ( SLen( FileName ) >= 3 ) .AND. ( SubStr3( FileName, 2, 1 ) == ":" )
	cResult := Upper( SubStr3( FileName, 1, 2 ) )
ELSEIF ( SLen( FileName ) >= 2 ) .AND. ( SubStr3( FileName, 1, 2 ) == "\\" )
		// UNC naming
	wPos2 := 0
	wPos := 3
	WHILE ( wPos < SLen( FileName ) ) .AND. ( wPos2 < 2 )
		IF SubStr3( FileName, wPos, 1 ) == "\"
			wPos2 ++
		ENDIF
		IF ( wPos2 < 2 )
			wPos ++
		ENDIF
	ENDDO
	IF ( SubStr3( FileName, wPos, 1 ) == "\" )
		wPos --
	ENDIF
	cResult := SubStr3( FileName, 1, wPos )
ENDIF
RETURN cResult

FUNCTION FabExtractFileExt( FileName AS STRING) AS STRING
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
	WHILE ( wPos > 0 ) .AND. !Instr( SubStr3( FileName, wPos, 1 ), "\:." )
		wPos --
	ENDDO
	//
	IF ( wPos > 0 ) .AND. SubStr3( FileName, wPos, 1 ) == "."
		cResult := SubStr2( FileName, wPos )
	ENDIF
	RETURN cResult

	FUNCTION FabExtractFileInfo( cPath AS STRING ) AS STRING
//g Files,Files Related Classes/Functions
//p Get File Info from a FullPath String
//d Get File Info from a FullPath String
//a <cPath> is a string with the FullPath information
//r The File Name and extension stored in <cPath>
	LOCAL cFile, cExt	AS STRING
	//
	cFile := FabExtractFileName( cPath )
	cExt := FabExtractFileExt( cPath )
	//
	RETURN ( cFile + cExt )

	FUNCTION FabExtractFileName( FileName AS STRING) AS STRING
//g Files,Files Related Classes/Functions
//p Extract FileName info from FullPath String
//l Extract FileName info from FullPath String
//r the FileName ( including the extension )
//e "C:\TEST\TESTFILE.TST"			->	"TESTFILE"
//e "C:\TEST\TESTFILE."				->	"TESTFILE"
//e "C:\TEST\TESTFILE"				->	"TESTFILE"
//e "\\SERVER\TEST\TESTFILE.TST"	->	"TESTFILE"
	LOCAL wPos		AS	DWORD
	LOCAL cResult	AS	STRING
	//
	wPos := SLen( FileName )
	// Starting at end of String, search for a Path or Drive separator
	WHILE ( wPos > 0 ) .AND. !Instr( SubStr3( FileName, wPos, 1 ), "\:" )
		wPos --
	ENDDO
	// Extract File Name and File Extension
	cResult := SubStr2( FileName, wPos + 1 )
	// Now Remove the Extension
	wPos := RAt( ".", cResult )
	IF ( wPos > 0 )
		cResult := SubStr( cResult, 1, wPos - 1 )
	ENDIF
	RETURN cResult

	FUNCTION FabExtractFilePath( FileName AS STRING) AS STRING
//g Files,Files Related Classes/Functions
//p Extract FilePath info from FullPath String
//l Extract FilePath info from FullPath String
//r the FilePath ( always ended by a \ char )
//e "C:\TEST\TESTFILE.TST"			->	"C:\TEST\"
//e "C:\TESTFILE.TST"				->	"C:\"
//e "\TEST\TESTFILE.TST"			->	"\TEST\"
//e "TEST\TESTFILE.TST"				->	"TEST\"
//e "\\SERVER\TEST\TESTFILE.TST"	->	"\\SERVER\TEST\"
	LOCAL wPos		AS	DWORD
	LOCAL cResult	AS	STRING
	//
	wPos := SLen( FileName )
	// Starting at end of String, search for a Path or Drive separator
	WHILE ( wPos > 0 ) .AND. !Instr( SubStr3( FileName, wPos, 1 ), "\:" )
		wPos --
	ENDDO
	//
	cResult := SubStr3( FileName, 1, wPos )
	RETURN cResult



	#region DEFINES
	DEFINE FO_COPY           :=0x0002
		DEFINE FO_DELETE         :=0x0003
		DEFINE FO_MOVE           :=0x0001
		DEFINE FO_RENAME         :=0x0004
		DEFINE FOF_ALLOWUNDO              :=0x0040
		DEFINE FOF_CONFIRMMOUSE           :=0x0002
		DEFINE FOF_FILESONLY              :=0x0080  // on *.*, do only files
		DEFINE FOF_MULTIDESTFILES         :=0x0001
		DEFINE FOF_NOCONFIRMATION         :=0x0010  // Don't prompt the user.
		DEFINE FOF_NOCONFIRMMKDIR         :=0x0200  // don't confirm making any needed dirs
		DEFINE FOF_NOERRORUI              :=0x0400  // don't put up error UI
		DEFINE FOF_RENAMEONCOLLISION      :=0x0008
		DEFINE FOF_SILENT                 :=0x0004  // don't create progress/report
		DEFINE FOF_SIMPLEPROGRESS         :=0x0100  // means don't show names of files
		DEFINE FOF_WANTMAPPINGHANDLE      :=0x0020  // Fill in SHFILEOPSTRUCT.hNameMappings
                                     // Must be freed using SHFreeNameMappings
	#endregion

	STATIC FUNCTION _FabFile( cFile AS STRING ) AS LOGIC PASCAL
	LOCAL struFindData	IS 	_winWIN32_FIND_DATA
	LOCAL pszFile		AS	PSZ
	LOCAL lFound		:= FALSE AS	LOGIC
	LOCAL hSuccess		AS	PTR
	// Standard behaviour
	pszFile := StringAlloc( cFile )
	hSuccess := FindFirstFile( pszFile, @struFindData )
	IF ( hSuccess != INVALID_HANDLE_VALUE )
		// File exist and is not a directory
		lFound := ( _AND( struFindData.dwFileAttributes, FILE_ATTRIBUTE_DIRECTORY ) == 0 )
		//
		FindClose( hSuccess )
	ENDIF
	MemFree( pszFile )
	RETURN lFound



	FUNCTION FabConcatDir( cRoot AS STRING, cSub AS STRING ) AS STRING  PASCAL
//g Files,Files Related Classes/Functions
//l Concatenation of Dir and Sub-Dirs or Files
//d FabConcatDir() will add two strings with files related informations. It will check for \\ at the end of <cRoot> and at the beginning of <cSub>.
//d  Path Informations can be in the Unix format ( using / ), if so, all </> chars are translated to <\\>.
//e ? FabConcatDir( "C:\\", "\\Windows" ) 		// "C:\\Windows"
//e ? FabConcatDir( "C:\\Windows", "Win.ini" )	// "C:\\Windows\\Win.ini" )
	LOCAL cTmpPath	AS	STRING
	// Convert Unix -> Dos
	cSub := StrTran( cSub, "/", "\" )
	cRoot := StrTran( cRoot, "/", "\" )
	cTmpPath := cRoot
	// Relative Path ?
	IF Left( cSub, 1 ) == "\"
		// No, Absolute
		IF Right( cTmpPath, 1 ) == "\"
			cTmpPath := cTmpPath + SubStr( cSub, 2 )
		ELSE
			cTmpPath := cTmpPath + cSub
		ENDIF
	ELSE
		// Relative
		IF Right( cTmpPath, 1 ) == "\"
			cTmpPath := cTmpPath + cSub
		ELSE
			IF !Empty( cTmpPath )
				cTmpPath := cTmpPath + "\" + cSub
			ELSE
				cTmpPath := cSub
			ENDIF
		ENDIF
	ENDIF
	//
	IF ( Right( cTmpPath, 1 ) == "\" )
		// Root ?
		IF SubStr( cTmpPath, -2, 1 ) != ":"
			// No !
			cTmpPath := SubStr( cTmpPath, 1, SLen( cTmpPath ) - 1 )
		ENDIF
	ENDIF
	//
	RETURN cTmpPath



	FUNCTION FabDate2PackedWord( dDate AS DATE ) AS WORD   PASCAL
//g Files,Files Related Classes/Functions
//p Convert a VO Date to a MS-DOS date format, stored in a word.
//l Convert a VO Date to a MS-DOS date format, stored in a word.
//d !!! WARNING !!! Date must start from 1980.
//x <dDate> is a valid VO Date
//r A word with the Date information.
	LOCAL wDay, wMonth, wYear	AS	WORD
	LOCAL wDosDate := 0 AS WORD
	//
	wDay := WORD( Day( dDate ) )
	wMonth := WORD( Month( dDate ) )
	wYear := WORD( Year( dDate ) )
	IF ( wYear >= 1980 )
		wYear := wYear - 1980
		//
		wMonth := ( wMonth << 5 )
		wYear := ( wYear << 9 )
		//
		wDosDate := _OR( wDay, wMonth, wYear )
	ENDIF
	//
	RETURN wDosDate





	FUNCTION FabDeleteFiles( cDisk AS STRING, acWildCards  AS USUAL ) AS LOGIC   PASCAL
	LOCAL aFiles	AS	ARRAY
	LOCAL aDir		AS	ARRAY
	LOCAL lSuccess	AS	LOGIC
	LOCAL wCpt		AS	DWORD
	LOCAL oFS		AS	FileSpec
	LOCAL cFile		AS	STRING
	//
	DEFAULT( @acWildCards, "*.*" )
	lSuccess := FALSE
	//
	IF !Empty( cDisk )
		cDisk := Left( cDisk, 1 ) +":\"
		//
		IF IsString( acWildCards )
			aDir := Directory( cDisk + acWildCards )
			aFiles := {}
			AEval( aDir, { |a| AAdd( aFiles, a[ F_NAME ] ) } )
		ELSEIF IsArray( acWildCards )
			aFiles := AClone( acWildCards )
		ELSE
			RETURN FALSE
		ENDIF
		//
		lSuccess := TRUE
		FOR wCpt := 1 TO ALen( aFiles )
			oFS := FileSpec{ aFiles[ wCpt ] }
			oFS:Drive := cDisk
			//
			cFile := oFS:FullPath
			//
			IF !FErase( cFile )
				lSuccess := FALSE
				EXIT
			ENDIF
		NEXT
	ENDIF
	//
	RETURN lSuccess



	FUNCTION FabDirMake( cPath AS STRING ) AS LOGIC
	LOCAL aPath	AS	ARRAY
	LOCAL nPos	AS	DWORD
	LOCAL cDrv	AS	STRING
	//
	cDrv := FabExtractFileDrive( cPath )
	IF Empty( cDrv )
		RETURN FALSE
	ENDIF
	//
	cPath := AllTrim( cPath )
	IF ( Right( cPath, 1 ) == "\" )
		cPath := SubStr3( cPath, 1, SLen( cPath ) - 1 )
	ENDIF
	//
	aPath := {}
	WHILE TRUE
		nPos := RAt( "\", cPath )
		IF ( nPos > 0 )
			AAdd( aPath, SubStr2( cPath, nPos + 1 ) )
			cPath := SubStr3( cPath, 1, nPos - 1 )
		ELSE
			EXIT
		ENDIF
	ENDDO
	//
	cPath := cDrv
	FOR nPos := ALen( aPath ) DOWNTO 1
		cPath := FabConcatDir( cPath, aPath[ nPos ] )
		IF !FabIsDir( cPath )
			IF ( DirMake( String2Psz(cPath) ) != 0 )
				RETURN FALSE
			ENDIF
		ENDIF
	NEXT
	//
	RETURN TRUE
	FUNCTION FabEraseFile( cFileName AS STRING, lAllowUndo := TRUE AS LOGIC ) AS LOGIC  PASCAL
//g Files,Files Related Classes/Functions
//l Remplacement for the FErase() function
//p Remplacement for the FErase() function
//a <cFileName> is a string, indicating the File to erase.
//a <lAllowUndo> is a logical value, indicating if the file must be moved to the recycle bin.
//a 	Default value is TRUE
//d This function, unlike FErase() can use the Recycle Bin to delete file.
	LOCAL structFile	IS	_winSHFileOpStruct
	LOCAL pszFile		AS	PTR
	LOCAL lSuccess		AS	LOGIC
	//
	pszFile := StringAlloc( cFileName )
	//
	structFile.hWnd := NULL_PTR //GetAppObject():Handle()
	structFile.wFunc := FO_DELETE
	structFile.pFrom := pszFile
	structFile.pTo	:= NULL_PTR
	structFile.fFlags := _OR( FOF_SILENT, FOF_NOCONFIRMATION )
	IF lAllowUndo
		structFile.fFlags := _OR( structFile.fFlags, FOF_ALLOWUNDO )
	ENDIF
	//
	lSuccess := ( SHFileOperation( @structFile ) == 0 )
	//
	MemFree( pszFile )
	//
	RETURN lSuccess


	FUNCTION FabFile( cFile AS STRING )	AS LOGIC PASCAL
//g Files,Files Related Classes/Functions
//l Replacement for the File() function
//p Replacement for the File() function
//d This function works the same way the File() function should, according to the help file.
	LOCAL lFound	AS	LOGIC
	LOCAL cPath		AS	STRING
	//
	lFound := FALSE
	IF !Empty( cFile )
		// Do we have some Drive Info or Path Info
		IF !( Instr( ":", cFile )  .OR. Instr( "\", cFile ) )
			// We will have to search in the SetDefault() and SetPAth() setting
			// First GetDefault()
			cPath := GetDefault()
			cPath := AllTrim( cPath )
			cFile := cPath + cFile
			// Standard behaviour
			lFound := _FabFile( cFile )
			//
			IF !lFound
				// Now, GetCurPath()
				cPath := GetCurPath()
				cPath := AllTrim( cPath )
				IF ( Right( cPath, 1 ) != "\" )
					cPath := cPath + "\"
				ENDIF
				cFile := cPath + cFile
				// Standard behaviour
				lFound := _FabFile( cFile )
				//
			ENDIF
		ELSE
			// Standard behaviour
			lFound := _FabFile( cFile )
		ENDIF
		//
	ENDIF
	//
	RETURN lFound




	FUNCTION FabFileExact( cFile AS STRING )	AS LOGIC PASCAL
//g Files,Files Related Classes/Functions
//l Replacement for the File() function
//p Replacement for the File() function
//d This function search for a file in the current directory. ( No use of SetPath() or SetDefault() dir )
	LOCAL lFound	AS	LOGIC
	//
	lFound := FALSE
	IF SLen( cFile ) != 0
		// Do we have some Drive Info or Path Info
		IF !( Instr( ":", cFile )  .OR. Instr( "\", cFile ) )
			//
			cFile := FabConcatDir( FabGetCurrentPath(), cFile )
		ENDIF
		// Standard behaviour
		lFound := _FabFile( cFile )
	ENDIF
	//
	RETURN lFound




	FUNCTION FabGetCurrentPath() AS STRING  PASCAL
//g Files,Files Related Classes/Functions
//p Return the current directory as a string
//r the current directory as a string including Drive and Path
//s
	RETURN CurDrive() + ":\" + CurDir()




	FUNCTION FabGetDiskFree( cDrive AS STRING )	AS	USUAL   PASCAL
//g Files,Files Related Classes/Functions
//p Return the space available on a specified disk.
//l Return the space available on a specified disk.
//a <cDrive> is the root directory of the disk to return information about.
//r The number of bytes of empty space on the specified disk drive.
	LOCAL SectorsPCluster,;
	BytesPSector,;
	FreeClusters,;
	TotalClusters	AS	DWORD
	LOCAL LDiskFree := 0	AS	USUAL
	//
	IF GetDiskFreeSpace( String2Psz( cDrive ), @SectorsPCluster, @BytesPSector, @FreeClusters, @TotalClusters )
		LDiskFree  :=  BytesPSector * SectorsPCluster * FreeClusters
	ENDIF
	RETURN LDiskFree




	FUNCTION FabGetDiskLabel( cDisk AS STRING, cVolume REF STRING ) AS LOGIC  PASCAL
//g Files,Files Related Classes/Functions
//p Return the Label for a particular disk
//d Return the Label for a particular disk
//a <cDisk> is a string with the disk to read\line
//a \tab The first left char of the string is used.\line
//a <cVolume> is a string, passed by reference that will receive the label for the desired disk.
//r A logical value indicating the success of the operation
	LOCAL lSuccess				AS	LOGIC
	LOCAL drive					AS DriveInfo
	//
	lSuccess := FALSE
	//
	IF !Empty( cDisk )
		// To be sure that the string is correct
		cDisk := Left( cDisk, 1 ) + ":\"
		TRY
			drive := DriveInfo{ cDisk }
			//
			cVolume := drive:VolumeLabel
			lSuccess := TRUE
		CATCH
			lSuccess := FALSE
		END TRY
	ENDIF
	//
	RETURN lSuccess





	FUNCTION FabGetDiskSerialNumber( cDisk AS STRING, dwSerial REF DWORD ) AS LOGIC PASCAL
//g Files,Files Related Classes/Functions
//p Return the Serial Number for a particular disk
//d Return the Serial Number for a particular disk
//a <cDisk> is a string with the disk to read\line
//a \tab The first left char of the string is used.\line
//a <dwSerial> is a DWORD, passed by reference that will receive the serial number for the desired disk.
//r A logical value indicating the success of the operation
	LOCAL lSuccess				AS	LOGIC
	LOCAL drive					AS DriveInfo
	//
	lSuccess := FALSE
	//
	IF !Empty( cDisk )
		// To be sure that the string is correct
		cDisk := Left( cDisk, 1 ) + ":\"
		TRY
			drive := DriveInfo{ cDisk }
			//
			#warning incorrect !!!
			dwSerial := 0
			lSuccess := TRUE
		CATCH
			lSuccess := FALSE
		END TRY
	ENDIF
	//
	RETURN lSuccess






	FUNCTION FabGetDiskSize( cDrive AS STRING )	AS	USUAL  PASCAL
//g Files,Files Related Classes/Functions
//p Return the size of a specified disk.
//l Return the size of a specified disk.
//a <cDrive> is the root directory of the disk to return information about.
//r The number of bytes of the specified disk drive.
	LOCAL lSizeOfDisk := 0	AS	USUAL
	LOCAL drive					AS DriveInfo
	//
	IF !Empty( cDrive )
		// To be sure that the string is correct
		cDrive := Left( cDrive, 1 ) + ":\"
		TRY
			drive := DriveInfo{ cDrive }
			//
			lSizeOfDisk := drive:TotalSize
	CATCH
		END TRY
	ENDIF
	//
	RETURN lSizeOfDisk





	FUNCTION FabGetFileDateTime( cFileName AS STRING ) AS DWORD PASCAL
//g Files,Files Related Classes/Functions
//l Get DateTime stamp of a file
//p Get DateTime stamp of a file
//d You can use the returned value with the FabFileBin class and the SetDateTime method.
//d  Be aware that the DateTime is returned in Local time.
//r The DateTime stamp
	LOCAL dwFatDateTime	AS	DWORD
	//
	LOCAL lwt AS DateTime
	lwt := File.GetLastWriteTimeUtc( cFileName )
	dwFatDateTime := lwt:ToBinary()
	//
	RETURN dwFatDateTime




	FUNCTION FabGetLogicalDrivesArray( lDriveOnly := FALSE AS LOGIC ) AS ARRAY PASCAL
//g Files,Files Related Classes/Functions
//g Drives,Drives related Classes/Functions
//d Retrieve all existing drives, and return an array with/without drives type	\line
//d  If lDriveOnly is True :\line
//d 	{ { "A" }, { "C" }, { "D" }, { "K" } }\line
//d	If lDriveOnly is False\line
//d 	{ { "A", DRIVE_REMOVABLE }, { "C", DRIVE_FIXED }, { "K", DRIVE_REMOTE } }\line
	LOCAL aRet		AS	ARRAY
	LOCAL aTemp		AS	ARRAY
	LOCAL cDrv		AS	STRING
	LOCAL drives AS DriveInfo[]
	//
	aRet := {}
	cDrv := ""	
	drives := DriveInfo.GetDrives()
	//
	FOREACH drive AS DriveInfo IN drives
		cDrv := drive:Name:Substring(0,1)
		IF lDriveOnly
			aTemp := { Upper( cDrv ) }
		ELSE
			aTemp := { Upper( cDrv ), (INT)drive:DriveType }
		ENDIF
		//
		AAdd( aRet, aTemp )
		cDrv := ""
	NEXT
	//
	RETURN	aRet




	FUNCTION FabGetSystemDir()	AS	STRING  PASCAL
//g Files,Files Related Classes/Functions
//p Return the Windows System Directory as a string
//r Return the Windows System Directory as a string
	RETURN Environment.SystemDirectory




	FUNCTION FabGetTempFile( cTempFile REF STRING, cPrefix:= "Fab" AS STRING, cTempPath := "" AS STRING ) AS LOGIC PASCAL
	// Function to obtain temporary files
	LOCAL	szTempPath	AS	PSZ
	LOCAL	szTempFile	AS	PSZ
	LOCAL	lResult		AS	LOGIC
	//
	lResult := FALSE
	szTempPath := MemAlloc( MAX_PATH )
	szTempFile := MemAlloc( MAX_PATH )
	// Retrieve TEMP Path
	IF Empty( cTempPath )
		GetTempPath( MAX_PATH, szTempPath )
	ELSE
		FabPszCopy( szTempPath, String2Psz( cTempPath ) )
	ENDIF
	//
	IF ( GetTempFileName( szTempPath, String2Psz( cPrefix ), 0, szTempFile) != 0 )
	    //
		cTempFile := Psz2String( szTempFile )
		lResult := TRUE
		//
	ENDIF
	//
	MemFree( szTempPath )
	MemFree( szTempFile )
	//
	RETURN lResult




	FUNCTION FabGetTempFile2( cTempFile REF STRING, cPrefix:= "Fab" AS STRING, cTempPath := "" AS STRING, lDel := TRUE AS LOGIC ) AS LOGIC  PASCAL
	LOCAL lResult 	AS	LOGIC
	LOCAL hFile		AS	PTR
	LOCAL cTemp		AS	STRING
	//
	lResult := FabGetTempFile( @cTemp, cPrefix, cTempPath )
	IF lResult
		//
		cTempFile := cTemp
		hFile := FCreate( cTempFile )
		FClose( hFile )
		FErase( cTempFile )
		//
	ENDIF
	RETURN lResult




	FUNCTION FabGetTempPath( cTempPath REF STRING ) AS LOGIC PASCAL
//g Files,Files Related Classes/Functions
//l Retrieve Windows Temp Dir
//p Retrieve Windows Temp Dir
//a <cTempPath> is a REF string, receiving the temp path value
//r A logical value indicating the success of the operation.
	// Function to obtain temporary files
	LOCAL	szTempPath	AS	PSZ
	LOCAL	lResult		AS	LOGIC
	LOCAL	nNeed		AS	DWORD
	//
	lResult := FALSE
	szTempPath := MemAlloc( MAX_PATH + 1 )
	// Retrieve TEMP Path
	nNeed := GetTempPath( MAX_PATH, szTempPath )
	IF ( nNeed > 0 )  .AND. ( nNeed < MAX_PATH )
		lResult := TRUE
		cTempPath := Psz2String( szTempPath )
	ENDIF
	//
	MemFree( szTempPath )
	//
	RETURN lResult




	FUNCTION FabGetWindowsDir()	AS	STRING PASCAL
//g Files,Files Related Classes/Functions
//p Return the Windows Directory as a string
//r Return the Windows Directory as a string
	RETURN Environment.GetEnvironmentVariable("windir")




	FUNCTION FabIsDir( cDir AS STRING )	AS	LOGIC PASCAL
//g Files,Files Related Classes/Functions
//p Check if a Directory exist
//l Check if a Directory exist
//a <cDir> is a string indicating the Directory to search
//d This function uses the Win32 FindFirstFile() to search for directories.
//d  It can also search for directories with UNC naming convention.
//r A Logical value indicating if the Directory has been found
	//
	RETURN Directory.Exists( cDir )




	FUNCTION FabIsDiskReady( cDisk AS STRING ) AS LOGIC PASCAL
//g Files,Files Related Classes/Functions
//g Drives,Drives related Classes/Functions
//p Indicate if a particular disk is readeable.
//d Indicate if a particular disk is readeable.
//a <cDisk> is a string with the disk to check\line
//a \tab The first left char of the string is used.\line
//r A logical value indicating the success of the operation
	LOCAL cDummy AS STRING
	RETURN FabGetDiskLabel( cDisk, @cDummy )




	FUNCTION FabIsDiskWriteable( cDisk AS STRING ) AS LOGIC PASCAL
//g Files,Files Related Classes/Functions
//g Drives,Drives related Classes/Functions
//p Indicate if a particular disk is writeable.
//d Indicate if a particular disk is writeable.
//a <cDisk> is a string with the disk to check\line
//a \tab The first left char of the string is used.\line
//r A logical value indicating the success of the operation
	LOCAL hPtr		AS	PTR
	LOCAL lSuccess	AS	LOGIC
	LOCAL cTemp		AS	STRING
	//
	lSuccess := FALSE
	IF !Empty( cDisk )
		cDisk := Left( cDisk, 1 ) + ":\"
		IF FabGetTempFile( @cTemp, , cDisk )
			hPtr := FCreate( cTemp )
			lSuccess := ( hPtr != F_ERROR )
			IF lSuccess
				FClose( hPtr )
				FErase( cTemp )
			ENDIF
		ENDIF
	ENDIF
	//
	RETURN lSuccess




	FUNCTION FabPackedWord2Date( wDate AS WORD ) AS DATE  PASCAL
//g Files,Files Related Classes/Functions
//p Convert a MS-DOS date format, stored in a word, to a VO Date
//d Convert a MS-DOS date format, stored in a word, to a VO Date
//a <wData> is a Date stored in MS-DOS date format
//r A VO Date type value

	LOCAL wDay, wMonth, wYear	AS	WORD
	//
	wDay := _AND( wDate, 0x001F )
	wMonth := _AND( ( wDate >> 5 ), 0x000F )
	wYear := _AND( ( wDate >> 9 ), 0x7F ) + 1980
	//
	RETURN SToD( StrZero( wYear, 4 ) + StrZero( wMonth, 2 ) + StrZero( wDay, 2 ) )





	FUNCTION FabPackedWord2Time( wTime AS WORD ) AS STRING  PASCAL
//g Files,Files Related Classes/Functions
//p Convert a MS-DOS time format, stored in a word, to a VO time string, in 24h format
//d Convert a MS-DOS time format, stored in a word, to a VO time string, in 24h format
//a <wData> is a Time value stored in MS-DOS time format
//r a VO time string, in 24h format
	LOCAL wSec, wMin, wHour	AS	WORD
	//
	wSec := ( _AND( wTime, 0x001F ) * 2 )
	wMin := _AND( ( wTime >> 5 ), 0x003F )
	wHour := _AND( ( wTime >> 11 ), 0x1F )
	RETURN ( StrZero( wHour,2 ) + ":" + StrZero( wMin,2 ) + ":" + StrZero( wSec,2 ) )




	FUNCTION FabPathUp( cFilePath AS STRING ) AS STRING   PASCAL
//g Files,Files Related Classes/Functions
//p Remove the last subdirectory from the end of a path.
//d Remove the last subdirectory from the end of a path.
//a <cFilePath> is a string with path info
//r A String, moved one path up.
//e // "\Dir1"
//e FabPathUp( "C:\Dir1\Test.Tst" )
//e // "\Dir1\Dir2\Dir3"
//e FabPathUp( "\Dir1\Dir2\Dir3\Test.Tst" )
//e // "Dir1\Dir2\Dir3"
//e FabPathUp( "Dir1\Dir2\Dir3\Test.Tst" )
//e // "Dir1\Dir2"
//e FabPathUp( "Dir1\Dir2\Dir3\" )
//e // "Dir1\Dir2"
//e FabPathUp( "Dir1\Dir2\Dir3" )
	LOCAL cPath		AS 	STRING
	LOCAL nPos		AS	DWORD
	// First, remove Drive Info
	cPath := cFilePath
	IF SubStr( cPath, 2, 1 ) == ":"
		cPath := SubStr( cPath, 3 )
	ENDIF
	// Remove any back-slash at the end
	IF ( Right( cPath, 1 ) == "\" )
		cPath := SubStr( cPath, 1, SLen( cPath ) - 1 )
	ENDIF
	// Rightmost "\"
	IF (nPos := RAt2("\", cPath )) != 0
		cPath := SubStr( cPath, 1, nPos)
	ELSE
		cPath := ""
	ENDIF
	//
	IF ( Right( cPath, 1 ) == "\" )
		cPath := SubStr( cPath, 1, SLen( cPath ) - 1 )
	ENDIF
	//
	RETURN cPath



	FUNCTION FabSetDiskLabel( cDisk AS STRING, cVolume AS STRING ) AS LOGIC
//g Files,Files Related Classes/Functions
//g Drives,Drives related Classes/Functions
//p Set the Label for a particular disk
//d Set the Label for a particular disk
//a <cDisk> is a string with the disk to read\line
//a \tab The first left char of the string is used.\line
//a <cVolume> is a string, indicating the label for the desired disk.
//r A logical value indicating the success of the operation
LOCAL lSuccess				AS	LOGIC
	//
lSuccess := FALSE
	//
IF !Empty( cDisk )
		// To be sure that the string is correct
	cDisk := Left( cDisk, 1 ) + ":\"
		//
	lSuccess := SetVolumeLabel( String2Psz( cDisk ), String2Psz( cVolume ) )
ENDIF
RETURN lSuccess




FUNCTION FabSetFileAttributes( cFile AS STRING, dwAttributes AS DWORD ) AS LOGIC
//g Files,Files Related Classes/Functions
//p Set the attributes of an existing file
//l Set the attributes of an existing file
//x <cFile> is a string with the fullpath of an existing file\line
//x <dwAttributes> is a DWord with the new attributes to set.
//r A logical value indicating the success of the operation.
//e FabSetFileAttributes( "C:\MyFile.Tst", FILE_ATTRIBUTE_HIDDEN + FILE_ATTRIBUTE_READONLY )
LOCAL lResult AS LOGIC
	//
lResult := FALSE
IF File( cFile )
	lResult := SetFileAttributes( String2Psz( cFile ), _AND( dwAttributes, _OR( FC_READONLY, FC_HIDDEN, FC_SYSTEM, FC_ARCHIVED ) ) )
ENDIF
	//
RETURN lResult




FUNCTION FabSetFileDateTime( cFile AS STRING, dNewDate AS DATE, cNewTime AS STRING ) AS LOGIC
//g Files,Files Related Classes/Functions
//p Change the Date and Time attribute of an existing file
//l Change the Date and Time attribute of an existing file
//d Change the Date and Time attribute of an existing file.\line
//d Parameters must be in Local time format and are converted to UTC by the function.
//x <cFile> is a string with fullpath information of an existing file.\line
//x <dNewDate> is the new date to set.\line
//x <cNewTime> is string with the new time to set
//r A logical Value indicating the success of the operation.
LOCAL lResult 	AS LOGIC
LOCAL hFile		AS	PTR
LOCAL wDate		AS	WORD
LOCAL wTime		AS	WORD
LOCAL lpLocalTime IS _WinFileTime
LOCAL lpFileTime IS _WinFileTime
lResult := FALSE
	// File Exist ?
IF File( cFile )
		//
	wDate := FabDate2PackedWord( dNewDate )
	wTime := FabTime2PackedWord( cNewTime )
		//
	lResult := DosDateTimeToFileTime( wDate, wTime, @lpLocalTime )
	LocalFileTimeToFileTime( @lpLocalTime, @lpFileTime )
	IF lResult
		hFile := CreateFile( String2Psz( cFile ), GENERIC_WRITE, 0, NULL, OPEN_EXISTING,	;
		FILE_ATTRIBUTE_NORMAL, NULL)
			//
		lResult := ( hFile != INVALID_HANDLE_VALUE )
		IF lResult
			lResult := SetFileTime( hFile, NULL, NULL, @lpFileTime )
			CloseHandle( hFile )
		ENDIF
	ENDIF
ENDIF
	//
RETURN lResult




FUNCTION FabSetFileDateTime2( cFile AS STRING, wDate AS WORD, wTime AS WORD ) AS LOGIC
//g Files,Files Related Classes/Functions
//p Set the Date and Time Attributes of a file, passed in the PackedWord format
//l Set the Date and Time Attributes of a file, passed in the PackedWord format.
//d Set the Date and Time Attributes of a file, passed in the PackedWord format.\line
//d Parameters must be in Local time format and are converted to UTC by the function.
//x <cFile> is a string with the fullpath information of an existing file\line
//x <wDate> is the date information stored in a word\line
//x <wTime> is the Time information stored in a word.
//r A logical value indicating the success of the operation.
/*
	Set the Date and Time Attributes of a file, passed in the PackedWord format
*/
LOCAL lResult 	AS LOGIC
LOCAL hFile		AS	PTR
LOCAL lpLocalTime IS _WinFileTime
LOCAL lpFileTime IS _WinFileTime
lResult := FALSE	
	// File Exist ?
IF File( cFile )
		//
	lResult := DosDateTimeToFileTime( wDate, wTime, @lpLocalTime )
	LocalFileTimeToFileTime( @lpLocalTime, @lpFileTime )
	IF lResult
		hFile := CreateFile( String2Psz( cFile ), GENERIC_WRITE, 0, NULL, OPEN_EXISTING,	;
		FILE_ATTRIBUTE_NORMAL, NULL)
			//
		lResult := ( hFile != INVALID_HANDLE_VALUE )
		IF lResult
			lResult := SetFileTime( hFile, NULL, NULL, @lpFileTime )
			CloseHandle( hFile )
		ENDIF
	ENDIF
ENDIF
	//
RETURN lResult




PROCEDURE FabSplitPath(	cPath AS STRING,	;
cDrive REF STRING,	;
cDir REF STRING,	;
cFile REF STRING,	;
cExt REF STRING)
	//
SplitPath( cPath, REF cDrive, REF cDir, REF cFile, REF cExt)
	//
RETURN




FUNCTION FabTime2PackedWord( cTime AS STRING ) AS WORD
//g Files,Files Related Classes/Functions
//p Convert a VO time string, in 24h format, to a MS-DOS time format, stored in a word
//x <cTime> is a string with a valid Time information.
//r A word with the Time information.
	LOCAL wSec, wMin, wHour	AS	WORD
	LOCAL wDosTime AS WORD
	//
	wSec := Val( SubStr( cTime, 7, 2 ) )
	wSec := ( wSec >> 2 )
	wMin := Val( SubStr( cTime, 4, 2 ) )
	wMin := ( wMin << 5 )
	wHour := Val( SubStr( cTime, 1, 2 ) )
	wHour := ( wHour << 11 )
	//
	wDosTime := wSec + wMin + wHour//_or( wSec, wMin, wHour )
	//
	RETURN wDosTime



