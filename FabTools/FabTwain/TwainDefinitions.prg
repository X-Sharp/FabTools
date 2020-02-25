#region DEFINES
DEFINE CAP_AUTHOR                  := 0x1000
DEFINE CAP_AUTOFEED                := 0x1007
DEFINE CAP_AUTOSCAN                := 0x1010   /* Added 1.6 */
DEFINE CAP_CAPTION                 := 0x1001
DEFINE CAP_CLEARPAGE               := 0x1008
DEFINE CAP_DEVICEONLINE            := 0x100f   /* Added 1.6 */
DEFINE CAP_EXTENDEDCAPS            := 0x1006
DEFINE CAP_FEEDERENABLED           := 0x1002
DEFINE CAP_FEEDERLOADED            := 0x1003
DEFINE CAP_FEEDPAGE                := 0x1009
DEFINE CAP_INDICATORS              := 0x100b   /* Added 1.1 */
DEFINE CAP_PAPERDETECTABLE         := 0x100d   /* Added 1.6 */
DEFINE CAP_REWINDPAGE              := 0x100a
DEFINE CAP_SUPPORTEDCAPS           := 0x1005
DEFINE CAP_SUPPORTEDCAPSEXT        := 0x100c   /* Added 1.6 */
DEFINE CAP_TIMEDATE                := 0x1004
DEFINE CAP_UICONTROLLABLE          := 0x100e   /* Added 1.6 */
DEFINE CAP_XFERCOUNT          := 0x0001
DEFINE DAT_AUDIOFILEXFER   := 0x0201
/* Null data                            */
DEFINE DAT_AUDIOINFO       := 0x0202
/* TW_AUDIOINFO                         */
DEFINE DAT_AUDIONATIVEXFER := 0x0203
/* TW_UINT32 handle to WAV, (AIFF Mac)  */
DEFINE DAT_CAPABILITY      := 0x0001
/* TW_CAPABILITY                        */
DEFINE DAT_CIECOLOR        := 0x0106
/* TW_CIECOLOR                          */
DEFINE DAT_CUSTOMBASE      := 0x8000
/* Base of custom DATs.  */
/* Data Argument Types for the DG_CONTROL Data Group. */
DEFINE DAT_CUSTOMDSDATA    := 0x000c
/* TW_CUSTOMDSDATA.                     */
/* Added 1.8 */
DEFINE DAT_DEVICEEVENT     := 0x000d
/* TW_DEVICEEVENT                       */
DEFINE DAT_EVENT           := 0x0002
/* TW_EVENT                             */
DEFINE DAT_EXTIMAGEINFO    := 0x010b
/* TW_EXTIMAGEINFO -- for 1.7 Spec.     */
/* Added 1.8 */
/* Data Argument Types for the DG_AUDIO Data Group. */
DEFINE DAT_FILESYSTEM      := 0x000e
/* TW_FILESYSTEM                        */
DEFINE DAT_GRAYRESPONSE    := 0x0107
/* TW_GRAYRESPONSE                      */
DEFINE DAT_IDENTITY        := 0x0003
/* TW_IDENTITY                          */
DEFINE DAT_IMAGEFILEXFER   := 0x0105
/* Null data                            */
DEFINE DAT_IMAGEINFO       := 0x0101
/* TW_IMAGEINFO                         */
DEFINE DAT_IMAGELAYOUT     := 0x0102
/* TW_IMAGELAYOUT                       */
DEFINE DAT_IMAGEMEMXFER    := 0x0103
/* TW_IMAGEMEMXFER                      */
DEFINE DAT_IMAGENATIVEXFER := 0x0104
/* TW_UINT32 loword is hDIB, PICHandle  */
DEFINE DAT_JPEGCOMPRESSION := 0x0109
/* TW_JPEGCOMPRESSION                   */
DEFINE DAT_NULL            := 0x0000
/* No data or structure. */
DEFINE DAT_PALETTE8        := 0x010a
/* TW_PALETTE8                          */
DEFINE DAT_PARENT          := 0x0004
/* TW_HANDLE, application win handle in Windows */
DEFINE DAT_PASSTHRU        := 0x000f
/* TW_PASSTHRU                          */
/* Data Argument Types for the DG_IMAGE Data Group. */
DEFINE DAT_PENDINGXFERS    := 0x0005
/* TW_PENDINGXFERS                      */
DEFINE DAT_RGBRESPONSE     := 0x0108
/* TW_RGBRESPONSE                       */
DEFINE DAT_SETUPFILEXFER   := 0x0007
/* TW_SETUPFILEXFER                     */
DEFINE DAT_SETUPMEMXFER    := 0x0006
/* TW_SETUPMEMXFER                      */
DEFINE DAT_STATUS          := 0x0008
/* TW_STATUS                            */
DEFINE DAT_TWUNKIDENTITY   := 0x000b
/* TW_TWUNKIDENTITY                     */
DEFINE DAT_USERINTERFACE   := 0x0009
/* TW_USERINTERFACE                     */
DEFINE DAT_XFERGROUP       := 0x000a
/* TW_UINT32                            */
/*  SDH - 03/21/95 - TWUNK                                         */
/*  Additional message required for thunker to request the special */
/*  identity information.                                          */
DEFINE DG_AUDIO            := 0x0004L
/* data pertaining to audio */
/****************************************************************************
* Data Argument Types                                                      *
****************************************************************************/
/*  SDH - 03/23/95 - WATCH                                                  */
/*  The thunker requires knowledge about size of data being passed in the   */
/*  lpData parameter to DS_Entry (which is not readily available due to     */
/*  type LPVOID.  Thus, we key off the DAT_ argument to determine the size. */
/*  This has a couple implications:                                         */
/*  1) Any additional DAT_ features require modifications to the thunk code */
/*     for thunker support.                                                 */
/*  2) Any applications which use the custom capabailites are not supported */
/*     under thunking since we have no way of knowing what size data (if    */
/*     any) is being passed.                                                */
DEFINE DG_CONTROL          := 0x0001L
/* data pertaining to control       */
DEFINE DG_IMAGE            := 0x0002L
/* data pertaining to raster images */
/* Added 1.8 */
DEFINE DSM_ENTRYPOINT 	:=	"DSM_Entry"
DEFINE DSM_FILENAME 	:=	"TWAIN_32.DLL"
DEFINE ICAP_AUTOBRIGHT        := 0x1100
DEFINE ICAP_BITDEPTH          := 0x112b
DEFINE ICAP_BITDEPTHREDUCTION := 0x112c           /* Added 1.5 */
DEFINE ICAP_BITORDER          := 0x111c
DEFINE ICAP_BITORDERCODES     := 0x1126
DEFINE ICAP_BRIGHTNESS        := 0x1101
DEFINE ICAP_CCITTKFACTOR      := 0x111d
DEFINE ICAP_COMPRESSION       := 0x0100
DEFINE ICAP_CONTRAST          := 0x1103
DEFINE ICAP_CUSTHALFTONE      := 0x1104
DEFINE ICAP_EXPOSURETIME      := 0x1105
DEFINE ICAP_FILTER            := 0x1106
DEFINE ICAP_FLASHUSED         := 0x1107
DEFINE ICAP_FRAMES            := 0x1114
DEFINE ICAP_GAMMA             := 0x1108
DEFINE ICAP_HALFTONES         := 0x1109
DEFINE ICAP_HIGHLIGHT         := 0x110a
DEFINE ICAP_IMAGEFILEFORMAT   := 0x110c
DEFINE ICAP_JPEGPIXELTYPE     := 0x1128
DEFINE ICAP_LAMPSTATE         := 0x110d
DEFINE ICAP_LIGHTPATH         := 0x111e
DEFINE ICAP_LIGHTSOURCE       := 0x110e
DEFINE ICAP_MAXFRAMES         := 0x111a
DEFINE ICAP_ORIENTATION       := 0x1110
DEFINE ICAP_PHYSICALHEIGHT    := 0x1112
DEFINE ICAP_PHYSICALWIDTH     := 0x1111
DEFINE ICAP_PIXELFLAVOR       := 0x111f
DEFINE ICAP_PIXELFLAVORCODES  := 0x1127
DEFINE ICAP_PIXELTYPE         := 0x0101
DEFINE ICAP_PLANARCHUNKY      := 0x1120
DEFINE ICAP_ROTATION          := 0x1121
DEFINE ICAP_SHADOW            := 0x1113
DEFINE ICAP_SUPPORTEDSIZES    := 0x1122
DEFINE ICAP_THRESHOLD         := 0x1123
DEFINE ICAP_TILES             := 0x111b
DEFINE ICAP_TIMEFILL          := 0x112a
DEFINE ICAP_UNDEFINEDIMAGESIZE := 0x112d          /* Added 1.6 */
DEFINE ICAP_UNITS             := 0x0102 /* default is TWUN_INCHES */
DEFINE ICAP_XFERMECH          := 0x0103
DEFINE ICAP_XNATIVERESOLUTION := 0x1116
DEFINE ICAP_XRESOLUTION       := 0x1118
DEFINE ICAP_XSCALING          := 0x1124
DEFINE ICAP_YNATIVERESOLUTION := 0x1117
DEFINE ICAP_YRESOLUTION       := 0x1119
DEFINE ICAP_YSCALING          := 0x1125
DEFINE MSG_CHANGEDIRECTORY   := 0x0801
DEFINE MSG_CHECKSTATUS  := 0x0201 /* Get status information                   */
/* Messages used with a pointer to DAT_PARENT data                          */
DEFINE MSG_CLOSEDS      := 0x0402
/* Close a data source                      */
DEFINE MSG_CLOSEDSM     := 0x0302
/* Close the DSM                            */
/* Messages used with a pointer to a DAT_IDENTITY structure                 */
DEFINE MSG_CLOSEDSOK    := 0x0103
/* Tell the Application. to save the state.         */
/* Added 1.8 */
DEFINE MSG_CLOSEDSREQ   := 0x0102
/* Request for Application. to close DS             */
DEFINE MSG_CREATEDIRECTORY   := 0x0802
DEFINE MSG_CUSTOMBASE   := 0x8000
/* Base of custom messages                  */
/* Generic messages may be used with any of several DATs.                   */
DEFINE MSG_DELETE            := 0x0803
DEFINE MSG_DEVICEEVENT  := 0x0104
/* Some event has taken place               */
/* Messages used with a pointer to a DAT_STATUS structure                   */
DEFINE MSG_DISABLEDS    := 0x0501
/* Disable data transfer in the DS          */
DEFINE MSG_ENABLEDS     := 0x0502
/* Enable data transfer in the DS           */
DEFINE MSG_ENABLEDSUIONLY  := 0x0503
/* Enable for saving DS state only.     */
/* Messages used with a pointer to a DAT_EVENT structure                    */
DEFINE MSG_ENDXFER      := 0x0701
/* Added 1.8 */
/* Messages used with a pointer to a DAT_FILESYSTEM structure               */
DEFINE MSG_FORMATMEDIA       := 0x0804
DEFINE MSG_GET          := 0x0001
/* Get one or more values                   */
DEFINE MSG_GETCLOSE          := 0x0805
DEFINE MSG_GETCURRENT   := 0x0002
/* Get current value                        */
DEFINE MSG_GETDEFAULT   := 0x0003
/* Get default (e.g. power up) value        */
DEFINE MSG_GETFIRST     := 0x0004
/* Get first of a series of items, e.g. DSs */
DEFINE MSG_GETFIRSTFILE      := 0x0806
DEFINE MSG_GETINFO           := 0x0807
DEFINE MSG_GETNEXT      := 0x0005
/* Iterate through a series of items.       */
DEFINE MSG_GETNEXTFILE       := 0x0808
DEFINE MSG_NULL         := 0x0000
/* Used in TW_EVENT structure               */
DEFINE MSG_OPENDS       := 0x0401
/* Open a data source                       */
DEFINE MSG_OPENDSM      := 0x0301
/* Open the DSM                             */
DEFINE MSG_PASSTHRU          := 0x0901
DEFINE MSG_PROCESSEVENT := 0x0601
/* Messages used with a pointer to a DAT_PENDINGXFERS structure             */
DEFINE MSG_QUERYSUPPORT := 0x0008
/* Get supported operations on the cap.     */
/* Messages used with DAT_NULL                                              */
DEFINE MSG_RENAME            := 0x0809
/* Messages used with a pointer to a DAT_PASSTHRU structure                 */
DEFINE MSG_RESET        := 0x0007
/* Set current value to default value       */
DEFINE MSG_SET          := 0x0006
/* Set one or more values                   */
DEFINE MSG_USERSELECT   := 0x0403
/* Put up a dialog of all DS                */
/* Messages used with a pointer to a DAT_USERINTERFACE structure            */
DEFINE MSG_XFERREADY    := 0x0101
/* The data source has data ready           */
DEFINE	NO_TWAIN_STATE 	:= 0	
// internal use only
DEFINE	PRE_SESSION		:= 1	
//ground state, nothing loaded
DEFINE	SOURCE_ENABLED := 5			
// acquisition started
DEFINE	SOURCE_MANAGER_LOADED := 2	
// DSM loaded but not open
DEFINE	SOURCE_MANAGER_OPEN := 3
// DSM open
DEFINE	SOURCE_OPEN := 4			
// some Source open - Negotiation state!
DEFINE	TRANSFER_READY := 6			
// data ready to transfer
DEFINE	TRANSFERRING := 7		

