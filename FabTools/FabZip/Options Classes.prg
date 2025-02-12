// Options_Classes.prg

BEGIN NAMESPACE FabZip
	
	CLASS	FabAddOptions
		//l Options Available when adding files.
		//p Define a set of Options available when using the FabZipFile:Add() Method
		//d If DiskSpan or DiskSpanErase is set, you can NOT also use Freshen or Update,
		//d  and you can not create an .EXE (SFX Self-extracting) archive.\line
		//d So Setting either one to True, will reset Freshen and/or Update flag.\line
		//d NOTE: there is no encryption property for compression. If you have supplied a password STRING, then it will be used.
		// Set of Available options on Add Operations
		
		
		// Move Files
		PROTECT	lMove			AS	LOGIC
		// Freshen Archive
		PROTECT	lFreshen		AS	LOGIC
		// Update Archive
		PROTECT	lUpdate			AS	LOGIC
		// Disk Spanning
		PROTECT lDiskSpan		AS	LOGIC
		// Format each disk
		PROTECT lDiskSpanErase	AS	LOGIC
		// Include DirNames
		PROTECT lDirNames		AS	LOGIC
		// Separate Entries for each directories
		PROTECT lSeparateDirs	AS	LOGIC
		// Recurse Subdirectories
		PROTECT	lRecurseDirs		AS	LOGIC
		// Change ZipTime to newest file in Archive
		PROTECT	lZipTime			AS	LOGIC
		// Force 8.3 Format
		PROTECT lForceDOS		AS	LOGIC
		// Include System and Hidden Files
		PROTECT lSystem			AS	LOGIC
		//
		PROTECT lUseFloppy       AS  LOGIC
		//
		CONSTRUCTOR()  
			SUPER()
			RETURN
			
		ACCESS DirNames	AS LOGIC  
			//r A logical value indicating if Directory Info are saved with files.
			RETURN SELF:lDirNames
			
		ASSIGN DirNames( lNew AS LOGIC )   
			//p Set a logical value indicating if Directory Info are saved with files.
			IF lNew
				SELF:lDirNames := TRUE
			ELSE
				SELF:lDirNames := FALSE
				SELF:SeparateDirs := FALSE
			ENDIF
			
		ACCESS DiskSpan	AS LOGIC  
			//r A logical value indicating if we are creating a disk-spanning archive
			RETURN SELF:lDiskSpan
			
		ASSIGN DiskSpan( lNew AS LOGIC )   
			//p Set a logical value indicating if we are creating a disk-spanning archive
			IF lNew
				SELF:Freshen := FALSE
				SELF:Update := FALSE
			ELSE
				SELF:DiskSpanErase := FALSE
			ENDIF
			SELF:lDiskSpan := lNew
			
		ACCESS DiskSpanErase AS LOGIC  
			//r A Logical value indicating if the Disk must be formatted in a Disk-Span operation.
			RETURN SELF:lDiskSpanErase
			
		ASSIGN DiskSpanErase( lNew AS LOGIC )   
			//d This option pops up a "format disk" dialog every time the user is prompted
			//d  for the next disk (including the first disk).  Of course, this option can NOT be
			//d  used on non-removable drives (user will get an error msg if he tries to use this
			//d  option on a non-removable hard drive).
			IF lNew
				SELF:DiskSpan := TRUE
			ENDIF
			SELF:lDiskSpanErase := lNew
			
		ACCESS ForceDos AS LOGIC  
			//r A logical value indicating if FileNames are saved in 8.3 DOS format.
			RETURN SELF:lForceDos
			
		ASSIGN ForceDos( lNew AS LOGIC )   
			//d If True, force all filenames that go into the Zip file to meet the DOS 8.3 restriction.\line
			//d If False, long filenames are supported.\line
			//d \i WARNING:	Name conflicts can occur if 2 long filenames reduce to the same 8.3 filename!\i0
			SELF:lForceDos := lNew
			
		ACCESS	Freshen	AS LOGIC  
			//r A logical value indicating if the current Add mode is Freshen
			RETURN	SELF:lFreshen
			
		ASSIGN	Freshen( lNew AS LOGIC )   
			//p Set Add mode to Freshen. Existing files are updated if needed.
			IF lNew
				SELF:Move := FALSE
				SELF:Update := FALSE
			ENDIF
			SELF:lFreshen := lNew
			
		ACCESS	Move AS LOGIC  
			//r A logical value indicating if the current Add mode is Move
			RETURN	SELF:lMove
			
		ASSIGN	Move( lNew AS LOGIC )   
			//p Set Add mode to Freshen. Files are added to the archives, then deleted.
			IF lNew
				SELF:Freshen := FALSE
				SELF:Update := FALSE
			ENDIF
			SELF:lMove := lNew
			
		ACCESS RecurseDirs AS LOGIC  
			//r A Logical Value indicating if the Zip-process must recurse Subdirectories.
			RETURN SELF:lRecurseDirs
			
		ASSIGN RecurseDirs( lNew AS LOGIC )   
			//d Set a Logical Value indicating if the Zip-process must recurse Subdirectories.
			SELF:lRecurseDirs := lNew
			
		ACCESS SeparateDirs	AS LOGIC  
			//r A logical value indicating if Directories are stored as separated entries.
			RETURN SELF:lSeparateDirs
			
		ASSIGN SeparateDirs( lNew AS LOGIC )   
			//p Set a logical value indicating if Directories are stored as separated entries.
			IF lNew
				SELF:DirNames := TRUE
				SELF:lSeparateDirs := TRUE		
			ELSE
				SELF:lSeparateDirs := FALSE
			ENDIF
			
		ACCESS System AS LOGIC  
			//r A logical value indicating if files with their Hidden or System attributes set will be included in the Add operation.
			RETURN SELF:lSystem
			
		ASSIGN System( lNew AS LOGIC )   
			//r A logical value indicating if files with their Hidden or System attributes set will be included in the Add operation.
			SELF:lSystem := lNew
			
			
		ACCESS	Update AS LOGIC  
			//r A logical value indicating if the current Add mode is Update
			RETURN	SELF:lUpdate
			
		ASSIGN	Update( lNew AS LOGIC )   
			//p Set Add mode to Update. Existing files are updated if needed, and files that arent' in the archive too.
			IF lNew
				SELF:Move := FALSE
				SELF:Freshen := FALSE
			ENDIF
			SELF:lUpdate := lNew
			
		ACCESS ZipTime AS LOGIC  
			//r A logical value indicating if set Zip timestamp to that of the newest file in the archive.
			RETURN SELF:lZipTime
			
		ASSIGN ZipTime( lNew AS LOGIC )   
			//d Set a logical value indicating if set Zip timestamp to that of the newest file in the archive.
			SELF:lZipTime := lNew
			
	END CLASS
	
	CLASS	FabExtractOptions
		//l Options Available when extracting files.
		//p Define a set of Options available when using the FabZipFile:Extract() Method
		//d NOTE: there is no decryption property for extraction.\line
		//d If an encrypted file is encountered, the user will be automatically prompted for a password.
		// Set of Available options on Extract Operations
		PROTECT lTest		AS	LOGIC
		// "freshen" (extract only newer files that already exist)
		PROTECT	lFreshen	AS	LOGIC
		// "update" (extract only newer files & brand new files)
		PROTECT	lUpdate		AS	LOGIC
		// If true, recreate dir structure
		PROTECT	lDirNames	AS	LOGIC
		// if true, overwrite existing (no asking)
		PROTECT lOverWrite	AS	LOGIC
		
		CONSTRUCTOR()  
			SUPER()
			RETURN
			
		ACCESS	DirNames AS LOGIC  
			//r If True, extracts and recreates the relative pathname that may have been stored with each file. Empty directories stored in the archive (if any) will also be recreated.
			RETURN	SELF:lDirNames
			
		ASSIGN	DirNames( lNew AS LOGIC )   
			//d If True, extracts and recreates the relative pathname that may have been stored with each file. Empty directories stored in the archive (if any) will also be recreated.
			SELF:lDirNames := lNew
			
		ACCESS	Freshen AS LOGIC  
			//r A logical value indicating if we will extract only newer files that already exist.
			RETURN	SELF:lFreshen
			
		ASSIGN	Freshen( lNew AS LOGIC )   
			//d Set a A logical value indicating if we will extract only newer files that already exist.
			IF lNew
				SELF:Update := FALSE
				SELF:Test := FALSE
			ENDIF
			SELF:lFreshen := lNew
			
		ACCESS	OverWrite AS LOGIC  
			//r If True, overwrite any pre-existing files during Extraction.
			RETURN	SELF:lOverWrite
			
		ASSIGN	OverWrite( lNew AS LOGIC )   
			//d If True, overwrite any pre-existing files during Extraction.
			SELF:lOverWrite := lNew
			
		ACCESS	Test AS LOGIC  
			//d A logical value indicating if exraction will only test the archive to see if the files could be successfully extracted.
			//d  Testing is done by extracting the files, but NOT writing the extracted data to the disk.
			//d  Only the CRC code of the files is used to determine if they are stored correctly.
			RETURN	SELF:lTest
			
		ASSIGN	Test( lNew AS LOGIC )   
			//d A logical value indicating if exraction will only test the archive to see if the files could be successfully extracted.
			//d  Testing is done by extracting the files, but NOT writing the extracted data to the disk.
			//d  Only the CRC code of the files is used to determine if they are stored correctly.
			IF lNew
				SELF:Freshen := FALSE
				SELF:Update := FALSE
			ENDIF
			SELF:lTest := lNew
			
		ACCESS	Update AS LOGIC  
			//r If True, extract files that don’t already exist and OverWrite is also set to true, it will extract newer files from the archive.
			RETURN	SELF:lUpdate
			
		ASSIGN	Update( lNew AS LOGIC )   
			//d If True, extract files that don’t already exist and if OverWrite is also set to true, it will extract newer files from the archive.
			
			IF lNew
				SELF:Freshen := FALSE
				SELF:Test := FALSE
			ENDIF
			SELF:lUpdate := lNew
			
	END CLASS
	
	CLASS	FabSFXOptions
		//l Options Available when building a SFX file
		//p Define a set of Options Available when building a SFX file using the FabZipFile:Convert2SFX() Method
		//d These are the advanced options for creating more powerful Self-Extracting
		//d  archives.  By using these options, you can turn the new .EXE archive into
		//d  a small self-contained setup program!
		// Set of Available options on SFX Operations
		// Allows user to de-select the command line checkbox. Once deselected, the command line will not be run.
		// NOTE: The checkbox doesn't appear unless there is a command line specified.
		PROTECT		lAskCmdLine			AS	LOGIC
		// Lets user modify list of files to be extracted
		PROTECT		lAskFiles			AS	LOGIC
		// Does NOT show the user the dialog box that lets him choose the overwrite action at runtime for files that already exist
		PROTECT		lHideOverwriteBox	AS	LOGIC
		// If True, then the size of the SFX executable will be checked before extracting. By default checking is set to True.
		// If size checking is off (False) and the SFX file layout is wrong it is very likely you will get a system error.
		PROTECT		lCheckSize			AS	LOGIC
		// If True, extraction of the SFX contents will be performed automatically, no user actions are required.
		// NOTE: This works only if the SFX's filename starts with an exclamation mark ( ! )
		// -for security reasons-For example: !AUTORUN.EXE
		// WARNING: Use this only in rare cases! We advise you NOT to use this because files will be
		//  extracted onto the user's disk without his knowledge.
		PROTECT		lAutoRun			AS	LOGIC
		// This is the default overwrite option for what the SFX program is supposed to do if it finds files that already exist.
		// If  "HideOverWriteBox" is true, then this option  will be used during extraction.
		// These are the possible values for this property:
		//	FABZIP_ovrConfirm - ask user when each file is found ( Default )
		//	FABZIP_ovrAlways - always overwrite existing files
		//	FABZIP_ovrNever - never overwrite - skip those files
		PROTECT		nOverwriteMode		AS	WORD
		// The sum of length of the next three strings must not be bigger than 249
		// The caption of the SFX program's dialog box at runtime. The default is 'Self-extracting Archive'.
		PROTECT		cCaption			AS	STRING
		// The default target directory for extraction of files at runtime.
		// This can be changed at runtime through the dialog box. If you don't specify a value for this optional property,
		// the user's current directory will be the default.
		PROTECT		cDefaultDir			AS	STRING
		// This command line will be executed immediately after extracting the files.
		// Typically used to show the readme file, but can do anything. There is a predefined symbol that can be used
		//  in the command line to tell you which target directory was actually used (since the user can always change your default).
		// Special symbols:
		// 	"|" is the command/arg separator,
		// 	"><" is the actual extraction dir selected by user
		// Example:
		// 	notepad.exe|><readme.txt
		// Run notepad to show "readme.txt" in the actual extraction directory.
		// ( This is an optional property. )
		PROTECT		cCommandline		AS	STRING
		
		ACCESS AskCmdLine AS LOGIC  
			//d If True, allows user (at runtime) to de-select the SFX program’s command line checkbox.
			//d  Once de-selected, the command line will not be executed.\line
			//d NOTE: The checkbox doesn't appear unless there is a command line specified.
			RETURN SELF:lAskCmdLine
			
		ASSIGN AskCmdLine( lNew AS LOGIC )   
			//d If True, allows user (at runtime) to de-select the SFX program’s command line checkbox.
			//d  Once de-selected, the command line will not be executed.\line
			//d NOTE: The checkbox doesn't appear unless there is a command line specified.
			SELF:lAskCmdLine := lNew
			
		ACCESS AskFiles AS LOGIC  
			//d If True, lets user (at runtime) modify the SFX program's list of files to be extracted.
			RETURN SELF:lAskFiles
			
		ASSIGN AskFiles( lNew AS LOGIC )   
			//d If True, lets user (at runtime) modify the SFX program's list of files to be extracted.
			SELF:lAskFiles  := lNew
			
		ACCESS AutoRun AS LOGIC  
			//d If True, extraction of the SFX contents will be performed automatically, no user actions are required.\line
			//d NOTE: This works only if the SFX's filename starts with an exclamation mark ( ! ) -for security reasons- For example: !AUTORUN.EXE\line
			//d WARNING: Use this only in rare cases! We advise you NOT to use this because files will be extracted onto the user's disk without his knowledge.
			RETURN SELF:lAutoRun
			
		ASSIGN AutoRun( lNew AS LOGIC )   
			//d If True, extraction of the SFX contents will be performed automatically, no user actions are required.\line
			//d NOTE: This works only if the SFX's filename starts with an exclamation mark ( ! ) -for security reasons- For example: !AUTORUN.EXE\line
			//d WARNING: Use this only in rare cases! We advise you NOT to use this because files will be extracted onto the user's disk without his knowledge.
			SELF:lAutoRun := lNew
			
		ACCESS Caption AS STRING  
			//p Caption is the caption of the SFX dialog box when you start executing a .EXE archive.
			//d When you start a executable which was build by ConvertSFX then this will be the caption of the dialog box you will see.\line
			//d If you don’t set it yourself "Self-extracting Archive" will be used as default.
			RETURN SELF:cCaption
			
		ASSIGN Caption( cNew AS STRING )   
			//p Caption is the caption of the SFX dialog box when you start executing a .EXE archive.
			//d When you start a executable which was build by ConvertSFX then this will be the caption of the dialog box you will see.\line
			//d If you don’t set it yourself "Self-extracting Archive" will be used as default.
			SELF:cCaption := cNew
			
		ACCESS CheckSize AS LOGIC  
			//d If True, then the size of the SFX executable will be checked before extracting. By default checking is set to True. If size checking is off (False) and the SFX file layout is wrong it is very likely you will get a system error.
			RETURN SELF:lCheckSize
			
		ASSIGN CheckSize( lNew AS LOGIC )   
			//d If True, then the size of the SFX executable will be checked before extracting. By default checking is set to True. If size checking is off (False) and the SFX file layout is wrong it is very likely you will get a system error.
			SELF:lCheckSize := lNew
			
		ACCESS CommandLine AS STRING  
			//p CommandLine can contain a command line to execute after extracting the executable.
			//d This is the command line that will be executed immediately after extracting the files.\line
			//d Typically used to view the readme file, but can do anything. There is a predefined symbol that can be used in the command line to tell you which target directory was actually used.\line
			//d Special symbols:\line
			//d |    (Vertical bar) is the command / argument separator.\line
			//d >< Is the actual extraction directory selected by user.\line
			//e notepad.exe|><Readme.txt
			//e This will run notepad to show "Readme.txt" in the actual extraction dir.
			RETURN SELF:cCommandLine
			
		ASSIGN CommandLine( cNew AS STRING )   
			//p CommandLine can contain a command line to execute after extracting the executable.
			//d This is the command line that will be executed immediately after extracting the files.\line
			//d Typically used to view the readme file, but can do anything. There is a predefined symbol that can be used in the command line to tell you which target directory was actually used.\line
			//d Special symbols:\line
			//d |    (Vertical bar) is the command / argument separator.\line
			//d >< Is the actual extraction directory selected by user.\line
			//e notepad.exe|><Readme.txt
			//e This will run notepad to show "Readme.txt" in the actual extraction dir.
			SELF:cCommandLine := cNew
			
		ACCESS DefaultDir AS STRING  
			//p DefaultDir is the directory that will be used by the executable when extracting.
			//d The directory can be changed in the SFX dialog box before extracting.
			//d If you don't specify this, the user's current directory will be the default.\line
			//d If you specify the special symbol >< here, then the user’s temporary
			//d directory will be the default extraction directory.  A Windows API call
			//d will be used at runtime to determine the name of this directory.
			RETURN SELF:cDefaultDir
			
		ASSIGN DefaultDir( cNew AS STRING )   
			//p DefaultDir is the directory that will be used by the executable when extracting.
			//d The directory can be changed in the SFX dialog box before extracting.
			//d If you don't specify this, the user's current directory will be the default.\line
			//d If you specify the special symbol >< here, then the user’s temporary
			//d directory will be the default extraction directory.  A Windows API call
			//d will be used at runtime to determine the name of this directory.
			SELF:cDefaultDir := cNew
			
		ACCESS HideOverwriteBox AS LOGIC  
			//d If True, does NOT show the user (at runtime) the SFX program’s dialog box that lets him choose the overwrite action for files that already exist.
			RETURN SELF:lHideOverwriteBox
			
		ASSIGN HideOverwriteBox( lNew AS LOGIC )   
			//d If True, does NOT show the user (at runtime) the SFX program’s dialog box that lets him choose the overwrite action for files that already exist.
			SELF:lHideOverwriteBox := lNew
			
		CONSTRUCTOR() 
			//
			SELF:OverWriteMode := 0
			SELF:Caption := "Self-extracting Archive"
			SELF:DefaultDir := ""
			SELF:CommandLine := ""
			SELF:CheckSize := TRUE
			//
			RETURN 
			
		ACCESS OverWriteMode AS WORD  
			//d OverWriteMode sets the the action for what the SFX program is supposed to do if it finds files that already exist.\line
			//d If the option ‘HideOverWriteBox’ is True, then this option will be used during extraction.\line
			//d OverWriteMode can take one of the following values:\line
			//d	 FABZIP_ovrConfirm - ask user when each file is found ( Default )\line
			//d	 FABZIP_ovrAlways - always overwrite existing files\line
			//d  FABZIP_ovrNever - never overwrite - skip those files\line
			RETURN SELF:nOverWriteMode
			
		ASSIGN OverWriteMode( nNew AS WORD )   
			//d OverWriteMode sets the the action for what the SFX program is supposed to do if it finds files that already exist.\line
			//d If the option ‘HideOverWriteBox’ is True, then this option will be used during extraction.\line
			//d OverWriteMode can take one of the following values:\line
			//d	 FABZIP_ovrConfirm - ask user when each file is found ( Default )
			//d	 FABZIP_ovrAlways - always overwrite existing files
			//d  FABZIP_ovrNever - never overwrite - skip those files
			SELF:nOverWriteMode := nNew
			
	END CLASS
	
END NAMESPACE // FabZip