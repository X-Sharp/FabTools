#include "VOWin32APILibrary.vh"
_DLL FUNCTION DIBDelete(pWinBmp AS PTR) AS VOID PASCAL:FabPaint.FabDIBDelete
//p Delete an Existing DIB Object
//a <pWinBmp> Pointer to the DIB object
//d All DIBCreatexxx() function are allocating memory for C++ Objects. As we don't have a Garbage Collector,
//d it your responsability to free the memory when needed, by calling this function.
//j FUNCTION:DIBCreateCopy
//j FUNCTION:DIBCreateFromFile
//j FUNCTION:DIBCreateFromHBitmap
//j FUNCTION:DIBCreateFromHDib
//j FUNCTION:DIBCreateFromPTR

FUNCTION CAPaintIsLoaded() AS LOGIC STRICT
// DLL is now referenced statically, so always TRUE
// Same as standard CAPaint
RETURN TRUE

_DLL FUNCTION CAPaintLastError() AS LONGINT PASCAL:FabPaint.FabPaintLastError
//p Retrieve the Last Error Code
//r A psz to the Last Error Code.

_DLL FUNCTION CAPaintLastErrorMsg() AS PSZ PASCAL:FabPaint.FabPaintLastErrorMsg
//p Retrieve the Last Error String
//r A psz to the Last Error String. ( Don't try to free this PSZ !!! )

_DLL FUNCTION CAPaintShowErrors( lShow AS LOGIC) AS VOID PASCAL:FabPaint.FabPaintShowErrors
//p Activate/DeActivate the Error MessageBox
//a <lShow> A logical value indicating if Errors must be shown

_DLL FUNCTION DIBCreateCopy( pWinBmp AS PTR, BitPerPixel := 0 AS LONG ) AS PTR PASCAL:FabPaint.FabDIBCreateCopy
//p Create a DIB object from an existing DIB Object
//a <pWinBmp> 		Pointer to the existing DIB Object
//a <BitPerPixel>	Number of Bit per Pixel to use in the copy
//a		Values can be 0,1,8,32. 0 Means no change.
//d This function will copy the existing pixels, and create a DIB object.
//r A pointer to the DIB object
//j FUNCTION:DIBDelete

_DLL FUNCTION DIBCreateFromFile(pszFName AS PSZ) AS PTR PASCAL:FabPaint.FabDIBCreateFromFile
//p Create a DIB object from a File
//a <pszFName> Name of the file to read.
//d This function will read the indicated file, and create a DIB object.
//d The image can be any of : .JPG, .TIF, .BMP, .TGA, .PNG, .PCX, or .PCT.
//r A pointer to the DIB object
//j FUNCTION:DIBDelete

_DLL FUNCTION DIBCreateFromHBitmap( hBitmap AS PTR ) AS PTR PASCAL:FabPaint.FabDIBCreateFromHBitmap
//p Create a DIB object from bitmap Handle
//a <hBitmap>	Handle of the Bitmap to use to create the DIB object
//d This function copy the pixels in hBitmap to a DIB object
//r A pointer to the DIB object
//j FUNCTION:DIBDelete

_DLL FUNCTION DIBCreateFromHDib( hDIB AS PTR ) AS PTR PASCAL:FabPaint.FabDIBCreateFromHDib
//p Create a DIB object from Device Independent Bitmap memory
//a <hDIB>	Handle of the DIB o use to create the DIB object
//d This function copy the pixels in hDIB to a DIB object
//r A pointer to the DIB object
//j FUNCTION:DIBDelete

_dll FUNCTION DIBCreateFromPTR(pbImage as byte ptr, nSize as DWORD) as ptr PASCAL:FabPaint.FabDIBCreateFromPTR
//p Create a DIB object from memory block
//a <pbImage>	Pointer to the memory block
//a <nSIze>		Size of the memory block
//d This function will read the indicated memory as if it was a file, and then
//d create a DIB object. SO you can copy a file to memory, with a ProgressBar, and then use this function.
//r A pointer to the DIB object
//j FUNCTION:DIBDelete

_DLL FUNCTION DIBCrop( pWinBmp AS PTR, XMin AS LONG, XMax AS LONG, YMin AS LONG, YMax AS LONG ) AS VOID PASCAL:FabPaint.FabDIBCrop
//p Extract a part of an image
//a XMin,XMax,YMin,YMax The coordonates of the part to extract
//d This function will extract a part of the Image, indicated by the X,Y coordonates
//d and make it the new image
//d Only 8 and 32 bpp supported for now.
_DLL FUNCTION DIBGetInfo(pWinBmp AS PTR) AS _WINBITMAPINFO PASCAL:FabPaint.FabDIBGetInfo
//p Get Info for an existing DIB Object
//a <pWinBmp> Pointer the DIB Object to read
//d The returned _WINBITMAPINFO structure is filled with informations about the image.
//r A pointer to a _WINBITMAPINFO structure. ( Don't try to free this pointer !! )
// Same as standard CAPaint

_DLL FUNCTION DIBInvert( pWinBmp AS PTR ) AS VOID PASCAL:FabPaint.FabDIBInvert
//p VideoInvert a DIB Object
//a <pWinBmp> Pointer the DIB Object
//d This function only works for 32 bpp bitmaps at the moment, so you may copy and change the number of bit per pixel if needed.
//d To retrieve the number of bit per pixel, use the DIBGetInfo() function, and in the returned structure,
//d read the biBitCount member of the bmiHeader member.
//j FUNCTION:DIBGetInfo

_DLL FUNCTION DIBMakeGrayscale( pWinBmp AS PTR ) AS VOID PASCAL:FabPaint.FabDIBMakeGrayscale
//p Make the DIB object GrayScale
//a <pWinBmp> Pointer the DIB Object
//d This function only works for 32 bpp bitmaps at the moment, so you may copy and change the number of bit per pixel if needed.
//d To retrieve the number of bit per pixel, use the DIBGetInfo() function, and in the returned structure,
//d read the biBitCount member of the bmiHeader member.
//j FUNCTION:DIBGetInfo

_DLL FUNCTION DIBResizeBilinear( pWinBmp AS PTR, NewXSize AS LONG, NewYSize AS LONG ) AS VOID PASCAL:FabPaint.FabDIBResizeBilinear
//p Resizes a bitmap using bilinear interpolation
//a <pWinBmp> Pointer the DIB Object
//a <NewXSize> New X Size of the Image
//a <NewYSize> New Y Size of the Image
//d This function only works for 32 bpp bitmaps at the moment, so you may copy and change the number of bit per pixel if needed.
//d To retrieve the number of bit per pixel, use the DIBGetInfo() function, and in the returned structure,
//d read the biBitCount member of the bmiHeader member.
//j FUNCTION:DIBGetInfo