ENUM TwainState AS DWORD
	MEMBER	NO_TWAIN_STATE 	:= 0		// internal use only
	MEMBER	PRE_SESSION		:= 1		//ground state, nothing loaded
	MEMBER	SOURCE_MANAGER_LOADED := 2	// DSM loaded but not open
	MEMBER	SOURCE_MANAGER_OPEN := 3    // DSM open
	MEMBER	SOURCE_OPEN := 4			// some Source open - Negotiation state!
	MEMBER	SOURCE_ENABLED := 5			// acquisition started
	MEMBER	TRANSFER_READY := 6			// data ready to transfer
	MEMBER	TRANSFERRING := 7	
END ENUM

// transfer started
DEFINE TWCC_BADCAP        :=  6
/* Unknown capability                        */
DEFINE TWCC_BADDEST       :=  12
/* Unknown destination App/Src in DSM_Entry */
DEFINE TWCC_BADPROTOCOL   :=  9
/* Unrecognized MSG DG DAT combination       */
DEFINE TWCC_BADVALUE      :=  10
/* Data parameter out of range              */
DEFINE TWCC_BUMMER        :=  1
/* Failure due to unknown causes             */
DEFINE TWCC_CAPBADOPERATION:= 14
/* Operation not supported by capability         */
DEFINE TWCC_CAPSEQERROR   :=  15
/* Capability has dependancy on other capability */
DEFINE TWCC_CAPUNSUPPORTED:=  13
/* Capability not supported by source            */
DEFINE TWCC_CHECKDEVICEONLINE  := 23  /* The device went offline prior to or during this operation */
DEFINE TWCC_CUSTOMBASE    := 0x8000
/* Condition Codes: App gets these by doing DG_CONTROL DAT_STATUS MSG_GET.  */
DEFINE TWCC_DENIED             := 16 /* File System operation is denied (file is protected) */
DEFINE TWCC_FILEEXISTS         := 17 /* Operation failed because file already exists. */
DEFINE TWCC_FILENOTFOUND       := 18 /* File not found */
DEFINE TWCC_FILEWRITEERROR     := 22  /* Error writing the file (meant for things like disk full conditions) */
DEFINE TWCC_LOWMEMORY     :=  2
/* Not enough memory to perform operation    */
DEFINE TWCC_MAXCONNECTIONS:=  4
/* DS is connected to max possible apps      */
DEFINE TWCC_NODS          :=  3
/* No Data Source                            */
DEFINE TWCC_NOTEMPTY           := 19 /* Operation failed because directory is not empty */
DEFINE TWCC_OPERATIONERROR:=  5
/* DS or DSM reported error, app shouldn't   */
DEFINE TWCC_PAPERDOUBLEFEED    := 21  /* The feeder detected multiple pages */
DEFINE TWCC_PAPERJAM           := 20  /* The feeder is jammed */
DEFINE TWCC_SEQERROR      :=  11
/* DG DAT MSG out of expected sequence      */
DEFINE TWCC_SUCCESS       :=  0
/* It worked!                                */
DEFINE	TWERR_CAP_SET := 5			
// capability set failed
DEFINE TWERR_CREATEFILE := 102
//Cannot create file in SaveNative
DEFINE	TWERR_ENABLE_SOURCE := 2	
// unable to enable Datasource
DEFINE TWERR_GLOBALALLOC := 100
//Cannot allocate memory in SetCapOneValue
DEFINE TWERR_LOCKMEMORY := 101
//Cannot lock memory in SaveNative
DEFINE	TWERR_NOT_4	:= 3			
// capability set outside state 4 (SOURCE_OPEN)
DEFINE	TWERR_OPEN_DSM := 0			
// unable to load or open Source Manager
DEFINE	TWERR_OPEN_SOURCE := 1		
// unable to open Datasource
DEFINE TWMF_APPOWNS     :=0x1
/* Flags used in TW_MEMORY structure. */
DEFINE TWMF_DSMOWNS     :=0x2
DEFINE TWMF_DSOWNS      :=0x4
DEFINE TWMF_HANDLE      :=0x10
DEFINE TWMF_POINTER     :=0x8
DEFINE TWON_ARRAY           := 3 /* indicates TW_ARRAY container       */
DEFINE TWON_DONTCARE16      := 0xffff
DEFINE TWON_DONTCARE32      := 0xffffffff
DEFINE TWON_DONTCARE8       := 0xff
DEFINE TWON_DSMCODEID       := 63  /* res Id of the Mac SM Code resource     */
DEFINE TWON_DSMID           := 461 /* res Id of the DSM version num resource */
DEFINE TWON_ENUMERATION     := 4 /* indicates TW_ENUMERATION container */
DEFINE TWON_ICONID          := 962 /* res Id of icon used in USERSELECT lbox */
DEFINE TWON_ONEVALUE        := 5 /* indicates TW_ONEVALUE container    */
DEFINE TWON_PROTOCOLMAJOR := 1
DEFINE TWON_PROTOCOLMINOR := 7
/* Changed for Version 1.7            */
DEFINE TWON_RANGE           := 6 /* indicates TW_RANGE container       */
DEFINE TWPT_BW          := 0 /* Black and White */
DEFINE TWPT_CIEXYZ      := 8
DEFINE TWPT_CMY         := 4
DEFINE TWPT_CMYK        := 5
DEFINE TWPT_GRAY        := 1
DEFINE TWPT_PALETTE     := 3
DEFINE TWPT_RGB         := 2
DEFINE TWPT_YUV         := 6
DEFINE TWPT_YUVK        := 7
DEFINE TWQC_GET           :=0x0001
DEFINE TWQC_GETCURRENT    :=0x0008
DEFINE TWQC_GETDEFAULT    :=0x0004
DEFINE TWQC_RESET         :=0x0010
/* bit patterns: for query the operation that are supported by the data source on a capability */
/* App gets these through DG_CONTROL/DAT_CAPABILITY/MSG_QUERYSUPPORT */
/* Added 1.6 */
DEFINE TWQC_SET           :=0x0002
DEFINE TWRC_CANCEL        :=   3
DEFINE TWRC_CHECKSTATUS   :=   2
/* "tried hard"; get status                  */
DEFINE TWRC_CUSTOMBASE    := 0x8000
/* Return Codes: DSM_Entry and DS_Entry may return any one of these values. */
DEFINE TWRC_DATANOTAVAILABLE:= 9
DEFINE TWRC_DSEVENT       :=   4
DEFINE TWRC_ENDOFLIST     :=   7
/* After MSG_GETNEXT if nothing left         */
DEFINE TWRC_FAILURE       :=   1
/* App may get TW_STATUS for info on failure */
DEFINE TWRC_INFONOTSUPPORTED:= 8
DEFINE TWRC_NOTDSEVENT    :=   5
DEFINE TWRC_SUCCESS       :=   0
DEFINE TWRC_XFERDONE      :=   6

