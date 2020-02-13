/* TEXTBLOCK Sample Modif
/-*
//s
// To use the FabPaint.DLL extension with the VO standard CAPAINT demo
// Add the following code to the ImgShell Module, and replace existing code

STATIC DEFINE PROGRESS_PROGRESSBAR1 := 100
CLASS Progress INHERIT DIALOGWINDOW

	EXPORT oDCProgressBar1 AS PROGRESSBAR

  //{{%UC%}} USER CODE STARTS HERE (do NOT remove this line)
RESOURCE Progress DIALOGEX  6, 17, 180, 13
STYLE	DS_3DLOOK|DS_CENTER|WS_POPUP|WS_CAPTION
CAPTION	"Loading..."
FONT	8, "MS Sans Serif"
BEGIN
	CONTROL	"", PROGRESS_PROGRESSBAR1, "msctls_progress32", PBS_SMOOTH|WS_CHILD, 0, 0, 179, 12, WS_EX_STATICEDGE
END

METHOD Init(oParent,uExtra) CLASS Progress

SELF:PreInit(oParent,uExtra)

SUPER:Init(oParent,ResourceID{"Progress",_GetInst()},FALSE)

oDCProgressBar1 := ProgressBar{SELF,ResourceID{PROGRESS_PROGRESSBAR1,_GetInst()}}
oDCProgressBar1:HyperLabel := HyperLabel{#ProgressBar1,NULL_STRING,NULL_STRING,NULL_STRING}
oDCProgressBar1:Range := Range{0,100}

SELF:Caption := "Loading..."
SELF:HyperLabel := HyperLabel{#Progress,"Loading...",NULL_STRING,NULL_STRING}

SELF:PostInit(oParent,uExtra)

RETURN SELF

METHOD SaveAs	()	CLASS StdImageWindow

	LOCAL oTB 		AS TextBox
	LOCAL oSaveAs	AS SaveAsDialog
	LOCAL cFName	AS STRING

	oSaveAs := SaveAsDialog{SELF:Owner, "*.DIB"}
	oSaveAs:Show()

	cFName := oSaveAs:FileName	

	IF __IsValidImage(cFName)
		DIBSaveAs(SELF:pBitMap, cFName)
	ELSEIF ( ".JPG" $ Upper( cFName ) )
		DIBSaveAsJPEG(SELF:pBitMap, cFName)
	ELSEIF ( ".PNG" $ Upper( cFName ) )
		DIBSaveAsPNG(SELF:pBitMap, cFName)
	ELSEIF ( ".TIF" $ Upper( cFName ) )
		DIBSaveAsTIFF(SELF:pBitMap, cFName)
	ELSE
		oTB := TextBox{SELF, "Error", "Cannot save " + cFName + " - Not a .DIB file"}
		oTB:Type := BUTTONOKAY
		oTB:Show()
	ENDIF
	
METHOD Init(oParentWindow, sFileName) CLASS StdImageWindow
	LOCAL sCaption 	AS STRING
	LOCAL cr		IS _WINRECT
	LOCAL wr		IS _WINRECT
	LOCAL oDlg		AS	Progress

	SUPER:Init(oParentWindow, TRUE)
	
	SELF:Menu := ImgViewShellMenu{SELF}
	
	sCaption  := "Image File: "
	
	IF File(sFileName)
		SELF:cFile := sFileName
	ENDIF

	#IFDEF USE_CAPAINT
		oDlg := Progress{ SELF }
		oDlg:Show()
		ApplicationExec( EXECWHILEEVENT )
		DIBSetProgressControl( oDlg:oDCProgressBar1:Handle() )
   		SELF:pBitMap := DIBCreateFromFile(sFileName)
		DIBSetProgressControl( NULL_PTR )
   		oDlg:Destroy()

		IF SELF:pBitMap = NULL_PTR
			MessageBox(0,;
					   "Error reading image",;
					   "ERROR ", ;
					   MB_ICONSTOP)
			
		ELSEIF CAPaintLastError() > 0
			MessageBox(0,;
					   CAPaintLastErrorMsg(),;
					   "ERROR " + NTrim( CAPaintlasterror() ), ;
					   MB_OK)
		ELSE					
					
			SELF:lBitMap := .T.					
		ENDIF					
    #ENDIF	

	SELF:Caption := sCaption + sFileName

	hWnd := SELF:Handle()

	GetWindowRect(hWnd, @wr)
	GetClientRect(hWnd, @cr)

	SELF:cx := wr.right  - wr.left - cr.right
	SELF:cy := wr.bottom - wr.top  - cr.bottom
//!
*-/
*/
/* TEXTBLOCK ! Read Me First
/-*
//s
This freeware library has been build using the free C++ FreeImage
You can find the original library at http://freeimage.sourceforge.net/

The FabPaint DLL has been build using a modified version to fit some of my needs, and some add-on
has been made, and to keep it compatible with previous versions that were builds against
PaintLib (www.paintLib.de), but nothing "serious".

(See the Read Me Second, for more info )

Any comments, bug reports, or wishes are welcome

Fabrice Foray
fabrice@fabtoys.net
http://www.fabtoys.net


//!
*-/

*/
/* TEXTBLOCK ! Read Me Second
/-*
//s
This library is fully compatible with the standard VO CAPAINT DLL
All DIBxxx functions are working the same way and you can use the FABPAINT DLL
instead of the CAPAINT without any change in your code.

To use it, just put the Fab PaintLib in your "libraries" list, and put it BEFORE the GUI classes.
Rebuild...you're done !!

The "underground" of FABPAINT ( as CAPAINT I believe ) is a C++ DLL. All pBitmap PTR returned
by any DIBCreateXXX() function is a C++ object; functions are just wrappers to methods of these
objects. The DIBDelete() just call the destructor for these objects.

Now, FABPAINT offers you at least :

DIBCreateFromHBitmap
	Create a DIB ptr based on a hBitmap value ( For eg, a return value of a LoadBitmap() call )

DIBCreateFromHDib
	Create a DIB ptr based on a hDib value ( For eg, a return value of FabEZTwain32 )
	
DIBSaveAsJPEG
DIBSaveAsPNG
DIBSaveAsTIFF
	You really need some info about these ?? -))

DIBSetProgressControl
	Set a ProgressBar Control, via it's handle, that will be updated when decoding (reading)
	 a image. This control must be set for a range from 0 to 100 ( percentage value )
	Setting to NULL_PTR disables the notification. ( See the "Sample Modif" Textblock for a sample )

DIBCreateCopy
	Create a Copy of an existing DIB object. You can pass the needed BitPerPixel value.
	Values can be 1, 8, 32. 0 Keep the current one.
	
DIBStretchDraw
	Show a DIB Object at a pos with a specified Width and Height
	
DIBResizeBilinear
	Resize a DIB using a bilinear interpolation.

DIBResizeBox
	Resize a DIB. You can also set a blurred value.

DIBResizeGaussian
	Resize a DIB. You can also apply a gaussian blur to it.

DIBResizeHamming
	Resize a DIB. You can also apply a hamming filter to it
	
DIBCrop
	Cuts part of the image off.
	
DIBMakeGrayscale
	Creates a grayscale version of the bitmap.
	
DIBRotate
	Rotates a bitmap by angle radians.
	
DIBInvert
	Invert a DIB
	
DIBShowFitToWindow
	Show a DIB in a Window, keeping scale between Width and Height

//!
*-/
*/
/* TEXTBLOCK EXIF
/-*
EXIF  Tag are added in JEPG file coming from Digital Camera
You can then retrieve some info about the context when the image was taken.


*-/
*/
/* TEXTBLOCK TIFF - Compression Level
/-*
DEFINE TIFF_DEFAULT        :=0
DEFINE TIFF_CMYK			:= 0x0001	// reads/stores tags for separated CMYK (use | to combine with compression flags)
DEFINE TIFF_PACKBITS       := 0x0100  // save using PACKBITS compression
DEFINE TIFF_DEFLATE        := 0x0200  // save using DEFLATE compression (a.k.a. ZLIB compression)
DEFINE TIFF_ADOBE_DEFLATE  := 0x0400  // save using ADOBE DEFLATE compression
DEFINE TIFF_NONE           := 0x0800  // save without any compression
DEFINE TIFF_CCITTFAX3		:= 0x1000  // save using CCITT Group 3 fax encoding
DEFINE TIFF_CCITTFAX4		:= 0x2000  // save using CCITT Group 4 fax encoding
DEFINE TIFF_LZW			:= 0x4000	// save using LZW compression
DEFINE TIFF_JPEG			:= 0x8000	// save using JPEG compression
*-/
*/
/* TEXTBLOCK ! Fab Paint 3 : MUST read me
/-*
This new version has been build using FreeImage instead of PaintLib.

One of the changes is that I (currently) can't support the Notification any more.
For code compatibility everything is still in the Class and DLL but doesn't work any more.
	
This software uses the FreeImage open source image library. See http://freeimage.sourceforge.net for details.

FreeImage is used under the (GNU GPL or FIPL), version 1.0.
*-/
*/
/* TEXTBLOCK  FreeImage Licence TEXT
/-*
FreeImage Public License - Version 1.0
---------------------------------------------

1. Definitions.

1.1. "Contributor" means each entity that creates or contributes to the creation of Modifications.

1.2. "Contributor Version" means the combination of the Original Code, prior Modifications used by a Contributor, and the Modifications made by that particular Contributor.

1.3. "Covered Code" means the Original Code or Modifications or the combination of the Original Code and Modifications, in each case including portions thereof.

1.4. "Electronic Distribution Mechanism" means a mechanism generally accepted in the software development community for the electronic transfer of data.

1.5. "Executable" means Covered Code in any form other than Source Code.

1.6. "Initial Developer" means the individual or entity identified as the Initial Developer in the Source Code notice required by Exhibit A.

1.7. "Larger Work" means a work which combines Covered Code or portions thereof with code not governed by the terms of this License.

1.8. "License" means this document.

1.9. "Modifications" means any addition to or deletion from the substance or structure of either the Original Code or any previous Modifications. When Covered Code is released as a series of files, a
Modification is:

A. Any addition to or deletion from the contents of a file containing Original Code or previous Modifications.

B. Any new file that contains any part of the Original Code or previous Modifications.

1.10. "Original Code" means Source Code of computer software code which is described in the Source Code notice required by Exhibit A as Original Code, and which, at the time of its release under this License is not already Covered Code governed by this License.

1.11. "Source Code" means the preferred form of the Covered Code for making modifications to it, including all modules it contains, plus any associated interface definition files, scripts used to control
compilation and installation of an Executable, or a list of source code differential comparisons against either the Original Code or another well known, available Covered Code of the Contributor's choice. The Source Code can be in a compressed or archival form, provided the appropriate decompression or de-archiving software is widely available for no charge.

1.12. "You" means an individual or a legal entity exercising rights under, and complying with all of the terms of, this License or a future version of this License issued under Section 6.1. For legal entities, "You" includes any entity which controls, is controlled by, or is under common control with You. For purposes of this definition, "control" means (a) the power, direct or indirect, to cause the
direction or management of such entity, whether by contract or otherwise, or (b) ownership of fifty percent (50%) or more of the outstanding shares or beneficial ownership of such entity.

2. Source Code License.

2.1. The Initial Developer Grant.
The Initial Developer hereby grants You a world-wide, royalty-free, non-exclusive license, subject to third party intellectual property claims:

(a) to use, reproduce, modify, display, perform, sublicense and distribute the Original Code (or portions thereof) with or without Modifications, or as part of a Larger Work; and

(b) under patents now or hereafter owned or controlled by Initial Developer, to make, have made, use and sell ("Utilize") the Original Code (or portions thereof), but solely to the extent that
any such patent is reasonably necessary to enable You to Utilize the Original Code (or portions thereof) and not to any greater extent that may be necessary to Utilize further Modifications or
combinations.

2.2. Contributor Grant.
Each Contributor hereby grants You a world-wide, royalty-free, non-exclusive license, subject to third party intellectual property claims:

(a) to use, reproduce, modify, display, perform, sublicense and distribute the Modifications created by such Contributor (or portions thereof) either on an unmodified basis, with other Modifications, as Covered Code or as part of a Larger Work; and

(b) under patents now or hereafter owned or controlled by Contributor, to Utilize the Contributor Version (or portions thereof), but solely to the extent that any such patent is reasonably necessary to enable You to Utilize the Contributor Version (or portions thereof), and not to any greater extent that
may be necessary to Utilize further Modifications or combinations.

3. Distribution Obligations.

3.1. Application of License.
The Modifications which You create or to which You contribute are governed by the terms of this License, including without limitation Section 2.2. The Source Code version of Covered Code may be distributed only under the terms of this License or a future version of this License released under Section 6.1, and You must include a copy of this License with every copy of the Source Code You distribute. You may not offer or impose any terms on any Source Code version that alters or
restricts the applicable version of this License or the recipients' rights hereunder. However, You may include an additional document offering the additional rights described in Section 3.5.

3.2. Availability of Source Code.
Any Modification which You create or to which You contribute must be made available in Source Code form under the terms of this License either on the same media as an Executable version or via an accepted Electronic Distribution Mechanism to anyone to whom you made an Executable version available; and if made available via Electronic Distribution Mechanism, must remain available for at least twelve (12) months after the date it initially became available, or at least six (6) months after a subsequent version of that particular Modification has been made available to such recipients. You are responsible for ensuring that the Source Code version remains available even if the Electronic Distribution Mechanism is maintained by a third party.

3.3. Description of Modifications.
You must cause all Covered Code to which you contribute to contain a file documenting the changes You made to create that Covered Code and the date of any change. You must include a prominent statement that the Modification is derived, directly or indirectly, from Original Code provided by the Initial Developer and including the name of the Initial Developer in (a) the Source Code, and (b) in any notice in an Executable version or related documentation in which You describe the origin or ownership of the Covered Code.

3.4. Intellectual Property Matters

(a) Third Party Claims.
If You have knowledge that a party claims an intellectual property right in particular functionality or code (or its utilization under this License), you must include a text file with the source code distribution titled "LEGAL" which describes the claim and the party making the claim in sufficient detail that a recipient will know whom to contact. If you obtain such knowledge after You make Your Modification available as described in Section 3.2, You shall promptly modify the LEGAL file in all copies You make
available thereafter and shall take other steps (such as notifying appropriate mailing lists or newsgroups) reasonably calculated to inform those who received the Covered Code that new knowledge has been obtained.

(b) Contributor APIs.
If Your Modification is an application programming interface and You own or control patents which are reasonably necessary to implement that API, you must also include this information in the LEGAL file.

3.5. Required Notices.
You must duplicate the notice in Exhibit A in each file of the Source Code, and this License in any documentation for the Source Code, where You describe recipients' rights relating to Covered Code. If You created one or more Modification(s), You may add your name as a Contributor to the notice described in Exhibit A. If it is not possible to put such notice in a particular Source Code file due to its
structure, then you must include such notice in a location (such as a relevant directory file) where a user would be likely to look for such a notice. You may choose to offer, and to charge a fee for, warranty, support, indemnity or liability obligations to one or more recipients of Covered Code. However, You may do so only on Your own behalf, and not on behalf of the Initial Developer or any Contributor. You must make it absolutely clear than any such warranty, support, indemnity or
liability obligation is offered by You alone, and You hereby agree to indemnify the Initial Developer and every Contributor for any liability incurred by the Initial Developer or such Contributor as a result of
warranty, support, indemnity or liability terms You offer.

3.6. Distribution of Executable Versions.
You may distribute Covered Code in Executable form only if the requirements of Section 3.1-3.5 have been met for that Covered Code, and if You include a notice stating that the Source Code version of the Covered Code is available under the terms of this License, including a description of how and where You have fulfilled the obligations of Section 3.2. The notice must be conspicuously included in any notice in an Executable version, related documentation or collateral in which You
describe recipients' rights relating to the Covered Code. You may distribute the Executable version of Covered Code under a license of Your choice, which may contain terms different from this License,
provided that You are in compliance with the terms of this License and that the license for the Executable version does not attempt to limit or alter the recipient's rights in the Source Code version from the rights set forth in this License. If You distribute the Executable version under a different license You must make it absolutely clear that any terms which differ from this License are offered by You alone, not by the Initial Developer or any Contributor. You hereby agree to indemnify the Initial Developer and every Contributor for any liability incurred by the Initial Developer or such Contributor as a result of any such terms You offer.

3.7. Larger Works.
You may create a Larger Work by combining Covered Code with other code not governed by the terms of this License and distribute the Larger Work as a single product. In such a case, You must make sure the requirements of this License are fulfilled for the Covered Code.

4. Inability to Comply Due to Statute or Regulation.

If it is impossible for You to comply with any of the terms of this License with respect to some or all of the Covered Code due to statute or regulation then You must: (a) comply with the terms of this License to the maximum extent possible; and (b) describe the limitations and the code they affect. Such description must be included in the LEGAL file described in Section 3.4 and must be included with all distributions of the Source Code. Except to the extent prohibited by statute or regulation, such description must be sufficiently detailed for a recipient of ordinary skill to be able to understand it.

5. Application of this License.

This License applies to code to which the Initial Developer has attached the notice in Exhibit A, and to related Covered Code.

6. Versions of the License.

6.1. New Versions.
Floris van den Berg may publish revised and/or new versions of the License from time to time. Each version will be given a distinguishing version number.

6.2. Effect of New Versions.
Once Covered Code has been published under a particular version of the License, You may always continue to use it under the terms of that version. You may also choose to use such Covered Code under the terms of any subsequent version of the License published by Floris van den Berg
No one other than Floris van den Berg has the right to modify the terms applicable to Covered Code created under this License.

6.3. Derivative Works.
If you create or use a modified version of this License (which you may only do in order to apply it to code which is not already Covered Code governed by this License), you must (a) rename Your license so that the phrases "FreeImage", `FreeImage Public License", "FIPL", or any confusingly similar phrase do not appear anywhere in your license and (b) otherwise make it clear that your version of the license contains terms which differ from the FreeImage Public License. (Filling in the name of the Initial Developer, Original Code or Contributor in the notice described in Exhibit A shall not of themselves be deemed to be modifications of this License.)

7. DISCLAIMER OF WARRANTY.

COVERED CODE IS PROVIDED UNDER THIS LICENSE ON AN "AS IS" BASIS, WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING, WITHOUT LIMITATION, WARRANTIES THAT THE COVERED CODE IS FREE OF DEFECTS, MERCHANTABLE, FIT FOR A PARTICULAR PURPOSE OR NON-INFRINGING. THE ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE COVERED CODE IS WITH YOU. SHOULD ANY COVERED CODE PROVE DEFECTIVE IN ANY RESPECT, YOU (NOT THE INITIAL DEVELOPER OR ANY OTHER CONTRIBUTOR) ASSUME THE COST OF ANY NECESSARY SERVICING, REPAIR OR CORRECTION. THIS DISCLAIMER OF WARRANTY CONSTITUTES AN ESSENTIAL PART OF THIS LICENSE. NO USE OF ANY COVERED CODE IS AUTHORIZED HEREUNDER EXCEPT UNDER THIS DISCLAIMER.

8. TERMINATION.

This License and the rights granted hereunder will terminate automatically if You fail to comply with terms herein and fail to cure such breach within 30 days of becoming aware of the breach. All sublicenses to the Covered Code which are properly granted shall survive any termination of this License. Provisions which, by their nature, must remain in effect beyond the termination of this License shall survive.

9. LIMITATION OF LIABILITY.

UNDER NO CIRCUMSTANCES AND UNDER NO LEGAL THEORY, WHETHER TORT (INCLUDING NEGLIGENCE), CONTRACT, OR OTHERWISE, SHALL THE INITIAL DEVELOPER, ANY OTHER CONTRIBUTOR, OR ANY DISTRIBUTOR OF COVERED CODE, OR ANY SUPPLIER OF ANY OF SUCH PARTIES, BE LIABLE TO YOU OR ANY OTHER PERSON FOR ANY INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES OF ANY CHARACTER INCLUDING, WITHOUT LIMITATION, DAMAGES FOR LOSS OF GOODWILL, WORK STOPPAGE, COMPUTER FAILURE OR MALFUNCTION, OR ANY AND ALL OTHER COMMERCIAL DAMAGES OR LOSSES, EVEN IF SUCH PARTY SHALL HAVE BEEN INFORMED OF THE POSSIBILITY OF SUCH DAMAGES. THIS LIMITATION OF LIABILITY SHALL NOT APPLY TO LIABILITY FOR DEATH OR PERSONAL INJURY RESULTING FROM SUCH PARTY'S NEGLIGENCE TO THE EXTENT APPLICABLE LAW PROHIBITS SUCH LIMITATION. SOME JURISDICTIONS DO NOT ALLOW THE
EXCLUSION OR LIMITATION OF INCIDENTAL OR CONSEQUENTIAL DAMAGES, SO THAT EXCLUSION AND LIMITATION MAY NOT APPLY TO YOU.

10. U.S. GOVERNMENT END USERS.

The Covered Code is a "commercial item," as that term is defined in 48 C.F.R. 2.101 (Oct. 1995), consisting of "commercial computer software" and "commercial computer software documentation," as such terms are used in 48 C.F.R. 12.212 (Sept. 1995). Consistent with 48 C.F.R. 12.212 and 48 C.F.R. 227.7202-1 through 227.7202-4 (June 1995), all U.S. Government End Users acquire Covered Code with only those rights set forth herein.

11. MISCELLANEOUS.

This License represents the complete agreement concerning subject matter hereof. If any provision of this License is held to be unenforceable, such provision shall be reformed only to the extent necessary to make it enforceable. This License shall be governed by Dutch law provisions (except to the extent applicable law, if any, provides otherwise), excluding its conflict-of-law provisions. With respect to disputes in which at least one party is a citizen of, or an entity chartered or registered to do business in, the The Netherlands: (a) unless otherwise agreed in writing, all disputes relating to this License (excepting any dispute relating to intellectual property rights) shall be subject to final and binding arbitration, with the losing party paying all costs of arbitration; (b) any arbitration relating to this Agreement shall be held in Almelo, The Netherlands; and (c) any litigation relating to this Agreement shall be subject to the jurisdiction of the court of Almelo, The Netherlands with the losing par
ty responsible for costs, including without limitation, court costs and reasonable attorneys fees and expenses. Any law or regulation which provides that the language of a contract shall be construed against the drafter shall not apply to this License.

12. RESPONSIBILITY FOR CLAIMS.

Except in cases where another Contributor has failed to comply with Section 3.4, You are responsible for damages arising, directly or indirectly, out of Your utilization of rights under this License, based
on the number of copies of Covered Code you made available, the revenues you received from utilizing such rights, and other relevant factors. You agree to work with affected parties to distribute
responsibility on an equitable basis.

EXHIBIT A.

"The contents of this file are subject to the FreeImage Public License Version 1.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at http://home.wxs.nl/~flvdberg/freeimage-license.txt

Software distributed under the License is distributed on an "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for the specific language governing rights and limitations under the License.
*-/
*/
/* textblock History - What's new !?
/-*
//s 
V3.0.1.5
 - Added DIBSaveAsAny() function that allow to support all FreeImage file format in save operation

V3.0.1.4
 - Added DIBGetBits() functions. We already have DIBGetInfo(), but if you need to draw the image by yourself, you will the Bits pointer
 - Added DIBIsTransparent() which returns TRUE if the image has transparency
 - Added DIBHasBackgroundColor() return a logical value indicating if the image has embedded it's background color
 - Added	DIBGetBackgroundColor() retrieve the background color
 - Added DIBSetBackgroundColor() set the background color
 - Added DIBStretchExDrawDCBackground() which allow to draw an image transparenlty using a background color or another image (composite operation)
 - Added DIBCreateFromFileEx() to support 1.4.8 bits Icons, and any settings in reading that FreeImage allows
 - Added DIBCreateMemStream,DIBDeleteMemStream,DIBSaveToMemStream,DIBAcquireMemStream for direct memory operation when saving
 - Added AsString Access/Assign  
 - Added DIBPasteSub() to paste a sub image at a specified position
 - Added DIBSetTransparent()
 - Added DIBComposite() to composite a foreground image against a background color or a background image
  
 - Correction a bug in the DIBFromClipboard() function, which was mishandling images data in the Clipboard
 - Correcting a bug in DIBGethandle(). It was always returning a NULL pointer, this was a bug in the FabPaint DLL                                                       
 
 -	Known Bugs:
  In Rotate operation, if you set the background color, you will have black lines in the resulting image.

V3.0.1.3
 - No public release...
 
V3.0.1.2
 - Correcting a bug in SaveAsJPEG() function
 - Now ShowXXX functions are using DrawDibDraw (Screen only)
 - Now StretchXXX functions are using StretchDIBits except DIBStretchEx() and DIBStretchExDC()  
 
V3.0.0.0
 - Now using FreeImage
 - Added FabMultiPage Class to support for multi-page format like TIFF and GIF's
 - Added DIBRotateDeg for rotation in degree
 - Better support for TIFF compressions

V2.0.0.2 (Never released)
 - Added TIFF enhancements

V2.0.0.1
 - Bug correction in EXIF which buggy JPEG support
 - Bug correction in PNG save, using no compression in V2.0
 - Added DIBSetPNGCompressionLevel to set PNG compression. Default to 5 (0: No Compression, 9:Hardest compression)
 - Added DIBSetTIFFCompressionLevel
 - Added DIBEXIFGetTagShortName, DIBEXIFGetTagDescription, DIBEXIFGetTagValue

V2.0
 - Rebuild using Visual Studio .NET, so MS Compiler C7.0
 - Added DIBSetResizeCallBack : Callback used when resizing,; useable to Sleep() during batch processing
 - Added Basic support for EXIF data access (used by Digital Camera); only supported with JPEG files
 - Added DIBEXIFGetSize, DIBEXIFGetTagCommon

V1.3
 - Complete rewrite due to system crash ... and backup unrecoverable ! :-(

V1.2
 - Added Easy-To-Use Class around functions
 - Added Contrast/Intensity/Lightness methods
 - Added FabAutoDoc markers; You can now create a HLP file using FabAutoDoc application
 - Added Exception handlers in all operations that needs 32bpp ( Rotate, Resize, ... )
 - Added ToClipboard/FromClipboard
 - Added DIBGetHandle, so you can draw onto the Image using standard GDI functions
 - Added DIBShowDC, DIBStretchDC, ... so you can give you own Device Context for special needs
 - Added DIBShowEx, DIBStretchEx Functions
 - Added DIBUseGDI so you can force the library to use GDI functions instead of VFW DrawDibDraw function
 - Correcting a bug into DIBCreateFromHBitmap and DIBCreateFromHDib
 - Change the Dynamic Link to Static Link. Now, no more use of pointers to functions & etc

V1.1
 - Added some Filters possibilities, and Copy constructor :
   DIBCreateCopy,DIBStretchDraw,DIBResizeBilinear,DIBResizeBox,DIBResizeGaussian,
   DIBResizeHamming,DIBCrop,DIBMakeGrayscale,DIBRotate,DIBInvert

V 1.0	
 - Made the DLL compatible with CAPAINT
 - Added DIBCreateFromHBitmap, DIBCreateFromHDib, DIBSaveAsJPEG, DIBSaveAsPNG, DIBSaveAsTIFF, DIBSetProgressControl.
 - First Public Release

V 0.9
 - Found www.PaintLib.de, and looking if wrappers for VO were possible
 - Never released
//!
*-/

*/
/* textblock Fab Paint Version 3.0.1.4

*/
