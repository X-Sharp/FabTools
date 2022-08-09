USING FreeImageAPI
USING FreeImageAPI.Metadata
USING System.IO
USING System.Windows.Forms
USING VOWin32APILibrary
USING System.Runtime.InteropServices


#define SRCCOPY                     0x00CC0020U 
#define DIB_RGB_COLORS              0
#define COLORONCOLOR                3

BEGIN NAMESPACE FabPaintLib

	CLASS FabPaintLibBase
		// Internal FreeImageBitmap
		PROTECTED INTERNAL oDibObject  AS  FIBitmap
		
		//	PROTECT pDibObject	AS	PTR
		//	EXPORT pDibObject					as	ptr
		
		// Owner to notify any changes
		// Object
		PROTECT oOwner						AS	OBJECT
		// Please, don't notify my owner...
		PROTECT lSuspendNotification	AS	LOGIC
		// a MultiPage Object that owns the Image
		PROTECT oContainer 				AS FabMultiPage
		//
		PROTECT nExifModel				AS	FREE_IMAGE_MDMODEL
		// Default FileFormat when retrieving the image as a string
		PROTECT cAsStringFileFormat 	AS STRING
		
		// Direct Import of that function
		// The Wrapper is using Generics to call it in a way Vulcan doesn't like
		[DllImport( "FreeImage.dll" )] ; 
		STATIC METHOD FreeImage_Rotate( dib AS FIBITMAP, angle AS double, backgroundColor AS IntPtr ) AS FIBitmap
			
		
		INTERNAL METHOD GetDib() AS FIBitmap
			RETURN SELF:oDibObject
		
		METHOD __NotifyOwner( symEvent AS SYMBOL ) AS VOID  
			//
			IF ( SELF:oOwner != NULL_OBJECT )
				IF IsMethod( SELF:oOwner, #OnFabPaintLib ) .AND. !SELF:lSuspendNotification
					Send( SELF:oOwner, #OnFabPaintLib, SELF, symEvent )
				ENDIF
			ENDIF
			//
			RETURN
			
		ACCESS AsString AS STRING  
			//r The Bitmap as a list of bytes, to be stored for eg. in a blob
			LOCAL cFileContent AS STRING
			LOCAL nFif 			AS FREE_IMAGE_FORMAT
			LOCAL sr            AS StreamReader   
			LOCAL Memory        AS MemoryStream        	
			//
			IF SELF:IsValid
				//
				DO CASE    
					CASE ( SELF:cAsStringFileFormat == "BMP" )
						nFif := FREE_IMAGE_FORMAT.FIF_BMP
					CASE ( SELF:cAsStringFileFormat == "ICO" )
						nFif := FREE_IMAGE_FORMAT.FIF_ICO
					CASE ( SELF:cAsStringFileFormat == "JPG" )
						nFif := FREE_IMAGE_FORMAT.FIF_JPEG 
					CASE ( SELF:cAsStringFileFormat == "JPEG" )
						nFif := FREE_IMAGE_FORMAT.FIF_JPEG  
					CASE ( SELF:cAsStringFileFormat == "PCX" )
						nFif := FREE_IMAGE_FORMAT.FIF_PCX 
					CASE ( SELF:cAsStringFileFormat == "PNG" )
						nFif := FREE_IMAGE_FORMAT.FIF_PNG
					CASE ( SELF:cAsStringFileFormat == "TIF" )
						nFif := FREE_IMAGE_FORMAT.FIF_TIFF 
					CASE ( SELF:cAsStringFileFormat == "TIFF" )
						nFif := FREE_IMAGE_FORMAT.FIF_TIFF 
					CASE ( SELF:cAsStringFileFormat == "GIF" )
						nFif := FREE_IMAGE_FORMAT.FIF_GIF
					CASE ( SELF:cAsStringFileFormat == "J2K" )
						nFif := FREE_IMAGE_FORMAT.FIF_J2K
					CASE ( SELF:cAsStringFileFormat == "JP2" )
						nFif := FREE_IMAGE_FORMAT.FIF_J2K		
				ENDCASE
				//
				// Now Create the Memory Stream
				Memory := MemoryStream{}
				// Save the Image to the Memory Stream
				FreeImage.SaveToStream( SELF:oDibObject, Memory, nFif )
				// Now Retrieve the buffer where the memory is stored
				sr := StreamReader{ Memory }
				// Now, convert to a string
				cFileContent := sr:ReadToEnd()
			ENDIF
			RETURN cFileContent
			
		ASSIGN AsString( cFileContent AS STRING )   
			//r The Bitmap as a list of bytes, to be stored for eg. in a blob
			LOCAL Memory AS MemoryStream
			LOCAL sw AS StreamWriter
			//
			Memory := MemoryStream{}
			sw := StreamWriter{ Memory }
			//
			sw:Write( cFileContent )
			sw:Flush()
			//
			SELF:CreateFromStream( Memory )
			RETURN 
			
		ACCESS AsStringFileFormat AS STRING  
			//r The FileFormat to be used when using the Access AsString
			RETURN SELF:cAsStringFileFormat
			
		ASSIGN AsStringFileFormat( cFif AS STRING )   
			//r The FileFormat to be used when using the Access AsString
			SELF:cAsStringFileFormat := Upper(cFif)
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
		
		ACCESS BitmapBits AS PTR  
			// 
			LOCAL pBits AS PTR
			//
			IF SELF:IsValid
				pBits := FreeImage.GetBits( SELF:oDibObject )
			ENDIF              
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
			
		METHOD ChangeContrast( percentage AS double, bOffset AS BYTE ) AS VOID  
			// For Compatibility
			SELF:ChangeContrast( percentage )
			
		METHOD ChangeContrast( percentage AS double ) AS VOID  
			//
			IF SELF:IsValid
				FreeImage.AdjustContrast( SELF:oDibObject, percentage )
				//
				SELF:__NotifyOwner( #Contrast )
				//
			ENDIF
			//
			RETURN 
			
		METHOD ChangeIntensity( gamma AS double, bOffset AS BYTE, rExponent AS REAL8 ) AS VOID  
			// For Compatibility
			SELF:ChangeIntensity( gamma )
			
		METHOD ChangeIntensity( gamma AS double ) AS VOID  
			//
			IF SELF:IsValid
				FreeImage.AdjustGamma( SELF:oDibObject, gamma )
				//
				SELF:__NotifyOwner( #Intensity )
				//
			ENDIF
			//
			RETURN
			
		METHOD ChangeLightness( percentage AS double ) AS VOID  
			//
			IF SELF:IsValid
				FreeImage.AdjustBrightness( SELF:oDibObject, percentage ) 
				//
				SELF:__NotifyOwner( #Lightness )
				//
			ENDIF
			//   
			RETURN
			
		METHOD Composite( lUseFile AS LOGIC, pRGB AS FreeImageAPI.RGBQUAD[ ], oBackgroundImage AS FabPaintLibBase ) AS VOID  
			//a <lUseFile> use file as background ?
			//a <pRGB> is a _WinRGBQUAD struct with background color
			//a <oBackgroundImage> is a FabPaintLib object to use as background
			//j FUNCTION:DIBStretchDrawDC
			LOCAL oComposed AS FIBitmap
			LOCAL oDIB AS FIBitmap
			//
			IF SELF:IsValid
				//
				IF ( oBackgroundImage != NULL_OBJECT )
					oDIB := oBackgroundImage:oDibObject
				ENDIF
				oComposed := FreeImage.Composite( SELF:oDibObject, lUseFile, pRGB, oDib )
				//
				SELF:CreateFrom( oComposed )
			ENDIF
			//
			RETURN
			
		METHOD Copy( bpp := 0 AS LONG ) AS FabPaintLib  
			//p Create a Copy of the object
			//a <bpp> Number of Bit Per Pixel to use in the copy
			//a Values can be 1,8,32.
			//a 0,per default, means no change.
			//r The new FabPaintLib object
			LOCAL oNew	AS	FabPaintLib
			LOCAL oDib  AS FIBitmap
			LOCAL fibpp AS FreeImageAPI.FREE_IMAGE_COLOR_DEPTH
			//
			IF SELF:IsValid
				//
				DO CASE
					CASE bpp==1
						fibpp := FreeImageAPI.FREE_IMAGE_COLOR_DEPTH.FICD_01_BPP
					CASE bpp=8
						fibpp := FreeImageAPI.FREE_IMAGE_COLOR_DEPTH.FICD_08_BPP
					CASE bpp=32
						fibpp := FreeImageAPI.FREE_IMAGE_COLOR_DEPTH.FICD_32_BPP
				ENDCASE
				IF ( bpp == 0)
					oDib := FreeImage.Clone( SELF:oDibObject )
				ELSE
					//
					oDib := FreeImage.ConvertColorDepth( SELF:oDibObject, fibpp, FALSE )
				ENDIF
				//
				oNew := FabPaintLib{ oDib, NULL }
			ENDIF
			//
			RETURN oNew
			
		METHOD Create( nWidth:=16 AS LONG, nHeight := 16 AS LONG, nBpp := 8 AS WORD, lAlpha := FALSE  AS LOGIC ) AS LOGIC  
			//p Initialize an empty DIB Object
			//r A logical value indicating the success of the operation
			//
			SELF:Destroy()
			SELF:oDibObject := FreeImage.Allocate( nWidth, nHeight, nBpp, FreeImage.FI_RGBA_RED_MASK, FreeImage.FI_RGBA_GREEN_MASK, FreeImage.FI_RGBA_BLUE_MASK)
			//
			SELF:__NotifyOwner( #Create )
			//
			RETURN SELF:IsValid
			
		METHOD CreateFromStream( Stream AS System.IO.Stream ) AS LOGIC
			//
			SELF:_CreateFromStream( Stream )
			//
			SELF:__NotifyOwner( #CreateFromFile )
			//
			RETURN SELF:IsValid
			
		PROTECT METHOD _CreateFromStream( Stream AS System.IO.Stream ) AS LOGIC
			SELF:Destroy()
			//
			SELF:oDibObject := FreeImage.LoadFromStream( Stream )
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
				SELF:Destroy()
				cFile := Lower(Trim(cFile))
				SELF:oDibObject := FreeImage.LoadEx( cFile )
				//
				SELF:__NotifyOwner( #CreateFromFile )
			ENDIF
			//
			RETURN SELF:IsValid
			
		METHOD CreateFromHBitmap( hBitmap AS PTR ) AS LOGIC  
			//p Initialize from bitmap Handle
			//a <hBitmap>	Handle of the Bitmap to use to Initialize the object
			//d This function copy the pixels in hBitmap to a DIB object
			//r A logical value indicating the success of the operation
			//
			SELF:Destroy()
			SELF:oDibObject := FreeImage.CreateFromHbitmap(hbitmap, IntPtr.Zero);
			//
			SELF:__NotifyOwner( #CreateFromHBitmap )
			//
			RETURN SELF:IsValid
			
		METHOD CreateFromHDib( hDib AS PTR ) AS LOGIC  
			//p Initialize from Device Independent Bitmap memory
			//a <hDIB>	Handle of the DIB to use to Initialize the object
			//d This function copy the pixels in hDIB to a DIB object
			//r A logical value indicating the success of the operation
			// Support for HDib
			LOCAL pBFH IS _WINBITMAPFILEHEADER
			LOCAL pBIH AS _WINBITMAPINFOHEADER
			local Memory as System.IO.MemoryStream
			LOCAL tempArray AS BYTE[]
			//
			pBIH := GlobalLock( hDIB )
			TRY
				//
				pBFH:bfType := 0x4D42 // BM
				//
				LOCAL nSize := GlobalSize(hDIB ) AS DWORD
				nSize := nSize + SizeOf( _WINBITMAPFILEHEADER )
				tempArray := BYTE[]{  (int)nSize }
				Marshal.Copy( @pBFH, tempArray, 0, SizeOf( _WINBITMAPFILEHEADER ) )
				Marshal.Copy( (IntPtr)pBIH, tempArray, SizeOf( _WINBITMAPFILEHEADER ), (int)GlobalSize( hDIB ) )
				//
				Memory := System.IO.MemoryStream{ tempArray }
				Self:_CreateFromStream( Memory )
			CATCH ex AS Exception
				System.Diagnostics.Debug.Write(ex:Message)
			FINALLY
				GlobalUnlock( hDIB )
				IF ( Memory != NULL )
					Memory:Dispose()
				ENDIF
			END TRY
			//
			SELF:__NotifyOwner( #CreateFromHDib )
			//
			RETURN SELF:IsValid
			
			
		METHOD CreateFromPtr( pbImage AS BYTE PTR, nSize AS DWORD ) AS LOGIC  
			//p Initialize from memory block
			//a <pbImage>	Pointer to the memory block
			//a <nSIze>		Size of the memory block
			//d This function will read the indicated memory as if it was a file, and then
			//d init the object. So you can copy a file to memory, with a ProgressBar, and then use this method.
			//r A logical value indicating the success of the operation
			// 
			LOCAL tempArray := BYTE[]{(int)nSize} AS BYTE[]
			Marshal.Copy( pbImage, tempArray, 0, (int)nSize )
			//
			local Memory as System.IO.MemoryStream
			Memory := System.IO.MemoryStream{ tempArray }
			//
			Self:CreateFromStream( Memory )
			Memory:Dispose()
			//
			RETURN SELF:IsValid
			
		METHOD CreateFromResourceID( hInst AS PTR, nID AS DWORD ) AS LOGIC  
			//p Initialize from bitmap resource ID
			//a <hInst> Handle to the resource module handle
			//a  This can be _GetInst() for the current Exe, or and result of LoadLibrary()
			//a <nID> ID Number of the resource to use.
			//d This function copy the pixels in the resource to a DIB object
			//r A logical value indicating the success of the operation
			LOCAL hRes AS IntPtr
			//
			SELF:Destroy()
			//
			hRes := LoadBitmap( hInst, (IntPtr)nID )
			//
			SELF:CreateFromHBitmap( hRes )
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
			LOCAL hRes AS IntPtr
			
			//
			SELF:Destroy()
			//
			hRes := LoadBitmap( IntPtr.Zero , String2Psz(cResName) )
			//
			SELF:CreateFromHBitmap( hRes )
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
			LOCAL MemoryImage AS System.Drawing.Bitmap
			LOCAL memoryGraphics AS System.Drawing.Graphics
			LOCAL whSize  AS System.Drawing.Size
			//
			whSize := System.Drawing.Size{ nRight - nLeft, nBottom - nTop }
			//
			memoryImage := System.Drawing.Bitmap{ whSize:Width, whSize:Height, System.Drawing.Imaging.PixelFormat.Format32bppArgb }
			memoryGraphics := System.Drawing.Graphics.FromImage( memoryImage )
			memoryGraphics:CopyFromScreen( nLeft, nTop, 0, 0, whSize, System.Drawing.CopyPixelOperation.SourceCopy )
			//
			SELF:Destroy()
			//
			SELF:oDibObject := FreeImage.CreateFromBitmap( memoryImage )
			//
			SELF:__NotifyOwner( #CreateFromScreen )
			RETURN SELF:IsValid	
			
		PROTECTED METHOD CreateFrom( oNew AS FIBitmap ) AS LOGIC  
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
			LOCAL oNew AS FIBitmap
			//
			IF SELF:IsValid
				oNew := FreeImage.Copy( SELF:oDibObject, XMin, XMax, YMin, YMax)
				SELF:CreateFrom( oNew )
				//
				SELF:__NotifyOwner( #Crop )
				//
			ENDIF
			//
			RETURN
			
		METHOD Destroy() AS VOID  
			//p Delete the underlying DIB Object
			//
			IF SELF:IsValid 
				//
				IF ( SELF:oContainer != NULL_OBJECT )
					SELF:oContainer:UnlockPage( SELF, FALSE )
					SELF:oContainer := NULL_OBJECT
				ENDIF			 
				//
				FreeImage.Unload( SELF:oDibObject )
				SELF:oDibObject:SetNull()
				//
				SELF:__NotifyOwner( #Destroy )
				//
			ENDIF
			//
			RETURN
			
		METHOD EXIFGetTag( cTagName AS STRING ) AS STRING  
			//LOCAL pBuffer	AS PTR
			//LOCAL liSize	AS LONG
			LOCAL cTagValue	AS STRING
			//local cName     as String
			LOCAL oTag      AS MetadataTag
			LOCAL nModel    AS FREE_IMAGE_MDMODEL
			//
			cTagValue := ""
			IF SELF:IsValid
				IF ( SELF:EXIFTagCount > 0 )
					IF ( SELF:EXIFModel == FREE_IMAGE_MDMODEL.FIMD_NODATA )	
						////////////////////
						// 
						//			        	        
						IF ( cTagName:IndexOf( "Sub." ) == 0 )
							// Ok, it starts with "Sub."
							nModel := FREE_IMAGE_MDMODEL.FIMD_EXIF_EXIF
							cTagName := cTagName:Substring( 4 )
						ELSEIF ( cTagName:IndexOf( "Main." ) == 0 )
							// Ok, it starts with "Main."
							nModel := FREE_IMAGE_MDMODEL.FIMD_EXIF_MAIN
							cTagName := cTagName:Substring(5)
						ELSE
							// None of thme, try with TagName directly    
							nModel := FREE_IMAGE_MDMODEL.FIMD_EXIF_MAIN
						ENDIF
					ELSE
						nModel := SELF:EXIFModel
					ENDIF
					IF ( FreeImage.GetMetaData( nModel, SELF:oDibObject, cTagName, REF oTag ) )
						cTagValue := oTag:ToString()
					ENDIF			
				ENDIF
			ENDIF
			RETURN cTagValue
			
		METHOD EXIFGetTagDescription( dwPos AS DWORD ) AS STRING  
			/*	    LOCAL pBuffer	AS PTR
		LOCAL liSize	AS LONG*/
		LOCAL cTagDesc  AS STRING
		LOCAL nTotalMain AS DWORD
		//LOCAL nTotalSub  AS LONG
		LOCAL nModel     AS FREE_IMAGE_MDMODEL
		LOCAL oTag      AS MetadataTag
		LOCAL lFind     AS LOGIC
		LOCAL Count     AS LONG
		LOCAL hFind     AS FIMETADATA
		//
		IF SELF:IsValid
			IF ( SELF:EXIFTagCount > 0 )
				IF ( SELF:EXIFModel == FREE_IMAGE_MDMODEL.FIMD_NODATA )
					//
					nTotalMain := FreeImage.GetMetadataCount( FREE_IMAGE_MDMODEL.FIMD_EXIF_MAIN, SELF:oDibObject )
					//nTotalSub  := FreeImage.GetMetadataCount( FREE_IMAGE_MDMODEL.FIMD_EXIF_EXIF, SELF:oDibObject )
					//
					IF ( dwPos < nTotalMain )
						nModel := FREE_IMAGE_MDMODEL.FIMD_EXIF_MAIN 
					ELSE
						dwPos := dwPos - nTotalMain
						nModel := FREE_IMAGE_MDMODEL.FIMD_EXIF_EXIF
					ENDIF			
				ELSE
					nModel := SELF:EXIFModel
				ENDIF
				//
				lFind := FALSE
				Count := 0
				hFind := FreeImage.FindFirstMetadata( nModel, SELF:oDibObject, REF oTag )
				//
				IF ( ! hFind:IsNull )
					REPEAT
						IF ( Count == dwPos )
							lFind := TRUE
							EXIT
						ENDIF
						// Tag Count
						Count ++
					UNTIL ( ! FreeImage.FindNextMetadata( hFind, REF oTag ) )
					//
					IF lFind
						cTagDesc := oTag:Description
					ENDIF
				ENDIF
			ENDIF
		ENDIF
		RETURN cTagDesc
		
		METHOD EXIFGetTagShortName( dwPos AS DWORD ) AS STRING  
			/*	    LOCAL pBuffer	AS PTR
			LOCAL liSize	AS LONG*/
			LOCAL cTagKey  AS STRING
			LOCAL nTotalMain AS DWORD
			//LOCAL nTotalSub  AS LONG
			LOCAL nModel     AS FREE_IMAGE_MDMODEL
			LOCAL oTag      AS MetadataTag
			LOCAL lFind     AS LOGIC
			LOCAL Count     AS LONG
			LOCAL hFind     AS FIMETADATA
			//
			IF SELF:IsValid
				IF ( SELF:EXIFTagCount > 0 )
					IF ( SELF:EXIFModel == FREE_IMAGE_MDMODEL.FIMD_NODATA )
						//
						nTotalMain := FreeImage.GetMetadataCount( FREE_IMAGE_MDMODEL.FIMD_EXIF_MAIN, SELF:oDibObject )
						//nTotalSub  := FreeImage.GetMetadataCount( FREE_IMAGE_MDMODEL.FIMD_EXIF_EXIF, SELF:oDibObject )
						//
						IF ( dwPos < nTotalMain )
							nModel := FREE_IMAGE_MDMODEL.FIMD_EXIF_MAIN 
						ELSE
							dwPos := dwPos - nTotalMain
							nModel := FREE_IMAGE_MDMODEL.FIMD_EXIF_EXIF
						ENDIF			
					ELSE
						nModel := SELF:EXIFModel
					ENDIF
					//
					lFind := FALSE
					Count := 0
					hFind := FreeImage.FindFirstMetadata( nModel, SELF:oDibObject, REF oTag )
					//
					IF ( ! hFind:IsNull )
						REPEAT
							IF ( Count == dwPos )
								lFind := TRUE
								EXIT
							ENDIF
							// Tag Count
							Count ++
						UNTIL ( ! FreeImage.FindNextMetadata( hFind, REF oTag ) )
						//
						IF lFind
							cTagKey := oTag:Key
						ENDIF
					ENDIF
				ENDIF
			ENDIF
			RETURN cTagKey
			
		METHOD EXIFGetTagValue( dwPos AS DWORD ) AS STRING  
			/*	    LOCAL pBuffer	AS PTR
			LOCAL liSize	AS LONG*/
			LOCAL cTagValue  AS STRING
			LOCAL nTotalMain AS DWORD
			//LOCAL nTotalSub  AS LONG
			LOCAL nModel     AS FREE_IMAGE_MDMODEL
			LOCAL oTag      AS MetadataTag
			LOCAL lFind     AS LOGIC
			LOCAL Count     AS LONG
			LOCAL hFind     AS FIMETADATA
			//
			IF SELF:IsValid
				IF ( SELF:EXIFTagCount > 0 )
					IF ( SELF:EXIFModel == FREE_IMAGE_MDMODEL.FIMD_NODATA )
						//
						nTotalMain := FreeImage.GetMetadataCount( FREE_IMAGE_MDMODEL.FIMD_EXIF_MAIN, SELF:oDibObject )
						//nTotalSub  := FreeImage.GetMetadataCount( FREE_IMAGE_MDMODEL.FIMD_EXIF_EXIF, SELF:oDibObject )
						//
						IF ( dwPos < nTotalMain )
							nModel := FREE_IMAGE_MDMODEL.FIMD_EXIF_MAIN 
						ELSE
							dwPos := dwPos - nTotalMain
							nModel := FREE_IMAGE_MDMODEL.FIMD_EXIF_EXIF
						ENDIF			
					ELSE
						nModel := SELF:EXIFModel
					ENDIF
					//
					lFind := FALSE
					Count := 0
					hFind := FreeImage.FindFirstMetadata( nModel, SELF:oDibObject, REF oTag )
					//
					IF ( ! hFind:IsNull )
						REPEAT
							IF ( Count == dwPos )
								lFind := TRUE
								EXIT
							ENDIF
							// Tag Count
							Count ++
						UNTIL ( ! FreeImage.FindNextMetadata( hFind, REF oTag ) )
						//
						IF lFind
							cTagValue := oTag:ToString()
						ENDIF
					ENDIF
				ENDIF
			ENDIF
			RETURN cTagValue
			
		ACCESS EXIFModel AS FREE_IMAGE_MDMODEL  
			RETURN SELF:nExifModel
			
		ASSIGN EXIFModel( lModel AS FREE_IMAGE_MDMODEL )   
			SELF:nExifModel := lModel
			RETURN //self:nExifModel
			
			
		ACCESS EXIFTagCount AS LONG  
			LOCAL liTagCount	AS	DWORD
			//
			IF SELF:IsValid
				IF ( SELF:EXIFModel == FREE_IMAGE_MDMODEL.FIMD_NODATA )
					//
					liTagCount := FreeImage.GetMetadataCount( FREE_IMAGE_MDMODEL.FIMD_EXIF_MAIN, SELF:oDibObject )
					liTagCount += FreeImage.GetMetadataCount( FREE_IMAGE_MDMODEL.FIMD_EXIF_EXIF, SELF:oDibObject )
				ELSE
					liTagCount  := FreeImage.GetMetadataCount( SELF:EXIFModel, SELF:oDibObject )
				ENDIF
			ENDIF
			RETURN (long)liTagCount	    
			
		METHOD FromClipboard( dwFormat := 2 AS DWORD ) AS VOID  
			//p Paste the DIB object from the clipboard
			//d The underground object MUST exist before using this method.
			//d At least, use the Create() method.
			//j METHOD:FabPaintLib:Create
			//j METHOD:FabPaintLib:ToClipboard
			LOCAL oBitmap AS System.Drawing.Bitmap
			//
			IF SELF:IsValid
				//
				IF Clipboard.ContainsImage()
					oBitmap := (System.Drawing.Bitmap)Clipboard.GetImage()
					SELF:Destroy()
					//
					SELF:oDibObject := FreeImage.CreateFromBitmap( oBitmap );
					//
					SELF:__NotifyOwner( #FromClipboard )
				ENDIF    
				//
			ENDIF
			//	
			RETURN
			
		METHOD GetBackgroundColor( pRGB AS _WINRGBQUAD ) AS LOGIC  
			LOCAL pFIRGBQuad AS FreeImageAPI.RGBQUAD
			LOCAL lOk AS LOGIC
			//
			IF SELF:IsValid
				pFIRGBQuad := FreeImageAPI.RGBQUAD{}
				lOk := FreeImage.GetBackgroundColor( SELF:oDibObject, REF pFIRGBQuad )
				IF ( lOk )
					pRGB:rgbBlue := pFIRGBQuad:rgbBlue
					pRGB:rgbGreen := pFIRGBQuad:rgbGreen
					pRGB:rgbRed := pFIRGBQuad:rgbRed
				ENDIF
			ENDIF
			RETURN lOk	
			
		METHOD GrayScale( ) AS VOID  
			//p Convert the Image to GrayScale
			//d As this operation only support 32 bpp, the image is converted to 32 bpp if necessary before proceeding.
			LOCAL oNew AS FIBitmap
			//
			IF SELF:IsValid
				oNew := FreeImage.ConvertToGreyscale( SELF:oDibObject )
				SELF:CreateFrom( oNew )
				//
				SELF:__NotifyOwner( #MakeGrayScale )
				//
			ENDIF
			//
			RETURN
			
		METHOD Handle() AS PTR  
			//r hBitmap for the current image
			LOCAL hBitmap	AS	PTR
			//
			IF SELF:IsValid
				hBitmap := FreeImage.GetBitmapForDevice( SELF:oDibObject, IntPtr.Zero, FALSE )
			ENDIF
			RETURN hBitmap
			
		ACCESS HasBackgroundColor AS LOGIC  
			//r A logical value indicating if the image has a background color.
			LOCAL lBack AS LOGIC
			//
			IF SELF:IsValid
				lBack := FreeImage.HasBackgroundColor( SELF:oDibObject )
			ENDIF              
			//
			RETURN lBack
			
		ACCESS Height AS DWORD  
			//r The Height on pixel of the Image
			LOCAL nHeight	AS	DWORD
			//
			IF SELF:IsValid
				nHeight  := FreeImage.GetHeight( SELF:oDibObject )
			ENDIF
			RETURN nHeight
			
		ACCESS Image AS System.Drawing.Image
			RETURN FreeImage.GetBitmap( SELF:oDibObject )
			
		ACCESS Info AS _winBitmapInfo 
			LOCAL pInfo AS _winBitmapInfo
			//
			IF SELF:IsValid
				pInfo := FreeImage.GetInfo( SELF:oDibObject )
			ENDIF              
			//
			RETURN pInfo
			
		ACCESS InfoHeader AS _winBitmapInfoHeader  
			LOCAL pInfo AS _winBitmapInfoHeader
			//
			IF SELF:IsValid
				pInfo := FreeImage.GetInfoHeader( SELF:oDibObject )
			ENDIF              
			//
			RETURN pInfo
			
		INTERNAL ASSIGN Owner ( oOwn AS OBJECT )
			SELF:oOwner := oOwn
			RETURN
		
		CONSTRUCTOR( ) 
			// None
			SELF:nExifModel := FREE_IMAGE_MDMODEL.FIMD_NODATA
			// Per default
			SELF:cAsStringFileFormat := "BMP"
			//
			RETURN
			
		CONSTRUCTOR( oDib AS FIBitmap ) 
			SELF:oDibObject := oDib
			// None
			SELF:nExifModel := FREE_IMAGE_MDMODEL.FIMD_NODATA
			// Per default
			SELF:cAsStringFileFormat := "BMP"
			//
			RETURN
			
		CONSTRUCTOR( oDib AS FIBitmap, oOwn AS OBJECT ) 
			SELF:oDibObject := oDib
			// None
			SELF:nExifModel := FREE_IMAGE_MDMODEL.FIMD_NODATA
			// Per default
			SELF:cAsStringFileFormat := "BMP"
			//
			IF ( oOwner != NULL )
				SELF:oOwner := oOwn
			ENDIF
			RETURN
			
		CONSTRUCTOR( cFile AS STRING, oOwn AS OBJECT  ) 
			SELF:CreateFromFile( cFile )
			// None
			SELF:nExifModel := FREE_IMAGE_MDMODEL.FIMD_NODATA
			// Per default
			SELF:cAsStringFileFormat := "BMP"
			IF ( oOwner != NULL )
				SELF:oOwner := oOwn
			ENDIF
			RETURN
			
		CONSTRUCTOR( oMultiContainer AS FabMultiPage, oOwn AS OBJECT ) 
			SELF:oContainer := oMultiContainer
			// None
			SELF:nExifModel := FREE_IMAGE_MDMODEL.FIMD_NODATA
			// Per default
			SELF:cAsStringFileFormat := "BMP"
			//
			IF ( oOwner != NULL )
				SELF:oOwner := oOwn
			ENDIF
			RETURN
			
		METHOD Invert( ) AS VOID  
			//p Invert the Image
			//d As this operation only support 32 bpp, the image is converted to 32 bpp if necessary before proceeding.
			/*	    LOCAL pCopy	AS	PTR*/
			//
			IF SELF:IsValid
				FreeImage.Invert( SELF:oDibObject )
				//
				SELF:__NotifyOwner( #Invert )
				//
			ENDIF
			//
			RETURN
			
		ACCESS IsTransparent AS LOGIC  
			//r A logical value indicating if the image is transparent.
			LOCAL lTransparent AS LOGIC
			//
			IF SELF:IsValid
				lTransparent := FreeImage.IsTransparent( SELF:oDibObject )
			ENDIF              
			//
			RETURN lTransparent
			
			
		ASSIGN IsTransparent( lSet AS LOGIC )   
			//r A logical value indicating if the image is transparent.
			//
			IF SELF:IsValid
				FreeImage.SetTransparent( SELF:oDibObject, lSet )
			ENDIF              
			//
			RETURN 
			
			
		ACCESS IsValid AS LOGIC  
			//r A logical value indicating if the object is linked to an image.
			RETURN ( SELF:oDibObject != FIBITMAP.Zero )
			
			
		METHOD PasteSubImage( oSubImage AS FabPaintLibBase, Left AS LONG, Top AS LONG ) AS LOGIC  
			LOCAL oSub AS FIBitmap
			LOCAL lOk AS LOGIC
			//
			IF SELF:IsValid
				IF ( oSubImage != NULL_OBJECT )
					oSub := oSubImage:oDibObject
					//lOk := DIBPasteSub( self:pDibObject, pSub, Left, Top, 256 )
					lOk := FreeImage.Paste( SELF:oDibObject, oSub, Left, Top, 256 )
				ENDIF
			ENDIF
			//
			RETURN lOk
			
			
		METHOD ResizeBilinear( NewXSize AS LONG, NewYSize AS LONG ) AS VOID  
			//p Resize the Image using bilinear interpolation
			//a <NewXSize> New X Size of the Image
			//a <NewYSize> New Y Size of the Image
			//d As this operation only support 32 bpp, the image is converted to 32 bpp if necessary before proceeding.
			LOCAL oNew	AS	FIBitmap
			//
			IF SELF:IsValid
				oNew := FreeImage.Rescale( SELF:oDibObject, NewXSize, NewYSize, FreeImageAPI.FREE_IMAGE_FILTER.FILTER_BILINEAR )
				SELF:CreateFrom( oNew )
				//
				SELF:__NotifyOwner( #ResizeBilinear )
				//
			ENDIF
			//
			RETURN
			
		METHOD ResizeBox( NewXSize AS LONG, NewYSize AS LONG, NewRadius AS REAL8 ) AS VOID  
			//p Resizes a bitmap and applies a box filter to it
			//a <NewXSize> New X Size of the Image
			//a <NewYSize> New Y Size of the Image
			//a <NewRadius>
			//d As this operation only support 32 bpp, the image is converted to 32 bpp if necessary before proceeding.
			LOCAL oNew	AS	FIBitmap
			//
			IF SELF:IsValid
				oNew := FreeImage.Rescale( SELF:oDibObject, NewXSize, NewYSize, FreeImageAPI.FREE_IMAGE_FILTER.FILTER_BOX )
				SELF:CreateFrom( oNew )
				//
				SELF:__NotifyOwner( #ResizeBilinear )
				//
			ENDIF
			RETURN    
			
		METHOD ResizeGaussian( NewXSize AS LONG, NewYSize AS LONG, NewRadius AS REAL8 ) AS VOID  
			//p Resizes a bitmap and applies a gaussian blur to it.
			//a <NewXSize> New X Size of the Image
			//a <NewYSize> New Y Size of the Image
			//a <NewRadius>
			//d As this operation only support 32 bpp, the image is converted to 32 bpp if necessary before proceeding.
			LOCAL oNew	AS	FIBitmap
			//
			IF SELF:IsValid
				oNew := FreeImage.Rescale( SELF:oDibObject, NewXSize, NewYSize, FreeImageAPI.FREE_IMAGE_FILTER.FILTER_BICUBIC )
				SELF:CreateFrom( oNew )
				//
				SELF:__NotifyOwner( #ResizeBilinear )
				//
			ENDIF
			RETURN
			
		METHOD ResizeHamming( NewXSize AS LONG, NewYSize AS LONG, NewRadius AS REAL8 ) AS VOID  
			//p Resizes a bitmap and applies a hamming filter to it.
			//a <NewXSize> New X Size of the Image
			//a <NewYSize> New Y Size of the Image
			//a <NewRadius>
			//d As this operation only support 32 bpp, the image is converted to 32 bpp if necessary before proceeding.
			LOCAL oNew	AS	FIBitmap
			//
			IF SELF:IsValid
				oNew := FreeImage.Rescale( SELF:oDibObject, NewXSize, NewYSize, FreeImageAPI.FREE_IMAGE_FILTER.FILTER_BSPLINE )
				SELF:CreateFrom( oNew )
				//
				SELF:__NotifyOwner( #ResizeBilinear )
				//
			ENDIF
			RETURN
			
		METHOD Rotate( angle AS REAL8, oColor AS System.Drawing.Color ) AS VOID  
			//p Rotates a bitmap by angle radians.
			//a <angle> Rotation angle in Radian
			//a <color> The RGB Color used to fill new part of the image
			//d As this operation only support 32 bpp, the image is converted to 32 bpp if necessary before proceeding.
			LOCAL deg AS Double
			//
			IF SELF:IsValid
				// angle is in Radian, FreeImage uses Degree....
				deg := angle * (180.0 / Math.PI )
				//
				SELF:RotateDeg( deg, oColor )
				//
			ENDIF
			//
			RETURN
			
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
				FreeImage_Rotate( SELF:oDibObject, angle, @pClr )
				SELF:__NotifyOwner( #Rotate )
				//
			ENDIF
			//
			RETURN
			
		METHOD SaveAs( cFileName AS STRING ) AS VOID  
			//p Save to a DIB file
			//a <cFileName> Name of the File to create
			//d This method will save the desired DIB Object as a DIB file.
			//
			IF SELF:IsValid
				FreeImage.SaveEx( SELF:oDibObject, cFileName )
			ENDIF
			//
			RETURN
			
		METHOD SaveAsAny( cFileName AS STRING, FI_Flag AS INT, FIF AS INT ) AS VOID  
			//p Save to a file
			//a <cFileName> Name of the File to create
			//a <FI_Flag is the flag to use in save operation. (look at FreeImage Help file for more info) 0 is the default value
			//a <FIF> indicates what is the file format to use.
			//d This method will save the desired DIB Object as a file.
			//
			IF SELF:IsValid
				FreeImage.SaveEx( SELF:oDibObject, cFileName, (FreeImageAPI.FREE_IMAGE_FORMAT)FIF, (FreeImageAPI.FREE_IMAGE_SAVE_FLAGS)FI_Flag )
			ENDIF
			//
			RETURN
			//-----------------------------------------------------------------------------------------------------------------------------------//
		METHOD SaveAsJPEG( cFileName AS STRING ) AS VOID  
			//p Save to a JPEG file
			//a <cFileName> Name of the File to create
			//d This function will save the desired DIB Object as a JPEG file.
			//
			IF SELF:IsValid
				FreeImage.SaveEx( SELF:oDibObject, cFileName, FreeImageAPI.FREE_IMAGE_FORMAT.FIF_JPEG )
			ENDIF
			//
			RETURN
			
		METHOD SaveAsJPEGEx( cFileName AS STRING, Quality AS INT ) AS VOID
			//
			IF SELF:IsValid
				FreeImage.SaveEx( SELF:oDibObject, cFileName, FreeImageAPI.FREE_IMAGE_FORMAT.FIF_JPEG, (FreeImageAPI.FREE_IMAGE_SAVE_FLAGS)Quality )
			ENDIF
			//
			RETURN    
			
			
		METHOD SaveAsPNG( cFileName AS STRING ) AS VOID  
			//p Save to a PNG file
			//a <cFileName> Name of the File to create
			//d This function will save the desired DIB Object as a PNG file.
			//
			IF SELF:IsValid
				FreeImage.SaveEx( SELF:oDibObject, cFileName, FreeImageAPI.FREE_IMAGE_FORMAT.FIF_PNG )
			ENDIF
			//
			RETURN
			
		METHOD SaveAsPNGEx( cFileName AS STRING, PNGLevel AS INT ) AS VOID
			//
			IF SELF:IsValid
				FreeImage.SaveEx( SELF:oDibObject, cFileName, FreeImageAPI.FREE_IMAGE_FORMAT.FIF_PNG, (FreeImageAPI.FREE_IMAGE_SAVE_FLAGS)PNGLevel )
			ENDIF
			//
			RETURN 
			
			
		METHOD SaveAsTIFF( cFileName AS STRING ) AS VOID  
			//p Save to a TIFF file
			//a <cFileName> Name of the File to create
			//d This function will save the desired DIB Object as a TIFF file.
			//
			IF SELF:IsValid
				FreeImage.SaveEx( SELF:oDibObject, cFileName, FreeImageAPI.FREE_IMAGE_FORMAT.FIF_TIFF )
			ENDIF
			//
			RETURN
			
		METHOD SaveAsTIFFEx( cFileName AS STRING, Quality AS INT ) AS VOID
			//
			IF SELF:IsValid
				FreeImage.SaveEx( SELF:oDibObject, cFileName, FreeImageAPI.FREE_IMAGE_FORMAT.FIF_TIFF, (FreeImageAPI.FREE_IMAGE_SAVE_FLAGS)Quality )
			ENDIF
			//
			RETURN     
			
		METHOD SetBackgroundColor( oColor AS System.Drawing.Color ) AS LOGIC  
			LOCAL lOk AS LOGIC
			LOCAL oRGB AS RGBQUAD
			//
			oRGB := RGBQUAD{ oColor }
			//
			IF SELF:IsValid
				FreeImage.SetBackgroundColor( SELF:oDibObject, REF oRGB )
				//DIBSetBackgroundColor( self:pDibObject, pRGB )
			ENDIF
			RETURN lOk	
			
		METHOD ToClipboard( ) AS VOID  
			//p Copy the DIB object to the clipboard
			//j METHOD:FabPaintLib:FromClipboard
			LOCAL Dib AS FIBitmap
			LOCAL Bmp AS System.Drawing.Bitmap
			//
			IF SELF:IsValid
				//
				IF ( FreeImage.GetImageType( SELF:oDibObject ) != FREE_IMAGE_TYPE.FIT_BITMAP )
					Dib := FreeImage.ConvertToType( SELF:oDibObject, FREE_IMAGE_TYPE.FIT_BITMAP, TRUE )
					Bmp := FreeImage.GetBitmap( Dib )
					System.Windows.Forms.Clipboard.SetImage( Bmp )
					FreeImage.Unload( Dib )
				ELSE
					Bmp := FreeImage.GetBitmap( SELF:oDibObject )
					System.Windows.Forms.Clipboard.SetImage( Bmp )
				ENDIF
				//
			ENDIF
			//	
			RETURN
			
			
		ACCESS Width AS DWORD  
			//r The width in pixel of the image
			LOCAL nWidth	AS	DWORD
			//
			IF SELF:IsValid
				nWidth := FreeImage.GetWidth( SELF:oDibObject )
			ENDIF
			RETURN nWidth
			
	END CLASS
	
	CLASS FabPaintLib INHERIT FabPaintLibBase
		
		CONSTRUCTOR( oDib AS FIBitmap ) 
			SUPER( oDib )
			RETURN
			
		CONSTRUCTOR( oDib AS FIBitmap, oOwn AS OBJECT ) 
			SUPER( oDib, oOwn )
			RETURN
			
		CONSTRUCTOR( cFile AS STRING, oOwn AS OBJECT  ) 
			SUPER( cFile, oOwn )
			RETURN
			
		CONSTRUCTOR( cFile AS STRING  ) 
			SUPER( cFile, NULL )
			RETURN
			
		CONSTRUCTOR(  ) 
			SUPER( )
			RETURN
			
		CONSTRUCTOR( oMultiContainer AS FabMultiPage, oOwn AS OBJECT ) 
			SUPER( oMultiContainer, oOwn )
			RETURN
			
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
			RETURN
			
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
			RETURN    
			
		METHOD Show( hWnd AS PTR, XPos AS LONG, YPos AS LONG, Width AS LONG, Height AS LONG ) AS VOID  
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
			RETURN
			
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
				StretchDIBits(hDC, 0, 0, (int)SELF:Width, (int)SELF:Height, ; 
				0, 0, (int)SELF:Width, (int)SELF:Height,;
				SELF:BitmapBits, SELF:Info, DIB_RGB_COLORS, SRCCOPY )
			ENDIF
			// 
			RETURN
			
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
				StretchDIBits(hDC, XPos, YPos, XPos + (int)SELF:Width, YPos + (int)SELF:Height, ; 
				0, 0, (int)SELF:Width, (int)SELF:Height,;
				SELF:BitmapBits, SELF:Info, 0, 0x00CC0020 )
			ENDIF
			// 
			RETURN
			
		METHOD ShowDC( hDC AS PTR, XPos AS LONG, YPos AS LONG, Width AS LONG, Height AS LONG ) AS VOID  
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
				0, 0, (int)SELF:Width, (int)SELF:Height,;
				SELF:BitmapBits, SELF:Info, 0, 0x00CC0020 )
			ENDIF
			// 
			RETURN
			
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
			RETURN
			
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
			RETURN
			
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
			RETURN
			
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
			RETURN
			
		METHOD Stretch( hWnd AS PTR, nWidth AS DWORD, nHeight AS DWORD, r8Factor AS REAL8) AS VOID  
			//p Stretch the image in a Window with Zoom
			//a <hWnd> Handle of the Window
			//a <nWidth> Width of the area for displaying the DIB.
			//a <nHeight> Height of the area for displaying the DIB.
			//a <r8Factor> The zoom factor of the bitmap.  A value of 1.0 would be its normal size.
			//d This function will stretch the image using the specified factor
			//j FUNCTION:DIBStretch
			LOCAL w AS LONG
			LOCAL h AS LONG
			//
			IF SELF:IsValid
				//
				w := LONG( nWidth * r8Factor )
				h := LONG( nHEight * r8Factor )
				SELF:ShowEx(  hWnd, w, h )
			ENDIF
			//
			RETURN
			
		METHOD StretchDC( hDC AS PTR, nCx AS DWORD, nCy AS DWORD, r8Factor AS REAL8) AS VOID  
			//p Stretch the image in a Window with Zoom
			//a <hDC> Handle of the Device Context
			//a <nCx> Width of the area for displaying the DIB.
			//a <nCy> Height of the area for displaying the DIB.
			//a <r8Factor> The zoom factor of the bitmap.  A value of 1.0 would be its normal size.
			//d This function will stretch the image using the specified factor
			//j FUNCTION:DIBStretch
			LOCAL w AS LONG
			LOCAL h AS LONG
			//
			IF SELF:IsValid
				//
				w := LONG( nCx * r8Factor )
				h := LONG( nCy * r8Factor )
				SELF:ShowExDC(  hDC, w, h )
			ENDIF
			//
			RETURN
			
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
			RETURN
			
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
			RETURN
			
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
			RETURN
			
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
				SELF:BitmapBits, SELF:Info, DIB_RGB_COLORS, SRCCOPY )
				//	    
			ENDIF
			//
			RETURN
			
		METHOD StretchExDrawDCBackground( hDC AS PTR, prcDest AS _WINRect, prcSrc AS _WINRect, ;
			lUseFile AS LOGIC, pRGB AS _winRGBQUAD, oBackgroundImage AS FabPaintLib ;
			) AS VOID  
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
			LOCAL lHasBackground    AS LOGIC
			LOCAL lIsTransparent    AS LOGIC
			LOCAL image_type        AS FREE_IMAGE_TYPE
			LOCAL oDisplayDib       AS FIBitmap
			LOCAL bg                AS FIBitmap
			LOCAL dib_double        AS FIBitmap
			LOCAL dib32             AS FIBitmap
			LOCAL pClr              AS FreeImageAPI.RGBQUAD
			LOCAL bDeleteMe         AS  LOGIC
			LOCAL rcDest            IS _WINRect
			LOCAL rcSrc             IS _WINRect
			//
			IF ( pRGB != NULL )
				pClr := FreeImageAPI.RGBQUAD{}
				pClr:rgbBlue := pRGB:rgbBlue
				pClr:rgbRed := pRGB:rgbRed
				pClr:rgbGreen := pRGB:rgbGreen
			ENDIF
			//
			IF SELF:IsValid
				IF ( oBackgroundImage != NULL_OBJECT )
					bg := oBackgroundImage:oDibObject
				ENDIF
				image_type := FreeImage.GetImageType( SELF:oDibObject )
				//
				IF ( image_type == FREE_IMAGE_TYPE.FIT_BITMAP )
					lHasBackground := SELF:HasBackgroundColor
					lIsTransparent := SELF:IsTransparent
					//
					IF( !lIsTransparent .AND. ( !lHasBackground .OR. !lUseFile ) )
						// Use the current FIBitmap
						oDisplayDib := SELF:oDibObject
					ELSE
						// Create the transparent / alpha blended image
						oDisplayDib := FreeImage.Composite( SELF:oDibObject, lUseFile, REF pClr, bg )
						IF ( oDisplayDib != FIBITMAP.Zero )
							bDeleteMe := TRUE
						ELSE
							oDisplayDib := SELF:oDibObject
						ENDIF
					ENDIF
				ELSE
					// Convert to a standard dib for display
					IF ( image_type == FREE_IMAGE_TYPE.FIT_COMPLEX)
						// Convert to type FIT_DOUBLE
						dib_double := FreeImage.GetComplexChannel( SELF:oDibObject, FREE_IMAGE_COLOR_CHANNEL.FICC_MAG)
						// Convert to a standard bitmap (linear scaling)
						oDisplayDib := FreeImage.ConvertToStandardType( dib_double, TRUE)
						// Free image of type FIT_DOUBLE
						FreeImage.Unload(dib_double)
					ELSEIF ( (image_type == FREE_IMAGE_TYPE.FIT_RGBF) .OR. ( image_type == FREE_IMAGE_TYPE.FIT_RGB16) ) 
						// Apply a tone mapping algorithm and convert to 24-bit 
						// default tone mapping operator
						oDisplayDib := FreeImage.ToneMapping( SELF:oDibObject, FreeImageAPI.FREE_IMAGE_TMO.FITMO_DRAGO03, 0, 0 )
					ELSEIF ( image_type == FREE_IMAGE_TYPE.FIT_RGBA16)
						// Convert to 32-bit
						dib32 := FreeImage.ConvertTo32Bits( SELF:oDibObject )
						IF ( dib32 != FIBITMAP.Zero )
							// Create the transparent / alpha blended image
							oDisplayDib := FreeImage.Composite( dib32, lUseFile, REF pClr, bg )
							FreeImage.Unload(dib32)
						ENDIF
					ELSE
						// Other cases: convert to a standard bitmap (linear scaling)
						oDisplayDib := FreeImage.ConvertToStandardType( SELF:oDibObject, TRUE)
					ENDIF
					// Remember to delete oDisplayDib
					bDeleteMe := TRUE
				ENDIF
				//
				IF ( prcDest == NULL )
					SetRect( @rcDest, 0, 0, (int)FreeImage.GetWidth(oDisplayDib), (int)FreeImage.GetHeight(oDisplayDib) )
				ELSE
					SetRect( @rcDest, prcDest:left, prcDest:top, prcDest:right, prcDest:bottom )
				ENDIF
				//
				IF ( prcSrc == NULL )
					SetRect( @rcSrc, 0, 0, (int)FreeImage.GetWidth(oDisplayDib), (int)FreeImage.GetHeight(oDisplayDib) )
				ELSE
					SetRect( @rcSrc, prcSrc:left, prcSrc:top, prcSrc:right, prcSrc:bottom )
				ENDIF
				// Draw the dib
				SetStretchBltMode(hDC, COLORONCOLOR)
				StretchDIBits(hDC,  rcDest:left, rcDest:top, rcDest:right-rcDest:left, rcDest:bottom-rcDest:top, ;
				rcSrc:left, rcSrc:top, rcSrc:right-rcSrc:left, rcSrc:bottom - rcSrc:top,;
				FreeImage.GetBits(oDisplayDib), FreeImage.GetInfo(oDisplayDib), DIB_RGB_COLORS, SRCCOPY)
				//
				IF ( bDeleteMe )
					FreeImage.Unload(oDisplayDib)
				ENDIF
			ENDIF
			
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
		RETURN
		
		ACCESS UseGDI AS LOGIC  
			//r A logical value indicating if FabPaint uses VFW functions or GDI functions to draw
			//LOCAL lSet	AS	LOGIC
			//
			IF SELF:IsValid
				// Nothing Todo here
				//lSet := DIBGetUseGDI( SELF:pDibObject )
			ENDIF
			RETURN TRUE
			
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
	
END NAMESPACE 