ENUM TwainResultCode AS DWORD
	MEMBER TWRC_SUCCESS       :=   0
	MEMBER TWRC_FAILURE       :=   1	/* App may get TW_STATUS for info on failure */
	MEMBER TWRC_CHECKSTATUS   :=   2	/* "tried hard"; get status                  */
	MEMBER TWRC_CANCEL        :=   3
	MEMBER TWRC_DSEVENT       :=   4
	MEMBER TWRC_NOTDSEVENT    :=   5
	MEMBER TWRC_XFERDONE      :=   6	
	MEMBER TWRC_ENDOFLIST     :=   7	/* After MSG_GETNEXT if nothing left         */
	MEMBER TWRC_INFONOTSUPPORTED:= 8
	MEMBER TWRC_DATANOTAVAILABLE:= 9
	MEMBER TWRC_CUSTOMBASE    := 0x8000	/* Return Codes: DSM_Entry and DS_Entry may return any one of these values. */
END ENUM

DEFINE TWTY_BOOL        := 0x0006    /* Means Item is a TW_BOOL   */
DEFINE TWTY_FIX32       := 0x0007    /* Means Item is a TW_FIX32  */
DEFINE TWTY_FRAME       := 0x0008    /* Means Item is a TW_FRAME  */
DEFINE TWTY_INT16       := 0x0001    /* Means Item is a TW_INT16  */
DEFINE TWTY_INT32       := 0x0002    /* Means Item is a TW_INT32  */
DEFINE TWTY_INT8        := 0x0000    /* Means Item is a TW_INT8   */
DEFINE TWTY_STR128      := 0x000b    /* Means Item is a TW_STR128 */
DEFINE TWTY_STR255      := 0x000c    /* Means Item is a TW_STR255 */
DEFINE TWTY_STR32       := 0x0009    /* Means Item is a TW_STR32  */
DEFINE TWTY_STR64       := 0x000a    /* Means Item is a TW_STR64  */
DEFINE TWTY_UINT16      := 0x0004	// Means Item is a TW_UINT16
DEFINE TWTY_UINT32      := 0x0005    /* Means Item is a TW_UINT32 */
DEFINE TWTY_UINT8       := 0x0003    /* Means Item is a TW_UINT8  */

