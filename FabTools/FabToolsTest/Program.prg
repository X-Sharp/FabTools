USING System
USING System.Collections.Generic
USING System.Linq
USING System.Text


FUNCTION Start() AS VOID STRICT
    ? "Hello World! Today is ",ToDay()
    ? FabIsDiskWriteable("d:\temp")
    WAIT
	RETURN	
