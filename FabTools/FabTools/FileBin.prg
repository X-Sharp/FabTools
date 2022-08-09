/*
textblock !Read-Me
/-*
An OOP way to access any "binary" file.
With an auto-close feature using the Axit() method.
*-/



*/
CLASS FabFileBin
	//l Class to access File in a OOP way.
	//g Files, Files Related Classes/Functions
	PROTECT 	oFileSpec		as 	FileSpec
	PROTECT 	ptrFileHandle	as 	ptr		// VO2
	PROTECT		dwErrorCode		as 	DWORD
	PROTECT		liSize			as	LONGINT	//++
	
	DECLARE	METHOD ReadBlock			//( ptrBuffer AS PTR, wBytes AS DWORD )
	DECLARE	METHOD WriteBlock			//( ptrBuffer AS PTR, wBytes AS DWORD )
	DECLARE	METHOD CopyFrom				//( oSrc AS FabFileBin, wCount AS DWORD )
	
	
	
	
	METHOD __GetDateTime( ) as DWORD PASCAL 
		//r Return the date/time stamp of the file as a DWORD value
		LOCAL dwFatDateTime	AS	DWORD
		//
		LOCAL lwt AS DateTime
		lwt := System.IO.File.GetLastWriteTimeUtc( oFileSpec:FullPath )
		dwFatDateTime := (dword)lwt:ToBinary()
		//
		RETURN dwFatDateTime
		
		
		
		
	METHOD __SetDateTime( dwFatDateTime as DWORD ) as LOGIC PASCAL 
		//p Set the date stamp/time of the file as a DWORD value
		//r A logical value indicating the success of the operation
		LOCAL LocalFileTime, FileTime	is	_WINFileTime
		LOCAL wLo		as	word
		LOCAL wHi		as	word
		LOCAL lResult	as	LOGIC
		//
		lResult := FALSE
		wLo := LoWord( dwFatDateTime )
		wHi := HiWord( dwFatDateTime )
		//
		IF self:IsOpen
			IF DosDateTimeToFileTime( wHi, wLo, @LocalFileTime )
				IF LocalFileTimeToFileTime( @LocalFileTime, @FileTime )
					lResult := SetFileTime( self:ptrFileHandle, null_ptr, null_ptr, @FileTime )
				ENDIF
			ENDIF
		ENDIF
		//
		RETURN lResult
		
		
		
		
		
	METHOD __SetDateTime2( wDate as word, wTime as word ) as LOGIC PASCAL 
		//p Set the date/time stamp of the file as two WORD Value
		//r A logical value indicating the success of the operation
		LOCAL dwFatDateTime	as	DWORD
		//
		dwFatDateTime := MAKEWPARAM( wTime, wDate )
		//
		RETURN self:__SetDateTime( dwFatDateTime )
		
		
		
		
	PROTECT METHOD __UpdateError() as DWORD PASCAL 
		//
		self:dwErrorCode := FError()
		//
		RETURN self:dwErrorCode
		
		
		
		
	PROTECT METHOD __UpdateSize() as USUAL PASCAL 
		LOCAL liCurrent	as	LONGINT
		//
		liCurrent := self:Position
		//
		self:liSize := self:GoBottom()
		//
		self:Goto( liCurrent )
		//
		RETURN	self:liSize
		
		
		
		
	DESTRUCTOR() 
		//p Close() the file when FabFileBin object is destroyed if it's still open.
		IF self:IsOpen
			FClose( self:FileHandle )
		ENDIF
		
		
		
	METHOD Close() as DWORD PASCAL 
		//p Close() the file if it's still open.
		//r The ErrorCode of the last operation. ( 0 means no error )
		IF self:IsOpen
			FClose( self:FileHandle )
			self:ptrFileHandle := F_ERROR
			self:liSize := 0
			//		IF !InCollect()
			//			UnRegisterAxit( self )
			//		ENDIF
		ENDIF
		RETURN self:__UpdateError()
		
		
		
		
	METHOD Commit() as DWORD PASCAL 
		//p Flush file buffers.
		//d Commit() writes to a file the contents of its buffers.
		//r The ErrorCode of the last operation. ( 0 means no error )
		IF self:IsOpen
			FCommit( self:FileHandle )	
			self:__UpdateError()
		ELSE
			self:dwErrorCode := (DWORD)ERROR_INVALID_HANDLE	// Invalid Handle
		ENDIF
		RETURN self:ErrorCode
		
		
		
		
	METHOD CopyFrom( oSrc as FabFileBin, wCount as DWORD ) as DWORD PASCAL 
		//p Copy a specified amount of bytes from a Source file
		//r The number of bytes that could not be written
		LOCAL wRemain	as	DWORD
		LOCAL ptrBuffer	as	ptr
		LOCAL wRead		as	DWORD
		//
		wRemain := wCount
		IF oSrc:IsOpen
			//
			ptrBuffer := MemAlloc( 32000 )
			DO WHILE !oSrc:Eof  .and. ( wRemain > 0 )
				// How many to read ?
				wRead := Min( 32000, wRemain )
				// Read block
				wRead := oSrc:ReadBlock( ptrBuffer, wRead )
				// Write Block ( the read size )
				IF ( self:WriteBlock( ptrBuffer, wRead ) != wRead )
					exit
				ENDIF
				// How many remaining ?
				wRemain := wRemain - wRead
			ENDDO
			MemFree( ptrBuffer )
		ENDIF
		// How many written ?
		RETURN ( wCount - wRemain )
		
		
		
		
	METHOD Create( kAttributes ) 
		//p Create a file or open and truncate an existing file.
		//d Create() is a low-level file function that either creates a new file or opens an existing file and truncates it to 0 length.
		//d   If <cFileName> does not exist, it is created and opened for writing.  If it does exist and can be opened for writing, it is truncated to 0 length.
		//x <kAttributes>	One of the following constants indicating the attribute to be set when creating the file:\line
		//x \tab FC_ARCHIVED \tab Archived file\line
		//x \tab FC_HIDDEN \tab Hidden file\line
		//x \tab FC_NORMAL \tab Normal read/write file\line
		//x \tab FC_READONLY \tab Read-only file\line
		//x \tab FC_SYSTEM \tab System file \line
		// Need to close ?
		self:Close()
		// Create the file
		self:ptrFileHandle := FCreate(self:oFileSpec:FullPath, kAttributes)
		self:__UpdateError()
		self:__UpdateSize()
		//
		//	IF self:IsOpen
		//		RegisterAxit( self )
		// 	ENDIF
		RETURN self:FileHandle
		
		
		
		
	ACCESS DateChanged as date PASCAL 
		//r A Date value indicating when the file was created or last changed.  If the file is not found, NULL_DATE is returned.
		LOCAL dDate	:= NULL_DATE AS	DATE
		//
		IF ( self:oFileSpec != null_object )
			dDate := self:oFileSpec:DateChanged
		ENDIF
		RETURN dDate
		
		
		
		
	ASSIGN DateChanged( dNewDate as date ) as date PASCAL 
		//p Set the Date value indicating when the file was created or last changed.
		//d If the file is not found, NULL_DATE is returned.
		LOCAL wDate		as	word
		LOCAL wTime		as	word
		LOCAL lWasOpen	as	LOGIC
		//
		IF ( self:oFileSpec != null_object )
			//
			lWasOpen := self:IsOpen
			IF !lWasOpen
				self:Open( )
			ENDIF
			IF self:IsOpen
				wDate := FabDate2PackedWord( dNewDate )
				wTime := FabTime2PackedWord( self:TimeChanged )
				//
				self:__SetDateTime2( wDate, wTime )
				IF !lWasOpen
					self:Close()
				ENDIF
				//
				dNewDate := self:oFileSpec:DateChanged
			ELSE
				dNewDate := null_date
			ENDIF
		ELSE
			dNewDate := null_date
		ENDIF
		
		
		
		
	METHOD	Destroy() as DWORD PASCAL	
		//p Close the current file
		RETURN	self:Close()
		
		
		
		
	ACCESS Eof as LOGIC PASCAL 
		//p Determine if the file pointer is positioned at the end-of-file.
		LOCAL isEOF	as	LOGIC
		//
		IF self:IsOpen
			isEof := FEof( self:FileHandle )
		ELSE
			isEof := true
			self:dwErrorCode := (DWORD)ERROR_INVALID_HANDLE	// Invalid Handle
		ENDIF
		RETURN ( isEof )
		
		
		
		
	ACCESS Error as LOGIC PASCAL 
		//p Determine if the last operation has produce an error.
		RETURN ( self:dwErrorCode != 0 )
		
		
		
		
	ACCESS ErrorCode as DWORD PASCAL 
		//p Get the error code for a file operation.
		RETURN self:dwErrorCode
		
		
		
		
	ACCESS ErrString as STRING PASCAL 
		//p Get the error string for a file operation.
		LOCAL sError as STRING
		// Don't forget to add the new Error Code according to help file
		DO CASE
			CASE self:ErrorCode = 256
				sError := "Disk Full"
			CASE self:ErrorCode = 257
				sError := "EOF was already reached when a read was tried"
			OTHERWISE
				// Standard Error code
				sError := DosErrString(self:ErrorCode)
		ENDCASE
		RETURN sError
		
		
		
		
	ACCESS Exist as LOGIC PASCAL 
		//p Check if a file eixst
		//r A logical value indicating the result of the File() function
		RETURN self:oFileSpec:Find()
		
		
		
		
	ACCESS FileHandle as ptr PASCAL 
		//p Get the File Handle.
		RETURN self:ptrFileHandle
		
		
		
		
	ACCESS FileSpec as FileSpec PASCAL 
		//p Get the FileSpec for the FabFileBin object
		RETURN self:oFileSpec
		
		
		
		
	METHOD GoBottom() as USUAL PASCAL 
		//p Set the file pointer at the end-of-file.
		//r The position of the file pointer as a longint value after the operation
		LOCAL liPosition as LONGINT
		liPosition  := self:Seek( 0, FS_END )
		RETURN liPosition
		
		
		
		
	METHOD Goto( nOffset as USUAL ) as USUAL PASCAL 
		//p Move the file pointer to a specified position
		//r The position of the file pointer as a longint value after the operation
		LOCAL liPosition as LONGINT
		liPosition := self:Seek( nOffset, FS_SET )
		RETURN  liPosition
		
		
		
		
	METHOD GoTop() as USUAL PASCAL 
		//p Set the file pointer at the begin-of-file.
		//r The position of the file pointer as a longint value after the operation
		LOCAL liPosition as LONGINT
		liPosition := self:Seek( 0, FS_SET )
		RETURN liPosition	
		
		
		
		
	METHOD Handle() as ptr PASCAL 
		//r The Windows Handle of the underlying file.
		RETURN self:ptrFileHandle
		
		
		
		
	CONSTRUCTOR( oFS ) 
		//p Build a FabFileBin object.
		//x <oFS> is a FileSpec or a FullPath String of the file to access.
		//
		DO CASE
			CASE IsInstanceOfUsual( oFS, #FileSpec)			// If a filespec object
				self:oFileSpec :=oFS 			// store the filespec
			CASE UsualType(oFS) == STRING					// If String
				oFS := FileSpec{ oFS }						// Assume it's a String representing file
				self:oFileSpec := oFS						// store the filespec
		ENDCASE
		//
		self:dwErrorCode := 0
		self:ptrFileHandle := F_ERROR
		//
		
		
		
		
	ACCESS IsOpen as LOGIC PASCAL 
		//r A logical value indicating if the file is open.
		RETURN ( self:ptrFileHandle != F_ERROR )
		
		
		
		
	METHOD Open( kMode := 0 as DWORD  ) as ptr PASCAL 
		//p Open a File
		//x <kMode>	The DOS open mode, which determines the accessibility of the file.
		//x  The open mode is composed of elements from the two types of modes: Access mode + Sharing mode.
		//x  Specifying an access mode constant indicates how the opened file is to be accessed;
		//x the sharing mode determines how other processes can access the file.
		// Need to close ?
		self:Close()
		// Open the file
		self:ptrFileHandle := FOpen2( self:oFileSpec:FullPath, kMode )
		self:__UpdateError()
		self:__UpdateSize()
		//
		//	IF self:IsOpen
		//		RegisterAxit( self )
		// 	ENDIF
		RETURN self:FileHandle
		
		
		
		
	ACCESS Position as LONG PASCAL 
		//r The current position of the file pointer as a longint value
		RETURN self:Tell()
		
		
		
		
	ASSIGN Position( liNew as LONG ) as LONG PASCAL 
		//r The Current File pointer position
		SELF:Seek( liNew, FS_SET )
		
		
	METHOD Read( sBuffer, wBytes ) 
		//p Read a specified number of bytes
		//r The number of bytes read
		//x <cBuffer> is a String buffer passed by reference ( with the @ operator )\line
		//x <wBytes> is the max of bytes to read If Nil, Slen( sBuffer ) is used, and if 0, 2048 is used
		LOCAL cTemp	as	STRING
		//
		IF self:IsOpen
			IF IsNil( wBytes )
				wBytes := SLen( sBuffer )
				IF ( wBytes == 0 )
					wBytes := 2048
				ENDIF
			ENDIF
			wBytes := FRead(self:FileHandle, @cTemp, wBytes)
			sBuffer := SubStr( cTemp, 1, wBytes )
			self:__UpdateError()
		ELSE
			self:dwErrorCode := (DWORD)ERROR_INVALID_HANDLE	// Invalid Handle
			wBytes := 0
		ENDIF
		RETURN wBytes
		
		
		
		
	METHOD ReadBlock( ptrBuffer as ptr, wBytes as DWORD ) as DWORD PASCAL 
		//p Copy a block of bytes from file to memory
		//r The number of bytes read
		IF self:IsOpen
			IF ( wBytes == 0 )
				RETURN 0
			ENDIF
			wBytes := FRead3( self:FileHandle, ptrBuffer, wBytes)
			self:__UpdateError()
		ELSE
			self:dwErrorCode := (DWORD)ERROR_INVALID_HANDLE	// Invalid Handle
			wBytes := 0
		ENDIF
		RETURN wBytes
		
		
		
		
	METHOD ReadBuffer( ptrBuffer as ptr, wBytes as DWORD ) as DWORD PASCAL 
		//p Read a specified number of bytes
		//r The number of bytes read
		//x <cBuffer> is a pointer to the destination memory\line
		//x <wBytes> is the max of bytes to read
		//r The number of bytes read
		IF self:IsOpen
			wBytes := FRead3( self:FileHandle, ptrBuffer, wBytes)
			self:__UpdateError()
		ELSE
			self:dwErrorCode := (DWORD)ERROR_INVALID_HANDLE	// Invalid Handle
			wBytes := 0
		ENDIF
		RETURN wBytes
		
		
		
		
	METHOD ReadByte( ) as byte PASCAL 
		//p Read a BYTE at the current position
		LOCAL sString as STRING
		//
		sString := self:ReadStr( 1 )
		//
		RETURN	Byte(Asc( sString ))
		
		
		
		
	METHOD ReadDWord( ) as DWORD PASCAL 
		//p Read a DWORD at the current position
		LOCAL sString as STRING
		//
		sString := self:ReadStr( _sizeof( DWORD ) )
		//
		RETURN	Bin2DW( sString )
		
		
		
		
	METHOD 	ReadLine( nMax := 256 as DWORD ) as STRING PASCAL 
		//p Read bytes until a CRLF sequence.
		//x <nMax> indicate the max number of chars in a line if no CRLF is found
		//r The line read
		LOCAL cString as STRING
		//
		IF self:IsOpen
			cString := FReadLine( self:FileHandle, nMax)
			self:__UpdateError()
		ELSE
			self:dwErrorCode := (DWORD)ERROR_INVALID_HANDLE	// Invalid Handle
		ENDIF
		RETURN cString
		
		
		
		
	METHOD ReadLong( ) as LONG PASCAL 
		//p Read a LONG at the current position
		LOCAL sString as STRING
		//
		sString := self:ReadStr( _sizeof( LONGINT ) )
		//
		RETURN	Bin2L( sString )
		
		
		
		
	METHOD ReadShort( ) as SHORT PASCAL 
		//p Read a SHORT at the current position
		LOCAL sString as STRING
		//
		sString := self:ReadStr( _sizeof( SHORTINT ) )
		//
		RETURN	Bin2I( sString )
		
		
		
		
	METHOD ReadStr( wBytes as DWORD ) as STRING PASCAL 
		//p Read a String with <wBytes> max.
		//r The String read
		LOCAL cString as STRING
		IF self:IsOpen
			cString := FReadStr( self:FileHandle, wBytes )
			self:__UpdateError()
		ELSE
			self:dwErrorCode := (DWORD)ERROR_INVALID_HANDLE	// Invalid Handle		
		ENDIF
		RETURN cString
		
		
		
		
	METHOD ReadText( cBufferByRef as STRING, wBytes as DWORD) as DWORD PASCAL 
		//p Read a specified number of bytes
		//r The number of bytes read
		//x <cBufferByRef> is a String buffer passed by reference ( with the @ operator )\line
		//x <wBytes> is the max of bytes to read
		IF self:IsOpen
			wBytes := FReadText(self:FileHandle, @cBufferByRef, wBytes)
			self:__UpdateError()
		ELSE
			self:dwErrorCode := (DWORD)ERROR_INVALID_HANDLE	// Invalid Handle
			wBytes := 0
		ENDIF
		RETURN wBytes
		
		
		
		
	METHOD ReadWord( ) as word PASCAL 
		//p Read a WORD at the current position
		LOCAL sString as STRING
		//
		sString := self:ReadStr( _sizeof( word ) )
		//
		RETURN	Bin2W( sString )
		
		
		
		
	METHOD Rewind() as void PASCAL 
		//p Move File pointer to Top of file
		IF self:IsOpen
			FRewind( self:FileHandle )
			self:__UpdateError()
		ELSE
			self:dwErrorCode := (DWORD)ERROR_INVALID_HANDLE	// Invalid Handle
		ENDIF
		
		return
		
		
	METHOD Seek( nOffset as USUAL, nOrigin as DWORD ) as USUAL PASCAL 
		//p Move the File pointer to a specified position
		//x <nOffset>	The number of bytes to move the file pointer, from the position defined by <nOrigin>.  It can be a positive or negative number.  A positive number moves the pointer forward in the file, and a negative number moves the pointer backward.  If <nOrigin> is the end-of-file, <nOffset> must be 0 or negative.\line
		//x <nOrigin>	One of the following constants indicating the starting location of the file pointer, telling where to start searching the file
		LOCAL liPosition := 0 AS LONGINT
		IF self:IsOpen
			liPosition := FSeek3( self:FileHandle, nOffset, nOrigin)
			self:__UpdateError()
		ELSE
			self:dwErrorCode := (DWORD)ERROR_INVALID_HANDLE	// Invalid Handle
		ENDIF
		RETURN  liPosition
		
		
		
		
	ACCESS	Size as USUAL PASCAL	
		//r The Size of File
		RETURN self:liSize
		
		
		
		
	METHOD Tell()as USUAL PASCAL 
		//r The current file pointer position
		LOCAL liPos := 0 as	LONGINT
		//
		IF self:IsOpen
			liPos := (long)FTell(self:FileHandle)
		ELSE
			self:dwErrorCode := (DWORD)ERROR_INVALID_HANDLE	// Invalid Handle
		ENDIF
		RETURN liPos
		
		
		
		
	ACCESS TimeChanged as STRING PASCAL 
		LOCAL cTime	as	STRING
		//
		IF ( self:oFileSpec != null_object )
			cTime := self:oFileSpec:TimeChanged
		ENDIF
		RETURN cTime
		
		
		
		
	ASSIGN TimeChanged( cNewTime as STRING ) as STRING PASCAL 
		//p Set the Time value indicating when the file was created or last changed.
		//d If the file is not found, NULL_STRING is returned.
		LOCAL wDate	as	word
		LOCAL wTime	as	word
		LOCAL lWasOpen	as	LOGIC
		//
		IF ( self:oFileSpec != null_object )
			//
			lWasOpen := self:IsOpen
			IF !lWasOpen
				self:Open( )
			ENDIF
			IF self:IsOpen
				wDate := FabDate2PackedWord( self:DateChanged )
				wTime := FabTime2PackedWord( cNewTime )
				//
				self:__SetDateTime2( wDate, wTime )
				IF !lWasOpen
					self:Close()
				ENDIF
				//
				cNewTime := self:oFileSpec:TimeChanged
			ELSE
				cNewTime := null_string
			ENDIF
		ENDIF
		
		
	METHOD Write( sBuffer, wBytes ) 
		//p Write a buffer
		//x <sBuffer> is the String to write\line
		//x <wBytes> is the number of bytes to write. ( SLen( sBuffer ) per default )
		//r The number of bytes written
		//
		IF self:IsOpen
			IF IsNil( wBytes )
				wBytes := SLen( sBuffer )
			ENDIF
			wBytes := FWrite(self:FileHandle, sBuffer, wBytes)
			self:__UpdateError()
			self:__UpdateSize()
		ELSE
			self:dwErrorCode := (DWORD)ERROR_INVALID_HANDLE	// Invalid Handle
			wBYtes := 0
		ENDIF
		RETURN wBytes
		
		
		
		
	METHOD WriteBlock( ptrBuffer as ptr, wBytes as DWORD ) as DWORD PASCAL 
		//p Write a buffer
		//x <ptrBuffer> is a pointer to the memory to write\line
		//x <wBytes> is the number of bytes to write.
		//r The number of bytes written
		IF self:IsOpen
			IF ( wBytes == 0 )
				RETURN 0
			ENDIF
			wBytes := FWrite3( self:FileHandle, ptrBuffer, wBytes)
			self:__UpdateError()
			self:__UpdateSize()
		ELSE
			self:dwErrorCode := (DWORD)ERROR_INVALID_HANDLE	// Invalid Handle
			wBYtes := 0
		ENDIF
		RETURN wBytes
		
		
		
		
	METHOD WriteBuffer( ptrBuffer as ptr, wBytes as DWORD ) as DWORD PASCAL 
		//p Write a specified number of bytes
		//r The number of bytes read
		//x <cBuffer> is a pointer to the Source memory\line
		//x <wBytes> is the max of bytes to read
		//r The number of bytes written
		IF self:IsOpen
			wBytes := FWrite3( self:FileHandle, ptrBuffer, wBytes)
			self:__UpdateError()
			self:__UpdateSize()
		ELSE
			self:dwErrorCode := (DWORD)ERROR_INVALID_HANDLE	// Invalid Handle
			wBYtes := 0
		ENDIF
		RETURN wBytes
		
		
		
		
	METHOD WriteLine( sBuffer, wBytes ) 
		//p Write a buffer, and add a CRLF at the end
		//x <sBuffer> is the String to write\line
		//x <wBytes> is the number of bytes to write. ( SLen( sBuffer ) per default )
		//r The number of bytes written
		IF self:IsOpen
			IF IsNil( wBytes )
				wBytes := SLen( sBuffer )
			ENDIF
			wBytes := FWriteLine( self:FileHandle, sBuffer, wBytes )
			self:__UpdateError()
			self:__UpdateSize()
		ELSE
			self:dwErrorCode := (DWORD)ERROR_INVALID_HANDLE	// Invalid Handle
			wBYtes := 0
		ENDIF
		RETURN wBytes
		
		
		
		
	METHOD WriteText( sBuffer, wBytes ) 
		//p Write a buffer
		//x <sBuffer> is the String to write\line
		//x <wBytes> is the number of bytes to write. ( SLen( sBuffer ) per default )
		//r The number of bytes written
		IF self:IsOpen
			IF IsNil( wBytes )
				wBytes := SLen( sBuffer )
			ENDIF
			wBytes := FWriteText( self:FileHandle, sBuffer, wBytes )
			self:__UpdateError()
			self:__UpdateSize()
		ELSE
			self:dwErrorCode := (DWORD)ERROR_INVALID_HANDLE	// Invalid Handle
			wBytes := 0
		ENDIF
		RETURN wBytes
		
		
		
		
		
END CLASS
