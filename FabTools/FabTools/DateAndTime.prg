#region DEFINES
DEFINE DOW_FRIDAY := 6
DEFINE DOW_MONDAY := 2
DEFINE DOW_SATURDAY := 7
DEFINE DOW_SUNDAY := 1
DEFINE DOW_THURSDAY := 5
DEFINE DOW_TUESDAY := 3
DEFINE DOW_WEDNESDAY := 4
#endregion

FUNCTION FabGetFirstDOW( wDOW AS WORD, dDate AS DATE ) AS DATE
//g Date & Time, Date & Time Manipulations
//l Retrieve the First day in a month
//p Retrieve the First day in a month
//a <wDOW> is a word setting what Day to retrieve
//a <dDate> is a date. The month and year will be used, and day will start at 1.
//r The corresponding date
//e // Retrieve the first Sunday in the current Month/Year
//e ? FabGetFirstDOW( DOW_SUNDAY, ToDay() )
	LOCAL dRet	AS	DATE
	//
	dRet := ConDate( Year( dDate ), Month( dDate ), 1 )
	//
	WHILE DoW( dRet ) != wDOW
		dRet ++
	ENDDO
	//
RETURN dRet





FUNCTION FabGetLastDOW( wDOW AS WORD, dDate AS DATE ) AS DATE
//g Date & Time
//l Retrieve the Last day in a month
//p Retrieve the Last day in a month
//a <wDOW> is a word setting what Day to retrieve
//a <dDate> is a date. The month and year will be used, and day will start at 1.
//r The corresponding date
//e // Retrieve the last Sunday in the current Month/Year
//e ? FabGetLastDOW( DOW_SUNDAY, ToDay() )
	LOCAL dRet		AS	DATE
	LOCAL dLast		:= dDate AS	DATE
	LOCAL wMonth	AS	DWORD
	//
	wMonth := Month( dDate )
	dRet := ConDate( Year( dDate ), Month( dDate ), 1 )
	//
	WHILE ( Month( dRet ) == wMonth )
		IF ( DoW( dRet ) == wDOW )
			dLast := dRet
		ENDIF
		dRet ++
	ENDDO
	//
RETURN dLast




FUNCTION FabGMTUnixTimeToLocalUnixTime( dwUnixTime AS DWORD )
//g Date & Time
//l Convert a GMT UnixTime to a Local UnixTime
//p Convert a GMT UnixTime to a Local UnixTime
//a <dwUnixTime> is a DWord with the UnixTime to convert
//d The UnixTime is a DWord with the number of seconds elapsed since Midnight 1 Jan 1970.
//d  It's usually exprimed in UTC time.\line
//e // Convert UnixTime
//e dwTime := FabGMTUnixTimeToLocalUnixTime( dwTime )
//e // Retrieve VO Date
//e ddate := ConDate( 1970,01,01)
//e ddate := ddate + Integer( dwTime / 86400 )
//e // And VO Time
//e	cTime := FabTString( dwTime % 86400 )
//r A Dword with the corresponding Local Time.
	LOCAL PTRTZ 	IS 	_WINTIME_ZONE_INFORMATION
	LOCAL GMTBias 	AS 	LONG
	LOCAL StdBias	AS	LONG
	LOCAL DlBias	AS	LONG
	LOCAL TotalBias	AS	LONG
	LOCAL dDate		AS	DATE
	LOCAL nTime		AS	DWORD
	LOCAL dStart	AS	DATE
	LOCAL cStart	AS	STRING
	LOCAL nStart	AS	DWORD
	LOCAL dEnd		AS	DATE
	LOCAL cEnd		AS	STRING
	LOCAL nEnd		AS	DWORD
 	// Retrieve Info about the current TimeZone
	GetTimeZoneInformation( @ptrTZ )
	// No StandardDate Month !!
	IF ( ptrTZ.StandardDate.wMonth == 0 )
		RETURN dwUnixTime
	ENDIF
	// Build GMT Info
	ddate := ConDate( 1970,01,01)
	ddate := ddate + Integer( dwUnixTime / 86400 )
	nTime := ( dwUnixTime % 86400 )
	// Search Start date / time of Daylight Saving
	cStart := FabSystemTimeToVOTime( @ptrTZ.DayLightNDate )
	nStart := Secs( cStart )
	//Absolute Format
	IF ( ptrTZ.DayLightNDate.wYear != 0 )
		dStart := FabSystemTimeToVODate( @ptrTZ.DayLightNDate )
	ELSE
		// Day-in-Month format
		ptrTZ.DayLightNDate.wDay := Max( ptrTZ.DayLightNDate.wDay, 1 )
		dStart := FabGetFirstDOW( DOW_SUNDAY, ConDate( Year( dDate ), ptrTZ.DayLightNDate.wMonth, 1 ) )
		dStart := dStart + ( 7 * ( ptrTZ.DayLightNDate.wDay - 1 ) )
		IF ( dStart > FabGetLastDOW( DOW_SUNDAY, ConDate( Year( dDate ), ptrTZ.DayLightNDate.wMonth, 1 ) ) )
			dStart := FabGetLastDOW( DOW_SUNDAY, ConDate( Year( dDate ), ptrTZ.DayLightNDate.wMonth, 1 ) )
		ENDIF
	ENDIF
	// Search End Date / time
	cEnd := FabSystemTimeToVOTime( @ptrTZ.StandardDate )
	nEnd := Secs( cEnd )
	// Absolute Format
	IF ( ptrTZ.StandardDate.wYear != 0 )
		dEnd := FabSystemTimeToVODate( @ptrTZ.StandardDate )
	ELSE
		// Day-in-Month Format
		ptrTZ.StandardDate.wDay := Max( ptrTZ.StandardDate.wDay, 1 )
		dEnd := FabGetFirstDOW( DOW_SUNDAY, ConDate( Year( dDate ), ptrTZ.StandardDate.wMonth, 1 ) )
		dEnd := dEnd + ( 7 * ( ptrTZ.StandardDate.wDay - 1 ) )
		IF ( dEnd > FabGetLastDOW( DOW_SUNDAY, ConDate( Year( dDate ), ptrTZ.StandardDate.wMonth, 1 ) ) )
			dEnd := FabGetLastDOW( DOW_SUNDAY, ConDate( Year( dDate ), ptrTZ.StandardDate.wMonth, 1 ) )
		ENDIF
	ENDIF
	// Initialize Bias
	GMTBias := ptrTZ.Bias
	StdBias := PTRTZ.StandardBias
	DlBias := PTRTZ.DaylightBias
	//
	TotalBias := GMTBias
	//
	IF ( dDate == dStart )
		IF ( nTime >= nStart )
			TotalBias := TotalBias + DlBias
		ENDIF
	ELSEIF ( dDate == dEnd )
		IF ( nTime <= nEnd )
			TotalBias := TotalBias + DlBias
		ENDIF
	ELSEIF ( dDate > dStart )  .and. ( dDate < dEnd )
		TotalBias := TotalBias + DlBias
	ELSE
		TotalBias := TotalBias + StdBias
	ENDIF
	// Apply Bias
	IF ( dwUnixTime >= dword(TotalBias ))
		dwUnixTime := dwUnixTime - ( dword(TotalBias) * 60 )
	ELSE
		dwUnixTime := 0
	ENDIF
	//