ENUM TwainType AS DWORD
	MEMBER TWTY_BOOL        := 0x0006    /* Means Item is a TW_BOOL   */
	MEMBER TWTY_FIX32       := 0x0007    /* Means Item is a TW_FIX32  */
	MEMBER TWTY_FRAME       := 0x0008    /* Means Item is a TW_FRAME  */
	MEMBER TWTY_INT16       := 0x0001    /* Means Item is a TW_INT16  */
	MEMBER TWTY_INT32       := 0x0002    /* Means Item is a TW_INT32  */
	MEMBER TWTY_INT8        := 0x0000    /* Means Item is a TW_INT8   */
	MEMBER TWTY_STR128      := 0x000b    /* Means Item is a TW_STR128 */
	MEMBER TWTY_STR255      := 0x000c    /* Means Item is a TW_STR255 */
	MEMBER TWTY_STR32       := 0x0009    /* Means Item is a TW_STR32  */
	MEMBER TWTY_STR64       := 0x000a    /* Means Item is a TW_STR64  */
	MEMBER TWTY_UINT16      := 0x0004	// Means Item is a TW_UINT16
	MEMBER TWTY_UINT32      := 0x0005    /* Means Item is a TW_UINT32 */
	MEMBER TWTY_UINT8       := 0x0003    /* Means Item is a TW_UINT8  */
