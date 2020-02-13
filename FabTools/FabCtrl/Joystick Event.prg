 
USING VO


CLASS FabJoystickEvent INHERIT @@Event
//l Joystick Event
//g Joystick,Joystick Classes
	PROTECT liPosX 		AS	LONG
	PROTECT liPosY 		AS	LONG
	PROTECT liPosZ 		AS	LONG
	PROTECT dwButtons	AS	DWORD




CONSTRUCTOR( _hWnd, _uMsg, _wParam, _lParam, _oWindow ) 
	//
	SUPER( _hWnd, _uMsg, _wParam, _lParam, _oWindow )
	//
	IF ( ( _uMsg == MM_JOY1ZMOVE ) .OR. ( _uMsg == MM_JOY2ZMOVE ) )
		SELF:liPosX := -1
		SELF:liPosY := -1
		SELF:liPosZ := LoWord( DWORD( _CAST, _lParam ) )
		SELF:liPosZ := ( FLOAT( SELF:liPosZ ) / 65535 ) * ( _oWindow:ZRange:Max - _oWindow:ZRange:Min - 1 ) + _oWindow:ZRange:Min
	ELSE
		SELF:liPosX := LoWord( DWORD( _CAST, _lParam ) )
		SELF:liPosX := ( FLOAT( SELF:liPosX ) / 65535 ) * ( _oWindow:XRange:Max - _oWindow:XRange:Min - 1 ) + _oWindow:XRange:Min
		SELF:liPosY := HiWord( DWORD( _CAST, _lParam ) )
		SELF:liPosY := ( FLOAT( SELF:liPosY ) / 65535 ) * ( _oWindow:YRange:Max - _oWindow:YRange:Min - 1 ) + _oWindow:YRange:Min
		SELF:liPosZ := -1
	ENDIF
	SELF:dwButtons := _wParam
	//
return 
	




ACCESS IsButton1Down 
//r A logical value indicating if the Button 1 is pressed
RETURN ( _And( SELF:dwButtons, JOY_BUTTON1 ) != 0 )




ACCESS IsButton2Down 
//r A logical value indicating if the Button 2 is pressed
RETURN ( _And( SELF:dwButtons, JOY_BUTTON2 ) != 0 )




ACCESS IsButton3Down 
//r A logical value indicating if the Button 3 is pressed
RETURN ( _And( SELF:dwButtons, JOY_BUTTON3 ) != 0 )




ACCESS IsButton4Down 
//r A logical value indicating if the Button 4 is pressed
RETURN ( _And( SELF:dwButtons, JOY_BUTTON4 ) != 0 )
	



ACCESS PosX 
//r A numerical value indicating the position of the Joystick on the X-Axis.\line
//r ( The value depends on the X-Range )
RETURN SELF:liPosX




ACCESS PosY 
//r A numerical value indicating the position of the Joystick on the Y-Axis
//r ( The value depends on the Y-Range )
RETURN SELF:liPosY




ACCESS PosZ 
//r A numerical value indicating the position of the Joystick on the Z-Axis
//r ( The value depends on the Z-Range )
RETURN SELF:liPosZ




END CLASS