RETURN dwUnixTime	





FUNCTION FabSetSystemTime( lpSystemTime AS _WINSYSTEMTIME ) AS LOGIC
//g System,System Functions
//g Date & Time
//l Set the local system time
//p Set the local system time
//a <lpSystemTime> is a SystemTime structure with the new time to set in UTC.
//d This fucntion will enable the current process to change time, set the new time, and disable privilege.
//r A logical value indicating the success of the operation
	LOCAL lRet		AS	LOGIC
	lRet := FALSE
	//
	IF FabEnablePrivilege( SE_SYSTEMTIME_NAME )
		// Set new Date and Time
		lRet := SetSystemTime( lpSystemTime )
		//
		FabDisablePrivilege( SE_SYSTEMTIME_NAME )
	ENDIF
	//
RETURN lRet




FUNCTION FabSetSystemTime2( dDate AS DATE, cTime AS STRING ) AS LOGIC
//g System,System Functions
//g Date & Time
//l Set the local system time
//p Set the local system time
//a <dDate> is the new date to set.
//a <cTime> is the new time to set in 24h hour format.
//a 	Be aware that time is in UTC !!
//d This function will enable the current process to change time, set the new time, and disable privilege.
//r A logical value indicating the success of the operation
	LOCAL lRet		AS	LOGIC
	LOCAL lpST		IS	_winSYSTEMTIME
	lRet := FALSE	
 	//
 	IF FabIsTime24( cTime )
 		//
 		lpST.wYear	:= word( Year( dDate ) )
 		lpST.wMonth	:= word( Month( dDate ) )
 		lpST.wDay	:= word( Day( dDate ) )
		//
 		lpST.wHour	:= Val( SubStr( cTime, 1, 2 ) )
 		lpST.wMinute:= Val( SubStr( cTime, 4, 2 ) )
 		lpST.wSecond:= Val( SubStr( cTime, 7, 2 ) )
 		//
 		lRet := FabSetSystemTime( @lpST )
 		//
 	ENDIF
RETURN lRet




FUNCTION FabSystemTimeToVODate( ptST AS _winSYSTEMTIME ) AS DATE
//g Date & Time
//l Convert a SYSTEMTIME to Date
//p Convert a SYSTEMTIME to Date
//a <ptST> is a pointer to a _winSYSTEMTIME structure
//r The corresponding Date
//s
	LOCAL dRet	AS	DATE
	//
	dRet := ConDate( ptST.wYear, ptST.wMonth, ptST.wDay )
	//
RETURN dRet	




FUNCTION FabSystemTimeToVOTime( ptST AS _winSYSTEMTIME ) AS STRING
//g Date & Time
//l Convert a SYSTEMTIME to Time
//p Convert a SYSTEMTIME to Time
//a <ptST> is a pointer to a _winSYSTEMTIME structure
//r The corresponding Time
//s
	LOCAL cTime	AS	STRING
	//
	cTime := ConTime( ptST.wHour, ptST.wMinute, ptST.wSecond )
	//
RETURN cTime




FUNCTION FabTString( dwSeconds AS DWORD ) AS STRING
//g Date & Time
//l Convert a specified number of seconds to a 24h time string.
//p Convert a specified number of seconds to a 24h time string.
//a <dwSeconds>	The number of seconds to convert.
//r The corresponding Time
	LOCAL cTime	AS	STRING
	LOCAL cSep	AS	STRING
	LOCAL nSec, nMin, nHour AS DWORD
	//
	cSep := CHR( GetTimeSep() )
	nSec := ( dwSeconds % 60 )
	nHour := Integer( dwSeconds / 3600 )
	nMin := Integer( dwSeconds / 60 ) -( nHour * 60 )
	cTime := StrZero( nHour, 2 ) + cSep + StrZero( nMin, 2 ) + cSep + StrZero( nSec, 2 )
	//
RETURN cTime