END ENUM



DEFINE TWUN_CENTIMETERS := 1
DEFINE TWUN_INCHES      := 0
DEFINE TWUN_PICAS       := 2
DEFINE TWUN_PIXELS      := 5
DEFINE TWUN_POINTS      := 3
DEFINE TWUN_TWIPS       := 4

ENUM TwainUnity AS WORD
	MEMBER TWUN_INCHES      := 0
	MEMBER TWUN_CENTIMETERS := 1
	MEMBER TWUN_PICAS       := 2
	MEMBER TWUN_POINTS      := 3
	MEMBER TWUN_TWIPS       := 4
	MEMBER TWUN_PIXELS      := 5
END ENUM 

DEFINE XFER_FILE := 1
// To do
DEFINE XFER_MEMORY := 2
// To do
DEFINE XFER_NATIVE := 0
// Default Mode

ENUM TwainTransfer AS WORD
	MEMBER XFER_NATIVE := 0
	MEMBER XFER_FILE := 1
	MEMBER XFER_MEMORY := 2
END ENUM

#endregion

//STATIC FUNCTION __FabDSM_Entry( pOrigin AS TW_IDENTITY, pDest AS TW_IDENTITY, dg AS DWORD, dat AS WORD, msg AS WORD, pd AS PTR ) AS SHORT PASCAL
//	RETURN 0

