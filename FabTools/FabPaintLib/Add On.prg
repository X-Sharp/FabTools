//#include "VOSystemLibrary.vh"
//#include "VOWin32APILibrary.vh"
#using FabPaintLib
#using FreeImageAPI

FUNCTION DIBShowFitToWindow( oBmp AS FabPaintLib, hWnd AS PTR ) AS VOID STRICT
//p Show a DIB object in a Window
//a <pBmp> is the DIB object pointer to show
//a <hWnd> is the Handle of the Container Window
//d This function will show the desired DIB object in the desired Window.
//d If the Width of the DIB is bigger than the Width of the window,
//d or the Height of the DIB if bigger than the Height of the window,
//d the DIB is resized to fit into the Window.
//g Add On
    oBmp:ShowFitToWindow( hWnd )
	//
return

FUNCTION DIBCreateFromResource( hInst AS PTR, pszRes AS String ) AS FabPaintLib
//p Create a DIB object from a resource name
//a <hInst> Handle to the resource module handle
//a  This can be _GetInst() for the current Exe, or and result of LoadLibrary()
//a <pszRes> Name of the resource to use.
//d This function will read the indicated file, and create a DIB object.
//r A pointer to the DIB object
//j FUNCTION:DIBDelete
//g Add On
	Local Bmp       as  System.Drawing.Bitmap
	Local fiBmp     as  FIBitmap
	Local oDib      as  FabPaintLib
	//
	Bmp := System.Drawing.Bitmap.FromResource(hInst, pszRes)
	fiBmp := FreeImage.CreateFromBitmap( Bmp )
    // return the created object.
    oDib := FabPaintLib{ fiBmp }
RETURN oDIB

FUNCTION DIBShowFitToWindowInDC( oBmp AS FabPaintLib, hWnd AS PTR, hDC AS PTR ) AS VOID 
//p Show a DIB object in a Window
//a <pBmp> is the DIB object pointer to show
//a <hWnd> is the Handle of the Container Window
//d This function will show the desired DIB object in the desired Window.
//d If the Width of the DIB is bigger than the Width of the window,
//d or the Height of the DIB if bigger than the Height of the window,
//d the DIB is resized to fit into the Window.
//g Add On
    oBmp:ShowFitToWindowInDC( hWnd, hDC )
	//
return

FUNCTION DIBCopyScreenToBitmap ( nLeft AS LONG, nTop AS LONG, nRight AS LONG, nBottom AS LONG ) AS PTR 
//p Copy a portion of Screen to a Bitmap DIB handler
    //p Initialize a DIB from a specified screen area
    //a Screen coordinates
    //a nLeft AS LONG, nTop AS LONG, nRight AS LONG, nBottom AS LONG
    //d This function creates a DIB object from a specified screen area
    //r A logical value indicating the success of the operation
    local MemoryImage as System.Drawing.Bitmap
    local memoryGraphics as System.Drawing.Graphics
    local whSize  as System.Drawing.Size
    Local hBitmap as Ptr
    Local oDibObject as FIBitmap
    //
    whSize := System.Drawing.Size{ nRight - nLeft, nBottom - nTop }
    //
    memoryImage := System.Drawing.Bitmap{ whSize:Width, whSize:Height, System.Drawing.Imaging.PixelFormat.Format32bppArgb }
    memoryGraphics := System.Drawing.Graphics.FromImage( memoryImage )
    memoryGraphics:CopyFromScreen( nLeft, nTop, 0, 0, whSize, System.Drawing.CopyPixelOperation.SourceCopy )
    //
    oDibObject := FreeImage.CreateFromBitmap( memoryImage )
    //
    hBitmap := FreeImage.GetHBitmap( oDibObject, IntPtr.Zero, True )
    //
RETURN hBitmap

