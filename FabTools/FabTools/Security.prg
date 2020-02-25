FUNCTION FabDisablePrivilege( cPrivilege AS STRING ) AS LOGIC
//g System,System Functions
//l Disable a Security privilege
//p Disable a Security privilege
//a <cPrivilege> is a string with the name of the privilege to disable.
//d This function will disable a security privilege for the current process.
//d Look at AdjustTokenPrivileges() in the Win32 SDK for more info.
//r A logical value indicating if operation has been successfull.
//e // Disable ShutDown privilege
//e ? FabDisablePrivilege( SE_SHUTDOWN_NAME )
//e // Disable the SystemTime privilege
//e ? FabDisablePrivilege( SE_SYSTEMTIME_NAME )

	LOCAL lRet		AS	LOGIC
	LOCAL ptrVI		IS	_winOSVERSIONINFO
	LOCAL hToken	AS	PTR
	LOCAL ptrTP		IS	_winTOKEN_PRIVILEGES
	//
	lRet := FALSE
	ptrVI.dwOSVersionInfoSize := _Sizeof( _winOSVERSIONINFO )
	GetVersionEx( @ptrVI )
	//
	IF ( ptrVI.dwPlatformId == (DWORD)VER_PLATFORM_WIN32_NT )
		// With NT, we MUST set the Application privilege
		// open access privilege list.
		IF OpenProcessToken( GetCurrentProcess(), _or( TOKEN_ADJUST_PRIVILEGES, TOKEN_QUERY ), @hToken )
			ptrTP.PrivilegeCount := 1
			// Ask for the privilege LUID
			LookupPrivilegeValue( NULL_PSZ, String2Psz( cPrivilege ), @ptrTP.Privileges[1].Luid )
			// Enable it
			ptrTP.Privileges[1].Attributes := 0
			AdjustTokenPrivileges( hToken, FALSE, @ptrTP, 0, NULL_PTR, NULL_PTR )
			lRet := ( GetLastError () == (DWORD)ERROR_SUCCESS )
		ENDIF
	ELSE
    	lRet := TRUE
    ENDIF
	//
RETURN lRet



FUNCTION FabEnablePrivilege( cPrivilege AS STRING ) AS LOGIC
//g System,System Functions
//l Enable a Security privilege
//p Enable a Security privilege
//a <cPrivilege> is a string with the name of the privilege to enable.
//d This function will Enable a security privilege for the current process.
//d Look at AdjustTokenPrivileges() in the Win32 SDK for more info.
//r A logical value indicating if operation has been successfull.
//e // Enable ShutDown privilege
//e ? FabEnablePrivilege( SE_SHUTDOWN_NAME )
//e // Enable the SystemTime privilege
//e ? FabEnablePrivilege( SE_SYSTEMTIME_NAME )

	LOCAL lRet		AS	LOGIC
	LOCAL ptrVI		IS	_winOSVERSIONINFO
	LOCAL hToken	AS	PTR
	LOCAL ptrTP		IS	_winTOKEN_PRIVILEGES
	//
	lRet := FALSE
	ptrVI.dwOSVersionInfoSize := _Sizeof( _winOSVERSIONINFO )
	GetVersionEx( @ptrVI )
	//
	IF ( ptrVI.dwPlatformId == (DWORD)VER_PLATFORM_WIN32_NT )
		// With NT, we MUST set the Application privilege
		// open access privilege list.
		IF OpenProcessToken( GetCurrentProcess(), _or( TOKEN_ADJUST_PRIVILEGES, TOKEN_QUERY ), @hToken )
			ptrTP.PrivilegeCount := 1
			// Ask for the privilege LUID
			LookupPrivilegeValue( NULL_PSZ, String2Psz( cPrivilege ), @ptrTP.Privileges[1].Luid )
			// Enable it
			ptrTP.Privileges[1].Attributes := (DWORD)SE_PRIVILEGE_ENABLED
			AdjustTokenPrivileges( hToken, FALSE, @ptrTP, 0, NULL_PTR, NULL_PTR )
			lRet := ( GetLastError () == (DWORD)ERROR_SUCCESS )
		ENDIF
	ELSE
    	lRet := TRUE
    ENDIF
	//
RETURN lRet





