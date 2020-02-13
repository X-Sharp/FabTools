//#include "GlobalDefines.vh"
//#include "VOSystemLibrary.vh"
//#include "VOWin32APILibrary.vh"
using FreeImageAPI
using FreeImageAPI.Metadata
using System.IO
using System.Windows.Forms
using VOWin32APILibrary
using System.Runtime.InteropServices;

#define SRCCOPY                     0x00CC0020U 
#define DIB_RGB_COLORS              0
#define COLORONCOLOR                3

BEGIN Namespace FabPaintLib

    CLASS FabPaintLibBase
    // Internal FreeImageBitmap
        protected INTERNAL oDibObject  as  FIBitmap
    
//	PROTECT pDibObject	AS	PTR
//	EXPORT pDibObject					as	ptr
	
	// Owner to notify any changes
	// Object
	PROTECT oOwner						as	OBJECT
	// Please, don't notify my owner...
	PROTECT lSuspendNotification	as	LOGIC
	// a MultiPage Object that owns the Image
	protect oContainer 				as FabMultiPage
	//
	protect nExifModel				as	FREE_IMAGE_MDMODEL
	// Default FileFormat when retrieving the image as a string
	protect cAsStringFileFormat 	as string
	
	// Direct Import of that function
	// The Wrapper is using Generics to call it in a way Vulcan doesn't like
	[DllImport( "FreeImage.dll" )] ; 
	static Method FreeImage_Rotate( dib as FIBITMAP, angle as double, backgroundColor as IntPtr ) AS FIBitmap
		
		
	INTERNAL METHOD GetDib() as FIBitmap
	    return self:oDibObject
	    
	METHOD __NotifyOwner( symEvent AS SYMBOL ) AS VOID  
	//
	    IF ( SELF:oOwner != NULL_OBJECT )
		    IF IsMethod( SELF:oOwner, #OnFabPaintLib ) .AND. !SELF:lSuspendNotification
			    Send( SELF:oOwner, #OnFabPaintLib, SELF, symEvent )
		    ENDIF
	    ENDIF
	//
    return

    ACCESS AsString as String  
    //r The Bitmap as a list of bytes, to be stored for eg. in a blob
	Local cFileContent as String
	Local nFif 			as FREE_IMAGE_FORMAT
    local sr            as StreamReader   
	local Memory        as MemoryStream        	
	//
	IF self:IsValid
		//
		Do case    
		case ( self:cAsStringFileFormat == "BMP" )
			nFif := FREE_IMAGE_FORMAT.FIF_BMP
		case ( self:cAsStringFileFormat == "ICO" )
			nFif := FREE_IMAGE_FORMAT.FIF_ICO
		case ( self:cAsStringFileFormat == "JPG" )
			nFif := FREE_IMAGE_FORMAT.FIF_JPEG 
		case ( self:cAsStringFileFormat == "JPEG" )
			nFif := FREE_IMAGE_FORMAT.FIF_JPEG  
		case ( self:cAsStringFileFormat == "PCX" )
			nFif := FREE_IMAGE_FORMAT.FIF_PCX 
		case ( self:cAsStringFileFormat == "PNG" )
			nFif := FREE_IMAGE_FORMAT.FIF_PNG
		case ( self:cAsStringFileFormat == "TIF" )
			nFif := FREE_IMAGE_FORMAT.FIF_TIFF 
		case ( self:cAsStringFileFormat == "TIFF" )
			nFif := FREE_IMAGE_FORMAT.FIF_TIFF 
		case ( self:cAsStringFileFormat == "GIF" )
			nFif := FREE_IMAGE_FORMAT.FIF_GIF
		case ( self:cAsStringFileFormat == "J2K" )
			nFif := FREE_IMAGE_FORMAT.FIF_J2K
		case ( self:cAsStringFileFormat == "JP2" )
			nFif := FREE_IMAGE_FORMAT.FIF_J2K		
		endcase
		//
		// Now Create the Memory Stream
		Memory := MemoryStream{}
		// Save the Image to the Memory Stream
		FreeImage.SaveToStream( Self:oDibObject, Memory, nFif )
		// Now Retrieve the buffer where the memory is stored
		sr := StreamReader{ Memory }
		// Now, convert to a string
		cFileContent := sr:ReadToEnd()
	ENDIF
    RETURN cFileContent

    Assign AsString( cFileContent as string )   
    //r The Bitmap as a list of bytes, to be stored for eg. in a blob
        local Memory as MemoryStream
        local sw as StreamWriter
        //
        Memory := MemoryStream{}
        sw := StreamWriter{ Memory }
        //
        sw:Write( cFileContent )
        sw:Flush()
        //
        Self:CreateFromStream( Memory )
    RETURN 
	
    ACCESS AsStringFileFormat as String  
    //r The FileFormat to be used when using the Access AsString
    RETURN self:cAsStringFileFormat
    	
    ASSIGN AsStringFileFormat( cFif as string )   
    //r The FileFormat to be used when using the Access AsString
        self:cAsStringFileFormat := Upper(cFif)
    RETURN
    
    /*DESTRUCTOR() 
	    //
	    SELF:Destroy()
	    //
	    //IF !InCollect()
	    //	UnRegisterAxit( SELF )
	    //ENDIF
	    //
    return*/ 

    ACCESS BitmapBits as ptr  
    // 
	    local pBits as ptr
	    //
	    if self:IsValid
		    pBits := FreeImage.GetBits( self:oDibObject )
	    endif              
	    //
    RETURN pBits


    ACCESS BitPerPixel AS WORD  
    //r The number of bit per pixel in the current image
	    LOCAL pBmiH	AS	FreeImageAPI.BITMAPINFOHEADER
	    LOCAL nBpp	AS	WORD
	    //
	    IF SELF:IsValid
	        //
	        pBmiH := FreeImage.GetInfoHeaderEx( SELF:oDibObject )
		    nBpp := pBmiH:biBitCount
	    ENDIF
    RETURN nBpp
	
    METHOD ChangeContrast( percentage as double, bOffset AS BYTE ) AS VOID  
        // For Compatibility
        Self:ChangeContrast( percentage )
    
    METHOD ChangeContrast( percentage as double ) AS VOID  
	    //
	    IF SELF:IsValid
	        FreeImage.AdjustContrast( Self:oDibObject, percentage )
		    //
		    SELF:__NotifyOwner( #Contrast )
		    //
	    ENDIF
	    //
    return 

    METHOD ChangeIntensity( gamma as double, bOffset AS BYTE, rExponent AS REAL8 ) AS VOID  
        // For Compatibility
        Self:ChangeIntensity( gamma )
        
    METHOD ChangeIntensity( gamma as double ) AS VOID  
	    //
	    IF SELF:IsValid
	        FreeImage.AdjustGamma( Self:oDibObject, gamma )
		    //
		    SELF:__NotifyOwner( #Intensity )
		    //
	    ENDIF
	    //
    return

    METHOD ChangeLightness( percentage as double ) AS VOID  
	    //
	    IF SELF:IsValid
	        FreeImage.AdjustBrightness( Self:oDibObject, percentage ) 
		    //
		    SELF:__NotifyOwner( #Lightness )
		    //
	    ENDIF
	    //   
    return

    METHOD Composite( lUseFile as Logic, pRGB as FreeImageAPI.RGBQUAD[ ], oBackgroundImage as FabPaintLibBase ) as void  
    //a <lUseFile> use file as background ?
    //a <pRGB> is a _WinRGBQUAD struct with background color
    //a <oBackgroundImage> is a FabPaintLib object to use as background
    //j FUNCTION:DIBStretchDrawDC
        local oComposed as FIBitmap
	    local oDIB as FIBitmap
	    //
	    IF self:IsValid
	        //
		    if ( oBackgroundImage != null_object )
			    oDIB := oBackgroundImage:oDibObject
		    endif
		    oComposed := FreeImage.Composite( Self:oDibObject, lUseFile, pRGB, oDib )
		    //
		    Self:CreateFrom( oComposed )
	    ENDIF
	    //
    return

    METHOD Copy( bpp := 0 AS LONG ) AS FabPaintLib  
        //p Create a Copy of the object
        //a <bpp> Number of Bit Per Pixel to use in the copy
        //a Values can be 1,8,32.
        //a 0,per default, means no change.
        //r The new FabPaintLib object
	    LOCAL oNew	AS	FabPaintLib
	    local oDib  as FIBitmap
	    local fibpp as FreeImageAPI.FREE_IMAGE_COLOR_DEPTH
	    //
	    IF SELF:IsValid
	        //
	        do case
	           case bpp==1
	              fibpp := FreeImageAPI.FREE_IMAGE_COLOR_DEPTH.FICD_01_BPP
	           case bpp=8
	              fibpp := FreeImageAPI.FREE_IMAGE_COLOR_DEPTH.FICD_08_BPP
	           case bpp=32
	              fibpp := FreeImageAPI.FREE_IMAGE_COLOR_DEPTH.FICD_32_BPP
	        endcase
	        if ( bpp == 0)
	           oDib := FreeImage.Clone( Self:oDibObject )
	        else
	            //
	            oDib := FreeImage.ConvertColorDepth( Self:oDibObject, fibpp, false )
	        endif
	        //
		    oNew := FabPaintLib{ oDib, null }
	    ENDIF
	    //
    RETURN oNew

    METHOD Create( nWidth:=16 AS LONG, nHeight := 16 AS LONG, nBpp := 8 AS WORD, lAlpha := FALSE  AS LOGIC ) AS LOGIC  
        //p Initialize an empty DIB Object
        //r A logical value indicating the success of the operation
	    //
	    SELF:Destroy()
	    Self:oDibObject := FreeImage.Allocate( nWidth, nHeight, nBpp, FreeImage.FI_RGBA_RED_MASK, FreeImage.FI_RGBA_GREEN_MASK, FreeImage.FI_RGBA_BLUE_MASK)
	    //
	    SELF:__NotifyOwner( #Create )
	    //
    RETURN SELF:IsValid

    METHOD CreateFromStream( Stream as System.IO.Stream ) as LOGIC
        Self:Destroy()
        //
        Self:oDibObject := FreeImage.LoadFromStream( Stream )
        //
        SELF:__NotifyOwner( #CreateFromFile )
	    //
    RETURN SELF:IsValid


    METHOD CreateFromFile( cFile AS STRING ) AS LOGIC  
    //p Initialize from a File
    //a <cFile> Name of the file to read.
    //d This method will read the indicated file, and initialize the object.
    //d The image can be any of : .JPG, .TIF, .BMP, .TGA, .PNG, .PCX, or .PCT.
    //r A logical value indicating the success of the operation
        IF ( cFile:Length > 0 )
	        //
	        self:Destroy()
	        cFile := Lower(Trim(cFile))
            Self:oDibObject := FreeImage.LoadEx( cFile )
	        //
	        SELF:__NotifyOwner( #CreateFromFile )
	    endif
	    //
    RETURN SELF:IsValid

    METHOD CreateFromHBitmap( hBitmap AS PTR ) AS LOGIC  
    //p Initialize from bitmap Handle
    //a <hBitmap>	Handle of the Bitmap to use to Initialize the object
    //d This function copy the pixels in hBitmap to a DIB object
    //r A logical value indicating the success of the operation
	    //
	    SELF:Destroy()
	    Self:oDibObject := FreeImage.CreateFromHbitmap(hbitmap, IntPtr.Zero);
	    //
	    SELF:__NotifyOwner( #CreateFromHBitmap )
	    //
    RETURN SELF:IsValid

    METHOD CreateFromHDib( hDib AS PTR ) AS LOGIC  
    //p Initialize from Device Independent Bitmap memory
    //a <hDIB>	Handle of the DIB to use to Initialize the object
    //d This function copy the pixels in hDIB to a DIB object
    //r A logical value indicating the success of the operation
	    //
	    SELF:Destroy()
	    // TODO : Support for HDib
	    //SELF:oDibObject := DIBCreateFromHDib( hDib )
	    //
	    SELF:__NotifyOwner( #CreateFromHDib )
	    //
    RETURN FALSE //SELF:IsValid
	

    METHOD CreateFromPtr( pbImage as byte ptr, nSize as DWORD ) as LOGIC  
    //p Initialize from memory block
    //a <pbImage>	Pointer to the memory block
    //a <nSIze>		Size of the memory block
    //d This function will read the indicated memory as if it was a file, and then
    //d init the object. So you can copy a file to memory, with a ProgressBar, and then use this method.
    //r A logical value indicating the success of the operation
        //TODO Read from Pointer to Stream
        //local Memory as System.IO.MemoryStream
        //Memory := System.IO.MemoryStream{ nSize }
        //Memory:Write( pbImage, 0, nSize )
	    //
	    //Self:CreateFromStream( Memory )
	    //
    RETURN FALSE //SELF:IsValid

    METHOD CreateFromResourceID( hInst AS PTR, nID AS DWORD ) AS LOGIC  
    //p Initialize from bitmap resource ID
    //a <hInst> Handle to the resource module handle
    //a  This can be _GetInst() for the current Exe, or and result of LoadLibrary()
    //a <nID> ID Number of the resource to use.
    //d This function copy the pixels in the resource to a DIB object
    //r A logical value indicating the success of the operation
        Local hRes as IntPtr
        //
        Self:Destroy()
        //
        hRes := LoadBitmap( hInst, (IntPtr)nID )
        //
        Self:CreateFromHBitmap( hRes )
        //
        DeleteObject( hRes) 
	    //
    RETURN SELF:IsValid
		

    METHOD CreateFromResourceName( hInst AS PTR, cResName AS STRING ) AS LOGIC  
    //p Initialize from bitmap resource name
    //a <hInst> Handle to the resource module handle
    //a  This can be _GetInst() for the current Exe, or and result of LoadLibrary()
    //a <pszRes> Name of the resource to use.
    //d This function copy the pixels in the resource to a DIB object
    //r A logical value indicating the success of the operation
        Local hRes as IntPtr
        
        //
        Self:Destroy()
        //
        hRes := LoadBitmap( IntPtr.Zero , String2Psz(cResName) )
        //
        Self:CreateFromHBitmap( hRes )
        //
        DeleteObject( hRes) 
	    //
    RETURN SELF:IsValid

    METHOD CreateFromScreen ( nLeft AS LONG, nTop AS LONG, nRight AS LONG, nBottom AS LONG ) AS LOGIC  
    //p Initialize a DIB from a specified screen area
    //a Screen coordinates
    //a nLeft AS LONG, nTop AS LONG, nRight AS LONG, nBottom AS LONG
    //d This function creates a DIB object from a specified screen area
    //r A logical value indicating the success of the operation
        local MemoryImage as System.Drawing.Bitmap
        local memoryGraphics as System.Drawing.Graphics
        local whSize  as System.Drawing.Size
        //
        whSize := System.Drawing.Size{ nRight - nLeft, nBottom - nTop }
        //
        memoryImage := System.Drawing.Bitmap{ whSize:Width, whSize:Height, System.Drawing.Imaging.PixelFormat.Format32bppArgb }
        memoryGraphics := System.Drawing.Graphics.FromImage( memoryImage )
        memoryGraphics:CopyFromScreen( nLeft, nTop, 0, 0, whSize, System.Drawing.CopyPixelOperation.SourceCopy )
        //
        Self:Destroy()
        //
        Self:oDibObject := FreeImage.CreateFromBitmap( memoryImage )
        //
        SELF:__NotifyOwner( #CreateFromScreen )
    RETURN SELF:IsValid	

    PROTECTED METHOD CreateFrom( oNew as FIBitmap ) AS LOGIC  
    //p Initialize from FIBitmap 
	    //
	    SELF:Destroy()
	    //
	    SELF:oDibObject := oNew
	    //
    RETURN SELF:IsValid

    METHOD Crop( XMin AS LONG, XMax AS LONG, YMin AS LONG, YMax AS LONG ) AS VOID  
    //p Extract a part of the image
    //a XMin,XMax,YMin,YMax The coordonates of the part to extract
    //d This function will extract a part of the Image, indicated by the X,Y coordonates, and make it the new image
        local oNew as FIBitmap
	    //
	    IF SELF:IsValid
	        oNew := FreeImage.Copy( Self:oDibObject, XMin, XMax, YMin, YMax)
	        Self:CreateFrom( oNew )
		    //
		    SELF:__NotifyOwner( #Crop )
		    //
	    ENDIF
	    //
    return

    METHOD Destroy() as void  
    //p Delete the underlying DIB Object
	    //
	    IF self:IsValid 
		    //
		    if ( self:oContainer != null_object )
			    self:oContainer:UnlockPage( self, false )
			    self:oContainer := null_object
		    endif			 
		    //
		    FreeImage.Unload( Self:oDibObject )
		    SELF:oDibObject:SetNull()
		    //
		    SELF:__NotifyOwner( #Destroy )
		    //
	    ENDIF
	    //
    return

    METHOD EXIFGetTag( cTagName AS STRING ) AS STRING  
	    //LOCAL pBuffer	AS PTR
	    //LOCAL liSize	AS LONG
	    LOCAL cTagValue	AS STRING
	    //local cName     as String
	    LOCAL oTag      as MetadataTag
	    local nModel    as FREE_IMAGE_MDMODEL
	    //
	    cTagValue := ""
	    IF SELF:IsValid
		    IF ( self:EXIFTagCount > 0 )
			    if ( self:EXIFModel == FREE_IMAGE_MDMODEL.FIMD_NODATA )	
			        ////////////////////
			        // 
			        //			        	        
			        if ( cTagName:IndexOf( "Sub." ) == 0 )
			            // Ok, it starts with "Sub."
			            nModel := FREE_IMAGE_MDMODEL.FIMD_EXIF_EXIF
			            cTagName := cTagName:Substring( 4 )
			        elseif ( cTagName:IndexOf( "Main." ) == 0 )
			            // Ok, it starts with "Main."
			            nModel := FREE_IMAGE_MDMODEL.FIMD_EXIF_MAIN
			            cTagName := cTagName:Substring(5)
			        else
			            // None of thme, try with TagName directly    
			            nModel := FREE_IMAGE_MDMODEL.FIMD_EXIF_MAIN
			        endif
			    else
			       nModel := Self:EXIFModel
                endif
			    if ( FreeImage.GetMetaData( nModel, Self:oDibObject, cTagName, oTag ) )
			       cTagValue := oTag:ToString()
			    endif			
		    ENDIF
	    ENDIF
    RETURN cTagValue

    METHOD EXIFGetTagDescription( dwPos AS DWORD ) AS STRING  
/*	    LOCAL pBuffer	AS PTR
	    LOCAL liSize	AS LONG*/
	    LOCAL cTagDesc  AS STRING
	    local nTotalMain as long
	    local nTotalSub  as long
	    local nModel     as FREE_IMAGE_MDMODEL
        LOCAL oTag      as MetadataTag
        local lFind     as logic
        local Count     as long
        local hFind     as FIMETADATA
	    //
	    IF SELF:IsValid
		    IF ( self:EXIFTagCount > 0 )
			    if ( self:EXIFModel == FREE_IMAGE_MDMODEL.FIMD_NODATA )
			        //
			        nTotalMain := FreeImage.GetMetadataCount( FREE_IMAGE_MDMODEL.FIMD_EXIF_MAIN, Self:oDibObject )
			        nTotalSub  := FreeImage.GetMetadataCount( FREE_IMAGE_MDMODEL.FIMD_EXIF_EXIF, Self:oDibObject )
			        //
			        if ( dwPos < nTotalMain )
			            nModel := FREE_IMAGE_MDMODEL.FIMD_EXIF_MAIN 
			        else
			           dwPos := dwPos - nTotalMain
			           nModel := FREE_IMAGE_MDMODEL.FIMD_EXIF_EXIF
			        endif			
			    ELSE
			       nModel := SELF:EXIFModel
			    endif
			    //
			    lFind := FALSE
			    Count := 0
			    hFind := FreeImage.FindFirstMetadata( nModel, Self:oDibObject, oTag )
			    //
			    if ( ! hFind:IsNull )
			        Repeat
			            if ( Count == dwPos )
			               lFind := true
			               exit
			            endif
			            // Tag Count
			            Count ++
			        until ( ! FreeImage.FindNextMetadata( hFind, oTag ) )
			        //
			        if lFind
			           cTagDesc := oTag:Description
			        endif
		        endif
		    ENDIF
	    ENDIF
    RETURN cTagDesc

    METHOD EXIFGetTagShortName( dwPos AS DWORD ) AS STRING  
/*	    LOCAL pBuffer	AS PTR
	    LOCAL liSize	AS LONG*/
	    LOCAL cTagKey  AS STRING
	    local nTotalMain as long
	    local nTotalSub  as long
	    local nModel     as FREE_IMAGE_MDMODEL
        LOCAL oTag      as MetadataTag
        local lFind     as logic
        local Count     as long
        local hFind     as FIMETADATA
	    //
	    IF SELF:IsValid
		    IF ( self:EXIFTagCount > 0 )
			    if ( self:EXIFModel == FREE_IMAGE_MDMODEL.FIMD_NODATA )
			        //
			        nTotalMain := FreeImage.GetMetadataCount( FREE_IMAGE_MDMODEL.FIMD_EXIF_MAIN, Self:oDibObject )
			        nTotalSub  := FreeImage.GetMetadataCount( FREE_IMAGE_MDMODEL.FIMD_EXIF_EXIF, Self:oDibObject )
			        //
			        if ( dwPos < nTotalMain )
			            nModel := FREE_IMAGE_MDMODEL.FIMD_EXIF_MAIN 
			        else
			           dwPos := dwPos - nTotalMain
			           nModel := FREE_IMAGE_MDMODEL.FIMD_EXIF_EXIF
			        endif			
			    ELSE
			       nModel := SELF:EXIFModel
			    endif
			    //
			    lFind := FALSE
			    Count := 0
			    hFind := FreeImage.FindFirstMetadata( nModel, Self:oDibObject, oTag )
			    //
			    if ( ! hFind:IsNull )
			        Repeat
			            if ( Count == dwPos )
			               lFind := true
			               exit
			            endif
			            // Tag Count
			            Count ++
			        until ( ! FreeImage.FindNextMetadata( hFind, oTag ) )
			        //
			        if lFind
			           cTagKey := oTag:Key
			        endif
		        endif
		    ENDIF
	    ENDIF
    RETURN cTagKey

    METHOD EXIFGetTagValue( dwPos AS DWORD ) AS STRING  
/*	    LOCAL pBuffer	AS PTR
	    LOCAL liSize	AS LONG*/
	    LOCAL cTagValue  AS STRING
	    local nTotalMain as long
	    local nTotalSub  as long
	    local nModel     as FREE_IMAGE_MDMODEL
        LOCAL oTag      as MetadataTag
        local lFind     as logic
        local Count     as long
        local hFind     as FIMETADATA
	    //
	    IF SELF:IsValid
		    IF ( self:EXIFTagCount > 0 )
			    if ( self:EXIFModel == FREE_IMAGE_MDMODEL.FIMD_NODATA )
			        //
			        nTotalMain := FreeImage.GetMetadataCount( FREE_IMAGE_MDMODEL.FIMD_EXIF_MAIN, Self:oDibObject )
			        nTotalSub  := FreeImage.GetMetadataCount( FREE_IMAGE_MDMODEL.FIMD_EXIF_EXIF, Self:oDibObject )
			        //
			        if ( dwPos < nTotalMain )
			            nModel := FREE_IMAGE_MDMODEL.FIMD_EXIF_MAIN 
			        else
			           dwPos := dwPos - nTotalMain
			           nModel := FREE_IMAGE_MDMODEL.FIMD_EXIF_EXIF
			        endif			
			    ELSE
			       nModel := SELF:EXIFModel
			    endif
			    //
			    lFind := FALSE
			    Count := 0
			    hFind := FreeImage.FindFirstMetadata( nModel, Self:oDibObject, oTag )
			    //
			    if ( ! hFind:IsNull )
			        Repeat
			            if ( Count == dwPos )
			               lFind := true
			               exit
			            endif
			            // Tag Count
			            Count ++
			        until ( ! FreeImage.FindNextMetadata( hFind, oTag ) )
			        //
			        if lFind
			           cTagValue := oTag:ToString()
			        endif
		        endif
		    ENDIF
	    ENDIF
    RETURN cTagValue

    ACCESS EXIFModel as FREE_IMAGE_MDMODEL  
    RETURN self:nExifModel

    ASSIGN EXIFModel( lModel as FREE_IMAGE_MDMODEL )   
	    self:nExifModel := lModel
    RETURN //self:nExifModel


    ACCESS EXIFTagCount AS LONG  
	    LOCAL liTagCount	AS	LONG
	    //
	    IF SELF:IsValid
			    if ( self:EXIFModel == FREE_IMAGE_MDMODEL.FIMD_NODATA )
			        //
			        liTagCount := FreeImage.GetMetadataCount( FREE_IMAGE_MDMODEL.FIMD_EXIF_MAIN, Self:oDibObject )
			        liTagCount += FreeImage.GetMetadataCount( FREE_IMAGE_MDMODEL.FIMD_EXIF_EXIF, Self:oDibObject )
			    else
			        liTagCount  := FreeImage.GetMetadataCount( self:EXIFModel, Self:oDibObject )
			    endif
	    endif
	return liTagCount	    

    METHOD FromClipboard( dwFormat := 2 AS DWORD ) AS VOID  
        //p Paste the DIB object from the clipboard
        //d The underground object MUST exist before using this method.
        //d At least, use the Create() method.
        //j METHOD:FabPaintLib:Create
        //j METHOD:FabPaintLib:ToClipboard
        local oBitmap as System.Drawing.Bitmap
        //
        IF SELF:IsValid
            //
            if Clipboard.ContainsImage()
                oBitmap := (System.Drawing.Bitmap)Clipboard.GetImage()
                Self:Destroy()
                //
                Self:oDibObject := FreeImage.CreateFromBitmap( oBitmap );
                //
                SELF:__NotifyOwner( #FromClipboard )
            endif    
	        //
        ENDIF
        //	
    return

    Method GetBackgroundColor( pRGB ref _WINRGBQUAD ) as logic  
        Local pFIRGBQuad AS FreeImageAPI.RGBQUAD
        Local lOk as logic
        //
        if self:IsValid
            pFIRGBQuad := FreeImageAPI.RGBQUAD{}
            lOk := FreeImage.GetBackgroundColor( Self:oDibObject, pFIRGBQuad )
            if ( lOk )
                pRGB:rgbBlue := pFIRGBQuad:rgbBlue
                pRGB:rgbGreen := pFIRGBQuad:rgbGreen
                pRGB:rgbRed := pFIRGBQuad:rgbRed
            endif
        endif
    return lOk	

    METHOD GrayScale( ) AS VOID  
    //p Convert the Image to GrayScale
    //d As this operation only support 32 bpp, the image is converted to 32 bpp if necessary before proceeding.
        local oNew as FIBitmap
        //
        IF SELF:IsValid
            oNew := FreeImage.ConvertToGreyscale( self:oDibObject )
            Self:CreateFrom( oNew )
	        //
	        SELF:__NotifyOwner( #MakeGrayScale )
	        //
        ENDIF
        //
    return

    METHOD Handle() AS PTR  
    //r hBitmap for the current image
        LOCAL hBitmap	AS	PTR
        //
        IF SELF:IsValid
	        hBitmap := FreeImage.GetBitmapForDevice( Self:oDibObject, IntPtr.Zero, False )
        ENDIF
    RETURN hBitmap

    ACCESS HasBackgroundColor as LOGIC  
    //r A logical value indicating if the image has a background color.
	    local lBack as Logic
	    //
	    if self:IsValid
		    lBack := FreeImage.HasBackgroundColor( self:oDibObject )
	    endif              
	    //
    RETURN lBack

    ACCESS Height AS LONG  
    //r The Height on pixel of the Image
	    LOCAL nHeight	AS	LONG
	    //
	    IF SELF:IsValid
		    nHeight  := FreeImage.GetHeight( self:oDibObject )
	    ENDIF
    RETURN nHeight
    
    ACCESS Image As System.Drawing.Image
    Return FreeImage.GetBitmap( Self:oDibObject )

    ACCESS Info as _winBitmapInfo 
	    local pInfo as _winBitmapInfo
	    //
	    if self:IsValid
		    pInfo := FreeImage.GetInfo( self:oDibObject )
	    endif              
	    //
    RETURN pInfo
    
    ACCESS InfoHeader as _winBitmapInfoHeader  
	    local pInfo as _winBitmapInfoHeader
	    //
	    if self:IsValid
		    pInfo := FreeImage.GetInfoHeader( self:oDibObject )
	    endif              
	    //
    RETURN pInfo
    
    INTERNAL ASSIGN Owner ( oOwn As Object )
        self:oOwner := oOwn
    RETURN

    CONSTRUCTOR( ) 
    	// None
	    self:nExifModel := FREE_IMAGE_MDMODEL.FIMD_NODATA
	    // Per default
	    self:cAsStringFileFormat := "BMP"
	    //
	return
	
    CONSTRUCTOR( oDib as FIBitmap ) 
        Self:oDibObject := oDib
    	// None
	    self:nExifModel := FREE_IMAGE_MDMODEL.FIMD_NODATA
	    // Per default
	    self:cAsStringFileFormat := "BMP"
	    //
	return
	
    CONSTRUCTOR( oDib as FIBitmap, oOwn as Object ) 
        Self:oDibObject := oDib
    	// None
	    self:nExifModel := FREE_IMAGE_MDMODEL.FIMD_NODATA
	    // Per default
	    self:cAsStringFileFormat := "BMP"
	    //
	    if ( oOwner != null )
	       self:oOwner := oOwn
	    endif
	return

    CONSTRUCTOR( cFile as String, oOwn as Object  ) 
        SELF:CreateFromFile( cFile )
    	// None
	    self:nExifModel := FREE_IMAGE_MDMODEL.FIMD_NODATA
	    // Per default
	    self:cAsStringFileFormat := "BMP"
	    if ( oOwner != null )
	       self:oOwner := oOwn
	    endif
	return

    CONSTRUCTOR( oMultiContainer as FabMultiPage, oOwn as Object ) 
        Self:oContainer := oMultiContainer
    	// None
	    self:nExifModel := FREE_IMAGE_MDMODEL.FIMD_NODATA
	    // Per default
	    self:cAsStringFileFormat := "BMP"
	    //
	    if ( oOwner != null )
	       self:oOwner := oOwn
	    endif
	return
    
    METHOD Invert( ) AS VOID  
    //p Invert the Image
    //d As this operation only support 32 bpp, the image is converted to 32 bpp if necessary before proceeding.
/*	    LOCAL pCopy	AS	PTR*/
	    //
	    IF SELF:IsValid
            FreeImage.Invert( Self:oDibObject )
		    //
		    SELF:__NotifyOwner( #Invert )
		    //
	    ENDIF
	    //
    return

    ACCESS IsTransparent as LOGIC  
    //r A logical value indicating if the image is transparent.
	    local lTransparent as Logic
	    //
	    if self:IsValid
		    lTransparent := FreeImage.IsTransparent( self:oDibObject )
	    endif              
	    //
    RETURN lTransparent


    Assign IsTransparent( lSet as logic )   
    //r A logical value indicating if the image is transparent.
	    //
	    if self:IsValid
		    FreeImage.SetTransparent( self:oDibObject, lSet )
	    endif              
	    //
    RETURN 


    ACCESS IsValid AS LOGIC  
    //r A logical value indicating if the object is linked to an image.
    RETURN ( SELF:oDibObject != FIBITMAP.Zero )
	

    Method PasteSubImage( oSubImage as FabPaintLibBase, Left as long, Top as long ) as logic  
	    local oSub as FIBitmap
	    local lOk as logic
	    //
	    IF self:IsValid
		    if ( oSubImage != null_object )
			    oSub := oSubImage:oDibObject
    		    //lOk := DIBPasteSub( self:pDibObject, pSub, Left, Top, 256 )
	    	    lOk := FreeImage.Paste( Self:oDibObject, oSub, Left, Top, 256 )
	    	 endif
	    ENDIF
	    //
    return lOk
 

    METHOD ResizeBilinear( NewXSize AS LONG, NewYSize AS LONG ) AS VOID  
    //p Resize the Image using bilinear interpolation
    //a <NewXSize> New X Size of the Image
    //a <NewYSize> New Y Size of the Image
    //d As this operation only support 32 bpp, the image is converted to 32 bpp if necessary before proceeding.
	    LOCAL oNew	AS	FIBitmap
	    //
	    IF SELF:IsValid
	        oNew := FreeImage.Rescale( Self:oDibObject, NewXSize, NewYSize, FreeImageAPI.FREE_IMAGE_FILTER.FILTER_BILINEAR )
	        Self:CreateFrom( oNew )
		    //
		    SELF:__NotifyOwner( #ResizeBilinear )
		    //
	    ENDIF
	    //
    return

    METHOD ResizeBox( NewXSize AS LONG, NewYSize AS LONG, NewRadius AS REAL8 ) AS VOID  
    //p Resizes a bitmap and applies a box filter to it
    //a <NewXSize> New X Size of the Image
    //a <NewYSize> New Y Size of the Image
    //a <NewRadius>
    //d As this operation only support 32 bpp, the image is converted to 32 bpp if necessary before proceeding.
	    LOCAL oNew	AS	FIBitmap
	    //
	    IF SELF:IsValid
	        oNew := FreeImage.Rescale( Self:oDibObject, NewXSize, NewYSize, FreeImageAPI.FREE_IMAGE_FILTER.FILTER_BOX )
	        Self:CreateFrom( oNew )
		    //
		    SELF:__NotifyOwner( #ResizeBilinear )
		    //
	    ENDIF
	 return    
	 
    METHOD ResizeGaussian( NewXSize AS LONG, NewYSize AS LONG, NewRadius AS REAL8 ) AS VOID  
    //p Resizes a bitmap and applies a gaussian blur to it.
    //a <NewXSize> New X Size of the Image
    //a <NewYSize> New Y Size of the Image
    //a <NewRadius>
    //d As this operation only support 32 bpp, the image is converted to 32 bpp if necessary before proceeding.
	    LOCAL oNew	AS	FIBitmap
	    //
	    IF SELF:IsValid
	        oNew := FreeImage.Rescale( Self:oDibObject, NewXSize, NewYSize, FreeImageAPI.FREE_IMAGE_FILTER.FILTER_BICUBIC )
	        Self:CreateFrom( oNew )
		    //
		    SELF:__NotifyOwner( #ResizeBilinear )
		    //
	    ENDIF
	 return
	 
    METHOD ResizeHamming( NewXSize AS LONG, NewYSize AS LONG, NewRadius AS REAL8 ) AS VOID  
    //p Resizes a bitmap and applies a hamming filter to it.
    //a <NewXSize> New X Size of the Image
    //a <NewYSize> New Y Size of the Image
    //a <NewRadius>
    //d As this operation only support 32 bpp, the image is converted to 32 bpp if necessary before proceeding.
	    LOCAL oNew	AS	FIBitmap
	    //
	    IF SELF:IsValid
	        oNew := FreeImage.Rescale( Self:oDibObject, NewXSize, NewYSize, FreeImageAPI.FREE_IMAGE_FILTER.FILTER_BSPLINE )
	        Self:CreateFrom( oNew )
		    //
		    SELF:__NotifyOwner( #ResizeBilinear )
		    //
	    ENDIF
	 return

    METHOD Rotate( angle AS REAL8, oColor AS System.Drawing.Color ) AS VOID  
    //p Rotates a bitmap by angle radians.
    //a <angle> Rotation angle in Radian
    //a <color> The RGB Color used to fill new part of the image
    //d As this operation only support 32 bpp, the image is converted to 32 bpp if necessary before proceeding.
	    LOCAL deg as Double
	    //
	    IF SELF:IsValid
	        // angle is in Radian, FreeImage uses Degree....
	        deg := angle * (180.0 / Math.PI )
	        //
	        Self:RotateDeg( deg, oColor )
		    //
	    ENDIF
	    //
    return

    METHOD RotateDeg( angle AS REAL8, oColor AS System.Drawing.Color ) AS VOID  
    //p Rotates a bitmap by angle radians.
    //a <angle> Rotation angle in degree
    //a <color> The RGB Color used to fill new part of the image
    //d As this operation only support 32 bpp, the image is converted to 32 bpp if necessary before proceeding.
	    LOCAL pClr IS _winRGBQUAD
	    //
	    IF SELF:IsValid
	        // It should be 
	        //FreeImage.Rotate<System.Drawing.Color>( Self:oDibObject, angle, oColor )
	        //FreeImage.Rotate( Self:oDibObject, angle, oColor )
	        // But as we can't compile it, let try a workaround with a direct call to the DLL
	        pClr:rgbBlue := oColor:B
	        pClr:rgbRed := oColor:R
	        pClr:rgbGreen := oColor:G
			FreeImage_Rotate( Self:oDibObject, angle, @pClr )
		    SELF:__NotifyOwner( #Rotate )
		    //
	    ENDIF
	    //
    return

    METHOD SaveAs( cFileName AS STRING ) AS VOID  
    //p Save to a DIB file
    //a <cFileName> Name of the File to create
    //d This method will save the desired DIB Object as a DIB file.
	    //
	    IF SELF:IsValid
	        FreeImage.SaveEx( Self:oDibObject, cFileName )
	    ENDIF
	    //
    return

    METHOD SaveAsAny( cFileName as STRING, FI_Flag as int, FIF as int ) as void  
    //p Save to a file
    //a <cFileName> Name of the File to create
    //a <FI_Flag is the flag to use in save operation. (look at FreeImage Help file for more info) 0 is the default value
    //a <FIF> indicates what is the file format to use.
    //d This method will save the desired DIB Object as a file.
	    //
	    IF self:IsValid
		    FreeImage.SaveEx( Self:oDibObject, cFileName, (FreeImageAPI.FREE_IMAGE_FORMAT)FIF, (FreeImageAPI.FREE_IMAGE_SAVE_FLAGS)FI_Flag )
	    ENDIF
	    //
    return
//-----------------------------------------------------------------------------------------------------------------------------------//
    METHOD SaveAsJPEG( cFileName AS STRING ) AS VOID  
    //p Save to a JPEG file
    //a <cFileName> Name of the File to create
    //d This function will save the desired DIB Object as a JPEG file.
	    //
	    IF SELF:IsValid
	        FreeImage.SaveEx( Self:oDibObject, cFileName, FreeImageAPI.FREE_IMAGE_FORMAT.FIF_JPEG )
	    ENDIF
	    //
    return
    
    METHOD SaveAsJPEGEx( cFileName AS STRING, Quality as int ) AS VOID
	    //
	    IF SELF:IsValid
	        FreeImage.SaveEx( Self:oDibObject, cFileName, FreeImageAPI.FREE_IMAGE_FORMAT.FIF_JPEG, (FreeImageAPI.FREE_IMAGE_SAVE_FLAGS)Quality )
	    ENDIF
	    //
    return    
    

    METHOD SaveAsPNG( cFileName AS STRING ) AS VOID  
    //p Save to a PNG file
    //a <cFileName> Name of the File to create
    //d This function will save the desired DIB Object as a PNG file.
	    //
	    IF SELF:IsValid
		    FreeImage.SaveEx( Self:oDibObject, cFileName, FreeImageAPI.FREE_IMAGE_FORMAT.FIF_PNG )
	    ENDIF
	    //
    return
        
    METHOD SaveAsPNGEx( cFileName AS STRING, PNGLevel as int ) AS VOID
	    //
	    IF SELF:IsValid
	        FreeImage.SaveEx( Self:oDibObject, cFileName, FreeImageAPI.FREE_IMAGE_FORMAT.FIF_PNG, (FreeImageAPI.FREE_IMAGE_SAVE_FLAGS)PNGLevel )
	    ENDIF
	    //
    return 
        

    METHOD SaveAsTIFF( cFileName AS STRING ) AS VOID  
    //p Save to a TIFF file
    //a <cFileName> Name of the File to create
    //d This function will save the desired DIB Object as a TIFF file.
	    //
	    IF SELF:IsValid
		    FreeImage.SaveEx( Self:oDibObject, cFileName, FreeImageAPI.FREE_IMAGE_FORMAT.FIF_TIFF )
	    ENDIF
	    //
    return
    
    METHOD SaveAsTIFFEx( cFileName AS STRING, Quality as int ) AS VOID
	    //
	    IF SELF:IsValid
	        FreeImage.SaveEx( Self:oDibObject, cFileName, FreeImageAPI.FREE_IMAGE_FORMAT.FIF_TIFF, (FreeImageAPI.FREE_IMAGE_SAVE_FLAGS)Quality )
	    ENDIF
	    //
    return     

    Method SetBackgroundColor( oColor as System.Drawing.Color ) as logic  
	    Local lOk as logic
	    LOCAL oRGB AS RGBQUAD
	    //
	    oRGB := RGBQUAD{ oColor }
	    //
	    if self:IsValid
	        FreeImage.SetBackgroundColor( Self:oDibObject, oRGB )
		    //DIBSetBackgroundColor( self:pDibObject, pRGB )
	    endif
    return lOk	

    METHOD ToClipboard( ) AS VOID  
    //p Copy the DIB object to the clipboard
    //j METHOD:FabPaintLib:FromClipboard
        LOCAL Dib AS FIBitmap
        Local Bmp AS System.Drawing.Bitmap
	    //
	    IF SELF:IsValid
	        //
	        if ( FreeImage.GetImageType( Self:oDibObject ) != FREE_IMAGE_TYPE.FIT_BITMAP )
	            Dib := FreeImage.ConvertToType( Self:oDibObject, FREE_IMAGE_TYPE.FIT_BITMAP, True )
	            Bmp := FreeImage.GetBitmap( Dib )
	            System.Windows.Forms.Clipboard.SetImage( Bmp )
	            FreeImage.Unload( Dib )
	        else
	            Bmp := FreeImage.GetBitmap( Self:oDibObject )
	            System.Windows.Forms.Clipboard.SetImage( Bmp )
	        endif
	        //
	    ENDIF
	    //	
    return


    ACCESS Width AS LONG  
    //r The width in pixel of the image
	    LOCAL nWidth	AS	LONG
	    //
	    IF SELF:IsValid
	        nWidth := FreeImage.GetWidth( SELF:oDibObject )
	    ENDIF
    RETURN nWidth

    END CLASS

    CLASS FabPaintLib Inherit FabPaintLibBase
    
	CONSTRUCTOR( oDib as FIBitmap ) 
        Super( oDib )
	return
	
    CONSTRUCTOR( oDib as FIBitmap, oOwn as Object ) 
        Super( oDib, oOwn )
	return

    CONSTRUCTOR( cFile as String, oOwn as Object  ) 
        Super( cFile, oOwn )
	return

    CONSTRUCTOR( cFile as String  ) 
        Super( cFile, Null )
	return

    CONSTRUCTOR(  ) 
        Super( )
	return

    CONSTRUCTOR( oMultiContainer as FabMultiPage, oOwn as Object ) 
        Super( oMultiContainer, oOwn )
	return

	#region Show Image 
    METHOD Show( hWnd AS PTR) AS VOID  
    //p Show the image in a Window
    //a <hWnd> Handle of the Window
    //d This function will show the image in the desired window
    //j FUNCTION:DIBShow
        LOCAL hDC AS PTR
	    //
	    IF SELF:IsValid
            //
            hDC := GetDC( hWnd )
            // Draw the dib
            SELF:ShowDC( hDC )
            //
            DeleteDC( hDC )
		    //
	    ENDIF
	    //
    return
    
    METHOD Show( hWnd AS PTR, XPos AS LONG, YPos AS LONG ) AS VOID  
    //p Show the image in a Window
    //a <hWnd> Handle of the Window
    //d This function will show the image in the desired window
    //j FUNCTION:DIBShow
        LOCAL hDC AS PTR
	    //
	    IF SELF:IsValid
            //
            hDC := GetDC( hWnd )
            // Draw the dib
            SELF:ShowDC( hDC, XPos, YPos )
            //
            DeleteDC( hDC )
		    //
	    ENDIF
	    //
    return    

    METHOD Show( hWnd AS PTR, XPos AS LONG, YPos AS LONG, Width as long, Height as Long ) AS VOID  
    //p Show the image in a Window
    //a <hWnd> Handle of the Window
    //d This function will show the image in the desired window
    //j FUNCTION:DIBShow
        LOCAL hDC AS PTR
	    //
	    IF SELF:IsValid
            //
            hDC := GetDC( hWnd )
            // Draw the dib
            SELF:ShowDC( hDC, XPos, YPos, Width, Height )
            //
            DeleteDC( hDC )
		    //
	    ENDIF
	    //
    return

    METHOD ShowDC( hDC AS PTR) AS VOID  
    //p Show the image in a Window
    //a <hDC> Handle of the Device Context
    //d This function will show the image in the desired window
    //j FUNCTION:DIBShow
	    //
	    IF SELF:IsValid
	        //
	        //SetStretchBltMode(hDC, COLORONCOLOR)
            //StretchDIBits(hDC, 0, 0, SELF:Width, SELF:Height, ; 
            //                    0, 0, SELF:Width, SELF:Height,;
            //                    Self:BitmapBits, Self:Info, DIB_RGB_COLORS, SRCCOPY )
            SetStretchBltMode(hDC, 3)
            StretchDIBits(hDC, 0, 0, SELF:Width, SELF:Height, ; 
                                0, 0, SELF:Width, SELF:Height,;
                                Self:BitmapBits, Self:Info, DIB_RGB_COLORS, SRCCOPY )
	    ENDIF
	    // 
    return

    METHOD ShowDC( hDC AS PTR, XPos AS LONG, YPos AS LONG ) AS VOID  
    //p Show the image in a Window
    //a <hDC> Handle of the Device Context
    //d This function will show the image in the desired window
    //j FUNCTION:DIBShow
	    //
	    IF SELF:IsValid
	        //
	        //SetStretchBltMode(hDC, COLORONCOLOR)
            //StretchDIBits(hDC, 0, 0, SELF:Width, SELF:Height, ; 
            //                    0, 0, SELF:Width, SELF:Height,;
            //                    Self:BitmapBits, Self:Info, DIB_RGB_COLORS, SRCCOPY )
            SetStretchBltMode(hDC, 3)
            StretchDIBits(hDC, XPos, YPos, XPos + SELF:Width, YPos + SELF:Height, ; 
                                0, 0, SELF:Width, SELF:Height,;
                                Self:BitmapBits, Self:Info, 0, 0x00CC0020 )
	    ENDIF
	    // 
    return

    METHOD ShowDC( hDC AS PTR, XPos AS LONG, YPos AS LONG, Width as long, Height as Long ) AS VOID  
    //p Show the image in a Window
    //a <hDC> Handle of the Device Context
    //d This function will show the image in the desired window
    //j FUNCTION:DIBShow
	    //
	    IF SELF:IsValid
	        //
	        //SetStretchBltMode(hDC, COLORONCOLOR)
            //StretchDIBits(hDC, 0, 0, SELF:Width, SELF:Height, ; 
            //                    0, 0, SELF:Width, SELF:Height,;
            //                    Self:BitmapBits, Self:Info, DIB_RGB_COLORS, SRCCOPY )
            SetStretchBltMode(hDC, 3)
            StretchDIBits(hDC, XPos, YPos, Width, Height, ; 
                                0, 0, SELF:Width, SELF:Height,;
                                Self:BitmapBits, Self:Info, 0, 0x00CC0020 )
	    ENDIF
	    // 
    return
            
    METHOD ShowEx( hWnd AS PTR, XPos AS LONG, YPos AS LONG ) AS VOID  
    //p Show the image in a Window
    //a <hWnd> Handle of the Window
    //a <XPos> <YPos> Upper/Left Coords of the Top/Left point
    //d This function will show the image in the desired window
    //j FUNCTION:DIBShowEx
	    //
	    IF SELF:IsValid
	        SELF:Show( hWnd, XPos, YPos )
	    ENDIF
	    //
    return

    METHOD ShowExDC( hDC AS PTR, XPos AS LONG, YPos AS LONG ) AS VOID  
    //p Show the image in a Window
    //a <hDC> Handle of the Device Context
    //a <XPos>, <YPos> Upper/Left Coords of the Top/Left point
    //d This function will show the image in the desired window
    //j FUNCTION:DIBShowExDC
	    //
	    IF SELF:IsValid
		    SELF:ShowDC( hDC, XPos, YPos )
	    ENDIF
	    //
    return

    METHOD ShowFitToWindow( hWnd AS PTR )  AS VOID  
    //p Show the image in a Window
    //a <hWnd> is the Handle of the Container Window
    //d This function will show the desired DIB object in the desired Window.
    //d If the Width of the DIB is bigger than the Width of the window,
    //d or the Height of the DIB if bigger than the Height of the window,
    //d the DIB is resized to fit into the Window.
    	LOCAL pRect		IS _winRECT
	    LOCAL Factor	AS	REAL8
	    LOCAL rx, ry	AS	REAL8
	    LOCAL pBMI		AS	_winBITMAPINFO
	    LOCAL Width, Height	AS	LONG
	    LOCAL hDC       AS  PTR
		//
	    IF SELF:IsValid
	        //
	        GetClientRect( hWnd, @pRect )
	        Width := pRect:Right - pRect:Left + 1
	        Height := pRect:Bottom - pRect:Top + 1
	        //
	        pBMI := SELF:Info
	        //
	        Factor := 1
	        //
	        IF ( pBMI:bmiHeader:biWidth > Width ) .OR. ( pBMI:bmiHeader:biHeight > Height )
		        // doesn't fit, need to scale
		        rx := REAL8( pBMI:bmiHeader:biWidth ) / REAL8( Width )
		        ry := REAL8(  pBMI:bmiHeader:biHeight ) / REAL8( Height )
		        Factor := 1.0 / Max( rx, ry )
	        ENDIF
	        //
	        Width := LONG( Factor * pBMI:bmiHeader:biWidth )
	        Height := LONG( Factor * pBMI:bmiHeader:biHeight )
	        //
	        hDC := GetDC( hWnd )
	        SELF:ShowDC( hDC, 0, 0, Width, Height )
	        DeleteDC( hDC )
	        //	        
	    ENDIF
	    //
    return

    METHOD ShowFitToWindowInDC( hWnd AS PTR, hDC AS PTR )  AS VOID  
    //p Show the image in a Window
    //a <hWnd> is the Handle of the Container Window
    //d This function will show the desired DIB object in the desired Window.
    //d If the Width of the DIB is bigger than the Width of the window,
    //d or the Height of the DIB if bigger than the Height of the window,
    //d the DIB is resized to fit into the Window.
    	LOCAL pRect		IS _winRECT
	    LOCAL Factor	AS	REAL8
	    LOCAL rx, ry	AS	REAL8
	    LOCAL pBMI		AS	_winBITMAPINFO
	    LOCAL Width, Height	AS	LONG
		//
	    IF SELF:IsValid
	        //
	        GetClientRect( hWnd, @pRect )
	        Width := pRect:Right - pRect:Left + 1
	        Height := pRect:Bottom - pRect:Top + 1
	        //
	        pBMI := SELF:Info
	        //
	        Factor := 1
	        //
	        IF ( pBMI:bmiHeader:biWidth > Width ) .OR. ( pBMI:bmiHeader:biHeight > Height )
		        // doesn't fit, need to scale
		        rx := REAL8( pBMI:bmiHeader:biWidth ) / REAL8( Width )
		        ry := REAL8(  pBMI:bmiHeader:biHeight ) / REAL8( Height )
		        Factor := 1.0 / Max( rx, ry )
	        ENDIF
	        //
	        Width := LONG( Factor * pBMI:bmiHeader:biWidth )
	        Height := LONG( Factor * pBMI:bmiHeader:biHeight )
	        //
	        SELF:ShowDC( hDC, 0, 0, Width, Height )
	        //	        
	    ENDIF
	    //
    return

    METHOD Stretch( hWnd AS PTR, nWidth AS DWORD, nHeight AS DWORD, r8Factor AS REAL8) AS VOID  
    //p Stretch the image in a Window with Zoom
    //a <hWnd> Handle of the Window
    //a <nWidth> Width of the area for displaying the DIB.
    //a <nHeight> Height of the area for displaying the DIB.
    //a <r8Factor> The zoom factor of the bitmap.  A value of 1.0 would be its normal size.
    //d This function will stretch the image using the specified factor
    //j FUNCTION:DIBStretch
        LOCAL w as long
        local h as long
	    //
	    IF SELF:IsValid
	        //
	        w := long( nWidth * r8Factor )
	        h := long( nHEight * r8Factor )
	        SELF:ShowEx(  hWnd, w, h )
	    ENDIF
	    //
    return

    METHOD StretchDC( hDC AS PTR, nCx AS DWORD, nCy AS DWORD, r8Factor AS REAL8) AS VOID  
    //p Stretch the image in a Window with Zoom
    //a <hDC> Handle of the Device Context
    //a <nCx> Width of the area for displaying the DIB.
    //a <nCy> Height of the area for displaying the DIB.
    //a <r8Factor> The zoom factor of the bitmap.  A value of 1.0 would be its normal size.
    //d This function will stretch the image using the specified factor
    //j FUNCTION:DIBStretch
        LOCAL w as long
        local h as long
	    //
	    IF SELF:IsValid
	        //
	        w := long( nCx * r8Factor )
	        h := long( nCy * r8Factor )
	        SELF:ShowExDC(  hDC, w, h )
	    ENDIF
	    //
    return

    METHOD StretchDraw( hWnd AS PTR, x AS LONG, y AS LONG, w AS LONG, h AS LONG ) AS VOID  
    //p Stretch the image in a Window
    //a <hWnd> Window handle.
    //a <x> X Pos of the image in the window.
    //a <y> Y Pos of the image in the window.
    //a <w> Width of the area for displaying the DIB.
    //a <h> Height of the area for displaying the DIB.
    //j FUNCTION:DIBStretchDraw
	    //
	    IF SELF:IsValid
	        SELF:Show( hWnd, x, y, x+w, y+h )
	    ENDIF
	    //
    return

    METHOD StretchDrawDC( hDC AS PTR, x AS LONG, y AS LONG, w AS LONG, h AS LONG ) AS VOID  
    //p Stretch the image in a Window
    //a <hDC> Handle of the Device Context
    //a <x> X Pos of the image in the window.
    //a <y> Y Pos of the image in the window.
    //a <w> Width of the area for displaying the DIB.
    //a <h> Height of the area for displaying the DIB.
    //j FUNCTION:DIBStretchDrawDC
	    //
	    IF SELF:IsValid
	        SELF:ShowDC( hDC, x, y, x+w, y+h )
	    ENDIF
	    //
    return

    METHOD StretchEx( hWnd AS PTR, pRectDest AS _WINRect, pRectSrc AS _WINRect ) AS VOID  
    //p Stretch the image in a Window
    //a <hWnd> Window handle.
    //a <pRectDest> Destination Rectangle in the specified Window.
    //a  If NULL_PTR, the pRectSrc rectangle is used.
    //a <pRectSrc> Rectangle part of the image to draw into the destination rectangle.
    //a  If NULL_PTR, the actual Width and Height of the image are used.
    //d DIBStretchEx() copies a DIB into a destination rectangle, stretching or compressing the bitmap
    //d to fit the dimensions of the specified window, <hWnd>.
    //j FUNCTION:DIBStretchEx
        LOCAL hDC AS PTR
	    //
	    IF SELF:IsValid
	    	hDC := GetDC( hWnd )
	        SELF:StretchExDC( hDC, pRectDest, pRectSrc )
	        DeleteDC( hDC )
	    ENDIF
	    //
    return

    METHOD StretchExDC( hDC AS PTR, pRectDest AS _WINRect, pRectSrc AS _WINRect ) AS VOID  
    //p Stretch the image in a Window
    //a <hDC> Handle of Device Context
    //a <pRectDest> Destination Rectangle in the specified Window.
    //a  If NULL_PTR, the pRectSrc rectangle is used.
    //a <pRectSrc> Rectangle part of the image to draw into the destination rectangle.
    //a  If NULL_PTR, the actual Width and Height of the image are used.
    //d DIBStretchEx() copies a DIB into a destination rectangle, stretching or compressing the bitmap
    //d to fit the dimensions of the specified window, <hWnd>.
    //j FUNCTION:DIBStretchExDC
	    //
	    IF SELF:IsValid
	        //
            SetStretchBltMode(hDC, 3)
            StretchDIBits(hDC, pRectDest:left, pRectDest:top, pRectDest:right-pRectDest:left, pRectDest:bottom-pRectDest:top, ; 
                               pRectSrc:left, pRectSrc:top, pRectSrc:right-pRectSrc:left, pRectSrc:bottom-pRectSrc:top,;
                                Self:BitmapBits, Self:Info, DIB_RGB_COLORS, SRCCOPY )
            //	    
	    ENDIF
	    //
    return

    METHOD StretchExDrawDCBackground( hDC as ptr, prcDest as _WINRect, prcSrc as _WINRect, ;
   										    lUseFile as Logic, pRGB as _winRGBQUAD, oBackgroundImage as FabPaintLib ;
										     ) as void  
    //p Stretch the image in a Window using transparency
    //a <hDC> Handle of the Device Context
    //a <x> X Pos of the image in the window.
    //a <y> Y Pos of the image in the window.
    //a <w> Width of the area for displaying the DIB.
    //a <h> Height of the area for displaying the DIB.
    //a <lUseFile> use file as background ?
    //a <pRGB> is a _WinRGBQUAD struct with background color
    //a <oBackgroundImage> is a FabPaintLib object to use as background
    //j FUNCTION:DIBStretchDrawDC
        // TODO Strech With Background
/*	    local pDIB as ptr*/
        LOCAL lHasBackground    as Logic
        Local lIsTransparent    as logic
        Local image_type        as FREE_IMAGE_TYPE
        Local oDisplayDib       as FIBitmap
        Local bg                as FIBitmap
        Local dib_double        as FIBitmap
        Local dib32             as FIBitmap
	    LOCAL pClr              AS FreeImageAPI.RGBQUAD
	    Local bDeleteMe         as  logic
	    Local rcDest            is _WINRect
	    Local rcSrc             is _WINRect
	    //
	    If ( pRGB != Null )
	        pClr := FreeImageAPI.RGBQUAD{}
	        pClr:rgbBlue := pRGB:rgbBlue
    	    pClr:rgbRed := pRGB:rgbRed
	        pClr:rgbGreen := pRGB:rgbGreen
	    EndIf
	    //
	    IF self:IsValid
		    if ( oBackgroundImage != null_object )
			    bg := oBackgroundImage:oDibObject
		    endif
		    image_type := FreeImage.GetImageType( SELF:oDibObject )
		    //
		    if ( image_type == FREE_IMAGE_TYPE.FIT_BITMAP )
		        lHasBackground := SELF:HasBackgroundColor
		        lIsTransparent := Self:IsTransparent
		        //
		        if( !lIsTransparent .AND. ( !lHasBackground .OR. !lUseFile ) )
		            // Use the current FIBitmap
		            oDisplayDib := Self:oDibObject
		        else
		            // Create the transparent / alpha blended image
		            oDisplayDib := FreeImage.Composite( Self:oDibObject, lUseFile, pClr, bg )
		            if ( oDisplayDib != FIBITMAP.Zero )
		                bDeleteMe := True
		            else
		                oDisplayDib := Self:oDibObject
		            endif
		        endif
		    else
		        // Convert to a standard dib for display
		        if ( image_type == FREE_IMAGE_TYPE.FIT_COMPLEX)
				    // Convert to type FIT_DOUBLE
				    dib_double := FreeImage.GetComplexChannel( Self:oDibObject, FREE_IMAGE_COLOR_CHANNEL.FICC_MAG)
				    // Convert to a standard bitmap (linear scaling)
				    oDisplayDib := FreeImage.ConvertToStandardType( dib_double, TRUE)
				    // Free image of type FIT_DOUBLE
				    FreeImage.Unload(dib_double)
				elseif ( (image_type == FREE_IMAGE_TYPE.FIT_RGBF) .OR. ( image_type == FREE_IMAGE_TYPE.FIT_RGB16) ) 
				    // Apply a tone mapping algorithm and convert to 24-bit 
				    // default tone mapping operator
				    oDisplayDib := FreeImage.ToneMapping( Self:oDibObject, FreeImageAPI.FREE_IMAGE_TMO.FITMO_DRAGO03, 0, 0 )
				elseif ( image_type == FREE_IMAGE_TYPE.FIT_RGBA16)
				    // Convert to 32-bit
				    dib32 := FreeImage.ConvertTo32Bits( self:oDibObject )
				    if ( dib32 != FIBITMAP.Zero )
					    // Create the transparent / alpha blended image
					    oDisplayDib := FreeImage.Composite( dib32, lUseFile, pClr, bg )
					    FreeImage.Unload(dib32)
				    endif
				else
				    // Other cases: convert to a standard bitmap (linear scaling)
				    oDisplayDib := FreeImage.ConvertToStandardType( Self:oDibObject, TRUE)
				endif
			    // Remember to delete oDisplayDib
			    bDeleteMe := TRUE
		    endif
	        //
	        if ( prcDest == NULL )
		        SetRect( @rcDest, 0, 0, FreeImage.GetWidth(oDisplayDib), FreeImage.GetHeight(oDisplayDib) )
	        else
		        SetRect( @rcDest, prcDest:left, prcDest:top, prcDest:right, prcDest:bottom )
		    endif
	        //
	        if ( prcSrc == NULL )
		        SetRect( @rcSrc, 0, 0, FreeImage.GetWidth(oDisplayDib), FreeImage.GetHeight(oDisplayDib) )
	        else
		        SetRect( @rcSrc, prcSrc:left, prcSrc:top, prcSrc:right, prcSrc:bottom )
	        endif
	        // Draw the dib
	        SetStretchBltMode(hDC, COLORONCOLOR)
	        StretchDIBits(hDC,  rcDest:left, rcDest:top, rcDest:right-rcDest:left, rcDest:bottom-rcDest:top, ;
		        rcSrc:left, rcSrc:top, rcSrc:right-rcSrc:left, rcSrc:bottom - rcSrc:top,;
		        FreeImage.GetBits(oDisplayDib), FreeImage.GetInfo(oDisplayDib), DIB_RGB_COLORS, SRCCOPY)
		    //
		    if ( bDeleteMe )
		        FreeImage.Unload(oDisplayDib)
		    endif
		endif
		
/*
	//
	RECT rcSrc;
	RECT rcDest;

	// Convert to a standard bitmap if needed
	if(_bHasChanged) {
		if(_bDeleteMe) {
			FreeImage_Unload(_display_dib);
			_display_dib = NULL;
			_bDeleteMe = FALSE;
		}

		FREE_IMAGE_TYPE image_type = getImageType();
		if(image_type == FIT_BITMAP) {
			BOOL bHasBackground = FreeImage_HasBackgroundColor(_dib);
			BOOL bIsTransparent = FreeImage_IsTransparent(_dib);

			if(!bIsTransparent && (!bHasBackground || !useFileBkg)) {
				// Copy pointer
				_display_dib = _dib;
			}
			else {
				// Create the transparent / alpha blended image
				_display_dib = FreeImage_Composite(_dib, useFileBkg, appBkColor, bg);
				if(_display_dib) {
					// Remember to delete _display_dib
					_bDeleteMe = TRUE;
				} else {
					// Something failed: copy pointers
					_display_dib = _dib;
				}
			}
		} else {
			// Convert to a standard dib for display

			if(image_type == FIT_COMPLEX) {
				// Convert to type FIT_DOUBLE
				FIBITMAP *dib_double = FreeImage_GetComplexChannel(_dib, FICC_MAG);
				// Convert to a standard bitmap (linear scaling)
				_display_dib = FreeImage_ConvertToStandardType(dib_double, TRUE);
				// Free image of type FIT_DOUBLE
				FreeImage_Unload(dib_double);
			} else if((image_type == FIT_RGBF) || (image_type == FIT_RGB16)) {
				// Apply a tone mapping algorithm and convert to 24-bit 
				_display_dib = FreeImage_ToneMapping(_dib, _tmo, _tmo_param_1, _tmo_param_2);
			} else if(image_type == FIT_RGBA16) {
				// Convert to 32-bit
				FIBITMAP *dib32 = FreeImage_ConvertTo32Bits(_dib);
				if(dib32) {
					// Create the transparent / alpha blended image
					_display_dib = FreeImage_Composite(dib32, useFileBkg, appBkColor, bg);
					FreeImage_Unload(dib32);
				}
			} else {
				// Other cases: convert to a standard bitmap (linear scaling)
				_display_dib = FreeImage_ConvertToStandardType(_dib, TRUE);
			}
			// Remember to delete _display_dib
			_bDeleteMe = TRUE;
		}

		_bHasChanged = FALSE;
	}
	//
	if ( prcDest == NULL )
	{
		SetRect( &rcDest, 0, 0, FreeImage_GetWidth(_display_dib), FreeImage_GetHeight(_display_dib) );
	}
	else
	{
		SetRect( &rcDest, prcDest->left, prcDest->top, prcDest->right, prcDest->bottom );
	}
	//
	if ( prcSrc == NULL )
	{
		SetRect( &rcSrc, 0, 0, FreeImage_GetWidth(_display_dib), FreeImage_GetHeight(_display_dib) );
	}
	else
	{
		SetRect( &rcSrc, prcSrc->left, prcSrc->top, prcSrc->right, prcSrc->bottom );
	}
	// Draw the dib
	SetStretchBltMode(hDC, COLORONCOLOR);	
	StretchDIBits(hDC,  rcDest.left, rcDest.top, rcDest.right-rcDest.left, rcDest.bottom-rcDest.top, 
		rcSrc.left, rcSrc.top, rcSrc.right-rcSrc.left, rcSrc.bottom - rcSrc.top,
		FreeImage_GetBits(_display_dib), FreeImage_GetInfo(_display_dib), DIB_RGB_COLORS, SRCCOPY);

*/		    
		    
		   // DIBStretchExDrawDCBackground( self:pDibObject, hDC, pRectDest, pRectSrc, lUSeFile, pRGB, pDIB )
	       //
    return
    
    ACCESS UseGDI AS LOGIC  
    //r A logical value indicating if FabPaint uses VFW functions or GDI functions to draw
	    //LOCAL lSet	AS	LOGIC
	    //
	    IF SELF:IsValid
	        // Nothing Todo here
		    //lSet := DIBGetUseGDI( SELF:pDibObject )
	    ENDIF
    RETURN True

    ASSIGN UseGDI( lUseGDI AS LOGIC )   
    //r A logical value indicating if FabPaint uses VFW functions or GDI functions to draw
	    //LOCAL lSet	AS	LOGIC
	    //
	    IF SELF:IsValid
	        // Nothing Todo here
		    //lSet := DIBSetUseGDI( SELF:pDibObject, lUseGDI )
		    // Not a change in the Image but on the way to draw, may need to redraw
		    SELF:__NotifyOwner( #UseGDI )
		    //
	    ENDIF
    RETURN 
    
    #endregion Show Image

    END CLASS

End Namespace 