_DLL FUNCTION DIBResizeBox( pWinBmp AS PTR, NewXSize AS LONG, NewYSize AS LONG, NewRadius AS REAL8 ) AS VOID PASCAL:FabPaint.FabDIBResizeBox
//p Resizes a bitmap and applies a box filter to it
//a <pWinBmp> Pointer the DIB Object
//a <NewXSize> New X Size of the Image
//a <NewYSize> New Y Size of the Image
//a <NewRadius>
//d This function only works for 32 bpp bitmaps at the moment, so you may copy and change the number of bit per pixel if needed.
//d To retrieve the number of bit per pixel, use the DIBGetInfo() function, and in the returned structure,
//d read the biBitCount member of the bmiHeader member.
//j FUNCTION:DIBGetInfo

_DLL FUNCTION DIBResizeGaussian( pWinBmp AS PTR, NewXSize AS LONG, NewYSize AS LONG, NewRadius AS REAL8 ) AS VOID PASCAL:FabPaint.FabDIBResizeGaussian
//p Resizes a bitmap and applies a gaussian blur to it.
//a <pWinBmp> Pointer the DIB Object
//a <NewXSize> New X Size of the Image
//a <NewYSize> New Y Size of the Image
//a <NewRadius>
//d This function only works for 32 bpp bitmaps at the moment, so you may copy and change the number of bit per pixel if needed.
//d To retrieve the number of bit per pixel, use the DIBGetInfo() function, and in the returned structure,
//d read the biBitCount member of the bmiHeader member.
//j FUNCTION:DIBGetInfo

_DLL FUNCTION DIBResizeHamming( pWinBmp AS PTR, NewXSize AS LONG, NewYSize AS LONG, NewRadius AS REAL8 ) AS VOID PASCAL:FabPaint.FabDIBResizeHamming
//p Resizes a bitmap and applies a hamming filter to it.
//a <pWinBmp> Pointer the DIB Object
//a <NewXSize> New X Size of the Image
//a <NewYSize> New Y Size of the Image
//a <NewRadius>
//d This function only works for 32 bpp bitmaps at the moment, so you may copy and change the number of bit per pixel if needed.
//d To retrieve the number of bit per pixel, use the DIBGetInfo() function, and in the returned structure,
//d read the biBitCount member of the bmiHeader member.
//j FUNCTION:DIBGetInfo

_DLL FUNCTION DIBRotate( pWinBmp AS PTR, angle AS REAL8, color AS DWORD ) AS VOID PASCAL:FabPaint.FabDIBRotate
//p Rotates a bitmap by angle radians.
//a <pWinBmp> Pointer the DIB Object
//a <angle> Rotation angle in Radians
//a <color> The RGB Color used to fill new part of the image
//d This function only works for 32 bpp bitmaps at the moment, so you may copy and change the number of bit per pixel if needed.
//d To retrieve the number of bit per pixel, use the DIBGetInfo() function, and in the returned structure,
//d read the biBitCount member of the bmiHeader member.
//j FUNCTION:DIBGetInfo

_DLL FUNCTION DIBSaveAs(pWinBmp AS PTR, pszFName AS PSZ) AS VOID PASCAL:FabPaint.FabDIBSaveAs
//p Save a DIB Object to a DIB file
//a <pWinBMp> Pointer to the DIB Object to save
//a <pszFName> Name of the File to create
//d This function will save the desired DIB Object as a DIB file.

_DLL FUNCTION DIBSaveAsJPEG(pWinBmp AS PTR, pszFName AS PSZ) AS VOID PASCAL:FabPaint.FabDIBSaveAsJPEG
//p Save a DIB Object to a JPEG file
//a <pWinBMp> Pointer to the DIB Object to save
//a <pszFName> Name of the File to create
//d This function will save the desired DIB Object as a JPEG file.
//d This function only works for 32 bpp bitmaps at the moment, so as an internal enhancement it
//d will try to copy the bitmap as 32 bpp if needed before saving.
//d To retrieve the number of bit per pixel, use the DIBGetInfo() function, and in the returned structure,
//d read the biBitCount member of the bmiHeader member.
//j FUNCTION:DIBGetInfo

_DLL FUNCTION DIBSaveAsPNG(pWinBmp AS PTR, pszFName AS PSZ) AS VOID PASCAL:FabPaint.FabDIBSaveAsPNG
//p Save a DIB Object to a PNG file
//a <pWinBMp> Pointer to the DIB Object to save
//a <pszFName> Name of the File to create
//d This function will save the desired DIB Object as a PNG file.

_DLL FUNCTION DIBSaveAsTIFF(pWinBmp AS PTR, pszFName AS PSZ) AS VOID PASCAL:FabPaint.FabDIBSaveAsTIFF
//p Save a DIB Object to a TIFF file
//a <pWinBMp> Pointer to the DIB Object to save
//a <pszFName> Name of the File to create
//d This function will save the desired DIB Object as a TIFF file.

_DLL FUNCTION DIBSetProgressControl( hCtrl AS PTR ) AS VOID PASCAL:FabPaint.FabDIBSetProgressControl
//p Use a Progress Control when reading.
//a <hCtrl> Handle of the Progress Control to be used. ( NULL_PTR for none )
//d With this function you can set a Progress Control, wich Range is 1..100, then start to read a file with
//d any of DIBCreatexxx() function. For each step, the control will receive a notification to show the current reading.
//d Don't forget to set the <hCtrl> to NULL_PTR when the read ends !!!

_DLL FUNCTION DIBShow(pWinBmp AS PTR, hWnd AS PTR) AS VOID PASCAL:FabPaint.FabDIBShow
//p Show a DIB Object in a Window
//a <pWinBMp> Pointer to the DIB Object to Show
//a <hWnd> Handle of the destination Window
//d Show a DIB Object in a Window. The Image keeps it size, and doesn't fit to the Window.
//j FUNCTION:DIBShowEx
//j FUNCTION:DIBStretch
//j FUNCTION:DIBStretchEx
//j FUNCTION:DIBStretchDraw
//j FUNCTION:DIBShowFitToWindow

