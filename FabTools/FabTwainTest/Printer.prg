Using FabPaintLib

CLASS	FabPrinter	INHERIT	Printer
	// Handle of a DIB bitmap
	EXPORT	oImg		AS	FabPaintLib
	// Enlarge to Window size ?
	EXPORT	FitToWindow	AS	LOGIC
	// Use GDI function or VideoForWindows
	EXPORT UseGDI		AS	LOGIC
	// How many ?
	EXPORT	Qty			AS	WORD



CONSTRUCTOR( cJobName, oDevice ) 
	//
	SUPER( cJobName, oDevice )
	//
	SELF:oImg := NULL_OBJECT
	SELF:FitToWindow := FALSE
	SELF:Qty := 1
	//
 return self

METHOD	PrinterExpose( oPrinterExposeEvent ) 	
	LOCAL wWidth		as	long
	LOCAL wHeight		as	long
	LOCAL lDoItAgain	AS	LOGIC
	// Something to  Print ?
	IF ( SELF:oImg == NULL_OBJECT )
		RETURN FALSE
	ENDIF
	// Fit to Window ?
	IF ( SELF:FitToWindow )
		wWidth := SELF:iWidth
		wHeight := SELF:iHeight
	ELSE
		// Use DIB Size
		wWidth := SELF:oImg:Width
		wHeight := SELF:oImg:Height
	ENDIF
	//
	SELF:oImg:UseGDI := SELF:UseGDI
	// Draw the DIB...
	SetMapMode( SELF:hDC, MM_TEXT)
	SetViewportOrgEx( SELF:hDC, 0, 0, NULL_PTR)
	SELF:oImg:StretchDrawDC( SELF:hDC, 0,0, wWidth, wHeight )
	//
	SELF:Qty := SELF:Qty - 1
	IF ( SELF:Qty > 0 )
		lDoItAgain := TRUE
	ELSE
		lDoItAgain := FALSE
	ENDIF
	//
RETURN lDoItAgain




END CLASS
