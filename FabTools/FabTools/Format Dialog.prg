#region DEFINES
DEFINE SHFMT_CANCEL    := 0xFFFFFFFEL    // Last format wascanceled
DEFINE SHFMT_ERROR     := 0xFFFFFFFFL    // Error on last format,
// drive may be formatable
DEFINE SHFMT_ID_DEFAULT   := 0xFFFF
DEFINE SHFMT_NOFORMAT  := 0xFFFFFFFDL    // Drive is not formatable
DEFINE SHFMT_OPT_FULL     := 0x0001
DEFINE SHFMT_OPT_QUICK    := 0x0000
DEFINE SHFMT_OPT_SYSONLY  := 0x0002
#endregion

CLASS	FabFormatDialog
	//g Drives,Drives related Classes/Functions
	//l Access to Drive Format Dialog
	//d This class provide a way to access the standard Shell Drive-Format Dialog from within your application.
	
	// Handle of Owner
	PROTECT hWnd		AS	PTR
	// Last Return Code
	PROTECT dwRet		AS	DWORD
	//s
	// Drive Letter
	EXPORT 	Drive		AS	STRING
	// Quick Format
	EXPORT	QuickFormat	AS	LOGIC
	// Add System Files
	EXPORT	System		AS	LOGIC
	
	
	
	
	METHOD	Init( oOwner, cDrive )	
		//d Create a FabFormatDialog Object.\line
		//d You must pass a Owner, or the method will try to determine what is the current active window, and set it as Owner.
		//a <oOwner> is a Window that owns the FormatDialog.
		//a <cDrive> is a string, indicating what drive to format
		//a 	You can specify "A", "A:", "A:\", ...
		//
		IF Empty( oOwner )
			SELF:hWnd := GetActiveWindow()
		ELSE
			IF IsMethod( oOwner, #Handle )
				SELF:hWnd := Send( oOwner, #Handle )
			ELSE
				SELF:hWnd := GetActiveWindow()
			ENDIF
		ENDIF
		//
		IF IsString( cDrive )
			SELF:Drive := cDrive
		ELSE
			// Floppy per default
			SELF:Drive := "A"		// You can specify "A", "A:", "A:\", ...
		ENDIF
		//
		
		
		RETURN self
		
		
	ACCESS LastReturnCode 
		//r The Last Return Code
		RETURN SELF:dwRet
		
		
		
		
	METHOD	Show()			
		//p Show the Format Dialog.
		//r A Logical indicating if the last format as been successfull
		LOCAL aDrives	AS	ARRAY
		LOCAL aDrv		AS	ARRAY
		LOCAL cDrv		AS	STRING
		LOCAL wCpt		AS	WORD
		LOCAL lResult	AS	LOGIC
		LOCAL liAction	AS	LONGINT
		//
		aDrives := FabGetlogicalDrivesArray( )
		cDrv := Upper( Left( SELF:Drive, 1 ) )
		//
		IF Empty( cDrv )
			RETURN FALSE
		ENDIF
		// Cannot format
		lResult := FALSE
		FOR wCpt := 1 TO ALen( aDrives )
			//
			aDrv := aDrives[ wCpt ]
			//
			IF ( Upper( Left( aDrv[ 1 ], 1 ) ) == cDrv )
				// Check Drive type
				IF 	( aDrv[ 2 ] == DRIVE_REMOVABLE )	 .or.	;
					( aDrv[ 2 ] == DRIVE_FIXED )
					// Can be formatted
					lResult := TRUE
					EXIT
				ENDIF
			ENDIF
		NEXT
		// Cannot format or not found
		IF !lResult
			RETURN FALSE
		ENDIF
		// Default Action : Normal Formatting
		liAction := SHFMT_OPT_FULL
		// Action code
		IF SELF:QuickFormat
			liAction := SHFMT_OPT_QUICK
		ELSE
			IF SELF:System
				liAction := SHFMT_OPT_SYSONLY
			ENDIF
		ENDIF
		//
		self:dwRet := SHFormatDrive( self:hWnd, longint( Asc( cDrv ) - Asc( "A" ) ), 0, liAction )
		//
		RETURN SELF:Success
		
		
		
		
	ACCESS Success 
		//r A logical value indicating if the last Format has been successfull
		LOCAL lSuccess	AS	LOGIC
		//
		lSuccess := ( SELF:dwRet != DWORD(_CAST, SHFMT_ERROR ) )  .and. ;
		( SELF:dwRet != DWORD(_CAST, SHFMT_CANCEL ) )  .and. ;
		( SELF:dwRet != DWORD(_CAST, SHFMT_NOFORMAT ) )
		IF lSuccess
			// Check for HiWord of dwRet
			lSuccess := ( HiWord( SELF:dwRet ) == 0 )
		ENDIF
		RETURN lSuccess
		
		
	
END CLASS


_DLL FUNCTION SHFormatDrive ( hwnd AS PTR, drive AS LONGINT, size AS DWORD, action AS LONGINT ) AS DWORD PASCAL:SHELL32.SHFormatDrive
//
// hwnd : the handle of the owner-window for the format-dialog
// drive : 0=a, 1=b ...
// size : ? seems not to be implemented
// action :
//            0 : quick - format (destroys only the fat)
//            1 : normal formatting
//            2 : "sys x:"
// result : the result should be 0 if the function was successfull, but it seems that
//          error # 6 (= error_invalid_handle) is returned on success


/*
The SHFormatDrive API provides access to the Shell's format
dialog box. This allows applications that want to format disks to bring
up the same dialog box that the Shell uses for disk formatting.

PARAMETERS
hwnd    = The window handle of the window that will own the
dialog. NOTE that hwnd == NULL does not cause this
dialog to come up as a "top level application"
window. This parameter should always be non-null,
this dialog box is only designed to be the child of
another window, not a stand-alone application.

drive   = The 0 based (A: == 0) drive number of the drive
to format.

fmtID   = Currently must be set to SHFMT_ID_DEFAULT.

options = There are currently only two option bits defined.

SHFMT_OPT_FULL
SHFMT_OPT_SYSONLY

SHFMT_OPT_FULL specifies that the "Quick Format"
setting should be cleared by default. If the user
leaves the "Quick Format" setting cleared, then a
full format will be applied (this is useful for
users that detect "unformatted" disks and want
to bring up the format dialog box).

If options is set to zero (0), then the "Quick
Format" setting will be set by default. In addition,
if the user leaves it set, a quick format will be
performed.

The SHFMT_OPT_SYSONLY initializes the dialog to
default to just sys the disk.

All other bits are reserved for future expansion
and must be 0.

Please note that this is a bit field and not a
value, treat it accordingly.

RETURN
The return is either one of the SHFMT_* values, or if
the returned DWORD value is not == to one of these
values, then the return is the physical format ID of the
last successful format. The LOWORD of this value can be
passed on subsequent calls as the fmtID parameter to
"format the same type you did last time".

DWORD WINAPI SHFormatDrive(HWND hwnd,
UINT drive,
UINT fmtID,
UINT options);

//
// Special value of fmtID which means "use the defaultformat"
//

#DEFINE SHFMT_ID_DEFAULT   0xFFFF

//
// Option bits for options parameter
//

#DEFINE SHFMT_OPT_FULL     0x0001
#DEFINE SHFMT_OPT_SYSONLY  0x0002

//
// Special return values. PLEASE NOTE that these are DWORD values.
//

#DEFINE SHFMT_ERROR     0xFFFFFFFFL    // Error on last format,
// drive may be formatable
#DEFINE SHFMT_CANCEL    0xFFFFFFFEL    // Last format wascanceled
#DEFINE SHFMT_NOFORMAT  0xFFFFFFFDL    // Drive is not formatable

*/