_DLL FUNCTION DIBStretchDraw( pWinBmp AS PTR, hWnd AS PTR, x AS LONG, y AS LONG, w AS LONG, h AS LONG ) AS VOID PASCAL:FabPaint.FabDIBStretchDraw
//p Stretch a DIB Object in a Window
//a <pWinBmp> Pointer to the DIB object to show.
//a <hWnd> Window handle.
//a <x> X Pos of the image in the window.
//a <y> Y Pos of the image in the window.
//a <w> Width of the area for displaying the DIB.
//a <h> Height of the area for displaying the DIB.
//j FUNCTION:DIBStretch
//j FUNCTION:DIBShow
//j FUNCTION:DIBShowFitToWindow

FUNCTION FreeCAPaint() AS LOGIC STRICT
// DLL is now referenced statically
RETURN TRUE

FUNCTION InitializeCAPaint() AS LOGIC STRICT
// DLL is now referenced statically, so always TRUE
// Same as standard CAPaint
RETURN TRUE

_DLL FUNCTION DIBGetHandle( pWinBmp AS PTR ) AS PTR PASCAL:FabPaint.FabDIBGetHandle
//p Retrieve the HBitmap for an existing DIB object
//a <pWinBmp> Pointer the DIB Object
//d Each DIB object data are copied into a internal memory, and you can get a standard hBitmap to this memory.
//d So, after retrieving this handle, you can SelectObject() the hBitmap into a Windows Device Context, and then
//d use any standard GDI function to draw on the bitmap.
//r A hBitmap Handle

_DLL FUNCTION DIBStretch(pWinBmp AS PTR, hWnd AS PTR, dwWidth AS DWORD, dwHeight AS DWORD, r8Factor AS REAL8) AS VOID PASCAL:FabPaint.FabDIBStretch
//p Stretch a DIB Object in a Window
//a <pWinBmp> Pointer to the DIB object to show.
//a <hWnd> Window handle.
//a <dwWidth> Width of the area for displaying the DIB.
//a <dwHeight> Height of the area for displaying the DIB.
//a <r8Factor> The zoom factor of the bitmap.  A value of 1.0 would be its normal size.
//d DIBStretch() copies a DIB into a destination rectangle of <nWidth> by <nHeight>, stretching or compressing the bitmap
//d by a factor of <r8Zoom> to fit the dimensions of the specified window, <hWnd>.  <r8Zoom> can be calculated as
//d <size of the area>/<size of the bitmap>.
//d  For example, a value of 2.0 would double the bitmap size, while a value of 0.5 would shrink the DIB to half
//d its normal size.
//j FUNCTION:DIBShow
//j FUNCTION:DIBShowEx
//j FUNCTION:DIBStretchEx
//j FUNCTION:DIBStretchDraw
//j FUNCTION:DIBShowFitToWindow

_DLL FUNCTION DIBShowEx(pWinBmp AS PTR, hWnd AS PTR, XPos AS LONG, YPos AS LONG) AS VOID PASCAL:FabPaint.FabDIBShowEx
//p Show a DIB Object in a Window at a Specified Position
//a <pWinBMp> Pointer to the DIB Object to Show
//a <hWnd> Handle of the destination Window
//a <XPos>, <YPos> are the coords of the Top-Left Corner of the Image in the destination Window
//d Show a DIB Object in a Window at a specified position. The Image keeps it size, and doesn't fit to the Window.
//j FUNCTION:DIBShow
//j FUNCTION:DIBStretch
//j FUNCTION:DIBStretchEx
//j FUNCTION:DIBStretchDraw
//j FUNCTION:DIBShowFitToWindow

_DLL FUNCTION DIBStretchEx(pWinBmp AS PTR, hWnd AS PTR, pRectDest AS _WINRect, pRectSrc AS _WINRect ) AS VOID PASCAL:FabPaint.FabDIBStretchEx
//p Stretch a DIB Object in a Window
//a <pWinBmp> Pointer to the DIB object to show.
//a <hWnd> Window handle.
//a <pRectDest> Destination Rectangle in the specified Window.
//a  If NULL_PTR, the pRectSrc rectangle is used.
//a <pRectSrc> Rectangle part of the image to draw into the destination rectangle.
//a  If NULL_PTR, the actual Width and Height of the image are used.
//d DIBStretchEx() copies a DIB into a destination rectangle, stretching or compressing the bitmap
//d to fit the dimensions of the specified window, <hWnd>.
//d
//j FUNCTION:DIBShow
//j FUNCTION:DIBShowEx
//j FUNCTION:DIBStretch
//j FUNCTION:DIBStretchDraw
//j FUNCTION:DIBShowFitToWindow

_DLL FUNCTION DIBShowDC(pWinBmp AS PTR, hDC AS PTR) AS VOID PASCAL:FabPaint.FabDIBShowDC
//p Show a DIB Object in a Window
//a <pWinBMp> Pointer to the DIB Object to Show
//a <hDC> Handle of the device context to use
//d Show a DIB Object in a DC The Image keeps it size, and doesn't fit to the DC.
//j FUNCTION:DIBShowExDC
//j FUNCTION:DIBStretchDC
//j FUNCTION:DIBStretchExDC
//j FUNCTION:DIBStretchDrawDC

_DLL FUNCTION DIBShowExDC(pWinBmp AS PTR, hDC AS PTR, XPos AS LONG, YPos AS LONG) AS VOID PASCAL:FabPaint.FabDIBShowExDC
//p Show a DIB Object in a Window at a Specified Position
//a <pWinBMp> Pointer to the DIB Object to Show
//a <hDC> Handle of the device context to use
//a <XPos>, <YPos> are the coords of the Top-Left Corner of the Image in the destination DC
//d Show a DIB Object in a Window at a specified DC. The Image keeps it size, and doesn't fit to the DC
//j FUNCTION:DIBShowDC
//j FUNCTION:DIBStretchDC
//j FUNCTION:DIBStretchExDC
//j FUNCTION:DIBStretchDrawDC

_DLL FUNCTION DIBStretchDC(pWinBmp AS PTR, hDC AS PTR, dwWidth AS DWORD, dwHeight AS DWORD, r8Factor AS REAL8) AS VOID PASCAL:FabPaint.FabDIBStretchDC
//p Stretch a DIB Object in a Window
//a <pWinBmp> Pointer to the DIB object to show.
//a <hDC> Handle of the device context to use
//a <dwWidth> Width of the area for displaying the DIB.
//a <dwHeight> Height of the area for displaying the DIB.
//a <r8Factor> The zoom factor of the bitmap.  A value of 1.0 would be its normal size.
//d DIBStretchDC() copies a DIB into a destination rectangle of <nWidth> by <nHeight>, stretching or compressing the bitmap
//d by a factor of <r8Zoom> to fit the dimensions of the specified window, <hDC>.  <r8Zoom> can be calculated as
//d <size of the area>/<size of the bitmap>.
//d  For example, a value of 2.0 would double the bitmap size, while a value of 0.5 would shrink the DIB to half
//d its normal size.
//j FUNCTION:DIBShowDC
//j FUNCTION:DIBShowExDC
//j FUNCTION:DIBStretchExDC
//j FUNCTION:DIBStretchDrawDC

