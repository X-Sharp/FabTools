 
CLASS   FabTimer
//l Timer Handling
//g Timer,Timer Classes
//d The FabTimer class provide all facilities to create/delete a Timer using a OOP way.\line\line
//d To Build a FabTimer object you need to pass :\line
//d \tab - a Control/Window that will receive the WM_TIMER message\line
//d \tab - a Interval value ( 1000 per default )\line\line
//d Then you can Start the timer, and you will receive a WM_TIMER message every nInterval/1000 seconds.
//d If you need more info on how to handle the WM_TIMER message, take a look at the FabTimerControl class.
//d \line\b YOU MUST call the Stop() method to kill the Timer....\b0
	// The Control/Window that own the Timer
	PROTECT oOwner		AS	OBJECT
	// The ID of the Timer
	PROTECT wId			AS	WORD
	// Interval in 1/1000 s
	PROTECT wInterval	AS	WORD
	// Is the Timer running ?
	PROTECT lRunning	AS	LOGIC



ACCESS  Id      
//r The current Id of the Timer
RETURN SELF:wId



CONSTRUCTOR( oOwner, nInterval )       
//d Initialize the Timer by giving it's Owner and it's interval. ( in ms )
	// Every second
	Default( @nInterval, 1000 )
	//
	SELF:oOwner     := oOwner
	SELF:wInterval  := nInterval
	SELF:wId		:= __wLastTimerId + 1
	SELF:lRunning   := FALSE
	// Prepare next Timer
	__wLastTimerId := SELF:wId
	//
return 

ACCESS	Interval	
//r The Current Interval value used by the Timer
RETURN SELF:wInterval



ASSIGN	Interval( nNew )	
//d Change the Interval of the Timer at Run-Time. If the Timer is running, it's stopped, the Interval is changed, and the Timer is restarted.	
	LOCAL lState	AS	LOGIC
	//
	IF IsNumeric( nNew )
		lState := SELF:Running
		//
		SELF:Stop()
		SELF:wInterval := nNew
		IF lState
			SELF:Start( )
		ENDIF
	ENDIF
RETURN	//SELF:wInterval



ACCESS  Owner   
//r The Owner of the Timer. ( This is a Window or a Control that will receive the WM_TIMER in it's Dispatch() method )
RETURN SELF:oOwner



ASSIGN	Owner( oNew )   
//d Change the Owner of the Timer at Run-Time. If the Timer is running, it's stopped, the Owner is changed, and the Timer is restarted.
	LOCAL lState	AS	LOGIC
	//
	IF IsObject( oNew )
		lState := SELF:Running
		//
		SELF:Stop()
		SELF:oOwner := oNew
		IF lState
			SELF:Start( )
		ENDIF
	ENDIF
RETURN //SELF:oOwner



ACCESS  Running 
//r A Logical Value indicating if the Timer is running
RETURN SELF:lRunning



METHOD Start()         
//d Start the Timer, the Owner of the Timer ( A Window or a Control ) will receive the WM_TIMER in it's Dispatch() method
	LOCAL   wNewId  as      dWORD
	//
	IF !SELF:lRunning .and. ( SELF:Owner != NULL_OBJECT )
		wNewId := SetTimer( SELF:Owner:Handle(), SELF:wId, SELF:wInterval, NULL_PTR )
		IF ( wNewId > 0 )
			SELF:lRunning := TRUE
		ENDIF
	ENDIF
RETURN ( wNewId > 0 )




METHOD Stop()  
//d Stop the Timer
	IF SELF:Running
		KillTimer( SELF:Owner:Handle(), SELF:wId )
		SELF:lRunning := FALSE
	ENDIF


return self
END CLASS

/* TEXTBLOCK	!Read-Me
/-*
	The FabTimer class provide all facilities to create/delete a Timer using a OOP way.
	
	To Build a FabTimer object you need to pass :
		- a Control/Window that will receive the WM_TIMER message
		- a Interval value ( 1000 per default )
		
	Then you can Start the timer, and you will receive a WM_TIMER message every nInterval/1000 seconds.
	If you need more info on how to handle the WM_TIMER message, take a look at the FabTimerControl class.
	

	YOU MUST call the Stop() method to kill the Timer....
*-/



*/
STATIC GLOBAL __wLastTimerId    := 2031 AS      WORD




