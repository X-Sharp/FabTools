# FabPaintLib

If you are moving a VO application that needs the FabPaintLib support, the process is the following :

1. Export your VO Application with the XSharp XPorter application
2. Copy to your Visual Studio Solution the needed Projects, and in the References add the projects
    - FabPaintLib (at least)
    - FabPaintLib_Control, if you are using the control to show images
3. Copy the FreeImage files in the Exe folder
   ( Theses files are in the FreeImage folder, in the FabPaintLib project folder)
   - FreeImage.dll
   - FreeImageNET.dll


You can test the port of the libs using :
- FabPaintLib_Test : The "original" VO Application, that use VO controls
- XSPaintLib_Test : The "new" XSharp Application, that use Windows Forms controls