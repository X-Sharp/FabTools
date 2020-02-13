//
// VN_PaintLib_Test.prg
//

#using System
#using System.Windows.Forms

/// <summary>
/// The main entry point for the application.
/// </summary>
[STAThread] ;
FUNCTION Start() AS INT

   LOCAL exitCode AS INT
    
   Application.EnableVisualStyles()
   Application.SetCompatibleTextRenderingDefault( false )
   Application.Run( MainWindow{} )
   
   RETURN exitCode