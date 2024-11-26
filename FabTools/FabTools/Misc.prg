// Misc.prg
using System.Windows.Forms

Function FabCenterWindow( oForm as Form ) as void
	Local oTemp as System.Windows.Forms.Form
	//
	oTemp := (System.Windows.Forms.Form) oForm
	oTemp:StartPosition := FormStartPosition.CenterScreen
	return
	
FUNCTION FabGetPercent( Value AS int64, Maximum AS int64 ) AS int64
	LOCAL dwPercent AS int64
	//
	TRY
		IF ( Maximum == 0 )
			dwPercent := 0
		ELSE
			dwPercent := ( Value * 100 ) / Maximum
		ENDIF
	CATCH
		dwPercent := 0
	END TRY
	RETURN dwPercent
	
FUNCTION FabLWSelectEntireRow( oListView AS VO.ListView, lSet:=TRUE AS LOGIC ) AS VOID
	oListView:FullRowSelect := lSet
	RETURN
	
STATIC FUNCTION _FabCheckDbServerErrorHandler(oError)
	// My ErrorHandler, don't retry, just ignore and try the default action
	RETURN FALSE
	
	
PROCEDURE	FabAllButPaint( hWindow AS PTR )
	LOCAL struMsg	IS	_WinMsg
	//
	IF ( PeekMessage( @struMsg, NULL_PTR, 0, 0, PM_REMOVE ) == TRUE )
		IF ( struMsg.Message == (DWORD)WM_PAINT )  .OR.	;
				( struMsg.Message == (DWORD)WM_TIMER )
			//
			DispatchMessage( @struMsg )
			//
		ELSEIF ( ( struMsg.hWnd == hWindow )  .OR. IsChild( hWindow, struMsg.hWnd ) )
			//
			TranslateMessage( @struMsg )
			DispatchMessage( @struMsg )
			//
		ENDIF
	ENDIF
	//
	
	RETURN
	
FUNCTION FabArrayFill(a AS ARRAY, dwEl AS DWORD, u AS USUAL )
	//g Array,Array Tools
	//l Fill an array
	//p Fill an array with a value.
	//a <a> is the array to fill\line
	//a <dwEl> is the number of element to fill\line
	//a <u> is the value to set
	//r The Value used to set the array
	LOCAL Cpt AS    WORD
	//
	FOR Cpt := 1 UPTO dwEl
		a[ Cpt ] := u
	NEXT
	RETURN u
	
	
	
	
FUNCTION Fabatoi( cString AS STRING ) AS USUAL
	
	//
	LOCAL cTrans	AS	STRING
	LOCAL wPos		AS	DWORD
	LOCAL liSize	AS	DWORD
	LOCAL lSign		AS	LOGIC
	//
	cString := AllTrim( cString )
	liSize := SLen( cString )
	lSign := FALSE
	//
	FOR wPos := 1 TO liSize
		IF Instr( SubStr( cString, wPos, 1 ), "0123456789" )
			cTrans := cTrans + SubStr( cString, wPos, 1 )
		ELSEIF Instr( SubStr( cString, wPos, 1 ), "-+" )  .AND. !lSign
			cTrans := cTrans + SubStr( cString, wPos, 1 )
			lSign := TRUE
		ELSE
			EXIT
		ENDIF
	NEXT
	//
	RETURN Val( cTrans )
	
	
	
	
