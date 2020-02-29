// FabZipFileCtrl.prg
#using System.Windows.Forms
#using Ionic.Zip;

BEGIN NAMESPACE FabZip.WinForms

	ENUM FabZipEvent
		MEMBER NewEntry
		MEMBER EndEntry
		MEMBER UpdateEntry
		MEMBER TotalFiles
		MEMBER TotalSize
	END ENUM
	
	CLASS FabZipFileCtrl Inherit UserControl
		
		Protect oZipFile as FabZipFile
		
		PROTECT lStartNew AS LOGIC
		PROTECT nDone	  AS INT64
		
		CONSTRUCTOR()
			Super()
			//
			Self:oZipFile := FabZipFile{ NULL_String , SELF }
			Self:oZipFile:ExtractHandler := EventHandler<ExtractProgressEventArgs>{SELF, @ExtractHandler() }
			SELF:oZipFile:SaveHandler := EventHandler<SaveProgressEventArgs>{ SELF, @SaveHandler() }
			SELF:lStartNew := FALSE
			RETURN
			
		ACCESS ZipFile as FabZipFile
			return SELF:oZipFile
			
		PRIVATE METHOD ExtractHandler( sender AS System.Object, e AS ExtractProgressEventArgs ) AS System.Void
			local zipParams as Object[]
			local symEvent as FabZipEvent
			local cFile as string
			local nSize as int64
			//
			cFile := ""
			nSize := 0
			//
			if ( SELF:Parent != NULL )
				//
				DO CASE
					CASE ( e:EventType == ZipProgressEventType.Extracting_BeforeExtractEntry )
						symEvent := FabZipEvent.NewEntry
						cFile := e:CurrentEntry:FileName
						nSize := e:CurrentEntry:UncompressedSize
					CASE ( e:EventType == ZipProgressEventType.Extracting_AfterExtractEntry )
						symEvent := FabZipEvent.EndEntry
						cFile := ""
						nSize := 0
					CASE ( e:EventType == ZipProgressEventType.Extracting_EntryBytesWritten )
						symEvent := FabZipEvent.UpdateEntry
						cFile := ""
						nSize := e:BytesTransferred
					OTHERWISE
						RETURN
				ENDCASE
				//
				zipParams := <Object>{ self, symEvent, cFile, nSize }
				//
				//Send( Self:Owner, "OnFabZipProgress", Self, symEvent, cFile, nSize )
				ReflectionLib.InvokeMethod( SELF:Parent, "OnFabZipProgress", zipParams )
			endif
			RETURN
		
		PRIVATE METHOD SaveHandler( sender AS System.Object, e AS SaveProgressEventArgs ) AS System.Void
			LOCAL zipParams AS OBJECT[]
			LOCAL symEvent AS SYMBOL
			LOCAL cFile AS STRING
			LOCAL nSize AS INT64
			//
			symEvent := NULL_SYMBOL
			cFile := ""
			nSize := 0
			//
			IF ( SELF:Parent != NULL )
				//
				SWITCH e:EventType
					CASE ZipProgressEventType.Saving_BeforeWriteEntry
						// We will need to send two notifications on first Update
						SELF:lStartNew := TRUE
						//symEvent := #new
						//cFile := e:CurrentEntry:FileName
						//nSize := e:CurrentEntry:UncompressedSize
					CASE ZipProgressEventType.Saving_AfterWriteEntry
						symEvent := #end
						cFile := ""
						nSize := 0
						SELF:lStartNew := FALSE		// UnNeeded
					CASE ZipProgressEventType.Saving_EntryBytesRead
						IF ( SELF:lStartNew )
							//
							symEvent := #new
							cFile := e:CurrentEntry:FileName
							nSize := e:TotalBytesToTransfer
							zipParams := <OBJECT>{ SELF, symEvent, cFile, nSize }
							ReflectionLib.InvokeMethod( SELF:Parent, "OnFabZipProgress", zipParams )
							SELF:lStartNew := FALSE
							SELF:nDone := 0
						ENDIF
						symEvent := #Update
						cFile := ""
						nSize := e:BytesTransferred - SELF:nDone
						SELF:nDone := e:BytesTransferred
					OTHERWISE 
						RETURN
				END SWITCH
				//
				zipParams := <OBJECT>{ SELF, symEvent, cFile, nSize }
				//
				//Send( Self:Owner, "OnFabZipProgress", Self, symEvent, cFile, nSize )
				ReflectionLib.InvokeMethod( SELF:Parent, "OnFabZipProgress", zipParams )
			ENDIF
			RETURN    		
		
		METHOD	OnFabZipDirUpdate(  )  as void
			local zipParams as Object[]
			//
			zipParams := <Object>{ SELF }
			ReflectionLib.InvokeMethod( SELF:Parent, "OnFabZipDirUpdate", zipParams ) 
			//
			return
			
		METHOD OnFabOperationSize( nTotalFiles as Int64, nTotalSize as Int64 ) as VOID
			local zipParams as Object[]
			//
			if ( SELF:Parent != NULL )
				//
				zipParams := <Object>{ Self, FabZipEvent.TotalFiles, "", nTotalFiles }
				ReflectionLib.InvokeMethod( SELF:Parent, "OnFabZipProgress", zipParams )
				//
				zipParams := <Object>{ Self, FabZipEvent.TotalSize, "", nTotalSize }
				ReflectionLib.InvokeMethod( SELF:Parent, "OnFabZipProgress", zipParams )
			ENDIF    
			RETURN        
			
	END CLASS
	
END NAMESPACE // FabZip