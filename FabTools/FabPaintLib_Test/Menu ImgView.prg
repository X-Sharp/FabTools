#include "GlobalDefines.vh"
#include "VOGUIClasses.vh"
#include "VOSystemLibrary.vh"
#include "VOWin32APILibrary.vh"
CLASS ImgViewMenu INHERIT ImgViewShellMenu

CONSTRUCTOR(oOwner) 
	//
	SUPER( oOwner )
	SELF:ToolBar := NULL_OBJECT
return 
END CLASS

CLASS ImgViewShellMenu INHERIT Menu
 

CONSTRUCTOR(oOwner) 
	local oTB as Toolbar

	SELF:PreInit()
	super(ResourceID{"ImgViewShellMenu", _GetInst( )})

	self:RegisterItem(IDM_ImgViewShellMenu_File_ID,	;
		HyperLabel{#File,	;
			"&File",	;
			,	;
			"File"},self:Handle( ),0)
	self:RegisterItem(IDM_ImgViewShellMenu_File_Open_ID,	;
		HyperLabel{#FileOpen,	;
			"&Open...	CTRL+O",	;
			"Open a file",	;
			"File_Open"})
	self:RegisterItem(IDM_ImgViewShellMenu_File_Save_As__ID,	;
		HyperLabel{#SaveAs,	;
			"Save &As ...	CTRL+Q",	;
			,	;
			,})
	self:RegisterItem(IDM_ImgViewShellMenu_File_Close_ID,	;
		HyperLabel{#FileClose,	;
			"&Close",	;
			"Close current child window",	;
			"File_Close"})
	self:RegisterItem(IDM_ImgViewShellMenu_File_Print_ID,	;
		HyperLabel{#FilePrint,	;
			"&Print",	;
			"Print the active window",	;
			,})
	self:RegisterItem(IDM_ImgViewShellMenu_File_Print_Setup_ID,	;
		HyperLabel{#FilePrinterSetup,	;
			"P&rint Setup...",	;
			"Setup printer options",	;
			"File_Printer_Setup"})
	self:RegisterItem(IDM_ImgViewShellMenu_File_Send__ID,	;
		HyperLabel{#SendMail,	;
			"&Send ...",	;
			"Send Mail via MS Exchange",	;
			,})
	self:RegisterItem(IDM_ImgViewShellMenu_File_Exit_ID,	;
		HyperLabel{#FileExit,	;
			"E&xit	ALT+F4",	;
			"End of application",	;
			"File_Exit"})
	self:RegisterItem(IDM_ImgViewShellMenu_Edit_ID,	;
		HyperLabel{#_Edit,	;
			"&Edit",	;
			,	;
			,},self:Handle( ),1)
	self:RegisterItem(IDM_ImgViewShellMenu_Edit_Copy_ID,	;
		HyperLabel{#ClipCopy,	;
			"&Copy	CTRL+C",	;
			"Copy the image to Clipboard",	;
			,})
	self:RegisterItem(IDM_ImgViewShellMenu_Edit_Paste_ID,	;
		HyperLabel{#ClipPaste,	;
			"&Paste	CTRL+P",	;
			"Paste from Clipboard",	;
			,})
	self:RegisterItem(IDM_ImgViewShellMenu_Image_ID,	;
		HyperLabel{#_Image,	;
			"&Image",	;
			,	;
			,},self:Handle( ),2)
	self:RegisterItem(IDM_ImgViewShellMenu_Image_Copy_ID,	;
		HyperLabel{#ImgCopy,	;
			"&Copy",	;
			,	;
			,},GetSubMenu(self:Handle( ),2),0)
	self:RegisterItem(IDM_ImgViewShellMenu_Image_Copy_No_Change_ID,	;
		HyperLabel{#ImgCopy0,	;
			"No Change",	;
			,	;
			,})
	self:RegisterItem(IDM_ImgViewShellMenu_Image_Copy__1_bpp_ID,	;
		HyperLabel{#ImgCopy1,	;
			"1 bpp",	;
			,	;
			,})
	self:RegisterItem(IDM_ImgViewShellMenu_Image_Copy__8_bpp_ID,	;
		HyperLabel{#ImgCopy8,	;
			"8 bpp",	;
			,	;
			,})
	self:RegisterItem(IDM_ImgViewShellMenu_Image_Copy__32_bpp_ID,	;
		HyperLabel{#ImgCopy32,	;
			"32 bpp",	;
			,	;
			,})
	self:RegisterItem(IDM_ImgViewShellMenu_Image_Resize_ID,	;
		HyperLabel{#Image_Resize,	;
			"&Resize",	;
			,	;
			,},GetSubMenu(self:Handle( ),2),1)
	self:RegisterItem(IDM_ImgViewShellMenu_Image_Resize_Bilinear_ID,	;
		HyperLabel{#ImgRBili,	;
			"Bilinear",	;
			,	;
			,})
	self:RegisterItem(IDM_ImgViewShellMenu_Image_Resize_Box_ID,	;
		HyperLabel{#ImgRBox,	;
			"Box",	;
			,	;
			,})
	self:RegisterItem(IDM_ImgViewShellMenu_Image_Resize_Gaussian_ID,	;
		HyperLabel{#ImgRGauss,	;
			"Gaussian",	;
			,	;
			,})
	self:RegisterItem(IDM_ImgViewShellMenu_Image_Resize_Hamming_ID,	;
		HyperLabel{#ImgRHamming,	;
			"Hamming",	;
			,	;
			,})
	self:RegisterItem(IDM_ImgViewShellMenu_Image_Crop_ID,	;
		HyperLabel{#ImgCrop,	;
			"Cr&op",	;
			,	;
			,})
	self:RegisterItem(IDM_ImgViewShellMenu_Image_Grayscale_ID,	;
		HyperLabel{#ImgGray,	;
			"&Grayscale",	;
			,	;
			,})
	self:RegisterItem(IDM_ImgViewShellMenu_Image_Rotate_ID,	;
		HyperLabel{#ImgRotate,	;
			"Ro&tate",	;
			,	;
			,})
	self:RegisterItem(IDM_ImgViewShellMenu_Image_Invert_ID,	;
		HyperLabel{#ImgInvert,	;
			"&Invert",	;
			,	;
			,})
	self:RegisterItem(IDM_ImgViewShellMenu_Image_Zoom_b2_ID,	;
		HyperLabel{#ZoomIn,	;
			"Zoom +",	;
			,	;
			,})
	self:RegisterItem(IDM_ImgViewShellMenu_Image_Zoom__ID,	;
		HyperLabel{#ZoomOut,	;
			"Zoom -",	;
			,	;
			,})
	self:RegisterItem(IDM_ImgViewShellMenu_Image_Contrast_ID,	;
		HyperLabel{#ImgContrast,	;
			"Contrast",	;
			,	;
			,})
	self:RegisterItem(IDM_ImgViewShellMenu_Image_Lightness_ID,	;
		HyperLabel{#ImgLightness,	;
			"Lightness",	;
			,	;
			,})
	self:RegisterItem(IDM_ImgViewShellMenu_Image_Intensity_ID,	;
		HyperLabel{#ImgIntensity,	;
			"Intensity",	;
			,	;
			,})
	self:RegisterItem(IDM_ImgViewShellMenu_Image_EXIF_Data_ID,	;
		HyperLabel{#EXIFData,	;
			"EXIF Data",	;
			,	;
			,})
	self:RegisterItem(IDM_ImgViewShellMenu_Window_ID,	;
		HyperLabel{#Window,	;
			"&Window",	;
			"Arrange child windows",	;
			,},self:Handle( ),3)
	self:RegisterItem(IDM_ImgViewShellMenu_Window_Cascade_ID,	;
		HyperLabel{#WindowCascade,	;
			"&Cascade",	;
			"Arrange child windows in a cascade",	;
			"WindowCascade"})
	self:RegisterItem(IDM_ImgViewShellMenu_Window_Tile_ID,	;
		HyperLabel{#WindowTile,	;
			"&Tile",	;
			"Arrange child windows tiled",	;
			"WindowTile"})
	self:RegisterItem(IDM_ImgViewShellMenu_Window_Close_All_ID,	;
		HyperLabel{#CloseAllChildren,	;
			"Close A&ll",	;
			"Close all child windows",	;
			"WindowCloseAll"})
	self:RegisterItem(IDM_ImgViewShellMenu_Help_ID,	;
		HyperLabel{#Help,	;
			"&Help",	;
			,	;
			,},self:Handle( ),4)
	self:RegisterItem(IDM_ImgViewShellMenu_Help_Index_ID,	;
		HyperLabel{#HelpIndex,	;
			"&Index	F1",	;
			"Index of help",	;
			"Help_Index"})
	self:RegisterItem(IDM_ImgViewShellMenu_Help_Context_Help_ID,	;
		HyperLabel{#HelpContext,	;
			"&Context Help	CTRL+F1",	;
			"Context sensitive help",	;
			"Help_ContextHelp"})
	self:RegisterItem(IDM_ImgViewShellMenu_Help_Using_Help_ID,	;
		HyperLabel{#HelpUsingHelp,	;
			"&Using Help",	;
			"How to use help",	;
			"Help_UsingHelp"})
	self:RegisterItem(IDM_ImgViewShellMenu_Help_About_ID,	;
		HyperLabel{#HelpAboutDialog,	;
			"&About...",	;
			"About application",	;
			,})

	self:SetAutoUpDate( 3 )

	oTB := Toolbar{ }
	oTB:ButtonStyle := TB_ICONONLY
	oTB:EnableBands(FALSE)

	oTB:AppendItem(IDT_ZOOMIN,IDM_ImgViewShellMenu_Image_Zoom_b2_ID)
	oTB:AddTipText(IDT_ZOOMIN,IDM_ImgViewShellMenu_Image_Zoom_b2_ID,"Zoom In")

	oTB:AppendItem(IDT_ZOOMOUT,IDM_ImgViewShellMenu_Image_Zoom__ID)
	oTB:AddTipText(IDT_ZOOMOUT,IDM_ImgViewShellMenu_Image_Zoom__ID,"Zoom Out")

	oTB:Flat := true

	self:ToolBar := oTB

	self:Accelerator := ImgViewShellMenu_Accelerator{ }

	SELF:PostInit()
	return 
END CLASS

CLASS ImgViewShellMenu_Accelerator INHERIT Accelerator
 

CONSTRUCTOR( ) 
	super(ResourceID{"ImgViewShellMenu_Accelerator", _GetInst( )})

	return 
END CLASS