_DLL FUNCTION DIBStretchDrawDC( pWinBmp AS PTR, hDC AS PTR, x AS LONG, y AS LONG, w AS LONG, h AS LONG ) AS VOID PASCAL:FabPaint.FabDIBStretchDrawDC
//p Stretch a DIB Object in a Window
//a <pWinBmp> Pointer to the DIB object to show.
//a <hDC> Handle of the device context to use
//a <x> X Pos of the image in the window.
//a <y> Y Pos of the image in the window.
//a <w> Width of the area for displaying the DIB.
//a <h> Height of the area for displaying the DIB.
//j FUNCTION:DIBStretchDC
//j FUNCTION:DIBShowDC

_DLL FUNCTION DIBStretchExDC(pWinBmp AS PTR, hDC AS PTR, pRectDest AS _WINRect, pRectSrc AS _WINRect ) AS VOID PASCAL:FabPaint.FabDIBStretchExDC
//p Stretch a DIB Object in a Window
//a <pWinBmp> Pointer to the DIB object to show.
//a <hDC> Handle of the device context to use
//a <pRectDest> Destination Rectangle in the specified Window.
//a  If NULL_PTR, the pRectSrc rectangle is used.
//a <pRectSrc> Rectangle part of the image to draw into the destination rectangle.
//a  If NULL_PTR, the actual Width and Height of the image are used.
//d DIBStretchExDC() copies a DIB into a destination rectangle, stretching or compressing the bitmap
//d to fit the dimensions of the specified window, <hDC>.
//j FUNCTION:DIBShowDC
//j FUNCTION:DIBShowExDC
//j FUNCTION:DIBStretchDC
//j FUNCTION:DIBStretchDrawDC

_DLL FUNCTION DIBGetUseGDI( pWinBmp AS PTR ) AS LOGIC PASCAL:FabPaint.FabDIBGetUseGDI
//p Retrieve the UseGDI property
//a <pWinBmp> Pointer the DIB Object
//d The FabPaint DLL uses VideoForWindows and all DrawDibxxx() function to draw images.
//d But if, for special needs, you want to use standard GDI functions you can get/set this flag,
//d the FabPaint will use StretchBlt() function.
//r A logical value

_DLL FUNCTION DIBSetUseGDI( pWinBmp AS PTR, lUseGDI AS LOGIC ) AS LOGIC PASCAL:FabPaint.FabDIBSetUseGDI
//p Set the UseGDI property
//a <pWinBmp> Pointer the DIB Object
//a <lUseGDI> Logical Value
//d The FabPaint DLL uses VideoForWindows and all DrawDibxxx() function to draw images.
//d But if, for special needs, you want to use standard GDI functions you can get/set this flag,
//d the FabPaint will use StretchBlt() function.
//r A logical value

_DLL FUNCTION DIBCreate(  Width := 16 AS LONG, Height := 16 AS LONG, BitsPerPixel := 8 AS WORD, bAlphaChannel := FALSE AS LOGIC ) AS PTR PASCAL:FabPaint.FabDIBCreate
//p Create an empty DIB object
//d This function will create an empty DIB according to the specified parameters.
//r A pointer to the DIB object
//j FUNCTION:DIBDelete

_DLL FUNCTION DIBToClipboard( pWinBmp AS PTR ) AS VOID PASCAL:FabPaint.FabDIBToClipboard
//p Copy a DIB object to the Clipboard
//a <pWinBmp> 		Pointer to the existing DIB Object
//d This function will copy the existing pixels to the Clipboard in the CF_DIB format.

_DLL FUNCTION DIBFromClipboard( pWinBmp AS PTR, dwFormat := CF_BITMAP AS DWORD ) AS LOGIC PASCAL:FabPaint.FabDIBFromClipboard
//p Copy a DIB object from the Clipboard
//a <pWinBmp> 		Pointer to the existing DIB Object
//a <dwFormat>		Format of data in the Clipboard to read. ( Only CF_BITMAP or CF_DIB are supported )
//d This function will copy the existing pixels from the Clipboard.
//r A logical value indicating the succes of the operation.

_DLL FUNCTION DIBContrast( pWinBmp AS PTR, rContrast AS REAL8, bOffset AS BYTE ) AS VOID PASCAL:FabPaint.FabDIBContrast
//p Change the contrast of the image
//a <pWinBmp> 		Pointer to the existing DIB Object
//a <rContrast> is the slope of the function.
//a <bOffset> is the intensity at which the color stays the same.
//a Above this value, intensities are increased.
//a Below it, they are reduced.
//a With offset 128 and contrast 1, the image stays unchanged.
//d This function enhances or reduces the image contrast using a linear mapping
//d between input and output. The zero point (i. e., the intensity
//d that is neither enhanced nor reduced) has to be provided.
//d (A Contrast filter is defined in the following way: It lowers all
//d intensity values below a given threshold, and it raises them
//d beyond. Most applications position the threshold at 50 %. This
//d does not always yield the best results, especially if you have an
//d unbalanced dark/light ratio of pixels. The best you can do here
//d is play around with the threshold.)
//d This function only works for 32 bpp bitmaps at the moment, so you may copy and change the number of bit per pixel if needed.
//d To retrieve the number of bit per pixel, use the DIBGetInfo() function, and in the returned structure,
//d read the biBitCount member of the bmiHeader member.
//j FUNCTION:DIBGetInfo

_DLL FUNCTION DIBLightness( pWinBmp AS PTR, iLightness AS LONG ) AS VOID PASCAL:FabPaint.FabDIBLightness
//p Change the lightness of the image
//a <pWinBmp> 		Pointer to the existing DIB Object
//a <iLightness>	values must be in the range -100..100.
//a A value of 0 leaves the image unchanged.
//d This function only works for 32 bpp bitmaps at the moment, so you may copy and change the number of bit per pixel if needed.
//d To retrieve the number of bit per pixel, use the DIBGetInfo() function, and in the returned structure,
//d read the biBitCount member of the bmiHeader member.
//j FUNCTION:DIBGetInfo

