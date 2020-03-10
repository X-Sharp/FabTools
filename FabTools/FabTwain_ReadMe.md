# FabTwain

If you are moving a VO application that needs the FabTwain support, the process is the following :

1. Export your VO Application with the XSharp XPorter application
2. Copy to your Visual Studio Solution the needed Projects, and in the References add the projects
    - FabTwain (at Least)
      - If using the Preview features
        - FabPaintLib
        - FabPaintLib_Control
        1. Copy the FreeImage files in the Exe folder
   ( Theses files are in the FreeImage folder, in the FabPaintLib project folder)
            - FreeImage.dll
            - FreeImageNET.dll


You can test the port of the libs using :
- FabTwainTest : The "original" VO Application, that use VO controls
