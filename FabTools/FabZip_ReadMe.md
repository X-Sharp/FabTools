# FabZip

The "new" FabZip library for XSharp has changed the underlying Zip Library.
I'm no more using the DelZip library, but a .NET one that is called DotNetZip : https://github.com/haf/DotNetZip.Semverd

You can either use the DLL reference, or as the FabZip project, use the NuGet package found at : https://www.nuget.org/packages/DotNetZip

If you are moving a VO application that needs the FabZip support, the process is the following :

1. Export your VO Application with the XSharp XPorter application
2. Copy to your Visual Studio Solution the needed Projects, and in the References add the projects
    - FabZip (at Least)
    - FabTools
      - If using VO Controls to get the Zip Events
        - FabZipVo
      - 
        

You can test the port of the libs using :
- Fab_Zip_1_52j_Test : The "original" VO Application, that use VO controls
- FabZip_Test : A Windows Forms Test Application
- NewZipApp : A Windows Forms Test Application