_DLL FUNCTION DIBIntensity( pWinBmp AS PTR, rIntensity AS REAL8, bOffset AS BYTE, rExponent AS REAL8 ) AS VOID PASCAL:FabPaint.FabDIBIntensity
//p Changes the intensity of the image.
//a <pWinBmp> 		Pointer to the existing DIB Object
//d Applies the factor intensityFactor = 1.0 + csupp * pow((v-m_offset), m_exponent)
//d with csupp = intensity/pow(255.0, m_exponent)
//d on the v-Value of the image after a HSV transform.
//d The bitmap stays unchanged for intensity = 20, offset = 128, exponent = 1.
//d This function only works for 32 bpp bitmaps at the moment, so you may copy and change the number of bit per pixel if needed.
//d To retrieve the number of bit per pixel, use the DIBGetInfo() function, and in the returned structure,
//d read the biBitCount member of the bmiHeader member.
//j FUNCTION:DIBGetInfo

_DLL FUNCTION DIBSetResizeCallBack( pWinBmp AS PTR, pFunc AS PTR ) AS VOID PASCAL:FabPaint.FabDIBSetResizeCallBack
//p Set the Callback function used during resize process
//a <pWinBmp> 		Pointer to the existing DIB Object
//a <pFunc> 		Pointer to the callback function
//d the ResizeCallback is called by FabPaint during the process to
//d allow you software to show a progress dialog, or to allow
//d some pause specially if you are doing some batch process on multiple
//d file in a stressed environment (eg: WEB server, ... )
//s //Set the callback like
//s DIBSetResizeCallBack( SELF:oImg:pDibObject, @FabResizeCallBack() )
//s
//s //When not needed you can unset with
//s DIBSetResizeCallBack( SELF:oImg:pDibObject, NULL_PTR )
//s
//s //Sample Resize Callback function
//s FUNCTION FabResizeCallBack( bPercentComplete AS BYTE ) AS LOGIC STRICT
//s 	// Continue, please....
//s 	oGlobalWin:Caption := Str( bPercentComplete )
//s 	// Return FALSE to cancel resize
//s RETURN TRUE


_DLL FUNCTION DIBEXIFGetSize( pWinBmp AS PTR ) AS LONG PASCAL:FabPaint.FabDIBEXIFGetSize
//p Retrieve the number of EXIF Tags stored in the JPEG Image
//a <pWinBmp> 		Pointer to the existing DIB Object
//d EXIF Tags are stored by Digital Camera in a JPEG File


_DLL FUNCTION DIBEXIFGetTagShortName( pWinBmp AS PTR, dwTagPos AS DWORD, pTagShortName AS PSZ, MaxSize AS LONG ) AS LONG PASCAL:FabPaint.FabDIBEXIFGetTagShortName
//p Retrieve a particular EXIF Tag ShortName
//a <pWinBmp> 		Pointer to the existing DIB Object
//a <dwTagPos>		Pos of Tag in internal Tag Array.
//a                 !!! Zero-Based Array !!!
//a <pTagShortName>	The name of the TAG to retrieve as a PSZ
//a <MaxSize>		Max Space available in <pTagShortName> buffer
//r Number of Chars of the Tag Value (not including the zero terminator )
//d EXIF Tags are stored by Digital Camera in a JPEG File

_DLL FUNCTION DIBEXIFGetTagDescription( pWinBmp AS PTR, dwTagPos AS DWORD, pTagDescription AS PSZ, MaxSize AS LONG ) AS LONG PASCAL:FabPaint.FabDIBEXIFGetTagDescription
//p Retrieve a particular EXIF Tag
//a <pWinBmp> 		Pointer to the existing DIB Object
//a <dwTagPos>		Pos of Tag in internal Tag Array.
//a                 !!! Zero-Based Array !!!
//a <pTagDescription>	The name of the TAG to retrieve as a PSZ
//a <MaxSize>		Max Space available in <pTagDescription> buffer
//r Number of Chars of the Tag Value (not including the zero terminator )
//d EXIF Tags are stored by Digital Camera in a JPEG File

_DLL FUNCTION DIBEXIFGetTagValue( pWinBmp AS PTR, dwTagPos AS DWORD, pTagValue AS PSZ, MaxSize AS LONG ) AS LONG PASCAL:FabPaint.FabDIBEXIFGetTagValue
//p Retrieve a particular EXIF Tag
//a <pWinBmp> 		Pointer to the existing DIB Object
//a <dwTagPos>		Pos of Tag in internal Tag Array.
//a                 !!! Zero-Based Array !!!
//a <pTagValue>		The name of the TAG to retrieve as a PSZ
//a <MaxSize>		Max Space available in <pTagValue> buffer
//r Number of Chars of the Tag Value (not including the zero terminator )
//d EXIF Tags are stored by Digital Camera in a JPEG File

_DLL FUNCTION DIBSetPNGCompressionLevel( PNGLevel AS WORD ) AS WORD PASCAL:FabPaint.FabDIBSetPNGCompressionLevel
//p Set the default PNGCompressionLevel property
//a <PNGLevel> Compression Level :
//a				0 - No Compression
//a				9 - Hardest Compression
//d If you pass an invalid level ( > 9 ), you can retrieve the current level.
//r The current compression Level

_DLL FUNCTION DIBSetTIFFCompressionLevel( TIFFLevel AS WORD ) AS WORD PASCAL:FabPaint.FabDIBSetTIFFCompressionLevel
//p Set the default TIFFCompressionLevel property
//a <TIFFLevel> Compression Level :
//a				COMPRESSION_NONE - No Compression
//a				Default is COMPRESSION_PACKBITS
//d If you pass an invalid level ( == 0 ), you can retrieve the current level.
//r The current compression Level
_dll FUNCTION DIBSaveAsJPEGEx(pWinBmp as ptr, pszFName as psz, wQuality as word) as void PASCAL:FabPaint.FabDIBSaveAsJPEGEx
//p Save a DIB Object to a JPEG file
//a <pWinBMp> Pointer to the DIB Object to save
//a <pszFName> Name of the File to create
//a <wQuality> Set the compression quality from 0 to 100. The standard quality is 0
//d This function will save the desired DIB Object as a JPEG file.
//d This function only works for 32 bpp bitmaps at the moment, so as an internal enhancement it
//d will try to copy the bitmap as 32 bpp if needed before saving.
//d To retrieve the number of bit per pixel, use the DIBGetInfo() function, and in the returned structure,
//d read the biBitCount member of the bmiHeader member.
//j FUNCTION:DIBGetInfo

