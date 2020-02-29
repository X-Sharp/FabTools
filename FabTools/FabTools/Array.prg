// Array.prg
using System.Collections
using System.Collections.Generic

BEGIN NAMESPACE FabTools

   CLASS FabArray Inherit ArrayList
       protect lAtBottom as logic
       protect wPos as word
       
		
	CONSTRUCTOR ( capacity AS INT32 )
		Super( Capacity )
		
	CONSTRUCTOR ( initList AS ICollection )
		Super( initList )
		
	CONSTRUCTOR ( )
		Super( )
		
    private access wSize as int
        return Self:Count
        
    Access Len as int
        Return Self:Count

    METHOD Get( wiPos AS DWORD ) AS USUAL
    	LOCAL xItem := NIL AS USUAL
	    //
	    IF SELF:GoTo( wiPos )
		    xItem := SELF:current
	    ENDIF
    RETURN xItem
    
    METHOD GoTo( wPos AS DWORD ) AS LOGIC
    //p Move to a specific Item
	    LOCAL lRetValue := FALSE AS LOGIC
	    //
	    IF ( wPos > 0 ) .and. ( wPos <= SELF:wSize )
		    self:wPos := word( wPos )
		    lRetValue := TRUE
		    SELF:lAtBottom := FALSE
	    ELSEIF ( wPos == 0 )
		    lRetValue := TRUE
		    SELF:lAtBottom := FALSE
	    ENDIF
    RETURN lRetValue
    
    ACCESS Current AS USUAL 
    //p Return the currently selected Item
	    LOCAL xItem := NIL AS USUAL
	    //
	    IF ( SELF:wSize > 0 )
	    	//FabArray is using OneBased position, ArrayList is using ZeroBased positions!!!!
	        //
		    xItem := SELF[ SELF:wPos - 1 ]
	    ENDIF
    RETURN xItem
         
   END CLASS
   
END NAMESPACE // FabTools
   