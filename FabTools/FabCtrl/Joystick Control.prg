USING VO

CLASS FabJoystickCtrl INHERIT CustomControl
//l A Joystick Control
//g Joystick
//d When you create a Joystick control, you can specify what Joystick using the Idenfitier property.
//d  Then you can set a range of coords for X/Y and Z-Axis.\line
//d When opening a Joystick control, you will capture the joystick ( only one Control can capture a joystick at a time ),
//d  and then received some messages into the Owner, indicating what event has been raised.\line
//d The Owner of the control can have the following methods :\line
//d OnFabJoyMove( ), OnFabJoyButtonDown( ), OnFabJoyButtonUp( ), OnFabJoyZMove( ).\line
//d Each method will receive a FabJoystickEvent object, reflecting the state of the joystick.
//d  Notice that on a three axis joystick, X/Y and Z movements raised two events.
//e In the following sample, we will move the Mouse cursor according to the Joystick position :
//e METHOD OnFabJoyMove( oJoyEvent ) CLASS JoyWnd
//e 	LOCAL pt IS _winPoint
//e 	//
//e 	GetCursorPos( @pt )
//e 	//	
//e 	IF( oJoyEvent:PosX <= 12 )
//e 		pt.x := pt.x + oJoyEvent:PosX - 17
//e 	ELSEIF( oJoyEvent:PosX >= 20 )
//e 		pt.x := pt.x + oJoyEvent:PosX - 15
//e 	ENDIF
//e 	//
//e 	IF( oJoyEvent:PosY <= 12)
//e 		pt.y := pt.y + oJoyEvent:PosY - 17
//e 	ELSEIF( oJoyEvent:PosY >= 20 )
//e 		pt.y := pt.y + oJoyEvent:PosY - 15
//e 	ENDIF
//e 	//
//e     SetCursorPos(pt.x, pt.y)
//e     //
//e 	SELF:oDCB1Chk:Checked := oJoyEvent:IsButton1Down
//e 	SELF:oDCB2Chk:Checked := oJoyEvent:IsButton2Down
//e 	SELF:oDCB3Chk:Checked := oJoyEvent:IsButton3Down
//e 	SELF:oDCB4Chk:Checked := oJoyEvent:IsButton4Down
	// Max of Joystisk supported
	PROTECT	dwJoys		AS	DWORD
	// Current Joystick Used
	PROTECT dwJoyUsed	AS	DWORD
	// Joystick Captured
	PROTECT lOpen		AS	LOGIC
	// Range of X Coords
	PROTECT oXRng		AS	Range
	// Range of Y Coords
	PROTECT oYRng		AS	Range
	// Range of Z Coords
	PROTECT oZRng		AS	Range
	



PROTECT METHOD __GetDevCaps( ptrDevCaps ) 
// Fill a _winJOYCAPS structure
	LOCAL dwRet	AS	DWORD
	LOCAL lOk	AS	LOGIC
	//
	IF SELF:IsPlugged
		//
		dwRet := joyGetDevCaps( SELF:Identifier, ptrDevCaps, _sizeof( _winJOYCAPS ) )
		//
		lOk := ( dwRet == JOYERR_NOERROR )
	ENDIF
	//
RETURN lOk




ACCESS AxesCount	
//r Number of axes currently in use by the joystick.
	LOCAL struDevCaps	IS	_winJOYCAPS
	LOCAL nButtons		AS	DWORD
	//
	IF ( SELF:__GetDevCaps( @struDevCaps ) )
		//
		nButtons := struDevCaps:wNumAxes
	ENDIF
RETURN nButtons




ACCESS ButtonsCount	
//r The Number of joystick buttons.
	LOCAL struDevCaps	IS	_winJOYCAPS
	LOCAL nButtons		AS	DWORD
	//
	IF ( SELF:__GetDevCaps( @struDevCaps ) )
		//
		nButtons := struDevCaps:wNumButtons
	ENDIF
RETURN nButtons




METHOD Close() 
//p Release a captured joystick
	//
	IF ( SELF:IsOpen )
		//
		joyReleaseCapture( SELF:Identifier )
		//
		SELF:lOpen := FALSE
	ENDIF
return self



METHOD Destroy() 
	//
	SELF:Close()
	//
	SUPER:Destroy()
	//
return self