/**********************************************************************
* Function: DSM_Entry, the only entry point into the Data Source Manager.
*
* Parameters:
*  pOrigin Identifies the source module of the message. This could
*          identify an Application, a Source, or the Source Manager.
*
*  pDest   Identifies the destination module for the message.
*          This could identify an application or a data source.
*          If this is NULL, the message goes to the Source Manager.
*
*  DG      The Data Group.
*          Example: DG_IMAGE.
*
*  DAT     The Data Attribute Type.
*          Example: DAT_IMAGEMEMXFER.
*
*  MSG     The message.  Messages are interpreted by the destination module
*          with respect to the Data Group and the Data Attribute Type.
*          Example: MSG_GET.
*
*  pData   A pointer to the data structure or variable identified
*          by the Data Attribute Type.
*          Example: (TW_MEMREF)&ImageMemXfer
*                   where ImageMemXfer is a TW_IMAGEMEMXFER structure.
*
* Returns:
*  ReturnCode
*         Example: TWRC_SUCCESS.
*
********************************************************************/


VOSTRUCT TW_CAPABILITY ALIGN 2
	/* DAT_CAPABILITY. Used by application to get/set capability from/in a data source. */
	MEMBER	Cap			AS	WORD	// id of capability to set or get, e.g. CAP_BRIGHTNESS
	MEMBER	ConType		AS	WORD	// TWON_ONEVALUE, _RANGE, _ENUMERATION or _ARRAY
	MEMBER	hContainer	AS	PTR		// Handle to container of type Dat
	
	
	
	VOSTRUCT TW_ENUMERATION ALIGN 2
	MEMBER	ItemType		AS	WORD
	MEMBER	NumItems		AS	DWORD	// How many items in ItemList
	MEMBER	CurrentIndex	AS	DWORD	// Current value is in ItemList[CurrentIndex]
	MEMBER	DefaultIndex	AS	DWORD	// Powerup value is in ItemList[DefaultIndex]
	MEMBER	DIM ItemList[1]	AS	BYTE	// Array of ItemType values starts here
	
	
	
	VOSTRUCT TW_EVENT ALIGN 2
	MEMBER	pEvent		AS	PTR		// Windows pMSG or Mac pEvent.
	MEMBER	TWMessage	AS	WORD	// TW msg from data source, e.g. MSG_XFERREADY
	
	
	VOSTRUCT TW_FIX32 ALIGN 2
	/* Fixed point structure type. */
	MEMBER	Whole		AS	SHORT	// maintains the sign
	MEMBER	Frac		AS	WORD
	
	
	
	UNION TW_FIX32DWORD
	MEMBER	dw		AS	DWORD
	MEMBER	fix32	AS	TW_FIX32
	
	
	VOSTRUCT	TW_FRAME	ALIGN 2
	MEMBER	Left	IS	TW_FIX32DWORD
	MEMBER	Top		IS	TW_FIX32DWORD
	MEMBER	Right	IS	TW_FIX32DWORD
	MEMBER	Bottom	IS	TW_FIX32DWORD
	
	
	VOSTRUCT TW_IDENTITY ALIGN 2
	MEMBER	Id				AS	DWORD			// Unique number generated by Source Manager
	MEMBER	Version			IS	TW_VERSION		// Identifies the piece of code
	MEMBER	ProtocolMajor	AS	WORD			// App and DS must set to TWON_PROTOCOLMAJOR
	MEMBER	ProtocolMinor	AS	WORD			// App and DS must set to TWON_PROTOCOLMINOR
	MEMBER	SupportedGroups	AS	DWORD			// Bit Field or combination of DG_ constants
	MEMBER	DIM Manufacturer[34] AS BYTE		// Manufacturer name, e.g. "Hewlett-Packard"
	MEMBER	DIM ProductFamily[34] AS BYTE		// Product family name, e.g. "ScanJet"
	MEMBER	DIM ProductName[34]	AS	BYTE		// Product name, e.g. "ScanJet Plus"
	
	
