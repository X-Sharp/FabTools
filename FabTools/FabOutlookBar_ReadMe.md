# FabOutlookBar

If you are moving a VO application that needs the FabOutlookBar support, the process is the following :

1. Export your VO Application with the XSharp XPorter application
2. Copy to your Visual Studio Solution the needed Projects, and in the References add the projects
    - FabOutlookBar
    - FabSplitShellLib

You can test the port of the libs using :
- FabSplitShellTest : The "original" VO Application, that use VO controls
