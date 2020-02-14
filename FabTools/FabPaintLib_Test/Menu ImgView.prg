#include "GlobalDefines.vh"
#include "VOGUIClasses.vh"
#include "VOSystemLibrary.vh"
#include "VOWin32APILibrary.vh"
DEFINE IDM_ImgViewShellMenu_File_ID := 29500
DEFINE IDM_ImgViewShellMenu_File_Open_ID := 29501
DEFINE IDM_ImgViewShellMenu_File_Save_As__ID := 29502
DEFINE IDM_ImgViewShellMenu_File_Close_ID := 29503
DEFINE IDM_ImgViewShellMenu_File_Print_ID := 29505
DEFINE IDM_ImgViewShellMenu_File_Print_Setup_ID := 29506
DEFINE IDM_ImgViewShellMenu_File_Send__ID := 29508
DEFINE IDM_ImgViewShellMenu_File_Exit_ID := 29510
DEFINE IDM_ImgViewShellMenu_Edit_ID := 29511
DEFINE IDM_ImgViewShellMenu_Edit_Copy_ID := 29512
DEFINE IDM_ImgViewShellMenu_Edit_Paste_ID := 29513
DEFINE IDM_ImgViewShellMenu_Image_ID := 29514
DEFINE IDM_ImgViewShellMenu_Image_Copy_ID := 29515
DEFINE IDM_ImgViewShellMenu_Image_Copy_No_Change_ID := 29516
DEFINE IDM_ImgViewShellMenu_Image_Copy_1_bpp_ID := 29517
DEFINE IDM_ImgViewShellMenu_Image_Copy_8_bpp_ID := 29518
DEFINE IDM_ImgViewShellMenu_Image_Copy_32_bpp_ID := 29519
DEFINE IDM_ImgViewShellMenu_Image_Resize_ID := 29520
DEFINE IDM_ImgViewShellMenu_Image_Resize_Bilinear_ID := 29521
DEFINE IDM_ImgViewShellMenu_Image_Resize_Box_ID := 29522
DEFINE IDM_ImgViewShellMenu_Image_Resize_Gaussian_ID := 29523
DEFINE IDM_ImgViewShellMenu_Image_Resize_Hamming_ID := 29524
DEFINE IDM_ImgViewShellMenu_Image_Crop_ID := 29525
DEFINE IDM_ImgViewShellMenu_Image_Grayscale_ID := 29526
DEFINE IDM_ImgViewShellMenu_Image_Rotate_ID := 29527
DEFINE IDM_ImgViewShellMenu_Image_Invert_ID := 29528
DEFINE IDM_ImgViewShellMenu_Image_Zoom___ID := 29530
DEFINE IDM_ImgViewShellMenu_Image_Contrast_ID := 29533
DEFINE IDM_ImgViewShellMenu_Image_Lightness_ID := 29534
DEFINE IDM_ImgViewShellMenu_Image_Intensity_ID := 29535
DEFINE IDM_ImgViewShellMenu_Image_EXIF_Data_ID := 29537
DEFINE IDM_ImgViewShellMenu_Window_ID := 29538
DEFINE IDM_ImgViewShellMenu_Window_Cascade_ID := 29539
DEFINE IDM_ImgViewShellMenu_Window_Tile_ID := 29540
DEFINE IDM_ImgViewShellMenu_Window_Close_All_ID := 29541
DEFINE IDM_ImgViewShellMenu_Help_ID := 29542
DEFINE IDM_ImgViewShellMenu_Help_Index_ID := 29543
DEFINE IDM_ImgViewShellMenu_Help_Context_Help_ID := 29544
DEFINE IDM_ImgViewShellMenu_Help_Using_Help_ID := 29545
DEFINE IDM_ImgViewShellMenu_Help_About_ID := 29547
PARTIAL CLASS ImgViewMenu INHERIT ImgViewShellMenu

CONSTRUCTOR(oOwner) 
	//
	SUPER( oOwner )
	SELF:ToolBar := NULL_OBJECT
return 
END CLASS

PARTIAL CLASS ImgViewShellMenu INHERIT Menu

