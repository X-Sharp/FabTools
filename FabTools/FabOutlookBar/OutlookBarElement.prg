
CLASS OutlookBarElement INHERIT VObject
//l Base class for all visible elements in the OutlookBar control
//p This class serves as parent for all visible components in the Outlookbar Control
//d All visible and mousesensitive elements of the OutlookBar control are derived from
//d this base class.
//t Klaus Pietsch 07.01.2001
	//
	PROTECT _symName  AS SYMBOL
	PROTECT _oArea    AS WRect
	PROTECT _lPressed AS LOGIC
	PROTECT _lIsEnabled AS LOGIC

	ACCESS Area AS WRect  
		RETURN _oArea


	ASSIGN Area( oRect AS WRect )   
		SELF:_oArea := oRect


	ACCESS Control AS OutlookBar
//p virtual, get the OutlookBar Object
		RETURN NULL_OBJECT


	METHOD Disable() AS VOID  
	//
		SELF:_lIsEnabled := FALSE
		SELF:Update()
	//
		RETURN		 

	METHOD Enable() AS VOID  
	//
		SELF:_lIsEnabled := TRUE
		SELF:Update()
	//
		RETURN		 

	METHOD HitTest( oPoint AS Point ) AS LOGIC  
		LOCAL lRet AS LOGIC
	//
		lRet := SELF:Area:PointInSide( oPoint )
		RETURN lRet


	CONSTRUCTOR( symName ) 
    //
		SUPER()
	//
		SELF:_symName := symName
		SELF:_oArea := WRect{}
	//
		SELF:_lIsEnabled := TRUE
	//
		RETURN 


	ACCESS IsEnabled AS LOGIC  
		RETURN SELF:_lIsEnabled

	ACCESS NameSym AS SYMBOL  
		RETURN SELF:_symName


	ASSIGN NameSym( symNewName AS SYMBOL )   
		_symName := symNewName


	METHOD Update() AS VOID  
		RETURN		 // Deferred	

END CLASS

