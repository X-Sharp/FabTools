// Functions.prg
#using Ionic.Zip

// These are functions that populate the Dlls
FUNCTION GetUnzDllVersion() AS DWORD
    Local Ver as System.Version
    Local nRet as long
    //
    Ver := ZipFile.LibraryVersion
    nRet := Ver:Major * 100 + Ver:Minor
return (DWORD)nRet

   
FUNCTION GetZipDllVersion() AS DWORD
    Local Ver as System.Version
    Local nRet as long
    //
    Ver := ZipFile.LibraryVersion
    nRet := Ver:Major * 100 + Ver:Minor
return (DWORD)nRet 