VOSTRUCT TW_IMAGEINFO ALIGN 2
	MEMBER	   XResolution		IS	TW_FIX32DWORD	/* Resolution in the horizontal             */
	MEMBER	   YResolution		IS	TW_FIX32DWORD    /* Resolution in the vertical               */
	MEMBER	   ImageWidth		AS	LONG    /* Columns in the image, -1 if unknown by DS*/
	MEMBER	   ImageLength		AS	LONG    /* Rows in the image, -1 if unknown by DS   */
	MEMBER	   SamplesPerPixel	AS	SHORT   /* Number of samples per pixel, 3 for RGB   */
	MEMBER	   DIM BitsPerSample[8] AS SHORT	/* Number of bits for each sample           */
	MEMBER	   BitsPerPixel		AS	SHORT 	/* Number of bits for each padded pixel     */
	MEMBER	   Planar			AS	LOGIC   /* True if Planar, False if chunky          */
	MEMBER	   PixelType		AS	SHORT   /* How to interp data; photo interp (TWPT_) */
	MEMBER	   Compression		AS	WORD    /* How the data is compressed (TWCP_xxxx)   */
	
	
	VOSTRUCT	TW_IMAGELAYOUT ALIGN 2
	/* DAT_IMAGELAYOUT. Provides image layout information in current units. */
	MEMBER	Frame			IS	TW_FRAME	/* Frame coords within larger document */
	MEMBER	DocumentNumber	AS	DWORD
	MEMBER	PageNumber		AS	DWORD
	MEMBER	FrameNumber		AS	DWORD
	
	
	VOSTRUCT TW_IMAGEMEMXFER ALIGN 2
	MEMBER	Compression	AS	WORD	/* How the data is compressed                */
	MEMBER	BytesPerRow	AS	DWORD	/* Number of bytes in a row of data          */
	MEMBER	Columns		AS	DWORD      /* How many columns                          */
	MEMBER	Rows		AS	DWORD         /* How many rows                             */
	MEMBER	XOffset		AS	DWORD      /* How far from the side of the image        */
	MEMBER	YOffset		AS	DWORD      /* How far from the top of the image         */
	MEMBER	BytesWritten	AS	DWORD /* How many bytes written in Memory          */
	MEMBER	Memory		IS	TW_MEMORY		/* Mem struct used to pass actual image data */
	
	
	VOSTRUCT TW_MEMORY ALIGN 2
	MEMBER	Flags	AS	DWORD	/* Any combination of the TWMF_ constants.           */
	MEMBER	Length	AS	DWORD	/* Number of bytes stored in buffer TheMem.          */
	MEMBER	TheMem	AS	PTR		/* Pointer or handle to the allocated memory buffer. */
	
	
	VOSTRUCT	TW_ONEVALUE	ALIGN 2
	MEMBER	ItemType	AS	WORD
	MEMBER	Item		AS	DWORD
	
	
	
	VOSTRUCT TW_PENDINGXFERS ALIGN 2
	MEMBER	Count		AS	WORD
	MEMBER	EOJ			AS	DWORD
	
	
