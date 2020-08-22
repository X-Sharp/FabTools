USING System
USING System.Collections.Generic
USING System.Linq
USING System.Text
USING VO

STATIC FUNCTION FabDSM_Entry( pOrigin AS TW_IDENTITY, pDest AS TW_IDENTITY, dg AS DWORD, dat AS WORD, msg AS WORD, pd AS PTR ) AS SHORT PASCAL 
RETURN 0

STATIC GLOBAL ptrDSM_Entry	AS	FabDSM_Entry PTR
// Ptr to TWAIN library loaded with LoadLibrary
STATIC GLOBAL hSMLib := NULL_PTR	AS PTR


BEGIN NAMESPACE FabTwain
	
	CLASS FabTwain
		//p Link to Twain with Objects
		//d This classUsingide most needed services for TwaiUsingport in your application.
		//d Using this class, you can use a Twain compliant device, to get Images
		//d Most of needed setting have implementing, but if some are missing
		//d the class provide at least low-level acces so you can implement your need by sub-classing.
		//d When using a Twain device, you must step from step to step to set the device in the needed
		//d transferring state.
		//d Currently the FabTwain ONLY support native transfer ( Images as DIB )
		//d Future release may support File and/or memory transfer.
		//d The ModalAcquire() method and the BeginAcquire() method can show you the different step.
		//d There is the list of states in the appearing order
		//d 01. Load the Source Manager and Get the DSM_Entry (State 1 to 2)
		//d 02. Open the Source Manager (State 2 to 3)
		//d 03. Select the Source (during State 3)
		//d 04. Open the Source (State 3 to 4)
		//d 05. Negotiate Capabilities with the Source (during State 4)
		//d 06. Request the Acquisition of Data from the Source (State 4 to 5)
		//d 07. Recognize that the Data Transfer is Ready (State 5 to 6)
		//d 08. Start and Perform the Transfer (State 6 to 7)
		//d 09. Conclude the Transfer (State 7 to 6 to 5)
		//d 10. Disconnect the TWAIN Session (State 5 to 1 in sequence)
		//d
		//d You can use the FabTwain object in a Modal or Modeles way. See ModalAcquire() for more Info.
		//e // To use the FabTwain class you must at least
		//e LOCAL oTwain AS FabTwain
		//e //
		//e oTwain := FabTwain{}
		//e oTwain:ModalAcquire()
		//e
		//e // But to retrieve the Image, you must pass a Owner, and
		//e // Provide a OnTwainDibAcquire() Method
		//e LOCAL oTwain AS FabTwain
		//e //
		//e oTwain := FabTwain{ oWindow }
		//e oTwain:ModalAcquire()
		//e
		//e METHOD OnTwainDibAcquire( hDIB ) CLASS MyTwainWindow
		//e // Now the hDIB is a pointer to the Image
		//e // that you can Show or Save ( See FabPaint Library for more info )
		//j METHOD:FabTwain:ModalAcquire
		
		// enable TRACE output
		PROTECT	lTrace			AS	LOGIC
		// current state
		PROTECT	dwCurState		AS	DWORD
		// Application identify structure
		PROTECT	pAppID			AS	TW_IDENTITY
		// Source Id
		PROTECT	pSourceId		AS	TW_IDENTITY
		// Source Name ( if you don't want to use the Default one )
		PROTECT cSourceName		AS	STRING
		// last error code
		PROTECT	siError			AS	SHORT
		// User Interface setup
		PROTECT	pUI				AS	TW_USERINTERFACE
		PROTECT	lShowUI			AS	LOGIC
		// Transfer Info
		PROTECT	pPending		AS	TW_PENDINGXFERS
		PROTECT wXferMode		AS	WORD
		// DIB pointer returned by native transfer
		PROTECT	hDIB			AS	PTR
		// default window
		PROTECT	pDefWnd			AS	PTR
		PROTECT	oOwner			AS	OBJECT
		//
		//PROTECT ptrDSM_Entry	AS	FabTwain.__FabDSM_Entry PTR
		// Ptr to TWAIN library loaded with LoadLibrary
		PROTECT hSMLib 			AS PTR
		
		
		DECLARE	ACCESS ConditionCode
		DECLARE ACCESS IsTwainAvailable
		DECLARE ACCESS Owner
		DECLARE ACCESS State
		DECLARE ACCESS ErrorCode
		DECLARE ACCESS ShowUI
		DECLARE	ACCESS XResolution
		DECLARE ACCESS YResolution
		DECLARE ACCESS Contrast
		DECLARE ACCESS Brightness
		DECLARE ACCESS PixelType
		DECLARE ACCESS PixelDepth
		
		DECLARE	ASSIGN XResolution
		DECLARE	ASSIGN YResolution
		DECLARE	ASSIGN Resolution
		DECLARE	ASSIGN Contrast
		DECLARE	ASSIGN Brightness
		DECLARE	ASSIGN PixelType
		DECLARE	ASSIGN PixelDepth
		
		
		
		
		
		PROTECT METHOD __CompareType( nTypeA AS WORD, nTypeB AS WORD ) AS LOGIC PASCAL 
			// Check of Types are equal of at least that TypeA value can fit in TypeB Value
			LOCAL lMatch	AS	LOGIC
			// Same Type or Same Size ?
			lMatch := ( nTypeA == nTypeB )  .OR. ( ;
			( nTypeA <= TWTY_UINT32)  .AND. ( nTypeB <= TWTY_UINT32 )  .AND. ( SELF:__GetSizeOf(nTypeA) == SELF:__GetSizeOf(nTypeB) ) )
			//
			RETURN lMatch
			
		
		PROTECT METHOD __DefaultApp() AS VOID PASCAL 
			// Initialize a Default Application ID
			// Replace with your Own values if you want an automatic Application ID
			SELF:RegisterApp( 1,0,TWLG_USA,TWCY_USA, "1.0", "Fabrice Foray", "FabTwain", "Fab Twain" )
			RETURN
		
		PROTECT METHOD __DS( dg AS DWORD, dat AS WORD, msg AS WORD, pd AS PTR) AS LOGIC PASCAL 
			// Call the current source with a triplet. See Twain spec for more info
			LOCAL lOk		AS	LOGIC
			LOCAL cTrace	AS	STRING
			LOCAL ptrEvt	AS	TW_EVENT
			LOCAL ptrXFers	AS	TW_PENDINGXFERS
			//
			System.Diagnostics.Debug.Assert ( SELF:dwCurState >= (DWORD)TwainState.SOURCE_OPEN )
			//
			SELF:siError := SELF:__DS_Call( dg, dat, msg, pd )
			// Don't Trace STATUS or EVENT call, too sloooooooow.....
			IF ( dat != DAT_STATUS )  .AND. ( dat != DAT_EVENT)
				//
				cTrace := "DS(" + NTrim( dg ) + "," + NTrim( Dat ) + "," + NTrim( msg ) + ") => " + SELF:ErrorString
				IF ( SELF:ErrorCode != TWRC_SUCCESS)
					cTrace := cTrace + ", " + SELF:ConditionString
				ENDIF
				SELF:__Trace( cTrace )
				//
			ENDIF
			//
			lOk := ( SELF:ErrorCode == TWRC_SUCCESS )
			// Change the state based on the requested operation.
			IF ( dg == (DWORD)DG_CONTROL )
				IF ( dat == DAT_EVENT )
					IF ( msg == MSG_PROCESSEVENT )
						ptrEvt := pd
						IF ( ptrEvt.TWMessage == MSG_XFERREADY )
							SELF:__Trace( "received MSG_XFERREADY")
							SELF:State := (DWORD)TwainState.TRANSFER_READY
						ELSEIF ( ptrEvt.TWMessage == MSG_CLOSEDSREQ )
							SELF:__Trace( "received MSG_CLOSEDSREQ")
							SELF:State := (DWORD)TwainState.SOURCE_ENABLED
						ENDIF
						lOK := ( SELF:ErrorCode == TWRC_DSEVENT )
					ENDIF
				ELSEIF ( dat == DAT_PENDINGXFERS )
					IF ( msg == MSG_RESET )
						IF lOk
							SELF:State := (DWORD)TwainState.SOURCE_ENABLED
						ENDIF
					ELSEIF ( msg == MSG_ENDXFER )
						IF lOk
							ptrXFers := pd
							IF ( ptrXFers.Count > 0 )
								SELF:State := (DWORD)TwainState.TRANSFER_READY
							ELSE
								SELF:State := (DWORD)TwainState.SOURCE_ENABLED
							ENDIF
						ELSE
							IF ( SELF:State > (DWORD)TwainState.SOURCE_ENABLED )
								SELF:State := (DWORD)TwainState.SOURCE_ENABLED
							ENDIF
							SELF:__Trace( "unexpected ENDXFER failure.")
						ENDIF
					ENDIF
				ELSEIF (dat == DAT_USERINTERFACE )
					IF ( msg == MSG_DISABLEDS )
						IF lOk
							SELF:State := (DWORD)TwainState.SOURCE_OPEN
						ENDIF
					ELSEIF ( msg == MSG_ENABLEDS )
						lOk := lOk  .OR. ( SELF:ErrorCode == TWRC_CHECKSTATUS )
						IF lOk
							SELF:State := (DWORD)TwainState.SOURCE_ENABLED
						ENDIF
					ENDIF
				ELSEIF ( dat == DAT_IDENTITY )
					IF ( msg == MSG_CLOSEDS )
						IF lOk
							SELF:State := (DWORD)TwainState.SOURCE_MANAGER_OPEN
						ENDIF
					ENDIF
				ENDIF
			ELSEIF ( dg == (DWORD)DG_IMAGE )
				IF ( dat == DAT_IMAGENATIVEXFER )
					IF ( msg == MSG_GET )
						lOk := lOk  .OR. ( SELF:ErrorCode == TWRC_XFERDONE )
						IF ( SELF:ErrorCode == TWRC_XFERDONE )
							// xfer successful, still in State 7
							SELF:State := (DWORD)TRANSFERRING
						ELSEIF ( SELF:ErrorCode == TWRC_CANCEL )
							// xfer cancelled by user, still in State 7
							SELF:State := (DWORD)TRANSFERRING
						ELSE
							// something else happened
							// transition to State 7 failed
							// STAY IN STATE 6
							SELF:State := (DWORD)TwainState.TRANSFER_READY
						ENDIF
					ENDIF
				ENDIF
			ENDIF
			//
			RETURN lOk
			
		
		PROTECT METHOD __DS_Call( dg AS DWORD, dat AS WORD, msg AS WORD, pd AS PTR ) AS SHORT PASCAL 
			//the real DS Call
			LOCAL siResult	AS	SHORT
			//
			System.Diagnostics.Debug.Assert ( ptrDSM_Entry != NULL_PTR )
			// Data Source Call
			siResult := PCALL( ptrDSM_Entry, SELF:pAppID, SELF:pSourceId, dg, dat, msg, pd )
			RETURN siResult
			
		
		PROTECT METHOD __Fix32ToReal8( dwFix32 AS DWORD ) AS REAL8 PASCAL 
			// Convert a Fix32 value to a Real8 ( Extract for Twain Spec )
			LOCAL pFix 		AS TW_FIX32
			LOCAL liValue 	AS LONG
			LOCAL rValue	AS	REAL8
			//
			pFix := @dwFix32
			liValue := _OR( LONG( _CAST, pFix.Whole ) << 16, pFix.Frac )
			rValue := REAL8( liValue ) / 65536.0
			RETURN rValue
			
		
		PROTECT METHOD __FlushMessageQueue() AS VOID PASCAL 
			// Remove all pending messages for the Twain DataSource UI
			LOCAL msg	IS	_winMSG
			//
			WHILE ( ( SELF:dwCurState >= (DWORD)TwainState.SOURCE_ENABLED )  .AND. PeekMessage( @msg, NULL, 0, 0, PM_REMOVE) )
				IF !( SELF:TwainDispatch( @msg ) )
					TranslateMessage( @msg )
					DispatchMessage( @msg)
				ENDIF
			ENDDO
			RETURN
		
		PROTECT METHOD	__GetSizeOf( nType AS WORD ) AS WORD PASCAL	
			// Return the Size in bytes of a TWTY_xxx type
			LOCAL aSize	AS	ARRAY
			//
			nType := nType + 1
			//
			aSize := {  _sizeof ( BYTE ),	;
			_sizeof ( SHORT ),  ;
			_sizeof ( LONG ),   ;
			_sizeof ( BYTE ),   ;
			_sizeof ( WORD ),   ;
			_sizeof ( DWORD ),  ;
			_sizeof ( SHORT ),  ;
			_sizeof (TW_FIX32), ;
			_sizeof (TW_FRAME), ;
			32 + 2, ;
			64 + 2, ;
			128 + 2,;
			255 + 1 }
			//
			RETURN aSize[ nType ]
			
		
		PROTECT METHOD __LoadSourceManager() AS LOGIC PASCAL 
			// Load the Source Manager DLL
			LOCAL DIM ptrWinDir[ MAX_PATH ] AS BYTE
			LOCAL cDir	AS	STRING
			//
			// SM already loaded ?
			IF ( SELF:dwCurState >= (DWORD)SOURCE_MANAGER_LOADED )
				RETURN TRUE
			ENDIF
			//
			GetWindowsDirectory( @ptrWinDir, MAX_PATH )
			cDir := Mem2String( @ptrWinDir, PszLen( @ptrWinDir ) )
			//
			IF ( Right( cDir, 1 ) != "\" )
				cDir := cDir + "\"
			ENDIF
			//
			cDir := cDir + DSM_FILENAME
			IF File( cDir ) .AND. (hSMLib == NULL_PTR )
				hSMLib := LoadLibrary( String2Psz(cDir ))
			ELSE
				SELF:__Trace( "Error Loading Library." )
				hSMLib := NULL_PTR
			ENDIF
			//
			IF ( hSMLib != NULL_PTR )
				ptrDSM_Entry := GetProcAddress( hSMLib, String2Psz( DSM_ENTRYPOINT ) )
				IF ( ptrDSM_Entry != NULL_PTR )
					SELF:State := (DWORD)SOURCE_MANAGER_LOADED
				ELSE
					SELF:__Trace( "GetProcAddress() Failed." )
					FreeLibrary( hSMLib )
					hSMLib := NULL_PTR
				ENDIF
			ELSE			
				ptrDSM_Entry := NULL_PTR
			ENDIF
			//
			IF ( SELF:State != (DWORD)SOURCE_MANAGER_LOADED )
				SELF:__Trace( "LoadSourceManager() Failed." )
			ENDIF
			RETURN ( SELF:State >= (DWORD)SOURCE_MANAGER_LOADED )
			
			
		
		PROTECT METHOD __SM( dg AS DWORD, dat AS WORD, msg AS WORD, pd AS PTR) AS LOGIC PASCAL 
			// Call the Source Manager with a triplet. See the Twain Spec for more info
			LOCAL lOk	AS	LOGIC
			//
			System.Diagnostics.Debug.Assert ( SELF:State >= (DWORD)SOURCE_MANAGER_LOADED )
			//
			SELF:siError := SELF:__SM_Call( dg, dat, msg, pd )
			lOk := ( SELF:ErrorCode == TWRC_SUCCESS )
			//
			IF ( dg == (DWORD)DG_CONTROL )
				IF ( dat == DAT_PARENT )
					IF ( msg == MSG_OPENDSM )
						IF lOk
							SELF:State := (DWORD)TwainState.SOURCE_MANAGER_OPEN
						ENDIF
					ELSEIF ( msg == MSG_CLOSEDSM )
						IF lOk
							SELF:State := (DWORD)TwainState.SOURCE_MANAGER_LOADED
						ENDIF
					ENDIF
				ELSEIF ( dat == DAT_IDENTITY )
					IF ( msg == MSG_OPENDS )
						IF lOk
							SELF:State := (DWORD)TwainState.SOURCE_OPEN
						ENDIF
					ENDIF
				ENDIF
			ENDIF
			RETURN lOk
			
			
		
		PROTECT METHOD __SM_Call( dg AS DWORD, dat AS WORD, msg AS WORD, pd AS PTR ) AS SHORT PASCAL 
			// The real call to SourceManager is made here
			LOCAL siResult	AS	SHORT
			//
			System.Diagnostics.Debug.Assert ( ptrDSM_Entry != NULL_PTR )
			// Source Manager Call
			siResult := PCALL( ptrDSM_Entry, SELF:pAppID, NULL_PTR, dg, dat, msg, pd )
			RETURN siResult
			
		
		PROTECT METHOD __ToFix32( r AS REAL8 ) AS DWORD PASCAL 
			// Convert a Real8 to a Fix32
			LOCAL fix 		IS TW_FIX32
			LOCAL dw		AS	DWORD
			LOCAL value		AS	LONG
			//
			r := ( r * 65536.0 ) + 0.5
			//
			//	value := LONG( _CAST, r )
			VALUE := Integer( r )
			fix.Whole := SHORT( _CAST, ( VALUE >> 16 ) )
			fix.Frac := WORD( _CAST, _AND( VALUE, 0xFFFF ) )
			//
			dw := MAKEWPARAM( WORD(fix.Whole), fix.Frac )
			RETURN dw
			
		
		METHOD __Trace( cStringTrace AS STRING ) AS VOID PASCAL 
			// Debugging method
			//
			IF SELF:lTrace
				//
				cStringTrace := "FABTWAIN : " + cStringTrace
				//
				_DebOut32( String2Psz( cStringTrace ) )
			ENDIF
			//
			
			RETURN
			
		PROTECT METHOD __UnloadSourceManager() AS LOGIC PASCAL 
			// Unload the Source Manager DLL
			//
			SELF:siError := (SHORT)TwainResultCode.TWRC_SUCCESS
			//
			IF ( SELF:State == (DWORD)TwainState.SOURCE_MANAGER_LOADED )
				IF ( hSMLib != NULL_PTR )
					FreeLibrary(hSMLib)
					hSMLib := NULL_PTR
				ENDIF
				ptrDSM_Entry := NULL_PTR
				SELF:State := (DWORD)TwainState.PRE_SESSION
			ENDIF
			RETURN ( SELF:State == (DWORD)TwainState.PRE_SESSION )
			
		
		ACCESS AutoFeed AS LOGIC PASCAL 
			//p AutoFeed Support
			//d Get the current AutoFeed Support
			LOCAL wAutoFeed	AS	WORD
			//
			SELF:GetCapCurrent( CAP_AUTOFEED, TWTY_BOOL, @wAutoFeed )
			RETURN ( wAutoFeed == 1 )
			
			
		ASSIGN AutoFeed( lAutoFeed AS LOGIC ) AS LOGIC PASCAL 
			//p AutoFeed Support
			//d Get the current AutoFeed Support
			//
			SELF:SetCapOneValue( CAP_AUTOFEED, TWTY_BOOL, DWORD(_CAST,lAutoFeed  ) )
			//	
			
			
		DESTRUCTOR() 
			//
			SELF:Destroy()
			//
			
		METHOD BeginAcquire() AS LOGIC PASCAL 
			//p Start an Acquisition
			//d This method will start an acquisition.
			//d If Twain in no in the right state, BeginAcquire() will do all state change to go into State > 5
			//r A logical value indicating the success of the operation.
			LOCAL dwState	AS	DWORD
			LOCAL lBeginOk	AS	LOGIC
			//
			dwState := SELF:State
			lBeginOk := FALSE
			//
			IF ( SELF:State >= (DWORD)TwainState.SOURCE_MANAGER_OPEN )  .OR. ( SELF:OpenSourceManager() )
				IF ( SELF:State >= (DWORD)TwainState.SOURCE_OPEN )  .OR. ( SELF:OpenSource( SELF:SourceName )  .AND. SELF:OnTwainSourceOpen() )
					IF ( SELF:State >= (DWORD)TwainState.SOURCE_ENABLED )  .OR. ( SELF:EnableSource() )
						lBeginOk := TRUE
					ELSE
						SELF:__Trace("unable to enable Datasource" )
						SELF:OnTwainError( TWERR_ENABLE_SOURCE )
					ENDIF
				ELSE
					SELF:__Trace( "unable to open Datasource" )
					SELF:OnTwainError( TWERR_OPEN_SOURCE)
				ENDIF
			ELSE
				SELF:__Trace( "unable to load or open Source Manager" )
				SELF:OnTwainError( TWERR_OPEN_DSM )
			ENDIF
			// Error ?
			IF !lBeginOk
				// Back to previous state...
				SELF:DropToState( dwState )
			ENDIF
			//
			RETURN lBeginOk
			
			
		ACCESS Brightness AS REAL8 PASCAL 
			//p Brightness
			//d Get the current brightness value
			LOCAL dwBrightness	AS	DWORD
			LOCAL rBrightness		AS	REAL8
			//
			SELF:GetCapCurrent( ICAP_BRIGHTNESS, TWTY_FIX32, @dwBrightness )
			rBrightness := SELF:__Fix32ToReal8( dwBrightness )
			RETURN rBrightness
			
			
		ASSIGN Brightness( rBrightness AS REAL8 ) AS REAL8 PASCAL 
			//p Brightness
			//d Set the current brightness value
			//
			SELF:SetCapFix32(ICAP_BRIGHTNESS, rBrightness )
			
			
		METHOD CancelXfers() AS LOGIC PASCAL 
			//p Abort Transfer
			//d If Twain is in TRANSFER_READY state, try to reset any Pending transfer.
			//d This method is currently not used by FabTwain, as it has only means we using File/Memory transfer.
			//r A logical value indicating the success of the operation.
			// If transferring, cancel it
			SELF:EndXfer()	
			//
			IF ( SELF:dwCurState == (DWORD)TwainState.TRANSFER_READY )
				SELF:__DS( DG_CONTROL, DAT_PENDINGXFERS, MSG_RESET, SELF:pPending )
				IF ( SELF:dwCurState == (DWORD)TwainState.TRANSFER_READY )
					SELF:__Trace( "CancelXfers failed.")
				ENDIF
			ENDIF
			RETURN ( SELF:dwCurState < (DWORD) TwainState.TRANSFER_READY)
			
			
		METHOD CloseSource() AS LOGIC PASCAL 
			//p Close the DataSource
			//d Try to Close the DataSource. This should move the FabTwain state to 3 (SOURCE_MANAGER_OPEN)
			//r A logical value indicating the success of the operation.
			//
			SELF:siError := (WORD)TwainResultCode.TWRC_SUCCESS
			//
			IF ( SELF:dwCurState == (DWORD)TwainState.SOURCE_ENABLED )
				SELF:DisableSource()
			ENDIF
			IF ( SELF:dwCurState == (DWORD)TwainState.SOURCE_OPEN )
				SELF:__DS( DG_CONTROL, DAT_IDENTITY, MSG_CLOSEDS, SELF:pSourceId )
				IF ( SELF:dwCurState == (DWORD)TwainState.SOURCE_OPEN )
					SELF:__Trace("TWAIN: CLOSEDS failed.")
				ENDIF
			ENDIF
			RETURN ( SELF:dwCurState < (DWORD)TwainState.SOURCE_OPEN )
			
			
		METHOD CloseSourceManager( )  AS LOGIC PASCAL 
			//p Close the Source Manager
			//d Try to close the Source Manager ( And go to state 2 )
			//r A logical value indicating the success of the operation
			LOCAL hWnd32	AS	DWORD
			// close source if open
			SELF:CloseSource()	
			//
			IF ( SELF:State >= (DWORD)TwainState.SOURCE_MANAGER_OPEN )
				//
				hWnd32 := DWORD( _CAST, SELF:pDefWnd )
				SELF:__SM( DG_CONTROL, DAT_PARENT, MSG_CLOSEDSM, @hwnd32 )
				IF ( SELF:State >= (DWORD)TwainState.SOURCE_MANAGER_OPEN )
					SELF:__Trace("CLOSEDSM failed.")
				ENDIF
			ENDIF
			RETURN ( SELF:State < (DWORD)TwainState.SOURCE_MANAGER_OPEN )
			
			
			
		ACCESS ConditionCode AS SHORT PASCAL 
			//p Get the current status of Source or Source Manager
			//d If the Source is open, we get the state of the source
			//d If the Source Manager is open, we get the state of the manager
			//d Values can be any of :
			//d TWCC_SUCCESS			No Error
			//d TWCC_BUMMER				Unknown Error
			//d TWCC_LOWMEMORY			Not enough memory to perform operation
			//d TWCC_NODS				No Data Source
			//d TWCC_MAXCONNECTIONS		DS is connected to max possible apps
			//d TWCC_OPERATIONERROR		DS or DSM reported error
			//d TWCC_BADCAP				Unknown capability
			//d TWCC_BADPROTOCOL		Unrecognized MSG DG DAT combination
			//d TWCC_BADVALUE			Data parameter out of range
			//d TWCC_SEQERROR			DG DAT MSG out of expected sequence
			//d TWCC_BADDEST			Unknown destination App/Src in DSM_Entry
			//d TWCC_CAPUNSUPPORTED		Capability not supported by source
			//d TWCC_CAPBADOPERATION	Operation not supported by capability
			//d TWCC_CAPSEQERROR		Capability has dependancy on other capability
			//r A Short value, indicating the current state.
			LOCAL pStatus	IS	TW_STATUS
			LOCAL siResult	AS	SHORT
			LOCAL siRet		AS	SHORT
			//
			siRet := (SHORT)TWCC_BUMMER
			siResult := (SHORT)TwainResultCode.TWRC_FAILURE
			pStatus.ConditionCode := (SHORT)TWCC_BUMMER
			//
			IF ( SELF:State >= (DWORD)TwainState.SOURCE_OPEN )
				// get source status if open
				siResult := SELF:__DS_Call( DG_CONTROL, DAT_STATUS, MSG_GET, @pStatus )
			ELSEIF ( SELF:State == (DWORD)TwainState.SOURCE_MANAGER_OPEN )
				// otherwise get source manager status
				siResult := SELF:__SM_Call( DG_CONTROL, DAT_STATUS, MSG_GET, @pStatus )
			ELSE
				// nothing open, not a good time to get condition code!
				siRet := (SHORT)TWCC_SEQERROR
			ENDIF
			//
			IF ( SELF:State >= (DWORD)TwainState.SOURCE_MANAGER_OPEN )
				IF ( siResult == (SHORT)TwainResultCode.TWRC_SUCCESS )
					siRet := (SHORT)pStatus.ConditionCode
				ELSE
					siRet := (SHORT)TWCC_BUMMER
				ENDIF
			ENDIF
			//
			RETURN siRet
			
			
		PROTECT	ACCESS	ConditionString AS STRING PASCAL 
			// For Debug purpose
			// Get the Condition Code String
			LOCAL aCcName	AS	ARRAY
			LOCAL cResult	AS	STRING
			LOCAL nCond AS DWORD
			//
			aCcName := { "TWCC_SUCCESS", "TWCC_BUMMER", "TWCC_LOWMEMORY", "TWCC_NODS", "TWCC_MAXCONNECTIONS", ;
			"TWCC_OPERATIONERROR","TWCC_BADCAP", "<Condition Code:7>", "<Condition Code:8>", "TWCC_BADPROTOCOL", ;
			"TWCC_BADVALUE", "TWCC_SEQERROR", "TWCC_BADDEST", "TWCC_CAPUNSUPPORTED", "TWCC_CAPBADOPERATION", ;
			"TWCC_CAPSEQERROR", "TWCC_DENIED", "TWCC_FILEEXISTS", "TWCC_FILENOTFOUND", "TWCC_NOTEMPTY", ;
			"TWCC_PAPERJAM", "TWCC_PAPERDOUBLEFEED", "TWCC_FILEWRITEERROR", "TWCC_CHECKDEVICEONLINE" ;
			}
			//
			nCond := DWORD( SELF:ConditionCode ) + 1
			IF  nCond <= ALen( aCcName )
				cResult := aCcName[ nCond ]
			ELSE
				cResult := "<Condition Code:" + NTrim( SELF:ConditionCode ) + ">"
			ENDIF
			//
			RETURN cResult
			
		
		ACCESS Contrast AS REAL8 PASCAL 
			//p Contrast
			//d Get the current contrast value
			LOCAL dwContrast	AS	DWORD
			LOCAL rContrast		AS	REAL8
			//
			SELF:GetCapCurrent( ICAP_CONTRAST, TWTY_FIX32, @dwContrast )
			rContrast := SELF:__Fix32ToReal8( dwContrast )
			RETURN rContrast
			
			
		ASSIGN Contrast( rContrast AS REAL8 ) AS REAL8 PASCAL 
			//p Contrast
			//d Set the current contrast value
			//
			SELF:SetCapFix32(ICAP_CONTRAST, rContrast )
			
			
		METHOD Convert_DPI2PPM( rDPI AS REAL8 ) AS REAL8 PASCAL 
			//p Convert a DPI value to a PPM
			//d Convert a Dot per Inch value to a Point Per Meter
			LOCAL rPPM	AS	REAL8
			// converts dpi to ppm
			rPPM := (( rDPI / 0.0254 ) + 0.5 )
			//
			RETURN rPPM
			
			
		METHOD Convert_PPM2DPI( rPPM AS REAL8 ) AS REAL8 PASCAL 
			//p Converts Point Per Meter to Dots Per Inch
			//r The PPM value converted in DPI
			LOCAL rDPI	AS	REAL8
			// converts Point Per Meter to Dots Per Inch
			rDPI := 0.0254 * rPPM
			//
			RETURN rDPI
			
			
		ACCESS CurrentUnits AS WORD PASCAL 
			//p Current Unit
			//d Get the current unit of measure the Source is using
			//d Values can be :
			//d TWUN_INCHES
			//d TWUN_CENTIMETERS
			//d TWUN_PICAS
			//d TWUN_POINTS
			//d TWUN_TWIPS
			//d TWUN_PIXELS
			//r The current unit value
			LOCAL wUnits AS	WORD
			// Default Value
			// ( 0 -> Not needed as VO var are zeroed, but just to show ! )
			wUnits := TwainUnity.TWUN_INCHES
			SELF:GetCapCurrent_Word( ICAP_UNITS, DWORD( _CAST,@wUnits) )
			//
			RETURN wUnits
			
			
		ASSIGN CurrentUnits( wUnits AS WORD ) AS WORD PASCAL 
			//p Current Unit
			//d Set the current unit of measure the Source is using
			//d Values can be :
			//d TWUN_INCHES ( Default Value )
			//d TWUN_CENTIMETERS
			//d TWUN_PICAS
			//d TWUN_POINTS
			//d TWUN_TWIPS
			//d TWUN_PIXELS
			//r The current unit value
			// Try to set the new Unit
			SELF:SetCapOneValue(ICAP_UNITS, TWTY_UINT16, DWORD(wUnits) )
			// Reset
			wUnits := TwainUnity.TWUN_INCHES
			// Now read from Twain
			SELF:GetCapCurrent_Word( ICAP_UNITS, DWORD( _CAST,@wUnits) )
			
			
		ACCESS DefaultSource AS STRING PASCAL 
			//p Retrieve the name of the Default Source
			//r A String with the name of the default source
			LOCAL dwState	AS	DWORD
			LOCAL cSource	AS	STRING
			LOCAL ptrIdent	IS	TW_IDENTITY
			//
			dwState := SELF:State
			//
			IF ( SELF:State >= (DWORD)TwainState.SOURCE_MANAGER_OPEN )  .OR. ( SELF:OpenSourceManager() )
				// Data Source Call
				SELF:__SM(DG_CONTROL, DAT_IDENTITY, MSG_GETDEFAULT, @ptrIdent )
				IF ( SELF:ErrorCode == TWRC_SUCCESS )
					cSource := Psz2String( @ptrIdent.ProductName[1] )
				ENDIF
				//
			ELSE
				SELF:__Trace( "unable to load or open Source Manager" )
				SELF:OnTwainError( TWERR_OPEN_DSM )
			ENDIF
			// Back to previous state...
			SELF:DropToState( dwState )
			//
			RETURN cSource
			
			
		METHOD Destroy() AS VOID PASCAL 
			//p Destroy the FabTwain object
			//d After this call all internal memory are freed, and the SourceManager has been unloaded.
			//d Don't try to use again the FabTwain object, or you will ... crash ...
			// shut down the Twain connection
			SELF:CloseSourceManager()
			SELF:__UnloadSourceManager()
			//
			IF ( SELF:pAppID != NULL_PTR )
				//
				MemFree( SELF:pAppID )
				SELF:pAppID := NULL_PTR
				//
				MemFree( SELF:pSourceId )
				SELF:pSourceId := NULL_PTR
				//
				MemFree( SELF:pUI )
				SELF:pUI := NULL_PTR
				//
				MemFree( SELF:pPending )
				SELF:pPending := NULL_PTR
				//
			ENDIF
			//
			//			IF !InCollect()
			//				UnRegisterAxit( SELF )
			//			ENDIF
			//
			RETURN	
			
		METHOD DisableSource() AS LOGIC PASCAL 
			//p Disable DataSource interface
			//d Cause the Source's user interface to be taken down
			//r A logical value indicating the succes of the operation
			//
			IF ( SELF:dwCurState == (DWORD)TwainState.SOURCE_ENABLED )
				SELF:__DS( DG_CONTROL, DAT_USERINTERFACE, MSG_DISABLEDS, SELF:pUI )
				//
				IF ( SELF:dwCurState == (DWORD)TwainState.SOURCE_ENABLED )
					SELF:__Trace( "TWAIN: DISABLEDS failed." )
				ELSE
					// Ok !! Bring back focus to the owner
					BringWindowToTop( SELF:pDefWnd )
				ENDIF
			ENDIF
			RETURN ( SELF:dwCurState < (DWORD)TwainState.SOURCE_ENABLED )
			
			
		METHOD DropToState( nNewState AS DWORD ) AS LOGIC PASCAL 
			//p Change the state
			//a <nNewState> is a DWORD indicating the desired state to match
			//d This method will move down the FabTwain object state to the desired one, by achieving all necessary step.
			//r A Logical value indicating the success of the operation
			LOCAL lOk	AS	LOGIC
			//
			lOk := TRUE
			//
			WHILE ( SELF:dwCurState > nNewState )
				SWITCH SELF:dwCurState
					CASE (DWORD)TwainState.TRANSFERRING 
						lOk := SELF:EndXfer()
					CASE (DWORD)TwainState.TRANSFER_READY
						lOk := SELF:CancelXfers()
					CASE (DWORD)TwainState.SOURCE_ENABLED
						lOk := SELF:DisableSource()
					CASE (DWORD)TwainState.SOURCE_OPEN
						lOk := SELF:CloseSource()
					CASE (DWORD)TwainState.SOURCE_MANAGER_OPEN
						lOk := SELF:CloseSourceManager()
					CASE (DWORD)TwainState.SOURCE_MANAGER_LOADED
						lOk := SELF:__UnloadSourceManager( )
					OTHERWISE
						lOk := FALSE
				END
				//
				IF !lOk
					EXIT
				ENDIF
			ENDDO
			RETURN lOk
			
			
		METHOD EnableSource() AS LOGIC PASCAL 
			//p Activate the Data Source User Interface
			//r A Logical value indicating the success of the operation
			//
			IF ( SELF:dwCurState != (DWORD)TwainState.SOURCE_OPEN)
				SELF:__Trace( "**WARNING** EnableSource() in wrong state.")
				RETURN FALSE
			ENDIF
			//
			SELF:SetCapOneValue(ICAP_XFERMECH, TWTY_UINT16, SELF:wXferMode)
			//
			SELF:pUI.ShowUI := (WORD)IIF( SELF:lShowUI, 1, 0 )
			SELF:pUI.hParent := SELF:pDefWnd
			SELF:pUI.ModalUI := 0
			// We can set ModalUi, but this is just a wish
			// so, we will make it modal....
			//
			SELF:__DS(DG_CONTROL, DAT_USERINTERFACE, MSG_ENABLEDS, SELF:pUI )
			IF ( SELF:dwCurState != (DWORD)TwainState.SOURCE_ENABLED )
				SELF:__Trace("EnableSource failed.")
			ENDIF
			// The source will set the ModalUI member
			// and indicates how it is working.
			//
			RETURN (SELF:dwCurState == (DWORD)TwainState.SOURCE_ENABLED )
			
			
		METHOD EndXfer() AS LOGIC PASCAL 
			//p End a Transfer
			//d Indicate to the Data Source that the transfer can terminate.
			//r A Logical value indicating the success of the operation
			//
			IF ( SELF:dwCurState == (DWORD)TwainState.TRANSFERRING)
				SELF:__DS(DG_CONTROL, DAT_PENDINGXFERS, MSG_ENDXFER, SELF:pPending )
				IF ( SELF:dwCurState == (DWORD)TwainState.TRANSFERRING )
					SELF:__Trace("EndXfer failed.")
				ENDIF
			ELSE
				SELF:__Trace("**WARNING** EndXfer in wrong state.")
			ENDIF
			RETURN ( SELF:dwCurState < (DWORD)TwainState.TRANSFERRING )
			
			
		METHOD EnumSources() AS ARRAY PASCAL 
			//p Retrieve the list of available sources
			//r An array with all avaible source names
			LOCAL dwState	AS	DWORD
			LOCAL aSources	AS	ARRAY
			LOCAL ptrIdent	IS	TW_IDENTITY
			//
			aSources := {}
			dwState := SELF:State
			//
			IF ( SELF:State >= (DWORD)TwainState.SOURCE_MANAGER_OPEN )  .OR. ( SELF:OpenSourceManager() )
				// Data Source Call
				SELF:__SM(DG_CONTROL, DAT_IDENTITY, MSG_GETFIRST, @ptrIdent )
				IF ( SELF:ErrorCode == TwainResultCode.TWRC_SUCCESS )
					AAdd( aSources, Psz2String( @ptrIdent.ProductName[1] ) )
				ENDIF
				//
				WHILE ( SELF:ErrorCode == TwainResultCode.TWRC_SUCCESS )
					SELF:__SM(DG_CONTROL, DAT_IDENTITY, MSG_GETNEXT, @ptrIdent )
					IF ( SELF:ErrorCode == TwainResultCode.TWRC_SUCCESS )
						AAdd( aSources, Psz2String( @ptrIdent.ProductName[1] ) )
					ENDIF
				ENDDO
				//
			ELSE
				SELF:__Trace( "unable to load or open Source Manager" )
				SELF:OnTwainError( TWERR_OPEN_DSM )
			ENDIF
			// Back to previous state...
			SELF:DropToState( dwState )
			//
			RETURN aSources
			
			
		ACCESS ErrorCode AS SHORT PASCAL 
			//p Last Error Code
			//d Return the last error code of the Source Manager or the Data Source
			//r The last Error Code in numerical format
			RETURN SELF:siError
			
			
		ACCESS ErrorString AS STRING PASCAL 
			//p Last Error String
			//d Return the last error string of the Source Manager or the Data Source
			//r The string indicating the last error
			//s
			LOCAL aRcName	AS	ARRAY
			LOCAL cResult	AS	STRING
			//
			aRcName := { "TWRC_SUCCESS", "TWRC_FAILURE", "TWRC_CHECKSTATUS", "TWRC_CANCEL", "TWRC_DSEVENT", ;
			"TWRC_NOTDSEVENT", "TWRC_XFERDONE", "TWRC_ENDOFLIST", "TWRC_INFONOTSUPPORTED", "TWRC_DATANOTAVAILABLE" ;
			}
			//
			IF ( SELF:ErrorCode + 1 ) <= SHORT( ALen( aRcName ) )
				cResult := aRcName[ SELF:ErrorCode + 1 ]
			ELSE
				cResult := "<Error Code:" + NTrim( SELF:ErrorCode ) + ">"
			ENDIF
			//
			RETURN cResult
			
			
		ACCESS FeederEnabled AS LOGIC PASCAL 
			//p FeederEnabled Support
			//d Get the current FeederEnabled Support
			LOCAL wFeederEnabled	AS	WORD
			//
			SELF:GetCapCurrent( CAP_FEEDERENABLED, TWTY_BOOL, @wFeederEnabled )
			RETURN ( wFeederEnabled == 1 )
			
			
		ASSIGN FeederEnabled( lFeederEnabled AS LOGIC ) AS LOGIC PASCAL 
			//p FeederEnabled Support
			//d Get the current FeederEnabled Support
			//
			SELF:SetCapOneValue( CAP_FEEDERENABLED, TWTY_BOOL, DWORD(_CAST,lFeederEnabled  ) )
			//	
			
			
		METHOD GetCapCurrent( Cap AS WORD, ItemType AS WORD, pRetValue AS PTR ) AS LOGIC PASCAL 
			//p Get a Capability
			//a <Cap>		The Capability to set
			//a <ItemType>	The Type as a TWTY_xxx define
			//a <pRetValue>	The pointer to the Value
			//d Get a capability by calling the DataSource. Teh DataSource can return different type
			//d that FabTwain may not handle. Refer to the DataSource doc if any.
			//d FabTwain can get a value from Enumeration or OneValue.
			//r A logical value indicating the succes of the operation.
			LOCAL	ptrCap		IS	TW_CAPABILITY
			LOCAL	lOk			AS	LOGIC
			LOCAL	pValue		AS	PTR
			LOCAL 	pEnum		AS	TW_ENUMERATION
			LOCAL 	pOne		AS	TW_ONEVALUE
			LOCAL	index		AS	DWORD
			LOCAL 	pItem		AS	PTR
			//
			lOk := FALSE
			IF ( SELF:State < (DWORD)TwainState.SOURCE_OPEN )
				//
				SELF:__Trace( "Error : " +NTrim( TWERR_NOT_4 ) )
				RETURN lOk
			ELSE
				// Fill in capability structure
				// capability id
				ptrCap.Cap := Cap
				// Ask for... ( but may be ignored ! )
				ptrCap.ConType := (WORD)TWON_ONEVALUE
				// This is were we will receive the value
				ptrCap.hContainer := NULL_PTR
				// No Error and Data Returned
				IF ( SELF:__DS( DG_CONTROL, DAT_CAPABILITY, MSG_GETCURRENT, @ptrCap) == TRUE )  .AND. ( ptrCap.hContainer != NULL_PTR )
					// Get a ptr to memory
					pValue := GlobalLock( ptrCap.hContainer )
					IF ( pValue != NULL_PTR )
						// The value may be returned as...
						IF ( ptrCap.ConType == TWON_ENUMERATION )
							//
							pEnum := pValue
							index := pEnum.CurrentIndex
							// In Interval and Same type as asked
							IF ( ( index < pEnum.NumItems )  .AND. SELF:__CompareType( pEnum.ItemType, ItemType ) )
								// BUG Correction : 2003.07.14 Fab
								pItem := PTR(_CAST, DWORD(_CAST,@pEnum.ItemList[1]) + Index*SELF:__GetSizeOf( ItemType ) )
								MemCopy( pRetValue, pItem, SELF:__GetSizeOf( ItemType ) )
								lOk := TRUE
							ENDIF
						ELSEIF ( ptrCap.ConType == TWON_ONEVALUE )
							//
							pOne := pValue
							// Is the Data Type Ok ?
							IF ( SELF:__CompareType( pOne.ItemType, ItemType ) )
								MemCopy( pRetValue, @pOne.Item, SELF:__GetSizeOf( ItemType ) )
								lOk := TRUE
							ENDIF
						ENDIF
						// Release Ptr
						GlobalUnlock( ptrCap.hContainer )
					ENDIF
					// And free memory
					GlobalFree( ptrCap.hContainer)
				ENDIF
			ENDIF
			RETURN lOk
			
			
		METHOD GetCapCurrent_DWord( Cap AS WORD, ptrDWord AS DWORD ) AS LOGIC PASCAL 
			//p Get a DWORD capability
			//d This function is used to get info from the Twain Data Source.
			//r The corresponding DWORD
			//j ACCESS:FabTwain:PixelType
			//j METHOD:FabTwain:GetCapCurrent
			RETURN SELF:GetCapCurrent( Cap, TWTY_UINT32, ptrDWord )
			
			
		METHOD GetCapCurrent_Long( Cap AS WORD, ptrLong AS DWORD ) AS LOGIC PASCAL 
			//p Get a LONG capability
			//d This function is used to get info from the Twain Data Source.
			//r The corresponding LONG
			//j ACCESS:FabTwain:PixelType
			//j METHOD:FabTwain:GetCapCurrent
			RETURN SELF:GetCapCurrent( Cap, TWTY_INT32, ptrLong )
			
			
		METHOD GetCapCurrent_Short( Cap AS WORD, ptrShort AS DWORD ) AS LOGIC PASCAL 
			//p Get a SHORT capability
			//d This function is used to get info from the Twain Data Source.
			//r The corresponding SHORT
			//j ACCESS:FabTwain:PixelType
			//j METHOD:FabTwain:GetCapCurrent
			RETURN SELF:GetCapCurrent( Cap, TWTY_INT16, ptrShort )
			
			
		METHOD GetCapCurrent_Word( Cap AS WORD, ptrWord AS DWORD ) AS LOGIC PASCAL 
			//p Get a LONG capability
			//d This function is used to get info from the Twain Data Source.
			//r The corresponding LONG
			//j ACCESS:FabTwain:PixelType
			//j METHOD:FabTwain:GetCapCurrent
			RETURN SELF:GetCapCurrent( Cap, TWTY_UINT16, ptrWORD )
			
			
		METHOD GetImageLayout( left AS REAL8 PTR, top AS REAL8 PTR, width AS REAL8 PTR, height AS REAL8 PTR) AS LOGIC PASCAL 
			//p Get the physical position of Image for next transfer
			//r A Logical value indicating the success of the operation
			LOCAL layout 	IS	TW_IMAGELAYOUT
			LOCAL lOk		AS	LOGIC
			//
			lOk := SELF:__DS( DG_IMAGE, DAT_IMAGELAYOUT, MSG_GET, @layout)
			IF lOk
				REAL8( left ) := SELF:__Fix32ToReal8(layout.Frame.Left.dw )
				REAL8( top ) := SELF:__Fix32ToReal8(layout.Frame.Top.dw)
				REAL8( width ) := SELF:__Fix32ToReal8(layout.Frame.Right.dw) - REAL8(left)
				REAL8( height ) := SELF:__Fix32ToReal8(layout.Frame.Bottom.dw) - REAL8(top)
			ELSE
				REAL8( left ) := 0
				REAL8( top ) := 0
				REAL8( width ) := 0
				REAL8( height ) := 0
			ENDIF
			RETURN lOk
			
			
		CONSTRUCTOR( oOwner ) 
			//p Initialize the FabTwain Object
			//a <oOwner> is the Owner of the FabTwain object
			//a This object can be a Window or a Control, and provide some event handler to catch FabTwain Events.
			//
			//RegisterAxit( SELF ) // Irrevelant in XSharp
			//
			SELF:pAppID := MemAlloc( _SIZEOF( TW_IDENTITY ) )
			SELF:pSourceId := MemAlloc( _SIZEOF( TW_IDENTITY ) )
			SELF:cSourceName := ""
			SELF:pUI := MemAlloc( _SIZEOF( TW_USERINTERFACE ) )
			SELF:pPending := MemAlloc( _SIZEOF( TW_PENDINGXFERS ) )
			//
			SELF:pDefWnd := NULL_PTR
			SELF:dwCurState := (DWORD)TwainState.NO_TWAIN_STATE
			//
			SELF:lShowUI := TRUE
			SELF:hDib := NULL_PTR
			//			SELF:ptrDSM_Entry := NULL_PTR
			SELF:siError := (DWORD)TWRC_SUCCESS
			// turn off if you get tired of seeing the output:
			#IFDEF __DEBUG__
				SELF:lTrace := TRUE
			#ELSE
				SELF:lTrace := FALSE
			#ENDIF
			// Fill Application Identification with default values
			SELF:__DefaultApp()
			SELF:State := (DWORD)TwainState.PRE_SESSION
			//
			IF IsObject( oOwner )
				SELF:Owner := oOwner
			ENDIF
			
		ACCESS IsTwainAvailable AS LOGIC PASCAL 
			//r A logical Value indicating if a TWAIN Source Manager is available.
			LOCAL lOk	AS	LOGIC
			//
			IF ( ptrDSM_Entry == NULL_PTR )
				lOk := SELF:__LoadSourceManager()
			ELSE
				lOk := TRUE
			ENDIF
			RETURN lOk
			
			
		METHOD ModalAcquire() AS VOID PASCAL 
			//p Acquire Image
			//d This method will start a Modal Acquire operation.
			//d The Data Source UI MUST be Visible ( See ShowUI )
			//d The Operation will end by Image tranasfer or User abort.
			//j ASSIGN:FabTwain:ShowUI
			LOCAL dwState	AS	DWORD
			//
			dwState := SELF:State
			//
			IF ( SELF:BeginAcquire() )
				// Disable Owner
				EnableWindow( SELF:pDefWnd, FALSE )
				// Now, run a Exec/Dispatch
				SELF:ModalEventLoop()
				// Enable Owner
				EnableWindow( SELF:pDefWnd, TRUE)
				// And come back to state
				SELF:DropToState( dwState )
			ELSE
				// BeginAcquire DropToState on errors
				// Self:DropToState( dwState )
			ENDIF
			RETURN
			
		METHOD ModalEventLoop() AS VOID PASCAL 
			// Extract messages from the Message Stack, and Query the DataSource to check if the message
			// is for the User Interface or for our App.
			LOCAL msg	IS	_winMSG
			//
			WHILE ( ( SELF:dwCurState >= (DWORD)TwainState.SOURCE_ENABLED )  .AND. GetMessage( @msg, NULL, 0, 0 ) )
				IF !( SELF:TwainDispatch( @msg ) )
					TranslateMessage( @msg )
					DispatchMessage( @msg)
				ENDIF
			ENDDO
			RETURN
			
		METHOD NativeXfer() AS LOGIC PASCAL 
			// The real acquisition of the Image
			// We come here, from TwainDispatch() that called XFerReady() where we have checked the Twain Transfer Mode
			// then to this method where we get Image from DS then callback OnTwainDibAcquire()
			LOCAL hNative AS	PTR
			// Get next native image
			SELF:__DS( DG_IMAGE, DAT_IMAGENATIVEXFER, MSG_GET, @hNative )
			//
			IF ( SELF:ErrorCode != TWRC_XFERDONE )
				// transfer failed for some reason or another
				hNative := NULL
				SELF:__Trace( "NativeXfer failed.")
			ENDIF
			//
			System.Diagnostics.Debug.Assert( SELF:dwCurState >= (DWORD)TwainState.TRANSFER_READY)
			// acknowledge & end transfer
			SELF:EndXfer()
			//
			System.Diagnostics.Debug.Assert( (SELF:dwCurState == (DWORD)TwainState.TRANSFER_READY)  .OR. (SELF:dwCurState == (DWORD)TwainState.SOURCE_ENABLED) )
			//
			SELF:__FlushMessageQueue()
			//
			IF ( hNative != NULL_PTR )
				// call back with DIB
				SELF:__Trace( "Calling DibReceived...")
				SELF:OnTwainDibAcquire( hNative )
			ENDIF
			//
			IF !( SELF:lShowUI )
				//
				SELF:DisableSource()
				//
			ENDIF
			//
			RETURN (hNative != NULL )
			
			
		METHOD OnTwainDibAcquire( hDIB AS PTR ) AS VOID PASCAL  
			//p Acquire notification
			//a <hDIB> is a global handler to image in DIB format
			//d This method will call the Owner OnTwainDibAcquire() if present for further processing.
			//d Unless the DIB image is freed.
			//s
			//
			IF IsMethod( SELF:oOwner, #OnTwainDibAcquire )
				//
				Send( SELF:oOwner, #OnTwainDibAcquire, hDib )
			ELSE
				GlobalFree( hDIB )
			ENDIF
			RETURN	
			
		METHOD OnTwainError( dwError AS DWORD ) AS VOID PASCAL 
			//p Twain Error notifications
			//d Called when an unexpected TWAIN malfunction occurs.
			//d !! Warning !!! The error code here are not related to the ErrorCode and ErrorString access.
			//d These indicate an abnormal function, not an error of the Source Manager or the Data Source
			//d This method is called in the Owner if it exist.
			//d Error Codes can be :
			//d	TWERR_OPEN_DSM		unable to load or open Source Manager
			//d	TWERR_OPEN_SOURCE	unable to open Datasource
			//d	TWERR_ENABLE_SOURCE	unable to enable Datasource
			//d	TWERR_NOT_4			capability set outside state 4 (SOURCE_OPEN)
			//d	TWERR_CAP_SET		capability set failed
			//d TWERR_GLOBALALLOC	Cannot allocate memory in SetCapOneValue
			//d TWERR_LOCKMEMORY	Error Locking bitmap into memoru
			//d TWERR_CREATEFILE	Error creating file
			//j ACCESS:FabTwain:ErrorCode
			//j ACCESS:FabTwain:ErrorString
			// See TWERR_XXX declarations
			// TWERR_OPEN_DSM, ...
			//s
			IF IsMethod( SELF:oOwner, #OnTwainError )
				//
				Send( SELF:oOwner, #OnTwainError, dwError )
			ENDIF
			
			RETURN
			
		METHOD OnTwainSourceOpen() AS LOGIC PASCAL 
			//p Source Open CallBack
			//d This method is called by BeginAcquire() after source has been successfully opened.
			//d Use this call-back to negotiate any special capabilities for the session.
			//d This method will call the Owner OnTwainSourceOpen() if present for further processing.
			//d Default does nothing.
			//r TRUE if the setting doesn't produce errors, FALSE otherwise.
			//j METHOD:FabTwain:BeginAcquire
			LOCAL uRet	AS	USUAL
			LOCAL lOk	AS	LOGIC
			//
			IF IsMethod( SELF:oOwner, #OnTwainSourceOpen )
				//
				uRet := Send( SELF:oOwner, #OnTwainSourceOpen )
				IF IsLogic( uRet )
					lOk := uRet
				ELSE
					// Suppose Ok ...
					lOk := TRUE
				ENDIF
				//
			ELSE
				lOk := TRUE
			ENDIF
			RETURN lOk
			
			
		METHOD OnTwainStateChange( dwNew AS DWORD ) AS VOID PASCAL  
			//p Change State notification
			//a <dwNew> is the new state of Twain
			//d This method will call the Owner OnTwainStateChange() if present for further processing.
			//s
			//
			IF IsMethod( SELF:oOwner, #OnTwainStateChange )
				//
				Send( SELF:oOwner, #OnTwainStateChange, dwNew )
			ENDIF
			RETURN
			
		METHOD OpenDefaultSource() AS LOGIC PASCAL 
			//p Open the Default Data Source
			//d The Data Source is the "real" device driver.
			//r	A Logical value indicating the success of the operation
			//
			RETURN SELF:OpenSource( "" )
			
			
		METHOD OpenSource( cSource AS STRING ) AS LOGIC PASCAL 
			//p Open the Default Data Source
			//d The Data Source is the "real" device driver.
			//r	A Logical value indicating the success of the operation
			LOCAL ptrIdent	IS	TW_IDENTITY
			LOCAL cListed	AS	STRING
			LOCAL lFound	AS	LOGIC
			//
			lFound := FALSE
			IF ( SELF:dwCurState != (DWORD)TwainState.SOURCE_MANAGER_OPEN )
				RETURN FALSE
			ENDIF
			// First, try to locate the desired Source
			IF !Empty( cSource )
				// Data Source Call
				SELF:__SM(DG_CONTROL, DAT_IDENTITY, MSG_GETFIRST, @ptrIdent )
				IF ( SELF:ErrorCode == TWRC_SUCCESS )
					cListed := Psz2String( @ptrIdent.ProductName[1] )
					lFound := ( cSource == cListed )
				ENDIF
				//
				WHILE ( SELF:ErrorCode == TWRC_SUCCESS )  .AND. !lFound
					SELF:__SM(DG_CONTROL, DAT_IDENTITY, MSG_GETNEXT, @ptrIdent )
					IF ( SELF:ErrorCode == TWRC_SUCCESS )
						cListed := Psz2String( @ptrIdent.ProductName[1] )
						lFound := ( cSource == cListed )
					ENDIF
				ENDDO
				//
				IF !lFound
					RETURN FALSE
				ENDIF
				// Copy the found TW_IDENTITY
				MemCopy( SELF:pSourceId, @ptrIdent, _sizeof( TW_IDENTITY ) )
			ELSE
				// open the system default source
				SELF:pSourceId.ProductName[ 1 ] := 0
				SELF:pSourceId.Id := 0
			ENDIF
			// Data Source Call
			SELF:__SM(DG_CONTROL, DAT_IDENTITY, MSG_OPENDS, SELF:pSourceId )
			IF ( SELF:dwCurState != (DWORD)TwainState.SOURCE_OPEN )
				SELF:__Trace( "OPENDS failed.")
			ENDIF
			//
			RETURN ( SELF:dwCurState == (DWORD)TwainState.SOURCE_OPEN)
			
			
		METHOD OpenSourceManager() AS LOGIC PASCAL 
			//p Open the Twain Source Manager
			//d The source manager is the Twain "heart", that will interface with Data Sources.
			//r A Logical value indicating the success of the operation
			LOCAL hWnd	AS	PTR
			//
			hWnd := SELF:pDefWnd
			//
			IF SELF:__LoadSourceManager( )
				SELF:__SM( DG_CONTROL, DAT_PARENT, MSG_OPENDSM, @hWnd )
				IF ( SELF:dwCurState != (DWORD)TwainState.SOURCE_MANAGER_OPEN )
					SELF:__Trace( "OPENDSM failed." )
				ENDIF
			ENDIF
			RETURN ( SELF:dwCurState >= (DWORD)TwainState.SOURCE_MANAGER_OPEN)
			
			
		ACCESS Owner AS OBJECT PASCAL 
			//p Owner of the FabTwain object
			//r The current owner of the FabTwain object
			RETURN SELF:oOwner
			
			
		ASSIGN Owner( oOwner AS OBJECT ) AS OBJECT PASCAL 
			//p Set the Owner of the FabTwain object
			//d This object is used by Twain as Owner of Twain dialog,
			//d and used by FabTwain as destination of all notifications
			//
			IF IsMethod( oOwner, #Handle )
				//
				SELF:oOwner := oOwner
				SELF:pDefWnd := SELF:oOwner:Handle()
			ENDIF
			//
			
			
		ACCESS PendingCount AS SHORT PASCAL 
			//p Transfer pending Count
			//r The current transfer pending count value
			RETURN SHORT( SELF:pPending.Count )
			
			
		ACCESS PhysicalHeight AS REAL8 PASCAL 
			//p Physical Height
			//d Get the current maximum Physical Height the source can acquire ( in current units )
			//j ACCESS:FabTwain:CurrentUnits
			// Pixel per Units ( Seee CurrentUnits )
			LOCAL dwPH		AS DWORD
			LOCAL rPH		AS	REAL8
			//
			SELF:GetCapCurrent( ICAP_PHYSICALHEIGHT, TWTY_FIX32, @dwPH )
			rPH := SELF:__Fix32ToReal8( dwPH )
			RETURN rPH
			
			
		ACCESS PhysicalWidth AS REAL8 PASCAL 
			//p Physical Width
			//d Get the current maximum Physical Width the source can acquire ( in current units )
			//j ACCESS:FabTwain:CurrentUnits
			// Pixel per Units ( Seee CurrentUnits )
			LOCAL dwPW		AS DWORD
			LOCAL rPW		AS	REAL8
			//
			SELF:GetCapCurrent( ICAP_PHYSICALWIDTH, TWTY_FIX32, @dwPW )
			rPW := SELF:__Fix32ToReal8( dwPW )
			RETURN rPW
			
		ACCESS PixelDepth AS WORD PASCAL 
			//p Current Pixel Depth ( in bits )
			//d Get the current pixel depth. This value depends on the current PixelType.
			//d Bit depth is per color channel e.g. 24-bit RGB has bit depth 8.
			//j ACCESS:FabTwain:PixelType
			LOCAL wDepth	AS	DWORD
			//
			SELF:GetCapCurrent_Word( ICAP_BITDEPTH, DWORD(_CAST,@wDepth) )
			//
			RETURN wDepth
			
			
		ASSIGN PixelDepth( wDepth AS WORD ) AS WORD PASCAL 
			//p Current Pixel Depth ( in bits )
			//d Set the current pixel depth. This value depends on the current PixelType.
			//d Bit depth is per color channel e.g. 24-bit RGB has bit depth 8.
			//j ACCESS:FabTwain:PixelType
			LOCAL wPDepth	AS	WORD
			//
			SELF:SetCapOneValue( ICAP_BITDEPTH, TWTY_UINT16, DWORD(wDepth) )
			SELF:GetCapCurrent_Word( ICAP_BITDEPTH, DWORD(_CAST,@wPDepth) )
			//
			
			
		ACCESS PixelType AS WORD PASCAL 
			//p Pixel Type
			//d Get the current Pixel Type
			//d Values can be
			//d TWPT_BW
			//d TWPT_GRAY
			//d TWPT_RGB
			//d TWPT_PALETTE
			//d TWPT_CMY
			//d TWPT_CMYK
			//d TWPT_YUV
			//d TWPT_YUVK
			//d TWPT_CIEXYZ
			//s
			LOCAL wPType	AS	WORD
			//
			SELF:GetCapCurrent_Word( ICAP_PIXELTYPE, DWORD(_CAST,@wPType) )
			//
			RETURN wPType
			
			
		ASSIGN PixelType( wType AS WORD ) AS WORD PASCAL 
			//p Pixel Type
			//d Set the current Pixel Type
			//d Values can be
			//d TWPT_BW
			//d TWPT_GRAY
			//d TWPT_RGB
			//d TWPT_PALETTE
			//d TWPT_CMY
			//d TWPT_CMYK
			//d TWPT_YUV
			//d TWPT_YUVK
			//d TWPT_CIEXYZ
			//s
			LOCAL wPType	AS	WORD
			//
			SELF:SetCapOneValue( ICAP_PIXELTYPE, TWTY_UINT16, DWORD(wType) )
			SELF:GetCapCurrent_Word( ICAP_PIXELTYPE, DWORD(_CAST,@wPType) )
			//
			
			
		METHOD RegisterApp( nMajorNum AS WORD, nMinorNum AS WORD, nLanguage AS WORD, nCountry AS WORD, ;
			cVersion AS STRING, cMfact AS STRING, cFamily AS STRING, cProduct AS STRING ) AS VOID PASCAL 
			//p Identify the Application for the Source Manager
			//d Set the indentification of the Application for the Source Manager.
			//d You MUST call this method before Opening the Source Manager.
			//d During the open, the DSM will assign an identifier to the App to track any further call
			//
			IF ( SELF:dwCurState < (DWORD)TwainState.SOURCE_MANAGER_OPEN )
				// This value is here set to 0
				// but the Source Manager will set the ID when Opening
				// This ID will then be used by the Source Manger to recognise our App
				SELF:pAppID.Id := 0
				//
				SELF:pAppID.ProtocolMajor := (WORD)TWON_PROTOCOLMAJOR
				SELF:pAppID.ProtocolMinor := (WORD)TWON_PROTOCOLMINOR
				SELF:pAppID.SupportedGroups := _XOR( DG_IMAGE, DG_CONTROL )
				//
				SELF:pAppID.Version.MajorNum := nMajorNum
				SELF:pAppID.Version.MinorNum := nMinorNum
				SELF:pAppID.Version.Language := nLanguage
				SELF:pAppID.Version.Country  := nCountry
				//
				cVersion := Left( cVersion, 33 )
				cMfact := Left( cMfact, 33 )
				cFamily := Left( cFamily, 33 )
				cProduct := Left( cProduct, 33 )
				//
				MemCopyString( @SELF:pAppID.Version.Info, cVersion, SLen( cVersion ) )
				MemCopyString( @SELF:pAppID.Manufacturer, cMfact, SLen( cMfact ) )
				MemCopyString( @SELF:pAppID.ProductFamily, cFamily, SLen( cFamily ) )
				MemCopyString( @SELF:pAppID.ProductName, cProduct, SLen( cProduct ) )
			ENDIF
			//
			RETURN
			
		ASSIGN Resolution( rRes AS REAL8 ) AS REAL8 PASCAL 
			//p X and Y Resolution
			//d Set the current X and Y Resolution in Pixel per unit
			//j ACCESS:FabTwain:CurrentUnits
			//j ASSIGN:FabTwain:XResolution
			//j ASSIGN:FabTwain:YResolution
			//
			SELF:XResolution := rRes
			SELF:YResolution := rRes
			//
			
		METHOD SaveNative( hDIB AS PTR, cFileName AS STRING ) AS LOGIC PASCAL 
			//p Write the specified DIB using the BMP format
			//a <hDib> is a pointer to a native image.
			//a <cFileName> is a string with the fullpath info of the desired BMP file.
			//r A logical value indicating the success of the operation
			LOCAL hFile			AS PTR
			LOCAL lSize			AS LONG
			LOCAL BFHeader		AS _WinBitmapFileHeader
			LOCAL BInfo			AS _WinBitmapInfoHeader
			LOCAL lRetVal		AS LOGIC
			LOCAL pszFileName	AS PSZ
			LOCAL dwClr			AS DWORD
			LOCAL dwSize		AS DWORD
			// Use Windows Low-Level Functions
			pszFileName := String2Psz( cFileName )
			hFile :=  _lcreat( pszFileName, 0 )
			lRetVal := FALSE
			dwClr := 0
			//
			IF ( hFile != NULL_PTR )
				//
				BInfo := GlobalLock( hDIB )
				//
				IF ( BInfo.biClrUsed == 0 )
					DO CASE
						CASE BInfo.biBitCount == 1
							// Monochrome bitmap -> 2 colors
							dwClr := 2
						CASE BInfo.biBitCount == 4
							// 4-bit image -> 16 colors
							dwClr := 16
						CASE BInfo.biBitCount == 8
							// 8-bit image -> 256 colors
							dwClr := 256
						CASE BInfo.biBitCount == 24
							// 24-bt image -> 0 colors in color table
							dwClr := 0
					ENDCASE
				ELSE
					dwClr := BInfo.biClrUsed
				ENDIF
				dwSize := dwClr * DWORD( _SIZEOF( _WinRGBQuad ) )		
				//
				lSize := LONG( GlobalSize( hDib ) )
				//
				IF ( BInfo != NULL_PTR )
					BFHeader := MemAlloc( _SIZEOF( _WinBitmapFileHeader ) )
					//
					BFHeader.bfType := 19778 //  'BM'
					BFHeader.bfSize := _SIZEOF( _WinBITMAPFILEHEADER ) + DWORD( lSize )
					BFHeader.bfReserved1 := 0
					BFHeader.bfReserved2 := 0
					BFHeader.bfOffBits := _SIZEOF( _WinBITMAPFILEHEADER)  + BInfo.biSize + dwSize
					// Use of Windows Huge-Write due to VO trouble with Huge Pointers
					_hwrite( hFile, (IntPtr)BFHeader, LONG(_SIZEOF( _WinBitmapFileHeader ) ) )
					// 4. Write out DIB header and packed bits to file
					_hwrite( hFile, (intPtr)BInfo, lSize )
					GlobalUnlock( hDIB )
					MemFree( BFHeader )
					lRetVal := TRUE
				ELSE
					//
					SELF:__Trace("Error locking bitmap into memory for FabTwain." + NTrim( TWERR_LOCKMEMORY ) )
					SELF:OnTwainError( TWERR_LOCKMEMORY )
				ENDIF
				_lclose( hFile )
			ELSE
				//
				SELF:__Trace("Error Creating File for FabTwain." + NTrim( TWERR_CREATEFILE ) )
				SELF:OnTwainError( TWERR_CREATEFILE )
			ENDIF
			RETURN  lRetVal
			
			
		METHOD SelectSource() AS LOGIC PASCAL 
			//p Call the Twain Source Selection Dialog
			//r A logical value indicating the success of the operation
			LOCAL NewSourceId	IS	TW_IDENTITY
			LOCAL nStartState	AS	DWORD
			LOCAL lOk		AS	LOGIC
			//
			nStartState := SELF:State
			lOk := FALSE
			//
			IF !( SELF:OpenSourceManager() )
				SELF:__Trace( "Unable to load & open TWAIN Source Manager" )
				SELF:OnTwainError( TWERR_OPEN_DSM )
			ELSE
				//
				lOk := SELF:__SM( DG_CONTROL, DAT_IDENTITY, MSG_USERSELECT, @NewSourceId )
			ENDIF
			//
			SELF:DropToState( nStartState )
			RETURN lOk
			
			
		METHOD SetCapFix32( Cap AS WORD , rValue AS REAL8 ) AS LOGIC PASCAL 
			//p Set a Capability as Fix32 value
			//a <Cap> is the Capability to set
			//a <rValue> is a Real8 value to convert in Fix32
			//r A Logical value indicating the success of the operation
			RETURN SELF:SetCapOneValue_Fix32( Cap, SELF:__ToFix32( rValue ) )
			
			
		METHOD SetCapOneValue( Cap AS WORD, ItemType AS WORD, ItemVal AS DWORD )  AS LOGIC PASCAL 
			//p Set a Capability
			//a <Cap>		The Capability to set
			//a <ItemType>	The Type as a TWTY_xxx define
			//a <ItemVal>	The Value
			//d Set a capability (setting) by calling the DataSource
			//r A logical value indicating the succes of the operation.
			LOCAL pCap		IS	TW_CAPABILITY
			LOCAL lOk		AS	LOGIC
			LOCAL pv		AS	TW_ONEVALUE
			//
			IF ( SELF:State != (DWORD)TwainState.SOURCE_OPEN )
				SELF:__Trace("Error " + NTrim( TWERR_NOT_4 ) )
				SELF:OnTwainError( TWERR_NOT_4 )
				RETURN FALSE
			ENDIF
			// capability id
			pcap.Cap := Cap
			// container type
			pcap.ConType := (WORD)TWON_ONEVALUE
			// We will store the Value in a TW_ONEVALUE structure
			pcap.hContainer :=GlobalAlloc( GHND, _SizeOf( TW_ONEVALUE ) )
			IF ( pcap.hContainer == 0 )
				SELF:__Trace("Cannot Allocate Global Memory for TWAIN." + NTrim( TWERR_GLOBALALLOC ) )
				SELF:OnTwainError( TWERR_GLOBALALLOC )
				RETURN FALSE
			ENDIF
			// Ok, get a pointer
			pv := GlobalLock( pcap.hContainer )
			// and store data and type
			pv.ItemType := ItemType
			pv.Item := ItemVal
			GlobalUnlock( pcap.hContainer )
			// Make the call
			lOk := SELF:__DS( DG_CONTROL, DAT_CAPABILITY, MSG_SET, @pcap )
			// And don't forget to free the TW_ONEVALUE structure !!
			GlobalFree( pcap.hContainer)
			RETURN lOk
			
			
		METHOD SetCapOneValue_Fix32( Cap AS WORD, dwFix AS DWORD ) AS LOGIC PASCAL 
			//p Set Capability in TW_FIX32 type
			//s
			RETURN SELF:SetCapOneValue( Cap, TWTY_FIX32, dwFix )
			
			
		METHOD SetImageLayout( left AS REAL8, top AS REAL8, width AS REAL8, height AS REAL8) AS LOGIC PASCAL 
			//p Set the physical position of Image for next transfer
			//r A Logical value indicating the success of the operation
			LOCAL layout 	IS	TW_IMAGELAYOUT
			LOCAL lOk		AS	LOGIC
			//
			IF ( SELF:dwCurState != (DWORD)TwainState.SOURCE_OPEN )
				SELF:__Trace( "capability set outside state 4 (SOURCE_OPEN)" )
				SELF:OnTwainError( TWERR_NOT_4 )
				RETURN FALSE
			ENDIF
			//
			layout.Frame.Left.dw := SELF:__ToFix32(left)
			layout.Frame.Top.dw := SELF:__ToFix32(top)
			layout.Frame.Right.dw := SELF:__ToFix32(left + width)
			layout.Frame.Bottom.dw := SELF:__ToFix32(top + height)
			//Don't know what to do with these...
			layout.DocumentNumber := 0
			layout.PageNumber := 0
			layout.FrameNumber := 0
			lOk := SELF:__DS(DG_IMAGE, DAT_IMAGELAYOUT, MSG_SET, @layout )
			RETURN lOK
			
			
		ACCESS ShowUI AS LOGIC PASCAL 
			//p Change the visibility of the DataSource UI
			//r The current visibility
			RETURN SELF:lShowUI
			
			
		ASSIGN ShowUI( lSet AS LOGIC ) AS LOGIC PASCAL 
			//p Change the visibility of the DataSource UI
			//r The current visibility
			SELF:lShowUI := lSet
			
			
		ACCESS SourceName AS STRING PASCAL 
			//p Retrieve the name of the Source that is used
			//r A String with the name of the source, Empty for the Default Source
			RETURN SELF:cSourceName
			
			
		ASSIGN SourceName( cUseSource AS STRING ) AS STRING PASCAL 
			//p Set the name of the Source that is used
			//d The ASSIGN try to locate the desired source; if is not available, the assignment is not done
			//d  and the default source will be used.
			//r A String with the name of the source, Empty for the Default Source
			LOCAL aSources AS ARRAY
			//
			aSources := SELF:EnumSources()
			IF ( AScanExact( aSources, cUseSource ) != 0 )
				SELF:cSourceName := cUseSource
			ELSE
				SELF:cSourceName := ""		
			ENDIF
			
			
		ACCESS State AS DWORD PASCAL 
			//p Current State of the Twain
			//r The current state of the FabTwain object.
			RETURN SELF:dwCurState
			
			
		PROTECT ASSIGN State( nNew AS DWORD ) AS VOID PASCAL 
			// Set the new FabTwain state ( And trace ... )
			LOCAL aState AS ARRAY
			//
			aState := {         "0:NO_TWAIN_STATE",         ;
			"1:PRE_SESSION",            ;
			"2:SOURCE_MANAGER_LOADED",  ;
			"3:SOURCE_MANAGER_OPEN",    ;
			"4:SOURCE_OPEN",            ;
			"5:SOURCE_ENABLED",         ;
			"6:TRANSFER_READY",         ;
			"7:TRANSFERRING"            }
			//
			SELF:__Trace( "State " + aState[ SELF:dwCurState + 1 ] + " -> " + aState[ nNew + 1 ]  )
			//
			SELF:dwCurState := nNew
			SELF:OnTwainStateChange( nNew )
			RETURN
		
		METHOD TwainDispatch( lpmsg AS _WINMsg ) AS LOGIC PASCAL 
			//p Check for DataSource UI Message
			//d This method will ask the DataSource to check if the message is
			//d for the DataSource User Interface, or for the application
			//d In the ModalAcquire(), the ModalEventLopp() disable the Owner, and get Windows messages,
			//d dispatching to the DataSource or the application.
			//d If you want to implement Modeless DataSource User Interface, you MUST place a call to this
			//d method in the BeforeDispatch() method of your App.
			//r TRUE if message processed by TWAIN, FALSE otherwise
			LOCAL lTwainMsg		AS	LOGIC
			LOCAL pEvent		IS	TW_EVENT
			//
			lTwainMsg := FALSE
			IF ( SELF:dwCurState >= (DWORD)TwainState.SOURCE_ENABLED )
				// source enabled
				pEvent.pEvent := lpmsg
				pEvent.TWMessage := (WORD)MSG_NULL
				// relay message to source in case it wants it
				SELF:__DS( DG_CONTROL, DAT_EVENT, MSG_PROCESSEVENT, @pEvent)
				lTwainMsg := ( SELF:ErrorCode == TWRC_DSEVENT )
				DO CASE
					CASE ( pEvent.TWMessage == MSG_XFERREADY )
						// notify by callback
						// default callback does transfers
						SELF:XferReady( lpmsg )
					CASE ( pEvent.TWMessage == MSG_CLOSEDSREQ )
						// notify by callback
						// default callback closes the source
						SELF:CloseSource()
					CASE ( pEvent.TWMessage == MSG_NULL )
						// no message returned from DS
				ENDCASE
			ENDIF
			RETURN lTwainMsg
			
			
		ACCESS XferCount AS SHORT PASCAL 
			//p Number if Images to receive
			//d Get the number of images the application wants to receive
			//r The number of images to receive
			LOCAL lOk		AS	LOGIC
			LOCAL siXFers	AS	SHORT
			//
			lOk := SELF:GetCapCurrent_Short( CAP_XFERCOUNT, DWORD(_CAST,@siXFers) )
			IF !lOk
				siXfers := 0
			ENDIF
			//
			RETURN siXFers
			
			
		ASSIGN XferCount( siXfers AS SHORT ) AS SHORT PASCAL 
			//p Number if Images to receive
			//d Set the number of images the application wants to receive
			//r The number of images to receive
			LOCAL lOk	AS	LOGIC
			//
			lOk := SELF:SetCapOneValue( CAP_XFERCOUNT, TWTY_INT16, DWORD(_CAST, siXfers ))
			IF !lOk
				siXfers := 0
			ENDIF
			//
			
			
		ACCESS XferMode AS WORD PASCAL 
			//p Retrive the current Transfer Mode
			//d Available Values are :
			//d XFER_NATIVE		Dib Transfer Mode
			//d XFER_FILE		File Transfer Mode
			//d XFER_MEMORY		Memory Transfer Mode
			//d !!! WARNING !!!
			//d Currently, FabTwain only support the Native Mode
			//r A WORD value indicating the current Transfer Mode
			RETURN SELF:wXferMode
			
			
		ASSIGN XferMode( wSet AS WORD ) AS WORD PASCAL 
			//p Set the Transfer Mode
			//d In FabTwain, only the XFER_NATIVE mode is currently supported
			//r The new transfer mode
			//s
			SELF:wXferMode := (WORD)TwainTransfer.XFER_NATIVE
			
			
		METHOD XferReady( lpmsg AS _WINMsg ) AS VOID PASCAL 
			// The TwainDispatch() has been notified by Twain that the Transfer is ready,
			// then we came here, where we check the Transfer Mode, and start the transfer
			System.Diagnostics.Debug.Assert( SELF:dwCurState == (DWORD)TwainState.TRANSFER_READY)
			//
			WHILE ( TRUE )
				DO CASE
					CASE ( SELF:XferMode == XFER_NATIVE )
						SELF:NativeXfer()
					CASE ( SELF:XferMode == XFER_FILE )
						// To Do
						// Start File Transfer
					CASE ( SELF:XferMode == XFER_MEMORY )
						// To Do
						// Start Memory Transfer
					OTHERWISE
						// ??
						SELF:__Trace( "corrupted transfer mode !")
				ENDCASE
				//
				IF ( SELF:dwCurState > (DWORD)TwainState.TRANSFER_READY)
					// Something went wrong during transfer, cancel/abort
					SELF:DropToState( (DWORD)TwainState.SOURCE_ENABLED )
					EXIT
				ENDIF
				//
				IF ( SELF:dwCurState != (DWORD)TwainState.TRANSFER_READY )
					EXIT
				ENDIF
				//
			ENDDO
			RETURN
			
		ACCESS XResolution AS REAL8 PASCAL 
			//p X Resulution
			//d Get the current X Resolution in Pixel per unit
			//j ACCESS:FabTwain:CurrentUnits
			// Pixel per Units ( Seee CurrentUnits )
			LOCAL dwXRes		AS DWORD
			LOCAL rXRes		AS	REAL8
			//
			SELF:GetCapCurrent( ICAP_XRESOLUTION, TWTY_FIX32, @dwXRes )
			rXRes := SELF:__Fix32ToReal8( dwXRes )
			RETURN rXRes
			
			
		ASSIGN XResolution( rXRes AS REAL8 ) AS REAL8 PASCAL 
			//p X Resolution
			//d Set the current X Resolution in Pixel per unit
			//j ACCESS:FabTwain:CurrentUnits
			// Pixel per Units ( Seee CurrentUnits )
			LOCAL dwXRes   AS DWORD
			//
			SELF:SetCapFix32(ICAP_XRESOLUTION, rXRes )
			//
			SELF:GetCapCurrent( ICAP_XRESOLUTION, TWTY_FIX32, @dwXRes )
			rXRes := SELF:__Fix32ToReal8( dwXRes )
			
			
			
		ACCESS YResolution AS REAL8 PASCAL 
			//p Y Resulution
			//d Get the current Y Resolution in Pixel per unit
			//j ACCESS:FabTwain:CurrentUnits
			// Pixel per Units ( Seee CurrentUnits )
			LOCAL dwXRes		AS DWORD
			LOCAL rXRes		AS	REAL8
			//
			SELF:GetCapCurrent( ICAP_YRESOLUTION, TWTY_FIX32, @dwXRes )
			rXRes := SELF:__Fix32ToReal8( dwXRes )
			RETURN rXRes
			
			
			
			
		ASSIGN YResolution( rYRes AS REAL8 ) AS REAL8 PASCAL 
			//p Y Resolution
			//d Set the current Y Resolution in Pixel per unit
			//j ACCESS:FabTwain:CurrentUnits
			// Pixel per Units ( Seee CurrentUnits )
			LOCAL dwYRes   AS DWORD
			//
			SELF:SetCapFix32(ICAP_YRESOLUTION, rYRes )
			//
			SELF:GetCapCurrent( ICAP_YRESOLUTION, TWTY_FIX32, @dwYRes )
			rYRes := SELF:__Fix32ToReal8( dwYRes )
			
			
			
	END CLASS
	
	
END NAMESPACE