FUNCTION FabBuildDbFile( symClass AS SYMBOL, lCheckIndexes := TRUE AS LOGIC, cPath := "" AS STRING, cName := "" AS STRING ) AS LOGIC
	//g Files,Files Related Classes/Functions
	//l  Create a DBF file from a class that was created using the DBServer editor.
	//p  Create a DBF file from a class that was created using the DBServer editor.
	//a <symClass> indicate the class name of the Server to create.\line
	//a <lCheckIndexes> indicate if the function must check/build the associated indexes.\line
	//a <cPath> indicate the PathName to use instead of the current/default path.\line
	//a 	The Path will used if a creation is needed ( DBF or Index ), or to build a fully qualified name if <cName> is not empty.\line
	//a <cName> indicate the FileName to use instead of the HardCoded one.\line
	//a 	This can be a FileName and Extension, or a fully qualified Name.\line
	//d 	If so, the indicated path will supersede the <cPath> parameter when the function try to open the DBF
	//d  FabBuildDbFile() will create a file using the desired class, catching any error, and use the FieldDesc Access to get the structure of the file.
	//d  Then according to this structure, the function wil create the file.So, you MUST not exclude any fields in the DbServer editor, or they will not be created.\line
	//d Then using the IndexList Access, the function will re-create any associated indexes.\line
	//d !!! WARNING !!! \line
	//d In order to FabBuildDBFile() to work correctly you may have to change the generated code
	//d  or the template in CAVODED.TPL. In the standard code, you will find : \line
	//d 		//\line
	//d 		SELF:PreInit()\line
	//d 		oFileSpec      := FileSpec{SELF:cName}\line
	//d 		oFileSpec:Path := SELF:cDBFPath\line
	//d 		SUPER(oFileSpec, SELF:lSharedMode, SELF:lReadOnlyMode , SELF:xDriver )\line
	//d 		//\line
	//d	As you can see, the path of the file used, is always the one set by the DbServerEditor, even you have
	//d  set the Name parameter with a fully qualified FileName.\line
	//d To avoid this you can write :\line
	//d 		//\line
	//d 		SELF:PreInit()\line
	//d 		oFileSpec      := FileSpec{SELF:cName}\line
	//d 		IF Empty( oFileSpec:Path )\line
	//d 			oFileSpec:Path := SELF:cDBFPath\line
	//d 		ENDIF\line
	//d 		SUPER(oFileSpec, SELF:lSharedMode, SELF:lReadOnlyMode , SELF:xDriver )\line
	//d 		//\line
	//d So you only set the path if the FileName parameter was not a FullPath.\line
	//d Be aware that you have to do a another modification with Index Files, and write :\line
	//d 		oFSIndex := FileSpec{ aIndex[i][DBC_INDEXNAME] }
	//d 		IF Empty( oFSIndex:Path )
	//d 			oFSIndex:path := SELF:cDBFPath
	//d 		ENDIF
	//r  Return TRUE if eveything is ok, FALSE unless
	LOCAL cbErrorHandler	AS	CODEBLOCK
	LOCAL cbLastHandler		AS	CODEBLOCK
	LOCAL oDb				AS	DbServer
	LOCAL aFields			AS	ARRAY
	LOCAL aStruct			AS	ARRAY
	LOCAL aNdx				AS	ARRAY
	LOCAL lSuccess			AS	LOGIC
	LOCAL oFieldSp			AS	FieldSpec
	LOCAL oFileSpec			AS	FileSpec
	LOCAL wCpt				AS	WORD
	LOCAL wCpt2				AS	WORD
	LOCAL aRdds				AS	ARRAY
	LOCAL aOrders			AS	ARRAY
	LOCAL aOrderInfo		AS	ARRAY
	LOCAL oFSpec			AS	FileSpec
	//
	IF ( symClass == NULL_SYMBOL )
		RETURN FALSE
	ENDIF
	// Place our ErrorHandler
	cbErrorHandler := {|oError| _FabCheckDbServerErrorHandler(oError)}
	// Save current handler
	cbLastHandler := ErrorBlock(cbErrorHandler)
	// Build a temp FileSpec
	oFSpec := FileSpec{}
	// We don't have the FileName !
	IF Empty( cName )
		// Build the Object
		oDb := CreateInstance( symClass )
		// Extract the Name
		cName := oDb:FileSpec:FileName + oDb:FileSpec:Extension
		// Apply this filename
		oFSpec:FileName := cName
		// Get Default / Standard Path
		IF Empty( cPath )
			cPath := FabExtractFilePath( oDB:FileSpec:FullPath )
		ENDIF
		// Reset...
		oDb:Close()
		oDb := NULL_OBJECT
	ENDIF
	oFSpec:FileName := cName
	// To preserve a fully qualified FileName
	IF !Empty( cPath )
		oFSpec:Path := cPath
	ENDIF
	// Try to build the DbServer object
	oDb := CreateInstance( symClass, oFSpec:FullPath )
	// Restore handler
	ErrorBlock(cbLastHandler)
	// Something went wrong....
	lSuccess := FALSE
	IF ( oDb:ErrInfo != NULL_OBJECT )  .AND. ( oDB:ErrInfo:GenCode == EG_OPEN )
		IF IsAccess( oDb, #FieldDesc )
			// Retrieve a FieldDesc array
			aFields := oDb:FieldDesc
			// Now, allocate an array
			aStruct := ArrayCreate( ALen( aFields ) )
			FOR wCpt := 1 TO ALen( aFields )
				oFieldSp := aFields[ wCpt][DBC_FIELDSPEC]
				// and build a DBSTRUCT() type array
				aStruct[wCpt] := ArrayCreate( 4 )
				//aStruct[wCpt][DBS_NAME] := oFieldSp:HyperLabel:Name
				aStruct[wCpt][DBS_NAME] := aFields[ wCpt][DBC_NAME ]    // bugfix  by erik visser
				aStruct[wCpt][DBS_TYPE] := oFieldSp:Valtype
				aStruct[wCpt][DBS_LEN]  := oFieldSp:Length
				aStruct[wCpt][DBS_DEC]  := oFieldSp:Decimals
			NEXT
			// Get the FileSpec
			oFileSpec := oDB:FileSpec
			IF !Empty( cPath )
				oFileSpec:Path := cPath
			ENDIF
			// Try to Recreate the File
			aRdds := oDB:RDDS
			lSuccess := DBCREATE(  oFileSpec:FullPath, aStruct, ;
				aRdds[ ALen( aRdds ) ], TRUE, oDB:Alias )
			// Created ?
			IF lSuccess
				// Close the current WorkArea
				DBCLOSEAREA()
				// Place our ErrorHandler
				cbErrorHandler := {|oError| _FabCheckDbServerErrorHandler(oError)}
				// Save current handler
				cbLastHandler := ErrorBlock(cbErrorHandler)
				// ReBuild the oDB Object ( we should not get an error here... )
				// We are using the oFileSpec that was build above with cPath ( if any ) and cName ( if any )
				oDb := CreateInstance( symClass, oFileSpec:FullPath )	// MUST use :FullPath ( V1.4.5 )
				// Restore handler
				ErrorBlock(cbLastHandler)
				// Something went wrong....
				lSuccess := ( oDb:ErrInfo == NULL_OBJECT )
			ENDIF
			//
		ENDIF
	ELSE
		// No need to rebuild...
		lSuccess := TRUE
	ENDIF
	// Right, now we ( at least ) have something like a DBF file
	IF lSuccess
		// Looking for indexes ?
		IF lCheckIndexes
			IF IsAccess( oDb, #IndexList )
				// Get the Index Array
				aNdx := oDb:IndexList
				// If one file is missing, ...Reindex
				FOR wCpt := 1 TO ALen( aNdx )
					//
					oFileSpec := Filespec{}
					// Get FileName
					oFileSpec:FileName := aNdx[ wCpt ][ DBC_INDEXNAME ]
					// Get FilePath
					IF !Empty( cPath )
						oFileSpec:path:= cPath
					ELSE
						oFileSpec:path := aNdx[ wCpt ][ DBC_INDEXPATH ]
					ENDIF
					// Don't Forget Extension
					oFileSpec:Extension := oDB:OrderInfo( DBOI_INDEXEXT )
					// Check...
					IF !oFileSpec:Find()
						// We need to rebuild the Index and order(s)
						aOrders := aNdx[ wCpt ][ DBC_ORDERS ]
						FOR wCpt2 := 1 TO ALen( aOrders )
							aOrderInfo := aOrders[ wCpt2 ]
							IF !Empty( aOrderInfo[ DBC_FOREXP ] )
								oDB:SetOrderCondition( aOrderInfo[ DBC_FOREXP ], ,TRUE, , ,0,0,0,0,FALSE, ;
									!aOrderInfo[ DBC_ASCENDING ],FALSE,FALSE,FALSE,FALSE )
							ELSE
								oDB:SetOrderCondition( )
							ENDIF
							lSuccess := lSuccess  .AND. oDB:CreateOrder( aOrderInfo[ DBC_TAGNAME ], oFileSpec, ;
								aOrderInfo[ DBC_KEYEXP ], , !aOrderInfo[ DBC_DUPLICATE ] )
						NEXT
					ENDIF
				NEXT
			ENDIF
		ENDIF
	ENDIF
	// Kill our DBServer before exiting
	oDB:Close()
	oDB := NULL_OBJECT
	RETURN lSuccess
	
	
	
	
FUNCTION FabBuildFillUsingArray( aFirst AS ARRAY, aSecond AS ARRAY ) AS ARRAY
	//l Merge two arrays
	//p Merge to arrays to build a FillUsing() array
	//g Array,Array Tools
	LOCAL aRet AS ARRAY
	LOCAL wCpt AS WORD
	//
	aRet := {}
	FOR wCpt := 1 TO ALen( aFirst )
		//
		AAdd( aRet, { aFirst[ wCpt ], aSecond[ wCpt ] } )
		//
	NEXT
	RETURN aRet
	
	
	
	
PROCEDURE FabCenterWindow( oWindow AS OBJECT  )
	/*
	Center a Window, in the desktop
	*/
	//
	LOCAL	hParent		AS	PTR
	LOCAL	hItem		AS	PTR
	LOCAL	rctWindow	IS	_WINRECT
	LOCAL	rctDesktop	IS	_WINRECT
	LOCAL	wLeft, wTop, wWidth, wHeight	AS	LONG
	//
	IF IsMethod( oWindow, #Handle )
		hItem	:= Send( oWindow, #Handle )
		hParent	:= GetDeskTopWindow()
		//
		GetWindowRect( hItem, @rctWindow )
		GetWindowRect( hParent, @rctDesktop )
		//
		wWidth	:= rctWindow.right - rctWindow.left
		wHeight	:= rctWindow.bottom - rctWindow.top
		wLeft	:= ( rctDesktop.right / 2 ) - ( wWidth / 2 )
		wTop	:= ( rctDesktop.bottom / 2 ) - ( wHeight / 2 )
		MoveWindow( hItem, wLeft, wTop, wWidth, wHeight, TRUE )
	ENDIF
	
	
	RETURN
	
FUNCTION FabColor2RGB( oColor AS Color ) AS DWORD
	//l  Convert Color object to Windows RGB color
	//p  Convert Color object to Windows RGB color
	RETURN DWORD( oColor:Red ) + ( DWORD( oColor:Green ) << 8 ) + ( DWORD( oColor:Blue ) << 16 )
	
	
	
	
FUNCTION FabCreateFontIndirect( pLogFont AS _winLogFont ) AS Font
	//l Create a Font
	//p Create a Font using a _WinLogFont structure.
	//a <pLogFont> is a windows structure with Font info.
	//r The corresponding VO Font object.
	LOCAL oFont	AS	Font
	LOCAL iFam	AS INT
	LOCAL iFamily	AS INT
	LOCAL oDim	AS Dimension
	//
	iFam := _AND( pLogFont.lfPitchAndFamily, 0B11110000 )
	DO CASE
	CASE iFam == FF_ROMAN
		iFamily := FONTFAMILY_ROMAN
	CASE iFam == FF_SWISS
		iFamily := FONTFAMILY_SWISS
	CASE iFam == FF_MODERN
		iFamily := FONTFAMILY_MODERN
	CASE iFam == FF_SCRIPT
		iFamily := FONTFAMILY_SCRIPT
	CASE iFam == FF_DECORATIVE
		iFamily := FONTFAMILY_DECORAT
	OTHERWISE
		iFamily := FONTFAMILY_ANY
	ENDCASE
	oDim  := Dimension{ pLogFont.lfWidth, pLogFont.lfHeight }
	oFont := Font{ iFamily, oDim, Psz2String( @pLogFont.lfFaceName[1] ) }
	//
	pLogFont.lfPitchAndFamily := _AND( pLogFont.lfPitchAndFamily, 0B11)
	DO CASE
	CASE pLogFont.lfPitchAndFamily == FIXED_PITCH
		oFont : PitchFixed := TRUE
	CASE pLogFont.lfPitchAndFamily == VARIABLE_PITCH
		oFont : PitchVariable := TRUE
	OTHERWISE
		oFont:Normal := TRUE
	ENDCASE
	//
	IF pLogFont.lfItalic != 0
		oFont:Italic := TRUE
	ENDIF
	IF pLogFont.lfUnderline != 0
		oFont:Underline := TRUE
	ENDIF
	IF pLogFont.lfStrikeOut != 0
		oFont:Strikethru := TRUE
	ENDIF
	DO CASE
	CASE pLogFont.lfWeight == FW_THIN
		oFont:Light := TRUE
	CASE pLogFont.lfWeight == FW_EXTRALIGHT
		oFont:Light := TRUE
	CASE pLogFont.lfWeight == FW_LIGHT
		oFont:Light := TRUE
	CASE pLogFont.lfWeight == FW_NORMAL
		oFont:Normal := TRUE
	CASE pLogFont.lfWeight == FW_MEDIUM
		oFont:Normal := TRUE
	CASE pLogFont.lfWeight == FW_SEMIBOLD
		oFont:Normal := TRUE
	CASE pLogFont.lfWeight == FW_BOLD
		oFont:Bold := TRUE
	CASE pLogFont.lfWeight == FW_ULTRABOLD
		oFont:Bold := TRUE
	CASE pLogFont.lfWeight == FW_HEAVY
		oFont:Bold := TRUE
	OTHERWISE
		oFont:Normal := TRUE
	ENDCASE
	//
	RETURN oFont
	
	
FUNCTION FabCreateInstance( aObject AS ARRAY ) AS OBJECT
	//l Enhanced CreateInstance() Function
	//p Enhanced CreateInstance() Function.
	//a <aObject> is an Array with CreateInstance() parameters in an array
	//r The created Object
	
	LOCAL oObject		AS	OBJECT
	LOCAL wParam	AS	DWORD
	// The number of parameter needed for the Instantiation
	wParam := ( ALen( aObject ) - 1 )
	//
	DO CASE
	CASE ( wParam == 1 )
		oObject := CreateInstance( aObject[ 1 ], aObject[ 2 ] )
	CASE ( wParam == 2 )
		oObject := CreateInstance( aObject[ 1 ], aObject[ 2 ],aObject[ 3 ] )
	CASE ( wParam == 3 )
		oObject := CreateInstance( aObject[ 1 ], aObject[ 2 ],aObject[ 3 ], aObject[ 4 ] )
	CASE ( wParam == 4 )
		oObject := CreateInstance( aObject[ 1 ], aObject[ 2 ],aObject[ 3],  aObject[ 4 ], aObject[ 5 ] )
	CASE ( wParam == 5 )
		oObject := CreateInstance( aObject[ 1 ], aObject[ 2 ],aObject[ 3 ], aObject[ 4 ], aObject[ 5 ], aObject[ 6 ] )
	CASE ( wParam == 6 )
		oObject := CreateInstance( aObject[ 1 ], aObject[ 2 ],aObject[ 3 ], aObject[ 4 ], aObject[ 5 ], aObject[ 6 ], aObject[ 7 ] )
	CASE ( wParam == 7 )
		oObject := CreateInstance( aObject[ 1 ], aObject[ 2 ],aObject[ 3 ], aObject[ 4 ], aObject[ 5 ], aObject[ 6 ], aObject[ 7 ], aObject[ 8 ] )
	CASE ( wParam == 8 )
		oObject := CreateInstance( aObject[ 1 ], aObject[ 2 ],aObject[ 3 ], aObject[ 4 ], aObject[ 5 ], aObject[ 6 ], aObject[ 7 ], aObject[ 8 ], aObject[ 9 ] )
	CASE ( wParam == 9 )
		oObject := CreateInstance( aObject[ 1 ], aObject[ 2 ],aObject[ 3 ], aObject[ 4 ], aObject[ 5 ], aObject[ 6 ], aObject[ 7 ], aObject[ 8 ], aObject[ 9 ], aObject[ 10 ] )
	CASE ( wParam == 10 )
		oObject := CreateInstance( aObject[ 1 ], aObject[ 2 ],aObject[ 3 ], aObject[ 4 ], aObject[ 5 ], aObject[ 6 ], aObject[ 7 ], aObject[ 8 ], aObject[ 9 ], aObject[ 10 ], aObject[ 11 ] )
	OTHERWISE
		// At least one parameter : The Symbol of the Class
		oObject := CreateInstance( aObject[ 1 ] )
	ENDCASE
	//
	RETURN oObject
	
	
	
FUNCTION FabCursorArrow() AS PTR
	//g Window,Window/Dialog Related Classes/Functions
	//l Set The Mouse cursor as Arrow
	//p Set The Mouse cursor as Arrow
	//r The previous cursor pointer
	/*
	Set the cursor AS NormalCursor
	*/
	RETURN   SetCursor( LoadCursor( 0, PSZ( IDC_ARROW ) ) )
	
	
	
	
FUNCTION FabCursorWait() AS PTR
	//g Window,Window/Dialog Related Classes/Functions
	//l Set The Mouse cursor as WaitState
	//p Set The Mouse cursor as WaitState
	//r The previous cursor pointer
	/*
	Set the cursor as WaitCursor
	*/
	RETURN   SetCursor( LoadCursor( 0, PSZ( IDC_WAIT ) ) )
	
	
	
	
FUNCTION FabDisableWindows( aWindows AS ARRAY, aExcept AS ARRAY ) AS ARRAY
	//g Window,Window/Dialog Related Classes/Functions
	//l Disable a set of Window
	//p Disable a set of Window
	//a <aWindows> is an array of Windows Handle to disable
	//a <aExcept> is an array of Windows Handle not to disable
	//d FabDisableWindows() will get all Windows Handle in the <aWindows> array, check if Windows are visible.
	//d  If so, and if they are not in the <aExcept> array, they will be disabled.
	//r An array with Handles of Windows that have been disabled by this function.
	LOCAL dwCpt		AS	DWORD
	LOCAL dwCount	AS	DWORD
	LOCAL aDone		AS	ARRAY
	//
	aDone := {}
	dwCount := ALen( aWindows )
	FOR dwCpt := 1 TO dwCount
		//
		IF IsWindow( aWindows[ dwCpt ] )  .AND.	;
				IsWindowVisible( aWindows[ dwCpt ] )  .AND.	;
				IsWindowEnabled( aWindows[ dwCpt ] )
			//
			IF ( AScan( aExcept, { |hWnd| hWnd == aWindows[ dwCpt ] } ) == 0 )
				EnableWindow( aWindows[ dwCpt ], FALSE )
				AAdd( aDone, aWindows[ dwCpt ] )
			ENDIF
		ENDIF
	NEXT
	//
	RETURN aDone
	
	
	
PROCEDURE FabEnableWindows( aWindows AS ARRAY, aExcept AS ARRAY )
	//g Window,Window/Dialog Related Classes/Functions
	//l Enable a set of Window
	//p Enable a set of Window
	//a <aWindows> is an array of Windows Handle to Enable
	//a <aExcept> is an array of Windows Handle not to Enable
	//d FabEnableWindows() will get all Windows Handle in the <aWindows> array and if they are not in the <aExcept> array, they will be enabled.
	LOCAL dwCpt		AS	DWORD
	LOCAL dwCount	AS	DWORD
	//
	dwCount := ALen( aWindows )
	FOR dwCpt := 1 TO dwCount
		//
		IF IsWindow( aWindows[ dwCpt ] )
			//
			IF ( AScan( aExcept, { |hWnd| hWnd == aWindows[ dwCpt ] } ) == 0 )
				EnableWindow( aWindows[ dwCpt ], TRUE )
			ENDIF
		ENDIF
	NEXT
	
	
	RETURN
	
STATIC FUNCTION FabExecErr( ObjError )
	BREAK ObjError
	
	
	
	
	
FUNCTION FabExecuteBlock( cChaine AS STRING , xValeur REF USUAL  ) AS LOGIC
	//l Execute a CodeBlock stored in a String
	//p Execute a CodeBlock stored in a String
	//a <cChaine> is the String with the CodeBlock to execute\line
	//a <xValeur> is a Usual Value than will receive the result of the execution. It MUST be passed by reference ( using the @ operator )
	//d This function will compile the specified String,  catch any errors, modifiy the <xValeur> parameter and return a logical value
	//r A logical value indicating if the compilation or execution has raised an error.
	LOCAL lOk		AS	LOGIC
	LOCAL oMyHandler	AS	CODEBLOCK
	LOCAL cbBlock
	//
	oMyHandler := ErrorBlock( { |e| FabExecErr( e ) } )
	//
	BEGIN SEQUENCE
		cbBlock := &("{||"+ cChaine +"}" )
		xValeur := Eval( cbBlock )
		lOk   := TRUE
	RECOVER 
		xValeur := NIL
		lOk     := FALSE
	END SEQUENCE
	//
	ErrorBlock( oMyHandler )
	//
	RETURN lOk
	
	
	
	
FUNCTION FabExitWindows( dwMode AS DWORD ) AS LOGIC
	//g System,System Functions
	//l Replacement for the ExitWindowsEx() function
	//p Replacement for the ExitWindowsEx() function
	//a <dwMode> specifies the type of shutdown.
	//a 	Look at the Win32SDK in the ExitWindowsEx() topic for more info.
	//d This function will internally call the ExitWindowsEx() function, but if running
	//d  with Windows NT, it first set the application privileges so it can call this function.
	//r A logicial value, indicating if the ExitWindowsEx() functions succeeds.
	LOCAL lRet		:= FALSE AS	LOGIC
	LOCAL ptrVI		IS	_winOSVERSIONINFO
	LOCAL hToken	AS	PTR
	LOCAL ptrTP		IS	_winTOKEN_PRIVILEGES
	//
	ptrVI.dwOSVersionInfoSize := _Sizeof( _winOSVERSIONINFO )
	GetVersionEx( @ptrVI )
	IF ( ptrVI.dwPlatformId == (DWORD)VER_PLATFORM_WIN32_NT )
		// With NT, we MUST set the Application privilege
		// open access privilege list.
		IF OpenProcessToken( GetCurrentProcess(), _OR( TOKEN_ADJUST_PRIVILEGES, TOKEN_QUERY ), @hToken )
			ptrTP.PrivilegeCount := 1
			// Ask the "shutdown" LUID
			LookupPrivilegeValue( NULL_PSZ, String2Psz( SE_SHUTDOWN_NAME ), @ptrTP.Privileges[1].Luid )
			// Enable it
			ptrTP.Privileges[1].Attributes := (DWORD)SE_PRIVILEGE_ENABLED
			AdjustTokenPrivileges( hToken, FALSE, @ptrTP, 0, NULL_PTR, NULL_PTR )
			lRet := ( GetLastError() == (DWORD)ERROR_SUCCESS )
		ENDIF
	ELSE
		lRet := TRUE
	ENDIF
	//
	IF lRet
		lRet := ExitWindowsEx( dwmode, 0 )
	ENDIF
	//
	RETURN lRet
	
	
	
	
	
	
	
	
PROCEDURE	FabFilterMessages( hWindow AS PTR, aDontFilterMsgs AS ARRAY )
	//g Window,Window/Dialog Related Classes/Functions
	//l Filter Messages in application Queue
	//p Filter Messages in application Queue
	//a <hWindow> is the Handle of the Window that needs modal work.
	//a <aDontFilterMsgs> is an array with messages to let go. ( eg. WM_COMMNOTIFY, ... )
	//d This function will get a message in the application queue.\line
	//d If the message is WM_PAINT or WM_TIMER the message is routed in the standard way.\line
	//d If the message concerned the Window, or any of its childs ( controls, .. ) the message is dispatched.
	//d Unless, if the message doesn't appear in the array of messages to routed, it is only removed from the queue.
	//e In the following sample, you can do a long work, keep the window refreshed, moveable, ...
	//e But don't let other windows receive messages except WM_PAINT, WM_TIMER, WM_COMMNOTIFY
	//e Self:lCancel is a logical property of the window, that a button set to TRUE.
	//e This can be done as FabFilterMessages() don't block messages for Childs of the window.
	//e WHILE ( lNotEnded )
	//e 	FabFilterMessages( SELF:Handle(), { WM_COMMNOTIFY } )
	//e		IF Self:lCancel
	//e			EXIT
	//e		ENDIF
	//e		...
	//e		...
	//e ENDDO
	//
	LOCAL struMsg	IS	_WinMsg
	//
	IF ( PeekMessage( @struMsg, NULL_PTR, 0, 0, PM_REMOVE ) == TRUE )
		IF ( struMsg.Message == (DWORD)WM_PAINT )  .OR.	;
				( struMsg.Message == (DWORD)WM_TIMER )
			//
			DispatchMessage( @struMsg )
			//
		ELSEIF ( ( struMsg.hWnd == hWindow )  .OR. IsChild( hWindow, struMsg.hWnd ) )
			//
			TranslateMessage( @struMsg )
			DispatchMessage( @struMsg )
			//
		ELSEIF ( AScan( aDontFilterMsgs, struMsg.Message ) != 0 )
			//
			DispatchMessage( @struMsg )
			//
		ENDIF
	ENDIF
	//
	
	
	RETURN
	
FUNCTION FabFormatCString( Format AS STRING, Args AS ARRAY ) AS STRING
	//p Format a string using C langage format style
	//l Format a string using C langage format style
	//d This function wil produce a string using the same format string as the wsprintf() function. ( Look in the Win32SDK.HLP file for more info. )
	//a <Format> is the string containing ordinary ASCII and the format specifications.
	//a <Args> is an array with arguments
	//r The corresponding string
	//e	? FabFormatCString( "a test %c %s %d %ld %#x %lx %X", { "a", "azert", 12, 12, 12, 12, 12 } )
	//e	// will produce
	//e	// a test a azert 12 12 0xc c C
	LOCAL cResult	AS	STRING
	LOCAL cAdd		AS	STRING
	LOCAL liSize	AS	DWORD
	LOCAL nArg		AS	DWORD
	LOCAL wPos		AS	DWORD
	LOCAL cChar		AS	STRING
	LOCAL wWidth	AS	DWORD
	LOCAL wMax		AS	DWORD
	LOCAL lLeft		AS	LOGIC
	LOCAL lHex		AS	LOGIC
	LOCAL lLong		AS	LOGIC
	LOCAL cPad		AS	STRING
	LOCAL liLen			AS	DWORD
	//
	IF ( ALen( Args ) == 0 )
		RETURN Format
	ENDIF
	//
	liSize := SLen( Format )
	//
	nArg := 0
	wPos := 1
	WHILE ( wPos <= liSize )
		cChar := SubStr3( Format, wPos, 1 )
		// Format Marker ?
		IF ( cChar != "%" )
			IF ( cChar == "\" )
				wPos ++
				cChar := SubStr3( Format, wPos, 1 )
				DO CASE
				CASE cChar == "a"
					// BEL
					// Eat it
					cChar := ""
				CASE cChar == "b"
					// BackSpace
					cChar := CHR( 8 )
				CASE cChar == "f"
					// Form Feed
					cChar := CHR( 12 )
				CASE cChar == "n"
					// New Line
					cChar := CRLF
				CASE cChar == "r"
					// Carriage Return
					cChar := CHR( ASC_CR )
				CASE cChar == "t"
					// Horz Tab.
					cChar := CHR( 9 )
				CASE cChar == "v"
					// Vert. Tab
					cChar := CHR( 11 )
				CASE cChar == "\"
					// Don't touch
                    NOP
				CASE cChar == "'"
					// Don't touch
                    NOP
				CASE cChar == '"'
					// Don't touch
                    NOP
				CASE cChar == "?"
					// Don't touch
                    NOP
				OTHERWISE
					// Don't know how to interpret, Don't touch whole escape command
					cChar := "\" + cChar
				ENDCASE
			ENDIF
			cResult := cResult + cChar
			wPos ++
			LOOP
		ELSE
			wPos ++
			cChar := SubStr3( Format, wPos, 1 )
		ENDIF
		// If we are here, we have found a "%"
		IF ( cChar == "%" )
			// Second, save it
			cResult := cResult + cChar
			wPos ++
			LOOP
		ENDIF
		//
		IF ( cChar == "-" )
			lLeft := TRUE
			wPos ++
			cChar := SubStr3( Format, wPos, 1 )
		ELSE
			lLeft := FALSE
		ENDIF
		//
		IF ( cChar == "#" )
			lHex := TRUE
			wPos ++
			cChar := SubStr3( Format, wPos, 1 )
		ELSE
			lHex := FALSE
		ENDIF
		//
		IF ( cChar == "0" )
			cPad := "0"
		ELSE
			cPad := " "
		ENDIF
		//
		IF Instr( cChar, "0123456789" )
			wWidth := Fabatoi( SubStr2( Format, wPos ) )
			wPos ++
			cChar := SubStr3( Format, wPos, 1 )
			WHILE ( Instr( cChar, "0123456789" ) )
				wPos ++
				cChar := SubStr3( Format, wPos, 1 )
			ENDDO
		ELSE
			wWidth := 0
		ENDIF
		//
		IF ( cChar == "." )
			wMax := Fabatoi( SubStr2( Format, wPos + 1 ) )
			wPos ++
			cChar := SubStr3( Format, wPos, 1 )
			WHILE ( Instr( cChar, "0123456789" ) )
				wPos ++
				cChar := SubStr3( Format, wPos, 1 )
			ENDDO
		ELSE
			wMax := 0
		ENDIF
		//
		IF ( cChar == "l" )
			lLong := TRUE
			wPos ++
			cChar := SubStr3( Format, wPos, 1 )
		ELSE
			lLong := FALSE
		ENDIF
		//
		cAdd := ""
		nArg ++
		wPos ++
		//
		DO CASE
		CASE ( cChar == "c" )
			// Single Char
			cAdd := SubStr( AsString( Args[ nArg ] ), 1, 1 )
		CASE ( cChar == "s" )
			// String
			cAdd := AsString( Args[ nArg ] )
		CASE ( cChar == "d" )  .or. ( cChar == "i" )
			// Decimal, signed
			IF lLong
				cAdd := AsString( LONG( _CAST, Args[ nArg ] ) )
			ELSE
				cAdd := AsString( SHORT( _CAST, Args[ nArg ] ) )
			ENDIF
			cAdd := AllTrim( cAdd )
		CASE ( cChar == "u" )
			// Decimal, unsigned
			IF lLong
				cAdd := AsString( DWORD( _CAST,Args[ nArg ] ) )
			ELSE
				cAdd := AsString( WORD( _CAST,Args[ nArg ] ) )
			ENDIF
			cAdd := AllTrim( cAdd )
		CASE ( cChar == "o" )
			// Octal, non implemented
            NOP
		CASE ( cChar == "b" )
			// Binary, non implemented
            NOP
		CASE ( cChar == "x" )  .or. ( cChar == "X" )
			// Hex
			IF lLong
				cAdd := Lower( AsHexString( DWORD( _CAST,Args[ nArg ] ) )  )
			ELSE
				cAdd := Lower( AsHexString( WORD( _CAST,Args[ nArg ] ) )  )
			ENDIF
			WHILE ( SubStr3( cAdd, 1, 1 ) == "0" )
				cAdd := SubStr2( cadd, 2 )
			ENDDO
			IF ( SLen( cadd ) == 0 )
				cAdd := "0"
			ENDIF
			IF lHex
				cAdd := "0x" + cAdd
			ENDIF
			IF ( cChar == "X" )
				// Hex, uppercase
				cAdd := Upper( cAdd )
			ENDIF
		ENDCASE
		//
		liLen := SLen( cAdd )
		IF ( wMax > 0 )  .and. ( wMax < liLen )
			liLen := wMax
		ENDIF
		//
		IF ( wWidth > liLen )
			wWidth := wWidth - liLen
		ELSE
			wWidth := 0
		ENDIF
		//
		IF !lLeft
			cAdd := Replicate( cPad, wWidth ) + SubStr3( cAdd, 1, liLen )
		ELSE
			cAdd := SubStr3( cAdd, 1, liLen ) + Replicate( cPad, wWidth )
		ENDIF
		//
		cResult := cResult + cAdd
		//
	ENDDO
	//
	RETURN cResult
	
	
	
	
	
FUNCTION FabFormatMessage( dwErrorCode AS DWORD ) AS STRING
	//l GetString message using GetLastError() code
	//p GetString message using GetLastError() code
	//
	LOCAL lpMsgBuf	AS	PSZ
	LOCAL sRet		AS	STRING
	//
	lpMsgBuf := NULL_PSZ
	//
	FormatMessage( _or( FORMAT_MESSAGE_ALLOCATE_BUFFER, FORMAT_MESSAGE_FROM_SYSTEM, FORMAT_MESSAGE_IGNORE_INSERTS),	;
		NULL_ptr,	;
		dwErrorCode,	;
		VOWin32APILibrary.Functions.MAKELANGID( LANG_NEUTRAL, SUBLANG_DEFAULT ),	; // Default language
		@lpMsgBuf,	;
		0,	;
		NULL )
	// Copy to VO String
	sRet := Psz2String( lpMsgBuf )
	// Free the buffer.
	LocalFree( lpMsgBuf )
	//
	RETURN sRet
	
	
	
FUNCTION FabGetCmdExe() AS STRING
	//g Files, Files Related Classes/Functions
	//l Get the Executable fullpath from Command Line
	//p Get the Executable fullpath from Command Line
	//r The Executable fullpath from the command line. You can use FabGetCmdParams() to get the parameters from command line
	LOCAL CmdLine	AS	STRING
	LOCAL nPos		AS	DWORD
	//
	CmdLine := _GetCmdLine()
	CmdLine := Upper( CmdLine )
	// When using _GetCmdLine() we will find the name of the application between ", then the params
	// First remove the application from the string
	nPos := At( '"', CmdLine )
	IF ( nPos > 0 )
		// First "
		CmdLine := SubStr( CmdLine, nPos+1 )
		nPos := At( '"', CmdLine )
		IF ( nPos > 0 )
			// Second "
			// Extract EXE name
			CmdLine := SubStr( CmdLine, 1, nPos-1 )
		ENDIF
	ENDIF
	//
	RETURN CmdLine
	
	
	
FUNCTION FabGetCmdParams() AS STRING
	//g Files, Files Related Classes/Functions
	//l Get the Parameters from Command Line
	//p Get the Parameters from Command Line
	//r The parameters from the command line. You can use FabGetCmdExe() to get the Executable command line
	LOCAL CmdLine	AS	STRING
	LOCAL nPos		AS	DWORD
	//
	CmdLine := _GetCmdLine()
	CmdLine := Upper( CmdLine )
	// When using _GetCmdLine() we will find the name of the application between ", then the params
	// First remove the application from the string
	nPos := At( '"', CmdLine )
	IF ( nPos > 0 )
		// First "
		CmdLine := SubStr( CmdLine, nPos+1 )
		nPos := At( '"', CmdLine )
		IF ( nPos > 0 )
			// Second "
			CmdLine := SubStr( CmdLine, 1, nPos+1 )
			// Now we only have the params.
			CmdLine := AllTrim( CmdLine )
		ENDIF
	ELSE
		CmdLine := ""
	ENDIF
	//
	RETURN CmdLine
	
	
	
	
FUNCTION FabGetFirstTabCtrl( oInWindow AS OBJECT ) AS PTR
	//g Window,Window/Dialog Related Classes/Functions
	//l Get the First Control Handle in Tab Order
	//p Get the First Control Handle in Tab Order
	//a <oInWindow> is the Window we must search
	//r The Handle of the First Control
	LOCAL	wFirst	AS	PTR
	// First Control
	wFirst := FabGetNextTabCtrl( oInWindow, 0 )	// Buggy in Ws311
	RETURN	wFirst
	
	
	
	
FUNCTION FabGetLastTabCtrl( oInWindow AS OBJECT ) AS PTR
	//g Window,Window/Dialog Related Classes/Functions
	//l Get the Last Control Handle in Tab Order
	//p Get the Last Control Handle in Tab Order
	//a <oInWindow> is the Window we must search
	//r The Handle of the Last Control
	LOCAL	wFirst	AS	PTR
	LOCAL	wLast	AS	PTR
	// First we need to know the first control
	wFirst := FabGetFirstTabCtrl( oInWindow )
	// The "last" control is the previous one
	wLast := FabGetPrevTabCtrl( oInWindow,WFirst )
	RETURN	wLast
	
	
	
	
FUNCTION FabGetMenuID( oMenu, symEventName, hMenuHandle )
	//l Retrieve an Item ID using it's Symbol EventName
	//p Retrieve an Item ID using it's Symbol EventName
	//a <oMenu> is the Menu object to search into\line
	//a <symEventName> is the Symbol value to search\line
	//a <hMenuHandle> MUST be Nil
	//r The MenuID found
	LOCAL wCtr := 0 AS INT
	LOCAL wItemID AS DWORD
	LOCAL wRetVal := 0 AS DWORD
	
	// hMenuHandle is really only for recursion; no need to pass it initially
	hMenuHandle := If( hMenuHandle == NIL, oMenu:Handle(), hMenuHandle )
	
	WHILE TRUE
		// Get item ID of current item
		wItemID := GetMenuItemID( hMenuHandle, wCtr )
		//
		IF ( wItemID == 0xFFFFFFFF )
			// Check if submenu
			IF GetSubMenu( hMenuHandle, wCtr ) <> NULL_PTR
				// If submenu, recurse and check return value
				IF ( wRetVal := FabGetMenuID( oMenu, symEventName, GetSubMenu( hMenuHandle, wCtr ) ) ) <> 0
					// If found in submenu, done
					EXIT
				ELSE
					// Go to next option.
					++wCtr
				ENDIF
			ELSE
				// No submenu, so last option in menu
				EXIT
			ENDIF
		ELSE
			// Match symbol name
			IF oMenu:HyperLabel( wItemID ) <> NULL_OBJECT  .and. oMenu:HyperLabel( wItemID ):NameSym == symEventName
				wRetVal := wItemID
				EXIT
			ELSE
				// Next option
				++wCtr
			ENDIF
		ENDIF
	ENDDO
	
	RETURN wRetVal
	
	
	
	
FUNCTION FabGetNextTabCtrl( oInWindow AS OBJECT, hCtrl AS PTR ) AS PTR
	//g Window,Window/Dialog Related Classes/Functions
	//l Get the Next Control Handle in Tab Order
	//p Get the Next Control Handle in Tab Order
	//a <oInWindow> is the Window we must search\line
	//a <hCtrl> is the Handle of the control where the search must begin
	//r The Handle of the next Control
	LOCAL	oSurface	AS	OBJECT
	LOCAL	wFirst	AS	PTR
	// DataWindow have a Surface, the real working place
	IF IsInstanceOfUsual( oInWindow,#DataWindow)
		oSurface := oInWindow:__getFormSurface()
	ELSE
		oSurface := oInWindow
	ENDIF
	// First Control
	wFirst := GetNextDlgTabItem( oSurface:Handle(), hCtrl, FALSE )
	RETURN	wFirst
	
	
	
	
FUNCTION FabGetPercent( Value AS DWORD, Maximum AS DWORD ) AS DWORD
	//l Calculate a percentage
	//p Calculate a percentage
	LOCAL dwPercent AS DWORD
	//
	DO WHILE ( Value > 10000000 )
		Value := Value >> 3
		Maximum := Maximum >> 3
	ENDDO
	//
	IF ( Maximum == 0 )
		dwPercent := 0
	ELSE
		dwPercent := ( Value * 100 ) / Maximum
	ENDIF
	RETURN dwPercent
	
	
	
	
FUNCTION FabGetPrevTabCtrl( oInWindow AS OBJECT, hCtrl AS PTR ) AS PTR
	//g Window,Window/Dialog Related Classes/Functions
	//l Get the Previous Control Handle in Tab Order
	//p Get the Previous Control Handle in Tab Order
	//a <oInWindow> is the Window we must search\line
	//a <hCtrl> is the Handle of the control where the search must begin
	//r The Handle of the Previous Control
	LOCAL	oSurface	AS	OBJECT
	LOCAL	wFirst	AS	PTR
	// DataWindow have a Surface, the real working place
	IF IsInstanceOfUsual( oInWindow,#DataWindow)
		oSurface := oInWindow:__getFormSurface()
	ELSE
		oSurface := oInWindow
	ENDIF
	// First Control
	wFirst := GetNextDlgTabItem( oSurface:Handle(), hCtrl, TRUE )
	RETURN	wFirst
	
	
	
	
FUNCTION FabGetSubMenuFromPos( oMenu AS VO.Menu , nPos AS INT ) AS VO.MENU
	LOCAL wItemID AS DWORD
	LOCAL hMenuHandle AS PTR
	LOCAL oRetMenu := NULL_OBJECT AS VO.Menu
	// First, get the Item
	hMenuHandle := oMenu:Handle()
	// Position is zero based
	nPos := nPos - 1
	// Get item ID of current item
	wItemID := GetMenuItemID( hMenuHandle, nPos )
	//
	IF ( wItemID == 0xFFFFFFFF )
		// Check if submenu
		IF GetSubMenu( hMenuHandle, nPos ) <> NULL_PTR
			//
			oRetMenu := GetObjectByHandle( GetSubMenu( hMenuHandle, nPos ) )
		ENDIF
	ENDIF
	RETURN oRetMenu
	
	
	
	
	
FUNCTION FabGetTime24() AS STRING
	//l Retrieve the current time, in 24h format
	//p Retrieve the current time, in 24h format
	//r The Current Time in 24h Format
	/*
	Retrieve the current time, in 24h format
	*/
	LOCAL	lAMPM		AS	LOGIC
	LOCAL	cAMExt		AS	STRING
	LOCAL	cPMExt		AS	STRING
	LOCAL	cSep		AS	STRING
	LOCAL	cTime		AS	STRING
	// Save current setting
	lAMPM := SetAmPm()
	cAMExt := GetAMExt()
	cPMExt := GetPMExt()
	cSep := CHR( GetTimeSep() )
	// Put our format
	SetAmPm( FALSE )
	SetTimeSep( WORD( Asc( ":" ) ) )
	// Get Time
	cTime := Time()
	// Restore Setting
	SetAmPm( lAMPM )
	SetAMExt( cAMExt )
	SetPMExt( cPMExt )
	SetTimeSep( word( Asc( cSep ) ) )
	//
	RETURN cTime
	
	
	
	
FUNCTION FabIsNullPtr( ptrPointer AS PTR ) AS LOGIC
	RETURN ( ptrPointer == NULL_PTR )
	
	
	
	
FUNCTION FabIsTime24( sString AS STRING )	AS	LOGIC
	//l Check a Time String
	//p Check a Time String in 24h format
	//r A logical value indicating if the Time String is correct
	/*
	Check if a time string is correct. ( In 24h Format )
	*/
	LOCAL	lRetVal 			AS	LOGIC
	LOCAL	sHour, sMin, sSec 	AS STRING
	//
	lRetVal := FALSE
	sString := AllTrim( sString )
	sHour := SubStr( sString, 1, 2 )
	sMin := SubStr( sString, 4, 2 )
	sSec := SubStr( sString, 7, 2 )
	//
	IF ( Val( sHour ) >= 0 )  .and. ( Val( sHour ) <= 23 )
		IF( Val( sMin ) >= 0 )  .and. ( Val( sMin ) <= 59 )
			IF( Val( sSec ) >= 0 )  .and. ( Val( sSec ) <= 59 )
				lRetVal := TRUE
			ENDIF
		ENDIF
	ENDIF
	//
	RETURN lRetVal
	
	
	
	
FUNCTION FabIsWindowsNT() AS LOGIC
	LOCAL ptrVI		IS	_winOSVERSIONINFO
	//
	ptrVI.dwOSVersionInfoSize := _Sizeof( _winOSVERSIONINFO )
	GetVersionEx( @ptrVI )
	//
	RETURN ( ptrVI.dwPlatformId == (DWORD)VER_PLATFORM_WIN32_NT )
	
	
	
	
FUNCTION Fabitoa( nVal AS LONG, nBase AS WORD ) AS STRING
	LOCAL nVal2		AS	LONG
	LOCAL nDigit	AS	LONG
	LOCAL cResult	AS	STRING
	// Hey !!
	IF ( nBase > 0 )
		// First, Get absolute value
		nVal2 := Abs( nVal )
		//
		WHILE ( nVal2 > 0 )
			//
			nDigit := nVal2 % nBase
			nVal2 := nVal2 / nBase
			//
			IF ( nDigit > 9 )
				//
				nDigit := nDigit - 10
				cResult := CHR( DWORD( nDigit ) + Asc( 'a' ) ) + cResult
			ELSE
				cResult := CHR( DWORD( nDigit ) + Asc( '0' ) ) + cResult
			ENDIF
		ENDDO
		//
		IF ( nVal < 0 )
			cResult := "-" + cResult
		ELSEIF ( nVal == 0 )
			cResult := "0"
		ENDIF
	ENDIF
	//
	RETURN cResult
	
	
	
	
FUNCTION FabMakeIntResource( i AS DWORD )	AS PTR
	RETURN  PTR( _CAST, DWORD( WORD( i ) ) )
	
	
	
	
FUNCTION FabRGB2Color( dwColor AS DWORD ) AS Color
	//l Convert a RGB value to a Color Object
	//p Convert a RGB value to a Color Object
	LOCAL oColor	AS	 Color
	LOCAL hiWord	AS	WORD
	LOCAL loWord	AS	WORD
	//
	hiWord := HiWord( dwColor )
	loWord := LoWord( dwColor )
	//
	oColor  := Color{ LoByte( loWord ), HiByte( loWord ), LoByte( HiWord ) }
	RETURN oColor
	
	
	
	
FUNCTION FabSetWindowStyle( hWnd AS PTR, liAdd AS LONG ) AS LONG
	//g Window,Window/Dialog Related Classes/Functions
	//l Set Window style
	//p Set Window style
	//a <hWnd> is the Handle of the window who's style must be changed\line
	//a <liAdd> is the Style Value to set
	//r The previous Style Value
	
	LOCAL liStyle	AS	LONGINT
	// Get Style
	liStyle := GetWindowLong( hWnd, GWL_STYLE )
	liStyle := _Or( liStyle, liAdd )
	SetWindowLong( hWnd, GWL_STYLE, liStyle )
	//
	RETURN liStyle
	
	
	
	
FUNCTION FabShiftLeft( Value AS LONG, Count AS LONG ) AS LONG
	//l Bit Shift Left
	//p Bit Shift Left
	//a <Value> is the value to shift left\line
	//a <Count> indicate the number of bit to shift
	//r The Result of the Shift Left
	/*
	ShiftLeft a Value, a Count number of times
	*/
	
	LOCAL Cpt       AS LONG
	//
	FOR Cpt := 1 TO Count
		Value := ( Value << 1 )
	NEXT
	//
	RETURN Value
	
	
	
	
FUNCTION FabShiftRight( Value AS LONG, Count AS LONG ) AS LONG
	//l Bit Shift Right
	//p Bit Shift Right
	//a <Value> is the value to shift Right
	//a <Count> indicate the number of bit to shift
	//r The Result of the Shift Right
	/*
	ShiftRight a Value, a Count number of times
	*/
	LOCAL Cpt       AS LONG
	//
	FOR Cpt := 1 TO Count
		Value := ( Value >> 1 )
	NEXT
	//
	RETURN Value
	
	
	
	
FUNCTION FabValueIsSet( nInValue AS DWORD, nVal1 := 0xFFFFFFFF AS DWORD, nVal2 := 0xFFFFFFFF AS DWORD, nVal3 := 0xFFFFFFFF AS DWORD, nVal4 := 0xFFFFFFFF AS DWORD, nVal5 := 0xFFFFFFFF AS DWORD )	AS	LOGIC
	/*
	Check if One or Up to Five value are existing in a Value
	*/
	LOCAL nRes1	AS	DWORD
	LOCAL nRes2	AS	DWORD
	LOCAL nRes3	AS	DWORD
	LOCAL nRes4	AS	DWORD
	LOCAL nRes5	AS	DWORD
	LOCAL lRes	AS	LOGIC
	//
	nRes1 := _And( nInValue, nVal1 )
	nRes2 := _And( nInValue, nVal2 )
	nRes3 := _And( nInValue, nVal3 )
	nRes4 := _And( nInValue, nVal4 )
	nRes5 := _And( nInValue, nVal5 )
	//
	lRes := ( nRes1 != 0 )  .and. ( nRes2 != 0 )  .and. ( nRes3 != 0 )  .and. ( nRes4 != 0 )  .and. ( nRes5 != 0 )
	//
	RETURN lRes
	
	
	
	
FUNCTION FabWinExecPause( progname AS PSZ, cmdshow AS SHORTINT ) AS LOGIC
	//l Run and Wait for a child process to end.
	//d Run and Wait for a child process to end.
	//a <progname> indicate the child application name to run.\line
	//a <cmdshow> indicate how to show the child application window.
	//r True if the Child application has been launched.
	LOCAL lSuccess 			AS	LOGIC
	LOCAL procAttr 			IS _WINSECURITY_ATTRIBUTES
	LOCAL thAttr 			IS _WINSECURITY_ATTRIBUTES
	LOCAL sInfo 			IS _WINSTARTUPINFO
	LOCAL sResult 			IS _WINPROCESS_INFORMATION
	//
	procAttr.nLength := _sizeOf(_WINSECURITY_ATTRIBUTES)
	thAttr.nLength := _sizeOf(_WINSECURITY_ATTRIBUTES)
	sInfo.cb := _sizeOf(_WINSTARTUPINFO)
	sInfo.dwFlags := (DWORD)STARTF_USESHOWWINDOW
	sInfo.wShowWindow := (WORD)cmdshow
	//
	lSuccess := CreateProcess( progname, NULL_PSZ , @procAttr, @thAttr, FALSE , 0, null_ptr, null_ptr, @sInfo, @sResult )
	//
	IF lSuccess
		WaitForSingleObject( sResult.hProcess , INFINITE )
	ENDIF
	RETURN lSuccess
	
	
	
	
	
	