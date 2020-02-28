// FabZipDirEntry.prg
#using Ionic.zip

BEGIN NAMESPACE FabZip

CLASS FabZipDirEntry

    Protect ZipEntryData as ZipEntry

   CONSTRUCTOR( InternalData as ZipEntry )
      Self:ZipEntryData := InternalData
      RETURN
      
        
    Access @@DateTime as Int64
        return ZipEntryData:LastModified:ToFileTimeUTC()
        
    Access Attributes as String
        // 
        local cAttr as string
        cAttr := ""
        //
        if ( Self:ZipEntryData:Attributes == System.IO.FileAttributes.ReadOnly )
            cAttr += "R"
        endif
        if ( Self:ZipEntryData:Attributes == System.IO.FileAttributes.Hidden)
            cAttr += "H"
        endif
        if ( Self:ZipEntryData:Attributes == System.IO.FileAttributes.System)
            cAttr += "S"
        endif
        if ( Self:ZipEntryData:Attributes == System.IO.FileAttributes.Archive)
            cAttr += "A"
        endif
        return cAttr
        
    Access CompressedSize as Int64
        Return ZipEntryData:CompressedSize
        
    Access CompressionMethod as Short
        Local cm as CompressionMethod
        Local value as Short
        //
        cm := ZipEntryData:CompressionMethod
        If ( cm == CompressionMethod.Deflate )
            value := 8
        Else
            value := 0
        EndIf
        Return value
        
    Access Crc32 as int
        return ZipEntryData:Crc
        
    Access Crypted as logic
        return ZipEntryData:UsesEncryption
    
    ACCESS ExtraFieldLength as word
    // TODO Dummy ExtraFieldLength as word
    return 0
        
    Access FileNameLength as int
        Return ZipEntryData:FileName:Length
        
    ACCESS	Flag as word
    // TODO Dummy Flag as word
    return 0

    Access FileName as String
        return ZipEntryData:FileName
        
    Access FileComment as String
        return ZipEntryData:Comment

    Access FileTime as String
        Local Tmp as DateTime
        //
        Tmp := ZipEntryData:LastModified
        return Tmp:TimeOfDay:ToString()
        
    Access FileDate as Date
        Local Tmp as DateTime
        local VoDate as Date
        //
        Tmp := ZipEntryData:LastModified
        VoDate := CToD( Tmp:@@Date:ToString() )
        return VoDate

    ACCESS IntFileAttrib as word
    // TODO Dummy IntFileAttrib as word
    RETURN 0
    
    ACCESS ExtFileAttrib as dword
    // TODO Dummy ExtFileAttrib as dword
    RETURN 0
    
    
    ACCESS	Version as word
    //TODO This should be the DotNetZip version
        return 1


    ACCESS	Ratio as int
    //r An INT with the Compression Ratio for this file.
    RETURN	Integer( ( 1 - ( SELF:CompressedSize / Max( SELF:UnCompressedSize,1 ) ) ) * 100 )
    
    ACCESS	UncompressedSize as Int64
        Return ZipEntryData:UnCompressedSize

    ACCESS	StartOnDisk	as word
        //TODO No MultiDisk support currently
        return 0



END CLASS

END NAMESPACE // FabZip