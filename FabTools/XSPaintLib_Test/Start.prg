//
// VN_PaintLib_Test.prg
//

#using System
#using System.Windows.Forms

/// <summary>
/// The main entry point for the application.
/// </summary>
[STAThread] ;
FUNCTION Start() AS VOID
    
   Application.EnableVisualStyles()
   Application.SetCompatibleTextRenderingDefault( false )
   Application.Run( MainWindow{} )
   
