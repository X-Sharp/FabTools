 
USING FreeImageAPI
using System.IO
using System.Windows.Forms
using VO
using FabPaintLib

BEGIN Namespace FabPaintLib

    CLASS FabMultiPage
//p MultiPage Image Manipulation
//d This class encUSINGate MultiPages services of the FabPaint Library
	//
	INTERNAL oMultiObject AS  FIMULTIBITMAP
	
	EXPORT pMultiObject	AS	PTR
	// Owner to notify any changes
	// Object, so same version for VO-GUI or ClassMate.
	PROTECT oOwner		AS	OBJECT
	// Please, don't notify my owner...
	PROTECT lSuspendNotification	AS	LOGIC
	//
	protect aLockPages as array
	//
	
	METHOD __NotifyOwner( symEvent AS SYMBOL ) AS VOID  
	//
	IF ( SELF:oOwner != NULL_OBJECT )
		IF IsMethod( SELF:oOwner, #OnFabPaintLibMulti ) .AND. !SELF:lSuspendNotification
			Send( SELF:oOwner, #OnFabPaintLibMulti, SELF, symEvent )
		ENDIF
	ENDIF
	//
    return

    METHOD AddPage( oImage AS FabPaintLibBase ) AS VOID  
    //p Add a new Page
    //p WARNING : Page number is zero-based
	    //
	    IF SELF:IsValid
		    //
		    FreeImage.AppendPage( Self:oMultiObject, oImage:oDibObject )
	    ENDIF
    RETURN

    DESTRUCTOR() 
	    //
	    SELF:Destroy()
	    //
	    //IF !InCollect()
	    //	UnRegisterAxit( SELF )
	    //ENDIF
	    //
    RETURN 

    METHOD CloneImage( nPage as LONGINT ) as FabPaintLib  
    //r The new FabPaintLib object
    //p Get a page as an Image.
    //p The Image is a copy of the page. 
    //p WARNING : Page number is zero-based

	    LOCAL oCopy	AS	FIBitmap
	    LOCAL oImg  as  FIBitmap
	    LOCAL oNew	AS	FabPaintLib
	    //
	    IF SELF:IsValid
		    oImg := FreeImage.lockPage( self:oMultiObject, nPage)
		    If ( oImg != FIBITMAP.Zero )
		        // Create a copy
		        oCopy := FreeImage.Clone( oImg )
		        // Release the page
		        FreeImage.unlockPage( self:oMultiObject, oImg, false )
		    else
		    endif
		    oNew := FabPaintLib{ oCopy }
	    ENDIF
    RETURN oNew

    METHOD Create( cFile as STRING ) as LOGIC  
    //p Initialize an new Multi Page File
    //a <cFile> Name of the file to read.
    //d This method will read the indicated file, and initialize the object.
    //d The image can be any of : .TIF, .GIF
    //r A logical value indicating the success of the operation
	    //
	    LOCAL Fif as FREE_IMAGE_FORMAT
	    //
	    self:Destroy()
	    Fif := FreeImage.GetFIFFromFileName( cFile )
	    // check for supported file types
	    if(( Fif == FREE_IMAGE_FORMAT.FIF_UNKNOWN) .OR. ;
	        (fif != FREE_IMAGE_FORMAT.FIF_TIFF) .AND. (fif != FREE_IMAGE_FORMAT.FIF_ICO) .AND. (fif != FREE_IMAGE_FORMAT.FIF_GIF) .AND. (fif != FREE_IMAGE_FORMAT.FIF_PSD))
		    return FALSE
	    ENDIF
	    //
	    //Self:oMultiObject := FreeImage.OpenMultiBitmap( Fif, cFile, True, False, False, FREE_IMAGE_LOAD_FLAGS.Default )
	    Self:oMultiObject := FreeImage.OpenMultiBitmapEx( cFile )
	    //
	    self:__NotifyOwner( #CreateFromFile )
	    //
    RETURN self:IsValid

    METHOD CreateFromFile( cFile AS STRING ) AS LOGIC  
    RETURN Self:Create( cFile )

    METHOD DeletePage( nPos AS INT ) AS VOID  
    //p Delete a Page
    //p WARNING : Page number is zero-based
	    //
	    IF SELF:IsValid
		    //
		    FreeImage.DeletePage( Self:oMultiObject, nPos )
	    ENDIF
    return

    METHOD Destroy() AS VOID  
    //p Delete the underlying DIB Object
    //d this Method will close the MultiPage Object, and apply any modifications done
    //d like delete, add, insert pages
	    local oImage as FabPaintLib
	    //
	    IF self:IsValid
		    // Are there still locked pages ?
		    if ( ALen( self:aLockPages ) >0 )
			    // Sorry, will have to unlock them first
			    // You haven't done it....All changes are lost.....
			    while ( ALen( self:aLockPages) > 0 )
				    // The array shrinks when we unlock a page, so works like a stack
				    oImage := self:aLockPages[ 1 ]
				    self:UnlockPage( oImage, false )
			    enddo 
		    endif 
		    //
		    FreeImage.CloseMultiBitmap( Self:oMultiObject, FREE_IMAGE_SAVE_FLAGS.Default )
		    SELF:oMultiObject := FIMULTIBITMAP.Zero
		    //
		    SELF:__NotifyOwner( #Destroy )
		    //
	    ENDIF
	    //
    return

    CONSTRUCTOR( cFile as String )
        // 
        Self:CreateFromFile( cFile )
        //
        self:aLockPages := {}
	RETURN

    CONSTRUCTOR( cFile as String, oOwn as Object )
        // 
	    if ( oOwner != null )
	       self:oOwner := oOwn
	    endif        
	    //
        Self:CreateFromFile( cFile )
        //
        self:aLockPages := {}
	RETURN
        
    CONSTRUCTOR( cFile as FIMULTIBITMAP, oOwn as Object ) 
    //p Initialize a FabMultiPage object
    //a <cFile> Name of the file to use to initialize the object
    //a If Empty, the FabMultiPage object is uninitialized
    //a <oOwner> An object, that want to receive notifications from the
    //a FabMultiPage object when it change.
	    //
        //
	    if ( oOwner != null )
	       self:oOwner := oOwn
	    endif        
	    // This might be an already created C++ Object ( See Copy )
	    SELF:oMultiObject := cFile
	    SELF:__NotifyOwner( #InitPTR )
	    //
	    self:aLockPages := {}
    return 

    METHOD InsertPage( oImage AS FabPaintLibBase, nPos AS INT ) AS VOID  
    //p Insert a new Page
    //p WARNING : Page number is zero-based
	    //
	    IF SELF:IsValid
		    //
		    FreeImage.InsertPage( Self:oMultiObject, nPos, oImage:oDibObject )
	    ENDIF
    return

    ACCESS IsValid AS LOGIC  
    //r A logical value indicating if the object is linked to an image.
    RETURN ( SELF:oMultiObject != FIMULTIBITMAP.Zero )
		

    METHOD LockPage( nPage as LONGINT ) as FabPaintLib  
    //r The new FabPaintLib object
    //p Get a page as an Image.
    //p The Image is the original image of the page.
    //p YOU MUST UNLOCK THE IMAGE 
    //p WARNING : Page number is zero-based
	    LOCAL oCopy	as	FIBitmap
	    LOCAL oNew	as	FabPaintLib
	    //
	    IF self:IsValid
	        //
	        oCopy := FreeImage.LockPage( Self:oMultiObject, nPage )
		    oNew := FabPaintLib{ oCopy }
		    // Track objects
		    AAdd( self:aLockPages, oNew )
	    ENDIF
    RETURN oNew 


    ACCESS PageCount AS LONGINT  
	    LOCAL nPages AS LONGINT
	    //
	    IF SELF:IsValid
		    nPages := FreeImage.GetPageCount( SELF:oMultiObject )
	    ENDIF
    RETURN nPages

    METHOD UnlockPage( oImage as FabPaintLibBase, lApplyChanges as logic ) as void  
    //r The new FabPaintLib object
    //p Get a page as an Image.
    //p The Image is the original image of the page.
    //p YOU MUST UNLOCK THE IMAGE 
    //p WARNING : Page number is zero-based
	    local nFoundAt as dword
	    //
	    IF self:IsValid .and. oImage:IsValid
		    // Known Page ?
		    nFoundAt := AScanExact( self:aLockPages, oImage ) 
		    //
		    if ( nFoundAt != 0 )
			    //
			    FreeImage.UnlockPage( Self:oMultiObject, oImage:oDibObject, lApplyChanges )
			    //
			    ADel( self:aLockPages, nFoundAt )
			    ASize( self:aLockPages, ALen( self:aLockPages)-1)
		    endif 
		    //			 
	    ENDIF
    RETURN 

    END CLASS

END NAMESPACE