CLASS OutlookBarBase INHERIT OutlookBarElement
//l Base Class for OutlookbarHeaders and -Items
//p Supply a base for OutlookBarHeaders and -Items
//d OutlookBarBase serves as the basis for OutlookBarHeaders and -Items
//t Klaus Pietsch 12.11.2000
	//
	PROTECT _cCaption AS STRING		// text to display
	PROTECT _uValue   AS USUAL		// user defined value

	ACCESS Caption AS STRING  
//l Get the caption of an base element
//p Determine the caption of this element
RETURN SELF:_cCaption


ASSIGN Caption( cNewCaption AS STRING )   
//l Set the caption for a base element
//p Sets the new caption for this element
	SELF:_cCaption := cNewCaption


CONSTRUCTOR(symName, cCaption, uValue) 
//l Initialize a OutlookBarBase object
//p Create a OutlookBarBase object
//a symName A symbol representing the name of the element
//a cCaption A string representing the caption of this element for use in its caption area
//a uValue A user defined value for this element
	SUPER( symName )
	//
	IF IsString(cCaption)
		SELF:_cCaption := cCaption
	ENDIF
	//
	IF !IsNil(uValue)
		SELF:_uValue := uValue
	ENDIF
	//

return 

ACCESS Value AS USUAL  
RETURN SELF:_uValue


ASSIGN Value( uValue AS USUAL )   
	SELF:_uValue := uValue


END CLASS

