CLASS	FabError	INHERIT	Error
//l BaseClass For Error Handling
//p Easy to use Error Class
//d This class inherit from the standard Error class. It adds a Raise() method that calls the current error handler with
//d  the object as parameter.\line
//d It's standard use, is to inherit from this class and add in the Init() method all error info. Then in your code,
//d  you just have to create a FabError-inherited object, and call Raise()
//e // You can have
//e CLASS MyError INHERIT FabError
//e METHOD Init() Class MyError
//e 	SELF:Description := "Sorry ! You can't do that"
//e 	SELF:CanRetry := False
//e
//e // And in your code
//e MyError{}:Raise()


METHOD _Break( )	
//d Branches execution to the statement immediately following the nearest RECOVER statement if one is specified,
//d  or the nearest END SEQUENCE statement.\line
//d SELF is the value returned into the Var specified in the USING clause of the RECOVER statement if any.
//s
	//
	IF CanBreak()
		_Break( SELF )
	ENDIF

RETURN self

METHOD _Raise( cbBlock )	
//p Raise an Error using the current Error Handler.
	LOCAL oErrorHandler	AS USUAL
	// Error
	IF IsNil( cbBlock )
		oErrorHandler := ErrorBlock()
	ELSE
		oErrorHandler := cbBlock
	ENDIF
	//
	Eval( oErrorHandler, SELF )
	//

RETURN self


METHOD Raise( cbBlock )	
//p Raise an Error.
//a <cbBlock> is a CodeBlock to use as Error Handler.
//a 	Default is the current Error Handler.
//d \b This method has changed since the V1.4.5 release\b0\line
//d If the method call occurs within the BEGIN SEQUENCE...END construct, a Break is issued,
//d  unless the current Error Handler is used.
//s
	LOCAL oErrorHandler	AS USUAL
	// Inside a SEQUENCE ?
	IF CanBreak()
		_Break(SELF )
	ELSE
		// Do we have a specified error handler ?
		IF IsNil( cbBlock )
			// No, Use the default one
			oErrorHandler := ErrorBlock()
		ELSE
			oErrorHandler := cbBlock
		ENDIF
		// Call the Error Handler
		Eval( oErrorHandler, SELF )
		//
	ENDIF

RETURN self


END CLASS
