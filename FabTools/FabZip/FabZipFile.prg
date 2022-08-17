// FabZipFile.prg
USING Ionic.zip
USING Ionic.Zlib
USING System.Collections
USING System.Collections.Generic
USING System.IO
USING FabTools

BEGIN NAMESPACE FabZip
	
	CLASS FabZipFile
		
		// FileSpec for the Zip File
		PROTECT	cZipFile			AS	STRING
		// Array of Files in the Zip File
		PROTECT	aContents			AS	List<FabZipDirEntry> 
		// Array of Files to Add/Delete/Replace
		PROTECT	aFilesArgs			AS	List<STRING>
		// Compression Level is now a Enum
		PROTECT nCompLevel          AS  Ionic.Zlib.CompressionLevel
		// Password
		PROTECT cPassword           AS  STRING
		// Comment
		PROTECT cZipComment         AS  STRING
		// Temp Directory
		PROTECT cTempDir            AS  STRING
		// Need informations
		PROTECT lVerbose            AS  LOGIC
		//
		PROTECT dwMinFreeVolume     AS  DWORD
		PROTECT dwKeepFreeOnDisk1   AS  DWORD
		PROTECT cLastWrittenFile    AS  STRING
		
		//
		PROTECT cExtractDir AS STRING
		PROTECT oOwner AS OBJECT
		PROTECT lProcessing AS LOGIC
		PROTECT nSuccessCnt AS LONG
		// Events Handler
		// 
		EXPORT ExtractHandler AS EventHandler<ExtractProgressEventArgs>
		EXPORT SaveHandler AS EventHandler<SaveProgressEventArgs>
		//
		// Options on Add
		EXPORT		AddOptions			AS	FabAddOptions
		// Options on Extract
		EXPORT		ExtractOptions		AS	FabExtractOptions
		// Options for SFX
		EXPORT		SFXOptions			AS	FabSFXOptions
		//
		PROTECT dwMaxVolumeSize AS DWORD
		PROTECT nFilesDone      AS DWORD
		PROTECT nDiskNr         AS LONG
		PROTECT HowToEncrypt         AS  Ionic.Zip.EncryptionAlgorithm
		
		/// <summary>
		/// the dir where the next Extract operation will be done.
		/// </summary>
		ACCESS ExtractDir AS STRING
			RETURN SELF:cExtractDir
			
		ASSIGN ExtractDir( cNew AS STRING )
			SELF:cExtractDir := cNew
			
		/// <summary>
		/// The List indicating all filenames to work with, on next operation.
		/// </summary>
		ACCESS FilesArg AS List<STRING>
			RETURN SELF:aFilesArgs
			
		/// <summary>
		/// The List indicating all filenames inside the Zip File
		/// </summary>
		ACCESS Contents AS FabArray //List<FabZipDirEntry> 
			LOCAL aTemp AS FabArray
			//
			aTemp := FabArray{ SELF:aContents }
			RETURN aTemp
			
		ACCESS FileName AS STRING
			RETURN SELF:cZipFile
			
		ASSIGN FileName( cNew AS STRING )
			SELF:cZipFile := cNew
			SELF:aContents:Clear()
			SELF:aFilesArgs:Clear() // ?????
			SELF:UpdateContents()
			
		ACCESS FilesOperated AS LONG
			RETURN SELF:nSuccessCnt
			
		CONSTRUCTOR( )
			SELF:InitComponents()
			
			
		CONSTRUCTOR( cFileName AS STRING )
			SELF:InitComponents()
			//
			IF ( cFileName != NULL_STRING )
				SELF:FileName := cFilename
			ENDIF    
			
			
		CONSTRUCTOR( cFileName AS STRING, xOwner AS OBJECT )
			SELF:InitComponents()
			//
			IF ( cFileName != NULL_STRING )
				SELF:FileName := cFilename
			ENDIF 
			//
			SELF:oOwner := xOwner
			//        
			RETURN
			
		PROTECT METHOD InitComponents() AS VOID
			//
			SELF:HowToEncrypt := Ionic.Zip.EncryptionAlgorithm.PkzipWeak
			SELF:cPassword := ""
			SELF:AddOptions := FabAddOptions{}
			SELF:ExtractOptions := FabExtractOptions{}
			SELF:SFXOptions := FabSFXOptions{}
			//
			SELF:aContents := List<FabZipDirEntry>{} //ArrayList{}
			SELF:aFilesArgs := List<STRING>{} //ArrayList{}
			//   
			SELF:dwMaxVolumeSize := 0
			//
			
			
			
		METHOD UpdateContents() AS VOID    
			LOCAL oZipFile := NULL AS ZipFile
			LOCAL oFabEntry AS FabZipDirEntry
			// Clear the current Content ArrayList
			SELF:aContents:Clear()
			SELF:lProcessing := TRUE
			//
			TRY
				oZipFile := ZipFile.Read( SELF:cZipFile )
				//
				SELF:cZipComment := oZipFile:Comment
				//
				FOREACH oEntry AS ZipEntry IN oZipFile
					oFabEntry := FabZipDirEntry{ oEntry }
					SELF:aContents:Add( oFabEntry )
				NEXT
				//
			CATCH //Err AS Exception
				
			FINALLY
				IF oZipFile != NULL
					oZipFile:Dispose()
				ENDIF
			END TRY
			//
			ReflectionLib.InvokeMethod( SELF:oOwner, "OnFabZipDirUpdate" )
			//
			SELF:lProcessing := FALSE
			RETURN
			
		PROTECT METHOD ReportExtractSize() AS VOID
			LOCAL zipParams AS OBJECT[]
			LOCAL oZipFile := NULL AS ZipFile
			LOCAL nTotalSize AS INT64
			LOCAL nTotalFiles AS INT64
			// HACK For compatibility
			// We MUST regenerate two events :
			// #TotalFiles
			// #TotalSize
			//
			nTotalSize := 0
			nTotalFiles := 0
			TRY
				oZipFile := ZipFile.Read( SELF:cZipFile )
				//
				FOREACH oEntry AS ZipEntry IN oZipFile
					IF ( SELF:aFilesArgs:Contains( StrTran( oEntry:FileName, "/", "\" ) ) ) 
						// TotalSize in Zip
						nTotalSize := nTotalSize + oEntry:UnCompressedSize
						// Number of Files in Zip
						nTotalFiles ++
					ENDIF
				NEXT
				//
			CATCH //Err AS Exception
				
			FINALLY
				IF oZipFile != NULL
					oZipFile:Dispose()
				ENDIF
			END TRY  
			//   
			IF ( SELF:oOwner != NULL )
				//
				zipParams := <OBJECT>{ nTotalFiles, nTotalSize }
				//
				ReflectionLib.InvokeMethod( SELF:oOwner, "OnFabOperationSize", zipParams )
			ENDIF 
			RETURN
			
		PROTECT METHOD ReportAddSize() AS VOID
			LOCAL Params AS OBJECT[]
			LOCAL nTotalSize AS INT64
			LOCAL nTotalFiles AS INT64
			LOCAL Info AS System.IO.FileInfo
			// HACK For compatibility
			// We MUST regenerate two events :
			// #TotalFiles
			// #TotalSize
			//
			// The number of Files to Add
			nTotalFiles := SELF:aFilesArgs:Count
			// The total size that will be added to Zip
			nTotalSize := 0
			FOREACH cTmp AS STRING IN SELF:aFilesArgs
				// Does it exist ?
				IF ( System.IO.File.Exists( cTmp ) )
					Info := System.IO.FileInfo{ cTmp }
					nTotalSize := nTotalSize + Info:Length
				ENDIF
			NEXT 
			//   
			IF ( SELF:oOwner != NULL )
				//
				PARAMS := <OBJECT>{ nTotalFiles, nTotalSize }
				//
				ReflectionLib.InvokeMethod( SELF:oOwner, "OnFabOperationSize", PARAMS )
			ENDIF 
			RETURN
			
			
		/// <summary>
		/// Extract Zip File
		/// </summary>
		METHOD Extract( ) AS LOGIC
			LOCAL lRet AS LOGIC
			//
			SELF:ReportExtractSize()
			// Now, do the extract operation
			lRet := SELF:DoExtract()
			//
			RETURN lRet        
			
		PROTECT METHOD DoExtract() AS LOGIC    
			LOCAL oZipFile AS ZipFile
			LOCAL ZP AS ZipEntry
			LOCAL FA AS ExtractExistingFileAction
			//local e as ExtractProgressEventArgs
			//Local ZP as ZipEntry
			//
			oZipFile := ZipFile.Read( SELF:cZipFile ) 
			IF ( SELF:ExtractHandler != NULL )
				oZipFile:ExtractProgress += SELF:ExtractHandler
				//
			ENDIF    
			//
			oZipFile:Password := SELF:cPassword
			SELF:cZipComment := oZipFile:Comment
			// 
			SELF:lProcessing := TRUE 
			SELF:nSuccessCnt := 0
			FOREACH cTmp AS STRING IN SELF:aFilesArgs
				//
				TRY
					ZP := oZipFile[ cTmp ]
					IF ( SELF:ExtractOptions:OverWrite )
						FA := ExtractExistingFileAction.OverwriteSilently
					ELSE
						FA := ExtractExistingFileAction.DoNotOverwrite
					ENDIF
					ZP:Extract( SELF:ExtractDir, FA )
					SELF:nSuccessCnt ++
				CATCH ex AS Exception
					THROW ex
				END TRY
				//
			NEXT
			//
			SELF:aFilesArgs:Clear()
			oZipFile:Dispose()
			//
			SELF:lProcessing := FALSE
			RETURN TRUE
			
		METHOD Add( ) AS LOGIC
			LOCAL lRet AS LOGIC
			//
			SELF:ReportAddSize()
			// Now, do the Add operation
			lRet := SELF:DoAdd()
			//
			RETURN lRet
			
			// Where the REAL Zip operations are done.
		PROTECT METHOD DoAdd() AS LOGIC
			LOCAL oZipFile AS Ionic.Zip.ZipFile
			LOCAL Info AS FileInfo
			LOCAL TmpZipName AS STRING
			LOCAL NewName AS STRING
			LOCAL cTmpPath, cTmpMask AS STRING
			LOCAL lRecurse  AS LOGIC
			//Local 
			// File Exist, but Size == 0 ?
			IF System.IO.File.Exists( SELF:cZipFile )
				Info := FileInfo{ SELF:cZipFile }
				IF ( Info:Length == 0 )
					File.Delete( SELF:cZipFile )
				ENDIF
			ENDIF
			// if we are using disk spanning, first create a temporary file
			IF ( SELF:AddOptions:DiskSpan ) .OR. ( SELF:AddOptions:DiskSpanErase )
				// We can't do this type of Add on a spanned archive
				IF ( SELF:AddOptions:Freshen ) .OR. ( SELF:AddOptions:Update )
					//SELF:__ShowZipMessage( AD_NoFreshenUpdate, "" )
					RETURN FALSE
				ENDIF
				// We can't make a spanned SFX archive
				IF Upper( FabExtractFileExt( SELF:cZipFile ) ) == ".EXE"
					//SELF:__ShowZipMEssage( DS_NoSfxSpan, "" )
					RETURN FALSE
				ENDIF
				NewName := ""
				IF Empty( SELF:cTempDir )
					FabGetTempFile( NewName, "zip" )
				ELSE
					FabGetTempFile( NewName, "zip", SELF:cTempDir )
				ENDIF
				// The temporary Zip FileName
				TmpZipName := NewName
				// make sure it doesn't exist already
				File.Delete( TmpZipName )
				//
				IF SELF:lVerbose
					IF IsMethodUsual( SELF:oOwner, #OnFabZipDirUpdate )
						ReflectionLib.InvokeMethod( SELF:oOwner, "OnFabZipMessage", <OBJECT>{0, "Temporary ZipFile: " + TmpZipName} )
					ENDIF
				ENDIF
			ELSE	
				// Not Spanned - Create the outfile directly
				TmpZipName := SELF:FileName
			ENDIF            
			// New File ?
			IF System.IO.File.Exists( TmpZipName )
				oZipFile := ZipFile.Read( TmpZipName )        
			ELSE
				oZipFile := ZipFile{ TmpZipName }
			ENDIF 
			// No Multi Thread to Compress
			oZipFile:ParallelDeflateThreshold := -1           
			//
			IF ( SELF:SaveHandler != NULL )
				oZipFile:SaveProgress += SELF:SaveHandler
			ENDIF
			// 
			SELF:lProcessing := TRUE
			// No Files !?
			IF ( SELF:aFilesArgs:Count == 0 )
				// If we have a Freshen Flag, then we must check what files are inside
				// and outside to update them
				FOREACH oZDir AS FabZipDirEntry IN SELF:aContents
					// Convert FileName from Unix to DOS
					// We can only Freshen existing file !
					SELF:FilesArg:Add( StrTran( oZDir:FileName, "/", "\" ) )
				NEXT
			ENDIF
			// Recurse subdir ?
			lRecurse := SELF:AddOptions:RecurseDirs
			// The password and Encryption must be set BEFORE !!!!
			IF !Empty( SELF:cPassword )
				oZipFile:Password := SELF:cPassword
				// TODO : Check for Encryption...
				oZipFile:Encryption := SELF:HowToEncrypt
			ELSE
				oZipFile:Password := NULL
				oZipFile:Encryption := IOnic.Zip.EncryptionAlgorithm.None
			ENDIF
			
			// Now, Add Files ...
			FOREACH cTmp AS STRING IN SELF:aFilesArgs
				// Try to handle Wildcards
				IF ( AT("*",cTmp) > 0 )
					// Extract the path if any
					cTmpPath := FabExtractFileDir( cTmp )
					// then extract the Mask
					cTmpMask := FabExtractFileInfo( cTmp )
					// TODO We will have to calculate files sizes
					// Keep Directory names
					IF ( SELF:AddOptions:DirNames )
						oZipFile:AddSelectedFiles( "name = " + cTmpMask, cTmpPath, cTmpPath, lRecurse )
					ELSE
						// Remove Directory info, so everything is at root
						oZipFile:AddSelectedFiles( "name = " + cTmpMask, cTmpPath, "", lRecurse )
					ENDIF                    
				ELSE
					// If File already exist, we have an Update.....
					// Keep Directory names
					IF ( SELF:AddOptions:DirNames )
						oZipFile:UpdateFile( cTmp )
					ELSE
						// Remove Directory info, so everything is at root
						oZipFile:UpdateFile( cTmp, "" )
					ENDIF
				ENDIF
			NEXT
			// Update Changes !
			oZipFile:CompressionLevel := SELF:nCompLevel
			oZipFile:Comment := SELF:cZipComment
			//
			// if we are using disk spanning, first create a temporary file
			IF ( SELF:AddOptions:DiskSpan ) .OR. ( SELF:AddOptions:DiskSpanErase )
				oZipFile:MaxOutputSegmentSize := (INT)SELF:MaxVolumeSize
			ENDIF            
			//
			SELF:nSuccessCnt := 0
			TRY
				//
				// This is where the real reading and adding of files is done
				oZipFile:Save()
				// How many segment files ?
				SELF:nDiskNr := oZipFile:NumberOfSegmentsForMostRecentSave 
				SELF:nSuccessCnt := SELF:aFilesArgs:Count
			CATCH Err AS Exception
				// Handle here trouble with Save operation
				THROW Err
			FINALLY
				IF oZipFile != NULL
					oZipFile:Dispose()
				ENDIF
			END TRY
			//Now, that the file is closed, we can handle MultiPart Zip Files
			IF ( ( SELF:AddOptions:DiskSpan .OR. SELF:AddOptions:DiskSpanErase ) )
				// Write the temp zipfile to the right target
				IF ( SELF:HandleMultiPart( TmpZipName, SELF:FileName ) <> 0 )
					// Error Occured during Write Span
					SELF:nFilesDone := 0
				ENDIF
				// Ok, delete the temp file...??? It should be Done in WriteSpan...
				File.Delete( TmpZipName )
			ELSE
				// Single Part file : The final FileName is the temp one
				SELF:FileName := TmpZipName
			ENDIF              
			//
			SELF:aFilesArgs:Clear()
			// 
			SELF:lProcessing := FALSE
			//
			SELF:UpdateContents()
			//     
			SELF:cLastWrittenFile := SELF:FileName   
			RETURN TRUE
			
		METHOD Delete() AS LOGIC
			LOCAL Cpt AS INT
			LOCAL Max AS INT
			LOCAL cTmp AS STRING
			LOCAL oZipFile AS ZipFile
			//local e as ExtractProgressEventArgs
			//Local ZP as ZipEntry
			//
			SELF:lProcessing := TRUE
			oZipFile := ZipFile.Read( SELF:cZipFile ) 
			// No Multi Thread to Compress
			oZipFile:ParallelDeflateThreshold := -1
			//   
			Max := SELF:aFilesArgs:Count
			SELF:nSuccessCnt := 0
			TRY
				FOR Cpt := 1 TO Max
					cTmp := (STRING)SELF:aFilesArgs[ Cpt -1]
					//
					oZipFile:RemoveEntry( cTmp )
					//
				NEXT
				//
				oZipFile:Save()
				SELF:nSuccessCnt := Max
			CATCH ex AS Exception
				THROW ex
			FINALLY
				oZipFile:Dispose()
			END TRY
			//
			SELF:aFilesArgs:Clear()
			SELF:lProcessing := FALSE
			SELF:UpdateContents()
			//        
			RETURN TRUE            
			
		ACCESS CompressionLevel AS WORD
			RETURN Convert.ToUInt16( SELF:nCompLevel )
			
		ASSIGN CompressionLevel( nSet AS WORD )
			LOCAL enumType AS System.Type
			enumType := typeof( Ionic.Zlib.CompressionLevel )
		///
		SELF:nCompLevel := (Ionic.Zlib.CompressionLevel)Enum.ToObject(enumType, nSet )
		
		ACCESS Password AS STRING
			RETURN SELF:cPassword
		ASSIGN Password( cSet AS STRING )
			SELF:cPassword := cSet
			
		ACCESS ZipComment AS STRING
			RETURN SELF:cZipComment
			
		ACCESS Processing AS LOGIC
			RETURN SELF:lProcessing
			
			
		ACCESS MaxVolumeSize AS DWORD
			// Max SIze of each part of MultiPart Archive
			RETURN SELF:dwMaxVolumeSize
			
		ASSIGN MaxVolumeSize( nSet AS DWORD )
			SELF:dwMaxVolumeSize := nSet
			
		ACCESS MinFreeVolumeSize AS DWORD
			// Doesn't exist anymore
			RETURN SELF:dwMinFreeVolume
			
		ASSIGN MinFreeVolumeSize( nSet AS DWORD )
			// Doesn't exist anymore
			SELF:dwMinFreeVolume := nSet
			
		ACCESS KeepFreeOnDisk1 AS DWORD
			// Doesn't exist anymore
			RETURN SELF:dwKeepFreeOnDisk1
			
		ASSIGN KeepFreeOnDisk1( nSet AS DWORD )
			// Doesn't exist anymore
			SELF:dwKeepFreeOnDisk1 := nSet
			
		ACCESS LastWrittenFile AS STRING
			RETURN SELF:cLastWrittenFile
			
		ACCESS UnAttended AS LOGIC
			RETURN FALSE
			
		ASSIGN UnAttended( lSet AS LOGIC )
			RETURN
			
			
		METHOD Convert2SFX() AS LOGIC
			RETURN FALSE
			
		METHOD Convert2Zip() AS LOGIC
			RETURN FALSE
			
		ACCESS TempDir AS STRING
			RETURN SELF:cTempDir
			
		ASSIGN TempDir( cNew AS STRING )
			SELF:cTempDir := cNew
			
		ACCESS Verbose	AS LOGIC
			//r A logical value indicating the state of the Verbose Flag. This one MUST only be used for debugging purpose.
			RETURN	SELF:lVerbose
			
		ASSIGN Verbose( lNew AS LOGIC )
			SELF:lVerbose := lNew
			
		ACCESS ZipDLLVersion AS DWORD
			LOCAL Ver AS System.Version
			LOCAL nRet AS LONG
			//
			Ver := ZipFile.LibraryVersion
			nRet := Ver:Major * 100 + Ver:Minor
			RETURN (DWORD)nRet
			
		ACCESS UnzipDLLVersion AS DWORD
			RETURN SELF:ZipDLLVersion
			
		PROTECT METHOD HandleMultiPart( InFileName AS STRING, OutFileName AS STRING ) AS INT
			//TODO Copy to Floppy...Or Not : Need to add an Option for that
			//read a Zip source file and write it back to one or more disks
			// The InFileName is the temp file, must be something like ZIPXXXXX.ZYY
			// and in nDiskNr we have the number of Segments, including the Zip file
			// OutFileName is the desired file
			//
			LOCAL TempInFile AS STRING
			LOCAL TempOutFile AS STRING
			LOCAL ExtFile AS STRING
			LOCAL nCurrent AS LONG
			//
			// We have ZIPxxx.Z01, ZIPxxx.Z02, .... ZIPxxx.ZIP
			// We want MyName.Z01, MyName.Z02, .... MyName.ZIP
			FOR nCurrent := 1 TO SELF:nDiskNr
				//
				IF ( nCurrent == 1 )
					// Exception, the first is ZIPxxx.ZIP
					TempInFile := InFileName
					ExtFile := ".zip"
				ELSE
					// Get the Path + Name
					TempInFile := FabExtractFilePath( InFileName )+ FabExtractFileName( InFileName )
					// and recreate the extension
					ExtFile := ".z" + StrZero( nCurrent - 1, 2 )
					//
					TempInFile := TempInFile + ExtFile
				ENDIF
				// This is the Destination file
				TempOutFile := FabExtractFilePath( OutFileName )+ FabExtractFileName( OutFileName )
				// The Extension is still the same as the original one
				TempOutFile := TempOutFile + ExtFile
				// TODO Format and Copy to Floppy
				// Now, we must copy the file
				File.Copy( TempInFile, TempOutFile, TRUE )
				// And don't forget to Delete the TempFile
				File.Delete( TempInFile )
			NEXT
			RETURN 0
			
			
		ACCESS Encryption AS Ionic.Zip.EncryptionAlgorithm
			RETURN SELF:HowToEncrypt
		ASSIGN Encryption ( How AS Ionic.Zip.EncryptionAlgorithm )
			SELF:HowToEncrypt := How
			
	END CLASS
	
END NAMESPACE // FabZip