_DLL FUNCTION DIBSaveAsPNGEx(pWinBmp AS PTR, pszFName AS PSZ, PNGLevel AS WORD) AS VOID PASCAL:FabPaint.FabDIBSaveAsPNGEx
//p Save a DIB Object to a PNG file
//a <pWinBMp> Pointer to the DIB Object to save
//a <pszFName> Name of the File to create
//a <PNGLevel> Compression Level : ( The standard compression is 5 )
//a				0 - No Compression
//a				9 - Hardest Compression
//d This function will save the desired DIB Object as a PNG file.

_DLL FUNCTION DIBSaveAsTIFFEx(pWinBmp AS PTR, pszFName AS PSZ, TIFFLevel AS WORD) AS VOID PASCAL:FabPaint.FabDIBSaveAsTIFFEx
//p Save a DIB Object to a TIFF file
//a <pWinBMp> Pointer to the DIB Object to save
//a <pszFName> Name of the File to create
//a <TIFFLevel> Compression Level :
//a				1 - No Compression
//a				Default is COMPRESSION_PACKBITS
//d This function will save the desired DIB Object as a TIFF file.

_DLL FUNCTION DIBSaveAsJPEGEx2(pWinBmp AS PTR, pszFName AS PSZ, wQuality AS WORD, uiX AS DWORD, uiY AS DWORD) AS VOID PASCAL:FabPaint.FabDIBSaveAsJPEGEx
//p Save a DIB Object to a JPEG file
//a <pWinBMp> Pointer to the DIB Object to save
//a <pszFName> Name of the File to create
//a <wQuality> Set the compression quality from 0 to 100. The standard quality is 0
//a <uiX>, <uiY> Set the resolution information (DPI) for the image.
//d This function will save the desired DIB Object as a JPEG file.
//d This function only works for 32 bpp bitmaps at the moment, so as an internal enhancement it
//d will try to copy the bitmap as 32 bpp if needed before saving.
//d To retrieve the number of bit per pixel, use the DIBGetInfo() function, and in the returned structure,
//d read the biBitCount member of the bmiHeader member.
//j FUNCTION:DIBGetInfo

_DLL FUNCTION DIBRotateDeg( pWinBmp AS PTR, angle AS REAL8, color AS DWORD ) AS VOID PASCAL:FabPaint.FabDIBRotateDeg
//p Rotates a bitmap by angle radians.
//a <pWinBmp> Pointer the DIB Object
//a <angle> Rotation angle in Degree
//a <color> The RGB Color used to fill new part of the image
//d This function only works for 32 bpp bitmaps at the moment, so you may copy and change the number of bit per pixel if needed.
//d To retrieve the number of bit per pixel, use the DIBGetInfo() function, and in the returned structure,
//d read the biBitCount member of the bmiHeader member.
//j FUNCTION:DIBGetInfo

_DLL FUNCTION MultiClose(pMultiPage AS PTR) AS VOID PASCAL:FabPaint.FabMultiClose
//p Close a MultiPage object

_DLL FUNCTION MultiPageCount(pMultiPage AS PTR) AS LONGINT PASCAL:FabPaint.FabMultiPageCount
//p Count the number of Pages in a MultiPage object

_DLL FUNCTION MultiDelete(pMultiPage AS PTR) AS VOID PASCAL:FabPaint.FabMultiDelete
//p Delete an Existing MultiPage Object
//a <pMultiPage> Pointer to the MultiPage object

_DLL FUNCTION MultiDelPage( pMultiPage AS PTR, nPage AS LONGINT ) AS VOID PASCAL:FabPaint.FabMultiDelPage
//p Delete a page from a MultiPage Image
//d This function will delete a page from a MultiPage image; changes are committed when the file is closed
//j FUNCTION:MultiInsPage
//j FUNCTION:MultiAddPage

_DLL FUNCTION MultiInsPage( pMultiPage AS PTR, pDib AS PTR, nPage AS LONGINT ) AS VOID PASCAL:FabPaint.FabMultiInsPage
//p Insert a page in a MultiPage Image
//d This function will insert a page in a MultiPage image; changes are committed when the file is closed
//j FUNCTION:MultiDelPage
//j FUNCTION:MultiAddPage

_DLL FUNCTION MultiAddPage( pMultiPage AS PTR, pDib AS PTR ) AS VOID PASCAL:FabPaint.FabMultiAddPage
//p Add a page at the end of a MultiPage Image
//d This function will add a page int a MultiPage image; changes are committed when the file is closed
//j FUNCTION:MultiDelPage
//j FUNCTION:MultiInsPage

_dll FUNCTION MultiClonePage( pMultiPage as ptr, nPage as LONGINT ) as ptr PASCAL:FabPaint.FabMultiClonePage
//p Create a DIB object from a MultiPage Image
//d This function will create an new DIB.
//r A pointer to the DIB object
//j FUNCTION:MultiDelete

_DLL FUNCTION DIBEXIFGetTagCommon( pWinBmp AS PTR, pTagShortName AS PSZ, pTagValue AS PTR, MaxSize AS LONG ) AS LONG PASCAL:FabPaint.FabDIBEXIFGetTagCommon
//p Retrieve a particular EXIF Tag
//a <pWinBmp> 		Pointer to the existing DIB Object
//a <pTagShortName>	The name of the TAG to retrieve as a PSZ
//a <pTagValue>		Buffer were the corresponding Tag Value will be copied
//a					!!! No zero terminator is added during the copy operation
//a <MaxSize>		Max Space available in <pTagValue> buffer
//r Number of Chars of the Tag Value (not including the zero terminator )
//d EXIF Tags are stored by Digital Camera in a JPEG File

_dll FUNCTION MultiCreateFromFile(pszFName as psz, Create as logic, ReadOnly as logic ) as ptr PASCAL:FabPaint.FabMultiCreateFromFile
//p Create a MultiPage object from a File
//a <pszFName> Name of the file to read.
//a <Create> Indicate if a new file must be created
//a <ReadOnly> Indicate if file is in ReadOnly mode (no changes will be applied)
//d This function will read the indicated file, and create a DIB object.
//d The image can be any of : .TIF, .GIF
//r A pointer to the MultiPage object
//j FUNCTION:MultiDelete

_DLL FUNCTION MultiGetPage( pMultiPage AS PTR, nPage AS LONGINT ) AS PTR PASCAL:FabPaint.FabMultiGetPage
//p Get/Lock a DIB object from a MultiPage Image
//d This function will lock a page as a DIB
//d Any modification to the image can be validated
//d YOU MUST UNLOCK THE IMAGE
//r A pointer to the DIB object
//j FUNCTION:MultiClonePage
//j FUNCTION:MultiLockPage

