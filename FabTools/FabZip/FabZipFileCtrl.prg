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
		
		CONSTRUCTOR()
			Super()
			//
			Self:oZipFile := FabZipFile{ NULL_String , SELF }
			Self:oZipFile:ExtractHandler := EventHandler<ExtractProgressEventArgs>{SELF, @ExtractHandler() }
			RETURN
			
		ACCESS ZipFile as FabZipFile
			return SELF:oZipFile
			
		PRIVATE METHOD ExtractHandler( sender AS System.Object, e AS ExtractProgressEventArgs ) AS System.Void
			local Params as Object[]
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
				Params := <Object>{ self, symEvent, cFile, nSize }
				//
				//Send( Self:Owner, "OnFabZipProgress", Self, symEvent, cFile, nSize )
				ReflectionLib.InvokeMethod( SELF:Parent, "OnFabZipProgress", Params )
			endif
			RETURN
		
		METHOD	OnFabZipDirUpdate(  )  as void
			local Params as Object[]
			//
			Params := <Object>{ SELF }
			ReflectionLib.InvokeMethod( SELF:Parent, "OnFabZipDirUpdate", Params ) 
			//
			return
			
		METHOD OnFabOperationSize( nTotalFiles as Int64, nTotalSize as Int64 ) as VOID
			local Params as Object[]
			//
			if ( SELF:Parent != NULL )
				//
				Params := <Object>{ Self, FabZipEvent.TotalFiles, "", nTotalFiles }
				ReflectionLib.InvokeMethod( SELF:Parent, "OnFabZipProgress", Params )
				//
				Params := <Object>{ Self, FabZipEvent.TotalSize, "", nTotalSize }
				ReflectionLib.InvokeMethod( SELF:Parent, "OnFabZipProgress", Params )
			ENDIF    
			RETURN        
			
	END CLASS
	
END NAMESPACE // FabZip