// FabZipFileCtrl.prg

USING VO
USING Ionic.Zip


BEGIN NAMESPACE FabZip

	CLASS FabZipFileCtrl INHERIT FixedText
	
		PROTECT oZipFile AS FabZipFile
		
		CONSTRUCTOR(oOwner, xID, oPoint, oDimension, cText) 
			// Call Super
			SUPER(oOwner, xID, oPoint, oDimension, cText)
			//
			SELF:oZipFile := FabZipFile{ NULL_STRING , SELF }
			SELF:oZipFile:ExtractHandler := EventHandler<ExtractProgressEventArgs>{SELF, @ExtractHandler() }
			SELF:oZipFile:SaveHandler := EventHandler<SaveProgressEventArgs>{ SELF, @SaveHandler() }
			//
			SELF:Hide()
			RETURN
			
		ACCESS ZipFile AS FabZipFile
			RETURN SELF:oZipFile
			
		PRIVATE METHOD ExtractHandler( sender AS System.Object, e AS ExtractProgressEventArgs ) AS System.Void
			//local Params as Usual[]
			LOCAL symEvent AS SYMBOL
			LOCAL cFile AS STRING
			LOCAL nSize AS INT64
			//
			symEvent := NULL_SYMBOL
			cFile := ""
			nSize := 0
			//
			IF ( SELF:Owner != NULL )
				//
				SWITCH e:EventType
					CASE ZipProgressEventType.Extracting_BeforeExtractEntry
						symEvent := #new
						cFile := e:CurrentEntry:FileName
						nSize := e:CurrentEntry:UncompressedSize
					CASE ZipProgressEventType.Extracting_AfterExtractEntry
						symEvent := #end
						cFile := ""
						nSize := 0
					CASE ZipProgressEventType.Extracting_EntryBytesWritten
						symEvent := #Update
						cFile := ""
						nSize := e:BytesTransferred
					OTHERWISE
						RETURN
				END SWITCH
				//
				//Params := <Usual>{ self, symEvent, cFile, nSize }
				//
				Send( SELF:Owner, "OnFabZipProgress", SELF, symEvent, cFile, nSize )
				//ReflectionLib.InvokeMethod( SELF:Owner, "OnFabZipProgress", Params )
			ENDIF
			RETURN
			
		PRIVATE METHOD SaveHandler( sender AS System.Object, e AS SaveProgressEventArgs ) AS System.Void
			LOCAL Params AS OBJECT[]
			LOCAL symEvent AS SYMBOL
			LOCAL cFile AS STRING
			LOCAL nSize AS INT64
			//
			symEvent := NULL_SYMBOL
			cFile := ""
			nSize := 0
			//
			IF ( SELF:Owner != NULL )
				//
				SWITCH e:EventType
					CASE ZipProgressEventType.Saving_BeforeWriteEntry
						symEvent := #new
						cFile := e:CurrentEntry:FileName
						nSize := e:CurrentEntry:UncompressedSize
					CASE ZipProgressEventType.Saving_AfterWriteEntry
						symEvent := #end
						cFile := ""
						nSize := 0
					CASE ZipProgressEventType.Saving_EntryBytesRead
						symEvent := #Update
						cFile := ""
						nSize := e:BytesTransferred
					OTHERWISE 
						RETURN
				END SWITCH
				//
				PARAMS := <OBJECT>{ SELF, symEvent, cFile, nSize }
				//
				//Send( Self:Owner, "OnFabZipProgress", Self, symEvent, cFile, nSize )
				ReflectionLib.InvokeMethod( SELF:Owner, "OnFabZipProgress", PARAMS )
			ENDIF
			RETURN    
		
		METHOD OnFabOperationSize( nTotalFiles AS INT64, nTotalSize AS INT64 ) AS VOID
			//
			IF ( SELF:Owner != NULL )
				//
				Send( SELF:Owner, "OnFSWITCHrogress", SELF, #TotalFiles, "", nTotalFiles )
				//
				Send( SELF:Owner, "OnFabZipProgress", SELF, #TotalSize, "", nTotalSize )
			ENDIF    
			RETURN
			
		METHOD	OnFabZipDirUpdate(  )  AS VOID
			LOCAL Params AS OBJECT[]
			//
			PARAMS := <OBJECT>{ SELF }
			ReflectionLib.InvokeMethod( SELF:Owner, "OnFabZipDirUpdate", PARAMS ) 
			//
			RETURN
			
			
	END CLASS
	
END NAMESPACE // FabZip
