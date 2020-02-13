CLASS Brush

#error (VTR1009) Adding members to a class defined outside of the assembly being compiled is not supported; please see the help topic for Transporter error VTR1009 for more information

// In the original VO code, these class members extend a class that is in another application or dll in the same repository.
// This is not supported in Vulcan.NET, you must use inheritance to extend a class that is declared outside of this application.

METHOD FromHandle( hNewBrush ) 
	SELF:hBrush := hNewBrush
return self
END CLASS

CLASS Control

#error (VTR1009) Adding members to a class defined outside of the assembly being compiled is not supported; please see the help topic for Transporter error VTR1009 for more information

// In the original VO code, these class members extend a class that is in another application or dll in the same repository.
// This is not supported in Vulcan.NET, you must use inheritance to extend a class that is declared outside of this application.

ACCESS CanvasArea 
	LOCAL rect       IS _WINRECT
	LOCAL oPoint     AS Point
	LOCAL oDimension AS Dimension
	//
	GetClientRect(SELF:Handle(), @rect)
	oPoint     := Point{0, 0}
	oDimension := Dimension{rect:right - rect:left, rect:bottom - rect:top}
RETURN BoundingBox{oPoint, oDimension}
END CLASS

CLASS Font

#error (VTR1009) Adding members to a class defined outside of the assembly being compiled is not supported; please see the help topic for Transporter error VTR1009 for more information

// In the original VO code, these class members extend a class that is in another application or dll in the same repository.
// This is not supported in Vulcan.NET, you must use inheritance to extend a class that is declared outside of this application.

METHOD FromHandle( hFontToCopy ) 
	LOCAL LogFont IS _WinLOGFONT
	//
	GetObject( hFontToCopy, _sizeof(_winLOGFONT), @LogFont )
	//
	SELF:lfWidth := logFont:lfWidth
    self:lfEscapement := LoWord(dword(LogFont:lfEscapement))
    self:lfOrientation := LoWord(dword(LogFont:lfOrientation))
    self:lfWeight := LoWord(dword(LogFont:lfWeight))
    SELF:lfItalic := logFont:lfItalic
    SELF:lfUnderline := logFont:lfUnderline
    SELF:lfStrikeOut := logFont:lfStrikeOut
    SELF:lfCharSet := logFont:lfCharSet
    SELF:lfClipPrecision := logFont:lfClipPrecision
    SELF:lfPitchAndFamily := logFont:lfPitchAndFamily
    //
    SELF:lfQuality := logFont:lfQuality
	SELF:lfOutPrecision := logFont:lfOutPrecision
	SELF:lfHeight := logFont:lfHeight
	SELF:lfWidth  := logFont:lfWidth
	//
	SELF:sFaceName := Mem2String( @logFont:lfFaceName[1], PszLen( @logFont:lfFaceName[1] ) )
	//
	SELF:bFontChanged := TRUE
	//
return self

END CLASS

CLASS Pen

#error (VTR1009) Adding members to a class defined outside of the assembly being compiled is not supported; please see the help topic for Transporter error VTR1009 for more information

// In the original VO code, these class members extend a class that is in another application or dll in the same repository.
// This is not supported in Vulcan.NET, you must use inheritance to extend a class that is declared outside of this application.

METHOD FromHandle( hNewPen ) 
	SELF:hPen := hNewPen
return self
END CLASS

VOSTRUCT _winIMAGELISTDRAWPARAMS
	MEMBER	cbSize		AS	DWORD
	MEMBER	himl		AS	PTR
	MEMBER	i			AS	LONG
	MEMBER	hdcDst		AS	PTR
	MEMBER	x			AS	LONG
	MEMBER	y			AS	LONG
	MEMBER	cx			AS	LONG
	MEMBER	cy			AS	LONG
	MEMBER	xBitmap		AS	LONG	// x offest from the upperleft of bitmap
	MEMBER	yBitmap		AS	LONG	// y offset from the upperleft of bitmap
	MEMBER	rgbBk		AS	LONG
	MEMBER	rgbFg		AS	LONG
	MEMBER	fStyle		AS	DWORD
	MEMBER	dwRop		AS	DWORD

_DLL FUNC ImageList_DrawIndirect( pimldp AS _winIMAGELISTDRAWPARAMS ) AS LOGIC PASCAL:COMCTL32.ImageList_DrawIndirect