VOSTRUCT TW_SETUPFILEXFER ALIGN 2
MEMBER DIM FileName[256]	AS	BYTE
MEMBER Format	AS	WORD	/* Any TWFF_ constant */
MEMBER VRefNum	AS	SHORT	/* Used for Mac only  */


VOSTRUCT TW_SETUPMEMXFER ALIGN 2
MEMBER	MinBufSize	AS	DWORD
MEMBER	MaxBufSize	AS	DWORD
MEMBER	Preferred	AS	DWORD


VOSTRUCT TW_STATUS ALIGN 2
MEMBER	ConditionCode	AS	WORD	// ANY TWCC_ constant
MEMBER	Reserved		AS	WORD	// Future expansion space
/* DAT_STATUS. Application gets detailed status info from a data source with this. */


VOSTRUCT TW_USERINTERFACE ALIGN 2
MEMBER	ShowUI		AS	WORD	// TW_BOOL, TRUE if DS should bring up its UI
MEMBER	ModalUI		AS	WORD	// TW_BOOL, For Mac only - true if the DS's UI is modal
MEMBER	hParent		AS	PTR		// TW_HANDLE, For windows only - App window handle


VOSTRUCT TW_VERSION ALIGN 2
	MEMBER	MajorNum	AS	WORD	// Major revision number of the software.
	MEMBER	MinorNum	AS	WORD	// Incremental revision number of the software.
	MEMBER	Language	AS	WORD	// e.g. TWLG_SWISSFRENCH
	MEMBER	Country		AS	WORD	// e.g. TWCY_SWITZERLAND
	MEMBER	DIM Info[34]	AS BYTE	// e.g. "1.0b3 Beta release"
	
	
	