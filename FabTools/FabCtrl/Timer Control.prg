USING VO

 
CLASS	FabTimerControl		INHERIT	CustomControl
//l A TimerControl
//g Timer,Timer Classes
//p Provide a way to handle a Control using a hidden control on a Window.\line
//d The FabTimerControl inherit from the FabCustomControl, so you can place a FabTimerControl
//d  using the Window Editor, choosing a CustomControl and the "inherit from" spec.
//d  Then in the PostInit() method of your window, you can set the Interval value that the Timer will use,
//d  and also start the timer.\line\line
	
//d If a WM_TIMER comes and the ID_Timer is ours then the Timer is stopped, searching for a OnFabTimer() method
//d  in the Owner of the FabTimerControl, passing it the FabTimerControl object.\line
//d The OnFabTimer() method can return a logical value :\line
//d \tab - True, Restart Timer when exit the OnFabTimer() Method ( Default value )\line
//d \tab - False, the Timer stay in Stop-State\line
		
//d You can change the Interval value at any moment. Thus will stop the Timer, change the Interval and restart the timer if needed.\line

//d The Timer is automatically Stopped when the FabTimerControl() is destroyed.

	PROTECT	oTimer		AS	FabTimer
	PROTECT	lStable		AS	LOGIC
	//

	DESTRUCTOR()	
	//
	IF ( SELF:oTimer != NULL_OBJECT )
		SELF:oTimer:Stop()
	ENDIF
	//Self:Axit()
	//
return 



METHOD Destroy()		
//d Destroy the TimerControl and the FabTimer object.
	//
	IF ( SELF:oTimer != NULL_OBJECT )
		SELF:oTimer:Stop()
	ENDIF
	SUPER:Destroy()
	//



return self

METHOD	Dispatch( oEvent )	
	LOCAL liRet		AS	LONG
	LOCAL uReStart	AS	USUAL
	//
	IF ( oEvent:Message == WM_TIMER ) .and. ( oEvent:wParam == SELF:Timer:ID )
		//
		IF IsMethod( SELF:Owner, #OnFabTimer )
			// Stop the Timer
			SELF:Stop()
			//
			uReStart := Send( SELF:Owner, #OnFabTimer, SELF )
			IF !IsLogic( uRestart )
				uRestart := TRUE
			ENDIF
			//
			IF uRestart
				// ReStart Timer
				SELF:Start()
			ENDIF
 		ENDIF
		liRet := 0
	ELSE
		liRet := SUPER:Dispatch( oEvent )
	ENDIF
	//
RETURN	liRet



CONSTRUCTOR( oOwner, xID, oPoint, oDimension, kStyle, lDataAware) 
//p Initialise the FabTimerControl object.
//d Per default, the Interval is set to 100ms. The Timer is NOT automatically run at creation.
	//
	SUPER(oOwner, xID, oPoint, oDimension, kStyle, lDataAware)
   	//
	SELF:oTimer := FabTimer{ SELF, 100 }
	//
	SELF:Hide()



return 

ACCESS	Running	AS LOGIC  
//r A logical Value indicating if the Timer is running
RETURN SELF:oTimer:Running




METHOD	Start() AS VOID  
//d Start Timer
	SELF:oTimer:Start()
return 

METHOD	Stop() AS VOID 	
//d Stop the Timer
	SELF:oTimer:Stop()
return

NEW ACCESS	Timer AS FabTimer 	
//d Give an access to the underlying FabTimer object
RETURN SELF:oTimer




END CLASS

/* TEXTBLOCK !Read-Me
/-*
	The FabTimerControl inherit from the FabCustomControl, so you can place a FabTimerControl
using the Window Editor, choosing a CustomControl and the "inherit from" spec.
	Then in the PostInit() method of your window, you can set the Interval value that the Timer will use,
	and also start the timer.
	
	If a WM_TIMER comes and the ID_Timer is ours then the Timer is stopped, searching for a OnFabTimer() method
in the Owner of the FabTimerControl, passing it the FabTimerControl object.
	The OnFabTimer() method can return a logical value :
		- True, Restart Timer when exit the OnFabTimer() Method ( Default value )
		- False, the Timer stay in Stop-State
		
	You can change the Interval value at any moment. Thus will stop the Timer, change the Interval and
restart the timer if needed.

	The Timer is automatically Stopped when the FabTimerControl() is destroyed.
	
!!! WARNING !!!
	New in V1.4
		Now the FabTimer IS NOT AUTOMATICALLY STARTED when the FabTimerControl is created
*-/



*/