_dll FUNCTION DIBEXIFGetSizeEx( pWinBmp as ptr, Model as long ) as LONG PASCAL:FabPaint.FabDIBEXIFGetSizeEx
//p Retrieve the number of EXIF Tags stored in the JPEG Image
//a <pWinBmp> 		Pointer to the existing DIB Object
//a <Model>			Exif's model of Metadata stored in the JPEG File
//d EXIF Tags are stored by Digital Camera in a JPEG File


_dll FUNCTION DIBEXIFGetTagCommonEx( pWinBmp as ptr, pTagShortName as psz, pTagValue as ptr, MaxSize as LONG, Model as long ) as LONG PASCAL:FabPaint.FabDIBEXIFGetTagCommonEx
//p Retrieve a particular EXIF Tag
//a <pWinBmp> 		Pointer to the existing DIB Object
//a <pTagShortName>	The name of the TAG to retrieve as a PSZ
//a <pTagValue>		Buffer were the corresponding Tag Value will be copied
//a					!!! No zero terminator is added during the copy operation
//a <MaxSize>		Max Space available in <pTagValue> buffer
//a <Model>			Exif's model of Metadata stored in the JPEG File
//r Number of Chars of the Tag Value (not including the zero terminator )
//d EXIF Tags are stored by Digital Camera in a JPEG File

_dll FUNCTION DIBEXIFGetTagShortNameEx( pWinBmp as ptr, dwTagPos as DWORD, pTagShortName as psz, MaxSize as LONG, Model as long ) as LONG PASCAL:FabPaint.FabDIBEXIFGetTagShortNameEx
//p Retrieve a particular EXIF Tag ShortName
//a <pWinBmp> 		Pointer to the existing DIB Object
//a <dwTagPos>		Pos of Tag in internal Tag Array.
//a                 !!! Zero-Based Array !!!
//a <pTagShortName>	The name of the TAG to retrieve as a PSZ
//a <MaxSize>		Max Space available in <pTagShortName> buffer
//a <Model>			Exif's model of Metadata stored in the JPEG File
//r Number of Chars of the Tag Value (not including the zero terminator )
//d EXIF Tags are stored by Digital Camera in a JPEG File

_dll FUNCTION DIBEXIFGetTagDescriptionEx( pWinBmp as ptr, dwTagPos as DWORD, pTagDescription as psz, MaxSize as LONG, Model as long ) as LONG PASCAL:FabPaint.FabDIBEXIFGetTagDescriptionEx
//p Retrieve a particular EXIF Tag
//a <pWinBmp> 		Pointer to the existing DIB Object
//a <dwTagPos>		Pos of Tag in internal Tag Array.
//a                 !!! Zero-Based Array !!!
//a <pTagDescription>	The name of the TAG to retrieve as a PSZ
//a <MaxSize>		Max Space available in <pTagDescription> buffer
//a <Model>			Exif's model of Metadata stored in the JPEG File
//r Number of Chars of the Tag Value (not including the zero terminator )
//d EXIF Tags are stored by Digital Camera in a JPEG File

_dll FUNCTION DIBEXIFGetTagValueEx( pWinBmp as ptr, dwTagPos as DWORD, pTagValue as psz, MaxSize as LONG, Model as long ) as LONG PASCAL:FabPaint.FabDIBEXIFGetTagValueEx
//p Retrieve a particular EXIF Tag
//a <pWinBmp> 		Pointer to the existing DIB Object
//a <dwTagPos>		Pos of Tag in internal Tag Array.
//a                 !!! Zero-Based Array !!!
//a <pTagValue>		The name of the TAG to retrieve as a PSZ
//a <MaxSize>		Max Space available in <pTagValue> buffer
//a <Model>			Exif's model of Metadata stored in the JPEG File
//r Number of Chars of the Tag Value (not including the zero terminator )
//d EXIF Tags are stored by Digital Camera in a JPEG File

_dll FUNCTION MultiLockPage( pMultiPage as ptr, nPage as LONGINT ) as ptr PASCAL:FabPaint.FabMultiLockPage
//p Get/Lock a DIB object from a MultiPage Image
//d This function will lock a page as a DIB
//d Any modification to the image can be validated
//d YOU MUST UNLOCK THE IMAGE
//r A pointer to the DIB object
//j FUNCTION:MultiClonePage
//j FUNCTION:MultiUnlockPage

_dll FUNCTION MultiUnlockPage( pMultiPage as ptr, pWinBmp as ptr, bApplyChange as logic ) as void PASCAL:FabPaint.FabMultiUnlockPage
//p Unlock a DIB object from a MultiPage Image
//d This function will unlock a page and apply/discard changes
//j FUNCTION:MultiGetPage
//j FUNCTION:MultiLockPage 

_dll FUNCTION DIBGetBits( pWinBmp as ptr ) as ptr PASCAL:FabPaint.FabDIBGetBits
//p Get a pointer to data bits inside the aimge
//d Using the DIBGetInfo function you can retrieve the _WINBITMAPINFO structure.   
//d Using this function you can now draw the image by yourself using StrechDIBits(), ....
//r A pointer to the Data bits
//j FUNCTION:DIBGetInfo


_dll FUNCTION DIBIsTransparent( pWinBmp as ptr ) as logic PASCAL:FabPaint.FabDIBIsTransparent
//p Check if the Image is transparent
//d Returns TRUE when the transparency table is enabled   
//r A logical value
//j FUNCTION:DIBHasBackgroundColor


_dll FUNCTION DIBHasBackgroundColor( pWinBmp as ptr ) as logic PASCAL:FabPaint.FabDIBHasBackgroundColor
//p Check if the Image has a background color
//d Returns TRUE when the image has a background color,   
//r A logical value
//j FUNCTION:DIBIsTransparent

_dll FUNCTION DIBGetBackgroundColor( pWinBmp as ptr, pRGB as _WINRGBQUAD ) as logic PASCAL:FabPaint.FabDIBGetBackgroundColor
//p Retrieves the file background color of an image.
//d For 8-bit images, the color index in the palette is returned in the rgbReserved member of the <pRGB> parameter.   
//r Returns TRUE if successful, FALSE otherwise.
//j FUNCTION:DIBHasBackgroundColor

_dll FUNCTION DIBSetBackgroundColor( pWinBmp as ptr, pRGB as _WINRGBQUAD ) as logic PASCAL:FabPaint.FabDIBSetBackgroundColor
//p Set the file background color of an image. 
//d When saving an image to PNG, this background color is transparently saved to the PNG file.
//d When the bkcolor parameter is null, the background color is removed from the image.
//r Returns TRUE if successful, FALSE otherwise.
//j FUNCTION:DIBHasBackgroundColor