CONSTRUCTOR( oOwner )

	LOCAL oTB AS Toolbar

	SELF:PreInit()

	SUPER( ResourceID { "ImgViewShellMenu" , _GetInst( ) } )

	SELF:RegisterItem(IDM_ImgViewShellMenu_File_ID, ;
		HyperLabel{ #File , "&File" ,  , "File" } , SELF:Handle() , 0)

	SELF:RegisterItem(IDM_ImgViewShellMenu_File_Open_ID, ;
		HyperLabel{ #FileOpen , "&Open...	Ctrl+O" , "Open a file" , "File_Open" })

	SELF:RegisterItem(IDM_ImgViewShellMenu_File_Save_As__ID, ;
		HyperLabel{ #SaveAs , "Save &As ...	Ctrl+A" ,  ,  })

	SELF:RegisterItem(IDM_ImgViewShellMenu_File_Close_ID, ;
		HyperLabel{ #FileClose , "&Close" , "Close current child window" , "File_Close" })

	SELF:RegisterItem(IDM_ImgViewShellMenu_File_Print_ID, ;
		HyperLabel{ #FilePrint , "&Print" , "Print the active window" ,  })

	SELF:RegisterItem(IDM_ImgViewShellMenu_File_Print_Setup_ID, ;
		HyperLabel{ #FilePrinterSetup , "P&rint Setup..." , "Setup printer options" , "File_Printer_Setup" })

	SELF:RegisterItem(IDM_ImgViewShellMenu_File_Send__ID, ;
		HyperLabel{ #SendMail , "&Send ..." , "Send Mail via MS Exchange" ,  })

	SELF:RegisterItem(IDM_ImgViewShellMenu_File_Exit_ID, ;
		HyperLabel{ #FileExit , "E&xit	Alt+F4" , "End of application" , "File_Exit" })

	SELF:RegisterItem(IDM_ImgViewShellMenu_Edit_ID, ;
		HyperLabel{ #ImgViewShellMenu_Edit , "&Edit" ,  ,  } , SELF:Handle() , 1)

	SELF:RegisterItem(IDM_ImgViewShellMenu_Edit_Copy_ID, ;
		HyperLabel{ #ClipCopy , "&Copy	Ctrl+C" , "Copy the image to Clipboard" ,  })

	SELF:RegisterItem(IDM_ImgViewShellMenu_Edit_Paste_ID, ;
		HyperLabel{ #ClipPaste , "&Paste	Ctrl+P" , "Paste from Clipboard" ,  })

	SELF:RegisterItem(IDM_ImgViewShellMenu_Image_ID, ;
		HyperLabel{ #ImgViewShellMenu_Image , "&Image" ,  ,  } , SELF:Handle() , 2)

	SELF:RegisterItem(IDM_ImgViewShellMenu_Image_Copy_ID, ;
		HyperLabel{ #ImgCopy , "&Copy" ,  ,  } , GetSubMenu( SELF:Handle() , 2 ) , 0)

	SELF:RegisterItem(IDM_ImgViewShellMenu_Image_Copy_No_Change_ID, ;
		HyperLabel{ #ImgCopy0 , "No Change" ,  ,  })

	SELF:RegisterItem(IDM_ImgViewShellMenu_Image_Copy_1_bpp_ID, ;
		HyperLabel{ #ImgCopy1 , "1 bpp" ,  ,  })

	SELF:RegisterItem(IDM_ImgViewShellMenu_Image_Copy_8_bpp_ID, ;
		HyperLabel{ #ImgCopy8 , "8 bpp" ,  ,  })

	SELF:RegisterItem(IDM_ImgViewShellMenu_Image_Copy_32_bpp_ID, ;
		HyperLabel{ #ImgCopy32 , "32 bpp" ,  ,  })

	SELF:RegisterItem(IDM_ImgViewShellMenu_Image_Resize_ID, ;
		HyperLabel{ #ImgViewShellMenu_Image_Resize , "&Resize" ,  ,  } , GetSubMenu( SELF:Handle() , 2 ) , 1)

	SELF:RegisterItem(IDM_ImgViewShellMenu_Image_Resize_Bilinear_ID, ;
		HyperLabel{ #ImgRBili , "Bilinear" ,  ,  })

	SELF:RegisterItem(IDM_ImgViewShellMenu_Image_Resize_Box_ID, ;
		HyperLabel{ #ImgRBox , "Box" ,  ,  })

	SELF:RegisterItem(IDM_ImgViewShellMenu_Image_Resize_Gaussian_ID, ;
		HyperLabel{ #ImgRGauss , "Gaussian" ,  ,  })

	SELF:RegisterItem(IDM_ImgViewShellMenu_Image_Resize_Hamming_ID, ;
		HyperLabel{ #ImgRHamming , "Hamming" ,  ,  })

	SELF:RegisterItem(IDM_ImgViewShellMenu_Image_Crop_ID, ;
		HyperLabel{ #ImgCrop , "Cr&op" ,  ,  })

	SELF:RegisterItem(IDM_ImgViewShellMenu_Image_Grayscale_ID, ;
		HyperLabel{ #ImgGray , "&Grayscale" ,  ,  })

	SELF:RegisterItem(IDM_ImgViewShellMenu_Image_Rotate_ID, ;
		HyperLabel{ #ImgRotate , "Ro&tate" ,  ,  })

	SELF:RegisterItem(IDM_ImgViewShellMenu_Image_Invert_ID, ;
		HyperLabel{ #ImgInvert , "&Invert" ,  ,  })

	SELF:RegisterItem(IDM_ImgViewShellMenu_Image_Zoom___ID, ;
		HyperLabel{ #ZoomIn , "Zoom +" ,  ,  })

	SELF:RegisterItem(IDM_ImgViewShellMenu_Image_Zoom___ID, ;
		HyperLabel{ #ZoomOut , "Zoom -" ,  ,  })

	SELF:RegisterItem(IDM_ImgViewShellMenu_Image_Contrast_ID, ;
		HyperLabel{ #ImgContrast , "Contrast" ,  ,  })

	SELF:RegisterItem(IDM_ImgViewShellMenu_Image_Lightness_ID, ;
		HyperLabel{ #ImgLightness , "Lightness" ,  ,  })

	SELF:RegisterItem(IDM_ImgViewShellMenu_Image_Intensity_ID, ;
		HyperLabel{ #ImgIntensity , "Intensity" ,  ,  })

	SELF:RegisterItem(IDM_ImgViewShellMenu_Image_EXIF_Data_ID, ;
		HyperLabel{ #EXIFData , "EXIF Data" ,  ,  })

	SELF:RegisterItem(IDM_ImgViewShellMenu_Window_ID, ;
		HyperLabel{ #Window , "&Window" , "Arrange child windows" ,  } , SELF:Handle() , 3)

	SELF:RegisterItem(IDM_ImgViewShellMenu_Window_Cascade_ID, ;
		HyperLabel{ #WindowCascade , "&Cascade" , "Arrange child windows in a cascade" , "WindowCascade" })

	SELF:RegisterItem(IDM_ImgViewShellMenu_Window_Tile_ID, ;
		HyperLabel{ #WindowTile , "&Tile" , "Arrange child windows tiled" , "WindowTile" })

	SELF:RegisterItem(IDM_ImgViewShellMenu_Window_Close_All_ID, ;
		HyperLabel{ #CloseAllChildren , "Close A&ll" , "Close all child windows" , "WindowCloseAll" })

	SELF:RegisterItem(IDM_ImgViewShellMenu_Help_ID, ;
		HyperLabel{ #Help , "&Help" ,  ,  } , SELF:Handle() , 4)

	SELF:RegisterItem(IDM_ImgViewShellMenu_Help_Index_ID, ;
		HyperLabel{ #HelpIndex , "&Index	F1" , "Index of help" , "Help_Index" })

	SELF:RegisterItem(IDM_ImgViewShellMenu_Help_Context_Help_ID, ;
		HyperLabel{ #HelpContext , "&Context Help	Ctrl+F1" , "Context sensitive help" , "Help_ContextHelp" })

	SELF:RegisterItem(IDM_ImgViewShellMenu_Help_Using_Help_ID, ;
		HyperLabel{ #HelpUsingHelp , "&Using Help" , "How to use help" , "Help_UsingHelp" })

	SELF:RegisterItem(IDM_ImgViewShellMenu_Help_About_ID, ;
		HyperLabel{ #HelpAboutDialog , "&About..." , "About application" ,  })

	SELF:SetAutoUpdate( 3 )

	oTB := Toolbar{}

	oTB:ButtonStyle := TB_ICONONLY
	oTB:Flat := TRUE
	oTB:EnableBands(FALSE)

	oTB:AppendItem(IDT_ZOOMIN , IDM_ImgViewShellMenu_Image_Zoom___ID)
	oTB:AddTipText(IDT_ZOOMIN , IDM_ImgViewShellMenu_Image_Zoom___ID , "Zoom In")

	oTB:AppendItem(IDT_ZOOMOUT , IDM_ImgViewShellMenu_Image_Zoom___ID)
	oTB:AddTipText(IDT_ZOOMOUT , IDM_ImgViewShellMenu_Image_Zoom___ID , "Zoom Out")


	SELF:ToolBar := oTB
	SELF:Accelerator := ImgViewShellMenu_Accelerator{ }

	SELF:PostInit()

	RETURN

END CLASS

PARTIAL CLASS ImgViewShellMenu_Accelerator INHERIT Accelerator

CONSTRUCTOR()
	SUPER( ResourceID { "ImgViewShellMenu_Accelerator" , _GetInst( ) } )
RETURN


END CLASS