METHOD Dispatch( oEvent ) 
	LOCAL oFabEvent	AS	FabJoystickEvent
	// We do the some job if messages are from Joy1 or Joy2
	// as this control can handle only one Joystick at a time, don't care.
	IF ( ( oEvent:Message == MM_JOY1BUTTONDOWN ) .OR. ( oEvent:Message == MM_JOY2BUTTONDOWN ) )
		oFabEvent := FabJoystickEvent{ oEvent:hWnd, oEvent:uMsg, oEvent:wParam, oEvent:lParam, oEvent:oWindow }
		IF IsMethod( SELF:Owner, #OnFabJoyButtonDown )
			Send( SELF:Owner, #OnFabJoyButtonDown, oFabEvent )
		ENDIF
	ELSEIF ( ( oEvent:Message == MM_JOY1BUTTONUP ) .OR. ( oEvent:Message == MM_JOY2BUTTONUP ) )
		oFabEvent := FabJoystickEvent{ oEvent:hWnd, oEvent:uMsg, oEvent:wParam, oEvent:lParam, oEvent:oWindow }
		IF IsMethod( SELF:Owner, #OnFabJoyButtonUp )
			Send( SELF:Owner, #OnFabJoyButtonUp, oFabEvent )
		ENDIF
	ELSEIF ( ( oEvent:Message == MM_JOY1MOVE ) .OR. ( oEvent:Message == MM_JOY2MOVE ) )
		oFabEvent := FabJoystickEvent{ oEvent:hWnd, oEvent:uMsg, oEvent:wParam, oEvent:lParam, oEvent:oWindow }
		IF IsMethod( SELF:Owner, #OnFabJoyMove )
			Send( SELF:Owner, #OnFabJoyMove, oFabEvent )
		ENDIF
	ELSEIF ( ( oEvent:Message == MM_JOY1ZMOVE ) .OR. ( oEvent:Message == MM_JOY2ZMOVE ) )
		oFabEvent := FabJoystickEvent{ oEvent:hWnd, oEvent:uMsg, oEvent:wParam, oEvent:lParam, oEvent:oWindow }
		IF IsMethod( SELF:Owner, #OnFabJoyZMove )
			Send( SELF:Owner, #OnFabJoyZMove, oFabEvent )
		ENDIF
	ENDIF
RETURN SUPER:Dispatch( oEvent )




ACCESS Identifier 
//r A numerical value indicating what Joystick is using the control. Values can be JOYSTICKID1, JOYSTICKID2.
RETURN SELF:dwJoyUsed




ASSIGN Identifier( dwID ) 
//p Set the value indicating what Joystick is using the control. Values can be JOYSTICKID1, JOYSTICKID2.
	LOCAL dwInt	AS	DWORD
	//
	IF !( SELF:IsOpen )
		IF ( ( dwID == JOYSTICKID1 ) .OR. ( dwID == JOYSTICKID2 ) )
			dwInt := SELF:Interval
			SELF:dwJoyUsed := dwID
			SELF:Interval := dwInt
		ENDIF
	ENDIF
	//
RETURN //SELF:dwJoyUsed




CONSTRUCTOR( oOwner, xID, oPoint, oDimension, kStyle, lDataAware ) 
//p Create a Joystick control
//d Create and Initialize a Joystick Control.\line
//d Per default, the Joystick 1 is used, and X/Y/Z axis are used there default range : 0 - 65335
	//
	SUPER( oOwner, xID, oPoint, oDimension, kStyle, lDataAware )
	//
	SELF:Hide()
	// Number of Joystick the driver is supporting
	SELF:dwJoys := joyGetNumDevs()
	// Default, used Joy1
	SELF:dwJoyUsed := JOYSTICKID1
	// Default Range
	SELF:XRange := Range{ 0, 65535 }
	SELF:YRange := Range{ 0, 65535 }
	SELF:ZRange := Range{ 0, 65535 }
	//
	SELF:Interval := 0


return 

ACCESS Interval 
//r A numerical value indicating the distance the joystick must be moved before a message is sent to
//r the window that has opened the device. The Interval is initially zero.
	LOCAL dwTh		AS	DWORD
	LOCAL dwRet		AS	DWORD
	//
	IF SELF:IsPlugged
		dwRet := joyGetThreshold( SELF:Identifier, @dwTh )
		IF ( dwRet != JOYERR_NOERROR )
			dwTh := 0
		ENDIF
	ENDIF
RETURN dwTh




ASSIGN Interval( dwThreshold ) 
//p Set the numerical value indicating the distance the joystick must be moved before a message is sent to
//p the window that has opened the device. The Interval is initially zero.
	LOCAL dwTh		AS	DWORD
	LOCAL dwRet		AS	DWORD
	//
	IF SELF:IsPlugged
		dwTh := dwThreshold
		dwRet := joySetThreshold( SELF:Identifier, dwTh )
		IF ( dwRet != JOYERR_NOERROR )
			dwTh := 0
		ENDIF
	ENDIF
RETURN 
	



ACCESS IsButton1Down 
//r A logical value indicating if the Button 1 is pressed.
	LOCAL struJoyInfo	IS	_winJoyInfo
	LOCAL dwRet			AS	DWORD
	LOCAL lDown			AS	LOGIC
	//
	IF SELF:IsPlugged
		dwRet := joyGetPos( SELF:Identifier, @struJoyInfo )
		IF ( dwRet == JOYERR_NOERROR )
			lDown := ( _And( struJoyInfo:wButtons, JOY_BUTTON1 ) != 0 )
		ENDIF
	ENDIF
RETURN lDown




ACCESS IsButton2Down 
//r A logical value indicating if the Button  is pressed.
	LOCAL struJoyInfo	IS	_winJoyInfo
	LOCAL dwRet			AS	DWORD
	LOCAL lDown			AS	LOGIC
	//
	IF SELF:IsPlugged
		dwRet := joyGetPos( SELF:Identifier, @struJoyInfo )
		IF ( dwRet == JOYERR_NOERROR )
			lDown := ( _And( struJoyInfo:wButtons, JOY_BUTTON2 ) != 0 )
		ENDIF
	ENDIF
RETURN lDown




ACCESS IsButton3Down 
//r A logical value indicating if the Button 3 is pressed.
	LOCAL struJoyInfo	IS	_winJoyInfo
	LOCAL dwRet			AS	DWORD
	LOCAL lDown			AS	LOGIC
	//
	IF SELF:IsPlugged
		dwRet := joyGetPos( SELF:Identifier, @struJoyInfo )
		IF ( dwRet == JOYERR_NOERROR )
			lDown := ( _And( struJoyInfo:wButtons, JOY_BUTTON3 ) != 0 )
		ENDIF
	ENDIF
RETURN lDown




ACCESS IsButton4Down 
//r A logical value indicating if the Button 4 is pressed.
	LOCAL struJoyInfo	IS	_winJoyInfo
	LOCAL dwRet			AS	DWORD
	LOCAL lDown			AS	LOGIC
	//
	IF SELF:IsPlugged
		dwRet := joyGetPos( SELF:Identifier, @struJoyInfo )
		IF ( dwRet == JOYERR_NOERROR )
			lDown := ( _And( struJoyInfo:wButtons, JOY_BUTTON4 ) != 0 )
		ENDIF
	ENDIF
RETURN lDown




ACCESS IsDriver 
//r A logical value indicating if a Joystick driver has been found.
	// Is Driver Available
	// At least one Joystick supported
RETURN ( SELF:dwJoys != 0 )




ACCESS IsOpen 
//r A logical value indicating if the control has captured a joystick
RETURN SELF:lOpen




ACCESS IsPlugged 
//r A logical value indicating if the joystick identified by the control is plugged
	LOCAL lPlug			AS	LOGIC
	LOCAL struJoyInfo	IS	_winJoyInfo
	LOCAL dwRet			AS	DWORD
	//
	IF SELF:IsDriver
		dwRet := joyGetPos( SELF:Identifier, @struJoyInfo )
		lPlug := ( dwRet == JOYERR_NOERROR )
	ENDIF
RETURN lPlug




ACCESS MaxAxes	
//r Maximum number of axes supported by the joystick.
	LOCAL struDevCaps	IS	_winJOYCAPS
	LOCAL nButtons		AS	DWORD
	//
	IF ( SELF:__GetDevCaps( @struDevCaps ) )
		//
		nButtons := struDevCaps:wMaxAxes
	ENDIF
RETURN nButtons




ACCESS MaxButtons	
//r The maximum number of buttons supported by the joystick.
	LOCAL struDevCaps	IS	_winJOYCAPS
	LOCAL nButtons		AS	DWORD
	//
	IF ( SELF:__GetDevCaps( @struDevCaps ) )
		//
		nButtons := struDevCaps:wMaxButtons
	ENDIF
RETURN nButtons




METHOD Open( nJoy ) 
//p Connect the control to a Joystick
//a <nJoy> indicate the joystick to use.
//a 	Value can be JOYSTICKID1 or JOYSTICKID2.
//a 	Per default, the current Identifier value is used.
//r A logical value indicating if the control is connected to the Joystick
	LOCAL dwRet	AS	DWORD
	//
	Default( @nJoy, SELF:Identifier )
	//
	IF ( nJoy != SELF:Identifier )
		SELF:Close()
	ENDIF
	//
	IF SELF:IsPlugged
		dwRet := FabjoySetCapture( SELF:Handle(), SELF:Identifier, 0, TRUE )
		IF ( dwRet == JOYERR_NOERROR )
			SELF:lOpen := TRUE
		ENDIF
	ENDIF
	//
RETURN SELF:lOpen




ACCESS PosX 
//r A numerical value indicating the joystick position on the X-Axis.\line
//r This value depends on the XRange value.
	LOCAL struJoyInfo	IS	_winJoyInfo
	LOCAL dwRet			AS	DWORD
	LOCAL dwPos			AS	DWORD
	//
	IF SELF:IsPlugged
		dwRet := joyGetPos( SELF:Identifier, @struJoyInfo )
		IF ( dwRet == JOYERR_NOERROR )
			dwPos := struJoyInfo:wXpos
			//
			dwPos := Dword( FLOAT(dwPos) / 65535 ) * ( SELF:oXRng:Max - SELF:oXRng:Min - 1 ) + SELF:oXRng:Min
		ENDIF
	ENDIF
RETURN dwPos




ACCESS PosY 
//r A numerical value indicating the joystick position on the Y-Axis.\line
//r This value depends on the YRange value.
	LOCAL struJoyInfo	IS	_winJoyInfo
	LOCAL dwRet			AS	DWORD
	LOCAL dwPos			AS	DWORD
	//
	IF SELF:IsPlugged
		dwRet := joyGetPos( SELF:Identifier, @struJoyInfo )
		IF ( dwRet == JOYERR_NOERROR )
			dwPos := struJoyInfo:wYpos
			//
			dwPos := Dword( FLOAT(dwPos) / 65535 ) * ( SELF:oYRng:Max - SELF:oYRng:Min - 1 ) + SELF:oYRng:Min
		ENDIF
	ENDIF
RETURN dwPos




ACCESS PosZ 
//r A numerical value indicating the joystick position on the Z-Axis.\line
//r This value depends on the ZRange value.
	LOCAL struJoyInfo	IS	_winJoyInfo
	LOCAL dwRet			AS	DWORD
	LOCAL dwPos			AS	DWORD
	//
	IF SELF:IsPlugged
		dwRet := joyGetPos( SELF:Identifier, @struJoyInfo )
		IF ( dwRet == JOYERR_NOERROR )
			dwPos := struJoyInfo:wZpos
			//
			dwPos := Dword( FLOAT(dwPos) / 65535 ) * ( SELF:oZRng:Max - SELF:oZRng:Min - 1 ) + SELF:oZRng:Min
		ENDIF
	ENDIF
RETURN dwPos




ACCESS ProductName	
//r A string with the Product Name.
	LOCAL struDevCaps	IS	_winJOYCAPS
	LOCAL cProd			AS	STRING
	//
	IF ( SELF:__GetDevCaps( @struDevCaps ) )
		//
		cProd := Psz2String( @struDevCaps:szPname )
	ENDIF
RETURN cProd




ACCESS XRange 
//r A Range object value indicating the Min/Max position on the X-Axis.
RETURN SELF:oXRng




ASSIGN XRange( oRange ) 
//p Set a Range object value indicating the Min/Max position on the X-Axis.
	//
	SELF:oXRng := oRange
RETURN //SELF:oXRng




ACCESS YRange 
//r A Range object value indicating the Min/Max position on the Y-Axis.
RETURN SELF:oYRng




ASSIGN YRange( oRange ) 
//p Set a Range object value indicating the Min/Max position on the Y-Axis.
	//
	SELF:oYRng := oRange
RETURN //SELF:oYRng




ACCESS ZRange 
//r A Range object value indicating the Min/Max position on the Z-Axis.
RETURN SELF:oZRng




ASSIGN ZRange( oRange ) 
//p Set a Range object value indicating the Min/Max position on the Z-Axis.
	//
	SELF:oZRng := oRange
RETURN //SELF:oZRng





END CLASS

_DLL FUNC FabjoySetCapture(hwnd AS PTR, uJoyID AS DWORD, uPeriod AS DWORD, fChanged AS LOGIC );
                        AS DWORD PASCAL:WINMM.joySetCapture
// It seems that VO is missing the fChanged parameter.