_dll FUNCTION DIBCreateFromFileEx(pszFName as psz, nFlag as long) as ptr PASCAL:FabPaint.FabDIBCreateFromFileEx
//p Create a DIB object from a File
//a <pszFName> Name of the file to read.
//a <nFlag> Some bitmap loaders can receive parameters to change the loading behaviour. When the parameter is not available or unused you can pass the value 0.
//a Look at FreeImage help for more info
//d This function will read the indicated file, and create a DIB object.
//d The image can be any of : .JPG, .TIF, .BMP, .TGA, .PNG, .PCX, or .PCT.
//r A pointer to the DIB object
//j FUNCTION:DIBDelete


_dll FUNCTION DIBCreateMemStream() as void PASCAL:FabPaint.FabDIBCreateMemStream
//p Create an internal MemStream for saving operation

_dll FUNCTION DIBDeleteMemStream() as void PASCAL:FabPaint.FabDIBDeleteMemStream
//p Delete an internal MemStream. MUST be called before closing application

_dll FUNCTION DIBSaveToMemStream(pWinBmp as ptr, ImageFormat as dword, Flags as int) as void PASCAL:FabPaint.FabDIBSaveToMemStream
//p Save a image to a MemStream
//a <pWinBMp> Pointer to the DIB Object to save
//a <ImageFormat> is a FreeImage define that indicate the FileFormat to be use for the save operation
//a <Flags> Is an additional parameter, depending of the desired ImageFormat
//d See FreeImage documentation for more info on Flags 

_dll FUNCTION DIBAcquireMemStream( pBuffer as ptr, pSize as dword ptr) as void PASCAL:FabPaint.FabDIBAcquireMemStream
//p Get data from a MemStream
//a <pBuffer> is a byte pointer. At exit, it indicate where the data are stored
//a <pSize> is a Dword pointer. At exit, it indicates the size of the buffer

_dll FUNCTION DIBPasteSub( pImg as ptr, pSub as ptr, left as long, top as long, alpha as dword ) as logic PASCAL:FabPaint.FabDIBPasteSub
//p Paste a sub image into an image
//a <pImg> is the "original" image
//a <pSub> is the Sub image to paste
//a <left> indicates the desired position of the sub image
//a <top> indicates the desired position of the sub image
//a <alpha> is the alpha blend factor. if alpha > 255, images are combined

_dll FUNCTION DIBSetTransparent( pImg as ptr, enable as logic ) as void PASCAL:FabPaint.FabDIBSetTransparent
//p Use the Transparency table 
//a <pImg> Pointer to the DIB Object to use
//a <enagle> logical value to use

_dll FUNCTION DIBComposite( pWinBmp as ptr, UseFile as Logic, pRGB as _winRGBQUAD, pBackgroundImage as ptr ) as void PASCAL:FabPaint.FabDIBComposite
//d Composite a foreground image against a background color or a background image. 
//a <pWinBmp> Pointer to the DIB object to show.
//a <UseFile> is a logic flag, If TRUE and a file background is present, use it as the background color
//a <pRGB> is a pointer to a _WinRGBQUAD. If not equal to NULL, and useFileBkg is FALSE, use this color as the background color
//a <pBackgroundImage> is a pointer to a DIB object. If not equal to NULL and UseFile is FALSE and pRGB is NULL, use this as the background image. 
_dll FUNCTION DIBStretchExDrawDCBackground( pWinBmp as ptr, hDC as ptr, pRectDest as _WINRect, pRectSrc as _WINRect, ;
														UseFile as Logic, pRGB as _winRGBQUAD, pBackgroundImage as ptr ; 
														) as void PASCAL:FabPaint.FabDIBStretchExDrawDCBackground
//p Stretch a DIB Object in a Window, using (or not) a background color / image
//d Composite a foreground image against a background color or a background image, then Draw it in the hDC. 
//a <pWinBmp> Pointer to the DIB object to show.
//a <hDC> Handle of the device context to use
//a <pRectDest> Destination Rectangle in the specified Window.
//a  If NULL_PTR, the pRectSrc rectangle is used.
//a <pRectSrc> Rectangle part of the image to draw into the destination rectangle.
//a  If NULL_PTR, the actual Width and Height of the image are used.
//a <UseFile> is a logic flag, If TRUE and a file background is present, use it as the background color
//a <pRGB> is a pointer to a _WinRGBQUAD. If not equal to NULL, and useFileBkg is FALSE, use this color as the background color
//a <pBackgroundImage> is a pointer to a DIB object. If not equal to NULL and UseFile is FALSE and pRGB is NULL, use this as the background image.  
//j FUNCTION:DIBStretchDC
//j FUNCTION:DIBShowDC
//j FUNCTION:DIBStretchExDrawDCBackground

_dll FUNCTION DIBSaveAsAny(pWinBmp as ptr, pszFName as psz, FI_Flag as int, FIF as int ) as void PASCAL:FabPaint.FabDIBSaveAsAny
//p Save a DIB Object to a file
//a <pWinBMp> Pointer to the DIB Object to save
//a <pszFName> Name of the File to create
//a <FI_Flag is the flag to use in save operation. (look at FreeImage Help file for more info) 0 is the default value
//a <FIF> indicates what is the file format to use.
//d This function will save the desired DIB Object as any image format that FreeImage support.
/*
	FIF_BMP		= 0,
	FIF_ICO		= 1,
	FIF_JPEG	= 2,
	FIF_JNG		= 3,
	FIF_KOALA	= 4,
	FIF_LBM		= 5,
	FIF_IFF = FIF_LBM,
	FIF_MNG		= 6,
	FIF_PBM		= 7,
	FIF_PBMRAW	= 8,
	FIF_PCD		= 9,
	FIF_PCX		= 10,
	FIF_PGM		= 11,
	FIF_PGMRAW	= 12,
	FIF_PNG		= 13,
	FIF_PPM		= 14,
	FIF_PPMRAW	= 15,
	FIF_RAS		= 16,
	FIF_TARGA	= 17,
	FIF_TIFF	= 18,
	FIF_WBMP	= 19,
	FIF_PSD		= 20,
	FIF_CUT		= 21,
	FIF_XBM		= 22,
	FIF_XPM		= 23,
	FIF_DDS		= 24,
	FIF_GIF     = 25,
	FIF_HDR		= 26,
	FIF_FAXG3	= 27,
	FIF_SGI		= 28,
	FIF_EXR		= 29,
	FIF_J2K		= 30,
	FIF_JP2		= 31
  */
